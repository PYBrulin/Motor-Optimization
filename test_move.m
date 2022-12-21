% Backemf simulation using FEMM 4.2 (Finite Element Method Magnetics)
% Note: It is recommended to use this script on Windows where it is much
%   more robust. The following script tends to crash a lot when using
%   Wine (on Linux). Several backups have been added to avoid losing
%   the execution steps of the simulation, but some scenarios could
%   still block the execution completely.

clear all;
close all;

save_images = true;
hidewindow = 0; % % 0 = show FEMM window, 1 = hide FEMM window (Recommended to leave it to 0)

% Add folders to path
addpath('C:\femm42\mfiles'); % Common FEMM installation path on Windows (change accordingly)
addpath('functions');
addpath('motor_geometries');
addpath('femm_wrapper');

%% Setup motor configuration
% Load motor geometry
% Walco;
% MN6007;
% test_outrunner;
MN4006;
% MN501S;
% U8II;

%% Choose the ratio of the motor to simulate (Comment the appropriate line)
% Ratio of the motor to simulate (1 = Full motor)
ratio = 1;
% Or...
% Below is the smallest ratio possible to simulate the motor
% which depends on the common denominator of the number of slots and poles
ratio = 1 / gcd(g.s.slots, g.r.ppairs * 2);

%% Select number of iterations to simulate for each current
niterat = 10; % Arbitrary for now

%% ! No variables should be edited past this point !

%% Simple test to check if the ratio is valid
Current = [0]; % Amps

% Record the ratio in the name of the motor
if ratio < 1
    g.name = append(g.name, '_', num2str(ratio));
end

% Number of poles and slots to simulate
g.n_p = (g.r.ppairs * 2) * ratio; % number of poles to simulate
g.n_s = g.s.slots * ratio; % number of slots to simulate

% Nominal current of the motor
id = 0;
iq = g.peak_current;

% Nominal mechanical speed of the rotor
SpeedRPM = g.nominal_speed; %RPM

% Electrical frequency
Freq = (2 * g.r.ppairs) * SpeedRPM / 120; % Hz

%% Setup simulation configuration
InitialAngle = 0;
StepAngle = (2 * pi / (g.r.ppairs)) * (1 / niterat);

if ratio < 1
    % If ratio < 1 start from the end
    InitialAngle = (2 * pi / (g.r.ppairs));
end

% Phase_step = 0; %360/niterat;
theta = linspace(0, pi * 2, niterat); % Sweep rotor angles from 0 to pi (electrical)

%% Setup output directories
% Check if 'results' and 'bmp_exports' folders exist, else create them
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

if ~exist(fullfile(filepath, sprintf('results/%s', g.name)), 'dir')
    mkdir(fullfile(filepath, sprintf('results/%s', g.name)))
end

%% Initialize variables
Torque = 0;
startiterat = 0;

%% Start simulation
openfemm;

%% Setup motor geometry
try
    init_geometry(g, InitialAngle - StepAngle * startiterat, id, Current(1), 0);
catch
    % On Linux, segmentation fault happen often when initializing geometry
    fprintf('[%s] Caught Exception - Initializing Geometry\n', datestr(now, 0))
end

for i = startiterat:niterat
    fprintf('[%s] Starting iteration %d/%d (%.2f°) - %.2f%%\n', datestr(now, 0), j, i, rad2deg(InitialAngle + StepAngle * i), 100 * ((j -1) * (i / niterat) / length(Current)));

    tic

    if i == 0
        % Re-initialize variables if we are changing currents values
        % Phase = Phase_init(j);
        time = 0;
    else
        % Rotate the geometry by StepAngle
        time = startiterat * (1 / Freq / niterat);

        if ratio < 1
            closefemm;
            pause(0.5); % Sleep for 0.5 second to let FEMM catch up
            init_geometry(g, InitialAngle - StepAngle * i, id, Current(1), 0);
        else
            rotate_rotor(g, StepAngle);
        end

        % Sleep for 0.5 second to let FEMM catch up
        pause(2);
    end

    fprintf('[%s] Geometry %d\n', datestr(now, 0), i);

    % mo_close();

    fprintf('[%s] Iteration %d took %08.3f seconds\n', datestr(now, 0), i, toc);

end

%% Current evaluation as ended.
% Close FEMM for next iteration
closefemm;

fprintf('[%s] Ended\n', datestr(now, 0))
