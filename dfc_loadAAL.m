 function handles = dfc_loadAAL( handles )
%DFC_LOADAAL Summary of this function goes here
%   Detailed explanation goes here (MM Test)

    h = msgbox('Loading default region atlas');
    
    % Unzip AAL file and then, load then delete unzipped file
    oldDir = pwd;
    cd('templates');
    gzAALFile = '3mm_SPMresliced_aal.nii.zip';
    %gzAALFile = 'aal_2mm.nii.zip';
    unzippedfile = unzip(gzAALFile);
    vol_info = spm_vol(unzippedfile{1});    % open data file
    img = spm_read_vols(vol_info); % Retrive data
    delete(unzippedfile{1});
    cd(oldDir);
    
    % Read aal text
    start_ix = 1;
    labels = dfc_parseRegMapLegend('templates/aal.nii.txt');
    handles.FormData.regMap = ...
        dfc_build_regMap(handles, img, labels, start_ix );

    % Set label and regMap status to default meaning default was loaded.
    handles.FormData.labelStatus = 'default';
    handles.FormData.regMapStatus = 'default';

    close(h);
end

