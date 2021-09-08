function TE=TransferEntropy(X,Y)

    if size(X,2)>1
       X=X';
       Y=Y';
    end

    Xd = X(1:end-1, 1);
    Yd = Y(1:end-1, 1);
    X_t1 = X(2:end, 1); % X_t+1 
    %TE = MutualInformation([Yd, Xd], X_t1) - MutualInformation(X_t1, Xd); % definition according to Garofalo et al.
    TE= JointEntropy([Xd,Yd]) - JointEntropy([X_t1, Xd, Yd]) + JointEntropy([X_t1, Xd]) - Entropy(Xd); % definition according to Vicente et al.
        

end