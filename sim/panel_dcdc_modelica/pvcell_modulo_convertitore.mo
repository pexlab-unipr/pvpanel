model pvcell_modulo_convertitore

  //importo pin + e - del modulo
  Modelica.Electrical.Analog.Interfaces.PositivePin p annotation(
    Placement(transformation(origin = {0, 40}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, 100}, extent = {{-16, -16}, {16, 16}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin n annotation(
    Placement(transformation(origin = {0, -20}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -100}, extent = {{-16, -16}, {16, 16}})));

  //variabili
  parameter Integer n_serie           = 10     "numero di celle in serie per ogni stringa";
  parameter Integer n_paralleli       = 1     "numero di stringhe in parallelo";
  parameter Integer n_celle_conveter  = 5     "numero di celle sotto convertitore";
  parameter Integer temp_test         = 25    "temperatura operativa della singola cella";
  parameter Integer irr_test          = 1000  "irraggiamento incidente sul modulo";
  
  // Matrix of PV cells, arranged as in the module (series -> rows, parallels -> columns)
  pvcell_singola_cella pv_celle[n_serie, n_paralleli] (each Temperatura = temp_test) "creo array e assegno temperatura a ciascuno";
 
  //importo la matrice per l'illuminazione delle singole celle
  Modelica.Blocks.Interfaces.RealVectorInput lights[n_serie, n_paralleli] annotation(
    Placement(transformation(origin = {-138, 0}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}})));

  //introduco i diodi di bypass e di stringa
  //Modelica.Electrical.Analog.Semiconductors.Diode diodi_bypass[num_bypass, n_paralleli]  "diodi di bypass";        
  Modelica.Electrical.Analog.Semiconductors.Diode diodi_stringa[n_paralleli]             "diodi di stringa";
  
  //importo il modello del convertitore, per ora non cambio il guadagno
  convertitore conv_dc_dc[num_conv, n_paralleli];
  
  
protected
  //calcolo il numero di convertitori per ogni stringa
  parameter Integer num_conv = div(n_serie, n_celle_conveter);
  
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
    
    //collego il diodo di stringa con il primo convertitore
    connect(diodi_stringa[ramo].p, conv_dc_dc[1, ramo].p_stringa);
    
    //connetto la prima cella della sotto-serie al convertitore
    connect(conv_dc_dc[1, ramo].p_celle, pv_celle[1, ramo].p);

    //collego tra di loro i convertitori nella stringa
    for k in 1:num_conv loop
      
      //collego le celle tra loro sotto al k-esimo convertitore
      for cell in 1:n_celle_conveter-1 loop
        connect(pv_celle[cell, ramo].n, pv_celle[cell+1, ramo].p);
      end for;

      //collego l'ultima cella della sotto-serie con il terminale n del k-esimo convertitore
      connect(pv_celle[n_celle_conveter, ramo].n, conv_dc_dc[k, ramo].n_celle);
      
      if(k == num_conv) then
        //collego terminale n dell'ultimo convertitore con quello del modulo
        connect(conv_dc_dc[num_conv, ramo].n_stringa, n); 
      else  
        connect(conv_dc_dc[k, ramo].n_stringa, conv_dc_dc[k+1, ramo].p_stringa);
      end if;  

    end for;
    
  end for;

annotation(
    uses(Modelica(version = "4.0.0")));
end pvcell_modulo_convertitore;
