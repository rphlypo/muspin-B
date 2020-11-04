% Generate Experiment Structure
function check = GenerateExperimentStructure()
  global Exp
  check = 0;

  if strcmp(Exp.Type, 'GazeEEG')  
      Exp.Structure.TEST = cell(Exp.Parameters.TEST.NumberOfBlocks, Exp.Parameters.TEST.LengthOfBlocks);
      for i = 1:Exp.Parameters.TEST.NumberOfBlocks
          Exp.Structure.TEST(i, :) = sampler(Exp.Parameters.TEST.Conditions, Exp.Parameters.TEST.LengthOfBlocks, 0);
      end  
      
      Exp.Structure.LEARN = cell(Exp.Parameters.LEARN.NumberOfBlocks, Exp.Parameters.LEARN.LengthOfBlocks);
      for i = 1:Exp.Parameters.LEARN.NumberOfBlocks
          Exp.Structure.LEARN(i, :) = sampler(Exp.Parameters.LEARN.Conditions, Exp.Parameters.LEARN.LengthOfBlocks, 0);
      end  
    
      Exp.Structure.ESTIM = cell(Exp.Parameters.ESTIM.NumberOfBlocks, Exp.Parameters.ESTIM.LengthOfBlocks);
      for i = 1:Exp.Parameters.ESTIM.NumberOfBlocks
          Exp.Structure.ESTIM(i, :) = sampler(Exp.Parameters.ESTIM.Conditions, Exp.Parameters.ESTIM.LengthOfBlocks, 1);
      end  
  end

  function samples = sampler(labels, n, replacement)
    % sampling with or without replacement
    m = length(labels);
    if ~replacement && n<=m,
        rp = randperm(m);
    elseif replacement,
        rp = randi(m, n);
    else
       error('ValueError', 'if sampling without replacement n should be smaller than m'); 
    end

    samples = labels(rp(1:n));

  end
end