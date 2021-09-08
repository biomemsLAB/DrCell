% --- Electrode wise -----------------------------------------------
    function [EWmean,EWstd,EWn]=electrodeWiseVariance(x) 
        
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
            % 3) calc mean and std over all values for each file
            for i=1:size(xj,2) % loop through all files
               [EWmean(1,i),EWvar(1,i),EWn(1,i)]=CollectiveVariance(xj(:,i),sj(:,i),nj(:,i)); % also consider variance on electrode to calculate entire variance
            end
            EWstd=sqrt(EWvar);
        else
            EWmean=nan;
            EWstd=nan;
            EWn=nan;
        end
        
%         if size(size(x),2)==2
%            for i=1:size(x,2) % loop through all files
%                
%            end
%         end
    end