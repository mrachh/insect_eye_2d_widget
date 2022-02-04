[file,path] = uigetfile('*.h5;*.mat', ...
     'Select a geometry file to load (*.h5 or *.mat)','MultiSelect',"off");
 fname = [path file];
 fprintf('Loading geometry\n');
 geom_class = clm.load_geom_gui(fname);
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

 [targdomain,tid] = clm.finddomain_gui(chnk_array, ...
      clmparams,targs);
 tid = unique(tid);
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
