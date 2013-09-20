function bench_results = runAll(save_filename,num_workers,memoryPerWorker_inGB,numNodes,numProcPerNode,remarks)
%   RUNALL   Runs all the MATLAB PCT implementations of the pSPOT benchmarks
%       [bench_results] = runAll(save_filename,num_workers,memoryPerWorker_inGB, {,numNodes,numProcPerNode,remarks})
%
%   # INPUTS
%   save_filename           results will be saved to the file `{save_filename}.json` if not an empty string
%   num_workers             a integer specifying the number of PCT workers to utilize
%                           (default: 1)
%   memoryPerWorker_inGB    set memory utilization per worker, in GB (1024^3 Bytes)
%                           (default: 0.5)
%   numNodes(int), numProcPerNode(int), remarks(string) are OPTIONAL and for record-keeping only, will be put into the record struct, see `matlabPCTBenchReport.m`
%   
%   # OUTPUTS
%   BENCH_RESULTS   a cell-array of structs representing finished benchmark results for each benchmark
%                   
%   
%   Created by Tim Lin on 2013-09-12.
%   Copyright (c) 2013 SLIM. All rights reserved.

run setupPath.m

%% === Initialize

% defaults
if not(exist('num_workers','var'))
    num_workers = 1;
end
if not(exist('memoryPerWorker_inGB','var'))
    memoryPerWorker_inGB = 0.5;
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

%% === Run each benchmark in its own directory

currDir = pwd();

try
    cd ./HPCchallenge
    bench_results_HPCC = runAll(num_workers,memoryPerWorker_inGB,'all',numNodes,numProcPerNode,remarks);
    cd(currDir)

    cd ./pSPOT
    bench_results_pSPOT = runAll(num_workers,memoryPerWorker_inGB,'all',numNodes,numProcPerNode,remarks);
    cd(currDir)
catch ME
    cd(currDir)
    rethrow(ME)
end

bench_results = {bench_results_HPCC{:} bench_results_pSPOT{:}};

if not(isempty(save_filename))
    savejson('', bench_results, [save_filename '.json'])
end
