model tb_cella
  Pexlab.PVPanels.pvcell_singola_cella pvcell_singola_cella1 annotation(
    Placement(transformation(origin = {-50, 10}, extent = {{-10, -10}, {10, 10}})));
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
  Modelica.Blocks.Sources.Ramp ramp(duration(displayUnit = "s") = 1, final height = 1) annotation(
    Placement(transformation(origin = {70, -50}, extent = {{10, -10}, {-10, 10}})));
  Modelica.Blocks.Sources.Constant temp(k = 25)  annotation(
    Placement(transformation(origin = {-90, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant irr(k = 1000)  annotation(
    Placement(transformation(origin = {-90, -10}, extent = {{-10, -10}, {10, 10}})));
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
  connect(pvcell_singola_cella1.p, currentSensor.p) annotation(
    Line(points = {{-40, 16}, {-20, 16}, {-20, 40}}, color = {0, 0, 255}));
  connect(pvcell_singola_cella1.n, ground.p) annotation(
    Line(points = {{-40, 4}, {-30, 4}, {-30, -20}}, color = {0, 0, 255}));
  connect(temp.y, pvcell_singola_cella1.Temperatura) annotation(
    Line(points = {{-78, 30}, {-62, 30}, {-62, 16}}, color = {0, 0, 127}));
  connect(irr.y, pvcell_singola_cella1.Irraggiamento) annotation(
    Line(points = {{-78, -10}, {-62, -10}, {-62, 4}}, color = {0, 0, 127}));

annotation(
    uses(Modelica(version = "4.0.0")));
end tb_cella;
