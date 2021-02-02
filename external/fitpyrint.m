function [fmodel,ydata,xdata,paut] = fitpyrint(ACG,xdata,pltq,numStPnts)
% Calculate a piecewise exponential (exp(x) or exp(x^2)) model to fit the positive portion of
% ACGs for PYRs and INTs. This function relies on
% This function assumes your spike times are rounded to 0.2 milliseconds. 
% Zach Saccomano, zsaccomano4@gmail.com
% ------ INPUTS --------
%   'spiks'    -  the spike times
%   'lagmax'    -  max lag of the ACG
%   'bine'   -  bine size of the ACG
%   'pltq'   -  1 if you want to plot the fit, 0 if you don't care
%   'numStPnts'   -  For global optimization, how many start points do you
%                    want in the search space.

% ------ OUTPUTS --------
%   'fmodel'   -  the model
%   'ydata'   -  the observed data
%   'xdata'   -  the positive lags of the ACG
%   'paut'   -  the best fit parameters: each param has an intuitive
%               meaning. They are as follows:
% P(2) + P(4) = the peak height of the ACG+
% P(1) = the slope of the ACG rising out of zero lag
% P(3) = the slope of the ACG on the right side of the peak
% P(4) = the positive fixed point as lag -> Inf
% P(5) = encodes the sharpness of the positive peak



ACGplus = ACG(1+ceil(length(ACG)/2):end);

% Use some heuristics from the empirical distribution to contrain
% optimization
sortacg = sort(ACGplus,'descend'); % sort ACG to find the summit values
tail = ACGplus(end-5:end); % see what the values are like near the tail
for k = 1:3 
    maxInd(k) = find(ACGplus==sortacg(k),1,'first');
end
maxInd = round(mean(maxInd));
xdata = -maxInd+2:(-maxInd+length(ACGplus)+1); % new X axis of centered data.

% Define the bounds for b2, which will restrict the height of the peak and
% the tail to be in the range of the heuristic measurement
peakup = mean(sortacg(1:2)) + 2.*std(sortacg(1:2)) - mean(tail);
peakdown = mean(sortacg(1:2)) - std(sortacg(1:2)) -  mean(tail);
tailup = mean(tail)+std(tail);
taildown = mean(tail)-std(tail);
lb = [0,peakdown,0,taildown,.9];
ub = [3e4,peakup,3e4,tailup,2.1];
ydata = ACGplus;
startPoint = lb + (ub - lb)./2; %Set bounds and initial point.

fun = @(P,x)doubexpo(P,x); % Create function handle for the model

% Define optimization problem
problem = createOptimProblem('lsqcurvefit','x0',startPoint,'objective',fun,...
    'lb',lb,'ub',ub,'xdata',xdata,'ydata',ydata);

% Run optimization with numStPnts start points
if pltq == 1 
ms = MultiStart('PlotFcns',@gsplotbestf);
else
    ms = MultiStart('Display','off');
end
[paut,erroraut,flagaut] = run(ms,problem,numStPnts);
 [fmodel] = doubexpo(paut,xdata);
if pltq == 1 % do you want to plot the fit?
   
    plot(xdata,ydata,'b','linewidth',2); axis square; hold on
    plot(xdata,fmodel,':r','linewidth',3); 
    zstr = {['The left slope =','',num2str(paut(1))],['The right slope =','',num2str(paut(3))],['The peak =','',num2str(paut(2)+paut(4))],['The right fixed point =','',num2str(paut(4))]};
    xlabel(zstr);
end

% Here is the model:
    function [model] = doubexpo(P,x)
        fxmin = (P(2) + P(4)).*exp(-(x.^2)./P(1)); 
        fxplu = P(2).*exp(-(x.^round(P(5)))./P(3)) + P(4); % P(5) is forced to be a 1 or 2 (note the lb is .9 and ub is 2.1.
        fxmin(x>0) = 0;
        fxplu(x<=0) = 0;
        model = fxmin+fxplu;
    end
end

