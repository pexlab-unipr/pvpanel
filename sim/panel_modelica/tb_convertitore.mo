model tb_convertitore
  Pexlab.PVPanels.convertitore convertitore1(efficiency = 0.95, fixed_gain = true, I_out_max = 3)  annotation(
    Placement(transformation(origin = {0, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-80, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(v(start = 22, fixed = true), C(displayUnit = "nF") = 1e-9)  annotation(
    Placement(transformation(origin = {80, -30}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Basic.VariableResistor resistor1 annotation(
    Placement(transformation(origin = {80, 10}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V = 10) annotation(
    Placement(transformation(origin = {-80, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.Ramp ramp(height = -19, duration = 1, offset = 20)  annotation(
    Placement(transformation(origin = {0, -30}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(ground.p, constantVoltage.n) annotation(
    Line(points = {{-80, -60}, {-80, 0}}, color = {0, 0, 255}));
  connect(capacitor.n, ground.p) annotation(
    Line(points = {{80, -40}, {80, -60}, {-80, -60}}, color = {0, 0, 255}));
  connect(resistor1.n, capacitor.p) annotation(
    Line(points = {{80, 0}, {80, -20}}, color = {0, 0, 255}));
  connect(convertitore1.p_stringa, resistor1.p) annotation(
    Line(points = {{10, 13}, {20, 13}, {20, 20}, {80, 20}}, color = {0, 0, 255}));
  connect(convertitore1.n_stringa, resistor1.n) annotation(
    Line(points = {{10, 7}, {20, 7}, {20, 0}, {80, 0}}, color = {0, 0, 255}));
  connect(constantVoltage.p, convertitore1.p_celle) annotation(
    Line(points = {{-80, 20}, {-20, 20}, {-20, 14}, {-10, 14}}, color = {0, 0, 255}));
  connect(constantVoltage.n, ground.p) annotation(
    Line(points = {{-80, 0}, {-80, -60}}, color = {0, 0, 255}));
  connect(constantVoltage.n, convertitore1.n_celle) annotation(
    Line(points = {{-80, 0}, {-20, 0}, {-20, 8}, {-10, 8}}, color = {0, 0, 255}));
  connect(ramp.y, resistor1.R) annotation(
    Line(points = {{12, -30}, {40, -30}, {40, 10}, {68, 10}}, color = {0, 0, 127}));
  annotation(
    uses(Modelica(version = "4.0.0")),
  Diagram);
end tb_convertitore;
