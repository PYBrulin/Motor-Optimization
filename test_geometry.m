%%% Create Motor Geometry Struct %%%

g.depth = 8; % axial length
g.s.slots = 36; % stator slots
g.s.r1 = 40.5; % tooth surface radius
g.s.r2 = 31.8; % radius at tooth root
g.s.r3 = 29.3; % backiron radius
g.s.t_pct = .39; % tooth fill percent
g.s.tip_pct = .75; % tooth tip fill percent
g.s.tip_l = 1; % Tooth tip length
g.s.tip_angle = pi / 16; % Tooth tip flare angle
g.s.ff = .8; % Slot fill-factor

g.r.ppairs = 21; % pole-pairs
g.r.r1 = 40.7; % rotor surface radius
g.r.r2 = 42.02; % back-iron radius, magnet side
g.r.r3 = 43.42; % backiron radius
g.r.m_pct = .7; % Magnet fill percent

g = calc_geometry(g);
