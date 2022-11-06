%% Initialize geometry 
geom_class = clm.read_geom_clm10();
 clmparams = clm.setup_geom(geom_class);
 
 
 chnk_array = clm.get_geom_clmparams(clmparams);
 fprintf('Initializing targets\n');
 
 nregions = clmparams.ndomain;
 ngr = clmparams.ngr;       % field evaluation at ngr^2 points
 xylim=clmparams.xylim;  % computational domain
 xtarg = linspace(xylim(1),xylim(2),ngr);
 ytarg = linspace(xylim(3),xylim(4),ngr);
 plot_geom();
 [xxtarg,yytarg] = meshgrid(xtarg,ytarg);
 targs = zeros(2,length(xxtarg(:)));
 targs(1,:) = xxtarg(:);
 targs(2,:) = yytarg(:);
 [~,ntarg] = size(targs); 
 clear xtarg ytarg 
 
 opts_flag = [];
 opts_flag.fac = 0.3;
 [targdomain,tid,flags] = clm.finddomain_gui(chnk_array, ...
      clmparams,targs,opts_flag); tid = unique(tid);
  
 ntid = setdiff(1:ntarg,tid);
 targlist = cell(1,nregions);
 for i=1:nregions
    targlist{i} = find(targdomain==i);
 end
 
 dir_radians = pi/2;
 direction = 0;
 mwscripts.update_uinc();
 mwscripts.update_rhs();
 is_mat_current = false;
 
 
 fprintf('Initialize geometry complete\n');
 
%% Update wavenumber 
 lambda = 0.5;
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
%% update incident direction
  run update_incident_direction.m
 
 %% Solve 
 run solve.m
 
 %% plot energy
 run plot_energy.m
 
 %% Compute average and max energies
 run compute_average_energy.m
 
 %% Test accuracy
 run test_accuracy.m

 %% Get domain buffers: needed for accurate computation of energy cs
 
 dom_buffers = mwscripts.compute_domain_buffer(chnk_array,clmparams);
 
 %% Compute energy cross sections in rhabdom
 
irhabdom = 5; % set domain corresponding to rhabdom
nleg = 100; % set number of points in each direction
run get_rhabdom_energy_cross_section.m