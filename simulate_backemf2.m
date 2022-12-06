clear all;
close all;

U8; % Load motor geometry
%Walco; % Load motor geometry
%MN6007;
test_outrunner;
%MN4006;

ratio = 1; %6/26;
g.n_p = (g.r.ppairs * 2) * ratio; % number of poles to simulate
g.n_s = g.s.slots * ratio; % number of slots to simulate

niterat = 50
theta = linspace(0, pi * 2, niterat); % Sweep rotor angles from 0 to pi (electrical)
theta_elec = [];
torque = [];

id = 0;
iq = 40; %9 * 40;

% Current = 10 % Amps
% Turns = 117
% Phase = 120 % deg
% SpeedRPM = 1000 %RPM
% Freq = Npoles * SpeedRPM / 120 % Hz

step_vec = [];
torq_vec = [];
time_vec = [];
PhA_vec = [];
PhB_vec = [];
PhC_vec = [];

% Check if 'exports' folder exists, else create it
[filepath, name, ext] = fileparts(mfilename('fullpath'));
% Ensure output is at the same level as script and not at Matlab current path
if ~exist(fullfile(filepath, "bmp_exports"), 'dir')
    mkdir(fullfile(filepath, "bmp_exports"))
end

tic

init_geometry_2(g, theta(1), id, iq, 0)
save_geometry("temp")

for i = 1:length(theta) - 1
    fprintf('Starting iteration %d %f\n', i, rad2deg(theta(i)));
    tic

    if (i > 1)
        rotate_rotor(g, -theta(i - 1));
        rotate_rotor(g, theta(i));
        update_circuits(g, theta(i), id, iq);
    end

    theta_elec = [theta_elec; theta(i)];

    fprintf('[%s] Geometry %d\n', datestr(now, 0), i);

    torq_vec = [torq_vec, calc_torque(g)]
    fprintf('[%s] Torque %d\n', datestr(now, 0), i);

    % mo_showdensityplot(0, 0, 2.5, 0, 'mag');
    % mo_hidepoints;
    % mo_savebitmap(sprintf('bmp_exports/%s.bmp', num2str(i, '%03d')));
    % mi_close();
    % mo_close();
    % fprintf('Iteration %d took %f seconds\n', i, toc);

    % Curr_PhA = Current * sin(2 * pi * Freq * time + Phase * pi / 180);
    % Curr_PhB = Current * sin(2 * pi * Freq * time + Phase * pi / 180 + 2 * pi / 3);
    % Curr_PhC = Current * sin(2 * pi * Freq * time + Phase * pi / 180 + 4 * pi / 3);
    % mi_modifycircprop('A', 1, Curr_PhA)
    % mi_modifycircprop('B', 1, Curr_PhB)
    % mi_modifycircprop('C', 1, Curr_PhC)

    Curr_PhA = mo_getcircuitproperties('A')(1);
    Curr_PhB = mo_getcircuitproperties('B')(1);
    Curr_PhC = mo_getcircuitproperties('C')(1);

    % mi_saveas('ToyotaPrius.FEM')
    % mi_clearselected
    % mi_createmesh;
    % mi_analyze(0);
    % mi_loadsolution;
    mo_showdensityplot(1, 0, 2, 0.0, 'mag');
    mo_setgrid(2, 'cart');
    mo_showvectorplot(1, 1);
    mo_hidepoints;
    %mo_showmesh;
    %mo_zoom(1.5,-1.2,6.5,1.0)

    % mo_groupselectblock(2);
    % mo_groupselectblock(3);
    % Torque = mo_blockintegral(22);
    % mo_clearblock

    step_vec = [step_vec, theta(i)]
    % torq_vec = [torq_vec, Torque];
    % time_vec = [time_vec, time];
    PhA_vec = [PhA_vec, Curr_PhA]
    PhB_vec = [PhB_vec, Curr_PhB]
    PhC_vec = [PhC_vec, Curr_PhC]

    % time = time + 1 / Freq / niterat;

    figure(1)
    subplot(2, 1, 1)
    hold on
    plot(step_vec, PhA_vec, '.-')
    plot(step_vec, PhB_vec, '.-')
    plot(step_vec, PhC_vec, '.-')
    xlabel('Angle [deg]')
    % plot(time_vec, PhA_vec, '.-')
    % plot(time_vec, PhB_vec, '.-')
    % plot(time_vec, PhC_vec, '.-')
    % xlabel('time [sec]')
    ylabel('Current [A]')
    legend('PhA', 'PhB', 'PhC')
    grid minor on
    hold off
    subplot(2, 1, 2)
    plot(step_vec, torq_vec, '.-', 'color', 'b')
    xlabel('Angle [deg]')
    ylabel('Torque [Nm]')
    legend('Torque [Nm]')
    % plot(time_vec, torq_vec, '.-', 'color', 'b')
    % xlabel('time [sec]')
    % ylabel('Torque [Nm]')
    % legend('Torque [Nm]')
    grid minor on

    if (i == 1)
        text = 'Angle [deg],Torque [Nm],CurrentA (A),CurrentB (A),CurrentC (A)';
        %write header to file
        fid = fopen(["simresult_", g.name, ".csv"], 'w');
        fprintf(fid, '%s\n', text)
        fclose(fid)
    end

    text = [step_vec(end), torq_vec(end), PhA_vec(end), PhB_vec(end), PhC_vec(end)];
    dlmwrite(sprintf("simresult_%s.csv", g.name), text, "-append")

    % Save Bitmap
    mo_savebitmap(['bmp_exports/', num2str(i, '%03d'), '.bmp']);

    % mi_close();
    % mo_close();
    fprintf('Iteration %d took %f seconds\n', i, toc);
    pause(1);
end

closefemm();
toc

% Build GIF animation
system(sprintf("python3 bmpexports2gif.py %s", g.name))

figure;
plot(theta_elec, torque);
xlabel('Electrical Angle');
ylabel('Torque (N-m)');
NicePlot;
average_torque = mean(torque)
torque_ripple = max(abs(torque - average_torque))
rms_torque_ripple = rms(torque - average_torque)
