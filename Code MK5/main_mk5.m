clc
clear all
close all
%% Global parameters
numSection = 4;
numAct = numSection - 1;
nf = 2;
nb = 2;
sigma_1 = 10000;   %
sigma_2 = 10000;   %
sigma_3 = 6000;   %
hf = 2000;     % 2000
kp = 600;
max_iter = 200;

% Other parameters

ID = linspace(1,numAct, numAct);
port = 'COM9';
screw_pos = zeros(1, numAct);
pres_speed = zeros(1, numAct);
lin_speed = zeros(1, numAct);
T_pred = 0;
delta_t = 0.0001;
f = zeros(numAct,max_iter);
time = zeros(numAct,max_iter);
F =  zeros(numAct,max_iter);
force_sens = zeros(numSection, max_iter);
position = zeros(numAct,max_iter);
speed = zeros(numAct,max_iter);
force_repulsive = zeros(1,numSection);
force_propulsive = zeros(1, numSection);
delta = zeros(numAct, max_iter);

initial_pos = zeros(numAct,1);
current_position = zeros(numAct, max_iter);
delta_pos = zeros(numAct, max_iter);

[isBack, isFront] = indexing(numSection, numAct, nf, nb);
%% Initialize connection with arduino and calibrate loadcell

a1 = arduino('COM10', 'Uno')
[L, cal] = calibrate_LC(numSection,a1)

%% Test the force sensor. Run multiple time for testing

test = zeros(1,length(numSection));
for h = 1:numSection
    test(h) = get_force(cal(h).idx, L(h).idx);
    fprintf('Force %d: %f\n', h, test(h));
end

%% Start comunication with DYNAMIXEL motor
port_num = initialization(port);

for j = 1:numAct
    setOpCon(ID(j), port_num)
    initial_pos(j) = get_position(ID(j), port_num);
    time(j,1) = double(get_time(ID(j), port_num))/1000;
end
%% Main cycle
pres_curr = set_current(ID(3), -100, port_num); 
tic

for i = 2: max_iter

    % Get the 3 force measurements
    for z = 1:numSection
        force_sens(z,i) = get_force(cal(z).idx, L(z).idx);
        if force_sens(z,i) > 0
            force_sens(z,i) = 0;
        end
    end
   
   for k = 1:numAct
    pres_speed(k) = get_speed(ID(k), port_num);
    
    % If not reached, compute force time evolution 
    S1 = sum(abs(force_sens(1:isBack(k),i)));   
    S2 = sum(abs(force_sens((k+1):isFront(k),i)));  
    F(k,i-1) = -sigma_3*f(k,i-1)+hf*tanh(sigma_1*S2...
        -sigma_2*S1);
    f(k,i) = f(k,i-1) + delta_t*F(k, i-1);
    % Get the position from the encoders
    
    current_position(k,i) = get_position(ID(k), port_num);
    delta_pos(k,i) = initial_pos(k) - current_position(k,i);
    
    %%%%%PROTECTION%%%%%%%%%%%
    if ((delta_pos(k,i) < -700)&& f(k,i) > 0) || ((delta_pos(k,i) > 700)&& f(k,i) < 0 )   
        pres_curr = set_current(ID(k), 0, port_num); % 0 instead of -kp*f(j,i). Give repulsive force in 
    else
        pres_curr = set_current(ID(k), kp*f(k,i), port_num);   
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Evaluate the position based on the current speed
    speed(k,i) = ((double(typecast(uint32(pres_speed(k)), 'int32'))*0.229)*0.105)*0.012;  % Conversion from angular to linear speed
   end
end

T_stop = toc;

% Disconnect the motors
for r = 1:numAct
    delOpCon(ID(r), port_num)
end

flag = termination(port_num)




%% Plot measured ground force
time_plot = linspace(1, T_stop, max_iter);

figure
subplot(3, 1, 1)
plot(time_plot(1:397) ,force_sens(1,1:397)/1000, 'r', 'LineWidth', 2),...
    grid on,  xlabel('Time [s]'), ylabel('Ground reaction force (N)')
hold on
plot(time_plot(1:397)  ,force_sens(2,1:397)/1000, 'b', 'LineWidth', 2)   
hold on
plot(time_plot(1:397) ,force_sens(3,1:397)/1000, 'c', 'LineWidth', 2)
hold on
plot(time_plot(1:397) ,force_sens(4,1:397)/1000, 'g', 'LineWidth', 2)
hold on
legend('force 1', 'force 2', 'force 3', 'force 4')

% Plot the actuation force
subplot(3,1,2)
plot(time_plot(1:397),f(1,1:397), 'b','LineWidth', 2),...
    grid on,  xlabel('Time [s]'), ylabel('Actuation force (N)')
hold on
plot(time_plot(1:397),f(2,1:397), '--c','LineWidth', 2), grid on
hold on
plot(time_plot(1:397),f(3,1:397), 'r','LineWidth', 2), grid on
legend('actuation force 1', 'actuation force 2', 'actuation force 3' )

% Plot the section positions
subplot(3,1,3)
plot(time_plot(1:397), delta_pos(1,1:397)/100000, 'r', 'LineWidth', 2), grid on, ...
     xlabel('Time [s]'), ylabel('Delta displacement [m]')
hold on
% plot(time_plot, speed(1,:), 'b', 'LineWidth', 2), grid on
plot(time_plot(1:397), delta_pos(2,1:397)/100000, 'g', 'LineWidth', 2), grid on
hold on
plot(time_plot(1:397), delta_pos(3,1:397)/100000, 'b', 'LineWidth', 2), grid on
% plot(time_plot, speed(2,:), '--c', 'LineWidth', 2), grid on
legend('Section elongation 1','Section elongation 2', 'section elongation 3')


