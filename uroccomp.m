function uroccomp(x,y,varargin)
%UROCCOMP Compare two unpaired ROC curves.
%
%   Syntax
%   ------
%   uroccomp(X, Y)
%   uroccomp(X, Y, ALPHA)
%
%   Description
%   -----------
%   UROCCOMP compares two unpaired ROC curves derived from two
%   independent datasets X and Y. Each dataset must contain a
%   continuous (or ordinal) diagnostic test value and a binary
%   class label (healthy vs diseased).
%
%   The function:
%     * computes ROC curves for X and Y by calling ROC
%     * extracts the AUC (Area Under the Curve) and its standard error
%     * performs a z-test for the difference between the two AUCs
%     * displays the results in tabular form
%     * plots both ROC curves on the same figure
%
%   Inputs
%   ------
%   X : N1-by-2 numeric matrix
%       X(:,1) = test values
%       X(:,2) = class labels
%                1 = unhealthy / diseased
%                0 = healthy / non-diseased
%
%   Y : N2-by-2 numeric matrix
%       Y(:,1) = test values
%       Y(:,2) = class labels
%                1 = unhealthy / diseased
%                0 = healthy / non-diseased
%
%   ALPHA (optional) : significance level for the z-test comparing
%                      AUC(X) and AUC(Y).
%                      Default: 0.05, with 0 < ALPHA < 1.
%
%   Outputs
%   -------
%   This function does not return any output arguments. It:
%     * prints a summary of AUCs and their standard errors
%     * prints the z-value and p-value for the difference between AUCs
%     * displays a plot with both ROC curves
%
%   Example
%   -------
%   % X and Y are N-by-2 matrices: [test_value, class_label]
%   % class_label: 1 = diseased, 0 = healthy
%   %
%   % Basic usage:
%   uroccomp(X, Y);
%   %
%   % With specified significance level:
%   uroccomp(X, Y, 0.01);
%
%   Dependencies
%   ------------
%   This function requires:
%     * ROC.m (Receiver Operating Characteristic analysis)
%       available at: https://github.com/dnafinder/roc
%
%   ROC, in turn, depends on:
%     * MWWTEST.m (Mann–Whitney–Wilcoxon test)
%       available at: https://github.com/dnafinder/mwwtest
%
%   Notes
%   -----
%   * X and Y must contain both healthy (0) and unhealthy (1) subjects.
%     If one of the groups contains only healthy or only unhealthy
%     subjects, an error is thrown.
%   * This routine assumes the two ROC curves are derived from
%     independent (unpaired) datasets.
%   * The comparison is based on:
%       z = |AUC1 - AUC2| / sqrt(SE1^2 + SE2^2)
%     with a two-sided p-value.
%
%   References
%   ----------
%   Cardillo G. (2009). uROCcomp: compare two unpaired ROC curves.
%
%   ------------------------------------------------------------------
%   Author : Giuseppe Cardillo
%   Email  : giuseppe.cardillo.75@gmail.com
%   GitHub : https://github.com/dnafinder/uroccomp
%   Created: 2009
%   Updated: 2025-11-26
%   Version: 2.0.0
%   ------------------------------------------------------------------

% --- Dependency check: ROC must be available --------------------------------
if exist('roc','file') ~= 2
    error('UROCCOMP:MissingDependency', ...
        ['ROC.m is required but was not found on the MATLAB path. ', ...
         'Please download it from https://github.com/dnafinder/roc ', ...
         'and add it to your MATLAB path before calling UROCCOMP.']);
end

% --- Input Error Handling ----------------------------------------------------
p = inputParser;
addRequired(p,'x',@(z) validateattributes(z,{'numeric'},...
    {'2d','real','finite','nonnan','nonempty','ncols',2}));
addRequired(p,'y',@(z) validateattributes(z,{'numeric'},...
    {'2d','real','finite','nonnan','nonempty','ncols',2}));
addOptional(p,'alpha',0.05, @(z) validateattributes(z,{'numeric'},...
    {'scalar','real','finite','nonnan','>',0,'<',1}));

parse(p,x,y,varargin{:});
alpha = p.Results.alpha;
clear p

% --- Validate class labels for X --------------------------------------------
if ~all(x(:,2)==0 | x(:,2)==1)
    error('UROCCOMP:InvalidLabelsX', ...
        'All values in X(:,2) must be 0 or 1.');
end
if all(x(:,2)==0)
    error('UROCCOMP:OnlyHealthyX', ...
        'There are only healthy subjects in X.');
end
if all(x(:,2)==1)
    error('UROCCOMP:OnlyUnhealthyX', ...
        'There are only unhealthy subjects in X.');
end

% --- Validate class labels for Y --------------------------------------------
if ~all(y(:,2)==0 | y(:,2)==1)
    error('UROCCOMP:InvalidLabelsY', ...
        'All values in Y(:,2) must be 0 or 1.');
end
if all(y(:,2)==0)
    error('UROCCOMP:OnlyHealthyY', ...
        'There are only healthy subjects in Y.');
end
if all(y(:,2)==1)
    error('UROCCOMP:OnlyUnhealthyY', ...
        'There are only unhealthy subjects in Y.');
end

% --- Compute ROC curves (no verbose, no plotting) ---------------------------
curve1 = roc(x,0,alpha,0,0);
curve2 = roc(y,0,alpha,0,0);

% Areas and standard errors
A  = [curve1.AUC, curve2.AUC];
SE = [curve1.SE,  curve2.SE];

% --- Display results ---------------------------------------------------------
tr = repmat('-',1,80);
disp('UNPAIRED ROC CURVES COMPARISON')
disp(tr)
disp(array2table([A;SE], ...
    'VariableNames',{'ROC1','ROC2'}, ...
    'RowNames',{'AUC','Standard_error'}))

z = abs(diff(A))/realsqrt(sum(SE.^2));
p = (1 - 0.5*erfc(-z/realsqrt(2))) * 2; % two-sided p-value

if p <= alpha
    txt = 'The areas are statistically different';
else
    txt = 'The areas are not statistically different';
end

disp(cell2table({z, p, txt}, ...
    'VariableNames',{'z_value','p_value','Comment'}))

% --- Plot both ROC curves ----------------------------------------------------
H = figure;
set(H,'Position',[100 100 560 500])
axis square; hold on
h1 = stairs(curve1.xr, curve1.yr, 'r','LineWidth',2);
h2 = stairs(curve2.xr, curve2.yr, 'b','LineWidth',2);
plot([0 1],[0 1],'k--') % chance line
xlabel('False positive rate (1 - Specificity)')
ylabel('True positive rate (Sensitivity)')
title('ROC Curves Comparison')
legend([h1 h2],{'ROC curve 1','ROC curve 2'},'Location','BestOutside')
grid on
hold off

end
