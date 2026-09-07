# /// script
# requires-python = ">=3.14"
# dependencies = ["numpy", "scipy", "matplotlib", "pandas", "fplot"]
# ///

from enum import Enum
import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as spo
import scipy.interpolate as spi
import pandas as pd
import fplot

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
                 vmpp=None, impp=None, pmpp=None, ff=0.75, \
                 itc=0.05, vtc=-0.25, ptc=-0.35, \
                 igc=0.1, vgc=0.01, pgc=0.1, \
                 condition=STC, model=None, name=None):
        self.voc = voc
        self.isc = isc
        self.vmpp = vmpp
        self.impp = impp
        self.pmpp = pmpp
        self.ff = ff
        self.itc = itc # [%/°C] short-circuit current temperature coefficient
        self.vtc = vtc # [%/°C] open-circuit voltage temperature coefficient
        self.ptc = ptc # [%/°C] maximum power temperature coefficient
        self.igc = igc # [%/(W/m^2)] short-circuit current irradiance coefficient
        self.vgc = vgc # [%/(W/m^2)] open-circuit voltage irradiance coefficient
        self.pgc = pgc # [%/(W/m^2)] maximum power irradiance coefficient
        self.condition = condition # condition at which data is represented, defaults to STC
        self.model = model
        self.name = name
        self.parameter_check()
    def parameter_check(self):
        # Determine secondary coefficients (temperature and irradiance)
        self.ftc = self.ptc - self.vtc - self.itc # fill factor temperature coefficient
        # Assuming a purely linear relationship between isc-irradiance and pmpp-irradiance,
        # they should both have a coefficient of +0.1 %/(W/m^2). This, in turn, implies that:
        #     fgc = -vgc
        # Since, for sure, vgc is positive, this leads to a negative fgc. This, unfortunately,
        # is the opposite of what is normally seen in reality. Hence, in order to have
        # positive fgc, it must hold that pgc > igc + vgc
        self.fgc = self.pgc - self.vgc - self.igc # fill factor irradiance coefficient
        # TODO: complete computation of coefficients of MPP quantities
        # For now, assuming vmpp coefficients are null
        # ptc = vhtc + ihtc
        # pgc = vhgc + ihgc
        self.vhtc = 0 # MPP voltage temperature coefficient
        self.ihtc = self.ptc - self.vhtc # MPP current temperature coefficient
        self.vhgc = 0 # MPP voltage irradiance coefficient
        self.ihgc = self.pgc - self.vhgc # MPP current irradiance coefficient
        # Full similarity in the ratio between MPP coordinates (vmpp, impp) and characteristic
        # boundaries (voc, isc) does not hold exactly, it seems that:
        # vmpp/voc = 0.80, impp/isc = 0.90
        if (self.vmpp is not None) and (self.impp is not None): # MPP completely specified, overrides everything
            self.pmpp = self.vmpp * self.impp
            self.ff = self.pmpp/(self.voc * self.isc)
        elif self.pmpp is not None: # maximum power specified, overrides fill factor
            self.ff = self.pmpp/(self.voc * self.isc)
            a = np.sqrt(self.ff) # TODO: fix according to what stated above
            self.vmpp = a * self.voc
            self.impp = a * self.isc
        elif self.ff is not None: # only fill factor given
            self.pmpp = self.ff * self.voc * self.isc
            a = np.sqrt(self.ff) # TODO: fix according to what stated above
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
                ff = pmpp/(voc*isc)
                Ia = isc*ff/(2*np.sqrt(ff) - 1)
                ip = Ia * (vp - voc)/(vp - voc/isc*Ia)
            case PvModelType.EXPONENTIAL:
                mdl = lambda vx, p: p[0] + p[1] * np.exp(vx/p[2])
                mdlp = lambda vx, p: p[1]/p[2] * np.exp(vx/p[2])
                fun = lambda y: \
                    y + np.log(y) - np.log(impp/isc) - np.log(np.expm1(voc/vmpp * y))
                fun2 = lambda y: \
                    np.log(np.expm1(y)) - np.log(1 - impp/isc) - np.log(np.expm1(voc/vmpp * y))
                yab = (1, 100)
                # fplot.plot((fun, fun2), yab[0], yab[1])
                y = spo.root_scalar(fun2, bracket=yab, method='brentq').root
                print(y)
                print(fun2(y))
                Vc = vmpp/y
                Ib = -isc/np.expm1(voc/Vc)
                Ia = isc - Ib
                print(mdl(0, (Ia, Ib, Vc)) - isc)
                print(mdl(voc, (Ia, Ib, Vc)))
                print(mdlp(vmpp, (Ia, Ib, Vc)) + impp/vmpp)
                print("--------")
                ip = mdl(vp, (Ia, Ib, Vc))
            case PvModelType.PIECEWISE_LINEAR:
                # ip = np.interp(vp, [0, vmpp, voc], [isc, impp, 0]) # does not extrapolate!!
                ip = spi.make_interp_spline([0, vmpp, voc], [isc, impp, 0], k=1)(vp)
            case _:
                raise ValueError("Unknown or unspecified PV model type.")
        return ip
    def current(self, vp, condition=STC, model=None):
        pmpp, vmpp, impp, ff, voc, isc = self.mpp(condition)
        # Compute current according to model
        model = self.model if model is None else model
        # TODO: check how to pass data at the specific current model
        ip = self.current_model(vp, voc, isc, vmpp, impp, pmpp, model)
        ip[vp > voc] = np.nan
        return ip
    def power(self, vp, condition=STC, model=None):
        return vp * self.current(vp, condition, model)
    def mpp(self, condition=STC):
        # Compute differences in conditions
        Delta_T = condition.panel_temp - self.condition.panel_temp
        Delta_G = condition.irradiance - self.condition.irradiance
        # Scale quantities in irradiance and temperature
        isc = self.isc * (1 + self.itc/100 * Delta_T + self.igc/100 * Delta_G)
        voc = self.voc * (1 + self.vtc/100 * Delta_T + self.vgc/100 * Delta_G)
        # TODO: check how Vmpp and Impp scale with temperature and irradiance
        # For now, assuming they scale as Voc and Isc, respectively
        impp = self.impp * (1 + self.ihtc/100 * Delta_T + self.ihgc/100 * Delta_G)
        vmpp = self.vmpp * (1 + self.vhtc/100 * Delta_T + self.vhgc/100 * Delta_G)
        # Scale maximum power (temperature and irradiance)
        pmpp = self.pmpp * (1 + self.ptc/100 * Delta_T + self.pgc/100 * Delta_G)
        ff = self.ff * (1 + self.ftc/100 * Delta_T + self.fgc/100 * Delta_G)
        # Check if Pmpp computed with temperature and irradiance is consistent with Vmpp*Impp
        assert np.abs(pmpp/(vmpp*impp) - 1) < 0.02, "Inconsistent max power in non-standard conditions."
        return pmpp, vmpp, impp, ff, voc, isc
    def plot(self, \
             conditions=[STC], model=None, \
             plot_current=True, plot_power=False, plot_mpp=True, \
             block=True, Npts=100):
        vp = np.linspace(0, self.voc, Npts)
        model = self.model if model is None else model
        fig, ax1 = plt.subplots()
        ax2 = ax1.twinx()
        ax1.set_xlabel('Panel voltage (V)')
        for condition in conditions:
            ip = self.current(vp, condition, model)
            if plot_current:
                ax1.plot(vp, ip, 'b-')
            if plot_power:
                ax2.plot(vp, vp * ip, 'b--')
        if plot_current:
            ax1.plot(vp, self.current(vp, condition=STC, model=model), 'g-', label="STC")
            ax1.plot(vp, self.current(vp, condition=NOCT, model=model), 'm-', label="NOCT")
            ax1.plot(self.vmpp, self.impp, 'r*', label="MPP")
            ax1.set_ylabel('Panel current (A)')
            ax1.set_ylim([0, self.isc*1.1])
        if plot_power:
            ax2.plot(vp, vp * self.current(vp, condition=STC, model=model), 'g--', label="STC")
            ax2.plot(vp, vp * self.current(vp, condition=NOCT, model=model), 'm--', label="NOCT")
            ax2.plot(self.vmpp, self.pmpp, 'r.', label="MPP")
            ax2.set_ylabel('Panel power (W)')
            ax2.set_ylim([0, self.pmpp*1.1])
        ax1.set_xlim([0, self.voc])
        ax1.grid(True)
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
conditions = [
    PvCondition(irradiance=1000, panel_temp=25, ambient_temp=25, air_mass=1.5, wind_speed=0),
    PvCondition(irradiance= 800, panel_temp=25, ambient_temp=25, air_mass=1.5, wind_speed=0),
    PvCondition(irradiance= 600, panel_temp=25, ambient_temp=25, air_mass=1.5, wind_speed=0),
    PvCondition(irradiance= 400, panel_temp=25, ambient_temp=25, air_mass=1.5, wind_speed=0),
    PvCondition(irradiance= 200, panel_temp=25, ambient_temp=25, air_mass=1.5, wind_speed=0)
]
pv1.plot(conditions=conditions, plot_current=True, plot_power=True, model=PvModelType.PIECEWISE_LINEAR)
pv1.plot(conditions=conditions, plot_current=True, plot_power=True, model=PvModelType.LINEAR_RATIONAL)
pv1.plot(conditions=conditions, plot_current=True, plot_power=True, model=PvModelType.EXPONENTIAL)

print("Ciao!")
plt.close('all')
