within Pexlab;

package Converters

  model IdealDCDC
    extends Modelica.Electrical.Analog.Interfaces.TwoPort;
    
    parameter Real gain = 1              "converter voltage gain"; // suggested gain (depends on saturation conditions)
    parameter Real efficiency = 1        "efficienza del convertitore";
    parameter Real input_impedance = 0.1 "input impedance";
    parameter Real I_out_max             "output current maximum value";
    parameter Boolean fixed_gain = true;
    
    Modelica.Units.SI.Power pw1 "input power";
    Modelica.Units.SI.Power pw2 "output power";
    // Working values (to help dealing with saturations)
    Modelica.Units.SI.Resistance R_in "input impedance";
    Real A "converter gain";
    Real s(start = -1.0) "abstract variable for saturation";
    Boolean sat "internal flag indicating saturation";
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
      A = if sat then gain/(s + 1) else gain; // TODO: check this strange (s + 1)
    else
      i2 = if sat then -I_out_max else I_out_max/(s - 1);
      R_in = if sat then -input_impedance/(s - 1) else input_impedance;
    end if;
    
    annotation(
      uses(Modelica(version = "4.0.0")),
      Diagram);
  end IdealDCDC;

end Converters;
