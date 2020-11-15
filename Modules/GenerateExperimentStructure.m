% Generate Experiment Structure
function check = GenerateExperimentStructure()
  
    global Exp

    Exp.Parameters.NumberOfPhases = length(Exp.Parameters.Phases);

    for j = 1:Exp.Parameters.NumberOfPhases
        Phase = Exp.Parameters.Phases{j};
        switch lower(Exp.Parameters.(Phase).Shuffling)
            case 'blocks'
                r = 0;
            case 'trials'
                r = 1;
        end
        Exp.Structure.(Phase) = cell(Exp.Parameters.(Phase).NumberOfBlocks, Exp.Parameters.(Phase).LengthOfBlocks);
        Exp.Structure.(Phase) = sampler(Exp.Parameters.(Phase).Conditions, ...
                                        Exp.Parameters.(Phase).NumberOfBlocks, ...
                                        Exp.Parameters.(Phase).LengthOfBlocks, r);
    end

    function samples = sampler(labels, k, n, replacement)
        % sampling with or without replacement
        m = length(labels);
        if replacement==0 && n<=m,
            for i = 1:k
                rp(i, :) = randperm(m);
            end
        elseif replacement,
            rp = randi(m, k, n);
        else
            error('ValueError', 'if sampling without replacement, n should be smaller than m'); 
        end
        
        samples = labels(rp(:, 1:n));
    end
end