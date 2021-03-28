 function handles = dfc_loadAAL( handles )
%DFC_LOADAAL Summary of this function goes here
%   Detailed explanation goes here (MM Test)

    h = msgbox('Loading default region atlas');
    
    % Unzip AAL file and then, load then delete unzipped file
    oldDir = pwd;
    
    selection = input('use default aal atlas? Y/N ', 's')
    %Andrew and Zak added case for user input atlas and labels
    switch selection
        case 'Y'
            cd('templates');
            gzAALFile = '3mm_SPMresliced_aal.nii.zip';
            %gzAALFile = 'aal_2mm.nii.zip';
            unzippedfile = unzip(gzAALFile);
            vol_info = spm_vol(unzippedfile{1});    % open data file
            img = spm_read_vols(vol_info); % Retrive data
            delete(unzippedfile{1});
            labelsfilename = 'aal.nii.txt'
            labels = dfc_parseRegMapLegend(labelsfilename);
            cd(oldDir);
            
        case 'N'
            
            [atlasfilename, atlaspath] = uigetfile('*.nii')
            %browse and select
            %%Andrew, change back to aal.nii.txt
            %img = spm_read_vols(spm_vol('C:\Users\18327\Documents\GitHub\Dynaconnv2\templates\atlas_update2018_resamp2mm.nii'));
            img = spm_read_vols(spm_vol(fullfile(atlaspath, atlasfilename)));
            [labelsfilename,labelspath] = uigetfile('*.txt');
            labels = dfc_parseRegMapLegend(fullfile(labelspath,labelsfilename));

    end    
    
    % Read aal text
    start_ix = 1;
    handles.FormData.regMap = ...
        dfc_build_regMap(handles, img, labels, start_ix );

    % Set label and regMap status to default meaning default was loaded.
    handles.FormData.labelStatus = 'default';
    handles.FormData.regMapStatus = 'default';

    close(h);
end

