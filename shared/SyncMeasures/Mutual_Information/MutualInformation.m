% MutualInformation: returns mutual information (in bits) of the 'X' and 'Y'
% by Will Dwinnell
%
% I = MutualInformation(X,Y);
%
% I  = calculated mutual information (in bits)
% X  = variable(s) to be analyzed (column vector)
% Y  = variable to be analyzed (column vector)
%
% Note: Multiple variables may be handled jointly as columns in matrix 'X'.
% Note: Requires the 'Entropy' and 'JointEntropy' functions.
%
% Last modified: Nov-12-2006

function I = MutualInformation(X,Y,norm)

%% init
if nargin()==2
   norm='0'; 
end

%% calculate I
hx=Entropy(X);
hy=Entropy(Y);
if (size(X,2) > 1)  % More than one predictor?
    % Axiom of information theory
    I = JointEntropy(X) + hy - JointEntropy([X Y]);
else
    % Axiom of information theory
    I = hx + hy - JointEntropy([X Y]);
end

%% normalize I
switch norm
    case '0'
        % no normalizaiton
    case '1'
        % normalization 1
        I=I/min(hx,hy);
    case '2'
        % normalization 2
        I=(2*I)/(hx+hy);
end

% God bless Claude Shannon.

% EOF


