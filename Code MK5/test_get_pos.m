clc
clear all
close all

%% 
port = 'COM9';
port_num = initialization(port);
setOpCon(1, port_num);
pos = zeros(1,100000);
pos(1) = get_position(1, port_num);
i = 2;
%%
while 1
    set_current(4, +2, port_num);
    pos(i) = get_position(4,port_num);
    i = i+1;
end

%%

pos(4) = get_position(1, port_num);

%%

delOpCon(1, port_num)
flag = termination(port_num)
