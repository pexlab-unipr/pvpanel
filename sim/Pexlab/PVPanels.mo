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
    extends Modelica.Electrical.Analog.Interfaces.TwoPort;
    
    parameter Real gain = 1              "converter voltage gain"; // suggested gain (depends on saturation conditions)
    parameter Real efficiency = 1        "efficienza del convertitore";
    parameter Real input_impedance = 0.1 "input impedance";
    parameter Real I_out_max             "output current maximum value";
    
    parameter Boolean fixed_gain = true;
    Modelica.Units.SI.Power pw1  "input power";
    Modelica.Units.SI.Power pw2 "output power";
    // Working values (to help dealing with saturations)
    Modelica.Units.SI.Resistance R_in  "input impedance";
    Real A     "converter gain";
    Real s(start = 0.0)    "abstract variable for saturation";
    Boolean sat;
  equation
  // Output voltage as a function of input, multiplied by gain
    v2 = A*v1;
  // Input power computation
    pw1 = v1*i1;
  // Output power computation considering finite efficiency (yet constant)
    pw2 + pw1*efficiency = 0;
  // Iout computation from power conservation (efficiency included)
    pw2 = v2*i2;
  // Input impedance
    v1 = R_in*i1;
    
    /*
    Real input current (i_in) may differ from the nominal one (i_in_unsat), coming from the
    chosen (optimal) input impedance, due to saturation. This is a physical limit imposed
    by the converter implementation.
    i_in is saturated to zero on the negative side to represent unidirectionality of the 
    converter (power cannot flow from output to input).
    */
    sat = s > 0;
    if fixed_gain then
      i2 = if sat then -I_out_max else I_out_max/(s - 1);
      A = if sat then gain/(s + 1) else gain;
    else
      i2 = if sat then -I_out_max else I_out_max/(s - 1);
      R_in = if sat then -input_impedance/(s - 1) else input_impedance;
    end if;
    
    annotation(
      uses(Modelica(version = "4.0.0")),
      Diagram);
  end convertitore;

  model pvcell_singola_cella
    Modelica.Blocks.Interfaces.RealInput Temperatura "temperatura della cella in °C" annotation(
      Placement(transformation(origin = {-340, 60}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 60}, extent = {{-20, -20}, {20, 20}})));
    Modelica.Blocks.Interfaces.RealInput Irraggiamento "Irraggiamento incidente sulla cella" annotation(
      Placement(transformation(origin = {-340, -30}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, -60}, extent = {{-20, -20}, {20, 20}})));
    Modelica.Electrical.Analog.Basic.Resistor R_serie(R = 3e-3, useHeatPort = false, T_ref = 298.15) annotation(
      Placement(transformation(origin = {4, 20}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Electrical.Analog.Basic.Resistor R_shunt(R = 200, useHeatPort = false, T_ref = 298.15) annotation(
      Placement(transformation(origin = {-20, -10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    Modelica.Electrical.Analog.Semiconductors.Diode diode(useTemperatureDependency = false, final useHeatPort = false, Ids = 6.4e-12, final T(final displayUnit = "K") = 297.15, Vt = 26e-3, Maxexp = 150) annotation(
      Placement(transformation(origin = {-52, -10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    Modelica.Electrical.Analog.Sources.SignalCurrent I_ph annotation(
      Placement(transformation(origin = {-80, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    Modelica.Blocks.Sources.Constant Isc0(k = 10) annotation(
      Placement(transformation(origin = {-210, 10}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Math.Product product11 annotation(
      Placement(transformation(origin = {-130, -10}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Math.Division division annotation(
      Placement(transformation(origin = {-290, -50}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Sources.Constant Radiation(k = 1000) annotation(
      Placement(transformation(origin = {-330, -70}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Electrical.Analog.Interfaces.PositivePin p annotation(
      Placement(transformation(origin = {40, 20}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, 60}, extent = {{-16, -16}, {16, 16}})));
    Modelica.Electrical.Analog.Interfaces.NegativePin n annotation(
      Placement(transformation(origin = {40, -40}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, -60}, extent = {{-16, -16}, {16, 16}})));
  Modelica.Blocks.Math.Gain Ksc(k = 0)  annotation(
      Placement(transformation(origin = {-250, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Add add2(k2 = -1)  annotation(
      Placement(transformation(origin = {-290, 50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant Tref(k = 25) annotation(
      Placement(transformation(origin = {-330, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Add add3 annotation(
      Placement(transformation(origin = {-210, 44}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant const(k = 1) annotation(
      Placement(transformation(origin = {-250, 10}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Product product12 annotation(
      Placement(transformation(origin = {-170, 30}, extent = {{-10, -10}, {10, 10}})));
  equation
    connect(diode.p, R_serie.p) annotation(
      Line(points = {{-52, 0}, {-52, 20}, {-6, 20}}, color = {0, 0, 255}));
    connect(product11.y, I_ph.i) annotation(
      Line(points = {{-118, -10}, {-92, -10}}, color = {0, 0, 127}));
    connect(I_ph.n, R_serie.p) annotation(
      Line(points = {{-80, 0}, {-80, 20}, {-6, 20}}, color = {0, 0, 255}));
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
    connect(Temperatura, add2.u1) annotation(
      Line(points = {{-340, 60}, {-321, 60}, {-321, 56}, {-302, 56}}, color = {0, 0, 127}));
    connect(Tref.y, add2.u2) annotation(
      Line(points = {{-318, 30}, {-302, 30}, {-302, 44}}, color = {0, 0, 127}));
    connect(add2.y, Ksc.u) annotation(
      Line(points = {{-278, 50}, {-262, 50}}, color = {0, 0, 127}));
    connect(const.y, add3.u2) annotation(
      Line(points = {{-238, 10}, {-222, 10}, {-222, 38}}, color = {0, 0, 127}));
    connect(Ksc.y, add3.u1) annotation(
      Line(points = {{-238, 50}, {-222, 50}}, color = {0, 0, 127}));
  connect(add3.y, product12.u1) annotation(
      Line(points = {{-198, 44}, {-182, 44}, {-182, 36}}, color = {0, 0, 127}));
  connect(Isc0.y, product12.u2) annotation(
      Line(points = {{-198, 10}, {-182, 10}, {-182, 24}}, color = {0, 0, 127}));
  connect(product12.y, product11.u1) annotation(
      Line(points = {{-158, 30}, {-142, 30}, {-142, -4}}, color = {0, 0, 127}));
  connect(R_shunt.p, R_serie.p) annotation(
      Line(points = {{-20, 0}, {-20, 20}, {-6, 20}}, color = {0, 0, 255}));
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
    //Modelica.Electrical.Analog.Semiconductors.Diode diodi_stringa[n_paralleli]             "diodi di stringa";
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
for ramo in 1:n_paralleli loop //collego l'anodo del diodo di stringa con il terminale + del modulo
        //connect(p, diodi_stringa[ramo].n);
//collego il diodo di stringa con la prima cella
        //connect(diodi_stringa[ramo].p, pv_celle[1, ramo].p);
        connect(p, pv_celle[1, ramo].p);
//ciclo serie
      for serie in 1:n_serie-1 loop
//collego la cella con la successiva
          connect(pv_celle[serie, ramo].n, pv_celle[serie+1, ramo].p);
    
        end for;
//ciclo per collegare diodi di bypass
        for bp_diode in 1:num_bypass loop
          connect(pv_celle[(bp_diode-1) * n_celle_bypass + 1, ramo].p, diodi_bypass[bp_diode, ramo].n);
          connect(pv_celle[bp_diode * n_celle_bypass, ramo].n, diodi_bypass[bp_diode, ramo].p);
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
    parameter Real I_out_max_converter "maximum converter output current";
    // Matrix of PV cells, arranged as in the module (series -> rows, parallels -> columns)
    pvcell_singola_cella pv_celle[n_serie, n_paralleli] (each Temperatura = temp_test) "creo array e assegno temperatura a ciascuno";
  //importo la matrice per l'illuminazione delle singole celle
    Modelica.Blocks.Interfaces.RealVectorInput lights[n_serie, n_paralleli] annotation(
      Placement(transformation(origin = {-138, 0}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}})));

//importo il modello del convertitore, per ora non cambio il guadagno
    convertitore conv_dc_dc[num_conv, n_paralleli](each I_out_max = I_out_max_converter, each fixed_gain = false, each R_in = 15);
    
    
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
        connect(pv_celle[1 + (ii_conv - 1)*n_celle_converter, ramo].p, conv_dc_dc[ii_conv, ramo].p1);
// Connect converter input n terminal to cells
        connect(pv_celle[n_celle_converter + (ii_conv - 1)*n_celle_converter, ramo].n, conv_dc_dc[ii_conv, ramo].n1);
// Connect converter outputs in series
        if ii_conv < num_conv then
          connect(conv_dc_dc[ii_conv, ramo].n2, conv_dc_dc[ii_conv + 1, ramo].p2);
        end if;
      end for;
// Connect p terminal of first converter to block p pin
      connect(conv_dc_dc[1, ramo].p2, p);
// Connect n terminal of last converter to block n pin
      connect(conv_dc_dc[num_conv, ramo].n2, n);
// Connect n terminal of last cell to block n pin (for biasing the cell string)
      connect(pv_celle[n_serie, ramo].n, n);
    end for;
  annotation(
      uses(Modelica(version = "4.0.0")));
  end pvcell_modulo_convertitore;

end PVPanels;
