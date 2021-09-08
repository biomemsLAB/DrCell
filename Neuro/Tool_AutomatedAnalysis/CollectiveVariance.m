% --- Variance -----------------------------------------------------
    function [x,varges,n]=CollectiveVariance(xj,sj,nj) 
        % xj: mean value of each electrode
        % sj: std value of each electrode
        % nj: number of elements of each electrode
        
        n = sum(nj,'omitnan'); % number of elements of entire chip
        x = 1/n * sum(nj.*xj,'omitnan'); % mean value of entire chip
        varint = 1/n * sum(nj.*(sj.^2),'omitnan'); 
        varext = 1/n * sum(nj.*((xj-x).^2),'omitnan');
        varges = varint + varext; % variance of entire chip
    end