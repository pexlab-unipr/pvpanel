# /// script
# requires-python = ">=3.14"
# dependencies = ["numpy", "scipy", "matplotlib"]
# ///

import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as spo

# === PV description parameters ===
Isc  = 1.0  # [A] PV panel short circuit current
Voc  = 12.0 # [V] PV panel open circuit voltage
Iset = 0.6  # [A] current working point (set to 0 for MPP)
a    = 1.03 # [A] PV curve shape parameter (must be > Isc)
RL   = 20   # [ohm] minimum output load resistance
RH   = 1e3  # [ohm] maximum output load resistance
eta  = 0.97 # [1] converter efficiency (assumed constant)
Np   = 100  # [1] number of simulation evaluation points

# === Simulation ===
vi = np.linspace(0, Voc, Np)
# Using model based on linear fractional function (homographic function)
fpv = lambda vx: a*(vx - Voc) / (vx - a*Voc/Isc)
ii = fpv(vi)
# Look for MPP
Vmpp = (spo.minimize_scalar(lambda vp: -vp*fpv(vp), bounds=(0, Voc), method='bounded')).x
Impp = fpv(Vmpp)
# In case of Iset == 0, use it
if Iset < 1e-6:
    (Vset, Iset) = (Vmpp, Impp)
else:
    # Find voltage at given input current
    Vset = spo.fsolve(lambda vx: fpv(vx) - Iset, Voc/2)[0]
# Sweep boost converter output resistance
Rmin = Vset/Iset/eta # minimum output resistance to guarantee boost operation
if RL < Rmin:
    RL = Rmin
Ro = np.logspace(np.log10(RL), np.log10(RH), Np)
vo = np.sqrt(Ro * eta* Vset * Iset)
io = vo / Ro
duty = 1 - Vset/vo # hypothesis of boost converter in CCM

# === Results ===
print(f"                 WP    |    MPP")
print(f"Voltage (V)  : {Vset:5.2f}   |  {Vmpp:5.2f}")
print(f"Current (A)  : {Iset:5.2f}   |  {Impp:5.2f}")
print(f"Power   (W)  : {Vset*Iset:5.2f}   |  {Vmpp*Impp:5.2f}")
print(f"Rmin    (ohm): {Rmin:5.2f}")
print(f"Pout    (W)  : {eta*Vset*Iset:5.2f}")

plt.figure()
plt.plot(vi, ii, 'b-', label="PV characteristic")
plt.plot(Vset, Iset, 'go', label="Working point")
plt.plot(Vmpp, Impp, 'r*', label="MPP")
plt.xlabel("Panel voltage (V)")
plt.ylabel("Panel current (A)")
plt.legend()
plt.box(True)
plt.grid(True)
plt.show(block=False)

plt.figure()
plt.plot(vi, vi*ii, 'b-', label="PV characteristic")
plt.plot(Vset, Vset*Iset, 'go', label="Working point")
plt.plot(Vmpp, Vmpp*Impp, 'r*', label="MPP")
plt.xlabel("Panel voltage (V)")
plt.ylabel("Panel power (W)")
plt.legend()
plt.box(True)
plt.grid(True)
plt.show(block=False)

plt.figure()
plt.plot(vo, io, 'b-')
plt.xlabel("Output voltage (V)")
plt.ylabel("Output current (A)")
plt.box(True)
plt.grid(True)
plt.show(block=False)

plt.figure()
plt.plot(Ro, duty, 'b-')
plt.plot([Rmin, Rmin], [0, 1], 'r--', label="Minimum resistance")
plt.xlabel("Load resistance (Ohm)")
plt.ylabel("Boost duty-cycle (1)")
plt.legend()
plt.box(True)
plt.grid(True)
plt.show()
