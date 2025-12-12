function cleanFuncResults(dataPath, subjectID)
    
    % Combine subjectPath
    subjectPath = fullfile(dataPath, subjectID);

    % Get session folders (ses-*)
    sesFolders = dir(fullfile(subjectPath, 'ses-*'));
    sesFolders = sesFolders([sesFolders.isdir]);

    for s = 1:length(sesFolders)
        sesPath = fullfile(subjectPath, sesFolders(s).name);

        % Results folders containing ".results"
        resultsFolders = dir(fullfile(sesPath, '*.*results*'));
        resultsFolders = resultsFolders([resultsFolders.isdir]);

        for r = 1:length(resultsFolders)
            resPath = fullfile(sesPath, resultsFolders(r).name);

            % Get contents of results folder
            contents = dir(resPath);

            for c = 1:length(contents)
                item = contents(c);

                % Skip . and ..
                if strcmp(item.name, '.') || strcmp(item.name, '..')
                    continue;
                end

                fullItemPath = fullfile(resPath, item.name);

                % Handle folders
                if item.isdir
                    
                    % KEEP if folder starts with QC or tedana
                    if startsWith(item.name, 'QC') || startsWith(item.name, 'tedana')
                        continue;
                    end

                    % Otherwise delete folder
                    fprintf('Deleting folder: %s\n', fullItemPath);
                    rmdir(fullItemPath, 's');
                
                else
                    % Handle files: keep only final_func, final_anat
                    keepFile = strcmp(item.name, 'final_func.nii') || ...
                               strcmp(item.name, 'final_anat.nii');

                    if ~keepFile
                        fprintf('Deleting file: %s\n', fullItemPath);
                        delete(fullItemPath);
                    end
                end
            end
        end
    end

    fprintf('Cleanup completed for subject: %s\n', subjectPath);
end
