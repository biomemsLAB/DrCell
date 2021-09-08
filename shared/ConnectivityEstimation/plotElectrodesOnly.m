function plotElectrodesOnly(x,y)

        nr_channel = length(x);
        CM = zeros(nr_channel,nr_channel);
        G = digraph(CM);
        h=plot(G,'XData',x,'YData',y); hold on
        h.NodeLabel={};
        h.NodeColor=[0 0 0.8];
        axis off
        axis square

end