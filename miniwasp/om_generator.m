function geom_class = om_generator(r_out,r_in,w_cor,l_cc,d_cc,l_rhab,d_rhab_prox,d_rhab_dist,rns)

% calculations

r_cc = d_cc/2;
r_rhab_prox = d_rhab_prox/2;
r_rhab_dist = d_rhab_dist/2;

h1 = r_out - sqrt(r_out^2-r_cc^2);
x = r_cc - sqrt(r_in^2 - (r_in-w_cor+h1)^2);

% ommatidium structure

geom_class = struct;

geom_class.xylim = [-15,15,-26,4];
geom_class.ndomain = 5;
geom_class.ncurve = 10;
geom_class.lvert = 1;
geom_class.rvert = 4;
geom_class.rn = rns;
geom_class.lambda = 0.3800;
geom_class.mode = 'te';
geom_class.verts = [[-r_cc, -r_cc + x, r_cc - x, r_cc, -r_rhab_prox, r_rhab_prox, -r_rhab_dist, r_rhab_dist]; [0, 0, 0, 0, -l_cc, -l_cc, -l_cc - l_rhab, -l_cc - l_rhab]];

% curves

curve_1 = struct;

curve_1.curve_id = 1;
curve_1.vert_list = [4,1];
curve_1.curvetype = 2;
curve_1.theta = 2*asin(r_cc/r_out);
curve_1.ifconvex = 1;

curve_2 = struct;

curve_2.curve_id = 2;
curve_2.vert_list = [1,2];
curve_2.curvetype = 1;

curve_3 = struct;

curve_3.curve_id = 3;
curve_3.vert_list = [2,3];
curve_3.curvetype = 2;
curve_3.theta = 2*asin((r_cc-x)/r_in);
curve_3.ifconvex = 1;

curve_4 = struct;

curve_4.curve_id = 4;
curve_4.vert_list = [3,4];
curve_4.curvetype = 1;

curve_5 = struct;

curve_5.curve_id = 5;
curve_5.vert_list = [1,5];
curve_5.curvetype = 1;

curve_6 = struct;

curve_6.curve_id = 6;
curve_6.vert_list = [5,6];
curve_6.curvetype = 1;

curve_7 = struct;

curve_7.curve_id = 7;
curve_7.vert_list = [6,4];
curve_7.curvetype = 1;

curve_8 = struct;

curve_8.curve_id = 8;
curve_8.vert_list = [5,7];
curve_8.curvetype = 1;

curve_9 = struct;

curve_9.curve_id = 9;
curve_9.vert_list = [7,8];
curve_9.curvetype = 1;

curve_10 = struct;

curve_10.curve_id = 10;
curve_10.vert_list = [8,6];
curve_10.curvetype = 1;

geom_class.curves = {curve_1,curve_2,curve_3,curve_4,curve_5,curve_6,curve_7,curve_8,curve_9,curve_10};

% regions

region_1 = struct;

region_1.region_id = 1;
region_1.icurve_list = [-1];
region_1.is_inf = 1;

region_2 = struct;

region_2.region_id = 2;
region_2.icurve_list = [1,2,3,4];
region_2.is_inf = 0;

region_3 = struct;

region_3.region_id = 3;
region_3.icurve_list = [-4,-3,-2,5,6,7];
region_3.is_inf = 0;

region_4 = struct;

region_4.region_id = 4;
region_4.icurve_list = [-6,8,9,10];
region_4.is_inf = 0;

region_5 = struct;

region_5.region_id = 5;
region_5.icurve_list = [-7,-10,-9,-8,-5];
region_5.is_inf = -1;

geom_class.regions = {region_1,region_2,region_3,region_4,region_5};

% save geometry

save('miniwasp_om.mat','geom_class')

end