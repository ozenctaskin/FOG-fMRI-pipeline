function makeAnat(inv2, unit)

    % This is a wrapper around 3dMPRAGEise to cleanup MP2RAGE images.
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
                'cd 3dMPRAGEise; chmod +x *; cp * ' afniPath ';rm -r 3dMPRAGEise'])
    end

    % Run 3dMPRAGEise to get the final anatomical image 
    [anatPath, ~, ~] = fileparts(inv2);
    system(['cd ' anatPath ';3dMPRAGEise -i ' inv2 ' -u ' unit])

end