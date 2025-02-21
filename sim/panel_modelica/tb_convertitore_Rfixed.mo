model tb_convertitore_Rfixed
  Pexlab.PVPanels.convertitore convertitore1(efficiency = 0.95, fixed_gain = true, I_out_max = 3)  annotation(
    Placement(transformation(origin = {0, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-80, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(v(start = 22, fixed = true), C(displayUnit = "nF") = 1e-9)  annotation(
    Placement(transformation(origin = {80, -30}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Basic.Resistor resistor(R = 10)  annotation(
    Placement(transformation(origin = {80, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Sources.RampVoltage rampVoltage(V = 49, duration = 0.5, offset = 1)  annotation(
    Placement(transformation(origin = {-80, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Sources.RampVoltage rampVoltage1(V = -49, duration = 0.5, offset = 0, startTime = 0.5) annotation(
    Placement(transformation(origin = {-80, -30}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
equation
  connect(capacitor.n, ground.p) annotation(
    Line(points = {{80, -40}, {80, -60}, {-80, -60}}, color = {0, 0, 255}));
  connect(rampVoltage.p, convertitore1.p_celle) annotation(
    Line(points = {{-80, 20}, {-19, 20}, {-19, 14}, {-10, 14}}, color = {0, 0, 255}));
  connect(convertitore1.p_stringa, resistor.p) annotation(
    Line(points = {{10, 14}, {20, 14}, {20, 20}, {80, 20}}, color = {0, 0, 255}));
  connect(convertitore1.n_stringa, resistor.n) annotation(
    Line(points = {{10, 8}, {20, 8}, {20, 0}, {80, 0}}, color = {0, 0, 255}));
  connect(resistor.n, capacitor.p) annotation(
    Line(points = {{80, 0}, {80, -20}}, color = {0, 0, 255}));
  connect(rampVoltage1.p, rampVoltage.n) annotation(
    Line(points = {{-80, -20}, {-80, 0}}, color = {0, 0, 255}));
  connect(rampVoltage1.n, ground.p) annotation(
    Line(points = {{-80, -40}, {-80, -60}}, color = {0, 0, 255}));
  connect(convertitore1.n_celle, ground.p) annotation(
    Line(points = {{-10, 8}, {-20, 8}, {-20, -60}, {-80, -60}}, color = {0, 0, 255}));
  annotation(
    uses(Modelica(version = "4.0.0")),
  Diagram);
end tb_convertitore_Rfixed;
