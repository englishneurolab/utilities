% antiRunEpochs

nonrun = zeros(1,length(run.epochs)+1)';
nonrun(2:end,1) = run.epochs(:,2);
nonrun(1,1) = 0;
nonrun(1:end-1,2) = run.epochs(:,1);
nonrun(end,:) = [];


