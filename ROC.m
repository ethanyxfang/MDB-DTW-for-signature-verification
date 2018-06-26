function [EER, th] = ROC(FAR, FRR, fplot)
% Calculate the EER

if nargin < 3
    fplot = true;
end

if fplot
    len = 1:length(FAR);
    plot(len, FAR, len, FRR);
end

if FAR(1) > FRR(1)
    D = FAR - FRR;
else 
    D = FRR - FAR;
end

if find(D==0)
    th = find(D==0);
    th = th(1);
    EER = FAR(th);
    return;
end

[~, loc] = find(D<0);
if isempty(loc)
    error('Error: there is no intersection point between FAR and FRR.');
end 

loc = min(loc) - 1;
eerl = D(loc);
eerr = D(loc+1);
th = ((loc+1)*eerl - loc*eerr) / (eerl-eerr);
EERl = -((th-loc-1)*(FAR(loc)) - (th-loc)*(FAR(loc+1)));
EERr = -((th-loc-1)*(FRR(loc)) - (th-loc)*(FRR(loc+1)));
EER = (EERl + EERr) / 2;

end