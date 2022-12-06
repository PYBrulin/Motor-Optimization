%%% Create Motor Geometry Struct %%%
g.name = "test_outrunner";

g.depth = 8; % axial length
g.s.slots = 6*2; % stator slots
g.s.r1 = 19.7; % tooth surface radius
g.s.r2 = 13; % radius at tooth root
g.s.r3 = 10; % backiron radius
g.s.t_pct = .28; % tooth fill percent
g.s.tip_pct = .707; % tooth tip fill percent
g.s.tip_l = .5; % Tooth tip length
g.s.tip_angle = pi / 24; % Tooth tip flare angle
g.s.ff = .5; % Slot fill-factor

g.r.ppairs = 2*2; % pole-pairs
g.r.r1 = 20; % rotor surface radius
g.r.r2 = 22; % back-iron radius, magnet side
g.r.r3 = 24; % backiron radius
g.r.m_pct = .62; % Magnet fill percent

% g.n_p = 7; % number of poles to simulate
% g.n_s = 6; % number of slots to simulate
% g.n_p = 42; % number of poles to simulate
% g.n_s = 36; % number of slots to simulate

g.s.material = 'M-19 Steel'; % Stator steel type
g.s.t_lam = .2; % Stator lamination thickness
g.s.stacking_factor = .928; % lamination stackign factor
g.r.magnet_type = 'N42'; % Rotor Magnet Type
g.r.backiron_material = '1018 Steel'; % Rotor Back Iron Material

% g.s.imap = ['A', 'b', 'b', 'C', 'C', 'a', ...
%             'a', 'B', 'B', 'c', 'c', 'A']; %  phase current to slot mapping
% g.s.imap = ['A', 'b', 'B', 'c', 'C', 'a']; %  phase current to slot mapping
g.s.imap = ['A', 'B', 'B', 'C', 'C', 'A']; %  phase current to slot mapping
g.s.idir = [+1, -1, +1, -1, +1, -1];
% 6N4P = ABC-ABC
g.s.imap = repmat(g.s.imap, 1, 8);
g.s.idir = repmat(g.s.idir, 1, 8);

g.s.span = 1; % number of slots spanned by each turn (typically 1 for concentrated winding, 3 for distributed
g.s.turns = 10;

g = calc_geometry(g);
