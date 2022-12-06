clear all;
close all;

linecolor1 = ['k', 'b', 'c', 'g', 'y', 'r', 'm'];
linecolor2 = ['k', 'b', 'm', 'r', 'y', 'c', 'g'];
linecolor3 = ['m', 'k', 'b', 'c', 'g', 'y', 'r'];
linecolor6 = ['c', 'g', 'b', 'k', 'm', 'r'];

% Add folders to path
addpath("Motor Geometries");
addpath("femm_wrapper");

%U8; % Load motor geometry
%Walco; % Load motor geometry
%MN6007;
%test_outrunner;
MN4006;

ratio = 1; %6/26;
g.n_p = (g.r.ppairs * 2) * ratio; % number of poles to simulate
g.n_s = g.s.slots * ratio; % number of slots to simulate

Current = [0, 25, 50, 75, 100]; %[0 50 75 100 125 150 200 250] % Amps

niterat = 6 * 15
InitialAngle = 0; %360 / Nslots %? Why?
%StepAngle = (2 * pi / (g.r.ppairs)) * (2 / niterat);
StepAngle = (2 * pi / (g.r.ppairs)) * (1 / niterat)
% Phase_step = 0; %360/niterat;
k = 0;
Torque = 0;
step_vec = [];
torq_vec = [];
time_vec = [];
theta_elec = [];
% Phase_vec = [];
% Phase_max = [];
Torque_max = [];
Torque_avg = [];
Torque_min = [];
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
Mag_B_vec = [];
Mag_H_vec = [];
legend_text = [];

theta = linspace(0, pi * 2, niterat); % Sweep rotor angles from 0 to pi (electrical)

id = 0;
iq = 40; %9 * 40;
SpeedRPM = 2000 %RPM
Freq = (2 * g.r.ppairs) * SpeedRPM / 120 % Hz

% Check if 'exports' folder exists, else create it
[filepath, name, ext] = fileparts(mfilename('fullpath'));
% Ensure output is at the same level as script and not at Matlab current path
if ~exist(fullfile(filepath, "bmp_exports"), 'dir')
    mkdir(fullfile(filepath, "bmp_exports"))
end

if ~exist(fullfile(filepath, "results"), 'dir')
    mkdir(fullfile(filepath, "results"))
end

iter_vec = [];
step_vec = [];
torq_vec = [];
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
Mag_B_vec = [];
Mag_H_vec = [];
startiterat = 0;

openfemm;

tic

for j = 1:length(Current)
    startiterat = 0;

    if (startiterat == 0)

        if exist(fullfile(filepath, ['results/result_', g.name, '_', num2str(Current(j)), '.csv']), 'file')
            M = dlmread(['results/result_', g.name, '_', num2str(Current(j)), '.csv']);
            startiterat = int8(M(end, 1)) + 1;
            fprintf('Resuming from iteration %d\n', startiterat);

        end

    end

    for i = startiterat:niterat
        fprintf('Starting iteration %d %f\n', i, rad2deg(InitialAngle + StepAngle * i));

        if i == 0
            % Phase = Phase_init(j);
            time = 0;

            iter_vec = [];
            step_vec = [];
            torq_vec = [];
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
            Mag_B_vec = [];
            Mag_H_vec = [];
        end

        theta_elec = [theta_elec; init_geometry_4(g, InitialAngle - StepAngle * i, id, Current(j), 0)];

        fprintf('[%s] Geometry %d\n', datestr(now, 0), i);
        mi_analyze(1)
        fprintf('[%s] Analyzed %d\n', datestr(now, 0), i);
        mi_loadsolution
        fprintf('[%s] Loaded %d\n', datestr(now, 0), i);

        if save_images
            mo_showdensityplot(1, 0, 2, 0.0, 'mag');
            mo_setgrid(2, 'cart');
            mo_showvectorplot(1, 1);
            mo_hidepoints;

            if (i < niterat)
                mo_savebitmap(sprintf('bmp_exports/%s_%s.bmp', num2str(Current(j)), num2str(i, '%03d')));
            end

            mo_hidedensityplot();
            mo_hidecontourplot();
            mo_hidevectorplot();
        end

        % Record standard values
        iter_vec = [iter_vec, i];
        step_vec = [step_vec, InitialAngle + StepAngle * i];
        time_vec = [time_vec, time];
        % Phase_vec = [Phase_vec, Phase];

        % Update step
        time = time + 1 / Freq / niterat
        % Phase = Phase + Phase_step; % deg

        % Calc Torque
        torq_vec = [torq_vec, calc_torque(g)];

        % Calc B and H Magnet Fields
        [Mag_B, Mag_H] = calc_B_H_field(g, InitialAngle - StepAngle * i);
        Mag_B_vec = [Mag_B_vec, Mag_B];
        Mag_H_vec = [Mag_H_vec, Mag_H];

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

        %  mo_seteditmode('contour');
        %  mo_addcontour(StatorID/2,0);
        %  mo_addcontour(StatorOD/2,0);
        %  mo_makeplot(1,360*2);
        %  mo_makeplot(1,360*2,['/home/andrei/Data/MotorDesign_ToyotaPrius/IMG/B_field_',...
        %  num2str(j),'_',num2str(i),'.csv'],0);
        %  mo_clearcontour;

        % Measure stator B field tooth and B field back-iron
        [B_th_T, B_bi_T] = calc_B_tooth_backiron(g);
        B_tooth_T = [B_tooth_T, B_th_T];
        B_bkiron_T = [B_bkiron_T, B_bi_T];

        j
        i

        mo_close();
        mi_close();
        % closefemm();

        fprintf('Iteration %d took %f seconds\n', i, toc);

        % Save Results in CSV
        text1 = [iter_vec', step_vec', time_vec', PhA_vec_amps', PhB_vec_amps', PhC_vec_amps', ...
            PhA_vec_volts', PhB_vec_volts', PhC_vec_volts', ...
                PhA_vec_webs', PhB_vec_webs', PhC_vec_webs', ...
                torq_vec', B_tooth_T', B_bkiron_T', Mag_B_vec', -Mag_H_vec'];

        if (i == 0)
            fid = fopen(['results/result_', g.name, '_', num2str(Current(j)), '.csv'], 'w');
            fprintf(fid, 'iter,step,time,PhA_amps,PhB_amps,PhC_amps,PhA_volts,PhB_volts,PhC_volts,PhA_webs,PhB_webs,PhC_webs,torque,B_tooth_T,B_bkiron_T,Mag_B,neg_Mag_H\n');
            fclose(fid);
        end

        % Append last row
        dlmwrite(['results/result_', g.name, '_', num2str(Current(j)), '.csv'], text1(end, :), '-append');

    end

    % closefemm();
    toc

    [Torque] = max(torq_vec);
    Torque_max = [Torque_max, Torque];
    [Torque] = mean(torq_vec);
    Torque_avg = [Torque_avg, Torque];
    [Torque] = min(torq_vec);
    Torque_min = [Torque_min, Torque];
    % Phase_max = [Phase_max, Phase];

    % region plots
    figure(1)
    hold on
    plot(step_vec, PhA_vec_amps, 'linewidth', 2, '.-r')
    plot(step_vec, PhB_vec_amps, 'linewidth', 2, '.-g')
    plot(step_vec, PhC_vec_amps, 'linewidth', 2, '.-b')
    % plot(time_vec, PhA_vec_amps, 'linewidth', 2, '.-r')
    % plot(time_vec, PhB_vec_amps, 'linewidth', 2, '.-g')
    % plot(time_vec, PhC_vec_amps, 'linewidth', 2, '.-b')
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('Current [A]')
    legend('PhA', 'PhB', 'PhC')
    title('Phase currents')
    grid minor on
    %axis([0 max(step_vec)])
    %axis([0 max(time_vec)])

    figure(2)
    hold on
    plot(step_vec, PhA_vec_volts, 'linewidth', 2, '.-r')
    plot(step_vec, PhB_vec_volts, 'linewidth', 2, '.-g')
    plot(step_vec, PhC_vec_volts, 'linewidth', 2, '.-b')
    % plot(time_vec, PhA_vec_volts, 'linewidth', 2, '.-r')
    % plot(time_vec, PhB_vec_volts, 'linewidth', 2, '.-g')
    % plot(time_vec, PhC_vec_volts, 'linewidth', 2, '.-b')
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('Induced Voltage [V]')
    legend('PhA', 'PhB', 'PhC')
    title('Induced Phase Voltages')
    grid minor on
    %axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(3)
    hold on
    plot(step_vec, PhA_vec_webs, 'linewidth', 2, '.-r')
    plot(step_vec, PhB_vec_webs, 'linewidth', 2, '.-g')
    plot(step_vec, PhC_vec_webs, 'linewidth', 2, '.-b')
    % plot(time_vec, PhA_vec_webs, 'linewidth', 2, '.-r')
    % plot(time_vec, PhB_vec_webs, 'linewidth', 2, '.-g')
    % plot(time_vec, PhC_vec_webs, 'linewidth', 2, '.-b')
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('Flux Linkage [Wb]')
    legend('PhA', 'PhB', 'PhC')
    title('Phase Flux Linkages')
    grid minor on
    %axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(4)
    hold on
    plot(step_vec, torq_vec, 'linewidth', 2, '.-', 'color', linecolor1(mod(j, 7) + 1))
    % plot(time_vec, torq_vec, 'linewidth', 2, '.-', 'color', linecolor1(mod(j, 7) + 1))
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('Torque [Nm]')
    legend(num2str(Current'))
    title('Transient Torque')
    grid minor on
    %axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(5)
    hold on
    plot(step_vec, B_tooth_T, 'linewidth', 2, '.-', 'color', linecolor1(mod(j, 7) + 1))
    % plot(time_vec, B_tooth_T, 'linewidth', 2, '.-', 'color', linecolor1(mod(j, 7) + 1))
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('B field tooth [T]')
    legend(num2str(Current'))
    title('Stator Tooth B Field')
    grid minor on
    % axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(6)
    hold on
    plot(step_vec, B_bkiron_T, 'linewidth', 2, '.-', 'color', linecolor1(mod(j, 7) + 1))
    % plot(time_vec, B_bkiron_T, 'linewidth', 2, '.-', 'color', linecolor1(mod(j, 7) + 1))
    % xlabel('Time [sec]')
    xlabel('Angle [deg]')
    ylabel('B max field back-iron [T]')
    legend(num2str(Current'))
    title('Stator Back-Iron B Field')
    grid minor on
    % axis([0 max(step_vec)])
    % axis([0 max(time_vec)])

    figure(7)
    hold on
    %   plot(time_vec,Mag_B_vec)
    plot(-Mag_H_vec, Mag_B_vec, '.-', 'markersize', 12, 'color', linecolor1(mod(j, 7) + 1))
    legend_text = [legend_text; num2str(Current(j)), ' A'];
    legend(legend_text)

    % % Save Results in CSV
    % text1 = [step_vec', time_vec', PhA_vec_amps', PhB_vec_amps', PhC_vec_amps', ...
    %     PhA_vec_volts', PhB_vec_volts', PhC_vec_volts', ...
    %         PhA_vec_webs', PhB_vec_webs', PhC_vec_webs', ...
    %         torq_vec', B_tooth_T', B_bkiron_T', Mag_B_vec', -Mag_H_vec'];
    % fid = fopen(['results/result_', g.name, '_', num2str(Current(j)), '.csv'], 'w');
    % fprintf(fid, 'iter,step,time,PhA_amps,PhB_amps,PhC_amps,PhA_volts,PhB_volts,PhC_volts,PhA_webs,PhB_webs,PhC_webs,torque,B_tooth_T,B_bkiron_T,Mag_B,neg_Mag_H\n');
    % fclose(fid);
    % dlmwrite(['results/result_', g.name, '_', num2str(Current(j)), '.csv'], text1, '-append');
    % % csvwrite(['iron_losses_results/simresult_', num2str(Current(j)), '.csv'], text1)

    % endregion

    time = 0; %reset time to zero

end

closefemm;

% Build GIF animation
system(sprintf("python3 bmpexports2gif.py %s", g.name))
