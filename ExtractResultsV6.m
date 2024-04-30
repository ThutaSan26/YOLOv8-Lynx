%% File name - ExtractResultsV6.m
%% Author- K.Tun

%% Date Created - 10 April 2024
%% Date Last Modified - 10 April 2024

%% New features in Version 6: 
%% - Ik values are now converted to degrees from radians 
%% - Now includes serial communication to robotic arm 
%% - Minor code modification 

%% Code Description- This is the sixth version of the file "ExtractResults". The script has multiple functions:
%% 1. Extracts the bounding box coordinates from the text file
%% 2. Calculates Inverse Kinematics and simulates trajectory planning
%% 3. Maps the angle values from IK to servo PWM values 
%% 4. Drives the robotic arm from the obtained PWM values via Serial Communication

clc
clear all

%% 1.Result Extraction from "results.txt" text file

% Open the text file for reading
fid = fopen('results.txt', 'r');

if fid == -1
    error('Could not open the file.');
end

% Read the integers from the file
data = textscan(fid, '%f, %f');

% Close the file
fclose(fid);

% Read the float numbers from the file with commainput_value3 as delimiter
float_numbers = [data{1},data{2}]; % Concatenate the two cell arrays into one array

%Type casting the extracted coordinates to double
 extracted_x = double(data{1});
 extracted_y = double(data{2});

% Display the extracted float numbers
 disp('Extracted x and y:');
 disp(extracted_x);
 disp(extracted_y);


%% IK calculation and Trajectory Planning
%DH parameters updated according to SES-V1 AL5D Lynxmotion Robot Arm   
L1 = 153;
L2 = 153;
L3 = 98;
d1 = 68;

% DH parameters
LL(1) = Link('a',0,'alpha',pi/2,'d',d1);   
LL(2) = Link('a',L1,'alpha',0,'d',0);       
LL(3) = Link('a',L2,'alpha',0,'d',0);       
LL(4) = Link('a',0,'alpha',pi/2,'d',0);
LL(5) = Link('a',0,'alpha',0,'d',L3);


%PLot
robo = SerialLink(LL)
robo.name = 'Lynx motion'

%5 points 
%only using 3 points for now, additional 2 points are commented out
TT1 = transl([0 0 200]) * trotx(180, 'deg')
TT2 = transl([extracted_x extracted_y 0]) * trotx(180, 'deg')
TT3 = transl([0 0 200]) * trotx(180, 'deg')

%TT4 = transl([0 0 200]) * trotx(180, 'deg')
%TT5 = transl([0 0 200]) * trotx(180, 'deg')

%inverse kinematics
qdmax = [1 1 1 1 1];
DT = 0.1;
TACC = 0.5; %acceleration

q1 = robo.ikine(TT1, 'mask',[1 1 1 1 1 0]);

q2 = robo.ikine(TT2, 'mask',[1 1 1 1 1 0]);

q3 = robo.ikine(TT3, 'mask',[1 1 1 1 1 0]);

%q4 = robo.ikine(TT4, 'mask',[1 1 1 1 1 0]);

%q5 = robo.ikine(TT5, 'mask',[1 1 1 1 1 0]);


%matrix
S1 = q1(1,:)
S2 = q2(1,:)
S3 = q3(1,:)
%S4 = q4(1,:)
%S5 = q5(1,:)
S0 = [S1;S2;S3] %free motion points in a matrix

%trajectory between multiple points
figure(1)
set(1,'position',[540 190 760 540])
A = mstraj(S0,qdmax,[],S1,DT,TACC) %trajectory
title('Free motion between points')
robo.plot(A, 'trail', 'r') %free motion between points


%% Extract results
% Type casting the angle values from IK to double
input_value1_radians = double(q1(1,1:5));
input_value2_radians = double(q2(1,1:5));
input_value3_radians = double(q3(1,1:5));

%Radians to Degrees conversion
input_value1_degrees  = rad2deg(input_value1_radians);
input_value2_degrees  = rad2deg(input_value2_radians);
input_value3_degrees  = rad2deg(input_value3_radians);

%Mapping from degrees to servo PWM values
mapped_values1 = map_servo_values(input_value1_degrees);
mapped_values2 = map_servo_values(input_value2_degrees);
mapped_values3 = map_servo_values(input_value3_degrees);

%% IMPORTANT: to make the array to double as the fprintf only accepts double

%%type casting
mapped_double1 = double(mapped_values1);
mapped_double2 = double(mapped_values2);
mapped_double3 = double(mapped_values3);

disp(['Mapped values for position 1: ', num2str(mapped_double1)]);
disp(['Mapped values for position 2: ', num2str(mapped_double2)]);
disp(['Mapped values for position 3: ', num2str(mapped_double3)]);

delay = 5;    % Variable for between the moves (>1)

%% Open communication via /dev/ttyUSB0

s = serial('/dev/ttyUSB0','Baudrate', 9600,'Terminator','LF/CR');
fopen(s) ;
disp('serial port opened')

disp(num2str(mapped_double1))
disp(num2str(mapped_double2))
disp(num2str(mapped_double3))

% Wait for initialisation to finish
pause(delay)

%% This is the 'Home position for most of the robots 
% IMPORTANT: You might need to check this for 'your' robot

%%start with home position
fprintf(s,'#0 P1500 S400 #1 P1500  S400 #2 P1500 S400 #3 P1500 S400 #4 P1500 S400 #5 P1500 S400\r') ;
pause(3)

%position1
fprintf(s,'#0 P%f S400 #1 P%f S400 #2 P%f S400 #3 P%f S400 #4 P%f S400 #5 P500 S400\r', mapped_double1);
pause(6)

%position2
fprintf(s,'#0 P%f S400 #1 P%f S400 #2 P%f S400 #3 P%f S400 #4 P%f S400 #5 P500 S400\r', mapped_double2);
pause(6)

%position 3
fprintf(s,'#0 P%f S400 #1 P%f S400 #2 P%f S400 #3 P%f S400 #4 P%f S400 #5 P500 S400\r', mapped_double3);
pause(6)

%back to home position
fprintf(s,'#0 P1500 S400 #1 P1500  S400 #2 P1500 S400 #3 P 1500 S400 #4 P1500 S400 #5 P1500 S400\r') ;
pause(3)


%% Close the serial port
fclose(s) ;
disp('serial port closed')


function mapped_values = map_servo_values(input_value_array)
    % Define the input range for 5 servos
    input_min = [0, 0, -23, -34, -90];
    input_max = [180, 180, 157, 145, 90];

    % Define the new range for all 5 servos
    new_min = 500.0;
    new_max = 2500.0;
    
    % Initialize the mapped_values array
    mapped_values = zeros(size(input_value_array));
    
    % Perform mapping for each element
    for i = 1:numel(input_value_array)
        % Map the input value to the new range
        if i == 1
            mapped_values(i) = map_value(input_value_array(i), input_min(i), input_max(i), new_max, new_min);
        else    
            mapped_values(i) = map_value(input_value_array(i), input_min(i), input_max(i), new_min, new_max);
        end 
    end

end


% Function to map a value from one range to another
function mapped_value = map_value(value, old_min, old_max, new_min, new_max)
    % Perform linear mapping
    mapped_value = (value - old_min) * (new_max - new_min) / (old_max - old_min) + new_min;
end
