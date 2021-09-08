function Time_Shape = export_Time_Shape(EL_NUMS,M,SPIKES,SaRa)

        clear Time adress Shape SP SPI;

        Time(1,:) = EL_NUMS(1,:);
        Time(2:size(SPIKES,1)+1,:) = SPIKES;
        
        SP = SPIKES*SaRa;
        pretime = 0.5;
        posttime = 0.5;
        
        for n=1:size(SP,2)
            SPI=nonzeros(SP(:,n));
            for i=1:size(SPI,1)
                if ((SPI(i)+1+floor(SaRa*posttime/1000))>size(M,1))||((SPI(i)+1-ceil(SaRa*pretime/1000)) <=0) % Spikes with length of 2*0.5 msec!!!
                   S_orig(i,n,1:1+floor(SaRa*pretime/1000)+ceil(SaRa*posttime/1000))= zeros;
                else
                   S_orig(i,n,:)=M(SPI(i)+1-floor(SaRa*pretime/1000):SPI(i)+1+ceil(SaRa*posttime/1000),n); % Shapes with variable window length
                end
               Shapes(i,n,:) = S_orig(i,n,:);
            end
            if size(SPI,1)<1
               Shapes(:,n,:) = zeros; 
            end
            clear SPI;
        end
        
        Shape(1:size(SP,1),1:size(EL_NUMS,2)*size(Shapes,3))=zeros;
        
        for n = 1:size(EL_NUMS,2)
            Shape(1,(size(Shapes,3)*(n-1))+1:(size(Shapes,3)*n)) = EL_NUMS(1,n);
            Shape(2:size(SP(:,n))+1,(size(Shapes,3)*(n-1)+1):(size(Shapes,3)*n)) = Shapes(:,n,:);
        end
        
        if size(Time,2)<60
           EL_NUMS_full = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
           Time_full(1,:) = EL_NUMS_full;
           Time_full(2:size(Time,1),:)=zeros;
           for n=1:size(EL_NUMS_full,2)
                Shape_full(1,(size(Shapes,3)*(n-1)+1):(size(Shapes,3)*n)) = EL_NUMS_full(n);
           end
           Shape_full(2:size(Time,1),:)=zeros;
           for i = 1:size(Time,2) 
               [~,nc]= find(EL_NUMS_full(:,:)==EL_NUMS(i));
               Time_full(:,nc) = Time(:,i);
               Shape_full(:,((nc-1)*size(Shapes,3)+1):nc*size(Shapes,3)) = Shape(:,((i-1)*size(Shapes,3)+1):i*size(Shapes,3));
           end
           Time_Shape = [Time_full,Shape_full];
        else
           Time_Shape = [Time,Shape];
        end
        
           temp = sortrows(Time_Shape',1)';
           clear Time_Shape
           Time_Shape = temp; 
                  
   end