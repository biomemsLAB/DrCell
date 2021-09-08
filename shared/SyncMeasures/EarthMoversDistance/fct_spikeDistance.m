function d = fct_spikeDistance(f, g)
% spike distance between two spikes trains.
%
% f : spike time of 1st spikes train, vector.
% g : spike time of 2nd spikes train, vector.
%
% e.g)
% f = [-1, 8, 9];
% g = [0, 10];
%
% d : spike distance between f and g

if iscolumn(f)
    f = transpose(f);
end
if iscolumn(g)
    g = transpose(g);
end



p = unique( sort( [f, g] ) );

[~, idx_f] = ismember(f, p);
[~, idx_g] = ismember(g, p);

% S = {x : f(x) > 0 or g(x) > 0}
val = zeros(2, size(p,2));
val(1, idx_f) = 1 / length(f);
val(2, idx_g) = 1 / length(g);



% hat_x = min{x \in S : f(x) > g(x)}
min_f_large = min( find( val(1,:) > val(2,:) ) );
% hat_y = min{x \in S : f(x) < g(x)}
min_g_large = min( find( val(1,:) < val(2,:) ) );

d = 0;% spike distance d*
while ~isempty(min_f_large) && ~isempty(min_g_large)
    % hat_r = min{ f(hat_x) - g(hat_x), g(hat_y) - f(hat_y) }
    min_quantity = min( [val(1, min_f_large) - val(2, min_f_large), val(2, min_g_large) - val(1, min_g_large)] );
    
    d = d + ( abs( p(min_f_large) - p(min_g_large) ) * min_quantity );% d* = d* + d(hat_x, hat_y) * hat_r
    
    val(1,min_f_large) = val(1,min_f_large) - min_quantity;
    val(1,min_g_large) = val(1,min_g_large) + min_quantity;
    
    % hat_x = min{x \in S : f(x) > g(x)}
    min_f_large = min( find( val(1,:) > val(2,:) ) );
    % hat_y = min{x \in S : f(x) < g(x)}
    min_g_large = min( find( val(1,:) < val(2,:) ) );
end
