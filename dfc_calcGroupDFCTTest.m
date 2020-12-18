function [CPG1, CPG2, pV, hV] = dfc_calcGroupDFCTTest(handles,GN1,GN2,CN1,CN2)
    % DFC_CALCGROUPDFCTTEST - Returns the DFC for the the groups GN1 and GN2.
    % It also returns the p-values for each DFC point

    % Pull variables from handles that will be used often
    windowSize = handles.FormData.windowSize;
    stepSize = handles.FormData.stepSize;
    subjProp = handles.FormData.subjProp;
    %usePfor = handles.FormData.usePfor; for the future

    % Count the number of subjects in each group
    nG1 = 0;
    nG2 = 0;
    for i = 1 : length(subjProp)
        if ~strcmpi(subjProp(i).code, 'Mean')
            if subjProp(i).group == GN1
                nG1 = nG1 + 1;
            elseif subjProp(i).group == GN2
                nG2 = nG2 + 1;
            end
        end
    end
    
    % Go through each subject and calculate the cp for each group
    N = uint16(ceil(subjProp(1).tcDim(1) - windowSize) / stepSize);
    CPG1 = zeros(nG1, N);
    CPG2 = zeros(nG2, N);
    ixG1 = 1; % index for group1
    ixG2 = 1; % index for group2
    for i = 1 : length(subjProp)
        if ~strcmpi(subjProp(i).code, 'Mean')
            % If this subject is in group1 and not Mean then open the 2
            % components and get the CP
            if subjProp(i).group == GN1
                kn = subjProp(i).tcDim(1);
                V = spm_vol(subjProp(i).tcFFile);    % open data file
                rmsig1 = spm_sample_vol(V,1:kn,CN1*ones(1,kn),ones(1,kn),0);
                rmsig2 = spm_sample_vol(V,1:kn,CN2*ones(1,kn),ones(1,kn),0);
                CPG1(ixG1,:) = dfc_corrTWin(rmsig1,rmsig2, handles);
                ixG1 = ixG1 + 1;
            % If this subject is in group1 and not Mean then open the 2
            % components and get the CP
            elseif subjProp(i).group == GN2
                V = spm_vol(subjProp(i).tcFFile);    % open data file
                rmsig1 = spm_sample_vol(V,1:kn,CN1*ones(1,kn),ones(1,kn),0);
                rmsig2 = spm_sample_vol(V,1:kn,CN2*ones(1,kn),ones(1,kn),0);
                CPG2(ixG2,:) = dfc_corrTWin(rmsig1,rmsig2, handles);
                ixG2 = ixG2 + 1;
            end
        end
    end
    
    % Calculate p-values from Wilcoxon rank sum test
    %
    % The Wilcoxon rank sum test is a nonparametric test for two
    %   populations when samples are independent. If X and Y are
    %   independent samples with different sample sizes, the test statistic
    %   which ranksum returns is the rank sum of the first sample.
    %
    % The Wilcoxon rank sum test is equivalent to the Mann-Whitney U-test.
    %   The Mann-Whitney U-test is a nonparametric test for equality of 
    %   population medians of two independent samples X and Y.
    N = size(CPG1,2);
    pV = zeros(1, N);
    hV = zeros(1, N);
    for i = 1 : N
        if isempty(CPG1(:,i)) || isempty(CPG2(:,i))
            pV(i) = 0;
            hV(i) = 0;
        else
            [pV(i), hV(i)] = ranksum(CPG1(:,i), CPG2(:,i));
        end
    end
