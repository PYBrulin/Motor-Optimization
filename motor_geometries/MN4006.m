%%% T-Motor MN4006 KV380 antiGravity %%%
% https://store.tmotor.com/goods.php?id=440
g.name = "MN4006";
g.nominal_speed = 6000; %RPM
g.peak_current = 16; %A

g.depth = 8; % axial length
g.s.slots = 18; % stator slots
g.s.r1 = 40.8; % tooth surface radius
g.s.r2 = 20.5; % radius at tooth root
g.s.r3 = 17.3; % backiron radius
g.s.t_pct = .28; % tooth fill percent
g.s.tip_pct = .707; % tooth tip fill percent
g.s.tip_l = .5; % Tooth tip length
g.s.tip_angle = pi / 24; % Tooth tip flare angle
g.s.ff = .5; % Slot fill-factor

g.r.ppairs = 12; % pole-pairs
g.r.r1 = 41.00; % rotor surface radius
g.r.r2 = 42.35; % back-iron radius, magnet side
g.r.r3 = 44.35; % backiron radius
g.r.m_pct = .62; % Magnet fill percent

% Smallest portion to simulate
% g.n_p = (g.r.ppairs*2)/gcd(g.s.slots ,g.r.ppairs*2); % number of poles to simulate
% g.n_s = g.s.slots /gcd(g.s.slots ,g.r.ppairs*2); % number of slots to simulate

g.s.material = 'M-19 Steel'; % Stator steel type
g.s.t_lam = .2; % Stator lamination thickness
g.s.stacking_factor = .928; % lamination stackign factor
g.r.magnet_type = 'N42'; % Rotor Magnet Type
g.r.backiron_material = '1018 Steel'; % Rotor Back Iron Material

g.s.imap = ['A', ...
            'B', 'B', ...
            'C', 'C', ...
        'A']; %  phase current to slot mapping
g.s.idir = [+1, -1];
% 18N24P = ABC-ABC-ABC-ABC-ABC-ABC
g.s.imap = repmat(g.s.imap, 1, 6);
g.s.idir = repmat(g.s.idir, 1, 6 * 3);

g.s.span = 1; % number of slots spanned by each turn
% (typically 1 for concentrated winding, 3 for distributed
g.s.turns = 100;

g = calc_geometry(g);
