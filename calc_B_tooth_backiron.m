%! Only usable when drawing full motor for now (Since we measure the first stator which is cut in half if not fully drawn)
function [B_th_T, B_bi_T, B_air_T] = calc_B_tooth_backiron(g)
    fprintf('[%s] Measuring stator B-fields\n', datestr(now, 0));

    % g.s.p1 % Tooth end
    % g.s.p5 % BackIron start
    % g.r.r1 % rotor surface radius
    B_th = mo_getb(0, g.s.p5(2) + (g.s.p1(2) - g.s.p5(2)) / 2);
    B_bi = mo_getb(0, g.s.p5(2));
    B_air = mo_getb(0, g.s.p5(2) + abs(g.s.p1(2) - g.r.r1) / 2);

    B_th_T = sign(B_th(1)) * sqrt(B_th(1)^2 + B_th(2)^2);
    B_bi_T = sign(B_bi(2)) * sqrt(B_bi(1)^2 + B_bi(2)^2);
    B_air_T = B_air(1); % radial

    mo_clearblock;

end
