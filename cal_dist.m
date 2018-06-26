function O = cal_dist(Feature, training_sample)
% Calculate the DTW distance between all samples and the training samples
opt.calpath = true;
[subject, sample] = size(Feature);
euclid_dist = zeros(subject, sample, training_sample);
bhattacharyya_dist = zeros(subject, sample, training_sample);
chebyshev_dist = zeros(subject, sample, training_sample);
cosine_dist = zeros(subject, sample, training_sample);
correlation_dist = zeros(subject, sample, training_sample);
cityblock_dist = zeros(subject, sample, training_sample);
seuclidean_dist = zeros(subject, sample, training_sample);
euclid_dtw_path = cell(subject, sample, training_sample);

for s = 1: subject
	disp(sprintf('%s%d%s%d%s', 'Calculating ', s, '/', subject, ' ...'));
	for i = 1: sample
        for j = 1: training_sample
            if j ~= i
                [euclid_dist(s, i, j), ~, ~, euclid_dtw_path{s, i, j}] = dtw(Feature{s,i}, Feature{s,j}, opt);
                sum_bhattacharyya_dist = 0;
                for k = 1: length(euclid_dtw_path{s, i, j}) 
                    Test_bha_maching_feature_matrix = Feature{s,i}(euclid_dtw_path{s, i, j}(k, 1), :)';
                    Ref_bha_maching_feature_matrix = Feature{s,j}(euclid_dtw_path{s, i, j}(k, 2), :)';
                    sum_bhattacharyya_dist = sum_bhattacharyya_dist + bhattacharyya(Test_bha_maching_feature_matrix, Ref_bha_maching_feature_matrix);                          
                end                                   
                bhattacharyya_dist(s, i, j) = sum_bhattacharyya_dist;
                
                Test_maching_feature_matrix = Feature{s,i}(euclid_dtw_path{s, i, j}(:, 1), :);
                Ref_maching_feature_matrix = Feature{s,j}(euclid_dtw_path{s, i, j}(:, 2), :);
                %
                chebyshev_dist(s, i, j) =  trace(pdist2(Test_maching_feature_matrix, Ref_maching_feature_matrix, 'chebychev'));
                %
                cosine_dist(s, i, j) =  trace(pdist2(Test_maching_feature_matrix, Ref_maching_feature_matrix, 'cosine'));
                %
                correlation_dist(s, i, j) =  trace(pdist2(Test_maching_feature_matrix, Ref_maching_feature_matrix, 'correlation'));         
                %
                cityblock_dist(s, i, j) =  trace(pdist2(Test_maching_feature_matrix, Ref_maching_feature_matrix, 'cityblock'));
                %
                seuclidean_dist(s, i, j) =  trace(pdist2(Test_maching_feature_matrix, Ref_maching_feature_matrix, 'seuclidean'));        
            end
        end
	end
end

O = cat(4, euclid_dist, bhattacharyya_dist, chebyshev_dist, cosine_dist, correlation_dist, cityblock_dist, seuclidean_dist);