function correlateROI(func, atlas, roiLabels)
    
    % This script does single subject correlation analysis. Needs fieldtrip
    % in MATLAB path to work. 
    %
    % func:      Preprocessed functional data with nii or nii.gz extension.
    % atlas:     Parcellation MRI image. Needs to be in the same coordinate
    %            space and resolution as the input func.
    % roiLabels: A matlab cell with parcellation names. It should match the
    %            atlas parcellation numbers
    %
    % Output - matlab matrices are saved in the location where input func
    % image is located. 
    %
    % Rvals.mat - Full correlation matrix for each ROI.
    % Zvals.mat - Fisher Z converted version of the R values to be used for
    %             within and between subject t-tests.
    % Pvals.mat - P-values for the correlation matrix.
    % Qvals.mat - Q-values for FDR adjusted P-values.

    % This is just for loading the CONN stuff
    s = load(roiLabels);  % Loads into struct
    fieldName = fieldnames(s);
    roiLabels = s.(fieldName{1});
    roiLabels = regexprep(roiLabels, '^atlas\.', '');            % Remove 'atlas.' at start
    roiLabels = regexprep(roiLabels, '\s*\(.*?\)', ''); 

    % --- Load fMRI and Atlas ---
    func_nii = MRIread(func);     % Or use niftiread
    atlas_nii = MRIread(atlas);
    
    fMRI_data = func_nii.vol;     % 4D: X × Y × Z × T
    atlas_data = atlas_nii.vol;   % 3D: X × Y × Z
    
    % --- Reshape for ROI-wise processing ---
    [X, Y, Z, T] = size(fMRI_data);
    nVoxels = X * Y * Z;
    
    fMRI_reshaped = reshape(fMRI_data, [nVoxels, T]);      % voxel x time
    atlas_reshaped = reshape(atlas_data, [nVoxels, 1]);    % voxel x 1
    
    % --- Get ROI labels (assumes roiLabels{i} matches atlas label i) ---
    nROIs = length(roiLabels);
    roiTimeSeries = nan(nROIs, T);  % ROIs x time
    
    % --- Average time series within each ROI ---
    for roi = 1:nROIs
        roiVoxels = atlas_reshaped == roi;
        if any(roiVoxels)
            roiTimeSeries(roi, :) = mean(fMRI_reshaped(roiVoxels, :), 1);
        end
    end
    
    % --- Compute full ROI × ROI correlation matrix ---
    [R, P] = corr(roiTimeSeries', 'rows', 'pairwise');  % [nROIs x nROIs]
    
    % Z transform and clip extremes 
    Z = atanh(R);
    Z(abs(R) >= 0.9999) = sign(R(abs(R) >= 0.9999)) * 10; 
    Z(1:nROIs+1:end) = NaN;  % NaN out the diagonal

    % --- FDR correction: apply only to upper triangle (excluding diagonal) ---
    upperIdx = find(triu(true(size(P)), 1));  % upper triangle linear indices
    pVec = P(upperIdx);
    qVec = mafdr(pVec, 'BHFDR', true);        % FDR correction

    % --- Reconstruct full q-value matrix ---
    Q = nan(size(P));
    Q(upperIdx) = qVec;
    Q = triu(Q, 1) + triu(Q, 1)';  % copy upper triangle to lower triangle, zero diagonal
    Q(1:nROIs+1:end) = NaN;  % diagonal to NaN
    
    % Save the files in the same location as the func image
    [filepath,name,ext] = fileparts(func);
    save(fullfile(filepath, 'correlation-Rvals.mat'), 'R');
    save(fullfile(filepath, 'correlation-Pvals.mat'), 'P');    
    save(fullfile(filepath, 'correlation-Qvals.mat'), 'Q');
    save(fullfile(filepath, 'correlation-Zvals.mat'), 'Z', 'roiLabels');
end