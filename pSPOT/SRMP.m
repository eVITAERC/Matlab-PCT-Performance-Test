function report = SRMP( num_workers, memoryPerWorker_inGB )
%SRMP   a HPC benchmark written in pSPOT, computes general surface-related multiple prediction for seismic line
% 
%   Created by Tim Lin on 2013-09-02.
%   Copyright (c) 2013 SLIM. All rights reserved.

% If no size provided then get a default size consistent with `hpccGetProblemSize` defaults
if nargin < 1
    num_workers = max(matlabpool('size'), 1);
    memoryPerWorker_inGB = 0.25; % in GB
end

disp('running SRMP...')

% create a cube
overhead_factor = 1.5; % memory usage redundancy factor
GB_to_byte = 1024^3;
n = floor(nthroot((memoryPerWorker_inGB * GB_to_byte) / (2 * overhead_factor * 8), 3));

spmd
    % Create two distributed matrix in the default 1d distribution
    data = codistributed.randn([n n n], codistributor1d);
    x = codistributed.randn([n n n], codistributor1d);
end

% Construct operator
OP_SRMP = opSRMP(data);
x = distVectorize(x);

% Time the SRMP operation (in-place)
tic
x = OP_SRMP*x;
t = toc;

% Performance in effective transfer rate of GFlops
problemSize = 8*n^3/(GB_to_byte);
perf = 2*(10*n*log2(n*2)*n^2 + (n*n^3)) / t / 1.e9;

fprintf('Data size: %f GB\nPerformance: %f GFlops\n', problemSize, perf);
report = matlabPCTBenchReport('SRMP', t, ...
                              'numWorkers', num_workers, ...
                              'memPerWorkerInGB', memoryPerWorker_inGB, ...
                              'problemSize', problemSize, ...
                              'problemSizeUnit', 'GFlops', ...
                              'performance', perf, ...
                              'performanceUnit', 'GFlops');

