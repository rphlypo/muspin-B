function [EX, VarX] = logn_params2moments(mu, sigma2)
EX = exp(mu+sigma2/2);
VarX = EX.^2.*(exp(sigma2)-1);
end
    