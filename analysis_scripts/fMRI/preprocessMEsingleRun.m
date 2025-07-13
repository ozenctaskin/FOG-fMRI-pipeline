function warpSet = preprocessMEsingleRun(dataFolder, subjectID, sessionID, blur, skipPCA, combineMethod)

    % IMPORTANT!!!! This script won't run if you do not start MATLAB from 
    % your terminal. If you are on linux, run "matlab" on your terminal. 
    % If you are on mac, run "open /Applications/MATLAB_R2023b.app" 
    % (Change the R2023b with your version). 
    %
    % The script depends on AFNI functions, so make sure you have it
    % installed and can call AFNI functions from your terminal. Try running
    % afni_proc.py on a terminal window to check if you have it installed
    % properly. Also, the bids conversion needs to be applied to the data
    % using the chenlab bidsmap, as the function depends on certain naming
    % scheme to find appropriate images.
    %
    % This script is for analyzing resting state fMRI data obtained with
    % multi-echo imaging only. When the function is run, the analysis is 
    % done twice with the blur you set and without blur. Separate folders 
    % for each run and each blur level is created automatically in your
    % bids folder. final_func.nii and final_anat.nii in these folders are
    % your final preprocessed images in NIFTI format.
    %
    %`  Input:
    %
    %   dataFolder: BIDS folder where all of your subjects are located.
    %   subjectID: Name of the subject folder located in dataFolder. e.g
    %   sub-01.
    %   sessionID: Name of the session folder located in subject folder e.g
    %   ses-PPN. 
    %   blur: Amount of smoothing you want to use in FWHM.
    %   skipPCA: Multi-echo processing removes some noise. The literature 
    %   is not solid on whether additional PCA analysis is beneficial after 
    %   this, so we leave this optional. Set it to false if you want to do
    %   PCA. 
    %   combineMethod: Echo combination method, check afni_proc.py for 
    %   details. 'm_tedana_m_tedort' is a good option here.
    
    % Find out how many runs we have
    allFuncFiles =  dir(fullfile(dataFolder, subjectID, sessionID, 'func', '*.json'));
    runNum = numel(unique(cellfun(@(f) sscanf(regexp(f, 'run-(\d+)', 'match', 'once'), 'run-%d'), {allFuncFiles.name})));

    % Set up static variables we will use.
    T1w = fullfile(dataFolder, subjectID, sessionID, 'anat', [subjectID '_' sessionID '_acq-btoMPRAGE2x11mmiso_T1w.nii.gz']);
    % MNITemplate = fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI152_T1_1mm.nii.gz');

    % Run recon all and SUMA if skipPCA is not supplied 
    if ~skipPCA
        if ~isfolder(fullfile(dataFolder, subjectID, sessionID, subjectID)) 
            system(['recon-all -all -subject ' subjectID ' -i ' T1w ' -sd ' fullfile(dataFolder, subjectID, sessionID)]);
            system(['cd ' fullfile(dataFolder, subjectID, sessionID, subjectID) '; @SUMA_Make_Spec_FS -sid ' subjectID ' -NIFTI']);
        end
        ventricles = fullfile(dataFolder, subjectID, sessionID, subjectID, 'SUMA', 'fs_ap_latvent.nii.gz');
        white_matter = fullfile(dataFolder, subjectID, sessionID, subjectID, 'SUMA', 'fs_ap_wm.nii.gz');   
        aseg = fullfile(dataFolder, subjectID, sessionID, subjectID, 'SUMA', 'aparc.a2009s+aseg_REN_all.nii.gz');
    end

    % Loop through runs and preprocess
    warpSet = 'NA';
    for blurs = 1:2
        if isequal(blurs,2)
            blur = 'NA';
        end
        for ii = 1:runNum
            afni_line = '';
            runNumber = num2str(ii);
            blipForward = fullfile(dataFolder, subjectID, sessionID, 'func', [subjectID '_' sessionID '_task-btoCMRREP2DMEBOLD2x42p5mmisorsfMRI_dir-PA_run-' runNumber '_echo-1_bold.nii.gz']);
            blipReverse = fullfile(dataFolder, subjectID, sessionID, 'fmap', [subjectID '_' sessionID '_acq-e1_dir-AP_run-' runNumber '_epi.nii.gz']);
            funcDataset = fullfile(dataFolder, subjectID, sessionID, 'func', [subjectID '_' sessionID '_task-btoCMRREP2DMEBOLD2x42p5mmisorsfMRI_dir-PA_run-' runNumber '_echo-*_bold.nii.gz']);
    
            % Insert slice timing info from json to nifti
            if isequal(blurs,1)
                fprintf('\nAdding slice time information to data. Do not stop the script now or your MRI images get corrupted.\n');
                system(['abids_tool.py -add_slice_times -input ' funcDataset]);
            end
    
            % Build and run the preprocessing setup. No blurring. If you need to
            % add it back. It needs to come after combine block. Also add the below
            % info to the main body
            afni_line = ['cd ' fullfile(dataFolder, subjectID, sessionID) ';' 'afni_proc.py ' ...,
            '-subj_id ' subjectID ' ' ...,
            '-radial_correlate_blocks tcat volreg regress ' ...,
            '-copy_anat ' T1w ' '  ...,
            '-anat_has_skull yes ' ..., 
            '-blip_forward_dset ' blipForward ' ' ..., 
            '-blip_reverse_dset ' blipReverse ' ' ..., 
            '-dsets_me_run ' funcDataset ' ' ..., 
            '-tshift_interp -wsinc9 ' ..., 
            '-align_unifize_epi local ' ..., 
            '-align_opts_aea -cost lpc+ZZ -giant_move -check_flip ' ...,
            '-tlrc_base MNI152_2009_template_SSW.nii.gz ' ..., 
            '-tlrc_NL_warp ' ...,
            '-volreg_align_to MIN_OUTLIER ' ...,
            '-volreg_align_e2a ' ..., 
            '-volreg_tlrc_warp ' ...,
            '-volreg_post_vr_allin yes ' ..., 
            '-volreg_pvra_base_index MIN_OUTLIER ' ...,
            '-volreg_compute_tsnr yes ' ..., 
            '-volreg_warp_dxyz 2.5 ' ...,
            '-combine_method ' combineMethod ' ' ...,
            '-echo_times 13.20 29.94 46.66 -reg_echo 2 ' ..., 
            '-mask_epi_anat yes ' ...,
            '-regress_motion_per_run ' ...,
            '-regress_censor_motion 0.2 ' ...,
            '-regress_censor_outliers 0.05 ' ..., 
            '-regress_apply_mot_types demean deriv ' ..., 
            '-regress_est_blur_epits ' ...,
            '-regress_est_blur_errts ' ..., 
            '-html_review_style pythonic ' ..., 
            '-remove_preproc_files'];
            
            % If blur is specified, add it to the function. 
            if ~strcmp(blur, 'NA')
                if isnumeric(blur)
                    blur = num2str(blur);
                end
                afni_line = [afni_line ' -blur_size ' blur ' -blur_in_mask yes -blocks despike tshift align tlrc volreg mask combine blur scale regress'];
            else
                afni_line = [afni_line ' -blocks despike tshift align tlrc volreg mask combine scale regress'];
            end
            
            % Check if PCA is skipped or not 
            if ~skipPCA
                afni_line = [afni_line ' -anat_follower_ROI aaseg anat ' aseg ' -anat_follower_ROI aeseg epi ' aseg ' -anat_follower_ROI FSvent epi ' ventricles  ' -anat_follower_ROI FSWe epi ' white_matter ' -anat_follower_erode FSvent FSWe -regress_ROI_PC FSvent 3 -regress_ROI_PC_per_run FSvent -regress_anaticor_fast -regress_anaticor_label FSWe -regress_make_corr_vols aeseg FSvent'];
            end
            
            % Add warps if supplied
            if ~strcmp(warpSet, 'NA')
                afni_line = [afni_line ' -tlrc_NL_warped_dsets ' warpSet{1} ' ' warpSet{2} ' ' warpSet{3}];
            end
        
            % Run the afni line
            system(afni_line);
        
            % Add the run number to the proc script that AFNI creates
            procScript = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID]);
            if strcmp(blur, 'NA')
                newProcName = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID '.' 'run-' runNumber]);
            else
                newProcName = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID '.' 'run-' runNumber '.blur_' blur 'mm']);
            end
            system(['mv ' procScript ' ' newProcName]);
    
            % Set the output text name
            if strcmp(blur, 'NA')
                outputReport = fullfile(dataFolder, subjectID, sessionID, ['output.proc.' subjectID '.' 'run-' runNumber]);
            else
                outputReport = fullfile(dataFolder, subjectID, sessionID, ['output.proc.' subjectID '.' 'run-' runNumber '.blur_' blur 'mm']);
            end
    
            % Run preprocessing 
            system(['cd ' fullfile(dataFolder, subjectID, sessionID) '; ' 'tcsh -xef ' newProcName ' 2>&1 | tee ' outputReport]);
    
            % Convert func and anat results to nifti 
            outputFolder = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results']);
            func = fullfile(outputFolder, ['errts.' subjectID '.fanaticor+tlrc.HEAD']);
            if ~isfile(func)
                func = fullfile(outputFolder, ['errts.' subjectID '.tproject+tlrc.HEAD']);
            end
            anat = fullfile(outputFolder, ['anat_final.' subjectID '+tlrc.HEAD']);
            system(['cd ' outputFolder ';' '3dAFNItoNIFTI -prefix final_func ' func]);
            system(['cd ' outputFolder ';' '3dAFNItoNIFTI -prefix final_anat ' anat]);
    
            % Add the run number to the folder
            if strcmp(blur, 'NA')
                newOutputName = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results.run-' runNumber '.noBlur']);
            else
                newOutputName = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results.run-' runNumber '.blur_' blur 'mm']);
            end
    
            system(['mv ' outputFolder ' ' newOutputName]);
        
            % Return final anat and warps to be used for the next run
            warpSet = {fullfile(newOutputName,'final_anat.nii'), ...
                       fullfile(newOutputName,'anat.un.aff.Xat.1D'), ...
                       fullfile(newOutputName,'anat.un.aff.qw_WARP.nii')};
        end
    end
end