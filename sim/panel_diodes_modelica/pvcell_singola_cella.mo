model pvcell_singola_cella
  Modelica.Blocks.Interfaces.RealInput Temperatura "temperatura della cella in °C" annotation(
    Placement(transformation(origin = {-340, 70}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 60}, extent = {{-20, -20}, {20, 20}})));
  Modelica.Blocks.Interfaces.RealInput Irraggiamento "Irraggiamento incidente sulla cella" annotation(
    Placement(transformation(origin = {-340, -30}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, -60}, extent = {{-20, -20}, {20, 20}})));
  Modelica.Electrical.Analog.Basic.Resistor R_serie(R = 4.2e-3, useHeatPort = false, T_ref = 298.15) annotation(
    Placement(transformation(origin = {4, 20}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Basic.Resistor R_shunt(R = 10.1, useHeatPort = false, T_ref = 298.15) annotation(
    Placement(transformation(origin = {-20, -10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Semiconductors.Diode diode(useTemperatureDependency = false, final useHeatPort = false, Ids = 3.15e-7, final T(final displayUnit = "K") = 297.15, Vt = 26e-3) annotation(
    Placement(transformation(origin = {-52, -10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Modelica.Electrical.Analog.Sources.SignalCurrent I_ph annotation(
    Placement(transformation(origin = {-80, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Math.UnitConversions.From_degC from_degC annotation(
    Placement(transformation(origin = {-290, 70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Add add(k1 = +1, k2 = -1) annotation(
    Placement(transformation(origin = {-250, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Product product1 annotation(
    Placement(transformation(origin = {-210, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant Kth(k = -0.01) annotation(
    Placement(transformation(origin = {-250, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Add add1 annotation(
    Placement(transformation(origin = {-170, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant Isc(k = 3.8) annotation(
    Placement(transformation(origin = {-210, -10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Product product11 annotation(
    Placement(transformation(origin = {-130, -10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant T0_K(k = 298.15) annotation(
    Placement(transformation(origin = {-290, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Division division annotation(
    Placement(transformation(origin = {-290, -50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant Radiation(k = 1000) annotation(
    Placement(transformation(origin = {-330, -70}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.PositivePin p annotation(
    Placement(transformation(origin = {40, 20}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, 60}, extent = {{-16, -16}, {16, 16}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin n annotation(
    Placement(transformation(origin = {40, -40}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, -60}, extent = {{-16, -16}, {16, 16}})));
equation
  connect(diode.p, R_serie.p) annotation(
    Line(points = {{-52, 0}, {-52, 20}, {-6, 20}}, color = {0, 0, 255}));
  connect(R_serie.p, R_shunt.p) annotation(
    Line(points = {{-6, 20}, {-20, 20}, {-20, 0}}, color = {0, 0, 255}));
  connect(Temperatura, from_degC.u) annotation(
    Line(points = {{-340, 70}, {-302, 70}}, color = {0, 0, 127}));
  connect(add.u1, from_degC.y) annotation(
    Line(points = {{-262, 56}, {-270, 56}, {-270, 70}, {-279, 70}}, color = {0, 0, 127}));
  connect(product1.u1, add.y) annotation(
    Line(points = {{-222, 36}, {-230, 36}, {-230, 50}, {-238, 50}}, color = {0, 0, 127}));
  connect(product1.u2, Kth.y) annotation(
    Line(points = {{-222, 24}, {-230, 24}, {-230, 10}, {-238, 10}}, color = {0, 0, 127}));
  connect(add1.u1, product1.y) annotation(
    Line(points = {{-182, 16}, {-190, 16}, {-190, 30}, {-198, 30}}, color = {0, 0, 127}));
  connect(add1.u2, Isc.y) annotation(
    Line(points = {{-182, 4}, {-190, 4}, {-190, -10}, {-198, -10}}, color = {0, 0, 127}));
  connect(product11.u1, add1.y) annotation(
    Line(points = {{-142, -4}, {-150, -4}, {-150, 10}, {-158, 10}}, color = {0, 0, 127}));
  connect(product11.y, I_ph.i) annotation(
    Line(points = {{-118, -10}, {-92, -10}}, color = {0, 0, 127}));
  connect(I_ph.n, R_serie.p) annotation(
    Line(points = {{-80, 0}, {-80, 20}, {-6, 20}}, color = {0, 0, 255}));
  connect(T0_K.y, add.u2) annotation(
    Line(points = {{-278, 30}, {-270, 30}, {-270, 44}, {-262, 44}}, color = {0, 0, 127}));
  connect(product11.u2, division.y) annotation(
    Line(points = {{-142, -16}, {-150, -16}, {-150, -50}, {-278, -50}}, color = {0, 0, 127}));
  connect(R_serie.n, p) annotation(
    Line(points = {{14, 20}, {40, 20}}, color = {0, 0, 255}));
  connect(I_ph.p, n) annotation(
    Line(points = {{-80, -20}, {-80, -40}, {40, -40}}, color = {0, 0, 255}));
  connect(diode.n, n) annotation(
    Line(points = {{-52, -20}, {-52, -40}, {40, -40}}, color = {0, 0, 255}));
  connect(R_shunt.n, n) annotation(
    Line(points = {{-20, -20}, {-20, -40}, {40, -40}}, color = {0, 0, 255}));
  connect(division.u1, Irraggiamento) annotation(
    Line(points = {{-302, -44}, {-308, -44}, {-308, -30}, {-340, -30}}, color = {0, 0, 127}));
  connect(Radiation.y, division.u2) annotation(
    Line(points = {{-318, -70}, {-308, -70}, {-308, -56}, {-302, -56}}, color = {0, 0, 127}));
  annotation(
    uses(Modelica(version = "4.0.0")),
    Diagram(coordinateSystem(extent = {{-360, 100}, {60, -80}})),
    version = "",
    Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}})));
end pvcell_singola_cella;
