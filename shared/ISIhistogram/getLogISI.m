function [ISI_log,ISI]=getLogISI(TS)

ISI = nonzeros(diff(sort(TS(:,:)))); % calculate ISIs for entire chip
ISI(ISI<0)=NaN; % delete last value as it is negative
ISI_log = log10(ISI); % calculate the logarithm

end