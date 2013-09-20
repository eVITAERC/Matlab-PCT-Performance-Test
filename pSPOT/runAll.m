function bench_results = runAll(num_workers,memoryPerWorker_inGB,benchmarkSet,numNodes,numProcPerNode,remarks)
%   RUNALL   Runs all the MATLAB PCT implementations of the pSPOT benchmarks
%       [bench_results] = runAll(num_workers, MemoryPerWorker_inGB, benchmarkSet {,numNodes,numProcPerNode,remarks})
%
%   # INPUTS
%   num_workers             a integer specifying the number of PCT workers to utilize
%                           (default: 1)
%   memoryPerWorker_inGB    set memory utilization per worker, in GB (1024^3 Bytes)
%                           (default: 0.5)
%   benchmarkSet            a cell-array containing one or more of the following stings, indicating
%                           which benchmarks are to be run (default to running all):
%                           'SRMP':         Surface-related multiple prediction for prestack seismic line
%                           'FourDimFFT':   4D FFT involving one large parallel transpose
%                           'all':          run all the above benchmarks
%   numNodes(int), numProcPerNode(int), remarks(string) are OPTIONAL and for record-keeping only, will be put into the record struct, see `matlabPCTBenchReport.m`
%   
%   # OUTPUTS
%   BENCH_RESULTS   a cell-array of structs representing finished benchmark results for each benchmark
%                   
%   
%   Created by Tim Lin on 2013-09-12.
%   Copyright (c) 2013 SLIM. All rights reserved.


%% === Initialize

% defaults
if not(exist('num_workers','var'))
    num_workers = 1;
end
if not(exist('memoryPerWorker_inGB','var'))
    memoryPerWorker_inGB = 0.5;
end
if not(exist('benchmarkSet','var')) || strcmp(benchmarkSet,'all')
    benchmarkSet = {'SRMP','FourDimFFT'};
end
if not(exist('numNodes','var'))
    numNodes = [];
end
if not(exist('numProcPerNode','var'))
    numProcPerNode = [];
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

% The Distributed FFT Benchmark and RandomAccess Benchmark requires that number of workers must be powers of 2
validateattributes(log2(num_workers),{'numeric'},{'integer'},'runAll','log2(num_workers)')

%% === Start Benchmarks

% SRMP
if ismember('SRMP',benchmarkSet)
    bench_results{end+1} = SRMP(num_workers, memoryPerWorker_inGB);
end

% 4D FFT
if ismember('FourDimFFT',benchmarkSet)
    bench_results{end+1} = FourDimFFT(num_workers, memoryPerWorker_inGB);
end

for k = 1:length(bench_results)
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
