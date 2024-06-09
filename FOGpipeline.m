% Cleanup MP2RAGE images for subjects
makeAnat('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG3/ses-PPN/anat/sub-pFOG3_ses-PPN_run-3_inv-2_part-mag_MP2RAGE.nii.gz', ...
         '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG3/ses-PPN/anat/sub-pFOG3_ses-PPN_acq-MP2RAGE_UNIT1.nii.gz')
makeAnat('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG7/ses-PPN/anat/sub-pFOG7_ses-PPN_run-3_inv-2_part-mag_MP2RAGE.nii.gz', ...
         '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG7/ses-PPN/anat/sub-pFOG7_ses-PPN_acq-MP2RAGE_UNIT1.nii.gz')
makeAnat('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG8/ses-CLR/anat/sub-pFOG8_ses-CLR_run-3_inv-2_part-mag_MP2RAGE.nii.gz', ...
         '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG8/ses-CLR/anat/sub-pFOG8_ses-CLR_acq-MP2RAGE_UNIT1.nii.gz')

% Run recon-all
runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG3/ses-PPN/anat/sub-pFOG3_ses-PPN_acq-MP2RAGE_UNIT1_unbiased_clean.nii', 'sub-pFOG3');
runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG4/ses-PPN/anat/sub-pFOG4_ses-PPN_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz', 'sub-pFOG4');
runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG6/ses-CLR/anat/sub-pFOG6_ses-CLR_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz', 'sub-pFOG6');
runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG7/ses-PPN/anat/sub-pFOG7_ses-PPN_acq-MP2RAGE_UNIT1_unbiased_clean.nii', 'sub-pFOG7');
runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG8/ses-CLR/anat/sub-pFOG8_ses-CLR_acq-MP2RAGE_UNIT1_unbiased_clean.nii', 'sub-pFOG8');


% Run func
dataFolder = '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/';
templatePath = fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI152_T1_1mm.nii.gz';

%% Process subjects
subjects = {'sub-pFOG3', 'sub-pFOG4', 'sub-pFOG6', 'sub-pFOG7', 'sub-pFOG8'};
anatomicals = {'/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG3/ses-PPN/anat/sub-pFOG3_ses-PPN_acq-MP2RAGE_UNIT1_unbiased_clean.nii', ...
               '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG4/ses-PPN/anat/sub-pFOG4_ses-PPN_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz', ...
               '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG6/ses-CLR/anat/sub-pFOG6_ses-CLR_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz', ...
               '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG7/ses-PPN/anat/sub-pFOG7_ses-PPN_acq-MP2RAGE_UNIT1_unbiased_clean.nii', ...
               '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG8/ses-CLR/anat/sub-pFOG8_ses-CLR_acq-MP2RAGE_UNIT1_unbiased_clean.nii'};
sessions = {{'ses-PPN'}, {'ses-PPN','ses-CLR'}, {'ses-PPN','ses-CLR'}, {'ses-PPN','ses-CLR'}, {'ses-PPN','ses-CLR'}};

for sub = 1:length(subjects)
    subjectID = subjects{sub};
    anatomicalPath = anatomicals{sub};
    for ses = 1:length(sessions{sub})
        sessionID = sessions{sub}{ses};
        runNumber = '1';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath)
        runNumber = '2';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath)
    end
end
