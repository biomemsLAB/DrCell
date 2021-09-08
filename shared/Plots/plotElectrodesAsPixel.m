function [hs,hc]=plotElectrodesAsPixel(TS,EL_NAMES,hs,HDmode)

[x,y]=get_X_Y_CoordinatesFromMeaLayout(EL_NAMES,HDmode);

TS_intensity = sum(TS~=0);

for i=1:size(TS,2)
      M(y(i),x(i))=TS_intensity(i); 
end

%image(M)

imagesc(M,[0 100]) % 0 100



hc=colorbar;


end



