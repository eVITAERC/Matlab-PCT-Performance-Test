function subfunc_handle = convolution_multidim2D(nr, ns, scale, geometry_type)
% Y = convolution_multidim2D(nr, ns, geometry_type)
%
% (Acts on monochromatic slices of seismic line, or 2D, data)
% Returns a function for oppDistFun that implements the multi-dimensional
% convolution used in EPSI modeling operator. For split-spread data in A 
% (monochromatic according to detail-hiding operator) and primary IR in
% X, this implements Y = X*A when mode = 1 and its adjoint operation when
% in mode = 2 (on X)
% 
% nr = number of recievers per shot gather
% ns = number of sources
%
% scale = scaling applied to the output
%
% geometry_type can either be 'splitspread' (Data-matrix style) or 'marine'
% (end-on geometry)
%
% 'marine' is for end-on geometry ('marine' style) seismic line data, data
% sorted into shot gathers of decreasing distance, and the traces in
% increasing absolute offset (see changeGeom_marine2datacube_slice for details)
% 
% Y, A, X are matrices of size nr-by-ns (for split spread require nr = ns)

if not(exist('geometry_type','var'))
    geometry_type = 'splitspread';
end

switch geometry_type
    case 'splitspread'
        subfunc_handle = @(A, x, mode) convolution_multidim2D_splitspread_intrnl(A, x, mode);
    case 'marine'
        nr_unknown = nr*2-1;
        subfunc_handle = @(A, x, mode) convolution_multidim2D_marine_intrnl(A, x, mode);
end

    
    % Subfunctions
    function y = convolution_multidim2D_splitspread_intrnl(A, x, mode);
        switch mode
            case 0
                % [m n cflag linflag]
                y = [nr*ns, nr*ns, 1, 1];

            case 1
                x = reshape(x, [nr ns]);
                x = (x + x.') / 2;
                x = scale * x * A;
                x = x(:);
                y = x;

            case 2
                x = reshape(x, [nr ns]);
                x = conj(scale) * x * A';
                x = (x + x.') / 2;
                x = x(:);
                y = x;
        end
    end
    
    function y = convolution_multidim2D_marine_intrnl(A, x, mode);
        switch mode
            case 0
                % [m n cflag linflag]
                y = [nr_unknown*ns, nr_unknown*ns, 1, 1];

            case 1
                x = reshape(x, [nr_unknown ns]);
                
                % Strategy: fill temporary Data-matrices with the marine data, then perform the conv with matrix-mult
                % (this ended up being a surprisingly fast approach due to JIT optimizations)
                x_buffer = changeGeom_marine2datacube_slice(x,'no_recip');
                A_buffer = changeGeom_marine2datacube_slice(A);
                
                x_buffer = (x_buffer + x_buffer.') / 2;
                result_buffer = scale .* (x_buffer * A_buffer);
                
                x = changeGeom_datacube2marine_slice(result_buffer,nr,ns,'no_recip');
                
                x = x(:);
                y = x;

            case 2
                x = reshape(x, [nr_unknown ns]);
                
                x_buffer = changeGeom_marine2datacube_slice(x,'no_recip');
                A_buffer = changeGeom_marine2datacube_slice(A);
                
                result_buffer = conj(scale) .* (x_buffer * A_buffer');
	            result_buffer = (result_buffer + result_buffer.') / 2;
	            
	            x = changeGeom_datacube2marine_slice(result_buffer,nr,ns,'no_recip');
                
                x = x(:);
                y = x;
        end
    end
end