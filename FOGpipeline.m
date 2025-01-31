% % Cleanup MP2RAGE images for subjects
% makeAnat('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG3/ses-PPN/anat/sub-pFOG3_ses-PPN_run-3_inv-2_part-mag_MP2RAGE.nii.gz', ...
%          '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG3/ses-PPN/anat/sub-pFOG3_ses-PPN_acq-MP2RAGE_UNIT1.nii.gz')
% makeAnat('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG7/ses-PPN/anat/sub-pFOG7_ses-PPN_run-3_inv-2_part-mag_MP2RAGE.nii.gz', ...
%          '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG7/ses-PPN/anat/sub-pFOG7_ses-PPN_acq-MP2RAGE_UNIT1.nii.gz')
% makeAnat('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG8/ses-CLR/anat/sub-pFOG8_ses-CLR_run-3_inv-2_part-mag_MP2RAGE.nii.gz', ...
%          '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG8/ses-CLR/anat/sub-pFOG8_ses-CLR_acq-MP2RAGE_UNIT1.nii.gz')
% 
% % Run recon-all
% runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG3/ses-PPN/anat/sub-pFOG3_ses-PPN_acq-MP2RAGE_UNIT1_unbiased_clean.nii', 'sub-pFOG3');
% runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG4/ses-PPN/anat/sub-pFOG4_ses-PPN_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz', 'sub-pFOG4');
% runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG6/ses-CLR/anat/sub-pFOG6_ses-CLR_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz', 'sub-pFOG6');
% runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG7/ses-PPN/anat/sub-pFOG7_ses-PPN_acq-MP2RAGE_UNIT1_unbiased_clean.nii', 'sub-pFOG7');
% runReconAll('/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG8/ses-CLR/anat/sub-pFOG8_ses-CLR_acq-MP2RAGE_UNIT1_unbiased_clean.nii', 'sub-pFOG8');

%% Process healthy subjects
% Specify folders and subjects
dataFolder = '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/';
templatePath = fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI152_T1_1mm_brain.nii.gz');
subjects = {'sub-pFOG3', 'sub-pFOG4', 'sub-pFOG6', 'sub-pFOG7', 'sub-pFOG8'};
anatomicals = {'/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG3/ses-PPN/anat/sub-pFOG3_ses-PPN_acq-MP2RAGE_UNIT1_unbiased_clean.nii', ...
               '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG4/ses-PPN/anat/sub-pFOG4_ses-PPN_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz', ...
               '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG6/ses-CLR/anat/sub-pFOG6_ses-CLR_acq-MPRAGE_rec-RMS_run-2_part-mag_T1w.nii.gz', ...
               '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG7/ses-PPN/anat/sub-pFOG7_ses-PPN_acq-MP2RAGE_UNIT1_unbiased_clean.nii', ...
               '/home/chenlab-linux/Desktop/FOG/healthyControls/bidsFolder/sub-pFOG8/ses-CLR/anat/sub-pFOG8_ses-CLR_acq-MP2RAGE_UNIT1_unbiased_clean.nii'};
sessions = {{'ses-PPN'}, {'ses-PPN','ses-CLR'}, {'ses-PPN','ses-CLR'}, {'ses-PPN','ses-CLR'}, {'ses-PPN','ses-CLR'}};
blurFWHM = 'NA';
combineMethod = 'm_tedana_OC';

% Loop through subjects and sessions and run the analysis
for sub = 1:length(subjects)
    subjectID = subjects{sub};
    anatomicalPath = anatomicals{sub};
    for ses = 1:length(sessions{sub})
        sessionID = sessions{sub}{ses};
        runNumber = '1';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath, blurFWHM, true, false, combineMethod)
        runNumber = '2';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath, blurFWHM, false, false, combineMethod)
    end
end

% Run the same thing with blur 4mm
blurFWHM = '4';
for sub = 1:length(subjects)
    subjectID = subjects{sub};
    anatomicalPath = anatomicals{sub};
    for ses = 1:length(sessions{sub})
        sessionID = sessions{sub}{ses};
        runNumber = '1';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath, blurFWHM, false, false, combineMethod)
        runNumber = '2';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath, blurFWHM, false, false, combineMethod)
    end
end

%% Process PPN patient
% makeAnat('/home/chenlab-linux/Desktop/FOG/patients/bidsFolder/sub-pFOGa/ses-PPNexcitatory/anat/sub-pFOGa_ses-PPNexcitatory_run-3_inv-2_part-mag_MP2RAGE.nii.gz', ...
         % '/home/chenlab-linux/Desktop/FOG/patients/bidsFolder/sub-pFOGa/ses-PPNexcitatory/anat/sub-pFOGa_ses-PPNexcitatory_acq-MP2RAGE_UNIT1.nii.gz')

% runReconAll('/home/chenlab-linux/Desktop/FOG/patients/bidsFolder/sub-pFOGa/ses-PPNexcitatory/anat/sub-pFOGa_ses-PPNexcitatory_acq-MP2RAGE_UNIT1_unbiased_clean.nii', 'sub-pFOGa');
dataFolder = '/home/chenlab-linux/Desktop/FOG/patients/bidsFolder/';
templatePath = fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI152_T1_1mm_brain.nii.gz');
subjects = {'sub-pFOGa'};
anatomicals = {'/home/chenlab-linux/Desktop/FOG/patients/bidsFolder/sub-pFOGa/ses-PPNexcitatory/anat/sub-pFOGa_ses-PPNexcitatory_acq-MP2RAGE_UNIT1_unbiased_clean.nii'};
sessions = {{'ses-PPNexcitatory','ses-PPNinhibitory', 'ses-UFexcitatory', 'ses-UFinhibitory'}};
blurFWHM = 'NA';
% Loop through subjects and sessions and run the analysis
for sub = 1:length(subjects)
    subjectID = subjects{sub};
    anatomicalPath = anatomicals{sub};
    for ses = 1:length(sessions{sub})
        sessionID = sessions{sub}{ses};
        runNumber = '1';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath, blurFWHM, true, false, combineMethod)
        runNumber = '2';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath, blurFWHM, false, false, combineMethod)
    end
end

% With blur
blurFWHM = '4';
for sub = 1:length(subjects)
    subjectID = subjects{sub};
    anatomicalPath = anatomicals{sub};
    for ses = 1:length(sessions{sub})
        sessionID = sessions{sub}{ses};
        runNumber = '1';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath, blurFWHM, false, false, combineMethod)
        runNumber = '2';
        preprocessMEsingleRun(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, templatePath, blurFWHM, false, false, combineMethod)
    end
end