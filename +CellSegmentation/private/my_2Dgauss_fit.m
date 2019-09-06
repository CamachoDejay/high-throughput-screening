function [ x, funct_values, residuals ] = my_2Dgauss_fit( data2fit, x0 )
%Simple fitting of a gaussian function in 2D
%   data2fit consists of two columns, the first with the x_values
%   (observables, e.g. pixels, nm etc.) and the second with the y_values
%   (measurements, e.g. intensity).

x = fminsearch(@(x) myfun2min(x,data2fit),x0);
[funct_values, residuals] = gaussOLSfunction (x, data2fit);

    function f = myfun2min(x,a)
        [~, f] = gaussOLSfunction (x, a);
    end

% OLS fitting of the data by a gaussian by giving a central position and
% sigma value. data to fit is contained in a while gauss parameters are
% contained in x.
    function [Ax, res] = gaussOLSfunction (x, a)        
        x_vals  = a(:,1);
        y_vals  = a(:,2); % measurements

        max_val  = 1;
        cent_pos = x(1);
        sigma    = x(2);
        m        = length(a);
        shape_1  = my_2Dgauss( x_vals, max_val, cent_pos, sigma);
        shape_2  = ones(m,1);
        A = [shape_1(:) shape_2(:)]; % Design matrix
        eps  = lsqnonneg(A,y_vals);  % only positive coefficients 
        Ax   = A*eps;
        r    = y_vals-Ax;
        res  = sum(sum(r.*r)); % Taking the squares is done for convenience.        
    end

% simple function to calculate the values of a gaussian
    function [ vals ] = my_2Dgauss( x, max_val, cent_pos, sigma)
    %Simple gaussian calculation
        a = max_val; %max val
        b = cent_pos; %central position
        c = sigma; %sigma
        vals = exp( ((((x-b).^2)).*(-1)) ./ (2*c^2)  )    .*a;

    end


end

