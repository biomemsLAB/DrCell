% detect peaks in a given signal defined by threshold
% signal is a 1D array!
% th a scalar value or same sized array like signal

function [x,y,begin,ending,duration,integral,peakMask] = detectSpikesFromThreshold(signal,th)

    % init
    x=NaN; % x coordinate of peak
    y=NaN; % y coordinate of peak
    begin=NaN;
    ending=NaN;
    duration=NaN;
    integral=NaN;
    peakMask = zeros(1,length(signal)); % is one during a peak


    M = signal > th; % mask
    
    m=1; % current sample position
    k=0; % index of nth peak
    potbeg = 0;
    potend = 0;
    X=1:length(signal);
    
    
%     %% new detection
%     tic
%     M_diff = zeros(size(M,1)+2,size(M,2));
%     M_dummy = zeros(size(M,1)+2,size(M,2)); % add 0 at beginnig and end
%     M_dummy(2:end-1,:)=M;
%     M_diff(2:end,:)= M_dummy(1:end-1,:)-M_dummy(2:end,:);
%     
%     
%     I_beg = find(M_diff==-1);
%     I_end = find(M_diff==1);
%     
%     
%     [I_beg_row,I_beg_col]=ind2sub(size(M_diff),I_beg);
%     [I_end_row,~]=ind2sub(size(M_diff),I_end);
%     I_beg_row=I_beg_row-1;
%     I_end_row=I_end_row-1;
%     
%     for i=1:length(I_beg_row)
%         [y(i,I_beg_col(i)),x(i,I_beg_col(i))]=max(signal(I_beg_row(i):I_end_row(i),I_beg_col(i)));
%         x(i,I_beg_col(i))=x(i,I_beg_col(i))+I_beg_row(i)-1; % add offset
%     end
%     
%     x(x==0)=NaN;
%     x=sort(x);
%     y(y==0)=NaN;
%     y=sort(y);
%     toc
%     %%
 
   
    while m <= length(M)-1
        % beginning of peak
        if m==1 && M(1)==1 % if first element is already above th
            potbeg = m;
            flag_first = 1;
        end
        if M(m+1)>M(m) % if th is crossed from beneath
            potbeg = m+1;
            flag_first = 0;
        end
        % end of peak
        if m==length(M)-1 && M(end)==1 && flag_first==0 && (potbeg ~= 0) % if last element is still above th
            potend = m+1;
        end
        if (M(m+1)<M(m) && (potbeg ~= 0)) % if th is crossed from above
            potend = m;
        end
        % Peak
        if potend ~= 0
            peakMask(potbeg:potend)=1; % peakMask is one during a peak
            SEARCH = signal(potbeg:potend);
            k=k+1;
            [y(k),I]= max(SEARCH); % search for negative peak (-> min)
            x(k) = X((potend-length(SEARCH)+I));
            begin(k)=potbeg;
            ending(k)=potend;
            duration(k)=potend-potbeg+1;
            integral(k)=sum(signal(potbeg:potend));
            potbeg = 0;
            potend = 0;
        end
        m = m + 1;
    end 
    
            
end