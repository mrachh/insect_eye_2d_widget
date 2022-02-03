opts_rhs = [];
opts_rhs.itype = 2;
opts_rhs.alpha = dir_radians;
fprintf('Updating rhs\n');
rhs = clm.get_rhs_gui_clm_cases(chnk_array, ...
    clmparams,clmparams.npts,clmparams.alpha1,clmparams.alpha2,opts_rhs);
clear opts_rhs
disp('updated rhs')