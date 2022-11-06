function dom_buffers = compute_domain_buffer(chnkr,clmparams,opts)
% This subroutine computes a buffer region around each domain
% outside of which the solution is known to be accurate

  if(nargin == 2)
      opts = [];
  end
  ncurve = clmparams.ncurve;
  ndomain = clmparams.ndomain;
  k = clmparams.ngl;
  [~,w] = lege.exps(k);

  hpanmax = zeros(ncurve,1);
  for i=1:ncurve
    zp = sqrt(chnkr(i).d(1,:).^2+chnkr(i).d(2,:).^2);
    hs = chnkr(i).h;
    ws = kron(hs(:),w(:));
    dsdt = zp(:).*ws(:);
    dsdt = reshape(dsdt,[k,chnkr(i).nch]);
    hpanmax(i) = max(sum(dsdt));  
  end
  
  fac = 0.3;
  if(isfield(opts,'fac'))
      fac = opts.fac;
  end
  
  dom_buffers = zeros(1,ndomain);
  for j=1:ndomain
    if(clmparams.is_inf(j) == 0)
      dom_buffers(j) = fac*max(hpanmax(abs(clmparams.clist{j})));
    end
  end
      
end