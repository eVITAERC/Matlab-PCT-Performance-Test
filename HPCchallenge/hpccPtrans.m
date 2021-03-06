function report = hpccPtrans( m )
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
%    hpccGetProblemSize('ptrans'), which assumes that each process in the pool
%    has 256 MB of memory available. This is expected to be smaller than
%    the actual memory available. 
%
%    Details of the HPC Challenge benchmarks can be found at
%    www.hpcchallenge.org and the specific Class 2 specs are linked off
%    that page. (At the time of writing, the specs are linked at
%    www.hpcchallenge.org/class2specs.pdf.)
%

%   Derived from 'hpccLinpack.m'
%   Created by Tim Lin on 2013-08-16.
%   Copyright (c) 2013 SLIM. All rights reserved.

% If no size provided then get a default size
if nargin < 1
    m = hpccGetProblemSize( 'ptrans' );
end

spmd
    % Create two distributed matrix in the default 1d distribution
    A = codistributed.randn(m, m);
    B = codistributed.randn(m, m);
    
    % Time the mat-add
    tic
    A = A + B;
    t_madd = toc;
    
    % Do the transpose +c in a loop and get the median time
    for k=1:5
        % main run for timing
        tic
        A = transpose(A) + B;
        t_runs(k) = toc;
        % second run to flush original untransposed matrix from cache
        A = transpose(A) + B;
    end
    t = median(t_runs);
    
    % remove matrix sum time (will also remove communication setup time bias)
    t = t - t_madd;
end

% Performance in effective transfer rate of gigabytes/s
t = max([t{:}]);
perf = (8*(m^2))/t/1.e9;
problemSize = 8*m^2/(1024^3);

fprintf('Data size: %f GB\nPerformance: %f GB/s\n', problemSize, perf);
report = matlabPCTBenchReport('hpccPtrans', t, ...
                              'problemSize', problemSize, ...
                              'problemSizeUnit', 'GB', ...
                              'performance', perf, ...
                              'performanceUnit', 'GB/s');

