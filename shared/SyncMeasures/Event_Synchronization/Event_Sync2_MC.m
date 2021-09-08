% Event Synchronization according to Quian Quiroga et al. (2002)
% programmed by Manuel Ciba 2016

% Input: 
% TS: time stamps in seconds (n_maxSpikes x n_electrodes)
% tauMax = maximal tau in seconds (e.g. 0.04)

% Output:
% M_syn: matrix of pairwise sync values (n_electrodes + n_electrodes)
% M_del: matrix of pairwise delay values

function [M_syn,M_del]=Event_Sync2_MC(TS,tauMax)

    N=size(TS,2); % number of electrodes


    % init Matrices (pairwise sync and delay)
    M_syn=zeros(N);
    M_syn(M_syn==0)=NaN;
    M_del=M_syn;
    
    
    
    % calculate sync and delay
    for x=1:N-1
        for y=x+1:N
            if ~isempty(nonzeros(TS(:,x))) && ~isempty(nonzeros(TS(:,y)))
                
                % init
                X=sort(nonzeros(TS(:,x)));
                Y=sort(nonzeros(TS(:,y)));
                mx=length(X);
                my=length(Y); 
                mxy=mx*my;
                
                di_1 = zeros(mx,1) * NaN; % di_i: di - di-1 "deltas" or inter spike intervals
                di1 = zeros(mx,1) * NaN;  % di1: di+1 - di
                dj_1 = zeros(my,1) * NaN;
                dj1 = zeros(my,1) * NaN;
                
                J_ij = zeros(mxy,1);
                J_ji = zeros(mxy,1);
                
                % fill arrays with values
                ti=sort(repmat(X,my,1)); % copy values of X mx times and sort
                tj=repmat(Y,mx,1); % copy values of Y mx times

                di_1(2:end) = diff(X);
                di1(1:end-1) =diff(X);
                dj_1(2:end) = diff(Y);
                dj1(1:end-1) = diff(Y);
                
                di_1(isnan(di_1)) = 0; % as sort handles zero as lowest and NaN as highest value  
                di_1 = sort(repmat(di_1,my,1));              
                di_1(di_1==0)=NaN; % convert zeros back to NaN                
                di1 = sort(repmat(di1,my,1));
                dj_1 = repmat(dj_1,mx,1);
                dj1 = repmat(dj1,mx,1);
                
                tauMax = repmat(tauMax,mxy,1); % copy value of tau max so it has same dimension
                tau = min([di_1,di1,dj_1,dj1,tauMax], [], 2)/2;
                
                % calc differences
                ti_tj = ti - tj;
                tj_ti = tj - ti;
                
                % if difference between 0 ... tau_max -> J=1
                % if difference 0 -> J=0.5
                % else -> J=0
                mask1 = ti_tj > 0 & ti_tj <= tau;
                mask2 = ti == tj;
                J_ij(mask1)=1;
                J_ij(mask2)=0.5;
                
                mask1 = tj_ti > 0 & tj_ti <= tau;
                mask2 = ti == tj;
                J_ji(mask1)=1;
                J_ji(mask2)=0.5;
                
                c_xy = sum(J_ij);
                c_yx = sum(J_ji);
                
                Q = (c_yx + c_xy) / sqrt(mxy);
                q = (c_yx - c_xy) / sqrt(mxy);
                
                M_syn(x,y)=Q;
                M_del(x,y)=q;
            end
        end             
    end
end



       
