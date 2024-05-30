function addSliceTime(dataFolder, subjectID)
    
    % IMPORTANT!!!! This script won't run if you do not start MATLAB from 
    % your terminal. If you are on linux, run "matlab". If you are on mac,
    % run "open /Applications/MATLAB_R2023b.app" (Change the R2023b with 
    % your version). The reason is that when started with the icon instead
    % of the terminal, matlab cannot access your $PATH variables and uses 
    % its own paths, so afni functions can't be found.    
    %
    % This script finds nifti files in the func and fmap folders of BIDS
    % curated data and adds slice timing information using AFNI's
    % abids_tools.py. Requires AFNI and python installed. Overwrites
    % original files with the slice time added ones. 
    %
    %   dataFolder:  BIDS folder containing subject folders
    %   subjectID:   The ID of the subject you want to use (e.g sub-04)
    %   afniBinPath: Path to afni functions. If you can run them these 
    %                functions from your terminal, you can find this path 
    %                by running 'which abids_tools' from a terminal
    %   pythonPath:  Path to your python bin folder. You can find this path
    %                by running 'which python' from a terminal window.
    %
    %

    % Get the files in the func and fmap dir
    subjectDir = fullfile(dataFolder, subjectID);
    funcDir = dir(fullfile(subjectDir, 'func'));
    fmapDir = dir(fullfile(subjectDir, 'fmap'));
    funcDir = funcDir(3:end, :);
    fmapDir = fmapDir(3:end, :);
    
    % Loop through the files
    fprintf('Adding slice timing info to nifti files in func. This might take a while \n')
    for ii = 1:length(funcDir)
        if contains(funcDir(ii).name, 'nii.gz') && ~contains(funcDir(ii).name, 'sbref')
            path = fullfile(dataFolder, subjectID, 'func', funcDir(ii).name);
            system(['abids_tool.py -add_slice_times -input ' path]);
        end
    end
end