model pvcell_mppt_bench
  pvcell_mppt pvcell_mppt1 annotation(
    Placement(visible = true, transformation(origin = {-18, -18}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Product product annotation(
    Placement(visible = true, transformation(origin = {30, 12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Continuous.PI pi(T = 1e-3, initType = Modelica.Blocks.Types.Init.InitialOutput, k = 1e4, y_start = 0.1)  annotation(
    Placement(visible = true, transformation(origin = {-80, -14}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Product product1 annotation(
    Placement(visible = true, transformation(origin = {-156, -16}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Continuous.Derivative derivative(T = 0.1, k = 10)  annotation(
    Placement(visible = true, transformation(origin = {80, 12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Continuous.Derivative derivative1 annotation(
    Placement(visible = true, transformation(origin = {-230, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Sign sign1 annotation(
    Placement(visible = true, transformation(origin = {-188, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Noise.NormalNoise normalNoise(samplePeriod = 1e-3, sigma = 0.01)  annotation(
    Placement(visible = true, transformation(origin = {12, 52}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Add add annotation(
    Placement(visible = true, transformation(origin = {56, 46}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Gain gain(k = -1)  annotation(
    Placement(visible = true, transformation(origin = {-122, -16}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(pvcell_mppt1.y, product.u2) annotation(
    Line(points = {{-7, -20}, {9.5, -20}, {9.5, 6}, {18, 6}}, color = {0, 0, 127}));
  connect(pi.y, pvcell_mppt1.u) annotation(
    Line(points = {{-68, -14}, {-44, -14}, {-44, -12}, {-28, -12}}, color = {0, 0, 127}));
  connect(product.u1, pi.y) annotation(
    Line(points = {{18, 18}, {-58, 18}, {-58, -14}, {-68, -14}}, color = {0, 0, 127}));
  connect(derivative.y, product1.u2) annotation(
    Line(points = {{92, 12}, {110, 12}, {110, -40}, {-168, -40}, {-168, -22}}, color = {0, 0, 127}));
  connect(pi.y, derivative1.u) annotation(
    Line(points = {{-68, -14}, {-64, -14}, {-64, 28}, {-250, 28}, {-250, -10}, {-242, -10}}, color = {0, 0, 127}));
  connect(derivative1.y, sign1.u) annotation(
    Line(points = {{-218, -10}, {-200, -10}}, color = {0, 0, 127}));
  connect(sign1.y, product1.u1) annotation(
    Line(points = {{-177, -10}, {-168, -10}}, color = {0, 0, 127}));
  connect(product.y, add.u2) annotation(
    Line(points = {{42, 12}, {44, 12}, {44, 40}}, color = {0, 0, 127}));
  connect(add.y, derivative.u) annotation(
    Line(points = {{68, 46}, {68, 12}}, color = {0, 0, 127}));
  connect(normalNoise.y, add.u1) annotation(
    Line(points = {{24, 52}, {44, 52}}, color = {0, 0, 127}));
  connect(product1.y, gain.u) annotation(
    Line(points = {{-144, -16}, {-134, -16}}, color = {0, 0, 127}));
  connect(gain.y, pi.u) annotation(
    Line(points = {{-111, -16}, {-98.5, -16}, {-98.5, -14}, {-92, -14}}, color = {0, 0, 127}));
  annotation(
    uses(Modelica(version = "4.0.0")));
end pvcell_mppt_bench;
