import os
import sys

import matplotlib.pyplot as plt
import pandas

# Forces matplotlib to use Type 1 fonts
# plt.rcParams["text.usetex"] = True
# plt.rcParams["pdf.fonttype"] = 42
# plt.rcParams["ps.fonttype"] = 42

"""Regenerate plots as shown at the end of the simulation, but with python"""

# Give one of the result files. We shall find the rest of them
file = sys.argv[1]
if not os.path.exists(file):
    print("The file does not exist")
    sys.exit(1)

result_list = []
motor_name = os.path.basename(os.path.dirname(file))
for f in os.listdir(os.path.dirname(file)):
    if (f.endswith(".csv")) and ("state" not in f):
        result_list.append(os.path.join(os.path.dirname(file), f))
result_list.sort()
print(result_list)

df = {
    os.path.splitext(os.path.basename(f))[0].split("_")[-1]: pandas.read_csv(
        f,
        sep=",",
        low_memory=False,
        header=0,
        dtype=float,
    )
    for f in result_list
}


for key in df.keys():
    # Fill NaN with the value from last row
    df[key].fillna(method="pad", inplace=True)
    df[key].set_index("step", inplace=True)  # set column 'step' as index


# Display data
nrows, ncols = 3, 3
fig, ax = plt.subplots(nrows, ncols)
fig.suptitle("Motor : " + motor_name, fontsize=16)
plt.get_current_fig_manager().window.showMaximized()

i = 1
# Phi_vec_amps
plt.subplot(nrows, ncols, i)
for key in df.keys():
    df[key]["PhA_amps"].plot(style="-r")
    df[key]["PhB_amps"].plot(style="-g")
    df[key]["PhC_amps"].plot(style="-b")
plt.legend(["PhA", "PhB", "PhC"])
plt.xlabel("Angle [deg]")
plt.ylabel("Currents [A]")
plt.title("Phase currents")
plt.grid(True)

# Phi_vec_webs
i += 1
plt.subplot(nrows, ncols, i)
for key in df.keys():
    df[key]["PhA_webs"].plot(style="-r")
    df[key]["PhB_webs"].plot(style="-g")
    df[key]["PhC_webs"].plot(style="-b")
plt.legend(["PhA", "PhB", "PhC"])
plt.xlabel("Angle [deg]")
plt.ylabel("Flux Linkage [Wb]")
plt.title("Phase Flux Linkages")
plt.grid(True)

# torque
i += 1
plt.subplot(nrows, ncols, i)
for key in df.keys():
    df[key]["torque"].plot(label="{} A".format(float(key)), legend=True)
plt.xlabel("Angle [deg]")
plt.ylabel("Torque [Nm]")
plt.title("Transient Torque")
plt.grid(True)

# Stator Tooth B Field
i += 1
plt.subplot(nrows, ncols, i)
for key in df.keys():
    df[key]["B_tooth_T"].plot(label="{} A".format(float(key)), legend=True)
plt.xlabel("Angle [deg]")
plt.ylabel("B max field tooth [T]")
plt.title("Stator Tooth B Field")
plt.grid(True)

# Stator Back-iron B Field
i += 1
plt.subplot(nrows, ncols, i)
for key in df.keys():
    df[key]["B_bkiron_T"].plot(label="{} A".format(float(key)), legend=True)
plt.xlabel("Angle [deg]")
plt.ylabel("B max field back-iron [T]")
plt.title("Stator Back-iron B Field")
plt.grid(True)

# Stator Airgap B Field
i += 1
plt.subplot(nrows, ncols, i)
for key in df.keys():
    df[key]["B_airgap_T"].plot(label="{} A".format(float(key)), legend=True)
plt.xlabel("Angle [deg]")
plt.ylabel("B max field airgap [T]")
plt.title("Stator Airgap B Field")
plt.grid(True)

# Mag H and B
i += 1
plt.subplot(nrows, ncols, i)
for key in df.keys():
    plt.plot(
        df[key]["neg_Mag_H"],
        df[key]["Mag_B"],
        label="{} A".format(float(key)),
    )
plt.legend()
plt.xlabel("neg_Mag_H")
plt.ylabel("Mag_B")
plt.grid(True)

# Phi_vec_volts
i += 1
plt.subplot(nrows, ncols, i)
for key in df.keys():
    df[key]["PhA_volts"].plot(style="-r")
    df[key]["PhB_volts"].plot(style="-g")
    df[key]["PhC_volts"].plot(style="-b")
plt.legend(["PhA", "PhB", "PhC"])
plt.xlabel("Angle [deg]")
plt.ylabel("Induced Voltage [V]")
plt.title("Induced Phase Voltages")
plt.grid(True)

plt.tight_layout()
plt.show()
