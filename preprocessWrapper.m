function preprocessWrapper(dataFolder, subjectID, sessionID, runNumber, anatomicalPath, MNITemplate)

    % IMPORTANT!!!! This script won't run if you do not start MATLAB from 
    % your terminal. If you are on linux, run "matlab". If you are on mac,
    % run "open /Applications/MATLAB_R2023b.app" (Change the R2023b with 
    % your version). The reason is that when started with the icon instead
    % of the terminal, matlab cannot access your $PATH variables and uses 
    % its own paths, so afni functions can't be found.
    %
    % This script performs preprocessing with AFNI, renames analysis output
    % with the run number so that you can analyze different runs in the
    % same subject separately, and convert necessary files to nifti. In the
    % results folder look for final_func.nii and final_anat.nii files.
    % These are the preprocessed final output converted to NIFTI.
    %
    %   dataFolder: BIDS folder where your subjects are located
    %   subjectID: Name of the subject folder located in dataFolder. e.g
    %   sub-01.
    %   sessionID: Name of the session folder located in subject folder e.g
    %   ses-PPN. 
    %   runNumber: The run you want to analyze. Use string input e.g. '1'
    %   anatomicalPath: Path to anatomical image you want to process
    %   MNITemplate: You can find one in $FSLDIR/data/standard. use 1mm MNI
    %   use the _brain one. 
    
    % Set up variables we will use 
    ventricles = fullfile(getenv('SUBJECTS_DIR'), subjectID, 'SUMA', 'fs_ap_latvent.nii.gz');
    white_matter = fullfile(getenv('SUBJECTS_DIR'), subjectID, 'SUMA', 'fs_ap_wm.nii.gz');
    blipForward = fullfile(dataFolder, subjectID, sessionID, 'func', [subjectID '_' sessionID '_task-rest_dir-PA_run-' runNumber '_echo-1_part-mag_bold.nii.gz']);
    blipReverse = fullfile(dataFolder, subjectID, sessionID, 'fmap', [subjectID '_' sessionID '_acq-e1_dir-AP_run-' runNumber '_epi.nii.gz']);
    funcDataset = fullfile(dataFolder, subjectID, sessionID, 'func', [subjectID '_' sessionID '_task-rest_dir-PA_run-' runNumber '_echo-*_part-mag_bold.nii.gz']);

    % Build and run the preprocessing setup
    afni_line = ['cd ' fullfile(dataFolder, subjectID, sessionID) ';' 'afni_proc.py ' ...,
    '-subj_id ' subjectID ' ' ...,
    '-blocks despike tshift align tlrc volreg mask combine blur scale regress ' ...,
    '-radial_correlate_blocks tcat volreg ' ...,
    '-copy_anat ' anatomicalPath ' '  ...,
    '-anat_has_skull yes ' ..., 
    '-anat_follower_ROI FSvent epi ' ventricles ' ' ...,      
    '-anat_follower_ROI FSWe epi ' white_matter ' ' ...,            
    '-anat_follower_erode FSvent FSWe ' ...,
    '-blip_forward_dset ' blipForward ' ' ..., 
    '-blip_reverse_dset ' blipReverse ' ' ..., 
    '-dsets_me_run ' funcDataset ' ' ..., 
    '-tshift_interp -wsinc9 ' ..., 
    '-align_unifize_epi local ' ..., 
    '-align_opts_aea -cost lpc+ZZ -giant_move -check_flip ' ...,
    '-tlrc_base ' MNITemplate ' ' ..., 
    '-tlrc_NL_warp ' ..., 
    '-tlrc_no_ss ' ...,
    '-volreg_align_to MIN_OUTLIER ' ...,
    '-volreg_align_e2a ' ..., 
    '-volreg_tlrc_warp ' ...,
    '-volreg_post_vr_allin yes ' ..., 
    '-volreg_pvra_base_index MIN_OUTLIER ' ...,
    '-volreg_compute_tsnr yes ' ..., 
    '-volreg_warp_dxyz 2.5 ' ...,
    '-combine_method m_tedana_m_tedort -echo_times 13 30 46 -reg_echo 2 ' ..., 
    '-blur_size 0 ' ..., 
    '-blur_in_mask yes ' ..., 
    '-mask_epi_anat yes ' ...,
    '-regress_motion_per_run ' ...,
    '-regress_ROI_PC FSvent 3 ' ..., 
    '-regress_ROI_PC_per_run FSvent ' ..., 
    '-regress_anaticor_fast ' ...,
    '-regress_anaticor_label FSWe ' ...,
    '-regress_censor_motion 0.2 ' ...,
    '-regress_censor_outliers 0.05 ' ..., 
    '-regress_apply_mot_types demean deriv ' ..., 
    '-regress_est_blur_epits ' ...,
    '-regress_est_blur_errts ' ..., 
    '-html_review_style pythonic ' ..., 
    '-remove_preproc_files'];

    system(afni_line);
    
    % Add the run number to the proc script that AFNI creates
    procScript = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID]);
    newProcName = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID '.' 'run-' runNumber]);
    system(['mv ' procScript ' ' newProcName]);

    % Run the preprocessing
    system(['cd ' fullfile(dataFolder, subjectID, sessionID) '; ' 'tcsh -xef proc.' subjectID '.run-' runNumber ' 2>&1 | tee output.proc.' subjectID '.run-' runNumber]);

    % Convert func and anat results to nifti 
    outputFolder = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results']);
    func = fullfile(outputFolder, ['errts.' subjectID '.fanaticor+tlrc.HEAD']);
    anat = fullfile(outputFolder, ['anat_final.' subjectID '+tlrc.HEAD']);
    system(['cd ' outputFolder ';' '3dAFNItoNIFTI -prefix final_func ' func]);
    system(['cd ' outputFolder ';' '3dAFNItoNIFTI -prefix final_anat ' anat]);

    % Add the run number to the folder
    newOutputName = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results.run-' runNumber]);
    system(['mv ' outputFolder ' ' newOutputName]);

end