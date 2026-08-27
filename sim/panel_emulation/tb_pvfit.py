# /// script
# requires-python = ">=3.14"
# dependencies = ["numpy", "scipy", "matplotlib", "pandas"]
# ///

import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as spo
import pandas as pd

class Pvmodel:
    def __init__(self, name):
        self.name = name
        self.Voc = 0
        self.Isc = 0
        self.Vmpp = 0
        self.Impp = 0
        self.Pmpp = self.Vmpp * self.Impp
        self.Idark = 0
        self.FF = 0
        self.Irr_norm = 1000 # [W/m^2]
        self.T_norm = 25 # [°C]
    def name(self):
        return self.name
    def __str__(self):
        return (
            f"PV \"{self.name}\":\n"
            f"    Voc  = {self.Voc:5.2f} V    Isc  = {self.Isc:5.2f} A    FF   = {self.FF*100:4.2f} %\n"
            f"    Vmpp = {self.Vmpp:5.2f} V    Impp = {self.Impp:5.2f} A    Pmpp = {self.Pmpp:5.2f} W"
        )
    def mpp(self):
        return self.Vmpp, self.Impp, self.Pmpp, self.FF
    def current(self, vp, irr=None, Tp=None):
        if irr is None:
            irr = self.Irr_norm
        if Tp is None:
            Tp = self.T_norm
        # TODO: manage temperature in code, not only in interface
        return self.Isc * irr/self.Irr_norm * np.ones_like(vp) # dummy values
    def power(self, vp, irr=None, Tp=None):
        return vp * self.current(vp, irr, Tp)
    def plot(self, block=True, Npts=100, irr=None, Tp=None):
        vp = np.linspace(0, self.Voc, Npts)
        plt.figure()
        if irr is None:
            irr = self.Irr_norm
        if Tp is None:
            Tp = self.T_norm
        conditions = np.hstack((np.reshape(irr, (-1, 1)), np.reshape(Tp, (-1, 1))))
        for condition in conditions:
            (irri, Tpi) = condition
            ip = self.current(vp, irri, Tpi)
            plt.plot(vp, ip, 'b-')
        plt.plot(vp, self.current(vp), 'g--', label="normal")
        plt.plot(self.Vmpp, self.Impp, 'r*', label="MPP")
        plt.xlabel("Output voltage (V)")
        plt.ylabel("Output current (A)")
        plt.xlim(0, self.Voc)
        plt.ylim(0, self.Isc*1.1)
        plt.box(True)
        plt.grid(True)
        plt.show(block=block)
    def plot_power(self, block=True, Npts=100, irr=None, Tp=None):
        vp = np.linspace(0, self.Voc, Npts)
        plt.figure()
        if irr is None:
            irr = self.Irr_norm
        if Tp is None:
            Tp = self.T_norm
        conditions = np.hstack((np.reshape(irr, (-1, 1)), np.reshape(Tp, (-1, 1))))
        for condition in conditions:
            (irri, Tpi) = condition
            ip = self.current(vp, irri, Tpi)
            plt.plot(vp, vp * ip, 'b-')
        plt.plot(vp, vp * self.current(vp), 'g--', label="normal")
        plt.plot(self.Vmpp, self.Pmpp, 'r*', label="MPP")
        plt.xlabel("Output voltage (V)")
        plt.ylabel("Output power (W)")
        plt.xlim(0, self.Voc)
        plt.ylim(0, self.Pmpp*1.1)
        plt.box(True)
        plt.grid(True)
        plt.show(block=block)
    
class Pvmodel_table(Pvmodel):
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
    pass

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
        # f = lambda x, p: Pvmodel_rational("asd", Voc, Isc, p).current(x)
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
    pass

pva = Pvmodel_rational("dummy analytical", 14, 8, 8.1)
print(pva)
pva.plot(False, irr=np.array([300, 600, 900]), Tp=np.array([40, 40, 40]))
pva.plot_power(False, irr=np.array([300, 600, 900]), Tp=np.array([40, 40, 40]))
# pva.plot(False)
# pva.plot_power(False)

pvt = Pvmodel_table("openei table", "10333_34_5_01152020.csv")
print(pvt)
pvt.plot(False)
pvt.plot_power(False)
pvt.plot(False, irr=np.array([300, 600, 900]), Tp=np.array([40, 40, 40]))
pvt.plot_power(False, irr=np.array([300, 600, 900]), Tp=np.array([40, 40, 40]))

Ias = np.linspace(8.01, 9, 100)
FFs = np.array([Pvmodel_rational("asd", 14, 8, Ia).mpp()[3] for Ia in Ias])
plt.figure()
plt.plot(Ias, FFs)
plt.show(block=False)

pvf = Pvmodel_rational.from_data("openei fitted", "10333_34_5_01152020.csv")
print(pvf)
pvf.plot(True, irr=np.array([300, 600, 900]), Tp=np.array([40, 40, 40]))

print("Ciao!")
