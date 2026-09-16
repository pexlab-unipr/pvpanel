within Pexlab;

package Converters

  model IdealDCDC
    extends Modelica.Electrical.Analog.Interfaces.TwoPort;
    
    parameter Real                         gain = 1              "converter voltage gain"; // nominal value (depends on saturation)
    parameter Real                         efficiency = 1        "converter efficiency";
    parameter Modelica.Units.SI.Resistance input_impedance = 0.1 "input impedance"; // nominal value (depends on saturation)
    parameter Modelica.Units.SI.Current    I_out_max = 100       "output current maximum value";
    parameter Boolean                      fixed_gain = true     "true/false = gain/input-impedance control";
    
    Modelica.Units.SI.Power pw1 "input power";
    Modelica.Units.SI.Power pw2 "output power";
    // Working values (depend on saturation)
    Modelica.Units.SI.Resistance R_in "input impedance";
    Real A "converter gain";
    Real s(start = -1.0) "abstract variable for saturation";
    Boolean sat "internal flag indicating saturation";
    
    equation
    // Output voltage as a function of input, multiplied by actual gain
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

    Note on fictious variable "s":
    It is designed to provide non-smooth management with a continuous variable. So it must be:
      - continuous
      - determine directly the saturation condition
      - at saturation edge, satisfy both saturated and unsaturated conditions
      - preserve the monotony of the saturation effect on the other parameter
    Hence, when s = 0, i_out_max/(s - 1) = -I_out_max and gain/(s + 1) = gain.
    Start value is somewhat arbitrary (?)
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
  end IdealDCDC;

end Converters;
