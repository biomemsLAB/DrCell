% idletime deletes k_n+1 elements in Array if   k_n+1 - k_n < time  
   
function Array=idle_time(Array,time)
if time~= 0 % Idletime (=Refractory time) in seconds
    for n=1:size(Array,2)
     for k=1:size(Array,1)-2 
         while (Array(k+1,n)-Array(k,n)<(time)) && (Array(k+1,n)~=0)
            Array((k+1):size(Array,1)-1,n)=Array((k+2):size(Array,1),n); % delete Spike k+1 and decrease position of following spikes by one
            Array(size(Array,1),n)=0; % fill last position with zero
         end
     end
    end      
end