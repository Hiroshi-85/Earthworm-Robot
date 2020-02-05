function [LoadCell, Calib] = calibrate_LC(NumOfSection, INO)

counter = 0;
LoadCell = struct([]);
Calib = struct([]);
idx = 0;
for i = 2:NumOfSection+1
    s0 = 'D';
    s1 = int2str(i+counter);
    s2 = int2str(i+counter+1);
    x = strcat(s0,s1);
    y = strcat(s0,s2);
    counter = counter +1;
    idx = i-1;
    LoadCell(idx).idx = addon(INO, 'ExampleAddon/HX711' ,{x ,y})
    Calib(idx).idx = calibration(20, 20);  % 100
    Calib(idx).idx.tare_weight = tare(Calib(idx).idx, LoadCell(idx).idx);
    Calib(idx).idx.scale_factor = 1.1801*10^4;    
end

