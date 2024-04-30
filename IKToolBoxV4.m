%% Free and straight line motion
clc
clear all
%Links nnow changed; specs updated according  to Lynxmotion Robot Arm   
L1 = 153;
L2 = 153;
L3 = 98;
d1 = 68;

%% DH parameters
LL(1) = Link('a',0,'alpha',pi/2,'d',d1);   
LL(2) = Link('a',L1,'alpha',0,'d',0);       
LL(3) = Link('a',L2,'alpha',0,'d',0);       
LL(4) = Link('a',0,'alpha',pi/2,'d',0);
LL(5) = Link('a',0,'alpha',0,'d',L3);


%PLot
robo = SerialLink(LL)
robo.name = 'Lynx motion'

%5 points 
% max range of the arm 1000 830 0
TT1 = transl([200 20 100]) * trotx(180)
TT2 = transl([150 10 20]) * trotx(180)
TT3 = transl([0 100 100]) * trotx(180)
TT4 = transl([-100 50 20]) * trotx(180)
TT5 = transl([0 0 200]) * trotx(180) 

%inverse kinematics
qdmax = [1 1 1 1 1];
DT = 0.03;
TACC = 0.5; %acceleration

q1 = robo.ikine(TT1, 'mask',[1 1 1 1 1 0]);

q2 = robo.ikine(TT2, 'mask',[1 1 1 1 1 0]);

q3 = robo.ikine(TT3, 'mask',[1 1 1 1 1 0]);

q4 = robo.ikine(TT4, 'mask',[1 1 1 1 1 0]);

q5 = robo.ikine(TT5, 'mask',[1 1 1 1 1 0]);

%matrix

S1 = q1(1,:)
S2 = q2(1,:)
S3 = q3(1,:)
S4 = q4(1,:)
S5 = q5(1,:)

S0 = [S1;S2;S3;S4;S5] %free motion and straight line points in a matrix
%trajectory between multiple points
figure(1)
set(1,'position',[540 190 760 540])
A = mstraj(S0,qdmax,[],S1,DT,TACC) %trajectory
title('Free motion between points')
robo.plot(A, 'trail', 'r') %free motion between points