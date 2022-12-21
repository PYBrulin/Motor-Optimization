%%% Create Motor Geometry in FEMM %%%
function [torque, theta_elec] = simulate_geometry(g, theta, id, iq)
    %%% motor geometry struct g, rotor angle theta, d-axis current id, q-axis
    %%% current iq
    delta_theta_rm = theta;
    theta = theta / g.r.ppairs;

    openfemm;
    newdocument(0); % 0 = magnetics, 1 = electrostatics, etc..
    Freq = 0;
    mi_probdef(Freq, 'millimeters', 'planar', 1.e-8, g.depth, 30);

    n_s = 6; % number of stator teeth to simulate
    n_p = 7; % number of poles to simulate

    % Draw the Stator Teeth %
    addnodelist_group(g.s.pointlist, 'stator', 1);
    addsegmentlist_group(g.s.segmentlist, 'stator', 1, 1);
    addarclist_group(g.s.arclist, 'stator', 2, 1);

    mi_selectgroup(1);
    mi_mirror(0, 0, g.s.p7(1), g.s.p7(2));
    mi_selectgroup(1);
    mi_copyrotate([0, 0], -rad2deg(g.s.theta), n_s - 1);

    % Draw Stator Back-iron %
    addnode_group(g.s.boundary_point, 'stator_backiron', 3);
    mi_selectgroup(3);
    mi_copyrotate([0, 0], -rad2deg(g.s.theta * n_s), 1);
    R = [cos(g.s.theta * n_s) -sin(g.s.theta * n_s); sin(g.s.theta * n_s) cos(g.s.theta * n_s)];
    p2 = R' * g.s.boundary_point';
    addarc_group(g.s.boundary_point, p2', [0, 0], 'stator_backiron', 10, 3);

    % Draw rotor %
    addnodelist_group(g.r.pointlist, 'rotor', 2);
    addsegmentlist_group(g.r.segmentlist, 'rotor', 1, 2);
    addarclist_group(g.r.arclist, 'rotor', 10, 2);

    mi_selectgroup(2);
    mi_mirror(0, 0, g.r.p2(1), g.r.p2(2));
    mi_selectgroup(2);
    mi_copyrotate([0, 0], -rad2deg(g.r.theta), n_p - 1);
    mi_selectgroup(2);
    mi_moverotate([0, 0], -rad2deg(theta));

    % Draw rotor back-iron %
    R1 = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    R2 = [cos(g.r.theta * n_p + theta) -sin(g.r.theta * n_p + theta); sin(g.r.theta * n_p + theta) cos(g.r.theta * n_p + theta)];
    p1 = R1' * g.r.boundary_point';
    p2 = R2' * g.r.boundary_point';
    addnode_group(p1, 'rotor_backiron', 4);
    mi_selectgroup(4);
    mi_copyrotate([0, 0], -rad2deg(g.r.theta * n_p), 1);
    addarc_group(p1', p2', [0, 0], 'rotor_backiron', 10, 4);

    % Add Materials %
    mi_getmaterial('Air'); % air
    mi_getmaterial('N42'); % permanent magnet
    % mi_addmaterial('A', 1, 1, 0, 0);
    % mi_addmaterial('a', 1, 1, 0, 0);
    % mi_addmaterial('B', 1, 1, 0, 0);
    % mi_addmaterial('b', 1, 1, 0, 0);
    % mi_addmaterial('C', 1, 1, 0, 0);
    % mi_addmaterial('c', 1, 1, 0, 0);
    mi_addmaterial('wire', 1, 1, 0, 0);
    %mi_getmaterial('Hiperco-50');          % armature material: Cobalt Iron
    mi_getmaterial('M-19 Steel'); % Stator Laminations
    mi_getmaterial('1018 Steel'); % Rotor Back Iron
    mi_modifymaterial('M-19 Steel', 9, 0); % Set stator lamination stacking factor
    mi_modifymaterial('M-19 Steel', 6, .2);
    mi_modifymaterial('M-19 Steel', 8, .928);

    % Add Magnet Labels %'
    R3 = [cos(g.r.theta) -sin(g.r.theta); sin(g.r.theta) cos(g.r.theta)];
    p1 = R1' * mean([g.r.p3; g.r.p5])';
    m_sign = 1;
    theta_m = atan2(p1(2), p1(1));

    for x = 1:n_p
        addblocklabel(p1, 'N42', 0, '<None>', '<None>', rad2deg(theta_m), 2, 0);
        p1 = R3' * p1;
        m_sign = -m_sign; % flip north/south magnets
        theta_m = atan2(m_sign * p1(2), m_sign * p1(1));
    end

    % Add Phase Currents %
    % Apply D/Q axis currents, transform to phase currents %
    abc = @(theta) [cos(-theta), sin(-theta), 1 / sqrt(2);
                cos((2 * pi / 3) - theta), sin((2 * pi / 3) - theta), 1 / sqrt(2);
                cos((-2 * pi / 3) - theta), sin((-2 * pi / 3) - theta), 1 / (sqrt(2))];
    theta_a = atan2(g.s.p6(2), g.s.p6(1)); % Phase A center angle
    p1 = R1' * mean([g.r.p3; g.r.p5])';
    theta_m = atan2(p1(2), p1(1)); % Magnet  angle
    theta_elec = (theta_m - theta_a) * g.r.ppairs - pi / 2;
    abc_transform = abc(theta_elec); % Invers dq0 transform
    i_abc = abc_transform * [id; iq; 0];
    i_phase = [i_abc(1), i_abc(2), i_abc(3)]; %j*[cos(-theta); -cos(theta + 2*pi/3); -cos(theta-2*pi/3)];
    %i_phase = iq*[-.5; -.5; 1];

    i_map = ['A', 'A', 'a', 'B', 'b', 'b', 'B', 'c', 'C', 'C', 'c', 'A'];

    mi_addcircprop('A', i_phase(1), 1);
    mi_addcircprop('a', -i_phase(1), 1);
    mi_addcircprop('B', i_phase(2), 1);
    mi_addcircprop('b', -i_phase(2), 1);
    mi_addcircprop('C', i_phase(3), 1);
    mi_addcircprop('c', -i_phase(3), 1);

    % Add Phase Labels %
    R4 = [cos(g.s.theta), -sin(g.s.theta); sin(g.s.theta), cos(g.s.theta)];
    p1 = mean([g.s.p4; g.s.p9; g.s.p6; g.s.p5])';
    p2 = mirror_point_about_line(p1, g.s.p6);

    for x = 1:n_s
        addblocklabel(p1, 'wire', 0, '<None>', i_map(2 * x - 1), 0, 1, 1);

        p1 = R4' * p1;
    end

    for x = 1:n_s
        addblocklabel(p2, 'wire', 0, '<None>', i_map(2 * x), 0, 1, 1);
        p2 = R4' * p2;
    end

    % Add steel and airgap labels %
    p1 = mean([g.s.p5; g.s.p6; g.s.p7; g.s.p8])';
    p2 = R1' * R3' * mean([g.r.p2; g.r.p3])';
    p3 = mean([g.s.p2; g.s.p3; g.s.p9]);
    addblocklabel(p1, 'M-19 Steel', 0, '<None>', '<None>', 0, 1, 0); % stator steel
    addblocklabel(p2, '1018 Steel', 0, '<None>', '<None>', 0, 2, 0); % rotor back iron
    addblocklabel(p3, 'Air', 0, '<None>', '<None>', 0, 0, 0); % airgap

    % Draw Boundaries and Set Boundary Conditions %
    muo = pi * 4.e-7;
    Rbd = 1e-3 * max(2 * [g.s.r3, g.r.r3]);
    mi_addboundprop('Asymptotic', 0, 0, 0, 0, 0, 0, 1 / (muo * Rbd), 0, 2);

    R5 = [cos(n_s * g.s.theta), -sin(n_s * g.s.theta); sin(n_s * g.s.theta), cos(n_s * g.s.theta)];
    p1 = [0; g.r_airgap];
    p2 = R2' * p1;
    p3 = R5' * p1;
    p4 = R1' * p1;
    mi_addnode(p1);
    mi_addnode(p2');
    mi_addnode(p3');
    mi_addnode(p4');
    addsegment_group(g.s.p8, g.s.p1, 'stator_boundary', 1, 6)
    addsegment_group([R5' * [0; g.s.r3]]', [R5' * [0; g.s.r1]]', 'stator_boundary', 1, 6)
    addsegment_group(p3, [R5' * [0; g.s.r1]]', 'airgap_vertical_1', 1, 7)
    addsegment_group(g.s.p1, p1, 'airgap_vertical_1', 1, 7)
    addsegment_group([R1' * [0; g.r.r3]], [R1' * [0; g.r.r2]], 'rotor_boundary', 1, 8);
    addsegment_group([R2' * [0; g.r.r3]], [R2' * [0; g.r.r2]], 'rotor_boundary', 1, 8);
    addsegment_group(p4, [R1' * [0; g.r.r2]], 'airgap_vertical_2', 1, 9);
    addsegment_group(p2, [R2' * [0; g.r.r2]], 'airgap_vertical_2', 1, 9);
    addarc_group(p1', p4', [0, 0], 'airgap_horizontal', 10, 10);
    addarc_group(p3', p2', [0, 0], 'airgap_horizontal', 10, 10);

    % Airgap BC
    mi_clearselected()
    mi_addboundprop('airgap_radius', 0, 0, 0, 0, 0, 0, 0, 0, 5);
    mi_selectgroup(10);
    mi_setarcsegmentprop(10, 'airgap_radius', 0, 10);
    mi_clearselected()
    mi_addboundprop('airgap_vertical_1', 0, 0, 0, 0, 0, 0, 0, 0, 5);
    mi_selectgroup(7);
    mi_setsegmentprop('airgap_vertical_1', 1, 0, 0, 7);
    mi_clearselected()
    mi_addboundprop('airgap_vertical_2', 0, 0, 0, 0, 0, 0, 0, 0, 5);
    mi_selectgroup(9);
    mi_setsegmentprop('airgap_vertical_2', 1, 0, 0, 9);

    % Stator Yoke  BC
    mi_clearselected()
    mi_selectgroup(3);
    mi_setarcsegmentprop(10, 'Asymptotic', 0, 1);

    % Rotor Backiron BC
    mi_clearselected()
    mi_selectgroup(4);
    mi_setarcsegmentprop(10, 'Asymptotic', 0, 2);

    % Stator Side BC
    mi_clearselected()
    mi_addboundprop('stator_boundary', 0, 0, 0, 0, 0, 0, 0, 0, 5);
    mi_selectgroup(6);
    mi_setsegmentprop('stator_boundary', 1, 0, 0, 1);

    %Rotor Side BC
    mi_clearselected()
    mi_addboundprop('rotor_boundary', 0, 0, 0, 0, 0, 0, 0, 0, 5);
    mi_selectgroup(8);
    mi_setsegmentprop('rotor_boundary', 1, 0, 0, 2);

    % mi_clearselected()
    % mi_selectgroup(4);  % Rotor backiron
    %addsegment_group()

    fem_name = sprintf('test.fem');
    mi_saveas(fem_name);
    mi_analyze
    mi_loadsolution

    %mo_selectblock(mean([g.s.p5; g.s.p6; g.s.p7; g.s.p8])'); %stator
    % mo_groupselectblock(2);
    % torque = (2*g.r.ppairs/n_p)*mo_blockintegral(22)
    % mo_clearblock;
    mo_groupselectblock(1);
    torque = (2 * g.r.ppairs / n_p) * mo_blockintegral(22);
    mo_clearblock;

    mi_zoomnatural;
end
