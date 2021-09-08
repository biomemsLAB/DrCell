% plot ISI histogram (MC)
% Input:    logISI:         Interspikeintervals in seconds as log10 (use DrCell function getLogISI)
%           hs:             handle of subplot (optional)
%           flag_getOnlyValues:     0: plot is generated, 1: no plot is generated
%           BinMethod:              NaN: bin Size of 10 ms is used, 'auto':
%           optimal bin size is choosen (more options see matlab: help histogram)

function [hp,hs]=plotISI_Histogram(logISI,hs,flag_getOnlyValues,BinMethod)

if nargin == 1
    flag_getOnlyValues = 0; % default: make plot
    hs = subplot(1,1,1);
    BinMethod = NaN;
end
if nargin == 2
    flag_getOnlyValues = 0; % default: make plot
    BinMethod = NaN;
end
if nargin == 3
    BinMethod = NaN;
end

binEdges = -3:0.01:1;

if flag_getOnlyValues
    if isnan(BinMethod)
        hp = histcounts(logISI,binEdges);
    else
        hp = histcounts(logISI,'BinMethod',BinMethod);
    end
else
    if isnan(BinMethod)
        hp=histogram(logISI,binEdges);
    else
        hp=histogram(logISI,'BinMethod',BinMethod);
    end
    hp.Parent.XLabel.String='log(ISI) in log(s)';
    hp.Parent.YLabel.String='Frequency';
end

end