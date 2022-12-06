clear all;

%U8; % Load motor geometry
%Walco; % Load motor geometry
MN4006;

ratio = 1; %6/26;
g.n_p = (g.r.ppairs * 2) * ratio; % number of poles to simulate
g.n_s = g.s.slots * ratio; % number of slots to simulate

theta = linspace(.001, .99 * pi, 21); % Sweep rotor angles from 0 to pi (electrical)
theta_elec = [];
torque = [];

id = 0;
iq = 40; %9 * 40;

% Check if 'exports' folder exists, else create it
[filepath, name, ext] = fileparts(mfilename('fullpath'));
% Ensure output is at the same level as script and not at Matlab current path
if ~exist(fullfile(filepath, "bmp_exports"), 'dir')
    mkdir(fullfile(filepath, "bmp_exports"))
end

tic

for i = 1:length(theta)
    fprintf('Starting iteration %d\n', i);
    tic
    theta_elec = [theta_elec; init_geometry_2(g, theta(i), id, iq, 0)];
    fprintf('[%s] Geometry %d\n', datestr(now, 0), i);
    torque = [torque; calc_torque(g)];
    fprintf('[%s] Torque %d\n', datestr(now, 0), i);
    mo_showdensityplot(0, 0, 2.5, 0, 'mag');
    mo_hidepoints;
    mo_savebitmap(sprintf('bmp_exports/%s.bmp', num2str(i, '%03d')));
    mi_close();
    mo_close();
    fprintf('Iteration %d took %f seconds\n', i, toc);
end

closefemm();
toc

figure;
plot(theta_elec, torque);
xlabel('Electrical Angle');
ylabel('Torque (N-m)');
NicePlot;
average_torque = mean(torque)
torque_ripple = max(abs(torque - average_torque))
rms_torque_ripple = rms(torque - average_torque)
