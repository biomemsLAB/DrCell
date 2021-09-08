% JointEntropy: Returns joint entropy (in bits) of each column of 'X'
% by Will Dwinnell
%
% H = JointEntropy(X)
%
% H = calculated joint entropy (in bits)
% X = data to be analyzed
%
% Last modified: Aug-29-2006

function H = JointEntropy(X)

if size(X,2)>1 % only calculate joint entropy if at least two columns are available
    % Sort to get identical records together
    X = sortrows(X);

    % Find elemental differences from predecessors
    DeltaRow = (X(2:end,:) ~= X(1:end-1,:));

    % Summarize by record
    Delta = [1; any(DeltaRow')'];

    % Generate vector symbol indices
    VectorX = cumsum(Delta);

    % Calculate entropy the usual way on the vector symbols
    H = Entropy(VectorX);
else
    H = Entropy(X);
end


% God bless Claude Shannon.

% EOF


