model tb_PvcellExp
  Pexlab.PVPanels.PvcellExp cell0;
  Modelica.Blocks.Math.Product potenza annotation(
    Placement(transformation(origin = {90, 40}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation(
    Placement(transformation(origin = {-10, 40}, extent = {{-10, 10}, {10, -10}})));
  Modelica.Electrical.Analog.Sensors.VoltageSensor voltageSensor annotation(
    Placement(transformation(origin = {52, 10}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-30, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation(
    Placement(transformation(origin = {10, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.Ramp ramp(duration(displayUnit = "s") = 1, final height = 48) annotation(
    Placement(transformation(origin = {70, -50}, extent = {{10, -10}, {-10, 10}})));
initial algorithm
  cell0.a := 1.20000000e+01;
  cell0.b := -2.78005780e-02;
  cell0.c := -6.04310276e-10;
  cell0.d := 4.91540716e-01;
equation
  connect(voltageSensor.v, potenza.u2) annotation(
    Line(points = {{63, 10}, {65, 10}, {65, 34}, {77, 34}}, color = {0, 0, 127}));
  connect(currentSensor.i, potenza.u1) annotation(
    Line(points = {{-10, 51}, {68, 51}, {68, 45}, {78, 45}}, color = {0, 0, 127}));
  connect(voltageSensor.p, currentSensor.n) annotation(
    Line(points = {{52, 20}, {52, 40}, {0, 40}}, color = {0, 0, 255}));
  connect(signalVoltage.p, currentSensor.n) annotation(
    Line(points = {{10, 20}, {10, 40}, {0, 40}}, color = {0, 0, 255}));
  connect(signalVoltage.v, ramp.y) annotation(
    Line(points = {{22, 10}, {30, 10}, {30, -50}, {59, -50}}, color = {0, 0, 127}));
  connect(signalVoltage.n, ground.p) annotation(
    Line(points = {{10, 0}, {10, -20}, {-30, -20}}, color = {0, 0, 255}));
  connect(voltageSensor.n, ground.p) annotation(
    Line(points = {{52, 0}, {52, -20}, {-30, -20}}, color = {0, 0, 255}));
  connect(cell0.p, currentSensor.p) annotation(
    Line(points = {{-40, 16}, {-20, 16}, {-20, 40}}, color = {0, 0, 255}));
  connect(cell0.n, ground.p) annotation(
    Line(points = {{-40, 4}, {-30, 4}, {-30, -20}}, color = {0, 0, 255}));
end tb_PvcellExp;
