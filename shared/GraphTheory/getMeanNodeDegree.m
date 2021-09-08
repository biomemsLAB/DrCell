% input: CM: Connectivity Matrix
% output: D_in: mean node degree of incoming connections, D_out, D: mean
% over D_in and D_out

function [D, D_in, D_out]=getMeanNodeDegree(CM)

    G=digraph(CM);

    D_in = mean(nonzeros(indegree(G))); % only consider nonzeros, as zero means that node is not connected to network
    D_out = mean(nonzeros(outdegree(G)));
    
    D = mean([D_in D_out]);

end