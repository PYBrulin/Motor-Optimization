function [PhA, PhB, PhC] = calc_circuits(g)
    fprintf('[%s] Measuring circuits\n', datestr(now, 0));

    PhA = mo_getcircuitproperties('A');
    PhB = mo_getcircuitproperties('B');
    PhC = mo_getcircuitproperties('C');

    mo_clearblock;

end
