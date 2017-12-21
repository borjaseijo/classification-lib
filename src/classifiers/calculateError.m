function error = calculateError(outputs, targets)
% calculateError Calculates the error committed by an ANN from the network 
% outputs and the desired outputs.
%
% Inputs:
%
% outputs - Outputs from the network.
% targets - Desired outputs.
%
% Outputs:
%
% error - Committed error (Scalar between 0 and 1).
% 
% Authors  : Iago Porto-Diaz, Oscar Fontenla-Romero, Amparo Alonso-Betanzos
%            Laboratory for Research and Development in Artificial Intelligence
%            (LIDIA Group) Universidad of A Coruna

if (size(outputs) ~= size(targets))
    disp 'Error. outputs and targets MUST be same sized.'
    return
end

error = 1 - (sum(outputs == targets)/length(targets));

end