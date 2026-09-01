# /// script
# requires-python = ">=3.14"
# dependencies = ["numpy", "scipy", "matplotlib", "pandas"]
# ///

from enum import Enum
import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as spo
import scipy.interpolate as spi
import pandas as pd

# Support functions
def extend(value, x, default=0):
    y = np.broadcast_to( \
        np.asarray(default if value is None else value), \
        x.shape)
    return y

# PV condition class
class PvCondition:
    def __init__(self, irradiance, panel_temp, ambient_temp, air_mass, wind_speed):
        self.irradiance = irradiance     # [W/m^2] panel irradiance
        self.panel_temp = panel_temp     # [°C] panel temperature
        self.ambient_temp = ambient_temp # [°C] ambient temperature
        self.air_mass = air_mass         # [1] air mass
        self.wind_speed = wind_speed     # [m/s] wind speed

STC = PvCondition(irradiance=1000, panel_temp=25, ambient_temp=25, air_mass=1.5, wind_speed=0)
NOCT = PvCondition(irradiance=800, panel_temp=45, ambient_temp=20, air_mass=1.5, wind_speed=1)

# Enumeration for PV model
PvModelType = Enum('PvModelType', [
    ('TABLE'           , 1),
    ('ELECTRIC'        , 2),
    ('LINEAR_RATIONAL' , 3),
    ('EXPONENTIAL'     , 4),
    ('PIECEWISE_LINEAR', 5)])

# Main PV model classes
class PvModel:
    def __init__(self, \
                 voc, isc, \
                 vmpp=None, impp=None, pmpp=None, ff=None, \
                 ctc=0.05, vtc=-0.25, ptc=-0.35, \
                 condition=STC, name=None, model=None):
        self.voc = voc
        self.isc = isc
        self.vmpp = vmpp
        self.impp = impp
        self.pmpp = pmpp
        self.ff = ff
        self.ctc = ctc # [%/°C] short-circuit current temperature coefficient
        self.vtc = vtc # [%/°C] open-circuit voltage temperature coefficient
        self.ptc = ptc # [%/°C] maximum power temperature coefficient
        self.condition = condition # condition at which data is represented, defaults to STC
        self.name = name
        self.model = model
        self.mpp_check()
    def mpp_check(self):
        # Assume similarity in ratio of MPP to characteristic boundaries
        # TODO: check if similarity hypothesis hold
        if (self.vmpp is not None) and (self.impp is not None): # MPP completely specified, overrides everything
            self.pmpp = self.vmpp * self.impp
            self.ff = self.pmpp/(self.voc * self.isc)
        elif self.pmpp is not None: # maximum power specified, overrides fill factor
            self.ff = self.pmpp/(self.voc * self.isc)
            a = np.sqrt(self.ff)
            self.vmpp = a * self.voc
            self.impp = a * self.isc
        elif self.ff is not None: # only fill factor given
            self.pmpp = self.ff * self.voc * self.isc
            a = np.sqrt(self.ff)
            self.vmpp = a * self.voc
            self.impp = a * self.isc
        else:
            raise ValueError("Either maximum power or fill factor must be specified.")
    def __str__(self):
        return (
            f"PV \"{self.name}\":\n"
            f"    Voc  = {self.voc:5.2f} V    Isc  = {self.isc:5.2f} A    FF   = {self.ff*100:4.2f} %\n"
            f"    Vmpp = {self.vmpp:5.2f} V    Impp = {self.impp:5.2f} A    Pmpp = {self.pmpp:5.2f} W"
        )
    def current_model(self, vp, voc, isc, vmpp, impp, pmpp, model):
        match model:
            case PvModelType.TABLE:
                ip = isc * np.ones_like(vp)
            case PvModelType.ELECTRIC:
                ip = isc * np.ones_like(vp)
            case PvModelType.LINEAR_RATIONAL:
                ip = isc * np.ones_like(vp)
            case PvModelType.EXPONENTIAL:
                ip = isc * np.ones_like(vp)
            case PvModelType.PIECEWISE_LINEAR:
                # ip = np.interp(vp, [0, vmpp, voc], [isc, impp, 0]) # does not extrapolate!!
                ip = spi.make_interp_spline([0, vmpp, voc], [isc, impp, 0], k=1)(vp)
            case _:
                raise ValueError("Unknown or unspecified PV model type.")
        return ip
    def current(self, vp, condition=STC, model=None):
        # Scale short-circuit current in irradiance and temperature
        isc = self.isc * (condition.irradiance/self.condition.irradiance) * (1 + self.ctc/100 * (condition.panel_temp - self.condition.panel_temp))
        # Scale open-circuit voltage in temperature only
        voc = self.voc * (1 + self.vtc/100 * (condition.panel_temp - self.condition.panel_temp))
        # TODO: check how Vmpp and Impp scale with temperature
        # For now, assuming they scale as Voc and Isc, respectively
        impp = self.impp * (condition.irradiance/self.condition.irradiance) * (1 + self.ctc/100 * (condition.panel_temp - self.condition.panel_temp))
        vmpp = self.vmpp * (1 + self.vtc/100 * (condition.panel_temp - self.condition.panel_temp))
        # Scale power in case it is needed by the interpolation model
        pmpp = self.pmpp * (1 + self.ptc/100 * (condition.panel_temp - self.condition.panel_temp))
        # Compute current according to model
        model = self.model if model is None else model
        # TODO: check how to pass data at the specific current model
        ip = self.current_model(vp, voc, isc, vmpp, impp, pmpp, model)
        return ip
    def power(self, vp, condition=STC, model=None):
        return vp * self.current(vp, condition, model)
    def mpp(self, condition=STC):
        # TODO: recompute values according to condition and model
        return self.vmpp, self.impp, self.pmpp, self.FF
    def plot(self, \
             conditions=[STC], model=None, \
             plot_current=True, plot_power=False, plot_mpp=True, \
             block=True, Npts=100):
        vp = np.linspace(0, self.voc, Npts)
        model = self.model if model is None else model
        x = np.ones_like(vp) if plot_current else vp
        plt.figure()
        for condition in conditions:
            ip = self.current(vp, condition, model)
            plt.plot(vp, x * ip, 'b-')
        plt.plot(vp, x * self.current(vp, condition=STC, model=model), 'g--', label="STC")
        plt.plot(vp, x * self.current(vp, condition=NOCT, model=model), 'm--', label="NOCT")
        plt.plot(self.vmpp, self.impp, 'r*', label="MPP")
        plt.xlabel("Output voltage (V)")
        plt.ylabel("Output current (A)") # plt.ylabel("Output power (W)")
        plt.xlim(0, self.voc)
        plt.ylim(0, self.isc * 1.1) # plt.ylim(0, self.Pmpp * 1.1)
        plt.box(True)
        plt.grid(True)
        plt.show(block=block)

""" class Pvmodel_table(Pvmodel):
    def __init__(self, name, filename):
        super().__init__(name)
        data = pd.read_csv(filename, sep=',', header=0, usecols=["V", "I"])
        self.vp = data.V.to_numpy()
        self.ip = data.I.to_numpy()
        self.Isc = self.ip.max()
        self.Voc = self.vp.max()
        pp = self.vp * self.ip
        self.Pmpp = pp.max()
        ii_mpp = pp.argmax()
        self.Vmpp = self.vp[ii_mpp]
        self.Impp = self.ip[ii_mpp]
        self.FF = self.Pmpp/(self.Voc * self.Isc)
    def current(self, vp, irr=None, Tp=None):
        if irr is None:
            irr = self.Irr_norm
        if Tp is None:
            Tp = self.T_norm
        ip = np.interp(vp, self.vp, self.ip) - self.Isc*(1 - irr/self.Irr_norm)
        return ip

class Pvmodel_electric(Pvmodel):
    def __init__(self, name, Voc, Isc, Idark, eta, Rs, Rp):
        super().__init__(name)
        self.Voc = Voc
        self.Isc = Isc
        self.Idark = Idark
        self.eta = eta
        self.Rs = Rs
        self.Rp = Rp
        self.Vt = 26e-3 # TODO: insert temperature dependence
        # Euristic: compute number of equivalent junctions in series, 
        # dividing by open circuit voltage of a diode giving the desired Isc
        self.N = np.round(self.Voc/(self.eta*self.Vt*np.log(self.Isc/self.Idark)))
        self.Irr_norm = 1000 # [W/m^2]
        self.T_norm = 25 # [°C]
    def current(self, vp, irr=None, Tp=None):
        if irr is None:
            irr = self.Irr_norm
        if Tp is None:
            Tp = self.T_norm
        ip = np.empty_like(vp)
        ii = 0
        for vpi in vp:
            vpi = vpi/self.N
            f = lambda x: \
                self.Isc * irr/self.Irr_norm - \
                self.Idark * (np.exp((vpi + self.Rs * x)/self.eta/self.Vt) - 1) - \
                (vpi + self.Rs * x)/self.Rp - \
                x
            ip[ii] = spo.root_scalar(f, x0=self.Isc/2).root
            ii += 1
        return ip

class Pvmodel_rational(Pvmodel):
    def __init__(self, name, Voc, Isc, Ia):
        super().__init__(name)
        self.Voc = Voc
        self.Isc = Isc
        self.Ia = Ia # specific parameter of the linear fraction model
        self.Re = Voc/Isc # derived parameter
        self.Vmpp = self.Re * self.Ia * (1 - np.sqrt(1 - self.Voc/self.Re/self.Ia)) # analytical expression
        self.Impp = self.current(self.Vmpp)
        self.Pmpp = self.power(self.Vmpp)
        self.FF = self.Pmpp/(self.Voc * self.Isc)
    @classmethod
    def from_data(cls, name, filename): # "overloaded constructor" the (strange) Python way!
        data = pd.read_csv(filename, sep=',', header=0, usecols=["V", "I"])
        vp = data.V.to_numpy()
        ip = data.I.to_numpy()
        Isc = ip.max()
        Voc = vp.max()
        # LSQ fit on all the characteristic gives bad results
        f = lambda x, p: Pvmodel_rational("asd", Voc, Isc, p).current(x)
        # TODO Trying fitting on fill factor
        Ia = spo.curve_fit(f, vp, ip, p0=None, bounds=(Isc, np.inf))[0][0]
        return cls(name, Voc, Isc, Ia)
    def current(self, vp, irr=None, Tp=None):
        if irr is None:
            irr = self.Irr_norm
        if Tp is None:
            Tp = self.T_norm
        # TODO: manage temperature
        # ip = self.Ia * (vp - self.Voc)/(vp - self.Re*self.Ia) * irr/self.Irr_norm # Voc does not change with irradiance
        ip = self.Ia * (vp - self.Voc)/(vp - self.Re*self.Ia) - self.Isc*(1 - irr/self.Irr_norm) # Voc changes but unvalidated
        return ip

class Pvmodel_pwl(Pvmodel):
    def __init__(self, name, Voc, Isc, Rs, Rp):
        super().__init__(name)
        self.Voc = Voc
        self.Isc = Isc
        self.Rs = Rs
        self.Rp = Rp
        self.Irr_norm = 1000 # [W/m^2]
        self.T_norm = 25 # [°C]
    def current(self, vp, irr=None, Tp=None):
        if irr is None:
            irr = self.Irr_norm
        if Tp is None:
            Tp = self.T_norm
        ip_doff = self.Isc * irr/self.Irr_norm - 1/self.Rp * vp
        ip_don = (self.Voc - vp)/self.Rs
        ip = np.minimum(ip_doff, ip_don)
        return ip """

# ==== Test bench ====

pv1 = PvModel(48, 12, ff=0.75)
pv2 = PvModel(48, 12, ff=0.75, name="prova")
pv3 = PvModel(48, 12, pmpp=400)
pv4 = PvModel(48, 12, pmpp=400, ff=0.8)
pv5 = PvModel(48, 12, vmpp=44, impp=9)
print(pv1)
print(pv2)
print(pv3)
print(pv4)
print(pv5)
pv1.plot(model=PvModelType.PIECEWISE_LINEAR)

print("Ciao!")
plt.close('all')
