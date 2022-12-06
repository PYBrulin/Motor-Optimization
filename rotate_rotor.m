%! This function is unusable when not drawing the full motor
%! This is caused by the lack of flexibility of the drawn air boundaries,
%! which might either not follow the rotor,
%! or completely mess up the model by trying to connect to the nearest node
function rotate_rotor(g, step_theta)

    %%% motor geometry struct g, rotor step angle step_theta
    % theta = step_theta / g.r.ppairs;

    mi_clearselected();
    mi_selectgroup(2);
    mi_selectgroup(12);

    % mi_selectgroup(8); %rotor_boundary
    % mi_selectgroup(10); %rotor_airgap

    % mi_selectgroup(4); % Rotor Backiron BC
    % mi_selectgroup(19); %rotor_air_side
    % mi_selectgroup(20); %rotor_air_side
    mi_moverotate(0, 0, rad2deg(step_theta)); %rad2deg(-step_theta)); %? negative? Linked to the current displacment?
    fprintf('[%s] Rotor advanced by %f°\n', datestr(now, 0), rad2deg(step_theta));

    % mi_clearselected();
end
