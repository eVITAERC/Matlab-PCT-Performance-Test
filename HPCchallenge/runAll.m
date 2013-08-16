function bench_results = runAll(num_workers)
% 	RUNALL   Runs all the MATLAB PCT implementations of the HPC Challenge benchmark
% 		[BENCH_RESULTS] = RUNALL(NUM_WORKERS)
% 
% 	NUMWORKERS		a integer specifying the number of PCT workers to utilize
%	BENCH_RESULTS	a struct of finished benchmark results
% 	
% 	Created by Tim Lin on 2013-08-15.
% 	Copyright (c) 2013 SLIM. All rights reserved.

%% Initialize

% The Distributed FFT Benchmark and RandomAccess Benchmark requires that number of workers must be powers of 2
validateattributes(log2(num_workers),{'numeric'},{'integer'},'runAll','log2(num_workers)')

MemoryPerWorker_inGB = 0.01; % we determine problem size by fixing memory utilization per worker
bench_results = [];

%% Start Benchmarks

% Distributed FFT
problemSize_FFT = hpccGetProblemSize('fft',num_workers,MemoryPerWorker_inGB);
hpccFft(problemSize_FFT);



end %  function