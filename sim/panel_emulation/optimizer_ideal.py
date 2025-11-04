import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as spo

Isc = 1.0
Voc = 12.0
Iset = 0.6
a = 1.03

vi = np.linspace(0, Voc, 100)
fpv = lambda vx: a*(vx - Voc) / (vx - a*Voc/Isc)
ii = fpv(vi)
Vset = spo.fsolve(lambda vx: fpv(vx) - Iset, Voc/2)[0]
print(f"Vset: {Vset:.2f} V")
Ro = np.logspace(np.log10(20), np.log10(1000), 100)
vo = np.sqrt(Ro * Iset * Vset)
io = vo / Ro
duty = 1 - Vset/vo

plt.figure()
plt.plot(vi, ii)
plt.xlabel("Panel voltage (V)")
plt.ylabel("Panel current (A)")
plt.box(True)
plt.grid(True)
plt.show(block=False)

plt.figure()
plt.plot(vo, io)
plt.xlabel("Output voltage (V)")
plt.ylabel("Output current (A)")
plt.box(True)
plt.grid(True)
plt.show(block=False)

plt.figure()
plt.plot(Ro, duty)
plt.xlabel("Load resistance (Ohm)")
plt.ylabel("Boost duty-cycle (1)")
plt.box(True)
plt.grid(True)
plt.show()
