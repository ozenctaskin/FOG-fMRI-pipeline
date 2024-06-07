function anatomicalPath = makeAnat(inv2, unit)

    % This is a wrapper around Sri's 3dMPRAGEise to cleanup MP2RAGE images.
    %
    %   inv2: Path to the inv2 image
    %   unit: Path to the UNIT image
    %
    %   Output image has the _unbiased_clean tag. This is your cleaned up
    %   anatomical image.
    
    % Make sure the 3dMPRAGEise is installed. If not install it in afni dir
    [~, afniPath] = system('which afni');
    afniPath = afniPath(1:end-6);
    if ~isfile(fullfile(afniPath, '3dMPRAGEise'))
        fprintf('Installing 3dMPRAGEise as you do not have it')
        system(['cd /tmp; git clone https://github.com/srikash/3dMPRAGEise.git;', ...
                'cd 3dMPRAGEise; chmod +x *; cp * ' afniPath ';rm -r 3dMPRAGEise']);
    end

    % Run 3dMPRAGEise to get the final anatomical image 
    [anatPath, ~, ~] = fileparts(inv2);
    system(['cd ' anatPath ';3dMPRAGEise -i ' inv2 ' -u ' unit]);

    % Get the cleaned up anatomical path to pass as a function output
    [unitFolder, unitName, unitExtension] = fileparts(unit);
    if strcmp(unitExtension, '.gz')
        anatomicalPath = fullfile(unitFolder, [unitName(1:end-4) '_unbiased_clean.nii']);
    else
        anatomicalPath = fullfile(unitFolder, [unitName '_unbiased_clean.nii']);
    end
end