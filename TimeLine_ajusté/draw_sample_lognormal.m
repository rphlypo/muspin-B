% Générer des échantillons à partir des paramètres estimés d'une loi
% log-normal
function x = draw_sample_lognormal(mu, sigma2,n)
%cumulative density function is given by :
% y = 1/2 + 1/2 erf((log(x)-mu)/sqrt(sigma2*2))
%The inverse, then, is given by :
% x =exp(erfinv(2*y-1)*sqrt(2*sigma2)+mu)
y = rand(n,1);
x = exp(erfinv(2*y-1)*sqrt(2*sigma2)+mu); %without statistics toolbox
% x = logninv (y, mu, sqrt(sigma2)); % with statistics toolbox
end