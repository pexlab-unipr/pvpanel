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
    "DISP:TEXT ""Ciao Alex!""";
    "DISP:TEXT:CLE";
    "FUNC RES, (@1)";
    "RES 31, (@1)";
    "TRAN:MODE LIST, (@1)";
    "LIST:RES " + sprintf("%d,", logspace(log10(20), log10(1000), 100)) + " (@1)";
    "LIST:DWEL 0.5, (@1)";
    "LIST:COUNT 1, (@1)";
    "LIST:STEP AUTO, (@1)";
    "RES:MODE LIST, (@1)";
    "INIT:TRAN (@1)";
    "SENS:DLOG:FUNC:VOLT 1, (@1)";
    "SENS:DLOG:FUNC:CURR 1, (@1)";
    "SENS:DLOG:TIME 50";
    "SENS:DLOG:PER 0.5";
    "TRIG:DLOG:SOUR BUS";
    "INIT:DLOG ""Internal:/log1.dlog""";
    "INP ON, (@1)";
    "*TRG"
];
for ii = 1:length(cmds)
    fprintf("%s\n", cmds(ii));
    writeline(inst, cmds(ii));
end
tim_wait = timer(...
    'StartFcn', @(~,~)disp('Waiting...'), ...
    'TimerFcn', @(~,~)disp('...'), ...
    'StopFcn', @(~,~)disp('Finished!'), ...
    'ExecutionMode', 'fixedRate', ...
    'TasksToExecute', 55, ...
    'Period', 1);
start(tim_wait)
wait(tim_wait)
writeline(inst, "INP OFF, (@1)")
writeline(inst, "SYST:BEEP")

%%
data_str = writeread(inst, "FETC:DLOG? 100, (@1)");
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
%
figure
hold on
plot(vs, is, '.-')
xlabel('Voltage (V)')
ylabel('Current (A)')
box on
grid on
%
figure
hold on
plot(vs, vs.*is, '.')
box on
grid on
