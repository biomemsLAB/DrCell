% Calculate several graph parameter from a connectivity matrix (MC, NN)
% flag_binary = 1: calculate paramater for binary matrix
% flag_binary = 0: calculate parameter for weighted matrix
%
% Output:
%           S           Structure that contains all parameter

function [S]=getAllGraphParameter(C_w_d_sign,flag_binary)

S.flag_binary = flag_binary;

% C_w_d_sign: weighted, directed, negative and positive
% C_w_d: weighted, directed, but only absolute values
% C_b_d: binary, directed
C_w_d = abs(C_w_d_sign);
C_b_d = double(C_w_d ~= 0);

S.C_w_d=C_w_d;
S.C_b_d=C_b_d;

%% Calculate graph parameter:

[D, D_in, D_out]=getMeanNodeDegree(C_w_d_sign); % = Matlab function
S.D = D; % mean node degree

if flag_binary % if binary
    [S_pos,S_neg,vpos,vneg]=strengths_und_sign(C_w_d_sign); % brain connectivity toolbox, Spos/Sneg: nodal strength of positive/negative weights; vpos/vneg: total positive/negative weight
    S.Dis = distance_bin(C_b_d); % Matrix, BCT
    S.CP = charpath(S.Dis); % Scalar
    S.E = efficiency_bin(C_b_d,0); % Scalar
    S.r1 = assortativity_bin(C_b_d,1); % brain connectivity toolbox, 1: out-strength/in-strength correlation
    S.r2 = assortativity_bin(C_b_d,2); % brain connectivity toolbox, 2: in-strength/out-strength correlation
    S.r3 = assortativity_bin(C_b_d,3); % brain connectivity toolbox, 3: out-strength/out-strength correlation
    S.r4 = assortativity_bin(C_b_d,4); % brain connectivity toolbox, 4: in-strength/in-strength correlation
    BC = betweenness_bin(C_b_d); % Vector, BCT
    S.BC = mean(BC);
    CC = clustering_coef_bd(C_b_d); % Vector, BCT
    S.CC = mean(CC);
    CL_vec = community_louvain(C_b_d); % Vector, BCT
    S.CL = mean(CL_vec);
    % ERROR: S.DE = diffusion_efficiency(C_b_d); % Scalar, BCT
    S.DE=NaN;
    EBC = edge_betweenness_bin(C_b_d); % Matrix, BCT
    S.EBC = mean(mean(EBC));
    %FPT = mean_first_passage_time(C_b_d); % Matrix, BCT
    %S.FPT = mean(mean(FPT));
    S.FPT=NaN;
    %Mod = modularity_dir(C_b_d); % Vector; BCT
    %S.Mod = mean(Mod);
    S.Mod = NaN;
    PC1 = participation_coef(C_b_d, CL_vec, 1); % Vector, Out-Degree, BCT
    S.PC1 = mean(PC1);
    PC2 = participation_coef(C_b_d, CL_vec, 2); % Vector, In-Degree, BCT
    S.PC2 = mean(PC2);
    S.T = transitivity_bd(C_b_d); % Scalar, BCT
else % if weighted
    S.Dis = distance_wei(weight_conversion(C_w_d, 'lengths')); % Matrix, BCT
    S.CP = charpath(S.Dis); % Scalar
    S.E = efficiency_wei(weight_conversion(C_w_d, 'lengths'),0); % Scalar
    S.r1 = assortativity_wei(C_w_d,1); % brain connectivity toolbox, 1: out-strength/in-strength correlation
    S.r2 = assortativity_wei(C_w_d,2); % brain connectivity toolbox, 2: in-strength/out-strength correlation
    S.r3 = assortativity_wei(C_w_d,3); % brain connectivity toolbox, 3: out-strength/out-strength correlation
    S.r4 = assortativity_wei(C_w_d,4); % brain connectivity toolbox, 4: in-strength/in-strength correlation
    BC = betweenness_wei(weight_conversion(C_w_d, 'lengths')); % Vector, BCT
    S.BC = mean(BC);
    CC = clustering_coef_wd(weight_conversion(C_w_d, 'normalize')); % Vector, BCT
    S.CC = mean(CC);
    CL_vec = community_louvain(C_w_d); % Vector, BCT
    S.CL = mean(CL_vec);
    % ERROR: S.DE = diffusion_efficiency(C_w_d); % Scalar, BCT
    S.DE=NaN;
    EBC = edge_betweenness_wei(weight_conversion(C_w_d, 'lengths')); % Matrix, BCT
    S.EBC = mean(mean(EBC));
    %FPT = mean_first_passage_time(C_w_d); % Matrix, BCT
    %S.FPT = mean(mean(FPT));
    S.FPT = NaN;
    %Mod = modularity_dir(C_w_d); % Vector; BCT
    %S.Mod = mean(Mod);
    S.Mod = NaN;
    PC1 = participation_coef(C_w_d, CL_vec, 1); % Vector, Out-Degree, BCT
    S.PC1 = mean(PC1);
    PC2 = participation_coef(C_w_d, CL_vec, 2); % Vector, In-Degree, BCT
    S.PC2 = mean(PC2);
    S.T = transitivity_wd(weight_conversion(C_w_d, 'normalize')); % Scalar, BCT
end


% unused functions:
%[S,C,L]=getSmallWorldness(C_w_d_sign); 
%[S_pos,S_neg,vpos,vneg]=strengths_und_sign(C_w_d_sign); % brain connectivity toolbox, Spos/Sneg: nodal strength of positive/negative weights; vpos/vneg: total positive/negative weight
%S_pos_neg = S_pos+S_neg;
%[J,J_od,J_id,J_bl] = jdegree(C_w_d);
%gt=gtom(C_b_d); % brain connectivity toolbox, Topological overlap (output=Matrix)
%[EC,ec,degij] = edge_nei_overlap_bu(C_b_d); % brain connectivity toolbox, Neighborhood overlap, (output=Matrix)
%[M0]=matching_ind_und(C_b_d); % brain connectivity toolbox, Matching index
%density_und(); % brain connectivity toolbox, densitiy, only for undirected matrices
%ClusteringCoef=clustering_coef_wd(weight_conversion(C_w_d, 'normalize')); % brain connectivity toolbox, Clustering coefficient (only values between 0 and 1 => weight_conversion)         
%[D_in,D_out,D] = degrees_dir(C_w_b); % brain connectivity toolbox
%[J,J_od,J_id,J_bl] = jdegree(C_w_d);
%gt=gtom(C_b_d); % brain connectivity toolbox, Topological overlap (output=Matrix)
%[EC,ec,degij] = edge_nei_overlap_bu(C_b_d); % brain connectivity toolbox, Neighborhood overlap, (output=Matrix)
%[M0]=matching_ind_und(C_b_d); % brain connectivity toolbox, Matching index
%density_und(); % brain connectivity toolbox, densitiy, only for undirected matrices
%[comps,comp_sizes] = get_components(adj); % brain connectivity toolbox,
%link_communities % brain connectivity toolbox, output=matrix
%clique_communities % brain connectivity toolbox, output=matrix
%local_assortativity_wu_sign % brain connectivity toolbox, only undirected
% rich_club_wd % brain connectivity toolbox, output is a curve
% core_periphery_dir % brain connectivity toolbox, output is vector
%kcore_bd % brain connectivity toolbox,
%score_wu % brain connectivity toolbox,
%eigenvector_centrality_und % brain connectivity toolbox, output is vector
%pagerank_centrality % brain connectivity toolbox, output is vector

end