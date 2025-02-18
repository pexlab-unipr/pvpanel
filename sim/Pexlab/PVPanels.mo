within Pexlab;
package PVPanels

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

  model convertitore
    Modelica.Electrical.Analog.Interfaces.PositivePin p_celle annotation(
      Placement(transformation(origin = {-100, 30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, 30}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Electrical.Analog.Interfaces.NegativePin n_celle annotation(
      Placement(transformation(origin = {-100, -30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-100, -30}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Electrical.Analog.Interfaces.PositivePin p_stringa annotation(
      Placement(transformation(origin = {100, 30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, 30}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Electrical.Analog.Interfaces.NegativePin n_stringa annotation(
      Placement(transformation(origin = {100, -30}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, -30}, extent = {{-10, -10}, {10, 10}})));

    parameter Real efficienza = 1   "efficienza del convertitore";
    parameter Real input_impedance = 0.1 "input impedance";
    parameter Real I_in_max = 1 "input current maximum value";
    
    // gain to be determined by power conservation
    Real guadagno "guadagno di conversione";
    
    Real v_in "input voltage";
    Real v_out "output voltage";
    Real i_in  "input current";
    Real i_out "output current";
    Real p_in  "input power";
    Real p_out "output power";
    
  equation
    
    // Easy-to-see quantities
    v_in = p_celle.v - n_celle.v;
    v_out = p_stringa.v - n_stringa.v;
    i_in = p_celle.i;
    i_out = p_stringa.i;
    
    // KCL at input and output
    p_celle.i + n_celle.i = 0;
    p_stringa.i + n_stringa.i = 0;
    
    // Output voltage as a function of input, multiplied by gain
    v_out = guadagno * v_in;
    
    //calcolo Pin
    p_in = i_in * v_in;
    
    //calcolo la Pout come Pin * efficienza
    p_out = -p_in * efficienza;
    
    // Iout computation from power conservation (efficiency included)
    i_out * v_out = p_out;
    
    // Impose additional constraint of input impedance, to avoid undetermined states
    v_in = input_impedance * i_in;
    
    annotation(
      uses(Modelica(version = "4.0.0")),
      Diagram);
  end convertitore;

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

end PVPanels;
