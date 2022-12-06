%! Only usable when drawing full motor for now (Since we measure the first magnet)
function [Mag_B, Mag_H] = calc_B_H_field(g, theta)
    fprintf('[%s] Measuring B and H fields\n', datestr(now, 0));

    % Get First Magnet position
    R1 = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    p1 = R1' * mean([g.r.p3; g.r.p5])';
    mag_x1 = p1(1);
    mag_y1 = p1(2);

    % Calc B and H Magnet Fields
    Magnet_B = mo_getb(mag_x1, mag_y1);
    Magnet_H = mo_geth(mag_x1, mag_y1);
    Mag_B = sqrt(Magnet_B(1)^2 + Magnet_B(2)^2);
    Mag_H = sqrt(Magnet_H(1)^2 + Magnet_H(2)^2);

    mo_clearblock;

end
