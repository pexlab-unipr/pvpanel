model matrix_output
  parameter Integer n_rows = 1;
  parameter Integer n_cols = 1;
  parameter Real values[n_rows, n_cols];
  Modelica.Blocks.Interfaces.RealVectorOutput y[n_rows, n_cols] annotation(
    Placement(transformation(extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {120, 0}, extent = {{-20, -20}, {20, 20}})));
equation
  y = values;
annotation(
    uses(Modelica(version = "4.0.0")),
  Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}})}));
end matrix_output;
