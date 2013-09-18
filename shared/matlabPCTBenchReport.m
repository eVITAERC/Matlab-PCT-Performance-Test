function report = matlabPCTBenchReport(varargin)
% Produces a struct that contains performance results for a particular Matlab PCT benchmark run
%    USAGE: report = matlabPCTBenchReport(benchmarkName,timeInSec {,'param1',value1,'param2','value2',...})
%    
%    Required
%       benchmarkName:      (string) name of specific benchmark
%       timeInSec:          (float) execution wall-time in seconds
%    Optional Parameters
%       'numWorkers':       (int) number of PCT workers used
%       'memPerWorkerInGB': (float) max memory usage per worker, used to determine problem size
%       'problemSize':      (float) size of the problem, specified in units of _problemSizeUnit_
%       'problemSizeUnit':  (string) unit for _problemSize_
%       'performance':      (float) specific performance indicator, higher should be better, in units of _performanceUnit_
%       'performanceUnit':  (string) unit for _problemSize_
%       'numNodes':         (int) number of nodes allocated for this benchmark run
%       'numProcPerNode':   (int) number of processors per node
%       'remark':           (string) additional comments
% 
% Output struct will have the following fields:
%   
%    - benchmarkName: String
%    - date: String, produced with matlab function: datestr(now,'mmmm dd, yyyy HH:MM:SS AM')
%    - numWorkers: int
%    - memPerWorkerInGB: float
%    - timeInSec: float
%    - problemSize: float
%    - problemSizeUnit: String
%    - performance: float
%    - performanceUnit: String
%    - notes:  % optional struct, only for record-keeping
%        - numNodes: int
%        - numProcPerNode: int
%        - remark: String
%
%   wirtten by Tim Lin for SLIM
%   Copyright SLIM-UBC 2013


argParser = inputParser;

% BEGIN params ========================================

    % GAPn specific parameters (passed to solver)
    addRequired(argParser, 'benchmarkName', @ischar);
    addRequired(argParser, 'timeInSec', @isnumeric);
    addParamValue(argParser, 'numWorkers', [], @isnumeric);
    addParamValue(argParser, 'memPerWorkerInGB', [], @isnumeric);
    addParamValue(argParser, 'problemSize', [], @isnumeric);
    addParamValue(argParser, 'problemSizeUnit', '', @ischar);
    addParamValue(argParser, 'performance', [], @isnumeric);
    addParamValue(argParser, 'performanceUnit', '', @ischar);
    addParamValue(argParser, 'numNodes', [], @isnumeric);
    addParamValue(argParser, 'numProcPerNode', [], @isnumeric);
    addParamValue(argParser, 'remark', '', @ischar);
    
    parse(argParser,varargin{:});
    inp = argParser.Results;
    
% END params ==========================================

report = struct();

report.benchmarkName = inp.benchmarkName;
report.date = datestr(now,'mmmm dd, yyyy HH:MM:SS AM');
report.timeInSec = inp.timeInSec;
report.numWorkers = inp.numWorkers;
report.memPerWorkerInGB = inp.memPerWorkerInGB;
report.problemSize = inp.problemSize;
report.problemSizeUnit = inp.problemSizeUnit;
report.performance = inp.performance;
report.performanceUnit = inp.performanceUnit;

notes = struct();
notes.numNodes = inp.numNodes;
notes.numProcPerNode = inp.numProcPerNode;
notes.remark = inp.remark;

report.notes = notes;

