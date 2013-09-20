function [OP_SRMP] = opSRMP(data)
%% OPSRMP      The SRMP prediction operator on 2D survey datacube (takes the data always in time domain)
%  usage: opSRMP(data)
%  
% DISTRIBUTED VERSION: requires "data" to be in a distributed 3D cube with time on the last axis (time-slice gathers),
%                      which should also be the axis that the data is distributed over.
% 
% Tim Lin for SLIM, 2013
  
  if not(exist('geometry_type','var'))
      geometry_type = 'splitspread';
  end
	
	%% Get relavant dimension information (assumes data is: d3=Time, d1=reciever, d2=shots, in time-slices)
	dims =    size(data);
	nt   =    dims(3);
	nr_data   = dims(1);
	ns_data   = dims(2);
    nt_conv = 2*nt; % time sample length of padded kernel for convolution
    switch geometry_type
        case 'splitspread'
            nr = nr_data;
            ns = ns_data;
        case 'marine'
            nr = 2*nr_data-1;
            ns = ns_data;
    end
    
    data = distVectorize(data);
  
	%% Make specialized FFT operators for the convolution and data transformations
	
	% determine number of frequencies 
  F1D = opFFTsym_conv(nt_conv);
	nf = size(F1D,1);

	%% Padding and chopping operators for non-wrap-around Fourier domain convolution
	OPPAD_BOTTOM = opPadBottom([nt 1], nt_conv, 1);
	OPPAD_TOP = opPadTop([nt 1], nt_conv, 1);
	OPCHOP_TOP = OPPAD_TOP';
  OPCHOP_BOTTOM = OPPAD_BOTTOM';
    
  % construct the DFT operators that acts on the whole datacube for (non-circular) multidimensional convolution
	F = oppKron2Lo( F1D * OPPAD_BOTTOM , opDirac(nr*ns) );
	invF = oppKron2Lo( OPCHOP_TOP * F1D' , opDirac(nr*ns) ); % for opFFTsym_conv the adjoint mode implements the inverse

    
  % Make frequency slices of the data for convolution
  F_data = oppKron2Lo(F1D * OPPAD_TOP, opDirac(nr_data*ns));
	data_conv_f = F_data * data; % Convolution is in Fourier domain
	clear data
	data_conv_f = distVec2distArray(data_conv_f,[nr_data ns nf]);	 
	
	%% Finally the multidimentional data-data convolution operators can be constructed
	funcMultidimConv = convolution_multidim2D(nr_data,ns,1,'splitspread');
	P = oppDistFun(data_conv_f, funcMultidimConv, 0);
	
	
	%% Final SRMP is 
  OP_SRMP = invF * P * F;

end