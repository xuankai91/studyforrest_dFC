function reverse_plot(PC_index,percent,scalelim)
%visualise PCs in the Schaefer 419-by-419 plot
%use the percent argument to take only the top X percent of coeff weights
%(0 to 100)
%use the scalelim argument to set the heatmap scale boundaries (fraction of
%max absolute weight, 0 to 1)
%plots will be Z-scored

% PC = 1;
% percent = 5;

if nargin<2
    percent  = 100;
    scalelim = .6;
elseif nargin<3
    scalelim = .6;
end

%col=PC_index;

M = csvread("C:\Users\Xuan Kai\studyforrest_dFC\PCA\coefficients.csv",0,PC_index,[0 min(PC_index) 87570 max(PC_index)]);

M = (M-mean(M))./std(M);

%ZM = (M-mean(M))/std(M);
S = sort(unique(abs(M)),'descend');
M_10 = M.*(abs(M)>=S(round(length(S)/100*percent)));

%set limit
plot_lim = scalelim*max(abs(M_10));

% rebuild 419-by-419 matrix
Matrix = zeros(419);

st=1;
count=418;
for i=1:418
    
    Matrix(i+1:419,i) = M_10(st:(count+st-1));
    
    st = st+count;
    count = count-1;
    
end

Arranged = Matrix + Matrix';

lh2lh = Arranged(1:200,1:200);
rh2rh = Arranged(201:400,201:400);
sc2sc = Arranged(401:419,401:419);

lh2rh = Arranged(1:200,201:400);
lh2sc = Arranged(1:200,401:419);
rh2sc = Arranged(201:400,401:419);

savedir = sprintf("C:\Users\Xuan Kai\studyforrest_dFC\PCA\Plots\top%d",percent);

if ~exist(savedir)
    mkdir(savedir);
end

%plot (function from CBIG repo)
CBIG_Plot_Schaefer400_17Networks19SubcorRearrCorrMat_WhiteGrid(lh2lh,lh2rh,rh2rh,...
    lh2sc,rh2sc,sc2sc,[-plot_lim plot_lim],[savedir sprintf('PC%d',PC_index+1)]);
end
