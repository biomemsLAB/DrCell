% Filter function used by Automated Analysis


function [RAW,filterName,f_edge]=ApplyFilter(RAW,f_edge,HDrawdata,flag_waitbar)

[RAW,filterName,f_edge]=bandstop(RAW,f_edge,RAW.SaRa,HDrawdata,flag_waitbar);

% if nargin <=2
%     HDrawdata=0;
%     flag_waitbar=0;
% end
% % if f_edge > 0 % only filter if f_edge is greater than 0 Hz
% %
% %     [z,p,k] = cheby2(3,20, f_edge*2/RAW.SaRa,'high');
% %     %cheby2(N,R,Wst,'high'); N=OrderOfFilter, R=RippleDecibel, Wst=EdgeFrequency:0...1.0 (1=half of SampleRate), 'high'=highpass,'low''stop'
% %     [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
% %     Hd = dfilt.df2tsos(sos,g);
% %     f_edge=f_edge;
% %     Name='HP_cheby2_order3_ripple20';
% %     RAW.M = filter(Hd,RAW.M);
% % else
% %     f_edge=0;
% %     Name='noFilter';
% % end
% 
% f_edge_low=0;
% f_edge_high=f_edge;
% 
% % taken from DrCell (bandstop)
% 
% MM=RAW.M;
% SaRa=RAW.SaRa;
% 
% if flag_waitbar; h_wait = waitbar(0,'Filtering'); end
% if f_edge_low == 0 % in case that lower boundary equals zero use highpass instead of bandstop
%     [z,p,k] = cheby2(3,20,f_edge_high*2/SaRa,'high');
%     [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
%     Hd = dfilt.df2tsos(sos,g);
% else
%     [z,p,k] = cheby2(3,20,[f_edge_low *2/SaRa f_edge_high*2/SaRa],'stop');
%     [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
%     Hd = dfilt.df2tsos(sos,g);
% end
% if size(MM,2)<=1000    %for .mat Data
%     MM = filter(Hd,MM);
% else
%     flag_enoughMemory = testMemory();
%     if flag_enoughMemory% When enough memory is available
%         j=1200;
%     else
%         j=1;
%     end% bei kleinem Arbeitsspeicher muss j kleiner werden
%     if HDrawdata ==1   || size(MM,2)>1000  % for .brw Data
%         for i=0:j:(floor(numel(MM(1,:))/j)-1)*j
%             
%             if flag_waitbar; waitbar(((floor(numel(MM(1,:))/j)-1)*j)/i,h_wait); end
%             
%             if HDrawdata ==1
%                 m=digital2analog_sh(MM(:,i+1:i+j),RAW);
%                 m(m<-4000)=0;
%                 m(m>4000)=0;
%                 m=(filter(Hd,m));
%                 m=RAW.SignalInversion*(m/(RAW.MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2); % %convert analog values to digital sample Values
%                 MM(:,i+1:i+j)=m;
%             else %for .mat Data mit  El > 60
%                 m = MM(:,i+1:i+j);
%                 m = filter(Hd,m);
%                 MM(:,i+1:i+j) = single(m);
%             end
%         end
%         i=i+j;
%         if i<size(MM,2)
%             clear m;
%             if HDrawdata ==1
%                 m=(MM(:,i+1:size(MM,2)));
%                 m=digital2analog_sh(m,RAW);
%                 m(m<-4000)=0;
%                 m(m>4000)=0;
%                 m=(filter(Hd,m));
%                 m=(m/(RAW.MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2); % %convert analog values to digital sample Values
%                 MM(:,i+1:size(MM,2))=m;
%             else %for .mat Data mit  El > 60
%                 m=(MM(:,i+1:size(MM,2)));
%                 m = filter(Hd,m);
%                 MM(:,i+1:size(MM,2))=m;
%             end
%         end
%     end
% end
% 
% RAW.M=MM;
% Name='HP_cheby2_order3_ripple20';
% 
% if flag_waitbar; waitbar(1, h_wait); close(h_wait); end

end

