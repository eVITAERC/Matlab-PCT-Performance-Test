function bench_results = runAll(num_workers,memoryPerWorker_inGB,benchmarkSet)
%   RUNALL   Runs all the MATLAB PCT implementations of the HPC Challenge benchmark
%       [bench_results] = runAll(num_workers, MemoryPerWorker_inGB, benchmarkSet)
%
%   # INPUTS
%   num_workers             a integer specifying the number of PCT workers to utilize
%                           (default: 1)
%   memoryPerWorker_inGB    set memory utilization per worker, in GB (1024^3 Bytes)
%                           (default: 0.5)
%   benchmarkSet            a cell-array containing one or more of the following stings, indicating
%                           which benchmarks are to be run (default to running all):
%                           'fft':      Distributed FFT
%                           'hpl':      Global-HighPerformanceLinpack
%                           'ptrans':   Global-Ptrans (matrix transpose)
%                           'stream':   EP Stream (triad operation a+b*c)
%                           'ra':       Global-RandomAccess
%   
%   # OUTPUTS
%   BENCH_RESULTS   a struct of finished benchmark results
%                   
%   
%   Created by Tim Lin on 2013-08-15.
%   Copyright (c) 2013 SLIM. All rights reserved.

%% === Initialize

% defaults
if not(exist('num_workers','var'))
    num_workers = 1;
end
if not(exist('memoryPerWorker_inGB','var'))
    memoryPerWorker_inGB = 0.5;
end
if not(exist('benchmarkSet','var'))
    benchmarkSet = {'fft','hpl','ptrans','stream','ra'};
end

% guard against lazy use of simply typing in the benchmark you want
if isstr(benchmarkSet)
    benchmarkSet = {benchmarkSet};
end

bench_results = [];

%% === Validate

% The Distributed FFT Benchmark and RandomAccess Benchmark requires that number of workers must be powers of 2
validateattributes(log2(num_workers),{'numeric'},{'integer'},'runAll','log2(num_workers)')

%% === Start Benchmarks

% EP STREAM (Triad)
if ismember('stream',benchmarkSet)
    disp('running hpccStream...')
    problemSize_Stream = hpccGetProblemSize('stream',num_workers,memoryPerWorker_inGB);
    hpccStream(problemSize_Stream);
end

% Distributed FFT
if ismember('fft',benchmarkSet)
    disp('running hpccFft...')
    problemSize_FFT = hpccGetProblemSize('fft',num_workers,memoryPerWorker_inGB);
    hpccFft(problemSize_FFT);
end

% Global Linpack
if ismember('hpl',benchmarkSet)
    disp('running hpccLinpack...')
    problemSize_Linpack = hpccGetProblemSize('hpl',num_workers,memoryPerWorker_inGB);
    hpccLinpack(problemSize_Linpack);
end

% Global Ptrans
if ismember('ptrans',benchmarkSet)
    disp('running hpccPtrans...')
    problemSize_Ptrans = hpccGetProblemSize('ptrans',num_workers,memoryPerWorker_inGB);
    hpccPtrans(problemSize_Ptrans);
end

% Global RandomAccess
if ismember('ra',benchmarkSet)
    disp('running hpccRandomAccess...')
    problemSize_RA = hpccGetProblemSize('ra',num_workers,memoryPerWorker_inGB);
    hpccRandomAccess(problemSize_RA);
end

end %  function
