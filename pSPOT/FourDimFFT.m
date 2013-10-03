function report = FourDimFFT( num_workers, memoryPerWorker_inGB )
% FourDimFFT   a HPC benchmark written in pSPOT, computes 4-dimensional parallel FFT that involves one intermediate parallel transpose
% 
%   Created by Tim Lin on 2013-09-08.
%   Copyright (c) 2013 SLIM. All rights reserved.

% If no size provided then get a default size consistent with `hpccGetProblemSize` defaults
if nargin < 1
    num_workers = max(matlabpool('size'), 1);
    memoryPerWorker_inGB = 0.25; % in GB
end

disp('running FourDimFFT...')

% create a cube
overhead_factor = 3; % memory usage redundancy factor
GB_to_byte = 1024^3;
n = floor(nthroot((memoryPerWorker_inGB * GB_to_byte) / (overhead_factor * 8), 4));

spmd
    % Create two distributed matrix in the default 1d distribution
    x = codistributed.randn([n*n n*n], codistributor1d);
end

% Construct operator
F = opDFT(n);
FFT4d = oppKron2Lo(opKron(F,F),opKron(F,F));
x = distVectorize(x);

% Time the SRMP operation (in-place)
tic
x = FFT4d*x;
t = toc;

% Performance in effective transfer rate of gigaflops
problemSize = 8*n^4/(GB_to_byte);
perf = 5*n*log2(n)*(4*n^3)/t/1.e9;

fprintf('Data size: %f GB\nPerformance: %f GFlops\n', problemSize, perf);
report = matlabPCTBenchReport('FourDimFFT', t, ...
                              'numWorkers', num_workers, ...
                              'memPerWorkerInGB', memoryPerWorker_inGB, ...
                              'problemSize', problemSize, ...
                              'problemSizeUnit', 'GB', ...
                              'performance', perf, ...
                              'performanceUnit', 'GFlops');

