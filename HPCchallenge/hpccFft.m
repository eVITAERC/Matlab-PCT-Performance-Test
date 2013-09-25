function report = hpccFft( m )
%HPCCFFT An implementation of the HPCC Global FFT benchmark
%
% hpccFft(m) creates a random complex codistributed array of length m and 
%  computes the discrete fourier transform on that vector in a parallel
%  way, using the currently available resources (MATLAB pool). This
%  computation is timed to produce the benchmark result. It then computes 
%  the inverse discrete fourier transform on the result (in parallel) to 
%  ensure that the error on the computation is within acceptable bounds.
%
%  The number of labs in the pool should be a power of 2; and m must be a 
%  power of 2
%
%  If you do not provide a value for m, the default value is that returned
%  from hpccGetProblemSize('fft'), which assumes that each process in the
%  pool has 256 MB of memory available. This is expected to be smaller than
%  the actual memory available.
%
%  Details of the HPC Challenge benchmarks can be found at
%  www.hpcchallenge.org and the specific Class 2 specs are linked off that
%  page. (At the time of writing, the specs are linked at
%  www.hpcchallenge.org/class2specs.pdf.)
%
%    Examples:
%
%      % Without a matlabpool open
%      tic; hpccFft; toc
%      Data size: 0.062500 GB
%      Performance: 0.211762 GFlops
%      Err: 0.016637
%      Elapsed time is 2.354904 seconds.
%
%      % With a local matlabpool of size 4
%      tic; hpccFft; toc
%      Data size: 0.250000 GB
%      Performance: 0.316420 GFlops
%      Err: 0.021332
%      Elapsed time is 7.170477 seconds.
%
%  See also: hpccGetProblemSize, matlabpool


%   Copyright 2008-2009 The MathWorks, Inc.

% If no size provided then get a default size
if nargin < 1
    m = hpccGetProblemSize( 'fft' );
end
% Input vector MUST be a power of 2 in size
assert(m == 2^floor(log2(m)), 'hpccFft requires an exact power of 2 size for its input vector size');
spmd
    % numlabs MUST be a power of 2
    assert(numlabs == 2^floor(log2(numlabs)), 'hpccFft requires an exact power of 2 number of labs');
    
    % Create complex 1xm random vector
    x = codistributed.rand(m,1) + codistributed.rand(m,1)*1i;
    
    % Time the forward FFT
    tic
    y = fft(x);
    t = toc;
end

% Performance in gigaflops
t = max([t{:}]);
perf = 5*m*log2(m)/t/1.e9;
problemSize = 32*m/(1024^3);

% Compute error from the inverse FFT    
z = (1/length(y))*conj(fft(conj(y)));
relErr = gather(norm(x-z,inf)/(16*log2(m)*eps));

if relErr > 1
    error('Failed the HPC FFT Benchmark');
end

fprintf('Data size: %f GB\nPerformance: %f GFlops\nRelativeErr: %f\n', problemSize, perf, relErr);
report = matlabPCTBenchReport('hpccFft', t, ...
                              'problemSize', problemSize, ...
                              'problemSizeUnit', 'GB', ...
                              'performance', perf, ...
                              'performanceUnit', 'GFlops');
