% Simulate & test solar panel with load, possibly with converter in the
% middle (separate logging of input and output voltage & current).

%% Cleaning
clear
clc
close all

%% PARAMETERS
SUPPLY_NAME = "ASRL3::INSTR";
LOAD_NAME = "USB0::0x2A8D::0x3802::MY61002160::0::INSTR";
SUPPLY_PERIOD = 0.1;
LOAD_PERIOD = 2;
TIME_TOTAL = 60;
SUPPLY_IDX = 1;
LOAD_IDX = 2;
LOAD_RESISTANCE = 100;

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
% figure
% plot(vs, is)
pv_lut = [vs(:), is(:)];
N_supply = round(TIME_TOTAL/SUPPLY_PERIOD);
N_load = round(TIME_TOTAL/LOAD_PERIOD);
supply_out = zeros(N_supply, 2);

%% Main test loop
tim_supply = timer(...
    'TimerFcn', {@supply_run, inst{SUPPLY_IDX}, pv_lut}, ...
    'StartFcn', {@supply_start, inst{SUPPLY_IDX}}, ...
    'StopFcn', {@supply_stop, inst{SUPPLY_IDX}}, ...
    'ErrorFcn', @error_handler, ...
    'Period', SUPPLY_PERIOD, ...
    'ExecutionMode', 'fixedRate', ...
    'TasksToExecute', N_supply, ...
    'UserData', {1, supply_out});
tim_load = timer(...
    'TimerFcn', {@load_run, inst{LOAD_IDX}}, ...
    'StartFcn', {@load_start, inst{LOAD_IDX}, LOAD_RESISTANCE}, ...
    'StopFcn', {@load_stop, inst{LOAD_IDX}}, ...
    'ErrorFcn', @error_handler, ...
    'Period', LOAD_PERIOD, ...
    'ExecutionMode', 'fixedRate', ...
    'TasksToExecute', N_load);
tim_supply.start()
tim_load.start()
wait(tim_supply)

%% Result visualization
figure
hold on
plot(pv_lut(:,1), pv_lut(:,2))
plot(tim_supply.UserData{2}(:,1), tim_supply.UserData{2}(:,2))
plot(pv_lut(:,1), pv_lut(:,1)/LOAD_RESISTANCE)
xlabel('Voltage (V)')
ylabel('Current (A)')
box on
grid on

%% Functions
function supply_run(obj, event, inst, lut)
    vo_str = writeread(inst, "V1O?");
    vo = str2double(regexp(vo_str, "[-|+]?[0-9]*[.]?[0-9]*[e|E]?[-|+]?[0-9]*", 'match'));
    io_str = writeread(inst, "I1O?");
    io = str2double(regexp(io_str, "[-|+]?[0-9]*[.]?[0-9]*[e|E]?[-|+]?[0-9]*", 'match'));
    io_set = interp1(lut(:,1), lut(:,2), vo, "linear", "extrap");
    io_pv = io_set;
    io_set = io_set; % - 0.1; % for convergence
    if io_set < 0
        io_set = 0;
    end
    cmd = "I1 " + num2str(io_set);
    writeline(inst, cmd);
    cmd = "V1 " + num2str(vo);
    writeline(inst, cmd);
    ii = obj.UserData{1};
    obj.UserData{2}(ii,:) = [vo, io];
    obj.UserData{1} = ii + 1;
    % fprintf("%f   %f   %f   %f\n", vo, io, io_pv, io_set)
end

function supply_start(obj, event, inst)
    writeline(inst, "V1 7");
    writeline(inst, "I1 0");
    writeline(inst, "OP1 1");
end

function supply_stop(obj, event, inst)
    writeline(inst, "OP1 0");
    inst.delete()
end

function load_run(obj, event, inst)
    res = writeread(inst, "RESISTANCE?");
    res = str2double(regexp(res, "[-|+]?[0-9]*[.]?[0-9]*[e|E]?[-|+]?[0-9]*", 'match'));
    writeline(inst, "RESISTANCE " + num2str(res/1.05));
end
function load_start(obj, event, inst, resistance)
    writeline(inst, "MODE RESISTANCE");
    writeline(inst, "RESISTANCE " + num2str(resistance));
    writeline(inst, "INPUT ON");
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





