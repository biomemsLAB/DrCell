function idx2 = getSpikePositions(input_sig,fs,orig_sig,params)
%GETSPIKEPOSITIONS computes spike positions from thresholded data
%
%   This function computes the exact spike locations based on a thresholded
%   signal. The spike locations are indicated as non-zero elements in
%   input_sig and are accordingly evaluated. 
%
%   The outputs are the spike positions in absolute index values (no time
%   dependance). 
%
%   Author: F.Lieb, February 2016
%


%Define a fixed spike duration, prevents from zeros before this duration is
%over
%maxoffset
%spikeduration = 10e-4*fs; %10e-4
spikeduration = round(10e-4*fs);%spikeduration = fix(10e-4*fs);%spikeduration = ceil(10e-4*fs);
%minoffset
minoffset = 3e-4*fs; %3e-4

offset = floor(5e-4*fs); %5e-4 %was 2e-4, dunno why
L = length(input_sig);
L2 = length(orig_sig);

switch params.method
    case 'numspikes'
        
        out = input_sig;
        np = 0;
        idx2 = zeros(1,params.numspikes);

        while (np < params.numspikes)
            [~, idxmax] = max(out); 
            idxl = idxmax;
            idxr = idxmax;
            out(idxmax) = 0;
            offsetcounter = 0;
            while( (out(max(1,idxl-2)) < out(max(1,idxl-1)) ||...
                        offsetcounter < minoffset) &&... 
                        offsetcounter < spikeduration )
                out(max(1,idxl-1)) = 0;
                idxl = idxl-1;
                offsetcounter = offsetcounter + 1;
            end
            offsetcounter = 0;
            while( (out(min(L,idxr+2)) < out(min(L,idxr+1)) ||...
                        offsetcounter < minoffset ) &&...
                        offsetcounter < spikeduration )
                out(min(L,idxr+1)) = 0;
                idxr = idxr+1;
                offsetcounter = offsetcounter + 1;
            end
            
            %new approach
            indexx = min(L2, idxmax-offset:idxmax+offset);
            %indexx = min(L2,idxl-offset:idxr+offset); %old approach
            indexx = max(offset,indexx);
            idxx = find( abs(orig_sig(indexx)) == ...
                                  max( abs(orig_sig(indexx) )),1,'first');
            idx2(np+1) = idxmax - offset + idxx-1;
            np = np + 1;
        end

              
    case {'energy'}
        rel_norm = params.rel_norm;
       % p = params.p;
        ysig = input_sig;
       % normy = norm(input_sig);
        L = length(input_sig);
        %min and max length of signal duration
        maxoffset = 12;
        minoffset = 6; 
        offset = 5;
        idx2 = [];
        np = 0;
        maxspikecount = 300;
        temp = 0;

        %while( norm(ysig) > (1-p)*normy )
        while( 1 )
            norm_old = norm(ysig);
            [~, idxmax] = max(ysig);
            idxl = idxmax;
            idxr = idxmax;
            ysig(idxmax) = 0;
            offsetcounter = 0;
            while ( ( ysig(max(1,idxl-2)) < ysig(max(1,idxl-1)) ||...
                      offsetcounter < minoffset ) && ...
                      offsetcounter < maxoffset )
                ysig(max(1,idxl-1)) = 0;
                idxl = idxl - 1;
                offsetcounter = offsetcounter + 1;
            end
            offsetcounter = 0;
            while ( ( ysig(min(L,idxr+2)) < ysig(min(L,idxr+1)) ||...
                      offsetcounter < minoffset ) && ...
                      offsetcounter < maxoffset )
                ysig(min(L,idxr+1)) = 0;
                idxr = idxr + 1;
                offsetcounter = offsetcounter + 1;
            end

            indexx = min(L, idxmax-offset:idxmax+offset);
            %indexx = min(L2,idxl-offset:idxr+offset); %old approach
            indexx = max(offset,indexx);
            idxx = find( abs(orig_sig(indexx)) == ...
                                  max( abs(orig_sig(indexx) )),1,'first');
            idx2(np+1) = idxmax - offset + idxx-1;
            np = np + 1;

            fprintf('rel norm: %f\n', (norm_old-norm(ysig))/norm_old);
            temp(np+1) = (norm_old-norm(ysig))/norm_old;
            if (norm_old-norm(ysig))/norm_old < rel_norm
                if length(idx2)>1
                    idx2 = idx2(1:end-1);
                else
                    idx2 = [];
                end
                break
            end
            if  np > maxspikecount
                break;
            end
        end
    case {'auto','lambda'}
        %helper variables

% new: faster algorithms (Sh.Kh)
        test2 = input_sig; 
        tmp = find(test2);
        tmp(:,2)= tmp(:,1)+1+spikeduration;
        if tmp(size(tmp,1),2)>size(test2,1)
          tmp(size(tmp,1),2)=length(test2);
        end
        i=1;
        while i<size(tmp,1)+1
            if i<size(tmp,1)
                while tmp(i,2)+1> tmp((i+1),1) 
                    tmp(i+1,:)=[];
                    if i>=size(tmp,1)-1
                        break 
                    end
                end
            end
            while test2(tmp(i,2))~= 0  && i < size(tmp,1)
                tmp(i,2)=tmp(i,2)+1;
                if tmp(i+1,1)==tmp(i,2)
                    tmp(i+1,:)=[];
                end
            end
            indexx = min(length(orig_sig),tmp(i,1)-offset:tmp(i,2)+offset); % mishe hazf kard fekr konam
            indexx = max(offset,indexx);
            idxx = find( abs(orig_sig(indexx)) == ...
                           max( abs(orig_sig(indexx) )),1,'first');
            tmp(i,3) = tmp(i,1) - offset + idxx-1;
            i=i+1;
        end
             idx2=tmp(:,3)';
      
% %     case 'lambda2'
% %         idx2 = [];
% %         iii = 1;
% %         test2 = input_sig;
% %         while (sum(test2) ~= 0)
% %             [~,tmp] = max(test2);
% %             test2(tmp) = 0;
% %             tmp2 = min
    otherwise
        error('unknown method');
end
