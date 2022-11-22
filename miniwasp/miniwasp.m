%% initialization

clear all;
close all;

%% startup

cd('../../chunkie/')
startup();

cd('../insect_eye_2d_widget/')
startup();

cd('miniwasp/')

%% ommatidia parameters

% handwritten note geometry parameters

r_out = 3.33;
r_in = 0.86;
w_cor = 1.89;
l_cc = 3.58;
d_cc = 4.14;
l_rhab = 13.91;
d_rhab_prox = 1.84;
d_rhab_dist = 1.17;

% indices of refraction

i_outside = 1;
i_lens = 1.452;
i_cone = 1.348;
i_rhab = 1.363;
i_pig = 1.34 + 0.1i;

rns = [[i_outside]; [i_lens]; [i_cone]; [i_rhab]; [i_pig]];

%% generate ommatdia geometry;

om_generator(r_out,r_in,w_cor,l_cc,d_cc,l_rhab,d_rhab_prox,d_rhab_dist,rns);

load_geometry();

%% solve

solve();
compute_average_energy();

%% plot_energy

plot_energy();

%% plots

wavelength = 380;
direction = 0;
lambda = wavelength/1000;
opts.lambda = lambda;
clmparams = clm.update_clmparams(clmparams,opts);
chnk_array = clm.get_geom_clmparams(clmparams);
is_mat_current = false;
dir_radians = direction*2*pi/360.0+pi/2;
mwscripts.update_rhs();
mwscripts.update_uinc();
solve();
plot_energy();

%% change angle

direction = 10;
dir_radians = direction*2*pi/360.0+pi/2;
mwscripts.update_rhs();
mwscripts.update_uinc();
solve();
plot_energy();

%% solve for the energy

wave_lengths = 380:90:650;
incident_directions = 0:1:30;

num_wavelengths = length(wave_lengths);
num_directions = length(incident_directions);
num_regions = 5;
avg_energies = zeros(num_wavelengths,num_directions,num_regions);
max_energies = zeros(num_wavelengths,num_directions,num_regions);

solve();
compute_average_energy();

for cint_wave = 1:num_wavelengths
    wavelength = wave_lengths(cint_wave);
    lambda = wavelength/1000;
    opts.lambda = lambda;
    clmparams = clm.update_clmparams(clmparams,opts);
    chnk_array = clm.get_geom_clmparams(clmparams);
    is_mat_current = false;
    for cint_dir = 1:num_directions
         direction = incident_directions(cint_dir);
         dir_radians = direction*2*pi/360.0+pi/2;
         mwscripts.update_rhs();
         mwscripts.update_uinc();
         solve();
         compute_average_energy();

         for j = 1:num_regions
             avg_energies(cint_wave,cint_dir,j) = avg_energy(j);
             max_energies(cint_wave,cint_dir,j) = max_energy(j);
         end
    end
end
cd('../')

%% figures

regions = ["outside","lens","cone","rhabdom","pigment"];

figure('outer',[10,10,800,400])

for n_wave = 1:num_wavelengths
    for n_region = 1:num_regions
        subplot(num_wavelengths,5,(n_wave-1)*num_regions+n_region)
        plot(incident_directions,avg_energies(n_wave,:,n_region))
        hold on
        plot(incident_directions,max_energies(n_wave,:,n_region))
        hold off
        
        grid on
        ylim([0,15])
        if n_wave==1
            title(regions(n_region))
        end
        if n_wave==num_wavelengths
            xlabel('angle \theta')
        end
        if n_region==1
            ylabel(['\lambda = ',num2str(wave_lengths(n_wave)),'nm'])
        end
    end
end

%% rhabdom

figure('outer',[100,100,200,400])

for n_wave = 1:num_wavelengths
    subplot(num_wavelengths,1,n_wave)
    plot(incident_directions,avg_energies(n_wave,:,4))
%     hold on
%     plot(incident_directions,max_energies(n_wave,:,4))
%     hold off
    grid on
    ylim([0,5])
    if n_wave==1
        title('rhabdom')
    end
    if n_wave==num_wavelengths
        xlabel('angle \theta')
    end
    ylabel(['\lambda = ',num2str(wave_lengths(n_wave)),'nm'])
end