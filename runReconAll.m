function runReconAll(anatomicalPath, subjectID)

    % This is a wrapper around Freesurfer recon-all. Run @SUMA_Make_Spec_FS
    % following recon-all to create afni-compatible files. We will use 
    % these files to regress out white matter and CSF masks from resting 
    % state data in afni_proc which is run by the preprocessWrapper 
    % directory.
    %
    %   anatomicalPath: Path to anatomical data
    %   subjectID: Subject ID to run

    % Run recon-all
    system(['recon-all -all -subject ' subjectID ' -i ' anatomicalPath])

    % Run Suma stuff
    system(['cd $SUBJECTS_DIR/' subjectID '; @SUMA_Make_Spec_FS -sid ' subjectID ' -NIFTI'])