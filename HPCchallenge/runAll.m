function bench_results = runAll(num_workers,memoryPerWorker_inGB)
% 	RUNALL   Runs all the MATLAB PCT implementations of the HPC Challenge benchmark
% 		[bench_results] = runAll(num_workers,MemoryPerWorker_inGB)

%   # INPUTS
% 	num_workers				a integer specifying the number of PCT workers to utilize
%							(default: 1)
%	memoryPerWorker_inGB	set memory utilization per worker, in GB (1024^3 Bytes)
%							(default: 0.5)
%	
%	# OUTPUTS
%	BENCH_RESULTS	a struct of finished benchmark results
%					
% 	
% 	Created by Tim Lin on 2013-08-15.
% 	Copyright (c) 2013 SLIM. All rights reserved.

%% === Initialize

if not(exist('num_workers','var'))
	num_workers = 1;
end

if not(exist('memoryPerWorker_inGB','var'))
	memoryPerWorker_inGB = 0.5;
end

bench_results = [];

%% === Validate

% The Distributed FFT Benchmark and RandomAccess Benchmark requires that number of workers must be powers of 2
validateattributes(log2(num_workers),{'numeric'},{'integer'},'runAll','log2(num_workers)')

%% === Start Benchmarks

% Distributed FFT
disp('running hpccFft...')
problemSize_FFT = hpccGetProblemSize('fft',num_workers,memoryPerWorker_inGB);
hpccFft(problemSize_FFT);

% Linpack
disp('running hpccLinpack...')
problemSize_Linpack = hpccGetProblemSize('hpl',num_workers,memoryPerWorker_inGB);
hpccLinpack(problemSize_Linpack);

% EP STREAM (Triad)
disp('running hpccStream...')
problemSize_Stream = hpccGetProblemSize('stream',num_workers,memoryPerWorker_inGB);
hpccStream(problemSize_Stream);

end %  function
