%% usage: colormap(cmap)

function cmap=get_cmap(colorA, colorB, colorC, colorD)
      
  res=1000; %resolution

  if nargin == 3
      R = linspace(colorA(1),colorB(1),res/2);
      G = linspace(colorA(2),colorB(2),res/2);
      B = linspace(colorA(3),colorB(3),res/2);
      T = [R', G', B'];
      cmap(1:res/2, :) = T;
      R = linspace(colorB(1),colorC(1),res/2);
      G = linspace(colorB(2),colorC(2),res/2);
      B = linspace(colorB(3),colorC(3),res/2);
      T = [R', G', B'];
      cmap(res/2+1:res, :) = T;
  end
  
  if nargin == 4
      R = linspace(colorA(1),colorB(1),res*1/3);
      G = linspace(colorA(2),colorB(2),res*1/3);
      B = linspace(colorA(3),colorB(3),res*1/3);
      T = [R', G', B'];
      cmap(1:res/3, :) = T;
      R = linspace(colorB(1),colorC(1),res*1/3);
      G = linspace(colorB(2),colorC(2),res*1/3);
      B = linspace(colorB(3),colorC(3),res*1/3);
      T = [R', G', B'];
      cmap(res*1/3+1:res*2/3, :) = T;
      R = linspace(colorC(1),colorD(1),res*1/3);
      G = linspace(colorC(2),colorD(2),res*1/3);
      B = linspace(colorC(3),colorD(3),res*1/3);
      T = [R', G', B'];
      cmap(res*2/3+1:res, :) = T;
  end

      

end