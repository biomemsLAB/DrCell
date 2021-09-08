% "Fehlerfortpflanzung"

function [x,stdges,n]=CollectiveVariance_TK(xj,sj,nj) 
    % xj: mean value of each electrode
    % sj: std value of each electrode
    % nj: number of elements of each electrode

    n = sum(nj,'omitnan'); % number of elements of entire chip
    if n>1
        %x = 1/n * sum(nj.*xj,'omitnan'); % mean value of entire chip
        x = mean(nonzeros(xj),'omitnan');
        varint = 1/(n-1) * sum(nj.*(sj.^2),'omitnan'); 
        varext = 1/(n-1) * sum(nj.*((xj-x).^2),'omitnan');
        varges = varint + varext; % variance of entire chip
    else
       x=xj(1);
       varges=0;
       n=nj(1);
    end

    stdges = sqrt(varges); % standard deviation of entire chip
end