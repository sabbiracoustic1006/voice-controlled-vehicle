# voice-controlled-vehicle

In this project, we used voice command to control the movement of the car by processing the voice commands in MATLAB and maintaining MATLAB-ARDUINO communication via Bluetooth module.

* We have used four voice commands(FORWARD,RIGHT,LEFT,STOP) to control the wheel chair
* First, the voice commands are saved as .MAT file in MATLAB from a specific user to use as reference
* Then voice commands from user are taken and processed by matlab to produce corresponding command codes
* For serial communication, we used HC-05 Bluetooth Module which is paired with matlab using the Bluetooth of PC
* Corresponding Command codes are sent to ARDUINO through the Bluetooth module
* Then arduino processed the received code to generate the required logic for the motor driver to control the car according to user’s intended direction

Below the matlab code for prerecording MFCCs for audio commands is shown.

```markdown
clc; clear all;
Fs = 44100; nBits = 8; nChannels = 1;
Tw = 20;
# analysis frame duration (ms)
Ts = 10;
# analysis frame shift (ms)
alpha = 0.97;
# preemphasis coefficient
R = [ 300 3700 ]; % frequency range to consider
M = 20;
# number of filterbank channels
C = 13;
# number of cepstral coefficients
L = 22;
# cepstral sine lifter parameter
# hamming window 
hamming = @(N)(0.54-0.46*cos(2*pi*[0:N-1].'/(N-1)));

A = [];
for f = 1 : 4
n = input( 'For how many sec you want to record?' );
recObj = audiorecorder(Fs,nBits,nChannels);
disp( 'Start speaking.' );
recordblocking( recObj,n );
disp( 'End of Recording.' );
play(recObj);
y = getaudiodata(recObj);
[ b, FBEs, frames ] = mfcc( y, Fs, Tw, Ts, alpha, hamming, R, M, C, L );
A(:,:,f) = b;
end
```

The user given command at test time was aligned and the closest match was found using Euclidean distance. The code snippet for this alignment and finding closest match is given below.

```markdown
# Connection of Bluetooth module
a = Bluetooth('HC-05',1);
fopen(a);
'Bluetooth Successfully Connected'

# record audio for 1 second
recObj = audiorecorder(Fs,nBits,nChannels);
disp( 'Start speaking.' );
recordblocking( recObj,1 );
disp( 'End of Recording.' );
play(recObj);
y = getaudiodata(recObj);
[ b, FBEs, frames ] = mfcc( y, Fs, Tw, Ts, alpha, hamming, R, M, C, L );

# the mfccs for the test command is aligned and matched with the prerecorded audio commands mfccs
error = zeros(4,length(b));
for k = 1:4
for j = 1:length(b)
error(k,j) = dtw(A(:,:,k),circshift(b,j-1,2));end
end
err = min(error,[],2);
result = find(err == min(err))
fprintf(a,result);
```

