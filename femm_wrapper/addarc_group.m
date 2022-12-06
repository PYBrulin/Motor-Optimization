function addarc_group(end_point, start_point, center_point, propname, maxseg, groupno)

    radius = .5 * norm(center_point - start_point) + .5 * norm(center_point - end_point);
    l = norm(start_point - end_point);

    n1 = (end_point - center_point) / norm(end_point - center_point);
    n2 = (start_point - center_point) / norm(start_point - center_point);

    angle = atan2d(n1(2), n1(1)) - atan2d(n2(2), n2(1));
    sign_angle = sign(angle);

    if (angle < 0)
        angle = angle + 360;
    end

    % angle, sign_angle

    if (abs(angle) <= 180)
        center_direction = mean([start_point; end_point]) - center_point;
        center_direction = center_direction / norm(center_direction);
        % center_direction

        mi_addarc(start_point(1), start_point(2), end_point(1), end_point(2), angle, maxseg);

        % if (sign_angle > 0)
        arc_center = center_point + radius * center_direction;
        % else
        %     arc_center = center_point - radius * center_direction;
        % end

        % arc_center

        mi_selectarcsegment(arc_center);
        maxsegdeg = angle / maxseg;
        mi_setarcsegmentprop(maxsegdeg, propname, 0, groupno);

    else

        center_direction = mean([start_point; end_point]) - center_point;
        center_direction = center_direction / norm(center_direction);

        if (angle < 180)
            arc_center_point = center_point + radius * center_direction;
        else
            arc_center_point = center_point - radius * center_direction;
        end

        % addarc angle property can only take a value between 0 and 180 degree
        % We need to cut the arc in half when the angle is bigger than 180
        addnode_group(arc_center_point, 'arc', groupno);
        mi_addarc(start_point(1), start_point(2), arc_center_point(1), arc_center_point(2), angle / 2, maxseg);
        mi_addarc(arc_center_point(1), arc_center_point(2), end_point(1), end_point(2), angle / 2, maxseg);

        %% First segment ===
        center_direction = mean([start_point; arc_center_point]) - center_point;
        center_direction = center_direction / norm(center_direction);

        if (angle < 180)
            arc_center = center_point + radius * center_direction;
        else
            arc_center = center_point - radius * center_direction;
        end

        mi_selectarcsegment(arc_center);
        maxsegdeg = abs(angle) / maxseg;
        mi_setarcsegmentprop(maxsegdeg, propname, 0, groupno);

        %% Second segment ===
        if (angle < 359) % Check if we are actually a whole circle or not

            center_direction = mean([arc_center_point; end_point]) - center_point;
            center_direction = center_direction / norm(center_direction);

            if (angle < 180)
                arc_center = center_point + radius * center_direction;
            else
                arc_center = center_point - radius * center_direction;
            end

            % arc_center

            mi_selectarcsegment(arc_center);
            maxsegdeg = abs(angle) / maxseg;
            mi_setarcsegmentprop(maxsegdeg, propname, 0, groupno);

        else % if we are doing a full circle connect second arc back to the start point

            center_direction = mean([arc_center_point; start_point]) - center_point;
            center_direction = center_direction / norm(center_direction);

            if (angle < 180)
                arc_center = center_point + radius * center_direction;
            else
                arc_center = center_point - radius * center_direction;
            end

            mi_selectarcsegment(arc_center);
            maxsegdeg = abs(angle) / maxseg;
            mi_setarcsegmentprop(maxsegdeg, propname, 0, groupno);
        end

    end

end
