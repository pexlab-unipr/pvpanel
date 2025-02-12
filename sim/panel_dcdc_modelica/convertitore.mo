model convertitore
  Modelica.Electrical.Analog.Interfaces.PositivePin p_celle annotation(
    Placement(transformation(origin = {-100, 30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin n_celle annotation(
    Placement(transformation(origin = {-100, -30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.PositivePin p_stringa annotation(
    Placement(transformation(origin = {100, 30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin n_stringa annotation(
    Placement(transformation(origin = {100, -30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, -30}, extent = {{-10, -10}, {10, 10}})));

  parameter Real guadagno   = 1   "guadagno di conversione";
  parameter Real efficienza = 1   "efficienza del convertitore";
  parameter Real input_impedance = 1 "input impedance";

  Real Pin  "potenza in ingresso";
  Real Pout "potenza in uscita del convertitore massima";
  
equation
  //la somma delle correnti in ingresso e uscita deve essere 0
  p_celle.i + n_celle.i = 0;
  p_stringa.i + n_stringa.i = 0;
  
  // Output voltage as a function of input, multiplied by gain
  p_stringa.v - n_stringa.v = guadagno * (p_celle.v - n_celle.v);
  
  //calcolo Pin
  Pin = p_celle.i * (p_celle.v - n_celle.v);
  
  //calcolo la Pout come Pin * efficienza
  Pout = Pin * efficienza;
  
  // Iout computation from power conservation (efficiency included)
  p_stringa.i * (p_stringa.v - n_stringa.v) = Pout;
  
  // Impose additional constraint of input impedance, to avoid undetermined states
  //p_celle.v - n_celle.v = input_impedance * p_celle.i;
  
  annotation(
    uses(Modelica(version = "4.0.0")),
    Diagram);
end convertitore;
