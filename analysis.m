clear; close all; clc;

scene_transitions = [0	    902     902	  891.2
                     886	1768	882   1759.2
                     1752	2628	876	  2618.8
                     2612	3588	976	  3578.5
                     3572	4496	924	  4488
                     4480	5358	878	  5349.2
                     5342	6426	1084  6418.2
                     6410	7086	676	  7085.5];
      
% bl = [];
% 
% for i=1:6
%     
%     bl = [bl scene_transitions(i,2) - scene_transitions(i,4)];
%     bl = [bl scene_transitions(i,4) - scene_transitions(i+1,1)];
%     
% end
% bl = [bl scene_transitions(8,2) - scene_transitions(8,4)];

%% dFC windows

filepath = ('/mnt/eql/yeo7/data/studyforrest/ds000113d_R2.0.0/preprocessedData/mwfMRI_skip0/Mean_dFC/win55/');

T=zeros(8,1);
winsize = 55;
dropout = (winsize-1)/2;

for runs = 1:8
    
    load([filepath sprintf('/run%d-win55.mat',runs)]); %load run dFC matrices as MeanWinDat
    Data{runs} = MeanWinDat;
    
    T(runs) = size(Data{runs},3); %for checking
    
    temp = (scene_transitions(runs,1)+1):2:scene_transitions(runs,2);
    
    t_stmp{runs} = temp((dropout+1):(size(Data{runs},3)+dropout));
    
    Feature{runs} = [t_stmp{runs}' nan(T(runs),87571)]; % 419*419 - 419 divide by 2
    
    for t = 1:T(runs)
        
        lh = tril(MeanWinDat(:,:,t),-1);
        Feature{runs}(t,2:end) = lh(lh~=0)';
        
    end

end

%% timeseries

filepath_ts = '/mnt/eql/yeo7/data/studyforrest/ds000113d_R2.0.0/preprocessedData/mwfMRI_skip0/Mean_timeseries';

for runs = 1:8
    
    load([filepath_ts sprintf('/run%d-timeseries.mat',runs)]); %load run timeseries as MeanZ
    
%     temp = (scene_transitions(runs,1)+1):2:scene_transitions(runs,2);
%     t_stmp{runs} = temp((dropout+1):(size(MeanZ,1)-dropout)); %t_stmp previously calculated during dFC
    
    FeatureTS{runs} = [t_stmp{runs}' MeanZ(dropout+1:end-dropout,:)]; % 419 ROIs
    
end

%% scene categorising

% note that the timestamps refer to the start of the scene (i.e. movie
% starts at 17s, and the last scene starts at 6945s

scenefile = '/mnt/eql/yeo7/data/studyforrest/gump_emotions/movie_scenes.csv';

fid = fopen(scenefile,'r');
S = textscan(fid,'%s%s%s%s','Delimiter',',');
fclose(fid);

SN = cellfun(@str2num,S{1});

num_cat = double(categorical(S{2})); % convert scene labels to numeric
key =[S{2} num2cell(num_cat)]; %checking

%save key
Z = unique(cellfun(@(x,y)[x ',' num2str(y)], key(:,1), key(:,2),'UniformOutput',0));
fid = fopen('scene_label_key.csv','w');

fprintf(fid,'scene,key,\n'); 
for i=1:size(Z,1)
    fprintf(fid,'%s,\n',Z{i}); 
end
fclose(fid);


F = [ceil(SN) num_cat];

%% repeat matrix for full movie

FullAnnot = [];

for L = 1:size(F,1)-1
    
    t_tofill = F(L,1):F(L+1,1)-1;
    
    filler = [t_tofill' repmat(F(L,:),length(t_tofill),1)];
    
    FullAnnot = [FullAnnot; filler];
    
end
    
t_tofill = F(end,1):scene_transitions(end,2);
filler = [t_tofill' repmat(F(end,:),length(t_tofill),1)]; %get ending scene
FullAnnot = [FullAnnot; filler];


% tag run number
R = zeros(size(FullAnnot,1),1);

for rt = 1:size(FullAnnot,1)-1
    
    R(rt) = find(FullAnnot(rt,1) <= scene_transitions(:,4),1,'first'); %get run number 
    
end

R(end)=8; %last entry is definitely last fun

FullAnnot = [FullAnnot R]; %tag each trial with run number

%% halve the values to match TR

%split into 2nd TR per run, and count mismatch
Prop = zeros(8,1);
for runs=1:8
    
    Working = FullAnnot(FullAnnot(:,4)==runs,:);
    
    A{runs} = [];
    
    if mod(Working(1,1),2) == 1 %if starts with odd number
        if mod(size(Working,1),2) == 1 %if odd number of rows
            rows=3:2:size(Working,1);
            
        else
            rows=3:2:size(Working,1)-1;
        end
    else %if starts with even number
        if mod(size(Working,1),2) == 1 %if odd number of rows
            rows=2:2:size(Working,1)-1;
        else
            rows=2:2:size(Working,1);
        end
    end
    
    for t=rows
        
        if Working(t,3) == Working(t-1,3)          
            A{runs} = [A{runs} 1];
        else
            A{runs} = [A{runs} 0];
        end
        
    end
    
    Annot{runs} = [Working(rows,:) A{runs}'];
    Prop(runs) = mean(A{runs});
end

% for runs=1:8
%     
%     disp(size(FullAnnot(FullAnnot(:,4)==runs,:),1) - (scene_transitions(runs,3)));
%     
% end

%% concatenate complete feature matrix

for runs=1:8
    
    st = find(t_stmp{runs}(1) == Annot{runs}(:,1));
    et = find(t_stmp{runs}(end) == Annot{runs}(:,1));
    
    if(mean(Annot{runs}(st:et,1) == t_stmp{runs}') ==  1)
        Feature{runs} = [Feature{runs} Annot{runs}(st:et,:)];
        FeatureTS{runs} = [FeatureTS{runs} Annot{runs}(st:et,:)];
        disp(['run ' num2str(runs) ' all labelled']);
    else
        Feature{runs} = 'mismatch';
        FeatureTS{runs} = 'mismatch';
        disp(['recheck run ' num2str(runs)]);
    end
    
end

%check timestamp(dFC side), timestamp(label side), scene start time (label
%side), scene category (label side), run no. (label side), consistent(label
%side).

disp('checking...');

for check =  1:5
    
    test_run = randi(8,1);
    test_row = randi(size(Feature{test_run},1)-10,1);
    
    test = Feature{test_run}(test_row,[1 end-4 end-1]);
    
    if(test(1) == test(2) & test(3) == test_run)
        fprintf('check %d: run %d row %d, ok\n',check,test_run,test_row);
    else
        fprintf('ERROR: check %d, run %d row %d problematic\n',check,test_run,test_row)
    end
    
end

% disp('timestamp_dFC | timestamp_label | scene start | scene cat | run no. | consistent? ')
% disp(Feature{test_run}(test_row:test_row+10,[1 end-4:end]));

DataFrame = [];
DataFrameTS = [];

for runs=1:8
    
    DataFrame = [DataFrame; Feature{runs}(:,[1:end-5 end-2:end])];
    DataFrameTS = [DataFrameTS; FeatureTS{runs}(:,[1:end-5 end-2:end])];
end

ConsistentScenes = mean(DataFrame(:,end));

UsableDF = DataFrame(DataFrame(:,end)~=0,1:end-1);
UsableDF_ts = DataFrameTS(DataFrameTS(:,end)~=0,1:end-1);

%to improve memory
clearvars -except UsableDF UsableDF_ts

%% reduce dimensions

to_reduce = UsableDF(:,2:end-2);
to_reduce = (to_reduce - mean(to_reduce,2))./std(to_reduce,0,2); %Z-score by TR

[coeff,score,~,~,exp,mu] = pca(to_reduce);

totvar = cumsum(exp);

explained_var = [exp totvar];

csvwrite('PC_explained_variance.csv',explained_var);

%save data for PCA application to new data
csvwrite('./PCA/coefficients.csv',coeff);
csvwrite('./PCA/score.csv',score);
csvwrite('./PCA/mu.csv',mu);
csvwrite('./PCA/explained_variance.csv',exp);

% cutoffs = [90 95 99 99.9 99.99 99.999];
% 
% table = [];
% 
% for i = 1:6
%     
%     %subplot(3,2,i);
%     %plot(totvar(find(totvar >= cutoffs(i),1,'first'):end));
%     %title(num2str(find(totvar >= cutoffs(i),1,'first')));
%     
%     
%     table = [table; [cutoffs(i) find(totvar >= cutoffs(i),1,'first')]];
%     
% end

% decision made here to take the first n PCs that account for 99%
% variance of the data

var = 99;
chosen_n = find(totvar >= var,1,'first');
%chosen_n = 211;

fprintf('%d PCs account for %d%% variance\n',chosen_n,var);

PCA_Data = [UsableDF(:,1) score(:,1:chosen_n) UsableDF(:,end-1:end)];

% drop scenes with <10 instances
min_val = 10;

[n,bins] = histc(PCA_Data(:,end-1),unique(PCA_Data(:,end-1)));
counts = n(bins);

PCA_Data_min = PCA_Data(counts >= min_val,:);
dropped_scenes = unique(PCA_Data(counts < min_val,end-1));

fid=fopen('dropped_scenes.txt','w');
for i=dropped_scenes
    fprintf(fid,'%d\n',i);
end
fclose(fid);

%count number of times each scene occurred
[C,~,ic] = unique(PCA_Data_min(:,end-1));
a_counts = accumarray(ic,1);
value_counts = [C, a_counts];

fid=fopen('scene_counts.csv','w');
fprintf(fid,'scene,counts\n');
for i=1:size(value_counts,1)
    %sprintf('%d,%d\n',value_counts(i,:));
    fprintf(fid,'%d,%d\n',value_counts(i,:));
end
fclose(fid);



%_CA write to csv
PCA_title = ['TR_second,' ... 
    strjoin(arrayfun(@(x) ['PC' num2str(x)],1:chosen_n,'UniformOutput',false),',') ... 
     ',Scene,Run'];
 
fid = fopen('PCA_title.csv','w');
fprintf(fid,PCA_title);
fclose(fid);

csvwrite(sprintf('PCA_Data_min%d.csv',min_val),PCA_Data_min);

system(sprintf("paste -sd '\n' PCA_title.csv PCA_Data_min%d.csv > PCA_TitledData_min%d.csv",min_val,min_val));
system(sprintf("rm PCA_title.csv PCA_Data_min%d.csv", min_val));


%timeseries write to CSV
TS_Data = UsableDF_ts;

% drop scenes with <10 instances
min_val = 10;

[n,bins] = histc(TS_Data(:,end-1),unique(TS_Data(:,end-1)));
counts = n(bins);

TS_Data_min = TS_Data(counts >= min_val,:);

TS_title = ['TR_second,' ... 
    strjoin(arrayfun(@(x) ['LH' num2str(x)],1:200,'UniformOutput',false),',') ',' ... 
    strjoin(arrayfun(@(x) ['RH' num2str(x)],1:200,'UniformOutput',false),',') ',' ... 
    strjoin(arrayfun(@(x) ['SC' num2str(x)],1:19,'UniformOutput',false),',') ... 
     ',Scene,Run'];

csvwrite(sprintf('timeseries_min%d.csv',min_val),TS_Data_min); %timeseries matched to dFC windows
fid = fopen('timeseries_title.csv','w');
fprintf(fid,TS_title);
fclose(fid);
system(sprintf("paste -sd '\n' timeseries_title.csv timeseries_min%d.csv > timeseries_data_min%d.csv",min_val,min_val));
system(sprintf("rm timeseries_title.csv timeseries_min%d.csv", min_val));



%% counting occurrence of each event

% counts = zeros(length(unique(FullAnnot(:,3))),1);
% 
% for n=1:length(unique(FullAnnot(:,3)))
%     
%     counts(n) = sum(FullAnnot(:,3)==n);
%     
% end
% 
% bar(sort(counts)); %cumulative count

%what cutoff to set? Min certain number of counts?
%do not correct first, try some form of qualitative grouping/recoding


% UC = unique(counts);
% LL=zeros(length(UC(1:7)),1);
% for i=1:length(UC(1:7))
%     
%     LL(i)=sum(counts==UC(i));
%     
% end
% LL = [UC(1:7), LL];