model tb_modulo_convertitore
  Modelica.Blocks.Math.Product potenza annotation(
    Placement(transformation(origin = {70, 40}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation(
    Placement(transformation(origin = {-30, 40}, extent = {{-10, 10}, {10, -10}}, rotation = -0)));
  Modelica.Electrical.Analog.Sensors.VoltageSensor voltageSensor annotation(
    Placement(transformation(origin = {32, 10}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-50, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sources.SignalVoltage signalVoltage annotation(
    Placement(transformation(origin = {-10, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.Ramp ramp(duration(displayUnit = "s") = 1, height = 1, offset = 0.01) annotation(
    Placement(transformation(origin = {50, -50}, extent = {{10, -10}, {-10, 10}})));
  Pexlab.PVPanels.matrix_output matrix_output1(n_cols = 1, n_rows = 2, values = [1000; fill(1000, 1, 1)]) annotation(
    Placement(transformation(origin = {-90, 10}, extent = {{-10, -10}, {10, 10}})));
  Pexlab.PVPanels.pvcell_modulo_convertitore pvcell_modulo_convertitore1(n_serie = 2, n_paralleli = 1, n_celle_converter = 1, I_in_max_converter = 10) annotation(
    Placement(transformation(origin = {-50, 10}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(voltageSensor.v, potenza.u2) annotation(
    Line(points = {{44, 10}, {46, 10}, {46, 34}, {58, 34}}, color = {0, 0, 127}));
  connect(currentSensor.i, potenza.u1) annotation(
    Line(points = {{-30, 52}, {48, 52}, {48, 46}, {58, 46}}, color = {0, 0, 127}));
  connect(voltageSensor.p, currentSensor.n) annotation(
    Line(points = {{32, 20}, {32, 40}, {-20, 40}}, color = {0, 0, 255}));
  connect(signalVoltage.v, ramp.y) annotation(
    Line(points = {{2, 10}, {10, 10}, {10, -50}, {39, -50}}, color = {0, 0, 127}));
  connect(signalVoltage.n, ground.p) annotation(
    Line(points = {{-10, 0}, {-10, -20}, {-50, -20}}, color = {0, 0, 255}));
  connect(voltageSensor.n, ground.p) annotation(
    Line(points = {{32, 0}, {32, -20}, {-50, -20}}, color = {0, 0, 255}));
  connect(pvcell_modulo_convertitore1.p, currentSensor.p) annotation(
    Line(points = {{-50, 20}, {-50, 40}, {-40, 40}}, color = {0, 0, 255}));
  connect(ground.p, pvcell_modulo_convertitore1.n) annotation(
    Line(points = {{-50, -20}, {-50, 0}}, color = {0, 0, 255}));
  connect(matrix_output1.y, pvcell_modulo_convertitore1.lights) annotation(
    Line(points = {{-78, 10}, {-62, 10}}, color = {0, 0, 127}, thickness = 0.5));
  connect(signalVoltage.p, currentSensor.n) annotation(
    Line(points = {{-10, 20}, {-10, 40}, {-20, 40}}, color = {0, 0, 255}));
  annotation(
    uses(Modelica(version = "4.0.0")),
    Diagram(coordinateSystem(extent = {{-100, 60}, {80, -60}})),
    version = "");
end tb_modulo_convertitore;
