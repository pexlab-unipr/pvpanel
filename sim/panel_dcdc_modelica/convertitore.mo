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
 

  Real Pin  "potenza in ingresso";
  Real Pout "potenza in uscita del convertitore massima";
  
equation
  //la somma delle correnti in ingresso e uscita deve essere 0
  p_celle.i + n_celle.i = 0;
  p_stringa.i + n_stringa.i = 0;
  
  //calcolo Pin
  Pin = p_celle.i * (p_celle.v - n_celle.v);
  
  //calcolo la Pout come Pin * efficienza
  Pout = Pin * efficienza;
  
  //calcolo Iout come Iin * G
  p_stringa.i = p_celle.i * guadagno;
  
  //ricavo Vout per mantenere la Pout in uscita
  p_stringa.v - n_stringa.v = Pout/p_stringa.i;
  

  annotation(
    uses(Modelica(version = "4.0.0")),
    Diagram);
end convertitore;
