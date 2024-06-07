%% Example Pipeline

%% Main path variables
% Enter path to your data folder. This folder should contain your subject
% folders named according to BIDS format (sub-01, sub-ABC, etc.). In each
% subject folder, there should be session folders again named according to
% BIDS format (ses-01, ses-CLR, etc.). In each session folder, you need 
% func, fmap, and anat folders containing your BIDS curated images. 
dataFolder = 'Enter folder path here';

% Enter template path. Needs to be brain extracted. The MNI template in fsl
% directory works well (fsl/data/standard/MNI152_T1_1mm_brain.nii.gz)
templatePath = 'Enter template path here'; 

%% Analysis block. Repeat this as neeeded
subjectID = 'Enter subject ID to process';
sessionID = 'Enter session ID to process';
anatomicalPath = 'Enter path to T1 image';
runNumber = 'Enter the run you want to process';

% If you have MP2RAGE images, you can use the makeAnat function to clean
% them up. That functions outputs the final cleaned up dataset so that you
% can directly set your anatomicalPath to its output:
%   anatomicalPath = makeAnat(inv2, unit)

% Run this once per each subject
runReconAll(anatomicalPath, subjectID)

% Run this once per each session of each subject
addSliceTime(dataFolder, subjectID, sessionID)

% Run this for each run of each session of each subject.
preprocessWrapperMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath)

% Below is an example where we analyze 2 runs from 1 subject with a single 
% session.
%
% subjectID = 'sub-04';
% sessionID = 'ses-PPN';
% anatomicalPath = '/home/chenlab/Desktop/data/sub-04/ses-PPN/anat/anat.nii.gz';
%
% runReconAll(anatomicalPath, subjectID)
% addSliceTime(dataFolder, subjectID, sessionID)
%
% runNumber = '1';
% preprocessWrapperMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath)
%
% runNumber = '2';
% preprocessWrapperMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath)
 

