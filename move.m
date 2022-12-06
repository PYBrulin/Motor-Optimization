pi = 3.141592;

for theta = 0:180:1
    open_femm_file("design.fem")
    seteditmode("group")
    selectgroup(11)
    move_rotate(0, 0, theta)
    save_femm_file("temp.fem")
    analyse()

    handle = openfile("angle.txt", "w") % For saving angle data [deg.]
    write(handle, theta, "\n")
    closefile(handle)

    % ???
    handle = openfile("weber.txt", "w") % to save magnetic flux data
    phi0 = read(handle, "\n")
    closefile(handle)
    % ???

    runpost("move_post.lua") % Post processing lua
end
