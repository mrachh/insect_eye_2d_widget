prompt = {'Update wavenumber (in nm):'};
dlgtitle = 'Update wavenumber';

definput = {num2str(clmparams.lambda*1000)};
dims = [1,50];

answer2 = inputdlg(prompt,dlgtitle,dims,definput);

lambda = str2num(answer2{1})/1000;
opts.lambda = lambda;
if(norm(opts.lambda-clmparams.lambda)>1e-14) 
  fprintf('Updating wavenumber\n');
  clmparams = clm.update_clmparams(clmparams,opts);
  fprintf('Updating chunkie object\n');
  chnk_array = clm.get_geom_clmparams(clmparams);
  is_mat_current = false;
  mwscripts.update_rhs();
  mwscripts.update_uinc();
else
   fprintf('Difference too small: nothing to update\n');
end
clear prompt dlgtitle definput answer2 opts

