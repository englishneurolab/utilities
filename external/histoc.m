function x = histoc(y,n)

if ~isempty(y)
[x,~] = histc(y,n);
x = x(:);

else
    x = zeros(length(n),1);
    
end
end