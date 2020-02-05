function screw_pos = get_screw_pos(pres_speed, time, prev_pos)

    lin_speed = ((double(typecast(uint32(pres_speed), 'int32'))*0.229)*0.105)*0.012;
    screw_pos = prev_pos + time*lin_speed;   

end