block pvcell_mppt
  Modelica.Electrical.Analog.Sources.ConstantCurrent constantCurrent(I = 3.8)  annotation(
    Placement(visible = true, transformation(origin = {-60, 10}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Electrical.Analog.Semiconductors.Diode diode annotation(
    Placement(visible = true, transformation(origin = {-20, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation(
    Placement(visible = true, transformation(origin = {60, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(visible = true, transformation(origin = {-20, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation(
    Placement(visible = true, transformation(origin = {30, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput u annotation(
    Placement(visible = true, transformation(origin = {-120, 60}, extent = {{-20, -20}, {20, 20}}, rotation = 0), iconTransformation(origin = {-104, 60}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealOutput y annotation(
    Placement(visible = true, transformation(origin = {110, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {108, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(constantCurrent.n, diode.p) annotation(
    Line(points = {{-60, 20}, {-20, 20}}, color = {0, 0, 255}));
  connect(constantCurrent.p, diode.n) annotation(
    Line(points = {{-60, 0}, {-20, 0}}, color = {0, 0, 255}));
  connect(signalVoltage.n, diode.n) annotation(
    Line(points = {{60, 0}, {-20, 0}}, color = {0, 0, 255}));
  connect(ground.p, diode.n) annotation(
    Line(points = {{-20, -20}, {-20, 0}}, color = {0, 0, 255}));
  connect(diode.p, currentSensor.p) annotation(
    Line(points = {{-20, 20}, {20, 20}}, color = {0, 0, 255}));
  connect(currentSensor.n, signalVoltage.p) annotation(
    Line(points = {{40, 20}, {60, 20}}, color = {0, 0, 255}));
  connect(currentSensor.i, y) annotation(
    Line(points = {{30, 10}, {30, -20}, {110, -20}}, color = {0, 0, 127}));
  connect(u, signalVoltage.v) annotation(
    Line(points = {{-120, 60}, {90, 60}, {90, 10}, {72, 10}}, color = {0, 0, 127}));

annotation(
    uses(Modelica(version = "4.0.0")));
end pvcell_mppt;
