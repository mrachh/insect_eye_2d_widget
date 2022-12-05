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

%% test different pigments

wave_lengths = 380:90:650;
incident_directions = 0:1:30;

rnis = [0.0001i,0.001i,0.01i,0.1i];

num_wavelengths = length(wave_lengths);
num_directions = length(incident_directions);
num_regions = 5;
num_pig = length(rnis);
   
avg_energies = zeros(num_wavelengths,num_directions,num_regions,num_pig);
max_energies = zeros(num_wavelengths,num_directions,num_regions,num_pig);

for cint_pig = 1:num_pig
   
    i_pig = 1.34 + rnis(cint_pig);
    
    display(i_pig);
    
    rns = [[i_outside]; [i_lens]; [i_cone]; [i_rhab]; [i_pig]];
    
    om_generator(r_out,r_in,w_cor,l_cc,d_cc,l_rhab,d_rhab_prox,d_rhab_dist,rns);

    load_geometry();
        
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
             
             if direction == 5
                 test_accuracy();
             end

             for cint_reg = 1:num_regions
                 avg_energies(cint_wave,cint_dir,cint_reg,cint_pig) = avg_energy(cint_reg);
                 max_energies(cint_wave,cint_dir,cint_reg,cint_pig) = max_energy(cint_reg);
             end
        end
    end
end

%% figures

figure('outer',[100,100,200,num_wavelengths*200])

for cint_wave = 1:num_wavelengths
   
    subplot(num_wavelengths,1,cint_wave)
    
    hold on
    for cint_pig = 1:num_pig
        plot(incident_directions,avg_energies(cint_wave,:,4,cint_pig))
    end    
    hold off
            
    title(['\lambda = ',num2str(wave_lengths(cint_wave)),'nm'])

    if cint_wave==num_wavelengths
        xlabel('angle \theta')
    end
    
    ylabel('average energy')
    
    grid on
    legend('0.0001i','0.001i','0.01i','0.1i')

end