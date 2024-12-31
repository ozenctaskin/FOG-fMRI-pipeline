function ASLstats(preMaps, postMaps, parcels)

% Load in the parcellations 
parcelLoaded = niftiread(parcels);
parcelLoaded = parcelLoaded(:);
unique_parcels = unique(parcelLoaded);

% Process
preDataMat = [];
postDataMat = [];
parcelDataPre = [];
parcelDataPost = [];
for ii = 1:length(preMaps)
    % Load pre and post
    dataPre = niftiread(preMaps{ii});
    oneHeader = niftiinfo(preMaps{ii});
    dataPost = niftiread(postMaps{ii});

    % Get shape and one header, flatten
    imageShape = size(dataPre);
    dataPre = dataPre(:);
    dataPost = dataPost(:);
    
    parcelMeansPre = [];
    parcelMeansPost = [];
    % dataPre parcellation average
    for i = 1:length(unique_parcels)
        parcel_id = unique_parcels(i);
        % Find voxels belonging to the current parcel
        parcel_voxels = parcelLoaded == parcel_id;
        % Calculate the mean ASL value for the parcel
        parcelMeansPre(i) = mean(dataPre(parcel_voxels));
    end
    parcelDataPre = [parcelDataPre, parcelMeansPre'];

    % dataPost parcellation average
    for i = 1:length(unique_parcels)
        parcel_id = unique_parcels(i);
        % Find voxels belonging to the current parcel
        parcel_voxels = parcelLoaded == parcel_id;
        % Calculate the mean ASL value for the parcel
        parcelMeansPost(i) = mean(dataPost(parcel_voxels));
    end
    parcelDataPost = [parcelDataPost, parcelMeansPost'];

    % Save stuff into a matrix
    preDataMat = [preDataMat, dataPre];
    postDataMat = [postDataMat, dataPost];

    % Do a percentage change and save a map
    perChange = ((dataPost - dataPre) ./ dataPre) * 100;
    perChange(isnan(perChange)) = 0;
    perChange = reshape(perChange, imageShape);
    dataPath = fileparts(preMaps{ii});
    niftiwrite(perChange, fullfile(dataPath, 'perChange.nii'), oneHeader)
end

% Save raw t-test results
[h,~, ~, stats] = ttest(preDataMat, postDataMat, 'Dim', 2);
stats.tstat(isnan(stats.tstat)) = 0;
stats.tstat = reshape(stats.tstat, imageShape);
niftiwrite(stats.tstat, fullfile(dataPath, 'finalTstats_unthr.nii'), oneHeader)

% Run a paired t-test to compare pre and post p<0.01
[h,~, ~, stats] = ttest(preDataMat, postDataMat, 'Dim', 2, 'Alpha', 0.01);
h(isnan(h)) = 0;
stats.tstat(isnan(stats.tstat)) = 0;
stats.tstat(find(h==0)) = 0;
stats.tstat = reshape(stats.tstat, imageShape);
niftiwrite(stats.tstat, fullfile(dataPath, 'finalTstats_0.01.nii'), oneHeader)

% Do the same for p<0.05
[h,~, ~, stats] = ttest(preDataMat, postDataMat, 'Dim', 2, 'Alpha', 0.05);
h(isnan(h)) = 0;
stats.tstat(isnan(stats.tstat)) = 0;
stats.tstat(find(h==0)) = 0;
stats.tstat = reshape(stats.tstat, imageShape);
niftiwrite(stats.tstat, fullfile(dataPath, 'finalTstats_0.05.nii'), oneHeader)

end
    