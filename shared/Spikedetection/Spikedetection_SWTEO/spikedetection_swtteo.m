function spikepos = swtteo(in,params)
%SWTTEO Detects Spikes Location using a modified WTEO approach
%   Usage:  spikepos = swtteo(in);
%           spikepos = swtteo(in,params);
%
%   Input parameters:
%       in:  
%         Input structure which contains
%             M   :   Matrix with data, stored columnwise
%             SaRa:   Sampling frequency
%       params:
%         Structure with additional parameters
%           method   : Method how to detect spikes
%                      'auto'      : detects spikes by using the estimated 
%                                    noise, no additional parameters 
%                                    required (this is the default)
%                      'numspikes' : detects the exact number of specified
%                                    spikes, the number must be specified
%                                    in params.numspikes
%           numspikes: Number of spikes to detect, only in combination
%                      with method 'numspikes'
%           wavLevel : Maximum Wavelet level decomposition (Default: 2)
%           wavelet  : Wavelet (Default: 'sym4')
%
%   Output parameters:
%       spikepos:   Timestamps of the detected spikes stored columnwise
%
%   Description:
%       swtteo(in,params) computes the location of action potential in
%       noisy MEA measurements. This method is based on the work of N.
%       Nabar and K. Rajgopal "A Wavelet based Teager Engergy Operator for
%       Spike Detection in Microelectrode Array Recordings". The algorithm
%       therein was further improved by using a stationary wavelet
%       transform and a different thresholding concept.
%       For an unsupervised usage the sensitivity of the algorithm can be
%       adapted by changing the value of the variable global_fac in line
%       108. A larger value results in fewer detected spikes but also the
%       number of false positives decrease. Decreasing this factor makes it
%       more sensitive to detect spikes. 
%
%   References:
%       tbd.
%
%
%   Author: F. Lieb, February 2016
%

if nargin<2
    params = struct;
end

%parse inputs
[params,s,fs] = parseInput(in,params);
TEO = @(x) (x.^2 - circshift(x,[-1, 0]).*circshift(x,[1, 0]));
[L,c] = size(s);



%do zero padding if the L is not divisible by a power of two
pow = 2^params.wavLevel;
if rem(L,pow) > 0
    Lok = ceil(L/pow)*pow;
    Ldiff = Lok - L;
    s = [s; zeros(Ldiff,c)];
end

%testing showed prefiltering didnt improve the results
%prefilter signal
% if params.filter
%     params.Fstop = 50;
%     params.Fpass = 100;
%     Apass = 0.2;
%     Astop = 80;
%     if ~isfield(params,'F1')
%         F1 = designfilt('highpassiir','StopbandFrequency',params.Fstop ,...
%           'PassbandFrequency',params.Fpass,'StopbandAttenuation',Astop, ...
%           'PassbandRipple',Apass,'SampleRate',fs,'DesignMethod','butter');
%     end
%     s = filtfilt(F1,s);
% end

%non vectorized version:
% [SWTa,~] = swt(s,wavLevel,wavelet);
%     out22 = TEO(SWTa);

%vectorized version:
lo_D = wfilters(params.wavelet);
out_ = zeros(size(s));
ss = s;
for k=1:params.wavLevel
    %Extension
    lf = length(lo_D);
    ss = extendswt(ss,lf);
    %convolution
    swa = conv2(ss,lo_D','valid');
    swa = swa(2:end,:); %even number of filter coeffcients
    %apply teo to swt output
    out_ = out_ + abs(TEO(swa));
    %dyadic upscaling of filter coefficients
    lo_D = dyadup(lo_D,0,1);
    %updates
    ss = swa;
end

%non-vectorized version to extract spikes...
switch params.method
    case 'auto'
        global_fac =100;% 220; %change this
        if c == 1
            [CC,LL] = wavedec(s,5,'sym4');
            lambda = global_fac*wnoisest(CC,LL,1);
            thout = wthresh(out_,'h',lambda);
            spikepos = getSpikePositions(thout,fs,s,params);
        else
            spikepos = cell(c,1);
            for jj=1:c
                [CC,LL] = wavedec(s(:,jj),5,'sym4');
                lambda = global_fac*wnoisest(CC,LL,1);
                thout = wthresh(out_(:,jj),'h',lambda);
                spikepos{jj}=getSpikePositions(thout,fs,s(:,jj),params);
            end
        end
    case 'numspikes'
        spikepos = zeros(params.numspikes,c);
        for jj=1:c
            % extract spike positions from wteo output
            spikepos(:,jj)=getSpikePositions(out_(:,jj),fs,s(:,jj),params);
        end
    otherwise
        error('unknown detection method specified');
end




%internal functions:
%--------------------------------------------------------------------------
function [params,s,fs] = parseInput(in,params)
%PARSEINPUT parses input variables
s = in.M;
fs = in.SaRa;
%Default settings for detection method
if ~isfield(params,'method')
    params.method = 'auto';
end
if strcmp(params.method,'numspikes')
    if ~isfield(params,'numspikes')
        error('please specify number of spikes in params.numspikes');
    end
end
%Default settings for stationary wavelet transform
if ~isfield(params,'wavLevel')
    params.wavLevel = 2;
end
if ~isfield(params, 'wavelet')
    params.wavelet = 'sym4';
end





function y = extendswt(x,lf)
%EXTENDSWT extends the signal periodically at the boundaries
[r,c] = size(x);
y = zeros(r+lf,c);
y(1:lf/2,:) = x(end-lf/2+1:end,:);
y(lf/2+1:lf/2+r,:) = x;
y(end-lf/2+1:end,:) = x(1:lf/2,:);


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
spikeduration = 1e-3*fs;
offset = 3;
L = length(input_sig);

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
            while( out(max(1,idxl-2)) < out(max(1,idxl-1)) ||...
                        offsetcounter < spikeduration )
                out(max(1,idxl-1)) = 0;
                idxl = idxl-1;
                offsetcounter = offsetcounter + 1;
            end
            offsetcounter = 0;
            while( out(min(L,idxr+2)) < out(min(L,idxr+1)) ||...
                        offsetcounter < spikeduration )
                out(min(L,idxr+1)) = 0;
                idxr = idxr+1;
                offsetcounter = offsetcounter + 1;
            end
            indexx = min(L,idxl-offset:idxr+offset);
            indexx = max(1,indexx);
            idxx = find( abs(orig_sig(indexx)) == ...
                                  max( abs(orig_sig(indexx) )),1,'first');
            idx2(np+1) = idxl - offset + idxx-1;
            np = np + 1;
        end
        
    case 'auto'
        %helper variables
        idx2=[];
        iii=1;
        test2 = input_sig;
        %loop until the input_sig is only zeros
        while (sum(test2) ~= 0)
            %get the first nonzero position
            tmp = find(test2,1,'first');
            test2(tmp) = 0;
            %tmp2 is the counter until the spike duration
            tmp2 = min(length(test2),tmp + 1);%protect against end of vec
            counter = 0;
            %search for the end of the spike
            while(test2(tmp2) ~= 0 || counter<spikeduration )
                test2(tmp2) = 0;
                tmp2 = min(length(test2),tmp2 + 1);
                counter = counter + 1;
            end
            %spike location is in intervall [tmp tmp2], look for the max 
            %element in the original signal with some predefined offset: 
            indexx = min(length(orig_sig),tmp-offset:tmp2+offset);
            indexx = max(1,indexx);
            idxx = find( abs(orig_sig(indexx)) == ...
                                   max( abs(orig_sig(indexx) )),1,'first');
            idx2(iii) = tmp - offset + idxx-1;
            iii = iii+1;
        end
    otherwise
        error('unknown method');
end



