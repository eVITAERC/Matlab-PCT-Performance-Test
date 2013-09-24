function bench_results = runAll(save_filename,numNodes,numProcPerNode,memoryPerWorker_inGB,remarks)
%   RUNALL   Runs all the MATLAB PCT implementations of the pSPOT benchmarks
%       [bench_results] = runAll(save_filename,numNodes,numProcPerNode,memoryPerWorker_inGB {,remarks})
%
%   # INPUTS
%   save_filename           results will be saved to the file `{save_filename}.json` if not an empty string
%   numNodes                an integer specifying the number of nodes allocated for this benchmark
%                           (default: 1)
%   numProcPerNode          an integer specifying the number of processors per node allocated for this 
%                           benchmark (default: 1)
%   memoryPerWorker_inGB    set memory utilization per worker, in GB (1024^3 Bytes)
%                           (default: 0.5)
%   remarks                 OPTIONAL string will be stored in the benchmark results. Useful for comments.
%   
%   # OUTPUTS
%   BENCH_RESULTS           a cell-array of structs representing finished benchmark results for each benchmark
%                   
%   
%   Created by Tim Lin on 2013-09-12.
%   Copyright (c) 2013 SLIM. All rights reserved.

run setupPath.m

%% === Initialize

% defaults
if not(exist('numNodes','var'))
    numNodes = [];
end
if not(exist('numProcPerNode','var'))
    numProcPerNode = [];
end
if not(exist('memoryPerWorker_inGB','var'))
    memoryPerWorker_inGB = 0.5;
end
if not(exist('remarks','var'))
    remarks = '';
end

%% === Run each benchmark in its own directory

currDir = pwd();

try
    cd ./HPCchallenge
    bench_results_HPCC = runAll(numNodes,numProcPerNode,memoryPerWorker_inGB,'all',remarks);
    cd(currDir)

    cd ./pSPOT
    bench_results_pSPOT = runAll(numNodes,numProcPerNode,memoryPerWorker_inGB,'all',remarks);
    cd(currDir)
catch ME
    cd(currDir)
    rethrow(ME)
end

bench_results = {bench_results_HPCC{:} bench_results_pSPOT{:}};

if not(isempty(save_filename))
    savejson('', bench_results, [save_filename '.json'])
end
