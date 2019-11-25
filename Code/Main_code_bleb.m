%###-------#### This Code is to measure the blebs properties of a
%time-lapse image of a cell
% 1-code will make an estimate mask of the whole cell body 
% 2. It will ask you if you are happy with this
    % i. "Yes" will go next step 
    % ii. "Adjust" will put a polygon back on the image and you can adjust it
    % iii. "manual" will let you draw your own mask
% 3.
% ch1 is red, channel 2 is green 
%%
clc, clear all;
[fName, pName] = uigetfile('*.tif');  
info = imfinfo(fName);
num_images = numel(info);

dummy=1;
for i=1:3:num_images 
Data1(:,:,dummy) = imread(fullfile(pName, fName),i);
 dummy=dummy+1; 
end

dummy2=1;
for i=2:3:num_images 
Data2(:,:,dummy2) = imread(fullfile(pName, fName),i);
 dummy2=dummy2+1; 
end

dummy3=1;
for i=3:3:num_images 
Data3(:,:,dummy3) = imread(fullfile(pName, fName),i);
 dummy3=dummy3+1; 
end

imageData1=double(Data1(:,:,1));
imageData2=double(Data2(:,:,1));
imageData3=double(Data3(:,:,1));
mixIm=imfuse(imageData1,imageData2,'falsecolor','ColorChannels',[2 1 0]);
%imshow(mixIm);

path =[pwd '\'];
outputPath = [path 'Analysed_' fName(1:length(fName)-4) '\'];%function_GenerateNumber(j,2)
mkdir(outputPath);

%##### ask for time interval 

 prompt1 = {'What is the time interval in sec?:'};
    dlg_title2 = 'Input';
    num_lines2 = 1;
    %(9.4102 pixels per micron), 1 pixel is 0.1899, 20um/0.1899
    defaultans = {'9'};
    TimeInterval= inputdlg(prompt1,dlg_title2,num_lines2,defaultans);
    TimeInterval = str2double(TimeInterval{:}); 
    

for t=1:length(Data1(1,1,:))
    
    clearvars -except t fName pName myimage isOk Data2 Data1 num_images info outputPath TimeInterval Y_row X_col Data3

    imageData1=double(Data1(:,:,t));
    imageData2=double(Data2(:,:,t));
    imageData3=double(Data3(:,:,t));

    mixIm=imfuse(imageData1,imageData2,'falsecolor','ColorChannels',[2 1 0]);
    %imshow(mixIm);
    
    %mask=zeros(size(Icrop1));
    ImCh1=imageData1; % in this data set channel 1 is green =cytoskeleton 
    [Y_row, X_col]=size(ImCh1);
 isOk = false ;
 while ~isOk % go to line 142 to see the argument "selection2" 
     
%###-------#### use this function to automatically detect the cell body
    [mask_cell_body,maskedImage] = segmentImageFluoImV5(ImCh1);
    %imshow(mask_cell_body);
    
    %###-------#### show boundary of masked image
  % show the BF image
  
    % hfig=figure;Im=mixIm;imshow(Im,[]);%label2rgb(L, @jet, [.5 .5 .5]))
    hfig=figure;Im=imageData1;imshow(Im,[])
    scrSize=get(0, 'MonitorPositions');%or this: get(0, 'Screensize')
        set(hfig, 'Position',[50 50 scrSize(1,3)-200 scrSize(1,4)-200] ); % maximize the image
    hold on
    text(30, 26, [ 'Frame: ' num2str(t),],'Color',[1 1 0.99],'FontSize',40); %frame number
       
    hold on 
  [B,L] = bwboundaries(mask_cell_body,'noholes');
    for k = 1:length(B)
       boundary = B{k};
       plot(boundary(:,2), boundary(:,1), '-r', 'LineWidth', 1)
    end

    % tell me which frame I am looking at
 

   % newImg = cat(2,A,mixIm);
 %###-------#### display a question dialog box and decide between manual and
  %automatic
       selection = questdlg('Are you happy with whole cell ROI selection?',...
          'Selection',...
          'Yes','Adjust','Draw manually','Draw manually'); 
        switch selection 
          case 'Draw manually'
            % if No, use the CROIEditor
            close
            roiwindow = CROIEditor(mat2gray(mixIm)); 
            title('Step 1: Please select the cell perimeter','FontSize',20);
            set(get(gca,'title'),'Position',[5.5 0.4 1.00011])
            set(gcf, 'Position', get(0, 'Screensize'));

            % wait for roi to be assigned 
            waitfor(roiwindow,'roi'); 
                if ~isvalid(roiwindow) 
                    disp('you closed the window without applying a ROI, exiting...'); 
                    return 
                end 
            % get ROI information, like binary mask, labelled ROI, and number of 
            % ROIs defined 
            [mask_cell_body, labels_cell_body, n_cell_body] = roiwindow.getROIData; 
            delete(roiwindow); 
            close
          case 'Yes'
              %if yes close the image and proceed
            close
         %return
          case 'Adjust'
            close
            %Create draggable, resizable interactive polygon based on the estimated mask and
            %generate a new mask
          
           hfig=figure; h_im=imshow(mat2gray(Im));
            title('Resize the polygon, double click inside the mask');
            hold on;
            [B_adj,L_adj] = bwboundaries(mask_cell_body,'noholes');
                x=B_adj{1, 1}(:,1);
                y=B_adj{1, 1}(:,2);
                % to have less point on the impoly,  take every (2nd) nth element from each
                % column in a matrix
                reducedNum_x = x(6:6:end,:);
                reducedNum_y = y(6:6:end,:);
         hold on % and tell me the frame number
         text(30, 26, [ 'Frame: ' num2str(t),],'Color',[1 1 0.99],'FontSize',40); %frame number
                
             h = impoly(gca,[reducedNum_y, reducedNum_x]);
            scrSize=get(0, 'MonitorPositions');%or this: get(0, 'Screensize')
            set(hfig, 'Position',[50 50 scrSize(1,3)-200 scrSize(1,4)-200] ); % maximize the image
            position = wait(h);
            mask_cell_body = createMask(h,h_im);
            close
            
       end

%###-------#### make the new image (only show the cell body)
    % Display the image with the mask "burned in."
    % Create masked image.
    mask_burn_cell_body =ImCh1;
    mask_burn_cell_body(~mask_cell_body) = 255;
    %Image Normalization in the range 0 to 1

    mask_burn_cell_body2 = mat2gray(mask_burn_cell_body);

%###-------#### start the bleb measurement 
    roiwindow = CROIEditor(mask_burn_cell_body2); % if you want to see the masked image
    %roiwindow = CROIEditor(myimage); % if you want to see the original image
    title('Step 2: Please select the blebs perimeter','FontSize',20);
    set(get(gca,'title'),'Position',[5.5 0.4 1.00011])
    %set(gcf,'name','  Myfig')%change the name of the window
    set(gcf, 'Position', get(0, 'Screensize'));

        % wait for roi to be assigned 
        waitfor(roiwindow,'roi'); 
        if ~isvalid(roiwindow) 
        disp('you closed the window without applying a ROI, exiting...'); 
        return 
        end 
    % get ROI information, like binary mask, labelled ROI, and number of 
    % ROIs defined 
    [mask_bleb, labels_bleb, n_bleb] = roiwindow.getROIData; 
    delete(roiwindow); 
    close

%%###-------#### info regarding pixel size
    prompt = {'Enter the Pixel size (um):'};
    dlg_title = 'Input';
    num_lines = 1;
    %(9.4102 pixels per micron), 1 pixel is 0.1899, 20um/0.1899
    pixelVal=1/info(1).XResolution;
    defaultans = {num2str(pixelVal)};
    Pixelsize = inputdlg(prompt,dlg_title,num_lines,defaultans);
    Pixelsize2 = str2double(Pixelsize{:}); 
    
 %%###-------#### Disconnect the objects(blebs)  
    ConnectedObjects = bwconncomp(mask_bleb,4); %// Find connected components.
mask_bleb = labelmatrix(ConnectedObjects);

%%###-------#### show both boundaries on the image
  
  TotalCel_mask=logical(mask_bleb)+mask_cell_body; % combine two mask to get the cell body mask
  TotalCel_mask2=logical(TotalCel_mask);
    %figure;imshow(double2logic(TotalCel_mask));
    %figure;imshow(TotalCel_mask);
    hfig=figure;Im=imshow(mat2gray(mixIm));
        iptsetpref('ImshowBorder','tight'); % tight, close, border around the image:
        % Figure size a bit smaller than full screen
        scrSize=get(0, 'MonitorPositions');%or this: get(0, 'Screensize')
        set(hfig, 'Position',[50 50 scrSize(1,3)-200 scrSize(1,4)-200] ); % maximize the image
    hold on
% add the whole cell body mask 
    [B,L] = bwboundaries(TotalCel_mask,'noholes');
            for k = 1:length(B)
               boundary = B{k};
               plot(boundary(:,2), boundary(:,1), '-g', 'LineWidth', 1)
            end

    hold on
    % add the blebs mask 
    TotalBlebs_mask = mask_bleb;
    [B2,L2] = bwboundaries(TotalBlebs_mask);%,'noholes');
        for k2 = 1:length(B2)
           boundary2 = B2{k2};
           plot(boundary2(:,2), boundary2(:,1), '-c', 'LineWidth', 1)
        end
        
    hold on
    % add annotation to the figure
    % move this to up close to f loop [Y_row, X_col]=size(ImCh1); %x
    MinXY=0;
    hold on
    % Put a micron bar up    %plot line on image
    p1 = [Y_row-20,30];
    barsize=20/Pixelsize2;
    p2 = [Y_row-20,30+barsize];% 10/0.0931pixel size -->10 um (5.265 pixels per micron), 1 pixel is 0.1899, 20um/0.1899
    %# plot the points. may have to swap x and y
    %plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',10);
    hLine=line([p1(2),p2(2)],[p1(1),p2(1)],'Color','white','LineWidth',10);%line([x1 x2], [y1 y2]);
    % Create a binary image ("mask") from the ROI object.
    %binaryImage2 = hLine.createMask();
    text(36,p1(1)-30, '20 \mum','Color',[1 1 0.99],'FontSize',55); % scale bar umber
    
    timeframe=(t-1)*TimeInterval; % Time frame is 9sec
    X_textTime=X_col-65;
    Y_textTime=Y_row-25;
    text(X_textTime,Y_textTime, [ num2str(timeframe),' s'],'Color',[1 1 0.99],'FontSize',40); %frame number
    %Y_row-28,X_col-60
    drawnow;
    hold off
     
        
%###-------#### Calculate the total cell volume: Get properties of the masks
% Get properties.
properties_CelBody = regionprops(TotalCel_mask2, {'Area', 'Eccentricity', 'EquivDiameter', 'EulerNumber', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Perimeter'});
properties_blebs = regionprops(TotalBlebs_mask, {'Area', 'Eccentricity', 'EquivDiameter', 'EulerNumber', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Perimeter'});
CellArea=[properties_CelBody.Area];
Bleb_To_Cellsize_Perc=(([properties_blebs.Area]/CellArea)*100);
No_Blebs_PerCell=length([properties_blebs.Area]);

%###-------#### decide if the user is happy with final results or not

 selection2 = questdlg(['Are you happy with the final results (#blebs=' num2str(No_Blebs_PerCell) ')?'],...
          'Selection',...
          'Yes','Redraw','Redraw'); 
        switch selection2 
         case 'Redraw'
           close all
           clearvars -except fName pName myimage isOk ImCh1 imageData1 imageData2 Data2 Data1 num_images info mixIm t outputPath TimeInterval Y_row X_col imageData3
           isOk = false;
            
            case 'Yes'
              isOk = true;
              frameNumber=t;
              save(fullfile(outputPath,(['Output_' fName(1:length(fName)-4) '_Frame_' sprintf('%1.0f',frameNumber') '.mat']))); % save file
              %saveas(hfig,['Output_' fName(1:length(fName)-4) '_Frame_' sprintf('%1.0f',frameNumber')  '.bmp']); % save image
              export_fig(fullfile(outputPath,['Output_' fName(1:length(fName)-4), '_Frame_', sprintf('%1.0f',frameNumber') '.png']));%export fig as pdf and Add A at the beginning              close all
        end
            
 end    
 close 
end

