function theta_elec = update_circuits(g, theta, id, iq)
    fprintf('[%s] Updating currents\n', datestr(now, 0));

    %%% motor geometry struct g,
    %%% rotor angle theta,
    %%% d-axis current id,
    %%% q-axis current iq
    % theta = theta / g.r.ppairs;

    % Add Phase Currents %
    % Apply D/Q axis currents, transform to phase currents %
    R1 = [cos(theta) -sin(theta); sin(theta) cos(theta)];
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

    mi_modifycircprop('A', 1, i_phase(1));
    % mi_modifycircprop('a', 1, -i_phase(1));
    mi_modifycircprop('B', 1, i_phase(2));
    % mi_modifycircprop('b', 1, -i_phase(2));
    mi_modifycircprop('C', 1, i_phase(3));
    % mi_modifycircprop('c', 1, -i_phase(3));

    mi_clearselected()
end
