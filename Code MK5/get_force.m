function F1 = get_force(cal_1, L1)
    F1 = get_weight(cal_1, L1);
    if abs(F1) < 10
        F1 = 0;
    end
end