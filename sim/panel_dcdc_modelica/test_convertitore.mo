model test_convertitore
  convertitore convertitore1(guadagno = 1.2, efficienza = 0.95)  annotation(
    Placement(transformation(origin = {-10, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Sources.CosineVoltage cosineVoltage(V = 12, f = 10)  annotation(
    Placement(transformation(origin = {-60, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-60, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Resistor resistor(R = 1000)  annotation(
    Placement(transformation(origin = {40, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(v(start = 22), C(displayUnit = "nF") = 1e-9)  annotation(
    Placement(transformation(origin = {40, -30}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
equation
  connect(ground.p, cosineVoltage.n) annotation(
    Line(points = {{-60, -60}, {-60, 0}}, color = {0, 0, 255}));
  connect(cosineVoltage.p, convertitore1.p_celle) annotation(
    Line(points = {{-60, 20}, {-40, 20}, {-40, 14}, {-20, 14}}, color = {0, 0, 255}));
  connect(cosineVoltage.n, convertitore1.n_celle) annotation(
    Line(points = {{-60, 0}, {-40, 0}, {-40, 8}, {-20, 8}}, color = {0, 0, 255}));
  connect(resistor.p, convertitore1.p_stringa) annotation(
    Line(points = {{40, 20}, {20, 20}, {20, 14}, {0, 14}}, color = {0, 0, 255}));
  connect(resistor.n, convertitore1.n_stringa) annotation(
    Line(points = {{40, 0}, {20, 0}, {20, 8}, {0, 8}}, color = {0, 0, 255}));
  connect(resistor.n, capacitor.p) annotation(
    Line(points = {{40, 0}, {40, -20}}, color = {0, 0, 255}));
  connect(capacitor.n, ground.p) annotation(
    Line(points = {{40, -40}, {40, -60}, {-60, -60}}, color = {0, 0, 255}));
  annotation(
    uses(Modelica(version = "4.0.0")),
  Diagram);
end test_convertitore;
