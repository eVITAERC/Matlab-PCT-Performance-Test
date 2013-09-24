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

The `runAll.m` function is declared as:

    bench_results = runAll(save_filename,numNodes,numProcPerNode,memoryPerWorker_inGB {,remarks})

Assuming that you want to use 8 nodes with 4 processes/workers each, for a total of 32 workers. For of the process/workers you want to use a maximum of 16 GB of memory (we'll use a bit a little less than that, perhaps 15 GB, for safety against burst overhead usage), which totals 64 GB of memory per node. In addition, you have a Matlab PCT profile called `CLUSTERPROFILE_8NODE_4PPN` that provisions these resources for a `matlabpool` environment, then the following commands will run the complete benchmark suite (make sure you are in main directory, **not** in any of the subdirectories):
    
    >> matlabpool CLUSTERPROFILE_8NODE_4PPN 24
    >> runAll('benchmarkResult_8node_4ppn', 8, 4, 15, 'this is a demo run')
    >> matlabpool close

The `runAll()` function will return a cell-array of benchmark results, as well as write them in JSON format to a file called `benchmarkResult_8node_4ppn.json`. The last argument is an optional string that is stored along with the rest of the benchmark numbers (in the `remark` field) and is useful for comments.

It's important that your Matlab PCT profile allocates the right number of nodes and processors per node. The `matlabpool` environment, by construction, only have knowledge of the number of total workers. It knows nothing about how the workers are distributed across different nodes. The `runAll()` function will simply calculate the total number of workers available by multiplying `numNodes` with `numProcPerNode`, and give their product to the individual benchmarks (as well as record `numNodes` and `numProcPerNode` in the benchmark results). It will *not* check that the specified number of nodes and ppn is actually allocated correctly by your profile.

**IMPORTANT**: Due to limitations in the implementation of some of the benchmarks in `HPCchallenge`, the total number of workers needs be a power of 2.

#### Recovery from errors or interrupts

Some of the benchmarks will render an existing `matlabpool` environment unusable if error occurred or if interrupted (with, e.g., `ctrl-c`). Anytime that a benchmark suite cannot complete successfully, make sure that you always destroy the existing `matlabpool` environment and return to the root directory by executing
    
    >> matlabpool close force
    >> cd HPCBENCH_DIR

where `HPCBENCH_DIR` is the base directory of this program, before attempting another benchmark run.

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
