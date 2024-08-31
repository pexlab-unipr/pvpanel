model pvcell_bench
  pvcell_mppt pvcell_mppt1 annotation(
    Placement(visible = true, transformation(origin = {-18, -18}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.Ramp ramp(duration(displayUnit = "ms") = 0.1, height = 0.61)  annotation(
    Placement(visible = true, transformation(origin = {-68, 10}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Product product annotation(
    Placement(visible = true, transformation(origin = {30, 12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(ramp.y, pvcell_mppt1.u) annotation(
    Line(points = {{-57, 10}, {-39, 10}, {-39, -12}, {-28, -12}}, color = {0, 0, 127}));
  connect(pvcell_mppt1.y, product.u2) annotation(
    Line(points = {{-7, -20}, {9.5, -20}, {9.5, 6}, {18, 6}}, color = {0, 0, 127}));
  connect(product.u1, ramp.y) annotation(
    Line(points = {{18, 18}, {-17.5, 18}, {-17.5, 10}, {-57, 10}}, color = {0, 0, 127}));

annotation(
    uses(Modelica(version = "4.0.0")));
end pvcell_bench;
