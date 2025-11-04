%% Cleaning
clear
clc
close all

%% PARAMETERS
LOAD_NAME = "USB0::0x2A8D::0x3802::MY61002160::0::INSTR";

%% Characterize
inst = visadev(LOAD_NAME);
name = writeread(inst, "*IDN?");
disp(name)

cmds = [
    "*RST";
    "*CLS";
    "SYST:BEEP:STAT ON";
    "SYST:BEEP";
    "FUNC CURR, (@1)";
    "TRAN:MODE LIST, (@1)";
    "LIST:CURR 0.5,1,2,3,4, (@1)";
    "LIST:DWEL 1,1,1,1,1, (@1)";
    "LIST:COUNT INF, (@1)";
    "LIST:STEP AUTO, (@1)";
    "CURR:MODE LIST, (@1)";
    "TRIG:SOUR BUS";
    "INIT:TRAN (@1)";
    "SENS:DLOG:FUNC:VOLT 1, (@1)";
    "SENS:DLOG:FUNC:CURR 1, (@1)";
    "SENS:DLOG:TIME 30";
    "SENS:DLOG:PER 0.2";
    "TRIG:DLOG:SOUR BUS";
    "INIT:DLOG ""Internal:/log1.dlog""";
    "INP ON, (@1)";
    "*TRG"
];
for ii = 1:length(cmds)
    writeline(inst, cmds(ii));
    fprintf("%s\n", cmds(ii))
end
tim_wait = timer(...
    'StartFcn', @(~,~)disp('Waiting...'), ...
    'TimerFcn', @(~,~)disp('...'), ...
    'StopFcn', @(~,~)disp('Finished!'), ...
    'ExecutionMode', 'fixedRate', ...
    'TasksToExecute', 35, ...
    'Period', 1);
start(tim_wait)
wait(tim_wait)
writeline(inst, "INP OFF, (@1)")
writeline(inst, "SYST:BEEP")

%%
data_str = writeread(inst, "FETC:DLOG? 150, (@1)");
data = str2num(data_str);
data = reshape(data(:), numel(data)/2, 2);
vs = data(:,1);
is = data(:,2);
par = polyfit(is, vs, 1);
par

%%
figure
hold on
plot(is, vs)
plot(is, polyval(par, is))
box on
grid on
