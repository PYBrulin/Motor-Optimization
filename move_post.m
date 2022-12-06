pi = 3.141592
len_stack = 1 % unit length
deg = 1 % moving degree of rotor [deg.]
coil_turn = 48 % total conductor number

handle = openfile("rpm.dat", "r") % to open motor speed file:1000 rpm
rpm = read(handle, "\n")
closefile(handle)

handle = openfile("weber.txt", "r") % to open magnetic flux data saved in previous step
phi0 = read(handle, "\n")
closefile(handle)

handle = openfile("angle.txt", "r") % to open moving angle of rotor
ini_ang = read(handle, "\n")
closefile(handle)

handle = openfile("bemf.dat", "a")
groupselectblock(1)
A1 = blockintegral(1) % to calculate of average vector potention in coil area
clearblock()
groupselectblock(2)
A2 = blockintegral(1)
area = blockintegral(5)
clearblock()
phi = (A2 - A1) * len_stack / area

% 1 Deg .= 0.01745 Radian
unit_bemf = (-1) * (phi - phi0) / 0.01745 * rpm * pi / 30 * coil_turn
write(handle, ini_ang, " ", phi, " ", unit_bemf, "\n")
closefile(handle)

handle = openfile("weber.txt", "w")
write(handle, phi, "\n")
closefile(handle)

% exitpost()
