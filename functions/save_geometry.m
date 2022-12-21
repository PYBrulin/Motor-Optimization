function save_geometry(name)
    fem_name = sprintf([name, '.fem']);
    mi_saveas(fem_name);
    fprintf('[%s] Saved temp FEMM file\n', datestr(now, 0));
end
