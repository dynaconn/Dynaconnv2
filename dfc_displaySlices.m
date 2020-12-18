function dfc_displaySlices(handles, img)
    % Display the img data into the 2 axes
    
    % Display the names of the panels
    set(handles.uipanel1,'Title',handles.FormData.panelStr1,'FontSize',16);
    set(handles.uipanel2,'Title',handles.FormData.panelStr2,'FontSize',16);
    
    % 1st and last slice to show in plot
    param.start = 16;        param.stop = 75;
    % Number of images in each dimention for the montage
    numImagesX = 4;   numImagesY = 5;
    % Data limits to cut out of overlay of icasig onto structural img
    param.UL = handles.FormData.UL;
    param.LL = handles.FormData.LL;
    % Read and covert the data into 2 montages
    param.mm = numImagesX;    param.nn = numImagesY;
    % The number of components to make a montague for
    param.numOfComp = 2;
    % Make the montague
    [data_img, sliceRange, maxICAIM, minICAIM] = dfc_imgTile(param, img);
    dim = size(data_img);
  
    % Properties for the component plots
    txtFont = 12;
    smTxtFont = 9;

    % Load color map and data intervals
    load('dfc_colormap.mat');
    minInterval = 0; maxInterval = 100;
    CLIM = [minInterval 2*maxInterval]; % Color map limits
    
    % Axes handles
    ax(1) = handles.axes1;
    ax(2) = handles.axes2;
    
    for comp = 1 : 2  % Do for each component
        
        % Plot the images in the component window
        %image(squeeze(data_img(:,:,comp)),'Parent',ax(comp))
        image(squeeze(data_img(:,:,comp)), 'parent', ...
            ax(comp), 'CDataMapping', 'scaled');

        set(ax(comp), 'clim', CLIM); % Set the color axis to specified range
        colormap(ax(comp),cm);  % Set the color map for this plot
        axis(ax(comp), 'off'); % Get rid of the axis numbers
    
        drawnow;

        % Convert slideRange to txt slide numbers in 2mm
        % Will need to change is using something besides 2mm
        for i = 1 : length(sliceRange)
            slideMM{i} = num2str(sliceRange(i)*2-74);
        end
        
        % Since we reversed the order of z images, also flip the 
        % Add slice numbers to each slice image.
        textCount = 0;
        yPos = 1 + dim(1) / numImagesY;
        for nTextRows = 1:numImagesY
            xPos = 1;
            for nTextCols = 1:numImagesX
                textCount = textCount + 1;
                if textCount <= length(sliceRange)
                    txHandle(textCount) = text(xPos, yPos, slideMM(textCount), 'color', [1 1 1],  ...
                        'fontsize', smTxtFont, 'HorizontalAlignment', 'left', 'verticalalignment', 'bottom', ...
                        'FontName', 'times', 'parent', ax(comp));
                end
                xPos = xPos + (dim(2) / numImagesX);
            end
            % end for cols
            yPos = yPos + (dim(1) / numImagesY); % update the y position
        end
        % end for rows
        clear slideMM;
        
        % Get axis limits
        xLimAxes = get(ax(comp), 'XLim');
        yLimAxes = get(ax(comp), 'YLim');

        % Plot the L and R to tell brain orientation
        firstLRPos = [xLimAxes(2) + 2, 0.5*yLimAxes(2)];
        secondLRPos = [xLimAxes(1) - 2 - txtFont, 0.5*yLimAxes(2)];
        text(firstLRPos(1), firstLRPos(2), 'R', ...
            'FontSize', txtFont, 'parent', ax(comp), ...
            'fontWeight', 'bold', 'FontUnits', 'pixels');
        text(secondLRPos(1), secondLRPos(2), 'L', ...
            'FontSize', txtFont, 'parent', ax(comp), ...
            'fontWeight', 'bold', 'FontUnits', 'pixels');
        
        
        % Resize and position of the color bar
        %cAxesPos = [425 20 20 480];
        %barPos = get(ColorbarHandle,'Position');
        %barPos(1) = barPos(1) + 45;
        %set(ColorbarHandle, 'Position', barPos);
        
        % A messy hack to get the drawing the right size on mac and
        % windows.  Only resize initialy; not when threshold is changed.
        if handles.FormData.InitialDraw
            % Resize and position of the slice plot
            %cAxesPos = [425 20 20 480];
            axPos = get(ax(comp),'Position');
            axPos(3) = axPos(3) + 0.1*axPos(3);
            set(ax(comp), 'Position', axPos);
        end
        
        % Call up a color bar
        ColorbarHandle = colorbar('peer', ax(comp));
        set(ColorbarHandle, 'units', 'pixels');
        
        % Put axis limits on the color bar
        ChildH=get(ColorbarHandle,'Children');
        set(ChildH, 'YData', CLIM);
        set(ColorbarHandle,'YLim',[minInterval maxInterval]);
        set(ColorbarHandle,'YTick',[]); % get rid of the inner tick marks

        % Create min max labels colorbar axis
        maxLabel = num2str(round(maxICAIM(comp)*10)/10);
        minLabel = num2str(round(minICAIM(comp)*10)/10);

        % Add min max labels to colorbar
        %text(4, 2, minLabel, 'units', 'data', 'FontUnits', 'pixels', ...
          %  'FontSize', txtFont, 'parent', ColorbarHandle);
        %text(4, 98, maxLabel, 'units', 'data', 'FontUnits', 'pixels', ...
           % 'FontSize', txtFont, 'parent', ColorbarHandle);
           
           %Andrew and Zak commented out the preceeding four lines
           %10/21/2020
    end
end
