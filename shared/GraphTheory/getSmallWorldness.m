% input: WCM: weighted or unweighted Connectivity Matrix
% output: S: small worldness, C: mean clustering coefficient, L: mean shortest path length

function [S,C,L]=getSmallWorldness(WCM)

A = WCM~=0; % weighted connectivy matrix, transform into simple connectivity matrix 

%% taken from: script to compute small-world-ness and do statistical testing on example data network
% Mark Humphries 3/2/2017

% analysis parameters
%Num_ER_repeats = 100;  % to estimate C and L numerically for E-R random graph
%Num_S_repeats = 1000; % to get P-value for S; min P = 0.001 for 1000 samples
%I = 0.95;

FLAG_Cws = 1;
FLAG_Ctransitive = 2;

%% load the adjacency matrix for the Lusseau bottle-nose dolphin social
% network
%load dolphins  % loads struct of data in "Problem"; adjacency matrix is Problem.A

%A = full(Problem.A); % convert into full from sparse format

% get its basic properties
n = size(A,1);  % number of nodes
k = sum(A);  % degree distribution of undirected network
m = sum(k)/2;
K = mean(k); % mean degree of network

%% computing small-world-ness using the analytical approximations for the E-R graph

[expectedC,expectedL] = ER_Expected_L_C(K,n);  % L_rand and C_rand

[S,C,L] = small_world_ness(A,expectedL,expectedC,FLAG_Cws);  % Using WS clustering coefficient
%[S_trans,C_trans,L] = small_world_ness(A,expectedL,expectedC,FLAG_Ctransitive);  %  Using transitive clustering coefficient

end