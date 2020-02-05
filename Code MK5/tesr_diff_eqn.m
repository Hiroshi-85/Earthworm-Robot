clc
clear all
close all
%% Initialize connection with arduino and calibrate loadcell

a1 = arduino('COM10', 'Uno')
% Initialize the loadcell 1
L1 = addon(a1, 'ExampleAddon/HX711' ,{'D2' ,'D3'})
% Calibrate the loadcell
cal_1 = calibration(100, 20);   % # of readings, known weight
% Set the tare
cal_1.tare_weight = tare(cal_1, L1);
% Set scale factor. Already pre-computed, scale = 1.1801e+04
cal_1.scale_factor = 1.1801*10^4;

% Initialize the loadcell 2
L2 = addon(a1, 'ExampleAddon/HX711' ,{'D4' ,'D5'})
% Calibrate the loadcell
cal_2 = calibration(100, 20);   % # of readings, known weight
% Set the tare
cal_2.tare_weight = tare(cal_2, L2);
% Set scale factor. Already pre-computed, scale = 1.1801e+04
cal_2.scale_factor = 1.1801*10^4;
% % Test the force sensor
% force = zeros(1,200);
% %
% tic
% for i = 1:1:length(force)
%     force(i) = get_weight(cal_1, L1);
% end
% T = toc;
% t = linspace(1,floor(T),length(force));
% plot(t,force, 'LineWidth', 2), grid on

%% Start comunication with DYNAMIXEL motor

ID = 1;
port = 'COM9';
max_iter = 1000;
i = 0;
force_1 = 1;
force_2 = 1;
screw_pos = 0;
danger = 0;
pres_speed = 0;
lin_speed = 0;
T_pred = 0;
sigma_1 = 1000;
sigma_2 = 1000;
sigma_3 = 800;
h = 100;
delta_t = 0.095;
f = zeros(1,max_iter);
time = linspace(1, max_iter, max_iter);
F = zeros(1,max_iter);

figure
for i = 3: max_iter
    % Get the 2 force measurements
    [force_1, force_2] = get_force(cal_1,cal_2,L1,L2)

    % If not reached, compute force time evolution

    F(1,i-1) = -sigma_3*f(i-2)+h*tanh(sigma_1*max(abs(force_2),0)...
        -sigma_2*max(abs(force_1),0))
    f(i) = f(i-1) + .0005*F(i-1);
    plot(time(i), f(i), '.r' ,'LineWidth',10), grid on
    drawnow;
    hold on
       
end




