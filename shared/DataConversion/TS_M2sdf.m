% Convert TS matrix to sdf (spike data format) used by e.g. TSPE by Stefano
% De Blasi et al. (MC)

function [sdf]=TS_M2sdf(TS,rec_dur)


    numEl = size(TS,2);  % number of Electrodes
    
    sdf = cell(1,numEl+1); % init sdf: sdf contains a cell for each electrode plus number of electrodes and number of all spikes in the last cell.

    TS=fix(TS.*1000); % from seconds to ms (as TSPE works with ms), "fix" deletes numbers after decimal point
    
    C=Matrix2Cell(TS);       % convert matrix to cell format
    
    rec_dur_ms = round(rec_dur) * 1000;
    
    sdf(1:end-1)=C;
    sdf(end)={[numEl, rec_dur_ms]}; % number of electrodes, rec_dur in ms
    
end