avg_energy = zeros(1,clmparams.ndomain);
max_energy = zeros(1,clmparams.ndomain);
[~,m] = size(targs);
zztarg = nan(size(xxtarg)) + 1i*nan(size(xxtarg));
zztarg_grad = nan(2,m) + 1j*nan(2,m);
nr_region = zeros(1,m);
for i=1:clmparams.ndomain
   if(~isempty(targlist{i}))
      nr_region(targlist{i}) = clmparams.rn(i);
   end
end

if ~isempty(uinc) && ~isempty(uscat)
    zztarg = uinc + uscat;
    zztarg_grad = uincgrad + ugrad;
end



zztarg = reshape(zztarg,size(xxtarg));

if(strcmpi(clmparams.mode,'te'))
  zztarg_plot_test = (abs(zztarg_grad(1,:)).^2 + ...
       abs(zztarg_grad(2,:)).^2)*clmparams.lambda^2/4/pi^2./abs(nr_region).^2 + ... 
       abs(zztarg(:).').^2;
else

    zztarg_plot_test = (abs(zztarg_grad(1,:)).^2 + ...
       abs(zztarg_grad(2,:)).^2)*clmparams.lambda^2/4/pi^2 + ... 
       abs(zztarg(:).').^2.*abs(nr_region).^2;
end

for i=1:clmparams.ndomain
    avg_energy(i) = mean(zztarg_plot_test(targlist{i}));
    max_energy(i) = max(zztarg_plot_test(targlist{i}));
end
