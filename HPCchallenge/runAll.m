function bench_results = runAll(numNodes,numProcPerNode,memoryPerWorker_inGB,benchmarkSet,remarks)
%   RUNALL   Runs all the MATLAB PCT implementations of the HPC Challenge benchmark
%       [bench_results] = runAll(numNodes, numProcPerNode, MemoryPerWorker_inGB, benchmarkSet {,remarks})
%
%   # INPUTS
%   numNodes                an integer specifying the number of nodes allocated for this benchmark
%                           (default: 1)
%   numProcPerNode          an integer specifying the number of processors per node allocated for this 
%                           benchmark (default: 1)
%   memoryPerWorker_inGB    set memory utilization per worker, in GB (1024^3 Bytes)
%                           (default: 0.5)
%   benchmarkSet            a cell-array containing one or more of the following stings, indicating
%                           which benchmarks are to be run (default to running all):
%                           'fft':      Distributed FFT
%                           'hpl':      Global-HighPerformanceLinpack
%                           'ptrans':   Global-Ptrans (matrix transpose)
%                           'stream':   EP Stream (triad operation a+b*c)
%                           'ra':       Global-RandomAccess
%                           'all':      run all the above benchmarks
%   remarks                 OPTIONAL string will be stored in the benchmark results. Useful for comments.
%   
%   # OUTPUTS
%   BENCH_RESULTS           a cell-array of structs representing finished benchmark results for each benchmark
%                   
%   
%   Created by Tim Lin on 2013-08-15.
%   Copyright (c) 2013 SLIM. All rights reserved.

%% === Initialize

% defaults
if not(exist('numNodes','var'))
    numNodes = 1;
end
if not(exist('numProcPerNode','var'))
    numProcPerNode = 1;
end
if not(exist('memoryPerWorker_inGB','var'))
    memoryPerWorker_inGB = 0.5;
end
if not(exist('benchmarkSet','var')) || strcmp(benchmarkSet,'all')
    benchmarkSet = {'fft','hpl','ptrans','stream','ra'};
end
if not(exist('remarks','var'))
    remarks = '';
end

% guard against lazy use of simply typing in the benchmark you want
if isstr(benchmarkSet)
    benchmarkSet = {benchmarkSet};
end

bench_results = {};

%% === Validate

num_workers = numNodes * numProcPerNode;

% The Distributed FFT Benchmark and RandomAccess Benchmark requires that number of workers must be powers of 2
validateattributes(log2(num_workers),{'numeric'},{'integer'},'runAll','log2(num_workers)')

%% === Start Benchmarks

% EP STREAM (Triad)
if ismember('stream',benchmarkSet)
    disp('running hpccStream...')
    problemSize_Stream = hpccGetProblemSize('stream',num_workers,memoryPerWorker_inGB);
    bench_results{end+1} = hpccStream(problemSize_Stream);
end

% Distributed FFT
if ismember('fft',benchmarkSet)
    disp('running hpccFft...')
    problemSize_FFT = hpccGetProblemSize('fft',num_workers,memoryPerWorker_inGB);
    bench_results{end+1} = hpccFft(problemSize_FFT);
end

% Global Linpack
if ismember('hpl',benchmarkSet)
    disp('running hpccLinpack...')
    problemSize_Linpack = hpccGetProblemSize('hpl',num_workers,memoryPerWorker_inGB);
    bench_results{end+1} = hpccLinpack(problemSize_Linpack);
end

% Global Ptrans
if ismember('ptrans',benchmarkSet)
    disp('running hpccPtrans...')
    problemSize_Ptrans = hpccGetProblemSize('ptrans',num_workers,memoryPerWorker_inGB);
    bench_results{end+1} = hpccPtrans(problemSize_Ptrans);
end

% Global RandomAccess
if ismember('ra',benchmarkSet) && exist('randRA') == 3 % only run if compiled
    disp('running hpccRandomAccess...')
    problemSize_RA = hpccGetProblemSize('ra',num_workers,memoryPerWorker_inGB);
    bench_results{end+1} = hpccRandomAccess(problemSize_RA);
end

for k = 1:length(bench_results)
    bench_results{k}.numWorkers = num_workers;
    bench_results{k}.memPerWorkerInGB = memoryPerWorker_inGB;
    
    if not(isempty('numNodes'))
        bench_results{k}.notes.numNodes = numNodes;
    end
    if not(isempty('numProcPerNode'))
        bench_results{k}.notes.numProcPerNode = numProcPerNode;
    end
    if not(isempty('remarks'))
        bench_results{k}.notes.remark = remarks;
    end
end

bench_results{:};

end %  function
