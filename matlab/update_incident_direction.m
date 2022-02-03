prompt = {'Update incident direction (in degrees):'};
dlgtitle = 'Update incident direction';

definput = {num2str(direction)};
dims = [1,50];

answer2 = inputdlg(prompt,dlgtitle,dims,definput);

direction = str2num(answer2{1});
dir_radians = direction*2*pi/360.0+pi/2;
mwscripts.update_rhs();
mwscripts.update_uinc();
clear prompt dlgtitle definput answer2 
