function ASLregister2MNI(aslMaps, calibRef, T1, template, parcel)

% Cellify the input if it is not
if ~iscell(aslMaps)
    aslMaps = {aslMaps};
end

% Create a workdir
workdir = fullfile(fileparts(calibRef), 'workdir');
if ~isfolder(workdir)
    mkdir(workdir)
end

% % Bias correct T1
corrected_T1 = fullfile(workdir, 'N4T1.nii.gz');
system(['N4BiasFieldCorrection -i ' T1 ' -o ' corrected_T1]);

% Register calibRef to T1 linearly
system(['antsRegistrationSyN.sh -m ' calibRef ' -f ' corrected_T1 ' -n 6 -t r -o ' fullfile(workdir, 'calib2T1')])

% Register T1 to template non-linearly 
system(['antsRegistrationSyN.sh -m ' corrected_T1 ' -f ' template ' -n 6 -o ' fullfile(workdir, 'T12temp')])

% % Resample template and parcels to ASL res
templateResampled = fullfile(workdir, 'resampledTemp.nii.gz');
parcelResampled = fullfile(workdir, 'parcelsResampled.nii.gz');
system(['flirt -in ' template ' -ref ' template ' -applyisoxfm 2.5 -nosearch -out ' templateResampled]);
system(['flirt -in ' parcel ' -ref ' parcel ' -applyisoxfm 2.5 -interp nearestneighbour -nosearch -out ' parcelResampled]);

% Apply the transformation to aslMaps
firstLvlAffine = fullfile(workdir, 'calib2T10GenericAffine.mat');
secondLvlAffine = fullfile(workdir, 'T12temp0GenericAffine.mat');
secondLvlWarp = fullfile(workdir, 'T12temp1Warp.nii.gz');

for ii = 1:length(aslMaps)
    [path, name, ext] = fileparts(aslMaps{ii});
    outName = fullfile(path, ['template_', name, ext]);
    system(['antsApplyTransforms -i ' aslMaps{ii} ' -r ' templateResampled ' -t ' secondLvlWarp ' -t ' secondLvlAffine, ' -t ' firstLvlAffine, ' -o ' outName])
end

end
