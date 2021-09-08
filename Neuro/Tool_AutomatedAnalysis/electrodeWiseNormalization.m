% --- Electrode wise -----------------------------------------------
    function [EWmean,EWstd,EWn,EW]=electrodeWiseNormalization(x) 
        
        % if dimension of x is 3 [values per electrode, electrodes, files]
        if size(size(x),2)==3 
            % 1) calc mean and std for every electrode:
            for i=1:size(x,3) % loop through all files
                for n=1:size(x,2)
                    xj(n,i) = mean(nonzeros(x(:,n,i))); % mean value of each electrode
                    sj(n,i) = std(nonzeros(x(:,n,i))); % std value of each electrode
                    nj(n,i) = length(nonzeros(x(:,n,i))); % number of elements of each electrode  
                end
            end
            % 2) electrode wise parameter (= normalize parameter to first file):
            for n=1:size(xj,1) % loop throuth all electrodes
                xj_norm(n,:)=xj(n,:)./xj(n,1);
                sj_norm(n,:)=sj(n,:)./xj(n,1);
            end
            % 3) calc mean and std over all normalized values for each file
            for i=1:size(xj_norm,2) % loop through all files
               [EWmean(1,i),EWvar(1,i),EWn(1,i)]=CollectiveVariance(xj_norm(:,i),sj_norm(:,i),nj(:,i)); % also consider variance on electrode to calculate entire variance
            end
            EW=xj_norm;
            EWstd=sqrt(EWvar);
        end
        
        % if dimension of x is 2 [electrodes, files]
        if size(size(x),2)==2
            % electrode wise parameter:
            for n=1:size(x,1) % loop throuth all electrodes
                EW(n,:)=x(n,:)./x(n,1);
            end
            EW(isnan(EW))=0;
            EW(isinf(EW))=0;
            for i=1:size(EW,2) % loop through all files
               EWmean(1,i)=mean(nonzeros(EW(:,i))); 
               EWstd(1,i)=std(nonzeros(EW(:,i)));
               EWn(1,i)=length(nonzeros(EW(:,i)));
            end
        end
        
        % set NaN to zeros
        EWmean(isnan(EWmean))=0;
        EWstd(isnan(EWstd))=0;
        EWn(isnan(EWn))=0;
        
    end