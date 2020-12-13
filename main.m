tic
clc; clear all; 
Fs = 44100; nBits = 8; nChannels = 1;
Tw = 20;           % analysis frame duration (ms)
Ts = 10;           % analysis frame shift (ms)
alpha = 0.97;      % preemphasis coefficient
R = [ 300 3700 ];  % frequency range to consider
M = 20;            % number of filterbank channels 
C = 13;            % number of cepstral coefficients
L = 22;            % cepstral sine lifter parameter
% hamming window (see Eq. (5.2) on p.73 of [1])
hamming = @(N)(0.54-0.46*cos(2*pi*[0:N-1].'/(N-1)));
%%
A = [];
for f = 1 : 4
    n = input( 'For how many sec you want to record?' );
    recObj = audiorecorder(Fs,nBits,nChannels);
    disp( 'Start speaking.' );
    recordblocking( recObj,n );
    disp( 'End of Recording.' );
    play(recObj);
    y = getaudiodata(recObj);
    [ b, FBEs, frames ] =  mfcc( y, Fs, Tw, Ts, alpha, hamming, R, M, C, L );  
%    
%    for i = 1:length(b)
% 
%         if sum(isnan(b(:,i)))~=0
% 
%             b(:,i) = 0;
% 
%         end
% 
%    end
% 
   A(:,:,f) = b;
   
end

%% Connection of Bluetooth module
a = Bluetooth('HC-05',1);
fopen(a);
'Bluetooth Successfully Connected'


%%
% load('C:\Users\User\Desktop\Audio.mat')
% while(1)

%   n = input( 'For how many sec you want to record?' );
recObj = audiorecorder(Fs,nBits,nChannels);
disp( 'Start speaking.' );
recordblocking( recObj,1 );
disp( 'End of Recording.' );
%     play(recObj);
y = getaudiodata(recObj);
[ b, FBEs, frames ] =  mfcc( y, Fs, Tw, Ts, alpha, hamming, R, M, C, L );  


error = zeros(4,length(b));
for k = 1:4

    for j = 1:length(b)
    
        error(k,j) = dtw(A(:,:,k),circshift(b,j-1,2));
        

    end

end

err = min(error,[],2);



result = find(err == min(err))

fprintf(a,result);
% end
toc
