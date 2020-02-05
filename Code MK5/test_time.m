clc
clear all
close all
%%
port = 'COM9';
port_num = initialization(port);

setOpCon(1, port_num)
time = zeros(1,2000);
delta = zeros(1,2000);
time(2) = double(get_time(1,port_num))/1000;
for i = 3:2000
    time(i) = double(get_time(1,port_num))/1000;
    delta(i) = time(i)-time(i-1);
    if abs(delta(i)) > 10
        delta(i) = 32.767 - abs(delta(i)) + time(i);
    end
end

%%

delOpCon(1, port_num);
flag = termination(port_num)
