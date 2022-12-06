% Backemf simulation using FEMM 4.2 (Finite Element Method Magnetics)
% Note: It is recommended to use this script on Windows where it is much
%   more robust. The following script tends to crash a lot when using
%   Wine (on Linux). Several backups have been added to avoid losing
%   the execution steps of the simulation, but some scenarios could
%   still block the execution completely.

clear all;
close all;

linecolor1 = ['k', 'b', 'c', 'g', 'y', 'r', 'm'];
linecolor2 = ['k', 'b', 'm', 'r', 'y', 'c', 'g'];
linecolor3 = ['m', 'k', 'b', 'c', 'g', 'y', 'r'];
linecolor6 = ['c', 'g', 'b', 'k', 'm', 'r'];

save_images = true;
hidewindow = 0;

% Add folders to path
addpath('C:\femm42\mfiles'); % Common FEMM installation path
addpath('Motor Geometries');
addpath('femm_wrapper');

%% Setup motor configuration
% Load motor geometry
% Walco;
% MN6007;
% test_outrunner;
% MN4006;
MN501S;
% U8II;

% Ratio of the motor to simulate (1 = Full motor)
ratio = 1;
% ratio = 1 / gcd(g.s.slots, g.r.ppairs * 2); % Smallest ratio to simulate the motor

g.n_p = (g.r.ppairs * 2) * ratio; % number of poles to simulate
g.n_s = g.s.slots * ratio; % number of slots to simulate

% Range of currents to simulate
Current = linspace(0, g.peak_current, 5); % Amps
id = 0;
iq = g.peak_current;
% Nominal mechanical speed of the rotor
SpeedRPM = g.nominal_speed; %RPM
% Electrical frequency
Freq = (2 * g.r.ppairs) * SpeedRPM / 120; % Hz

%% Setup simulation configuration
niterat = 10 * 14; % Arbitrary for now
InitialAngle = 0; %360 / Nslots %? Why?
%StepAngle = (2 * pi / (g.r.ppairs)) * (2 / niterat);
StepAngle = (2 * pi / (g.r.ppairs)) * (1 / niterat);
% Phase_step = 0; %360/niterat;
theta = linspace(0, pi * 2, niterat); % Sweep rotor angles from 0 to pi (electrical)

%% Setup output directories
% Check if 'exports' folder exists, else create it
[filepath, name, ext] = fileparts(mfilename('fullpath'));
% Ensure output is at the same level as script and not at Matlab current path
if ~exist(fullfile(filepath, 'bmp_exports'), 'dir')
    mkdir(fullfile(filepath, 'bmp_exports'))
end

if ~exist(fullfile(filepath, sprintf('bmp_exports/%s', g.name)), 'dir')
    mkdir(fullfile(filepath, sprintf('bmp_exports/%s', g.name)))
end

if ~exist(fullfile(filepath, 'results'), 'dir')
    mkdir(fullfile(filepath, 'results'))
end

%% Initialize variables
Torque = 0;
legend_text = {};
iter_vec = [];
step_vec = [];
torq_vec = [];
current_vec = [];
Torque_max = [];
Torque_avg = [];
Torque_min = [];
time_vec = [];
theta_elec = [];
% Phase_vec = [];
PhA_vec_amps = [];
PhB_vec_amps = [];
PhC_vec_amps = [];
PhA_vec_volts = [];
PhB_vec_volts = [];
PhC_vec_volts = [];
PhA_vec_webs = [];
PhB_vec_webs = [];
PhC_vec_webs = [];
B_tooth_T = [];
B_bkiron_T = [];
B_airgap_T = [];
Mag_B_vec = [];
Mag_H_vec = [];
startiterat = 0;
retry_times = 0;

%% Start simulation
openfemm;

j = 1;
while j<=length(Current)
    startiterat = 0;

    if (startiterat == 0)

        while ((j < length(Current)) ...
            && (exist(fullfile(filepath, sprintf('results/result_%s_%08.3f.csv', g.name, Current(j))), 'file'))  ...
            && (exist(fullfile(filepath, sprintf('results/result_%s_%08.3f.csv', g.name, Current(j+1))), 'file')))
            fprintf('[%s] Found result file %s\n', datestr(now, 0), fullfile(filepath, sprintf('results/result_%s_%08.3f.csv', g.name, Current(j))));
            j = j + 1;
        end

        result_file = sprintf('results/result_%s_%08.3f.csv', g.name, Current(j));
        result_file = fullfile(filepath, result_file);
        
        if exist(result_file, 'file')
            fprintf('[%s] Found last result file %s\n', datestr(now, 0), result_file);

            %M = dlmread(result_file);
            M = readmatrix(result_file);
            startiterat = M(end, 1) + 1;

            if (startiterat > niterat)
                fprintf('[%s] Measurement already completed for %s at %f A\n', datestr(now, 0), g.name, Current(j));
                j = j + 1;
                continue;
            else
                fprintf('[%s] Resuming from iteration %d for %s at %f A\n', datestr(now, 0), startiterat, g.name, Current(j));
            end

        end

    end

    %% Safeguard layer
    % Wine crashes a lot of times during the execution of this script.
    % The following code helps keep track of the number of times the
    % current simulation has been executed and reads it if it reaches the maximum limit.
    state_file = sprintf('results/state_%s.txt', g.name);

    if exist(fullfile(filepath, state_file), 'file')
        M = readmatrix(state_file);
        last_iterat = M(end, 1);
        retry_times = M(end, 2);
        fprintf('[%s] last_iterat %d / startiterat %d / retry_times %d\n', datestr(now, 0), last_iterat, startiterat, retry_times);

        if (last_iterat == startiterat)

            if (retry_times > 2)
                fprintf('[%s] Max number of retry reached. Avoiding this step\n', datestr(now, 0));
                startiterat = startiterat +1;
                continue;
            end

            retry_times = retry_times + 1;

        else
            retry_times = 0;
        end

    else
        retry_times = 0;
    end

    fid = fopen(state_file, 'w');
    fprintf(fid, '%d,%d\n', startiterat, retry_times);
    fclose(fid);

    %% Setup motor geometry
    try
        init_geometry_4(g, InitialAngle - StepAngle * startiterat, id, Current(j), 0);
    catch
        % This exception often gets caught on Linux due to FEMM having segmentation fault here.
        fprintf('[%s] Caught Exception - Initializing Geometry\n', datestr(now, 0))
    end

    for i = startiterat:niterat
        fprintf('[%s] Starting iteration %d/%d (%.2f°) - %.2f%%\n', datestr(now, 0), j, i, rad2deg(InitialAngle + StepAngle * i), 100 * ((j -1) * (i / niterat) / length(Current)));

        tic

        if i == 0
            % Re-initialize variables if we are changing currents values
            % Phase = Phase_init(j);
            time = 0;

            iter_vec = [];
            step_vec = [];
            torq_vec = [];
            current_vec = [];
            Torque_max = [];
            Torque_avg = [];
            Torque_min = [];
            time_vec = [];
            theta_elec = [];
            % Phase_vec = [];
            PhA_vec_amps = [];
            PhB_vec_amps = [];
            PhC_vec_amps = [];
            PhA_vec_volts = [];
            PhB_vec_volts = [];
            PhC_vec_volts = [];
            PhA_vec_webs = [];
            PhB_vec_webs = [];
            PhC_vec_webs = [];
            B_tooth_T = [];
            B_bkiron_T = [];
            B_airgap_T = [];
            Mag_B_vec = [];
            Mag_H_vec = [];
        else
            % Rotate the geometry by StepAngle
            time = startiterat * (1 / Freq / niterat);
            rotate_rotor(g, StepAngle);
        end

        theta_elec = [theta_elec; update_circuits(g, InitialAngle - StepAngle * i, id, Current(j))];

        fprintf('[%s] Geometry %d\n', datestr(now, 0), i);
        mi_analyze(1)
        fprintf('[%s] Analyzed %d\n', datestr(now, 0), i);
        mi_loadsolution
        fprintf('[%s] Loaded %d\n', datestr(now, 0), i);

        try

            if save_images
                mo_showdensityplot(1, 0, 2, 0.0, 'mag');
                mo_setgrid(2, 'cart');
                mo_showvectorplot(1, 1);
                mo_hidepoints;

                if (i < niterat)
                    mo_savebitmap(sprintf('bmp_exports/%s/%08.3f_%03d.bmp', g.name, Current(j), i));
                end

                % mo_hidedensityplot();
                % mo_hidecontourplot();
            end

        catch
            fprintf('[%s] Caught Exception - Saving Picture\n', datestr(now, 0))
        end

        try
            mi_purgemesh;
        catch
            fprintf('[%s] Caught Exception - Purging Mesh\n', datestr(now, 0))
        end

        % Record standard values
        iter_vec = [iter_vec, i];
        step_vec = [step_vec, InitialAngle + StepAngle * i];
        time_vec = [time_vec, time];
        current_vec = [current_vec, Current(j)];
        % Phase_vec = [Phase_vec, Phase];

        % Update step
        time = time + 1 / Freq / niterat;
        % Phase = Phase + Phase_step; % deg

        try
            % Calc Torque
            torq_vec = [torq_vec, calc_torque(g)];
        catch
            fprintf('[%s] Caught Exception - Mesuring Torque\n', datestr(now, 0))
        end

        try
            % Calc B and H Magnet Fields
            [Mag_B, Mag_H] = calc_B_H_field(g, InitialAngle - StepAngle * i);
            Mag_B_vec = [Mag_B_vec, Mag_B];
            Mag_H_vec = [Mag_H_vec, Mag_H];
        catch
            fprintf('[%s] Caught Exception - Measuring B and H fields\n', datestr(now, 0))
        end

        try
            % Measure Circuits properties
            [PhA, PhB, PhC] = calc_circuits(g);
            PhA_vec_amps = [PhA_vec_amps, PhA(1, 1)];
            PhB_vec_amps = [PhB_vec_amps, PhB(1, 1)];
            PhC_vec_amps = [PhC_vec_amps, PhC(1, 1)];
            PhA_vec_volts = [PhA_vec_volts, PhA(1, 2)];
            PhB_vec_volts = [PhB_vec_volts, PhB(1, 2)];
            PhC_vec_volts = [PhC_vec_volts, PhC(1, 2)];
            PhA_vec_webs = [PhA_vec_webs, PhA(1, 3)];
            PhB_vec_webs = [PhB_vec_webs, PhB(1, 3)];
            PhC_vec_webs = [PhC_vec_webs, PhC(1, 3)];
        catch
            fprintf('[%s] Caught Exception - Measuring Circuits\n', datestr(now, 0))
        end

        % mo_seteditmode('contour');
        % mo_addcontour(StatorID/2,0);
        % mo_addcontour(StatorOD/2,0);
        % mo_makeplot(1,360*2);
        % mo_makeplot(1,360*2,['/home/andrei/Data/MotorDesign_ToyotaPrius/IMG/B_field_',...
        % num2str(j),'_',num2str(i),'.csv'],0);
        % mo_clearcontour;

        try
            % Measure stator B field tooth and B field back-iron
            [B_th_T, B_bi_T, B_air_T] = calc_B_tooth_backiron(g);
            B_tooth_T = [B_tooth_T, B_th_T];
            B_bkiron_T = [B_bkiron_T, B_bi_T];
            B_airgap_T = [B_airgap_T, B_air_T];
        catch
            fprintf('[%s] Caught Exception - Measuring stator B fields\n', datestr(now, 0))
        end

        % mo_close();

        fprintf('[%s] Iteration %d took %08.3f seconds\n', datestr(now, 0), i, toc);

        %% Save Results in CSV
        try
            text1 = [iter_vec', step_vec', time_vec', current_vec', PhA_vec_amps', PhB_vec_amps', PhC_vec_amps', ...
                    PhA_vec_volts', PhB_vec_volts', PhC_vec_volts', ...
                    PhA_vec_webs', PhB_vec_webs', PhC_vec_webs', ...
                    torq_vec', B_tooth_T', B_bkiron_T', B_airgap_T', Mag_B_vec', -Mag_H_vec'];

            if (i == 0)
                fid = fopen(result_file, 'w');
                fprintf(fid, 'iter,step,time,current,PhA_amps,PhB_amps,PhC_amps,PhA_volts,PhB_volts,PhC_volts,PhA_webs,PhB_webs,PhC_webs,torque,B_tooth_T,B_bkiron_T,B_airgap_T,Mag_B,neg_Mag_H\n');
                fclose(fid);
            end

            % Append last row
            dlmwrite(result_file, text1(end, :), '-append');
        catch
            fprintf('[%s] Caught Exception - Saving Results\n', datestr(now, 0))
        end

    end

    closefemm;

    [Torque] = max(torq_vec);
    Torque_max = [Torque_max, Torque];
    [Torque] = mean(torq_vec);
    Torque_avg = [Torque_avg, Torque];
    [Torque] = min(torq_vec);
    Torque_min = [Torque_min, Torque];
    % Phase_max = [Phase_max, Phase];

    %% region plots
    figure(1)
    hold on
    plot(step_vec, PhA_vec_amps, '.-r', 'linewidth', 2)
    plot(step_vec, PhB_vec_amps, '.-g', 'linewidth', 2)
    plot(step_vec, PhC_vec_amps, '.-b', 'linewidth', 2)
    % plot(time_vec, PhA_vec_amps, '.-r', 'linewidth', 2)
    % plot(time_vec, PhB_vec_amps, '.-g', 'linewidth', 2)
    % plot(time_vec, PhC_vec_amps, '.-b', 'linewidth', 2)
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('Current [A]')
    legend('PhA', 'PhB', 'PhC')
    title('Phase currents')
    grid minor
    grid on
    %axis([0 max(step_vec)])
    %axis([0 max(time_vec)])

    figure(2)
    hold on
    plot(step_vec, PhA_vec_volts, '.-r', 'linewidth', 2)
    plot(step_vec, PhB_vec_volts, '.-g', 'linewidth', 2)
    plot(step_vec, PhC_vec_volts, '.-b', 'linewidth', 2)
    % plot(time_vec, PhA_vec_volts, '.-r', 'linewidth', 2)
    % plot(time_vec, PhB_vec_volts, '.-g', 'linewidth', 2)
    % plot(time_vec, PhC_vec_volts, '.-b', 'linewidth', 2)
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('Induced Voltage [V]')
    legend('PhA', 'PhB', 'PhC')
    title('Induced Phase Voltages')
    grid minor
    grid on
    %axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(3)
    hold on
    plot(step_vec, PhA_vec_webs, '.-r', 'linewidth', 2)
    plot(step_vec, PhB_vec_webs, '.-g', 'linewidth', 2)
    plot(step_vec, PhC_vec_webs, '.-b', 'linewidth', 2)
    % plot(time_vec, PhA_vec_webs, '.-r', 'linewidth', 2)
    % plot(time_vec, PhB_vec_webs, '.-g', 'linewidth', 2)
    % plot(time_vec, PhC_vec_webs, '.-b', 'linewidth', 2)
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('Flux Linkage [Wb]')
    legend('PhA', 'PhB', 'PhC')
    title('Phase Flux Linkages')
    grid minor
    grid on
    %axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(4)
    hold on
    plot(step_vec, torq_vec, '.-', 'linewidth', 2, 'color', linecolor1(mod(j, 7) + 1))
    % plot(time_vec, torq_vec, '.-', 'linewidth', 2, 'color', linecolor1(mod(j, 7) + 1))
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('Torque [Nm]')
    legend(num2str(Current'))
    title('Transient Torque')
    grid minor
    grid on
    %axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(5)
    hold on
    plot(step_vec, B_tooth_T, '.-', 'linewidth', 2, 'color', linecolor1(mod(j, 7) + 1))
    % plot(time_vec, B_tooth_T, '.-', 'linewidth', 2, 'color', linecolor1(mod(j, 7) + 1))
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('B field tooth [T]')
    legend(num2str(Current'))
    title('Stator Tooth B Field')
    grid minor
    grid on
    % axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(6)
    hold on
    plot(step_vec, B_bkiron_T, '.-', 'linewidth', 2, 'color', linecolor1(mod(j, 7) + 1))
    % plot(time_vec, B_bkiron_T, '.-', 'linewidth', 2, 'color', linecolor1(mod(j, 7) + 1))
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('B max field back-iron [T]')
    legend(num2str(Current'))
    title('Stator Back-Iron B Field')
    grid minor
    grid on
    % axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(7)
    hold on
    plot(step_vec, B_airgap_T, '.-', 'linewidth', 2, 'color', linecolor1(mod(j, 7) + 1))
    % plot(time_vec, B_bkiron_T, '.-', 'linewidth', 2, 'color', linecolor1(mod(j, 7) + 1))
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('B max field airgap [T]')
    legend(num2str(Current'))
    title('Stator Airgap B Field')
    grid minor
    grid on
    % axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(8)
    hold on
    % plot(time_vec,Mag_B_vec)
    plot(-Mag_H_vec, Mag_B_vec, '.-', 'markersize', 12, 'color', linecolor1(mod(j, 7) + 1))
    legend_text{end + 1} = sprintf('%08.3f A', Current(j));
    legend(legend_text)
    % endregion

    time = 0; %reset time to zero

    %mo_close();
    %mi_close();

end

fprintf('[%s] Ended\n', datestr(now, 0))
