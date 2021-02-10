function twcf_makeFGStim

% TWCF figure ground stimuli (Lamme) 
% Febraury 2021 
% Karen Tian

%% params 
saveFig = 1; % save fig to directory 

% ground 
pixelsPerDegree = 99; 
sizeIm = [600 1000]; % size of image 
lineLength = 50; % length of texture lines
lineWidth = 2; % width of texture lines
lineAngle = 60; % angle (degrees) of texture lines, scalar 
imContrast = .3; % proportion of image covered by line 

% figure 
figRad = 260; % figure aperture size (radius) 
apertureType = 'square'; %  determines circular figure aperture edge type % EDIT to make other shapes 
figGrating = 1; % logical for "grating" figure 

% grating params 
spatialFrequency = 0.5; 
tiltDegrees = 30;
phase = 0;
contrast = 1;

%% setup 
im = ones(sizeIm); % blank im 
sizeDegrees = max(size(im))/pixelsPerDegree; % side length in degrees of visual angle
nLines = round(((sizeIm(1)*sizeIm(2))/(lineLength*lineWidth)) * imContrast); % number of lines to draw
if lineAngle == 90 
    slope = 1; 
else
    slope = tan(deg2rad(lineAngle)); % angle to rise/run 
end

%% draw bg lines 
randX = randi([1-lineLength/2,sizeIm(2)+lineLength/2],1,nLines)'; % randomly generate line middle points 
randY = randi([1-lineLength/2,sizeIm(1)+lineLength/2],1,nLines)'; 

% lines plotted on im 
% is there better way to do this.. why do dimenions change..alternatively, manipulate im directly
% figure
% imshow(im) 
% hold on 
% for i = 1:nLines
%     lineSlope = slope(randsample(numel(lineAngle),1))*lineLength;
%     x = [randX(i)-lineLength/2, randX(i)+lineLength/2]; 
%     y = [randY(i)-lineSlope/2, randY(i)+lineSlope/2];
%     plot(x,y,'LineWidth',lineWidth,'Color','k')
% end
% F = getframe(gcf); 
% bg = frame2im(F);
% bg(bg~=0) = 1; 
% bg = squeeze(double(bg(:,:,1))); 

% try insert shape method
% works but slow.. edit to non loop 
bg = im; 
for i = 1:nLines
    lineSlope = slope(randsample(numel(lineAngle),1))*lineLength;
    x = [randX(i)-lineLength/2, randX(i)+lineLength/2]; 
    y = [randY(i)-lineSlope/2, randY(i)+lineSlope/2];
    bg = insertShape(bg,'Line',[x(1) y(1) x(2) y(2)],'LineWidth',lineWidth,'Color','black');
end
bg = squeeze(double(bg(:,:,1))); 

bg = im; 
lineSlope = slope(randsample(numel(lineAngle),1))*lineLength;

if lineAngle == 90
    x = cat(2, randX, randX); 
else
    x = cat(2, randX-lineLength/2, randX+lineLength/2); 
end
y = cat(2, randY-lineSlope/2, randY+lineSlope/2); 

bg = insertShape(bg,'Line',[x(:,1) y(:,1) x(:,2) y(:,2)],'LineWidth',lineWidth,'Color','black');

bg = squeeze(double(bg(:,:,1))); 
figure
imshow(bg)

%% draw fig lines 
figSlope = slope-pi/2; % fig lines orthogonal to bg lines 
% figX = randi([1-lineLength,sizeIm(1)+lineLength],1,nLines); 
% figY = randi([1-lineLength,sizeIm(2)+lineLength],1,nLines); 
fig = im; 
for i = 1:nLines
    lineSlope = figSlope(randsample(numel(lineAngle),1))*lineLength;
    x = [randX(i)-lineLength/2, randX(i)+lineLength/2]; % using same midpoints as bg, but could also regenerate randomly
    y = [randY(i)-lineSlope/2, randY(i)+lineSlope/2];
    fig = insertShape(fig,'Line',[x(1) y(1) x(2) y(2)],'LineWidth',lineWidth,'Color','black');
end
fig = squeeze(double(fig(:,:,1))); 
% figure
% imshow(fig)

%% aperture fig 
if figGrating
    grating = rd_grating(pixelsPerDegree, sizeDegrees, spatialFrequency, tiltDegrees, phase, contrast);
    grating(grating>.5) = 1; grating(grating<=.5) = 0; % hard edge
    grating = grating(1:size(im,1),1:size(im,2));
    fig(logical(grating)) = 1;
    bg(~logical(grating)) = 1;
end
[figAp, ap] = twcf_aperture(fig, apertureType, figRad, 0); % cutout figure shape 

%% combine fig + ground 
if figGrating
    fgIm = imfuse(bg,fig,'blend');
    fgIm = double(fgIm)/255; 
    fgIm(~logical(ap)) = 1; 
else
    fgIm = bg; 
    fgIm(logical(ap)) = figAp(logical(ap)); 
end

%% show final image 
figure
imshow(fgIm)
titleText = sprintf('FG_lineLength%d_density%d_gratingAngle%d',lineLength,nLines,tiltDegrees); 
title(sprintf('line length: %d; nLines: %d; line angle: %d, grating angle: %d',lineLength,nLines,lineAngle,tiltDegrees),...
    'FontSize', 14)
if saveFig 
    print(gcf,'-dpng','-painters',sprintf('%s/figs/%s.png',pwd,titleText))
end
