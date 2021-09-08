function PARAMETER=unpackWIN2PARAMETER(WIN)

    F=size(WIN,2); % number of files (= x values)
    P=size(WIN(1).parameter,2); % number of parameter

    %% check number of elements (e.g. number of spikes) for each file and parameter
    dim1_values=zeros(F,P);
    dim2_values=zeros(F,P);
    dim1_allEl=zeros(F,P);
    dim2_allEl=zeros(F,P);
    for f=1:F % for each file
        for p=1:P % for each parameter
           dim1_values(f,p)=size(WIN(f).parameter(p).values,1);
           dim2_values(f,p)=size(WIN(f).parameter(p).values,2);
           
           dim1_allEl(f,p)=size(WIN(f).parameter(p).allEl,1);
           dim2_allEl(f,p)=size(WIN(f).parameter(p).allEl,2);
        end
    end
    
    %% Init new variables
    PARAMETER(P*2)=struct();   % *2 as electrode wise parameter will be added for each parameter 
    max_dim1_values=zeros(P,1);
    max_dim2_values=zeros(P,1);
    max_dim1_allEl=zeros(P,1);
    max_dim2_allEl=zeros(P,1);
    for p=1:P % for each parameter
        max_dim1_values(p)=max(dim1_values(:,p));
        max_dim2_values(p)=max(dim2_values(:,p));
        PARAMETER(p).mean=zeros(F,1);
        PARAMETER(p).std=zeros(F,1);
        PARAMETER(p).values=zeros(max_dim1_values(p), max_dim2_values(p), F);
        
        max_dim1_allEl(p)=max(dim1_allEl(:,p));
        max_dim2_allEl(p)=max(dim2_allEl(:,p));
        PARAMETER(p).allEl=zeros(max_dim1_allEl(p), max_dim2_allEl(p), F);
    end
    
    
    %% fill new variables
    for f=1:F
        for p=1:P
            PARAMETER(p).pref(f).pref= WIN(f).parameter(p).pref; % preferences
            PARAMETER(p).YLabel= WIN(f).parameter(p).name; % parameter name
            PARAMETER(p).mean(f) = WIN(f).parameter(p).mean; % one mean value per file
            PARAMETER(p).std(f) = WIN(f).parameter(p).std; % one std value per file
            PARAMETER(p).values(1:dim1_values(f,p),1:dim2_values(f,p),f) = WIN(f).parameter(p).values; % all values per file (#elements x #electrodes x #F)
            
            PARAMETER(p).allEl(1:dim1_allEl(f,p),1:dim2_allEl(f,p),f) = WIN(f).parameter(p).allEl;
        end
    end
    
    %% Calculate electrode wise parameter (ew)
    for p=1:P
        [EWmean,EWstd,EWn,EW]=electrodeWiseNormalization(PARAMETER(p).allEl);
        
        PARAMETER(p+P).pref= PARAMETER(p).pref; % same structure as above
        PARAMETER(p+P).YLabel=[PARAMETER(p).YLabel ' (ew)'];
        PARAMETER(p+P).mean=EWmean;
        PARAMETER(p+P).std=EWstd;
        PARAMETER(p+P).values=EW;
    end
    PARAMETER=rmfield(PARAMETER,'allEl'); % remove field "allEl" as it is not needed anymore
    
    
    
end