clear all;
close all;

% Add folders to path
addpath('C:\femm42\mfiles'); % Common FEMM installation path
addpath('Motor Geometries');
addpath('femm_wrapper');

%% Setup motor configuration
% Load motor geometry
% Walco;
% MN6007;
% test_outrunner;
MN4006;
% MN501S;
% U8II;

% Smallest ratio to simulate the motor
ratio = 1 / gcd(g.s.slots, g.r.ppairs * 2);

g.n_p = (g.r.ppairs * 2) * ratio; % number of poles to simulate
g.n_s = g.s.slots * ratio; % number of slots to simulate

theta = 0; %pi / 6; %pi / 2; % Sweep rotor angles from 0 to pi (electrical)
theta_elec = [];
torque = [];

id = 0;
iq = 0; %9 * 40;

tic
%init_geometry_4(g, theta, id, iq, 0);
%save_geometry('temp');
%
%ratio = 2/3;
%g.n_p = (g.r.ppairs * 2) * ratio; % number of poles to simulate
%g.n_s = g.s.slots * ratio; % number of slots to simulate
%init_geometry_4(g, theta, id, iq, 0);
%save_geometry('temp');

% ratio = 1;
% g.n_p = (g.r.ppairs * 2) * ratio; % number of poles to simulate
% g.n_s = g.s.slots * ratio; % number of slots to simulate
init_geometry_4(g, theta, id, iq, 0);
save_geometry('temp');

% Get First Magnet position
% B_th_x =
% B_th_y =
% B_bi_x =
% B_bi_y =

% mi_addblocklabel(B_th_x, B_th_y)
% mi_selectlabel(B_th_x, B_th_y)
% mi_setblockprop('<No Mesh>', 1, 0, 'None', 0, 0, 0)
% mi_clearselected

% mi_addblocklabel(B_bi_x, B_bi_y)
% mi_selectlabel(B_bi_x, B_bi_y)
% mi_setblockprop('<No Mesh>', 1, 0, 'None', 0, 0, 0)
% mi_clearselected
g.s.pointlist

% B_th = mo_getb(StatorID / 2 + PostHeight / 2, 0);
% B_bi = mo_getb(StatorID / 4 + PostHeight / 2 + StatorOD / 4, 0);
% B_th_T = sign(B_th(1)) * sqrt(B_th(1)^2 + B_th(2)^2);
% B_bi_T = sign(B_bi(2)) * sqrt(B_bi(1)^2 + B_bi(2)^2);
% B_tooth_T = [B_tooth_T, B_th_T];
% B_bkiron_T = [B_bkiron_T, B_bi_T];

%t = calc_torque(g);
%% % [PhiA, Phia, PhiB, Phib, PhiC, Phic] = calc_circuits(g)
%mo_showdensityplot(0, 0, 2.5, 0, 'mag');
%mo_showvectorplot(1, 1);
%toc
%mo_savebitmap('output.bmp');

%for i=0:90
%  rotate_rotor(g, -theta);
%endfor
%closefemm;
