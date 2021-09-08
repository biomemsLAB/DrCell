% input:
%           CM              connectivity matrix, all values must be zero or positive
%           x               array containting coordinates (1, 2, 3, ...) of electrode field (x direction)
%           y               array containting coordinates (1, 2, 3, ...) of electrode field (y direction)
%           lineColor       RGB array e.g. [0, 1, 0] -> green line

function [hp,LWmin_used,LWmax_used,Cmin,Cmax]=plotLinesOfCM(CM,x,y,lineColor,Cmin,Cmax)

% init
hp=[];

Cmin=0;
Cmax=0.05;

CM_b = CM > max(max(CM))*0.0; % only plot biggest values
CM(CM_b==0)=NaN;

LWmin = 0.1; % line width for min value
LWmax = 5; % line width for max value

LWmax_used = 0; % line width that is used in plot (later used for legend)
LWmin_used = 10000; % line width that is used in plot (later used for legend)

CM_b = double(CM_b);
CM_b(CM_b==0)=NaN;

for N1=1:size(CM,1) % Neuron 1
    for N2=1:size(CM,1) % Neuron 2
        x1 = x(N1) * CM_b(N1,N2);
        x2 = x(N2) * CM_b(N1,N2);
        
        y1 = y(N1) * CM_b(N1,N2);
        y2 = y(N2) * CM_b(N1,N2);
        
        if ~isnan(x1) && ~isnan(x2) && ~isnan(y1) && ~isnan(y2)
            hp=line([x1,x2],[y1,y2]);
            hp.LineWidth = rescaleValue(CM(N1,N2),Cmin,Cmax,LWmin,LWmax);
            LWmax_used = max([hp.LineWidth,LWmax_used]);
            LWmin_used = min([hp.LineWidth,LWmin_used]);
            hp.Color = lineColor;     
        end
    end
end
end