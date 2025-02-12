model pvcell_modulo_convertitore

  //importo pin + e - del modulo
  Modelica.Electrical.Analog.Interfaces.PositivePin p annotation(
    Placement(transformation(origin = {0, 40}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, 100}, extent = {{-16, -16}, {16, 16}})));
  Modelica.Electrical.Analog.Interfaces.NegativePin n annotation(
    Placement(transformation(origin = {0, -20}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -100}, extent = {{-16, -16}, {16, 16}})));

  //variabili
  parameter Integer n_serie           = 10    "numero di celle in serie per ogni stringa";
  parameter Integer n_paralleli       = 1     "numero di stringhe in parallelo";
  parameter Integer n_celle_converter = 5     "numero di celle sotto convertitore";
  parameter Integer temp_test         = 25    "temperatura operativa della singola cella";
  parameter Integer irr_test          = 1000  "irraggiamento incidente sul modulo";
  
  // Matrix of PV cells, arranged as in the module (series -> rows, parallels -> columns)
  pvcell_singola_cella pv_celle[n_serie, n_paralleli] (each Temperatura = temp_test) "creo array e assegno temperatura a ciascuno";
 
  //importo la matrice per l'illuminazione delle singole celle
  Modelica.Blocks.Interfaces.RealVectorInput lights[n_serie, n_paralleli] annotation(
    Placement(transformation(origin = {-138, 0}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}})));

  //importo il modello del convertitore, per ora non cambio il guadagno
  convertitore conv_dc_dc[num_conv, n_paralleli];
  
  
protected
  //calcolo il numero di convertitori per ogni stringa
  parameter Integer num_conv = div(n_serie, n_celle_converter);
  
  //calcolo il numero totale di celle nel pannello
  parameter Integer n_tot_celle = n_serie * n_paralleli;
 
equation

  //ciclo per fornire l'irraggiamento alle celle del modulo
  for i in 1:n_serie loop
    for j in 1:n_paralleli loop
      connect(pv_celle[i,j].Irraggiamento, lights[i,j]);
    end for;
  end for;

    
  // For each series of converters
  for ramo in 1:n_paralleli loop
  
    // Since the converters modeled here are ideal and isolated, all the cells can be wired in series
    // This also gives the additional benefit of biasing all the intermediate nodes
    for ii_cell in 1:n_serie-1 loop
      connect(pv_celle[ii_cell, ramo].n, pv_celle[ii_cell+1, ramo].p);
    end for;
    
    // Connect converters in series
    for ii_conv in 1:num_conv loop
      // Connect converter input p terminal to cells
      connect(pv_celle[1 + (ii_conv - 1)*n_celle_converter, ramo].p, conv_dc_dc[ii_conv, ramo].p_celle);
      // Connect converter input n terminal to cells
      connect(pv_celle[n_celle_converter + (ii_conv - 1)*n_celle_converter, ramo].n, conv_dc_dc[ii_conv, ramo].n_celle);
      // Connect converter outputs in series
      if ii_conv < num_conv then
        connect(conv_dc_dc[ii_conv, ramo].n_stringa, conv_dc_dc[ii_conv + 1, ramo].p_stringa);
      end if;
    end for;
    
    // Connect p terminal of first converter to block p pin
    connect(conv_dc_dc[1, ramo].p_stringa, p);
    // Connect n terminal of last converter to block n pin
    connect(conv_dc_dc[num_conv, ramo].n_stringa, n);
    // Connect n terminal of last cell to block n pin (for biasing the cell string)
    connect(pv_celle[n_serie, ramo].n, n);
    
  end for;

annotation(
    uses(Modelica(version = "4.0.0")));
end pvcell_modulo_convertitore;
