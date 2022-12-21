%%% T-Motor MN501-S KV300 Navigator %%%
%! Disclaimer: The following data is extrapolated from the information available on the manufacturer's product page. These data are not accurate and have not been acknowledged by the manufacturer. This data is only intended to roughly simulate the motor behavior and is not intended to reverse engineer the product.
% https://store.tmotor.com/goods.php?id=696
g.name = "MN501S";
g.nominal_speed = 5017; %RPM
g.peak_current = 40; %A

g.depth = 12.85; % axial length
g.s.slots = 24; % stator slots
g.s.r1 = 50; % tooth surface radius
g.s.r2 = 28.96; % radius at tooth root
g.s.r3 = 25.26; % backiron radius
g.s.t_pct = .28; % tooth fill percent
g.s.tip_pct = .707; % tooth tip fill percent
g.s.tip_l = .5; % Tooth tip length
g.s.tip_angle = pi / 24; % Tooth tip flare angle
g.s.ff = .5; % Slot fill-factor

g.r.ppairs = 14; % pole-pairs
g.r.r1 = 50.7; % rotor surface radius
g.r.r2 = 53.55; % back-iron radius, magnet side
g.r.r3 = 55.6; % backiron radius
g.r.m_pct = .62; % Magnet fill percent

% Smallest portion to simulate
% g.n_p = (g.r.ppairs*2)/gcd(g.s.slots ,g.r.ppairs*2); % number of poles to simulate
% g.n_s = g.s.slots /gcd(g.s.slots ,g.r.ppairs*2); % number of slots to simulate

g.s.material = 'M-19 Steel'; % Stator steel type
g.s.t_lam = .2; % Stator lamination thickness
g.s.stacking_factor = .928; % lamination stackign factor
g.r.magnet_type = 'N42'; % Rotor Magnet Type
g.r.backiron_material = '1018 Steel'; % Rotor Back Iron Material

% g.s.imap = ['AbBBbCccCaAAaBbbBcCCcAaa'];
% g.s.idir = [ +-++-+--+-++-+--+-++-+-- ];

g.s.imap = ['A', ...
        'B', 'B', 'B', 'B', ...
            'C', 'C', 'C', 'C', ...
            'A', 'A', 'A']; %  phase current to slot mapping
g.s.idir = [+1, -1, +1, +1, ...
            -1, +1, -1, -1];

% 24N28P = AbBBbCccCaAAaBbbBcCCcAaa|AbBBbCccCaAAaBbbBcCCcAaa
%         ABBBBCCCCAAA|ABBBBCCCCAAA|ABBBBCCCCAAA|ABBBBCCCCAAA
%        +-++-+--|+-++-+--|+-++-+--|+-++-+--|+-++-+--|+-++-+--
g.s.imap = repmat(g.s.imap, 1, 2 * 2);
g.s.idir = repmat(g.s.idir, 1, 2 * 3);

g.s.span = 1; % number of slots spanned by each turn
% (typically 1 for concentrated winding, 3 for distributed
g.s.turns = 100; %? Unknown

g = calc_geometry(g);
