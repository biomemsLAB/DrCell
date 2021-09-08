function [CMres] = TSPE_withSurrogateThreshold(sdf, d, wins_before, wins_co, wins_in, jitt, FLAG_NORM, stdfactor, NrLoops, flag_waitbar)
% Parameters:
%   sdf         - Time series in Spike Data Format (in samples, not seconds!!!)(SDF)
%   d           - Maximal delay time (default 25)
%   wins_before - Windows for before and after area of interest (default [3, 4, 5, 6, 7, 8])
%   wins_co     - Cross-over window size (default 0)
%   wins_in     - Sizes of area of interest (default [2, 3, 4, 5, 6])
%   jitt        - Jitter-Window-Size (default 3)
%   FLAG_NORM   - 0 - no usage of normalization (default)
%               - 1 - usage of normalization
%   stdfactor   - standard deviatio factor for thresholding (default 3)
%   NrLoops     - Number of iterations for surrogate generation (default 50)
%
% Returns:
%   CMres       - NxN matrix where N(i, j) is the total spiking probability edges (TSPE) i->j


switch nargin
  case 1
    d = [];
    wins_before = [];
    wins_co = [];
    wins_in = [];
    jitt = [];
    FLAG_NORM = [];
    stdfactor = [];
    NrLoops = [];
    flag_waitbar = false;
  case 2
    wins_before = [];
    wins_co = [];
    wins_in = [];
    jitt = [];
    FLAG_NORM = [];
    stdfactor = [];
    NrLoops = [];
    flag_waitbar = false;
  case 3
    wins_co = [];
    wins_in = [];
    jitt = [];
    FLAG_NORM = [];
    stdfactor = [];
    NrLoops = [];
    flag_waitbar = false;
  case 4
    wins_in = [];
    jitt = [];
    FLAG_NORM = [];
    stdfactor = [];
    NrLoops = [];
    flag_waitbar = false;
  case 5
    jitt = [];
    FLAG_NORM = [];
    stdfactor = [];
    NrLoops = [];
    flag_waitbar = false;
  case 6
    FLAG_NORM = [];
    stdfactor = [];
    NrLoops = [];
    flag_waitbar = false;
  case 7
    stdfactor = [];
    NrLoops = [];
    flag_waitbar = false;
  case 8
    NrLoops = [];      
    flag_waitbar = false;
  case 9    
    flag_waitbar = false;
  case 10
      % all parameters are already set
  otherwise
    error('Input error.')
end
if isempty(wins_in)
  wins_in=[2, 3, 4, 5, 6];
end
if isempty(wins_co)
  wins_co=0;
end
if isempty(wins_before)
  wins_before=[3, 4, 5, 6, 7, 8];
end
if isempty(d)
  d=25;
end
if isempty(jitt)
  jitt=3;
end
if isempty(stdfactor)
  stdfactor=3;
end
if isempty(NrLoops)
  NrLoops=50;
end
if isempty(FLAG_NORM)
  FLAG_NORM=0;
end


if flag_waitbar; hw = waitbar(0,'Estimating connectivity'); end


%% Generation of sparse matrices
    a=sdf{end}; % needed for 4 ch data from Cal.
    NrC = a(1); % needed for 4 ch data from Cal.
  
    vec1=[];
    vec2=[];

    for i=1:NrC
        vec1=[vec1 sdf{1,i}]; 
        vec2=[vec2 i*ones(1,length(sdf{i}))];
    end
    
    matr=sparse(vec1(vec1>0 & vec1 <= a(2)),vec2(vec1>0 & vec1 <= a(2)),1,a(2),a(1));
    
    %mat=sparse(vec1,vec2,1);
    NrS=a(2);
    %clear vec1 vec2 a;
    
    
    
%% Calculation of std deviation and mean values   
    l=ones(1,NrS);
    
    
    u_mean=l*matr/NrS;
    u_0=matr-u_mean;
    r=std(u_0);
    
    
%% Fast Cross-Correlation  
    
    ran=1-max(wins_before)-max(wins_co):max(wins_before)+d;
    CM=(zeros(length(ran),NrC,NrC));

    ind=max(wins_before)+max(wins_co);                                                
    if(ind <= 0)
        ind=1;
    end
    
    for i=0:d+max(wins_before)
        CM(ind,:,:)=(matr(1+i:end,:)'*matr(1:end-i,:))./(r'*r)/NrS;
        
        % Correct form: 
        % CM(ind,:,:)=(u_0(1+i:end,:)'*u_0(1:end-i,:))./(r'*r)/NrS;
        % takes longer, no performance impact

        ind=ind+1;
    end
    
    
% Usage of symmetric construction of cross correlation for faster
% calculation:
    if(max(wins_before)+max(wins_co) > 0)
        bufCM=zeros(NrC);
        ind=0;
        for j=max(wins_before)+max(wins_co)-1:-1:1
            bufCM(:)=CM(max(wins_before)+max(wins_co)+j,:,:);
            ind=ind+1;
            CM(ind,:,:)=bufCM';
        end
    end
    
    
% Additional scaling for reduction of network burst impacts:
    if FLAG_NORM
      s=zeros(length(ran),1);
      for i=1:length(ran)
          zwi=CM(i, ~ diag(ones(NrC,1)));
          s(i)=sum(sum(  zwi(~ isnan(CM(i, ~ diag(ones(NrC,1)))))));
      end
      CM=CM./s;
    end  
    
    
%% Generation of edge filters

    WB=max(wins_before)+max(wins_co);
    sumWin=zeros(d+WB,NrC,NrC);
    in=0;
    for win_before=wins_before
      for win_p1=wins_co 
        for win_in=wins_in
            in=in+1;
            win_p2=win_p1;
            win_after=win_before;
            windows{in}=[-1*ones(win_before,1) /win_before; zeros(win_p1,1);2/win_in* ones(win_in,1);zeros(win_p2,1);-1*ones(win_after,1)/win_after];
            beginnings{in}=1+WB-win_before-win_p1;
            win_inner{in}=win_in;
        end
      end
    end
            
    m=d+max(wins_before)+max(wins_co)+max(wins_in);      
%% Usage of edge filters: 
    for j=1:in         
            CM3=convn(convn(CM(beginnings{j}:end, : , :),windows{j},'valid'),[ones(win_inner{j},1)],'full');
            m=min(m,length(CM3(:,1,1)));
           
            
            sumWin(1:size(CM3,1),:,:)=CM3+sumWin(1:size(CM3,1),:,:);
    end
  
%% Only look at valid window
    sumWin=sumWin(1:m,:,:);
    
 %% Adjustment and looking for maximum at each delay time 
 
    sumWin=permute(sumWin, [1 3 2]);
    [~,index] = max(abs(sumWin));
    CMres=zeros(NrC);
    DMres=index; % new, DelayMatrix
    for i=1:size(sumWin,2)
        CMres(:,i)=sumWin(sub2ind(size(sumWin), index(1,1:size(sumWin,2),i), 1:size(sumWin,2), i * ones(1,size(sumWin,2)))    );
    end



%CMresMean=zeros(NrLoops,NrC,NrC);
CMresMean=cell(NrLoops,1);%zeros(NrLoops,NrC,NrC);


%% Generation of edge filters

    WB=max(wins_before)+max(wins_co);
    
    in=0;
    for win_before=wins_before
      for win_p1=wins_co 
        for win_in=wins_in
            in=in+1;
            win_p2=win_p1;
            win_after=win_before;
            windows{in}=[-1*ones(win_before,1) /win_before; zeros(win_p1,1);2/win_in* ones(win_in,1);zeros(win_p2,1);-1*ones(win_after,1)/win_after];
            beginnings{in}=1+WB-win_before-win_p1;
            win_inner{in}=win_in;
        end
      end
    end
            
  
for iiii=1:NrLoops

    
    if flag_waitbar; waitbar(iiii/NrLoops,hw,'Estimating connectivity'); end
    
    sumWin=zeros(d+WB,NrC,NrC); %test

    
%% Generation of sparse matrices
    vec1_o=[];
    vec2=[];
    
    
    
    for i=1:NrC
        vec1_o=[vec1_o sdf{i}]; 
        vec2=[vec2 i*ones(1,length(sdf{i}))];
    end
    
    vec1=vec1_o+randi([-jitt,jitt],1,length(vec1_o));
    matr=sparse(vec1(vec1>0 & vec1 <= a(2)),vec2(vec1>0 & vec1 <= a(2)),1,a(2),a(1));
    matr(matr>1)=1;
    
    
    NrS=a(2);
    
    
    
%% Calculation of std deviation and mean values   
    l=ones(1,NrS);
    
    
    u_mean=l*matr/NrS;
    u_0=matr-u_mean;
    r=std(u_0);
    
    
%% Fast Cross-Correlation  
    ran=1-max(wins_before)-max(wins_co):max(wins_before)+d;
    CM=(zeros(length(ran),NrC,NrC));

    ind=max(wins_before)+max(wins_co);                                                
    if(ind <= 0)
        ind=1;
    end
    
    for i=0:d+max(wins_before)
        CM(ind,:,:)=(matr(1+i:end,:)'*matr(1:end-i,:))./(r'*r)/NrS;
        
        % Correct form: 
        % CM(ind,:,:)=(u_0(1+i:end,:)'*u_0(1:end-i,:))./(r'*r)/NrS;
        % takes longer, no performance impact

        ind=ind+1;
    end
    
    
% Usage of symmetric construction of cross correlation for faster
% calculation:
    if(max(wins_before)+max(wins_co) > 0)
        bufCM=zeros(NrC);
        ind=0;
        for j=max(wins_before)+max(wins_co)-1:-1:1
            bufCM(:)=CM(max(wins_before)+max(wins_co)+j,:,:);
            ind=ind+1;
            CM(ind,:,:)=bufCM';
        end
    end
    
    
%% Additional scaling for reduction of network burst impacts:
    if FLAG_NORM
      s=zeros(length(ran),1);
      for i=1:length(ran)
          zwi=CM(i, ~ diag(ones(NrC,1)));
          s(i)=sum(sum(  zwi(~ isnan(CM(i, ~ diag(ones(NrC,1)))))));
      end
      CM=CM./s;
    end  
    
    
    
    m=d+max(wins_before)+max(wins_co)+max(wins_in);  
%% Usage of edge filters: 
    for j=1:in         
            CM3=convn(convn(CM(beginnings{j}:end, : , :),windows{j},'valid'),[ones(win_inner{j},1)],'full');
            m=min(m,length(CM3(:,1,1)));
           
            
            sumWin(1:size(CM3,1),:,:)=(CM3)+sumWin(1:size(CM3,1),:,:);
            
    end
  
%% Only look at valid window
    sumWin=sumWin(1:m,:,:);
    
 %% Adjustment and looking for maximum at each delay time 
    sumWin=permute(sumWin, [1 3 2]);
    [~,index] = max(abs(sumWin));
    %CMres=zeros(NrC);
    %DMres=index; % new, DelayMatrix
    CMresMean{iiii}=zeros(NrC);
    for i=1:size(sumWin,2)
        CMresMean{iiii}(:,i)=sumWin(sub2ind(size(sumWin), index(1,1:size(sumWin,2),i), 1:size(sumWin,2), i * ones(1,size(sumWin,2)))    );
    end
   
end 

    CMres2=zeros(NrLoops,NrC,NrC);
for iiii=1:NrLoops 
    CMres2(iiii,:,:)=CMresMean{iiii};
end

for iiii=1:NrC
   for iiiii=1:NrC
       
        if sum(0<CMres2(:,iiii,iiiii))~=0
            %CMres2ex(iiii,iiiii)=max(CMres2(0<CMres2(:,iiii,iiiii),iiii,iiiii))+1*std(CMres2(0<CMres2(:,iiii,iiiii),iiii,iiiii));
            CMres2ex(iiii,iiiii)=mean(CMres2(0<CMres2(:,iiii,iiiii),iiii,iiiii))+stdfactor*std(CMres2(0<CMres2(:,iiii,iiiii),iiii,iiiii));
        else
            CMres2ex(iiii,iiiii)=0;
        end
        
        if sum(0>CMres2(:,iiii,iiiii))~=0
            %CMres2in(iiii,iiiii)=min(CMres2(0>CMres2(:,iiii,iiiii),iiii,iiiii))-1*std(CMres2(0>CMres2(:,iiii,iiiii),iiii,iiiii));
            CMres2in(iiii,iiiii)=mean(CMres2(0>CMres2(:,iiii,iiiii),iiii,iiiii))-stdfactor*std(CMres2(0>CMres2(:,iiii,iiiii),iiii,iiiii));
        else
            CMres2in(iiii,iiiii)=0;
        end
   end
end


    %CMres2ex=reshape(max((CMres2)),NrC,NrC);%+stdfactor*reshape(std(abs(CMres2)),NrC,NrC);
    %CMres2in=reshape(min((CMres2)),NrC,NrC);
    
    CMres(~(((CMres2in > CMres) & (CMres < 0)) | ((CMres2ex < CMres) & (CMres > 0))))=0;
    
    %delete('tempdata_mat')
    if flag_waitbar; waitbar(1,hw,'Estimating connectivity: finished'); end
    
    if flag_waitbar; close(hw); end
    
end