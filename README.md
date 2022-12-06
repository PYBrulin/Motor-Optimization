# Motor-Optimization

## Updated for use

Work in progress fork for FEMM and MATLAB based parameterized motor geometry simulation.

The geometry declaration should be more straight-forward and allows full motor geometry as shown in the following simulations:

<p align="center">
    <img src="U8II_animation.gif">
    <img align="left" width="50%" src="MN4006_animation.gif">
    <img align="left" width="50%" src="MN501S_animation.gif">
</p>

## Previous README

FEMM and MATLAB based parameterized motor geometry simulation

Geometry parameterization works for inrunners, outrunners, concentrated windings, distributed/full pitch windings.

Features so far:

- Draws a section of the motor based on ~15 geometry parameters, with the rotor at a specified angle (init_geometry_2.m)
- Calculates torque (static) given specified d and q axis currents (assming 1 turn per slot) (calc_torque.m)
- Calculates stator/rotor mass, rotor inertia, phase resistance (resistance is wrong right now, need to fix) (calc_phys_props.m)

Features to add:

- hallback rotor support
- IPM rotor suport, maybe
- inductance calculations
- line voltage calculations
- losses at speed, maybe eventually
- optimization/parameter sweeping

<img align="left" width="50%" src="u8_animation.gif">
<img align="left" width="50%" src="walco_animation.gif">
