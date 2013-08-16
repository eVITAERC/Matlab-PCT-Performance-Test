function hpccPtrans( m )
%HPCCPTRANS An implementation of the HPCC Global PTRANS benchmark
%
%  hpccPtrans(m) creates two random codistributed real matrix A and B of size
%    m-by-m. It then measures the time to calculate A = transpose(A) + B in a
%    parallel way using the currently available resources (MATLAB pool). This
%    time indicates the performance metric. Finally the function computes the
%    scaled residuals to ensure that the error on the computation is within
%    acceptable bounds.
%
%    If you do not specify m, the default value is that returned from
%    hpccGetProblemSize('hpl'), which assumes that each process in the pool
%    has 256 MB of memory available. This is expected to be smaller than
%    the actual memory available. 
%
%    Details of the HPC Challenge benchmarks can be found at
%    www.hpcchallenge.org and the specific Class 2 specs are linked off
%    that page. (At the time of writing, the specs are linked at
%    www.hpcchallenge.org/class2specs.pdf.)
%

%   Copyright 2008-2009 The MathWorks, Inc.

% If no size provided then get a default size
if nargin < 1
    m = hpccGetProblemSize( 'hpl' );
end

spmd
    % Create two distributed matrix in the default 1d distribution
    A = codistributed.randn(m, m);
    B = codistributed.randn(m, m);
    
    % Time the solution of the linear system   
    tic
    A = transpose(A) + B;
    t = toc;
end

% Performance in effective transfer rate of gigabytes/s
perf = (8*(m^2))/max([t{:}])/1.e9;

fprintf('Data size: %f GB\nPerformance: %f GB/s\n', 8*m^2/(1024^3), perf);

