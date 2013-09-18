classdef opKron < opSpot
%OPKRON   Kronecker tensor product.
%
%   opKron(OP1,OP2,...OPn) creates an operator that is the Kronecker
%   tensor product of OP1, OP2, ..., OPn.

%   Copyright 2009, Rayan Saab, Ewout van den Berg and 
%   Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        permutation; %Permutation vector of intergers defining the order to
        %use when the operators (children) of the Kronecker product are
        %applied to a data vector.
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op = opKron(varargin)
            narg=nargin;
            
            %Test the case where varargin is a list
            if narg == 1
                narg=length(varargin{1});
                varargin=varargin{1};
            end
            
            if narg < 2
                error('At least two operators must be specified')
            end
            
            % Input matrices are immediately cast to opMatrix.
            for i=1:narg
                if isa(varargin{i},'numeric')
                    varargin{i} = opMatrix(varargin{i});
                elseif ~isa(varargin{i},'opSpot')
                    error('One of the operators is not a valid input.')
                end
            end
            
            % Determine operator size and complexity (this code is
            % general for any number of operators)
            opA       = varargin{1};
            [m,n]     = size(opA);
            cflag     = opA.cflag;
            linear    = opA.linear;
            sweepflag = opA.sweepflag;
            
            for i=2:narg
                opA       = varargin{i};
                cflag     = cflag  | opA.cflag;
                linear    = linear & opA.linear;
                sweepflag = sweepflag & opA.sweepflag;
                [mi,ni]   = size(opA);
                m = m * mi; n = n * ni;
            end
            
            % Construct operator
            op = op@opSpot('Kron', m, n);
            op.cflag       = cflag;
            op.linear      = linear;
            op.sweepflag   = sweepflag;
            op.children    = varargin;
            op.permutation =(1:narg);
            
            %Evaluate the best permutation to use when a multiplication is
            %applied
            if ~ (m == 0 || n == 0)
                op.permutation=op.best_permutation();
            end
            
            % Setting up implicit dimensions of output vector
            % Flipped
            varargin = fliplr(varargin);
            len      = length(varargin);
            op.ms    = cell(1,len);
            op.ns    = cell(1,len);
            for u = 1:len
                child_op = varargin{u};
                if length(child_op.ms) > 1
                    op.ms{u} = [op.ms{u} child_op.ms(:)'];
                else
                    op.ms{u} = [op.ms{u} child_op.ms{:}];
                end
                if length(child_op.ns) > 1
                    op.ns{u} = [op.ns{u} child_op.ns(:)'];
                else
                    op.ns{u} = [op.ns{u} child_op.ns{:}];
                end
            end
                
        end % Constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function str = char(op)
            str=['Kron(',char(op.children{1})];
            
            % Get operators
            for i=2:length(op.children)
                str=strcat(str,[', ',char(op.children{i})]);
            end
            str=strcat(str,')');
        end % Char
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % headerMod
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function h = headerMod(op,header,mode)
            % Extract explicit size indices
            exsize = header.exsize;
            href   = @spot.data.headerRef; % Used function handles because
            hasg   = @spot.data.headerAsgn; % its shorter

            if mode == 1
                
                % Setup variables
                opList = fliplr(op.children); % Last op applied first
                % Number of output dimensions
                n_out_dims = length(spot.utils.uncell(op.ms)) +...
                                                        size(exsize,2) - 1;
                
                % Preallocate and setup header
                header_out        = header;
                header_out.dims   = n_out_dims;
                header_out.size   = zeros(1,n_out_dims);
                header_out.origin = zeros(1,n_out_dims);
                header_out.delta  = zeros(1,n_out_dims);
                header_out.unit   = zeros(1,n_out_dims);
                header_out.label  = zeros(1,n_out_dims);
                
                % Fill in the non-first-dimension header parts
                if size(exsize,2) > 1
                    h_part = href(header,exsize(1,2):exsize(end,end));
                    header_out = hasg(header_out,h_part,...
                        length(spot.utils.uncell(op.ms))+1:...
                        length(header_out.size));
                end
                
                % Replace old first (collapsed) dimensional sizes with
                % operator sizes.
                i = 1;
                x = 1;
                % Extract collapsed first dims from header.
                first_header = href(header,exsize(:,1));
                for u = 1:length(op.children)
                    % Input header (including collapsed)
                    y            = length(spot.utils.uncell(op.ns{u}))+x-1;
                    in_header    = href(first_header,x:y);
                    in_header.exsize = [1;y-x+1];
                    % child header
                    child_header = headerMod(opList{u},in_header,mode);
                    % Assignment indices
                    j            = length(spot.utils.uncell(op.ms{u}))+i-1;
                    % header assignment
                    oldsize      = length(header_out.size);
                    header_out   = hasg(header_out,child_header,i:j);
                    newsize      = length(header_out.size);
                    i            = j + 1 + newsize - oldsize;
                    x            = y + 1;
                end
                exsize_out = 1:length(header_out.size);
                exsize_out = [exsize_out;exsize_out];
                h          = header_out;
                h.exsize   = exsize_out;
            else
                % Setup variables
                opList = fliplr(op.children); % Last op applied first
                % Number of output dimensions
                n_out_dims = length(spot.utils.uncell(op.ns)) +...
                                                        size(exsize,2) - 1;
                
                % Preallocate and setup header
                header_out        = header;
                header_out.dims   = n_out_dims;
                header_out.size   = zeros(1,n_out_dims);
                header_out.origin = zeros(1,n_out_dims);
                header_out.delta  = zeros(1,n_out_dims);
                header_out.unit   = zeros(1,n_out_dims);
                header_out.label  = zeros(1,n_out_dims);
                
                % Fill in the non-first-dimension header parts
                if size(exsize,2) > 1
                    h_part = href(header,exsize(1,2):exsize(end,end));
                    header_out = hasg(header_out,h_part,...
                        length(spot.utils.uncell(op.ms))+1:...
                        length(header_out.size));
                end
                
                % Replace old first (collapsed) dimensional sizes with 
                % operator sizes.
                i = 1;
                x = 1;
                % Extract collapsed first dims from header.
                first_header = href(header,exsize(:,1));
                for u = 1:length(op.children)
                    % Input header (including collapsed)
                    y            = length(spot.utils.uncell(op.ms{u}))+x-1;
                    in_header    = href(first_header,x:y);
                    in_header.exsize = [1;y-x+1];
                    % child header
                    child_header = headerMod(opList{u},in_header,mode);
                    % Assignment indices
                    j            = length(spot.utils.uncell(op.ns{u}))+i-1;
                    % header assignment
                    oldsize      = length(header_out.size);
                    header_out   = hasg(header_out,child_header,i:j);
                    newsize      = length(header_out.size);
                    i            = j + 1 + newsize - oldsize;
                    x            = y + 1;
                end
                exsize_out = 1:length(header_out.size);
                exsize_out = [exsize_out;exsize_out];
                h          = header_out;
                h.exsize   = exsize_out;
            end
            
        end % headerMod
    end % Methods
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Protected methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods ( Access = protected )
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Multiply
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function y = multiply(op,x,mode)
            
            % The Kronecker product (KP) is applied to the righthand matrix
            % taking in account the best order to apply the operators.
            % That necessitates to decompose the KP in successive matrix
            % products with terms of type I(a) kron A kron I(b).
            % A is the operator to apply. I(a) and I(b) are identity
            % matrices with respective sizes a and b.
            
            opList       = op.children; % Contains list of opKron children
            ncol         = size(x,2); % Number of columns of 'x'
            nbr_children = length(opList); % Number of children
            
            % Pre-registering of the sizes of opKron's children
            sizes = zeros(nbr_children,2);
            for i=1:nbr_children
                sizes(i,:) = size(opList{i});
            end
            
            %%%%%%%%%%%%%%%%%%%%%%Multiplication%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if mode == 1 % Classic mode
                perm = op.permutation; % Permutation to take in account.
                m = op.m; % Height of the resulting matrix
                
                for i = 1:nbr_children
                    % Index of the operator A to consider.
                    index = perm(i);
                    
                    % Calculation of the sizes of the identity matrixs used
                    % in the Kronecker product I(a) kron A kron I(b)
                    
                    % Size of I(a)
                    a = 1;
                    for k = 1:(index-1)
                        if i > find(perm==k)
                            a = a * sizes(k,1);
                        else
                            a = a * sizes(k,2);
                        end
                    end
                    
                    % If 'x' has several columns. The initial matrix I(a)
                    % kron A kron I(b) is replicated 'ncol' (number of
                    % columns of x) times) along the diagonal.
                    if ncol>1
                        a=a*ncol;
                    end
                    
                    % Size of I(b)
                    b = 1;
                    for k = (index+1):nbr_children
                        if i > find(perm==k)
                            b = b * sizes(k,1);
                        else
                            b = b * sizes(k,2);
                        end
                    end
                    
                    % Size of the operator A=opList{index} to apply
                    r = sizes(index,1);
                    c = sizes(index,2);
                    
                    % (I(a) kron A kron I(b)) * x;
                    t = reshape(reshape(x,b,a*c).',c,a*b);
                    x = reshape(applyMultiply(opList{index},t,1)',a,r*b)';
                end
                y = reshape(x,m,ncol);
                
            elseif mode == 2 % Transpose mode
                perm = op.permutation(length(opList):-1:1); % The
                % permutation has to be in the other direction since with
                % transposition, operators' computational costs will be
                % inverted.
                n = op.n; % Height of the resulting matrix
                
                for i = 1:nbr_children
                    %Index of the operator A to consider.
                    index = perm(i);
                    
                    % Calculation of the sizes of the identity matrixs used
                    % in the Kronecker product I(a) kron A kron I(b)
                    
                    %Size of I(a)
                    a = 1;
                    for k = 1:(index-1)
                        if i > find(perm==k)
                            a = a * size(opList{k},2);
                        else
                            a = a * size(opList{k},1);
                        end
                    end
                    
                    % If 'x' has several columns. The initial matrix I(a)
                    % kron A kron I(b) is replicated 'ncol' (number of
                    % columns of x) times) along the diagonal.
                    if ncol>1
                        a = a*ncol;
                    end
                    
                    % Size of I(b)
                    b = 1;
                    for k = (index+1):length(opList)
                        if i > find(perm==k)
                            b = b * size(opList{k},2);
                        else
                            b = b * size(opList{k},1);
                        end
                    end
                    
                    % Size of the operator A=opList{index} to apply
                    r = sizes(index,2);
                    c = sizes(index,1);
                    
                    % (I(a) kron A kron I(b)) * x;
                    t = reshape(reshape(x,b,a*c).',c,a*b);
                    x = reshape(applyMultiply(opList{index},t,2)',a,r*b)';
                end
                y = reshape(x,n,ncol);
            end
        end % Multiply
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Divide
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function x = divide(op,b,mode)
            % Depends on sweepflag
            if op.sweepflag
                x = matldivide(op,b,mode);
            else
                x = lsqrdivide(op,b,mode);
            end
        end % divide
        
    end %Protected methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % best_permutation
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Returns the best permutation associated to this Kronecker product
        function perm = best_permutation(op)
            list = op.children; % List of 'op''s children
            cost = zeros(length(list),2); % Computational costs of the
            % operators (children of 'op'). This is simply a numeric
            % representation of theirs shapes, which will affect 
            % computation time. Operators with low computational costs 
            % should be applied first.
            for i=1:length(list)
                % Cost = (nbr_rows-nbr_columns) / (size of the operator)
                cost(i,1) = (size(list{i},1)-size(list{i},2))/...
                    (size(list{i},1)*size(list{i},2));
                cost(i,2)=int8(i);
            end
            cost=sortrows(cost)';
            
            perm = cost(2,:);
        end
        
    end % private methods
end % opKron
