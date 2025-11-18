function warpSet = preprocessMEsingleRun(dataFolder, subjectID, sessionID, blur, skipPCA, combineMethod, warpSet, freesurferBuild)

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
    % bids folder. final_func.nii and final_anat.nii in these result
    % folders are your final preprocessed images in NIFTI format.
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
    %   warpSet: Warp calculations between anatomical and template space.
    %   This function also outputs a variable with the same name which can
    %   be passed to a second run, for example if you are running the same
    %   subject with the same anatomical images. If you are running this 
    %   script for a subject for the first time, set this to 'NA'. If you 
    %   are running it again for the same subject but different session, 
    %   pass the warpSet output of this function to he next iteration. If 
    %   you do not know how to do this, always set this to 'NA'.
    %   freesurferBuild: This could be either 'docker' or 'local'. The
    %   docker version is the latest version on the Chenlab linux computer,
    %   so if you pick 'local', v7.4.1 will be run instead of v8.1.0.
    %   Ignored if skipPCA is set to true.

    % Convert blur input to string if input is numeric
    if isnumeric(blur)
        blur = num2str(blur);
    end

    % Go through all session folders in a subject folder and find the T1
    % and T2 weighted images. If no T2 is found, Freesurfer is run only
    % with T1. 
    allSes = dir(fullfile(dataFolder, subjectID, 'ses-*'));
    for ii = 1:length(allSes)
        anatDir = fullfile(allSes(ii).folder, allSes(ii).name, 'anat');
        if isfolder(anatDir)
            if isfile(fullfile(allSes(ii).folder, allSes(ii).name, 'anat', [subjectID '_' allSes(ii).name '_acq-btoMPRAGE2x11mmiso_T1w.nii.gz']))
                T1w = fullfile(allSes(ii).folder, allSes(ii).name, 'anat', [subjectID '_' allSes(ii).name '_acq-btoMPRAGE2x11mmiso_T1w.nii.gz']);
                fprintf(['\n Found the anatomical image ' T1w ' Stopping search\n']);
            elseif isfile(fullfile(allSes(ii).folder, allSes(ii).name, 'anat', [subjectID '_' allSes(ii).name '_acq-AxialT1wMPR_T1w.nii.gz']))
                T1w = fullfile(allSes(ii).folder, allSes(ii).name, 'anat', [subjectID '_' allSes(ii).name '_acq-AxialT1wMPR_T1w.nii.gz']);
                fprintf(['\n Found the anatomical image ' T1w ' Stopping search\n']);
            else
                error('Your subject either does not have a T1 image or have multiple runs of it. You need an anat folder in at least one of your sessions containing a btoMPRAGE2x11mmiso_T1w.nii.gz or a AxialT1wMPR_T1w.nii.gz image. if you have multiple T1 runs, it is probably because the acquisition was repeated due to bad quality. Pick the better one (ie. by loading it to fsleyes) and manually delete the _run-<num> part of the name of the image you want to use.')
            end
            if isfile(fullfile(allSes(ii).folder, allSes(ii).name, 'anat', [subjectID '_' allSes(ii).name '_acq-btoSPACET22x2CAIPI1mmiso_T2w']))
                T2w = fullfile(allSes(ii).folder, allSes(ii).name, 'anat', [subjectID '_' allSes(ii).name '_acq-btoSPACET22x2CAIPI1mmiso_T2w.nii.gz']);
            end
            break;
        end
    end

    % FSL version of the MNI template if we need this. Currently commented
    % out
    % MNITemplate = fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI152_T1_1mm.nii.gz');

    % Run recon all and SUMA if skipPCA is not supplied. Select between
    % docker or local versions and configure based on whether a T2 image
    % exists.
    if ~skipPCA  
        if ~isfolder(fullfile(dataFolder, subjectID, [subjectID '_freesurfer'])) 
            [~, T1name, T1ext] = fileparts(T1w);
            if exist('T2w', 'var')
                [~, T2name, T2ext] = fileparts(T2w);
                if strcmp(freesurferBuild, 'docker')
                    system(['docker run -it --rm -v ' T1w ':/anat/' [T1name,T1ext] ' -v ' T2w ':/anat/' [T2name,T2ext] ' -v ' fullfile(dataFolder, subjectID) ':/subjects freesurfer:latest recon-all -i ' fullfile('/anat', [T1name,T1ext]) ' -T2 ' fullfile('/anat', [T2name,T2ext]) ' -T2pial -sd /subjects -s ' [subjectID '_freesurfer'] ' -all']);
                elseif strcmp(freesurferBuild, 'local')
                    system(['recon-all -subject ' subjectID '_freesurfer' ' -i ' T1w ' -T2 ' T2w ' -sd ' fullfile(dataFolder, subjectID) ' -T2pial -all']);
                else
                    error('Wrong freesurferBuild specified. Check comments for the options');
                end
            else
                if strcmp(freesurferBuild, 'docker')
                    system(['docker run -it --rm -v ' T1w ':/anat/' [T1name,T1ext] ' -v ' fullfile(dataFolder, subjectID) ':/subjects freesurfer:latest recon-all -i ' fullfile('/anat', [T1name,T1ext]) ' -sd /subjects -s ' [subjectID '_freesurfer'] ' -all']);    
                elseif strcmp(freesurferBuild, 'local')
                    system(['recon-all -subject ' subjectID '_freesurfer' ' -i ' T1w ' -sd ' fullfile(dataFolder, subjectID) ' -all']);
                else
                    error('Wrong freesurferBuild specified. Check comments for the options');
                end
            end
            system(['docker run --rm -v ' fullfile(dataFolder, subjectID) ':/subjects alpine chmod -R a+rwX /subjects']); % Fix permission lock
            system(['cd ' fullfile(dataFolder, subjectID, [subjectID, '_freesurfer']) '; @SUMA_Make_Spec_FS -sid ' subjectID '_freesurfer -NIFTI']);
        end        
        % Get the files we need for PCA
        ventricles = fullfile(dataFolder, subjectID, [subjectID '_freesurfer'], 'SUMA', 'fs_ap_latvent.nii.gz');
        white_matter = fullfile(dataFolder, subjectID, [subjectID '_freesurfer'], 'SUMA', 'fs_ap_wm.nii.gz');   
        aseg = fullfile(dataFolder, subjectID, [subjectID '_freesurfer'], 'SUMA', 'aparc.a2009s+aseg_REN_all.nii.gz');
    end

    % Find out how many runs we have in the session based on the run-<>
    % part of the BIDS name. 
    allFuncFiles =  dir(fullfile(dataFolder, subjectID, sessionID, 'func', '*.json'));
    try
        runNum = numel(unique(cellfun(@(f) sscanf(regexp(f, 'run-(\d+)', 'match', 'once'), 'run-%d'), {allFuncFiles.name})));
    catch
        if ~isempty(allFuncFiles)
            runNum = 1;
        else
            error('Your func folder is empty');
        end
    end

    % We run preprocessing twice, one with the specified blur amount and
    % one without blur. Different versions will be used for seed-brain and
    % ROI-ROI analyses respectively. So do 2 iterations. That's unless the
    % blur is set to 'NA' to begin with. In which case, only one iteration
    % is run.
    if strcmp(blur, 'NA')
        iteration = 1;
    else
        iteration = 2;
    end

    % Run through iterations
    for blurs = 1:iteration
        % If we are in the second loop, set blur to 'NA'
        if isequal(blurs,2)
            blur = 'NA';
        end

        % Loop through each run in a session
        for ii = 1:runNum
            
            % If we only have a single run, look for images without _run
            % tag in the BIDS name.
            if isequal(runNum, 1)
                blipForward = fullfile(dataFolder, subjectID, sessionID, 'func', [subjectID '_' sessionID '_task-btoCMRREP2DMEBOLD2x42p5mmisorsfMRI_dir-PA_echo-1_sbref.nii.gz']);
                blipReverse = fullfile(dataFolder, subjectID, sessionID, 'fmap', [subjectID '_' sessionID '_acq-e1_dir-AP_epi.nii.gz']);
                funcDataset = fullfile(dataFolder, subjectID, sessionID, 'func', [subjectID '_' sessionID '_task-btoCMRREP2DMEBOLD2x42p5mmisorsfMRI_dir-PA_echo-*_bold.nii.gz']);
            else
                runNumber = num2str(ii);
                blipForward = fullfile(dataFolder, subjectID, sessionID, 'func', [subjectID '_' sessionID '_task-btoCMRREP2DMEBOLD2x42p5mmisorsfMRI_dir-PA_run-' runNumber '_echo-1_sbref.nii.gz']);
                blipReverse = fullfile(dataFolder, subjectID, sessionID, 'fmap', [subjectID '_' sessionID '_acq-e1_dir-AP_run-' runNumber '_epi.nii.gz']);
                funcDataset = fullfile(dataFolder, subjectID, sessionID, 'func', [subjectID '_' sessionID '_task-btoCMRREP2DMEBOLD2x42p5mmisorsfMRI_dir-PA_run-' runNumber '_echo-*_bold.nii.gz']);
            end
    
            % Insert slice timing info from json to nifti only in the first
            % blur run. Print a warning about not stopping here, as
            % stopping halfway through this function casuses images to get
            % corrupted
            if isequal(blurs,1)
                fprintf('\nAdding slice time information to data. Do not stop the script now or your MRI images get corrupted.\n');
                system(['abids_tool.py -add_slice_times -input ' funcDataset]);
            end
    
            % Prepare afni pipeline script. Start with an empty line
            afni_line = '';
            warpSet = afniWrapper(dataFolder, subjectID, sessionID, T1w, blipForward, blipReverse, funcDataset, combineMethod, blur, aseg, ventricles, white_matter, warpSet, skipPCA);
        
            % Add the run number to the proc script that AFNI creates.
            procScript = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID]);
            if strcmp(blur, 'NA')
                if isequal(runNum, 1)
                    newProcName = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID '.noBlur']);
                    outputReport = fullfile(dataFolder, subjectID, sessionID, ['output.proc.' subjectID '.noBlur']);
                else
                    newProcName = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID '.run-' runNumber '.noBlur']);
                    outputReport = fullfile(dataFolder, subjectID, sessionID, ['output.proc.' subjectID '.run-' runNumber '.noBlur']);
                end
            else
                if isequal(runNum, 1)
                    newProcName = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID '.blur_' blur 'mm']);
                    outputReport = fullfile(dataFolder, subjectID, sessionID, ['output.proc.' subjectID '.blur_' blur 'mm']);
                else
                    newProcName = fullfile(dataFolder, subjectID, sessionID, ['proc.' subjectID '.run-' runNumber '.blur_' blur 'mm']);
                    outputReport = fullfile(dataFolder, subjectID, sessionID, ['output.proc.' subjectID '.run-' runNumber '.blur_' blur 'mm']);
                end
            end
            system(['mv ' procScript ' ' newProcName]);

            % Start the preprocessing. 
            system(['cd ' fullfile(dataFolder, subjectID, sessionID) '; ' 'tcsh -xef ' newProcName ' 2>&1 | tee ' outputReport]);
    
            % Add the run number to the output folder once preprocessing is
            % done.
            outputFolder = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results']);
            if strcmp(blur, 'NA')
                if isequal(runNum, 1)
                    newOutputName = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results.noBlur']);
                else
                    newOutputName = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results.run-' runNumber '.noBlur']);
                end
            else
                if isequal(runNum, 1)
                    newOutputName = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results.blur_' blur 'mm']);
                else
                    newOutputName = fullfile(dataFolder, subjectID, sessionID, [subjectID '.results.run-' runNumber '.blur_' blur 'mm']);
                end
            end
            system(['mv ' outputFolder ' ' newOutputName]);

            % Convert func and anat results to nifti to be used for other
            % software like CONN. 
            func = fullfile(newOutputName, ['errts.' subjectID '.fanaticor+tlrc.HEAD']);
            if ~isfile(func)
                func = fullfile(newOutputName, ['errts.' subjectID '.tproject+tlrc.HEAD']);
            end
            anat = fullfile(newOutputName, ['anat_final.' subjectID '+tlrc.HEAD']);
            system(['cd ' newOutputName ';' '3dAFNItoNIFTI -prefix final_func ' func]);
            system(['cd ' newOutputName ';' '3dAFNItoNIFTI -prefix final_anat ' anat]);

        end
    end
end

% AFNI preprocessing wrapper function for some prespecified options.
function warpSet = afniWrapper(dataFolder, subjectID, sessionID, T1w, blipForward, blipReverse, funcDataset, combineMethod, blur, aseg, ventricles, white_matter, warpSet, skipPCA)

    % The concrete block which will be present regardless of different
    % options
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
    
    % If blur is specified, add step to the preprocessing list and blur
    % size to the end of the concrete line
    if ~strcmp(blur, 'NA')
        afni_line = [afni_line ' -blur_size ' blur ' -blur_in_mask yes -blocks despike tshift align tlrc volreg mask combine blur scale regress'];
    else
        afni_line = [afni_line ' -blocks despike tshift align tlrc volreg mask combine scale regress'];
    end
    
    % If PCA is not skipped, add it to the line as well
    if ~skipPCA
        afni_line = [afni_line ' -anat_follower_ROI aaseg anat ' aseg ' -anat_follower_ROI aeseg epi ' aseg ' -anat_follower_ROI FSvent epi ' ventricles  ' -anat_follower_ROI FSWe epi ' white_matter ' -anat_follower_erode FSvent FSWe -regress_ROI_PC FSvent 3 -regress_ROI_PC_per_run FSvent -regress_anaticor_fast -regress_anaticor_label FSWe -regress_make_corr_vols aeseg FSvent'];
    end
    
    % Add the suppled warps if avaialable
    if ~strcmp(warpSet, 'NA')
        afni_line = [afni_line ' -tlrc_NL_warped_dsets ' warpSet{1} ' ' warpSet{2} ' ' warpSet{3}];
    end
    
    % Run the afni script creation
    system(afni_line);
end