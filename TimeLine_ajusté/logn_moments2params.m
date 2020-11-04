function[mu,sigma2] = logn_moments2params(EX, VarX)
sigma2 = log(1+VarX/EX.^2);
mu = log(EX)-1/2*sigma2;
end

