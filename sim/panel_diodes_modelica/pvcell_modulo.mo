model pvcell_modulo

  //importo pin + e - del modulo
  Modelica.Electrical.Analog.Interfaces.PositivePin p annotation(
    Placement(transformation(origin = {0, 40}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, 100}, extent = {{-16, -16}, {16, 16}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin n annotation(
    Placement(transformation(origin = {0, -20}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -100}, extent = {{-16, -16}, {16, 16}})));

  //variabili
  parameter Integer n_serie         = 6     "numero di celle in serie per ogni stringa";
  parameter Integer n_paralleli     = 2     "numero di stringhe in parallelo";
  parameter Integer n_celle_bypass  = 3     "numero di celle sotto diodo di bypass";
  parameter Integer temp_test       = 25    "temperatura operativa della singola cella";
  parameter Integer irr_test        = 1000  "irraggiamento incidente sul modulo";
  
  // Matrix of PV cells, arranged as in the module (series -> rows, parallels -> columns)
  pvcell_singola_cella pv_celle[n_serie, n_paralleli] (each Temperatura = temp_test) "creo array e assegno temperatura a ciascuno";
 
  //introduco i diodi di bypass e di stringa
  Modelica.Electrical.Analog.Semiconductors.Diode diodi_bypass[num_bypass, n_paralleli]  "diodi di bypass";        
  Modelica.Electrical.Analog.Semiconductors.Diode diodi_stringa[n_paralleli]             "diodi di stringa";
  Modelica.Blocks.Interfaces.RealVectorInput lights[n_serie, n_paralleli] annotation(
    Placement(transformation(origin = {-138, 0}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}})));

protected
  //calcolo il numero di diodi di bypass per ogni stringa
  parameter Integer num_bypass = div(n_serie, n_celle_bypass);
  
  //calcolo il numero totale di celle nel pannello
  parameter Integer n_tot_celle = n_serie * n_paralleli;
 
equation

  //ciclo per fornire l'irraggiamento alle celle del modulo
  for i in 1:n_serie loop
    for j in 1:n_paralleli loop
      connect(pv_celle[i,j].Irraggiamento, lights[i,j]);
    end for;
  end for;

  
  //ciclo per ogni ramo
  for ramo in 1:n_paralleli loop
    //collego l'anodo del diodo di stringa con il terminale + del modulo
    connect(p, diodi_stringa[ramo].n);
    
    //collego il diodo di stringa con la prima cella
    connect(diodi_stringa[ramo].p, pv_celle[1, ramo].p);
    
    //ciclo serie
    for serie in 1:n_serie-1 loop
      //collego la cella con la successiva
      connect(pv_celle[serie, ramo].n, pv_celle[serie+1, ramo].p);
 
    end for;
    
    //ciclo per collegare diodi di bypass
    for bp_diode in 1:num_bypass loop
      connect(pv_celle[(bp_diode-1) * n_celle_bypass + 1, ramo].p, diodi_bypass[bp_diode, ramo].n);
      connect(pv_celle[bp_diode * n_celle_bypass - 1, ramo].n, diodi_bypass[bp_diode, ramo].p);
    end for;
  
    //collego il terminale - della stringa con quello del modulo
    connect(pv_celle[n_serie, ramo].n, n); 
  end for;

annotation(
    uses(Modelica(version = "4.0.0")));
end pvcell_modulo;
