function [dist, d, D, w] = dtw(t, r, args)
%DTW Dynamic time warping algorithm.
%   [dist, w, d, D] = DTW(t, r, opts) computes the modified dtw distance 
%   between t and r, where t and r are both N-by-M matrices and M is the 
%   time step and often different. The output d is the distance matrices 
%   and D is the distance accumulation matrix. w is the optimal warp 
%   calculated when calpath flag set to true.
%
%   Modified dtw accepts the following options:
%   `uo`/`do`:: 0        Set the up/down offset.
%   `ur`/`dr`:: 1        Set the up/down ratio.
%   `sp`:: `false`       Set to true in order to enable step pattern dtw.
%   `calpath`:: `false`  Set to true in order to enable path calculation.
%
%   Notes
%   -------
%   The iteration formula of D in this version is as follows:
%   D(i,j) = d(Ti,Rj) + min([ur*D(i-1,j-1)+uo, D(i-1,j), dr*D(i,j-1)+do])
%
%   Example
%   -------
%   r = rand([10,2]); t = rand([20,2]);
%   opts.uo = 0.05;
%   dist = dtw(r,t,opts)

%   Copyright 2016-2017 BIP Lab in SCUT.

% initialization
opts.uo = 0;
opts.do = 0;
opts.ur = 1;
opts.dr = 1;
opts.sp = false;
opts.calpath = false;
if nargin > 2
    opts = argparse(opts, args);
end

% normalize the input size
t = t'; r = r';
[features, N] = size(t);
[~, M] = size(r);

d = zeros(N, M);
for i = 1 : features
    d = bsxfun(@minus, t(i, :)', r(i, :)).^2 + d ;
end
d = sqrt(d);

D = zeros(size(d));
D(1, 1) = d(1, 1);

if ~opts.sp
    for n = 2 : N
        D(n, 1) = d(n, 1) + D(n-1, 1);
    end
    for m = 2 : M
        D(1, m) = d(1, m) + D(1, m-1);
    end
    for n = 2 : N
        for m = 2 : M
            D(n, m) = d(n, m) + min([opts.ur * D(n-1, m) + opts.uo, D(n-1, m-1), opts.dr * D(n, m-1) + opts.do]);
        end
    end
else
    % step pattern
    for n = 2 : N
        D(n, 1) = d(n, 1) + D(n-1, 1);
        D(n, 2) = d(n, 2) + D(n-1, 1);
    end
    for m = 2 : M
        D(1, m) = d(1, m) + D(1, m-1);
        D(2, m) = d(2, m) + D(1, m-1);
    end
    for n = 3 : N
        for m = 3 : M
            D(n, m) = d(n, m) + min([opts.ur * D(n-1, m-2) + opts.uo, D(n-1, m-1), opts.dr *  D(n-2, m-1) + opts.do]);
        end
    end
end
dist = D(N, M);

% calculate the warp path
if opts.calpath
    n = N;
    m = M;
    k = 1;
    w = [];
    w(1, :) = [N, M];           
    if ~opts.sp
        while ((n + m) ~= 2)
            if (n-1) == 0
                m = m - 1;
            elseif (m - 1) == 0
                n = n - 1;
            else 
                [~, number] = min([opts.ur * D(n-1, m) + opts.uo, D(n-1, m-1), opts.dr * D(n, m-1) + opts.do]);
                switch number
                case 1
                    n = n - 1;
                case 2
                    n = n - 1;
                    m = m - 1;
                case 3
                    m = m - 1;
                end
            end
            k = k + 1;
            w = cat(1, w, [n, m]);
        end
    else
        % step pattern case
        while ((n + m) ~= 2)
            if (n - 1) == 0
                m = m - 1;
            elseif (m - 1) == 0
                n = n - 1;
            elseif (n - 2) == 0
                n = n - 1;
                m = m - 1;
            elseif (m - 2) == 0
                n = n - 1;
                m = m - 1;
            else 
                [~, number] = min([opts.ur * D(n-1, m-2) + opts.uo, D(n-1, m-1), opts.dr * D(n-2, m-1) + opts.do]);
                switch number
                case 1
                    n = n - 1;
                    m = m - 2;
                case 2
                    n = n - 1;
                    m = m - 1;
                case 3
                    n = n - 2;
                    m = m - 1;
                end
            end
            k = k + 1;
            w = cat(1, w, [n, m]);
        end
    end
end
end

function opts = argparse(opts, args)
    argsNames = fieldnames(args);
    optsNames = fieldnames(opts);
    for i = 1 : numel(argsNames)
        for j = 1 : numel(optsNames)
            if strcmp(optsNames{j},argsNames{i})
                opts.(argsNames{i}) = args.(argsNames{i});
            end
        end
    end   
end

    
    