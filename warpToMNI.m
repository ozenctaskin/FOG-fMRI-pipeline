function warpToMNI(dataFolder, subjectID, runNumber, MNIPath)

% Find the final_anat.nii.gz and final_func.nii.gz
anatomicalData = fullfile(dataFolder, subjectID, [subjectID, '.results.run-', runNumber], 'final_anat.nii');
functionalData = fullfile(dataFolder, subjectID, [subjectID, '.results.run-', runNumber], 'final_func.nii');

% Run non-linear registration between anatomical and MNI
system(['antsRegistrationSyN.sh -f ', MNIPath, ' -m ', anatomicalData, ' -n 9 -o ' fullfile(dataFolder, subjectID, [subjectID, '.results.run-', runNumber], 'finalAnat2MNI')]);

% We need a single volume of the func as a target
singleEPI = fullfile(dataFolder, subjectID, [subjectID, '.results.run-', runNumber], 'single_epi.nii.gz');
system(['fslroi ', functionalData, ' ', singleEPI, ' 0 1'])

% Warp functional image to MNI template. Don't change the resolution
linearRegistration = fullfile(dataFolder, subjectID, [subjectID, '.results.run-', runNumber], 'finalAnat2MNI0GenericAffine.mat');
nonLinearRegistration = fullfile(dataFolder, subjectID, [subjectID, '.results.run-', runNumber], 'finalAnat2MNI1Warp.nii.gz');
system(['antsApplyTransforms -v -e 3 -i ', functionalData, ' -r ', singleEPI, ' -t ', nonLinearRegistration, ' -t [ ', linearRegistration, ',0 ] -o ', fullfile(dataFolder, subjectID, [subjectID, '.results.run-', runNumber], 'final_func_MNI.nii.gz')]);

end


