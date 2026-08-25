# /// script
# requires-python = ">=3.14"
# dependencies = ["numpy", "scipy", "matplotlib"]
# ///

import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as spo

class Pvmodel:
    def __init__(self, name):
        self.name = name
        self.Voc = 0
        self.Isc = 0
        self.Vmpp = 0
        self.Impp = 0
        self.Pmpp = self.Vmpp * self.Impp
        self.Idark = 0
        self.Irr_norm = 1000 # [W/m^2]
        self.FF = 0
    def name(self):
        return self.name
    def __str__(self):
        return (
            f"PV \"{self.name}\":\n"
            f"    Voc  = {self.Voc:5.2f} V    Isc  = {self.Isc:5.2f} A    FF   = {self.FF*100:4.2f} %\n"
            f"    Vmpp = {self.Vmpp:5.2f} V    Impp = {self.Impp:5.2f} A    Pmpp = {self.Pmpp:5.2f} W"
        )
    def mpp(self):
        return self.Vmpp, self.Impp, self.Pmpp # dummy values
    def current(self, vp, irr=None):
        if not irr:
            irr = self.Irr_norm
        return self.Isc * irr/self.Irr_norm * np.ones_like(vp) # dummy values
    def power(self, vp, irr=None):
        return vp * self.current(vp, irr)
    def plot(self, block=True, Npts=100, irr=None):
        vp = np.linspace(0, self.Voc, Npts)
        plt.figure()
        for irri in irr:
            ip = self.current(vp, irri)
            plt.plot(vp, ip, 'b-')
            plt.plot(self.Vmpp, self.Impp, 'r*', label="MPP")
        plt.xlabel("Output voltage (V)")
        plt.ylabel("Output current (A)")
        plt.box(True)
        plt.grid(True)
        plt.show(block=block)
    def plot_power(self, block=True, Npts=100, irr=None):
        vp = np.linspace(0, self.Voc, Npts)
        plt.figure()
        for irri in irr:
            ip = self.current(vp, irri)
            plt.plot(vp, vp * ip, 'b-')
            plt.plot(self.Vmpp, self.Pmpp, 'r*', label="MPP")
        plt.xlabel("Output voltage (V)")
        plt.ylabel("Output power (W)")
        plt.box(True)
        plt.grid(True)
        plt.show(block=block)
    
class Pvmodel_table(Pvmodel):
    pass

class Pvmodel_electric(Pvmodel):
    pass

class Pvmodel_rational(Pvmodel):
    def __init__(self, name, Voc, Isc, Ia):
        super().__init__(name)
        self.Voc = Voc
        self.Isc = Isc
        self.Ia = Ia # specific parameter of the liner fraction model
        self.Re = Voc/Isc # derived parameter
        self.Vmpp = self.Re * self.Ia * (1 - np.sqrt(1 - self.Voc/self.Re/self.Ia))
        self.Impp = self.current(self.Vmpp)
        self.Pmpp = self.Vmpp * self.Impp
        self.FF = self.Pmpp/(self.Voc * self.Isc)
    def current(self, vp, irr=None):
        if not irr:
            irr = self.Irr_norm
        ip = self.Ia * (vp - self.Voc)/(vp - self.Re*self.Ia) * irr/self.Irr_norm
        return ip
    pass

pv = Pvmodel_rational("dummy", 14, 8, 8.4)
print(pv)
pv.plot(False, irr=np.array([300, 600, 1000]))
pv.plot_power(True, irr=np.array([300]))
