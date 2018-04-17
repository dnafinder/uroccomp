function uroccomp(x,y,varargin)
% UROCCOMP - Compare two unpaired ROC curves
% The ROC graphs are a useful tecnique for organizing classifiers and
% visualizing their performance. ROC graphs are commonly used in medical
% decision making.
% This function compares two unpaired ROC curves using my previously
% submitted routine ROC
% (http://www.mathworks.com/matlabcentral/fileexchange/19950)
% If this file is absent, uroccomp will try to download it from FEX.
%
% Syntax: uroccomp(x,y,alpha)
%
% Input: x and y - These are the data matrix. 
%                  The first column is the column of the data value;
%                  The second column is the column of the tag: 
%                  unhealthy (1) and healthy (0).
%          alpha - significance level (default 0.05)
%
% Output: The ROC plots;
%         The z-test to compare Areas under the curves
%
%   run uroccompdemo to see an example
%
%           Created by Giuseppe Cardillo
%           giuseppe.cardillo-edta@poste.it
%
% To cite this file, this would be an appropriate format:
% Cardillo G. (2009) uROCcomp: compare two unpaired ROC curves.
% http://www.mathworks.com/matlabcentral/fileexchange/23020

%Input Error handling
p=inputParser;
addRequired(p,'x',@(x) validateattributes(x,{'numeric'},{'2d','real','finite','nonnan','nonempty','ncols',2}));
addRequired(p,'y',@(x) validateattributes(x,{'numeric'},{'2d','real','finite','nonnan','nonempty','ncols',2}));
addOptional(p,'alpha',0.05, @(x) validateattributes(x,{'numeric'},{'scalar','real','finite','nonnan','>',0,'<',1}));
parse(p,x,y,varargin{:});
alpha=p.Results.alpha; 
clear p
x(:,2)=logical(x(:,2));
if all(x(:,2)==0)
    error('Warning: there are only healthy subjects!')
end
if all(x(:,2)==1)
    error('Warning: there are only unhealthy subjects!')
end
x(:,2)=logical(x(:,2));
if all(y(:,2)==0)
    error('Warning: there are only healthy subjects!')
end
if all(y(:,2)==1)
    error('Warning: there are only unhealthy subjects!')
end

if exist('roc.m','file')==0
    filename=unzip('https://it.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/19950/versions/35/download/zip','prova');
    Index = contains(filename,'roc.m');
    current=cd;
    copyfile(filename{Index},current)
    rmdir('prova','s')
    clear filename Index current
end

curve1=roc(x,0,alpha,0);
curve2=roc(y,0,alpha,0);
%Areas
A=[curve1.AUC,curve2.AUC];
%standard errors
SE=[curve1.SE,curve2.SE];

%display results
disp('UNPAIRED ROC CURVES COMPARISON')
disp(repmat('-',1,80))
disp(array2table([A;SE],'VariableNames',{'ROC1','ROC2'},'Rownames',{'AUC','Standard_error'}))
z=abs(diff(A))/realsqrt(sum(SE.^2));
p=(1-0.5*erfc(-z/realsqrt(2)))*2; %p-value
if p<=alpha
    txt='The areas are statistically different';
else
    txt='The areas are not statistically different';
end
disp(cell2table({z,p,txt},'VariableNames',{'z_value','p_value','Comment'}))

xg=linspace(0,1,500);
H=plot(xg,curve1.rocfit(xg),'r',xg,curve2.rocfit(xg),'b');
axis square
xlabel('False positive rate (1-Specificity)')
ylabel('True positive rate (Sensitivity)')
title('ROC Curves Comparison')
legend(H,'ROC curve 1','ROC curve 2','Location','BestOutside')
grid on