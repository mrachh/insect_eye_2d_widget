fprintf('Updating incident field\n');
[~,m] = size(targs);
uinc = zeros(m,1);
uincgrad = zeros(2,m);
idomup = find(clmparams.is_inf == 1);
idomdown = find(clmparams.is_inf == -1);
for i=1:clmparams.ndomain
    if(~isempty(targlist{i}))
        if(i == idomup || i == idomdown)
            [uinc(targlist{i}),gtmp] = ...
    clm.planewavetotal_gui(clmparams.k(idomup),dir_radians, ...
    clmparams.k(idomdown),targs(:,targlist{i}),clmparams.is_inf(i), ...
    idomup,idomdown,clmparams.coef);
            uincgrad(:,targlist{i}) = gtmp.';
        end
    end

end
uinc = reshape(uinc,[1,m]);
fprintf('Incident field updated\n');