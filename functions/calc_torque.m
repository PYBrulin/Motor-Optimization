function torque = calc_torque(g)
    fprintf('[%s] Measuring torque\n', datestr(now, 0));
    mi_loadsolution

    mo_clearblock;

    mo_groupselectblock(1); % stator laminations
    mo_groupselectblock(11); % stator windings
    torque = (2 * g.r.ppairs / g.n_p) * mo_blockintegral(22);

    mo_clearblock;

end
