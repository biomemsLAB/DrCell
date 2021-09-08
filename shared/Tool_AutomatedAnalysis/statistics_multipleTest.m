% ANOVA

function [COMPARISON, p_anova, H_norm, p_norm, H_var, p_var] = statistics_multipleTest(x, GROUP)

        numVar = size(x,2);
        
        % test if residues (=value - sample_mean) come from normal distribution
        for i=1:numVar
            % anderson darling test has a higher test strength than lilliefors test
            if length(x(:,i))>=4
            [H_norm(i), p_norm(i)] = adtest(x(:,i)-mean(x(:,i))); % H!=0, H=0 indicates that the null hypothesis ("the data are normally distributed") cannot be rejected at the 5% significance level. H=1 indicates that the null hypothesis can be rejected at the 5% level.
            end
        end
        
        % test for homoscedasticity (all variables have to have the same variance)
        for i=1:numVar
            for k=1:numVar
                [H_var(i,k), p_var(i,k)] = vartest2(x(:,i),x(:,k)); % H!=0, F test: null hypothesis = variances are equal => H!=0
            end
        end
        
        % validity (TODO)
        % validity=~H_norm & ~H_var;
        
        % parameter free test: Kruskal-Wallis' test is a non parametric one way anova. While Friedman's test can be thought of as a (non parametric) repeated measure one way anova
        
        % one-way anova
        [p_anova,table,stats] = anova1(x,GROUP,'off');   % returns the p-value for the null hypothesis that the means of the groups are equal.
        [COMPARISON,m,h,nms] = multcompare(stats);      % COMPARISON: one row per comparison and six columns.  
                                                        % Columns 1-2 are the indices of the two samples being compared.  
                                                        % Columns 3-5 are a lower bound, estimate, and upper bound for their difference. 
                                                        % Column 6 is the p-value for each individual comparison. 
end