% Plot connectivity using MEA Layout defined by coordinates x and y
% CM_exh: connectivity matrix with exhibitory connections
% CM_inh: connectivity matrix with inhibitory connections
% hs: handle to subplot (optional)

function [hs,h_exh,h_inh]=plotGraph_MEA_Layout(CM_exh,CM_inh,x,y,hs)

        if nargin == 4
           hs = subplot(1,1,1); 
        end
        
        % init
        h_exh = [];
        h_inh = [];
        
        CM_inh = abs(CM_inh); % values have to be positive in order to plot them

        G_exh = digraph(CM_exh);
        G_inh = digraph(CM_inh);
        
        maxWeight = max(max([G_exh.Edges.Weight; G_inh.Edges.Weight]));
        
        LWidths_exh = 4*G_exh.Edges.Weight/maxWeight;
        LWidths_inh = 4*G_inh.Edges.Weight/maxWeight;
        
        % plot exhibitory connections
        if ~isempty(LWidths_exh)
            h_exh=plot(G_exh,'XData',x,'YData',y,'LineWidth',LWidths_exh); hold on
            h_exh.EdgeColor = [0 .8 .2];
        else
            h_exh=plot(G_exh,'XData',x,'YData',y);
            disp('No exhibitory connections')
        end
        h_exh.NodeLabel={};
        h_exh.NodeColor=[1 1 1]; % not visible, plot nodes in next plot
            
        
        % plot inhibitory connections
        if ~isempty(LWidths_inh)
            h_inh=plot(G_inh,'XData',x,'YData',y,'LineWidth',LWidths_inh);
            h_inh.EdgeColor = [0 0 0]; 
        else
            h_inh=plot(G_inh,'XData',x,'YData',y);
            disp('No inhibitory connections')
        end
        h_inh.NodeLabel={};
        h_inh.NodeColor=[0.8 0.8 0.8];
        
        axis square
        axis off
end