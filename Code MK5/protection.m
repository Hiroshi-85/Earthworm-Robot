function exit_flag = protection(screw, force, pres_speed, ID, port_num)
%
if screw < -0.02 %&&  pres_speed <= 0     %&& force < 0
    pres_curr = set_current(ID, +100, port_num);
    exit_flag = 1;
elseif screw > 0.02 %&& pres_speed >= 0 %&& force > 0
    pres_curr = set_current(ID, -100, port_num);
    exit_flag = 2;
else 
    exit_flag = 0;
end