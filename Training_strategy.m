function score = Training_strategy(database, training_sample, multi_dist, training_method)
% Training PCA and output the reconstructed matrix
seed = 100;
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
end

if strcmp(training_method, 'svm')
    seed = seed / 10;
    k = 0;
    training_data = [];
    for s = randi(subject, [1, seed])
        k = k + 1;
        temp = squeeze(multi_dist(s, randi(training_sample), randi(training_sample), :));
        training_data = [training_data, temp];
        training_label(k) = 1;
        k = k + 1;
        temp = squeeze(multi_dist(s, gsample+randi(sample-gsample), randi(training_sample), :));
        training_data = [training_data, temp];
        training_label(k) = 0;
    end

    svm_model = svmtrain(training_label', training_data', '-g 0.005 -h 0 -b 0');
    score = zeros(subject, sample, training_sample);
    k = 0;
    for s = 1 : subject
        for j = 1 : training_sample
            k = k + 1;
            [~, acc, prob] = svmpredict([ones(gsample, 1); zeros(sample-gsample, 1)], squeeze(multi_dist(s, :, j, :)), svm_model);
            macc(k) = acc(1);
            score(s, :, j) = - prob;
        end
    end

elseif strcmp(training_method, 'pca')
    O = zeros(subject, sample, training_sample, 7);
    for s = 1: subject
        for j = 1: training_sample
            for dist_id = 1 : 7
                temp_data(training_sample*(j-1)+1 : training_sample*j, dist_id) = multi_dist(s, 1:training_sample, j, dist_id)';
            end
        end
        temp_data(all(temp_data == 0, 2),:) = [];
        training_data(s, :, :) = temp_data;
    end

    training_pca = [];
    for i = randi(subject,[1,seed])
        training_pca = [training_pca, squeeze(training_data(i,randi(training_sample^2-training_sample),:))];
    end
    [coeff,~, ~, ~] = pca(training_pca');
    for s = 1: subject
        for j = 1: training_sample
            for i = 1: sample
               O(s, i, j, :) = squeeze(multi_dist(s, i, j, :))' * coeff;
            end
        end
    end
    score = squeeze(O(:,:,:,1));
end

