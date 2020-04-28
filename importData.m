function data = importData(directory)
    %Check if input is a valid directory
    if (exist(directory) ~= 7)
        error('importData: Directory does not exist');
    end

    % Load A-E (stored in 'Z', 'O', 'N', 'F', 'S' zip files respectively)
    folder = ['Z', 'O', 'N', 'F', 'S'];
    
    for i = 1:5
        %Get the names of *.txt files in the directory
        files = dir(strcat(directory, '\', folder(i), '\*.txt'));

        %Import all *.txt files in the directory
        numFiles = length(files);

        %Check to see if any text files are found
        if (numFiles == 0)
            error('importData: No *.txt files found');
        end

        j = 1;
        for k = numFiles:-1:1

            filename = files(k).name;
            handle = strcat(directory, '\', folder(i), '\', filename);
            fd = fopen(handle);
            %filedata = readtable(fd,'delimiter','\n','readvariablenames',true);
            filedata = fscanf(fd, '%d\n', [1,4096]);
            data(i).eeg(j,:) = filedata;
            j = j+1;
            fclose(fd);
        end
    
    end
    
    disp('Saving data to eegData.mat...')
    pause(1)
    save('eegData.mat','data','-v7.3');
end