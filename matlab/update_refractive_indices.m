prompt = {'Update real part:', 'Update imaginary part'};
dlgtitle = 'Update refractive indices';

rr = real(clmparams.rn);
ri = imag(clmparams.rn);
rr = rr(:).';
ri = ri(:).';
rr_str = num2str(rr);
ri_str = num2str(ri);
definput = {rr_str,ri_str};
l1 = length(rr_str);
l2 = length(ri_str);
lmax = max(l1,l2);
dims = [1,ceil(lmax+20)];

answer2 = inputdlg(prompt,dlgtitle,dims,definput);

rr = str2num(answer2{1});
ri = str2num(answer2{2});

opts = [];
rn = rr(:) + 1j*ri(:);
opts.rn = rn;
if(norm(opts.rn-clmparams.rn)>1e-14) 
  fprintf('Updating refractive indices\n');
  clmparams = clm.update_clmparams(clmparams,opts);
  fprintf('Updating chunkie object\n');
  chnk_array = clm.get_geom_clmparams(clmparams);

%   fprintf('Updating skeletonization structs\n');
%   eps = 0.5e-5;
%    [fw_factors,pp_factors] = mwscripts.skeletonize_im(chnk_array, ...
%      clmparams,targs,targdomain,eps);
  mwscripts.update_rhs();
  mwscripts.update_uinc();
  is_mat_current = false;
else
   fprintf('Difference too small: nothing to update\n');
end
clear rr ri l1 l2 prompt dlgtitle definput answer2 opts

