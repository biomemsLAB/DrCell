% Event Synchronization according to Quian Quiroga et al. (2002)

% Input: 
% TS: time stamps in seconds (n_maxSpikes x n_electrodes)
% tauMax = maximal tau in seconds (e.g. 0.04)

% Output:
% M_syn: matrix of pairwise sync values (n_electrodes + n_electrodes)
% M_del: matrix of pairwise delay values

function [M_syn,M_del]=Event_Sync_MC(TS,tauMax)

    N=size(TS,2); % number of electrodes

    % init Matrices (pairwise sync and delay)
    M_syn=zeros(N);
    M_syn(M_syn==0)=NaN;
    M_del=M_syn;
    
    % calculate sync and delay
    for x=1:N-1
        for y=x+1:N
            if ~isempty(nonzeros(TS(:,x))) && ~isempty(nonzeros(TS(:,y)))
                
                X=sort(nonzeros(TS(:,x)));
                Y=sort(nonzeros(TS(:,y)));
                c_xy=0;
                c_yx=0;
                mx=length(X);
                my=length(Y);
                
                for i=1:mx
                    for j=1:my
                        % c(x|y)
                        tau=findTau(X,Y,i,j,tauMax);
                        J_ij=Jay(X(i),Y(j),tau); 
                        c_xy = c_xy + J_ij;
                        
                        % c(y|x)
                        tau=findTau(Y,X,j,i,tauMax);
                        J_ji=Jay(Y(j),X(i),tau); 
                        c_yx = c_yx + J_ji;
                    end
                end
                
                Q = (c_yx + c_xy)/sqrt(mx*my); % synchrony
                q = (c_yx - c_xy)/sqrt(mx*my); % delay
                
                M_syn(x,y)= Q;
                M_del(x,y)= q;
            end
        end
    end
    
    
    function tau=findTau(X,Y,i,j,tauMax)
        if i<=1
            tx_1 = NaN;
        else
            tx_1 = X(i-1);
        end
        
        if j<=1
            ty_1 = NaN;
        else
            ty_1 = Y(j-1);
        end
        
        if i>= length(X)
            tx1=NaN;
        else
            tx1=X(i+1);
        end
        
        if j>= length(Y)
            ty1=NaN;
        else
            ty1=Y(j+1);
        end
        
        tx=X(i);
        ty=Y(j);
        
        tau=min([tx1-tx, tx-tx_1, ty1-ty, ty-ty_1, tauMax])/2;
    end
    
    function J=Jay(tx,ty,tau)
        if 0 < tx-ty && tx-ty <= tau
            J=1;
        elseif tx == ty
            J=0.5;
        else
            J=0;
        end
    end

end



       
