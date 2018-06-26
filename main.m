clc; clear;
rng('default');
% dbstop if error

%% setting
database = 'svc2'; % specify database
training_sample = 5; % set the number of training sample
pflag = true; % P feature flag
training_method = 'pca'; % pca or svm

if strcmp(database, 'mcyt')
    subject = 100;
    sample = 50;
    gsample = 25;
elseif strcmp(database, 'susig')
    subject = 94;
    sample = 30;
    gsample = 20;
elseif strcmp(database, 'svc1') || strcmp(database, 'svc2')
    subject = 40;
    sample = 40;
    gsample = 20;
    if strcmp(database, 'svc1') 
        pflag = false;
    end
end
    
%% get the feature of signature
disp('Calculating feature ...')
[Feature, L] = getFeature(database, pflag);

%% calculate the DTW distance between all samples and the training samples
disp('Calculating Multi-distances ...')
if pflag
    if exist([upper(database), '_dist_p_', num2str(training_sample), '.mat'],'file')
        load ([upper(database), '_dist_p_',  num2str(training_sample), '.mat']);
    else
        multi_dist = cal_dist(Feature, training_sample);
        disp('Saving distances matrix ...');
        save([upper(database), '_dist_p_', num2str(training_sample), '.mat'], 'multi_dist');
        disp('distances matrix saved.')
    end
else
    if exist([upper(database), '_dist_', num2str(training_sample), '.mat'],'file')
        load ([upper(database), '_dist_', num2str(training_sample), '.mat']);
    else
        multi_dist = cal_dist(Feature, training_sample);
        disp('Saving distances matrix ...');
        save([upper(database), '_dist_', num2str(training_sample), '.mat'], 'multi_dist');
        disp('distances matrix saved.')
    end
end

%% distance normalization
for i = 1: subject
    for j = 1: training_sample
        multi_dist(i, :, j, :) = multi_dist(i, :, j, :) / (L(i, j)); % dist/L
    end
end

%% training PCA/SVM
if pflag
    if exist([upper(database), '_', upper(training_method), '_dist_p_', num2str(training_sample), '.mat'],'file')
        load ([upper(database), '_', upper(training_method),'_dist_p_',  num2str(training_sample), '.mat']);
    else
        trans_dist = Training_strategy(database, training_sample, multi_dist, training_method);
        save([upper(database), '_', upper(training_method),'_dist_p_', num2str(training_sample), '.mat'], 'trans_dist');
    end
else
    if exist([upper(database), '_', upper(training_method),'_dist_', num2str(training_sample), '.mat'],'file')
        load ([upper(database), '_', upper(training_method),'_dist_', num2str(training_sample), '.mat']);
    else
        trans_dist = Training_strategy(database, training_sample, multi_dist, training_method);
        save([upper(database), '_', upper(training_method),'_dist_', num2str(training_sample), '.mat'], 'trans_dist');
    end
end
% trans_dist = squeeze(multi_dist(:,:,:,1));

%% Gauss probability distribution estimation
Gref_mean = zeros(subject, 1);
Gref_std = Gref_mean;
Gtest_mean = zeros(subject, sample);
Gtest_std = Gtest_mean;

for i = 1 : subject
    temArray = trans_dist(i, 1:training_sample, :);
    temArray = temArray(:);
    temArray(temArray == temArray(1)) = [];
    Gref_mean(i) = mean(temArray);
    Gref_std(i) = std(temArray);
    
    for j = 1 : training_sample
        temArray = trans_dist(i, j, :);
        temArray(temArray == temArray(1)) = [];
        Gtest_mean(i, j) = mean(temArray);
        Gtest_std(i, j) = std(temArray);
    end
    for j = training_sample+1 : sample
        Gtest_mean(i, j) = mean(trans_dist(i, j, :));
        Gtest_std(i, j) = std(trans_dist(i, j, :));
    end
end

%% score normalization
score = zeros(subject, sample);
for i = 1 : subject
    for j = 1 : sample
        % ID_2
        thre = 0.7 * ((Gtest_mean(i, j)-Gref_mean(i))^2 / (Gref_std(i)^2) + 1);
        if (Gtest_std(i, j)^2 / Gref_std(i)^2) >= thre
            score(i, j) = (Gtest_mean(i, j) - Gref_mean(i)) * (Gtest_std(i, j) / Gref_std(i)) ^ 0.4;
        else
            score(i, j) = (Gtest_mean(i, j) - Gref_mean(i)) * (Gref_std(i) / Gtest_std(i, j)) ^ 0.4;
        end
    end
end

%% calculate EER
range = 0 : 0.01 : 2;
FA = zeros(1, length(range));
FR = FA;
k = 0;
for thre = range
    k = k + 1;
    for i = 1 : subject
        for j = training_sample+1 : gsample
            if score(i, j) >= thre
                FR(k) = FR(k) + 1;
            end
        end
        for j = gsample+1 : sample
            if score(i, j) < thre
                FA(k) = FA(k) + 1;
            end
        end
    end
end
[EER, TH] = ROC(FR/(gsample-training_sample)/subject, FA/(sample-gsample)/subject);

disp('Result:');
disp(sprintf('%s%s%3.4f%s%3.3f', upper(database),' EER=',EER(1), ' TH=', (range(2)-range(1))*(TH(1)-1)));
