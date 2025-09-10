% Simulate & test solar panel with load, possibly with converter in the
% middle (separate logging of input and output voltage & current).

%% Cleaning
clear
clc
close all

%% PARAMETERS
SUPPLY_NAME = "ASRL3::INSTR";
LOAD_NAME = "USB0::0x2A8D::0x3802::MY61002160::0::INSTR";
SUPPLY_PERIOD = 0.05;
LOAD_PERIOD = 0.2;
TIME_TOTAL = 30;
SUPPLY_IDX = 1;
LOAD_IDX = 2;
LOAD_RESISTANCE = 60;

%% Connect to instrumentation

% Create connection
inst_names = {SUPPLY_NAME, LOAD_NAME};
inst = cell(size(inst_names));
N_inst = numel(inst);
for ii = 1:N_inst
    inst{ii} = visadev(inst_names{ii});
end

% Display diagnostic information
plural = {'', 's'};
fprintf("Found %d device%c.\n", N_inst, plural{(N_inst > 1) + 1})
for ii = 1:N_inst
    name = writeread(inst{ii}, "*IDN?");
    name = regexp(name, "[^\r\n]*", 'match');
    fprintf("    #%d: %s\n", ii, name)
end

%%
Isc = 1.2;
Voc = 7;
a = 1.03*Isc;
b = -a*Voc;
c = b/Isc;
f = @(x) (a*x + b)./(x + c);
vs = linspace(0, Voc, 101);
is = f(vs);
pv_lut = [vs(:), is(:)];
N_supply = round(TIME_TOTAL/SUPPLY_PERIOD);
N_load = round(TIME_TOTAL/LOAD_PERIOD);
init0 = zeros(N_supply, 2);

%% Main test loop
tim_supply = timer(...
    'TimerFcn', {@supply_run, inst{SUPPLY_IDX}, pv_lut}, ...
    'StartFcn', {@supply_start, inst{SUPPLY_IDX}}, ...
    'StopFcn', {@supply_stop, inst{SUPPLY_IDX}}, ...
    'ErrorFcn', @error_handler, ...
    'Period', SUPPLY_PERIOD, ...
    'ExecutionMode', 'fixedRate', ...
    'TasksToExecute', N_supply, ...
    'UserData', {1, init0, init0});
tim_load = timer(...
    'TimerFcn', {@load_run, inst{LOAD_IDX}}, ...
    'StartFcn', {@load_start, inst{LOAD_IDX}, LOAD_RESISTANCE}, ...
    'StopFcn', {@load_stop, inst{LOAD_IDX}}, ...
    'ErrorFcn', @error_handler, ...
    'Period', LOAD_PERIOD, ...
    'ExecutionMode', 'fixedRate', ...
    'TasksToExecute', N_load, ...
    'UserData', {1, zeros(N_load, 2);});
tim_supply.start()
tim_load.start()
wait(tim_supply)

%% Result visualization
figure
hold on
plot(pv_lut(:,1), pv_lut(:,2))
plot(tim_supply.UserData{2}(:,1), tim_supply.UserData{2}(:,2))
% plot(pv_lut(:,1), pv_lut(:,1)/LOAD_RESISTANCE)
% plot(tim_supply.UserData{3}(:,1), tim_supply.UserData{3}(:,2))
plot(tim_load.UserData{2}(:,1), tim_load.UserData{2}(:,2))
xlabel('Voltage (V)')
ylabel('Current (A)')
box on
grid on

figure
hold on
plot(tim_supply.UserData{2}(:,1))
plot(tim_supply.UserData{2}(:,2))
plot(tim_supply.UserData{2}(:,1)./tim_supply.UserData{2}(:,2))
plot(tim_supply.UserData{3}(:,1))
plot(tim_supply.UserData{3}(:,2))
box on
grid on

%% Functions
function supply_run(obj, event, inst, lut)
    vo_str = writeread(inst, "V1O?");
    io_str = writeread(inst, "I1O?");
    vo = get_number(vo_str);
    io = get_number(io_str);
    G_est = io/vo;
    vo_max = fzero(@(v)interp1(lut(:,1), lut(:,2), v, "linear", "extrap") - G_est*v, 6);
    io_max = interp1(lut(:,1), lut(:,2), vo, "linear", "extrap");
    if io_max < 0
        io_max = 0;
    end
    if vo_max < 0
        vo_max = 0;
    end
    writeline(inst, "I1 " + num2str(io_max));
    writeline(inst, "V1 " + num2str(vo_max));
    ii = obj.UserData{1};
    obj.UserData{2}(ii,:) = [vo, io];
    obj.UserData{3}(ii,:) = [vo_max, io_max];
    obj.UserData{1} = ii + 1;
    fprintf("\b\b\b\b%4d", ii)
end

function supply_start(obj, event, inst)
    writeline(inst, "V1 0");
    writeline(inst, "I1 0");
    writeline(inst, "OP1 1");
    fprintf("xxxx")
end

function supply_stop(obj, event, inst)
    writeline(inst, "OP1 0");
    inst.delete()
    fprintf("\n")
end

function load_run(obj, event, inst)
    res = writeread(inst, "RESISTANCE?");
    res = get_number(res);
    writeline(inst, "RESISTANCE " + num2str(res/1.02));
    il_str = writeread(inst, "MEASURE:ARRAY:CURRENT?");
    vl_str = writeread(inst, "MEASURE:ARRAY:VOLTAGE?");
    il = get_number(il_str);
    vl = get_number(vl_str);
    ii = obj.UserData{1};
    obj.UserData{2}(ii,:) = [vl, il];
    obj.UserData{1} = ii + 1;
end
function load_start(obj, event, inst, resistance)
    writeline(inst, "MODE RESISTANCE");
    writeline(inst, "RESISTANCE " + num2str(resistance));
    writeline(inst, "INPUT ON");
    writeline(inst, "SENSE:SWEEP:POINTS 1");
end

function load_stop(obj, event, inst)
    writeline(inst, "INPUT OFF");
    inst.delete()
end

function error_handler(obj, event)
    obj
    event
    event.Data
end

function num = get_number(str)
    num = str2double(regexp(str, "[-|+]?[0-9]*[.]?[0-9]*[e|E]?[-|+]?[0-9]*", 'match'));
end




