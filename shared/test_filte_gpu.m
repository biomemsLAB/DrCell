function  [G,a]=test_filte_gpu(M)

%------------test aval
%         x = gpuArray.rand(8, 10);% test GPU
%         b = rand(5, 1);
%         a = 3;
%         y = filter(b,a,x);
%         G = gather(y);
        
%----------test dade vaghei-----        

%         x = gpuArray.rand(8, 10);% test GPU
tic
        x = gpuArray(M);
        b = rand(5, 1);
        a = 3;
        y = filter(b,a,x);
        G = gather(y)
toc
a=toc
%    
        
 % ------------------filter ohne GPU --------------
%         tic
%         M = filter(Hd,M);
%         toc
%         a=toc
 %------------------filter mit GPU dade vagheii-------     
%  tic
%         x = gpuArray(M);
%         y = filter(Hd,x);
%         G = gather(y)
%  toc
%  a=toc
 
        
end
