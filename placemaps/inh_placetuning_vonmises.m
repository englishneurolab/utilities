% Von Mises
% https://en.wikipedia.org/wiki/Von_Mises_distribution
xvals = wheel_cms; % used to be ori_radians
yvals = [FR_placecell FR_placecell(:,1)]; % because circular
kappa = 1;

%Set parameters for fit
paramInit = [];
paramInit(1) = maxFR_placecell;
paramInit(2) = kappa;

%Perform fit
[paramBest, mse] = MLFit(@vonMises, paramInit, xvals, imnorm(yvals));
YFitted = vonMises(circ_ang2rad(0:359), paramBest);

%Get tuned orientation
[~,vecTunedPlace] = max(YFitted);

%Get angle at 1/sqrt(2) heigth
[~,vecAngleHalfWidth] = min(abs(YFitted - (max(YFitted)*(1/sqrt(2))) ));

