% Make error bar plot but instead of error bars plot shaded area (MC)

function h=plotShaded(x,y,dmin,dmax,hs,color)
    
    axes(hs); % make h current axes
    
    % remove singleton dimensions
    x=squeeze(x);
    y=squeeze(y);
    dmax=squeeze(dmax);
    dmin=squeeze(dmin);
    
    % array dimension has to be n by 1
    if size(x,2)>size(x,1); x=x'; end
    if size(y,2)>size(y,1); y=y'; end
    if size(dmax,2)>size(dmax,1); dmax=dmax'; end
    if size(dmin,2)>size(dmin,1); dmin=dmin'; end
    
    % all vectors have to have the same dimension (e.g. x = 2x1, y = 1x2 is
    % not allowed!)
    if size(x)~=size(y)
        errordlg('Different dimensions of x, y, dmin, and dmax!')
    end

    h=fill([x;flipud(x)],[y-dmin;flipud(y+dmax)],color); hold on
    %X=[x;flipud(x)];
    %Y=[y-dmin;flipud(y+dmax)];
    %Z=ones(size(X))*(-.1);
    %h=patch(X,Y,Z,color); hold on % patch is same as fill but has z-coordinate that can be used to bring area into background
    
    uistack(h, 'bottom');
    
    h.FaceAlpha=0.15;
    h.LineStyle='none';
    
    h=plot(x,y,'- .');
    h.Color=color;
end