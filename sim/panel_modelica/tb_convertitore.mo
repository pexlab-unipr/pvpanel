model tb_convertitore
  Pexlab.PVPanels.convertitore convertitore1(efficiency = 0.95, fixed_gain = false, I_out_max = 3, input_impedance = 3)  annotation(
    Placement(transformation(origin = {0, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation(
    Placement(transformation(origin = {-80, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Capacitor capacitor(v(start = 22, fixed = true), C(displayUnit = "nF") = 1e-9)  annotation(
    Placement(transformation(origin = {80, -30}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Basic.VariableResistor resistor1 annotation(
    Placement(transformation(origin = {80, 10}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  Modelica.Electrical.Analog.Sources.ConstantVoltage constantVoltage(V = 10) annotation(
    Placement(transformation(origin = {-80, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Blocks.Sources.Ramp ramp(height = 19, duration = 0.5, offset = 1)  annotation(
    Placement(transformation(origin = {-50, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Sum sum1(nin = 2)  annotation(
    Placement(transformation(origin = {30, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Routing.Multiplex mux(n = 2)  annotation(
    Placement(transformation(origin = {-10, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp1(duration = 0.5, height = -19, offset = 0, startTime = 0.5) annotation(
    Placement(transformation(origin = {-50, -80}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(ground.p, constantVoltage.n) annotation(
    Line(points = {{-80, -60}, {-80, 0}}, color = {0, 0, 255}));
  connect(capacitor.n, ground.p) annotation(
    Line(points = {{80, -40}, {80, -60}, {-80, -60}}, color = {0, 0, 255}));
  connect(resistor1.n, capacitor.p) annotation(
    Line(points = {{80, 0}, {80, -20}}, color = {0, 0, 255}));
  connect(constantVoltage.n, ground.p) annotation(
    Line(points = {{-80, 0}, {-80, -60}}, color = {0, 0, 255}));
  connect(constantVoltage.p, convertitore1.p1) annotation(
    Line(points = {{-80, 20}, {-10, 20}}, color = {0, 0, 255}));
  connect(constantVoltage.n, convertitore1.n1) annotation(
    Line(points = {{-80, 0}, {-10, 0}}, color = {0, 0, 255}));
  connect(convertitore1.p2, resistor1.p) annotation(
    Line(points = {{10, 20}, {80, 20}}, color = {0, 0, 255}));
  connect(convertitore1.n2, resistor1.n) annotation(
    Line(points = {{10, 0}, {80, 0}}, color = {0, 0, 255}));
  connect(sum1.y, resistor1.R) annotation(
    Line(points = {{42, -30}, {60, -30}, {60, 10}, {68, 10}}, color = {0, 0, 127}));
  connect(ramp.y, mux.u[1]) annotation(
    Line(points = {{-38, -30}, {-20, -30}}, color = {0, 0, 127}));
  connect(ramp1.y, mux.u[2]) annotation(
    Line(points = {{-38, -80}, {-20, -80}, {-20, -30}}, color = {0, 0, 127}));
  connect(mux.y, sum1.u) annotation(
    Line(points = {{2, -30}, {18, -30}}, color = {0, 0, 127}, thickness = 0.5));
  annotation(
    uses(Modelica(version = "4.0.0")),
  Diagram);
end tb_convertitore;
