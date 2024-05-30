% Pipeline 
MNIPath = '/Users/chenlab/fsl/data/standard/MNI152_T1_1mm_brain.nii.gz'; % Use the brain extracted one. 

% CLR preprocessing 
dataFolder = '/Users/chenlab/Desktop/OzzyfMRI/Group1_CLR';

subjectID = 'sub-04';
anatomicalPath = '/Users/chenlab/Desktop/OzzyfMRI/Group1_CLR/sub-04/anat/sub-04_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz';
addSliceTime(dataFolder, subjectID)
preprocessWrapper(dataFolder, subjectID, '1', anatomicalPath)
warpToMNI(dataFolder, subjectID, '1', MNIPath)
preprocessWrapper(dataFolder, subjectID, '2', anatomicalPath)
warpToMNI(dataFolder, subjectID, '2', MNIPath)
system(['recon-all -s ' subjectID ' -i '  anatomicalPath ' -all ']);

subjectID = 'sub-06';
anatomicalPath = '/Users/chenlab/Desktop/OzzyfMRI/Group1_CLR/sub-06/anat/sub-06_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz';
addSliceTime(dataFolder, subjectID)
preprocessWrapper(dataFolder, subjectID, '1', anatomicalPath)
warpToMNI(dataFolder, subjectID, '1', MNIPath)
preprocessWrapper(dataFolder, subjectID, '2', anatomicalPath)
warpToMNI(dataFolder, subjectID, '2', MNIPath)
system(['recon-all -s ' subjectID ' -i '  anatomicalPath ' -all ']);

subjectID = 'sub-08';
anatomicalPath = '/Users/chenlab/Desktop/OzzyfMRI/Group1_CLR/sub-08/anat/sub-08_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz';
addSliceTime(dataFolder, subjectID)
preprocessWrapper(dataFolder, subjectID, '1', anatomicalPath)
warpToMNI(dataFolder, subjectID, '1', MNIPath)
preprocessWrapper(dataFolder, subjectID, '2', anatomicalPath)
warpToMNI(dataFolder, subjectID, '2', MNIPath)
system(['recon-all -s ' subjectID ' -i '  anatomicalPath ' -all ']);

%% PPN preprocessing. 
% We don't want to run Freesurfer again as these share
% the same anatomical images.
dataFolder = '/Users/chenlab/Desktop/OzzyfMRI/Group2_PPN';

subjectID = 'sub-04';
anatomicalPath = '/Users/chenlab/Desktop/OzzyfMRI/Group1_CLR/sub-04/anat/sub-04_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz';
addSliceTime(dataFolder, subjectID)
preprocessWrapper(dataFolder, subjectID, '1', anatomicalPath)
warpToMNI(dataFolder, subjectID, '1', MNIPath)
preprocessWrapper(dataFolder, subjectID, '2', anatomicalPath)
warpToMNI(dataFolder, subjectID, '2', MNIPath)

subjectID = 'sub-06';
anatomicalPath = '/Users/chenlab/Desktop/OzzyfMRI/Group1_CLR/sub-06/anat/sub-06_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz';
addSliceTime(dataFolder, subjectID)
preprocessWrapper(dataFolder, subjectID, '1', anatomicalPath)
warpToMNI(dataFolder, subjectID, '1', MNIPath)
preprocessWrapper(dataFolder, subjectID, '2', anatomicalPath)
warpToMNI(dataFolder, subjectID, '2', MNIPath)

subjectID = 'sub-08';
anatomicalPath = '/Users/chenlab/Desktop/OzzyfMRI/Group1_CLR/sub-08/anat/sub-08_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz';
addSliceTime(dataFolder, subjectID)
preprocessWrapper(dataFolder, subjectID, '1', anatomicalPath)
warpToMNI(dataFolder, subjectID, '1', MNIPath)
preprocessWrapper(dataFolder, subjectID, '2', anatomicalPath)
warpToMNI(dataFolder, subjectID, '2', MNIPath)