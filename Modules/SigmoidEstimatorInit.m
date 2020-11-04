function [] = SigmoidEstimatorInit()

Global Exp;

SigParam = ones(1,4);
Exp.SigEst.sigfunc = @(SigParam, Sig_x) (1 ./ (1 + exp(-SigParam(3) .* Sig_x + SigParam(4))));
Exp.SigEst.sigHess = @(SigParam, Sig_x) ((-SigParam(3).^2 * exp(-SigParam(3) .* Sig_x + SigParam(4)))...
    .* (1 + exp(-SigParam(3) .* Sig_x + SigParam(4))).^2 ...
    - (SigParam(3) * exp(-SigParam(3) .* Sig_x + SigParam(4))) ...
    .* 2*(1+exp(-SigParam(3) .* Sig_x + SigParam(4))) .* (-SigParam(3) * exp(-SigParam(3) .* Sig_x + SigParam(4))))...
    ./ ((1 + exp(-SigParam(3) .* Sig_x + SigParam(4))).^4);
Exp.SigEst.SigParam0 = ones(size(SigParam));
syms xs

end