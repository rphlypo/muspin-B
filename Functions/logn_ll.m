% estimator de log-vraisemblance des paramètres mu et sigma2
function [mu, sigma] = logn_ll(x)
    n = length(x);
    mu = sum(log(x))/n;
    sigma = sqrt(sum((log(x)-mu).^2)/n);
end