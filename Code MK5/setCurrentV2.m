function dxl_present_current = setCurrentV2(ID, goalCurrent,port, port_num)

lib_name = '';

if strcmp(computer, 'PCWIN')
  lib_name = 'dxl_x86_c';
elseif strcmp(computer, 'PCWIN64')
  lib_name = 'dxl_x64_c';
elseif strcmp(computer, 'GLNX86')
  lib_name = 'libdxl_x86_c';
elseif strcmp(computer, 'GLNXA64')
  lib_name = 'libdxl_x64_c';
elseif strcmp(computer, 'MACI64')
  lib_name = 'libdxl_mac_c';
end

% Load Libraries
if ~libisloaded(lib_name)
    [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
end

% Control table address
ADDR_PRO_TORQUE_ENABLE       = 64;         % Control table address is different in Dynamixel model
ADDR_PRO_GOAL_CURRENT        = 102;
ADDR_PRO_PRESENT_CURRENT     = 126;
ADDR_OPERATING_MODE          = 11;

% Protocol version
PROTOCOL_VERSION            = 2.0;          % See which protocol version is used in the Dynamixel

% Default setting
DXL_ID                      = ID;            % Dynamixel ID: 1
BAUDRATE                    = 1000000;
DEVICENAME                  = port;       % Check which port is being used on your controller
                                            % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'

TORQUE_ENABLE               = 1;            % Value for enabling the torque
TORQUE_DISABLE              = 0;            % Value for disabling the torque
CURRENT_CTR_MODE            = 0;

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed


dxl_goal_current = goalCurrent;

    % Write goal current
    write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PRO_GOAL_CURRENT, typecast(int16(dxl_goal_current), 'uint16'));
    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
    if dxl_comm_result ~= COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
    elseif dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
    end
    
        dxl_present_current = 0;
        % Read present current
        dxl_present_current = read2ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PRO_PRESENT_CURRENT);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        elseif dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
        end

         fprintf('[ID:%03d] GoalCurrent:%03d  PresCurrent:%03d\n', DXL_ID, dxl_goal_current, typecast(uint16(dxl_present_current), 'int16'));

end


