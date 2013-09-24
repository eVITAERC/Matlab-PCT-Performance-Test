function bench_results = runAll(numNodes,numProcPerNode,memoryPerWorker_inGB,benchmarkSet,remarks)
%   RUNALL   Runs all the MATLAB PCT implementations of the pSPOT benchmarks
%       [bench_results] = runAll(numNodes, numProcPerNode, MemoryPerWorker_inGB, benchmarkSet {,remarks})
%
%   # INPUTS
%   numNodes                an integer specifying the number of nodes allocated for this benchmark
%                           (default: 1)
%   numProcPerNode          an integer specifying the number of processors per node allocated for this 
%                           benchmark (default: 1)
%   benchmarkSet            a cell-array containing one or more of the following stings, indicating
%                           which benchmarks are to be run (default to running all):
%                           'SRMP':         Surface-related multiple prediction for prestack seismic line
%                           'FourDimFFT':   4D FFT involving one large parallel transpose
%                           'all':          run all the above benchmarks
%   remarks                 OPTIONAL string will be stored in the benchmark results. Useful for comments.
%   
%   # OUTPUTS
%   BENCH_RESULTS           a cell-array of structs representing finished benchmark results for each benchmark
%                           
%   
%   Created by Tim Lin on 2013-09-12.
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
    benchmarkSet = {'SRMP','FourDimFFT'};
end
if not(exist('remarks','var'))
    remarks = '';
end

% guard against lazy use of simply typing in the benchmark you want
if isstr(benchmarkSet)
    benchmarkSet = {benchmarkSet};
end

bench_results = {};


%% === Start Benchmarks

num_workers = numNodes * numProcPerNode;

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
