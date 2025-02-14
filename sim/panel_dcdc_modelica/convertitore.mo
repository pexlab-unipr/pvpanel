model convertitore
  Modelica.Electrical.Analog.Interfaces.PositivePin p_celle annotation(
    Placement(transformation(origin = {-100, 30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin n_celle annotation(
    Placement(transformation(origin = {-100, -30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, -30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.PositivePin p_stringa annotation(
    Placement(transformation(origin = {100, 30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin n_stringa annotation(
    Placement(transformation(origin = {100, -30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, -30}, extent = {{-10, -10}, {10, 10}})));

  // gain to be determined by power conservation
  Real guadagno "guadagno di conversione";
  parameter Real efficienza = 1   "efficienza del convertitore";
  parameter Real input_impedance = 0.1 "input impedance";

  Real Pin  "potenza in ingresso";
  Real Pout "potenza in uscita del convertitore massima";
  Real v_in "input voltage";
  Real v_out "output voltage";
equation
  
  // Easy-to-see voltage quantities
  v_in = p_celle.v - n_celle.v;
  v_out = p_stringa.v - n_stringa.v;
  
  // KCL at input and output
  p_celle.i + n_celle.i = 0;
  p_stringa.i + n_stringa.i = 0;
  
  // Output voltage as a function of input, multiplied by gain
  v_out = guadagno * v_in;
  
  //calcolo Pin
  Pin = p_celle.i * v_in;
  
  //calcolo la Pout come Pin * efficienza
  Pout = -Pin * efficienza;
  
  // Iout computation from power conservation (efficiency included)
  p_stringa.i * v_out = Pout;
  
  // Impose additional constraint of input impedance, to avoid undetermined states
  v_in = input_impedance * p_celle.i;
  
  annotation(
    uses(Modelica(version = "4.0.0")),
    Diagram);
end convertitore;
