% Plot connectivity using HDMEA Layout defined by coordinates x and y
% CM_exh: connectivity matrix with exhibitory connections
% CM_inh: connectivity matrix with inhibitory connections
% hs: handle to subplot (optional)

function [hs,h_exh,h_inh]=plotGraph_HDMEA_Layout(CM_exh,CM_inh,x,y,hs)

        if nargin == 4
           hs = subplot(1,1,1); 
        end
        
        % dummy connectivity matrix to create graph
        plotElectrodesOnly(x,y)
        
        % plot lines
        CM_inh = abs(CM_inh);
        
        Cmax_exh = max(max(CM_exh)); % max value in matrix
        Cmin_exh = min(min(CM_exh)); % min value in matrix
        Cmax_inh = max(max(CM_inh)); % max value in matrix
        Cmin_inh = min(min(CM_inh)); % min value in matrix      
        Cmin = min([Cmin_exh, Cmin_inh]);
        Cmax = max([Cmax_exh, Cmax_inh]);

        lineColor_exh = [0,1,0.5];
        [h_exh,LWmin_exh,LWmax_exh]=plotLinesOfCM(CM_exh,x,y,lineColor_exh,Cmin,Cmax);
        
        lineColor_inh = [0.5,0.5,0.5];
        [h_inh,LWmin_inh,LWmax_inh]=plotLinesOfCM(CM_inh,x,y,lineColor_inh,Cmin,Cmax);
        
        axis square
        
        
        % legend exhibitory
        x1=0; x2=10; y1=-1; y2=-1;
        hp=line([x1,x2],[y1,y2]);
        hp.LineWidth = LWmin_exh;
        hp.Color = lineColor_exh;
        text(x2,y2,num2str(Cmin_exh,'%.2f'))
        
        x1=0; x2=10; y1=-5; y2=-5;
        hp=line([x1,x2],[y1,y2]);
        hp.LineWidth = LWmax_exh;
        hp.Color = lineColor_exh;
        text(x2,y2,num2str(Cmax_exh,'%.2f'))
        
        
        % legend inhibitory
        x1=20; x2=30; y1=-1; y2=-1;
        hp=line([x1,x2],[y1,y2]);
        hp.LineWidth = LWmin_inh;
        hp.Color = lineColor_inh;
        text(x2,y2,num2str(Cmin_inh,'%.2f'))
        
        x1=20; x2=30; y1=-5; y2=-5;
        hp=line([x1,x2],[y1,y2]);
        hp.LineWidth = LWmax_inh;
        hp.Color = lineColor_inh;
        text(x2,y2,num2str(Cmax_inh,'%.2f'))
        
        hs.YDir='reverse'; % reverse Y dir as HDMEA layout has electrode #1 at left upper corner instead of left bottom corner
end