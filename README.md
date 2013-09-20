## Matlab Parallel Computing Toolbox benchmark suite for SLIM

This package provides a set of standalone benchmarks for high-performance computing clusters using the Matlab [Parallel Computing Toolbox](http://www.mathworks.com/products/parallel-computing/) programming paradigm built on top of MPI. Most of the benchmark routines make use of the `spmd` and `co/distributed array` paradigm instead of directly making MPI calls.

The benchmarks are partitioned into different directories according to their purpose:

- `HPCchallenge`: includes a modified set of [HPCC benchmarks](http://www.hpcchallenge.org/) implemented by Mathworks and included as demos in the Matlab PCT distribution
- `pSPOT`: includes a few tests of real-world intensive operations constructed using the SLIM pSPOT framework.

### Installation

Just these files to a directory. No additional libraries are necessary. Use the `setupPath.m` script to import all the helper functions pertaining to this benchmark (the main `runAll.m` script will do this for you). 

The only additional step is that `HPCchallenge/randRA.cpp` needs to be mex compiled for the **hpccRandomAccess** benchmark, although it will be skipped automatically if this is not done:
    
    >> cd HPCchallenge
    >> mex randRA.cpp

This version is tested with Matlab release 2012b and later.

### Running the benchmark

The main executable is the script `runAll.m` (which in turn calls the specific `runAll.m` under each of the benchmark category directories, e.g., `HPCchallenge/runAll.m` and `pSPOT/runAll.m`). This will return a cell-array of benchmark results for individual benchmarks (see section **Result report** below), and write it a specified file in JSON format.

The benchmarks mainly depend on two variables:

- number of MPI processes (Matlab PCT workers)
- (approximate) amount of memory usage allowed for each process/worker

In addition, the user needs to provision a working `matlabpool` instance before running `runAll.m`. This is the level at which resource types are defined (e.g., number of nodes and which ones, number of processes per node).

#### Usage example

Assuming that you want to use 6 nodes, each allowing 4 processes, for a total of 24 workers. For each process you want to use a maximum of 16 GB of memory available on the node (perhaps a little less than that, say 15 GB, for safety against burst access). In addition, you have a Matlab PCT profile called `CLUSTERPROFILE_6NODE_4PPN` that provisions these resources for `matlabpool`, then the following commands will run the complete benchmark suite (make sure you are in main directory, **not** in any of the subdirectories):
    
    >> matlabpool CLUSTERPROFILE_6NODE_4PPN 24
    >> runAll('benchmarkResult_6node_4ppn', 24, 15, 6, 4, 'this is a demo run')

The `runAll()` function will return a cell-array of benchmark results, as well as write them in JSON format to a file called `benchmarkResult_6node_4ppn.json`. The last three arguments are simply for record-keeping: the function itself does not know how many nodes are used and how many processes live on each. The last argument is a string that is stored along with the rest of the benchmark numbers (in the `remark` field) and is useful for comments.

For reference, `runAll.m` is declared as:

    bench_results = runAll(save_filename,num_workers,memoryPerWorker_inGB, {,numNodes,numProcPerNode,remarks})


### Result report

Results for each individual benchmark is saved represented as a struct by the following standardized fields (as specified by the constructor `matlabPCTBenchReport.m`):

     benchmarkName:     string
     date:              string, in format 'mmmm dd, yyyy HH:MM:SS AM'
     numWorkers:        int
     memPerWorkerInGB:  float
     timeInSec:         float
     problemSize:       float
     problemSizeUnit:   string
     performance:       float
     performanceUnit:   string
     notes:             (optional struct, only for record-keeping)
         numNodes:      int
         numProcPerNode: int
         remark:        string

Here's a concrete example of such a struct:

       benchmarkName: 'FourDimFFT'
                date: 'September 14, 2013  1:11:00 AM'
           timeInSec: 4.7214
          numWorkers: 2
    memPerWorkerInGB: 0.2500
         problemSize: 0.0588
     problemSizeUnit: 'GB'
         performance: 0.1915
     performanceUnit: 'GFlops'
               notes: [1x1 struct]

The `runAll.m` functions return benchmark results as a cell-array of these structs. In addition, the main `runAll.m` function under the base directory can save this cell-array in JSON notation to a file. The main identifier for these records should be a unique filename.


created by Tim T.Y. Lin on 2013-09-15  
Copyright (c) 2013 SLIM. All rights reserved.
