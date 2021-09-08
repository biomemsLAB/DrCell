function [SPIKEZ]=combinedSpikeDetection(raw,SPIKEZ)

%combined spike detection,
%no dynamic threshold


M=raw.M;
% T=raw.T;
fs = raw.SaRa;

if size(SPIKEZ.neg.THRESHOLDS.Th,1) ~= 1
    error('no dynamic threshold available');
end

SPIKEZ.PREF.dyn_TH=0;
spikepos = cell(1,size(M,2));
params_tmp.method = 'lambda';

% detect positive or negative or both spikes /for less memory to use
% to calculate faster.(Sh.Kh)
if SPIKEZ.neg.flag && SPIKEZ.pos.flag % both (!!!up to now absolute value of negative threshold is also used as positve threshold!!!)
    lambda = SPIKEZ.neg.THRESHOLDS.Th;
end
if SPIKEZ.neg.flag && ~SPIKEZ.pos.flag % only negative
    lambda = SPIKEZ.neg.THRESHOLDS.Th;
end
if ~SPIKEZ.neg.flag && SPIKEZ.pos.flag % only positive
    lambda = SPIKEZ.pos.THRESHOLDS.Th;
end
%  if size(M,2)>60 % for HDMEA Data (.brw)
%  	M=digital2analog_sh(M,raw);
%  end
for ii=1:size(M,2)
    y = abs (M(:,ii));
    y((y<abs(lambda(ii)))) = 0;
    if sum(y)==0
        spikepos{ii}=[];
    else
        spikepos{ii} = getSpikePositions(y,fs,M(:,ii),params_tmp);
    end
end

SPIKEZ.COMBINED.sppos_schw = spikepos;

%need a wrapper function to compute the number of spikes in each electrode
numspikes = zeros(1,size(M,2));
for ii =1:size(M,2)
    numspikes(ii) = nnz(spikepos{ii});
end

param_swtteo.method = 'numspikes';
param_swtteo.numspikes = numspikes;

% new: faster algorithms (Sh.Kh)
[~,c] = size(M);
if c < 61
    sppos_swtteo = testfoo(M,raw.SaRa,param_swtteo);
else
    j=440; % bei kleinem Arbeitsspeicher muss j kleiner werden
    for i=0:+j:(floor(c/j)-1)*j
        sppos_swtteo(:,i+1:i+j) = testfoo(M(:,i+1:i+j),raw.SaRa,param_swtteo);
    end
    i=i+j;
    if i<c
        sppos_swtteo(:,i+1:c)= testfoo(M(:,i+1:c),raw.SaRa,param_swtteo);
    end
end

SPIKEZ.COMBINED.sppos_swtteo = sppos_swtteo;

%intersection
combres = cell(1,size(M,2));
for ii=1:size(M,2)
    combres{ii} = intersect(spikepos{ii},sppos_swtteo{ii});
end

%format result to drcell format
numspikes = cellfun('length',combres);
TSC = {[]};
TS = zeros(max(numspikes),size(M,2));
%AMP = zeros(max(numspikes),size(M,2));
for ii=1:size(M,2)
    tmp = combres{ii};
    tmp(tmp<=0)=1; % MC
    TS(1:length(tmp),ii) = tmp-1; % -1 as time stamps had one sample offset
    TSC (1,ii)= {(tmp'/fs)-1}; % Save spikes as a cell array Sh_Kh
    % Amplitudes are now calculated after this function
%     if isempty(tmp) % MC
%         AMP(1:length(tmp),ii) = 0;
%     else
%         AMP(1:length(tmp),ii) = M(tmp,ii);
%     end
end


SPIKEZ.TS = TS./fs;
SPIKEZ.TSC = TSC;
%SPIKEZ.AMP=AMP;
SPIKEZ.neg.TS=SPIKEZ.TS;
%SPIKEZ.neg.AMP=AMP;
SPIKEZ.pos.TS=SPIKEZ.TS;
%SPIKEZ.pos.AMP=AMP;



end

