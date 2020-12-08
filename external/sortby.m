function [Y,b] =  sortby(X,Z)

[~,b] = sort(Z);
Y = X(b,:);
end

