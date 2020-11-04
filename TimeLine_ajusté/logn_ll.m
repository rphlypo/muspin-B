% estimator de log-vraisemblance des paramètres mu et sigma2
function [mu, sigma2] = logn_ll(x)
    n = length(x);
    mu = sum(log(x))/n;
    sigma2 = sum((log(x)-mu).^2)/n;
end