function [U,varargout] = hfmm2d(eps,zk,srcinfo,pg,varargin)
%
%
%  This subroutine computes the N-body Helmholtz
%  interactions and its gradients in two dimensions where 
%  the interaction kernel is given by $i/4 H_{0}^{(1)}kr)$, with
%  $H_{0}^{(1)}$ being the Hankel function of the first kind of order
%  0
% 
%    u(x) = \frac{i}{4}\sum_{j=1}^{N} c_{j} H_{0}(k\|x-x_{j}\|) - d_{j} v_{j}
%    \cdot \nabla \left( H_{0}(k\|x-x_{j} \|) \right)
%
%  where $c_{j}$ are the charge densities, $d_{j}$ are the dipole
%  densities,
%  $v_{j}$ are the dipole orientation vectors, and
%  $x_{j}$ are the source locations.
%  When $\|x-x_{j}\| <= L \eps_{m}$, with $L$ being the size of the bounding
%  box of sources and targets and $\eps_{m}$ being machine precision, 
%  the term corresponding to $x_{j}$ is dropped
%  from the sum.
% 
%  Args:
%
%  -  eps: double   
%        precision requested
%  -  zk: complex
%        Helmholtz parameter, k
%  -  srcinfo: structure
%        structure containing sourceinfo
%     
%     *  srcinfo.sources: double(2,n)    
%           source locations, $x_{j}$
%     *  srcinfo.nd: integer
%           number of charge/dipole vectors (optional, 
%           default - nd = 1)
%     *  srcinfo.charges: complex(nd,n) 
%           charge densities, $c_{j}$ (optional, 
%           default - term corresponding to charges dropped)
%     *  srcinfo.dipstr: complex(nd,n)
%           dipole densities, $d_{j}$ (optional, 
%           default - term corresponding to dipoles dropped)
%     *  srcinfo.dipvec: double(nd,2,n) 
%           dipole orientation vectors, $v_{j}$ (optional
%           default - term corresponding to dipoles dropped) 
%  -  pg: integer
%        | source eval flag
%        | potential at sources evaluated if pg = 1
%        | potential and gradient at sources evaluated if pg=2
%        | potential, gradient, and hessians at sources evaluated if pg=3
%        
%  Optional args
%  -  targ: double(2,nt)
%        target locations, $t_{i}$ 
%  -  pgt: integer
%        | target eval flag 
%        | potential at targets evaluated if pgt = 1
%        | potential and gradient at targets evaluated if pgt=2 
%  -  opts: options structure, values in brackets indicate default
%           values wherever applicable
%        opts.ndiv: set number of points for subdivision criterion
%        opts.idivflag: set subdivision criterion (0)
%           opts.idivflag = 0, subdivide on sources only
%           opts.idivflag = 1, subdivide on targets only
%           opts.idivflag = 2, subdivide on sources and targets
%        opts.ifnear: include near (list 1) interactions (true)
%
%  
%  Returns:
%  
%  -  U.pot: potential at source locations, if requested, $u(x_{j})$
%  -  U.grad: gradient at source locations, if requested, $\nabla u(x_{j})$
%  -  U.hess: hessian at source locations, if requested, $\nabla \nabla u(x_{j})$
%  -  U.pottarg: potential at target locations, if requested, $u(t_{i})$
%  -  U.gradtarg: gradient at target locations, if requested, $\nabla u(t_{i})$
%  -  U.hesstarg: hessian at target locations, if requested, $\nabla \nabla u(t_{i})$
%
%  - ier: error code for fmm run
%  - timeinfo: time taken in each step of the fmm
%       timeinfo(1): form multipole step
%       timeinfo(2): multipole->multipole translation step
%       timeinfo(3): multipole to local translation, form local + multipole eval step
%       timeinfo(4): local->local translation step
%       timeinfo(5): local eval step
%       timeinfo(6): direct evaluation step
%
%
%  Examples:
%  U = hfmm3d(eps,zk,srcinfo,pg)
%     Call the FMM for sources only with default arguments
%  U = hfmm3d(eps,zk,srcinfo,pg,targ,pgt)
%     Call the FMM for sources + targets with default arguments
%  U = hfmm3d(eps,zk,srcinfo,pg,opts)
%     Call the FMM for sources only with user specified arguments
%  U = hfmm3d(eps,zk,srcinfo,pg,targ,pgt)
%     Call the FMM for sources + targets with user specified arguments 
%  [U,ier] = hfmm3d(eps,zk,srcinfo,pg)
%     Call the FMM for sources only with default arguments and returns
%     the error code for the FMM as well
%  [U,ier,timeinfo] = hfmm3d(eps,zk,srcinfo,pg)
%     Call the FMM for sources only with default arguments, returns
%     the error code for the FMM as well and the time split
%      
 


  sources = srcinfo.sources;
  [m,ns] = size(sources);
  assert(m==2,'The first dimension of sources must be 2');
  if(~isfield(srcinfo,'nd'))
    nd = 1;
  end
  if(isfield(srcinfo,'nd'))
    nd = srcinfo.nd;
  end

  pot = complex(zeros(nd,ns)); 
  grad = complex(zeros(nd*2,ns));
  hess = complex(zeros(nd*3,ns));
  
  if( nargin < 4)
    disp('Not enough input arguments, exiting\n');
    return;
  end
  if( nargin == 4 )
    nt = 0;
    pgt = 0;
    targ = zeros(2,1);
    opts = [];
  elseif (nargin == 5)
    nt = 0;
    pgt = 0;
    targ = zeros(2,1);
    opts = varargin{1};
  elseif (nargin == 6)
    targ = varargin{1};
    pgt = varargin{2};
    [m,nt] = size(targ);
    assert(m==2,'First dimension of targets must be 2');
    opts = [];
  elseif (nargin == 7)
    targ = varargin{1};
    pgt = varargin{2};
    [m,nt] = size(targ);
    assert(m==2,'First dimension of targets must be 2');
    opts = varargin{3};
  end
  ntuse = max(nt,1);
  pottarg = complex(zeros(nd,ntuse));
  gradtarg = complex(zeros(nd*2,ntuse));
  hesstarg = complex(zeros(nd*3,ntuse));


  if((pg ==0 && pgt ==0) || (ns == 0)), disp('Nothing to compute, set eigher pg or pgt to 1 or 2'); return; end;

  if(isfield(srcinfo,'charges'))
    ifcharge = 1;
    charges = srcinfo.charges;
    if(nd==1), assert(length(charges)==ns,'Charges must be same length as second dimension of sources'); end;
    if(nd>1), [a,b] = size(charges); assert(a==nd && b==ns,'Charges must be of shape [nd,ns] where nd is the number of densities, and ns is the number of sources'); end;
  else
    ifcharge = 0;
    charges = complex(zeros(nd,ns));
  end

  if(isfield(srcinfo,'dipstr') || isfield(srcinfo,'dipvec'))
    ifdipole = 1;
    dipstr = srcinfo.dipstr;
    if(nd==1), assert(length(dipstr)==ns,'Dipole strength must be same length as second dimension of sources'); end;
    if(nd>1), [a,b] = size(dipstr); assert(a==nd && b==ns,'Dipstr must be of shape [nd,ns] where nd is the number of densities, and ns is the number of sources'); end;
    dipvec = srcinfo.dipvec;
    if(nd == 1), [a,b] = size(squeeze(dipvec)); assert(a==2 && b==ns,'Dipvec must be of shape[2,ns], where ns is the number of sources'); end;
    if(nd>1), [a,b,c] = size(dipvec); assert(a==nd && b==2 && c==ns, 'Dipvec must be of shape[nd,2,ns], where nd is number of densities, and ns is the number of sources'); end;
    dipvec = reshape(dipvec,[2*nd,ns]);
  else
    ifdipole = 0;
    dipvec = zeros(nd*2,ns);
    dipstr = complex(zeros(nd,ns));
  end

  nd2 = 2*nd;
  nd3 = 3*nd;
  ier = 0;

  ndiv = 20;
  idivflag = 0;
  mex_id_ = 'hndiv2d(i double[x], i int[x], i int[x], i int[x], i int[x], i int[x], i int[x], io int[x], io int[x])';
[ndiv, idivflag] = fmm2d(mex_id_, eps, ns, nt, ifcharge, ifdipole, pg, pgt, ndiv, idivflag, 1, 1, 1, 1, 1, 1, 1, 1, 1);
  if(isfield(opts,'ndiv'))
    ndiv = opts.ndiv;
  end

  if(isfield(opts,'idivflag'))
    idivflag = opts.idivflag;
  end

  ifnear = 1;
  if(isfield(opts,'ifnear'))
    ifnear = opts.ifnear;
  end
  iper = 1;
  timeinfo = zeros(8,1);
  mex_id_ = 'hfmm2d_ndiv(i int[x], i double[x], i dcomplex[x], i int[x], i double[xx], i int[x], i dcomplex[xx], i int[x], i dcomplex[xx], i double[xx], i int[x], i int[x], io dcomplex[xx], io dcomplex[xx], io dcomplex[xx], i int[x], i double[xx], i int[x], io dcomplex[xx], io dcomplex[xx], io dcomplex[xx], i int[x], i int[x], i int[x], io double[x], io int[x])';
[pot, grad, hess, pottarg, gradtarg, hesstarg, timeinfo, ier] = fmm2d(mex_id_, nd, eps, zk, ns, sources, ifcharge, charges, ifdipole, dipstr, dipvec, iper, pg, pot, grad, hess, nt, targ, pgt, pottarg, gradtarg, hesstarg, ndiv, idivflag, ifnear, timeinfo, ier, 1, 1, 1, 1, 2, ns, 1, nd, ns, 1, nd, ns, nd2, ns, 1, 1, nd, ns, nd2, ns, nd3, ns, 1, 2, ntuse, 1, nd, ntuse, nd2, ntuse, nd3, ntuse, 1, 1, 1, 8, 1);

  U.pot = [];
  U.grad = [];
  U.hess = [];
  U.pottarg = [];
  U.gradtarg = [];
  U.hesstarg = [];
  if(pg >= 1), U.pot = squeeze(reshape(pot,[nd,ns])); end;
  if(pg >= 2), U.grad = squeeze(reshape(grad,[nd,2,ns])); end;
  if(pg >= 3), U.hess = squeeze(reshape(hess,[nd,3,ns])); end;
  if(pgt >= 1), U.pottarg = squeeze(reshape(pottarg,[nd,nt])); end;
  if(pgt >= 2), U.gradtarg = squeeze(reshape(gradtarg,[nd,2,nt])); end;
  if(pgt >= 3), U.hesstarg = squeeze(reshape(hesstarg,[nd,3,nt])); end;

  varargout{1} = ier;
  varargout{2} = timeinfo;
end

% ---------------------------------------------------------------------
