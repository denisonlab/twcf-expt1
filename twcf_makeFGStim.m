function [fgIm] = twcf_makeFGStim(lineLength,lineAngle,figTilt,imContrast,isFig)

% function [fgIm] = twcf_makeFGStim(lineLength,lineAngle,figTilt,imContrast)
% 
% Generates figure ground stimuli (Lamme) for TWCF expt 1. 
% 
% INPUTS
%   lineLength (default 100)
%   lineAngle (angle degrees of bg lines) 
%   figTilt (angle degrees of square tilt) 
%   imContrast (overall image contrast [0 to 1]
%   isFig (1=figure+, 0=figure-)
% 
% OUTPUTS 
%   fgIm: figure ground image matrix 
%
% Febraury 2021 
% Karen Tian

%% params 
saveFig = 0; % save fig to directory 

% ground 
pixelsPerDegree = 99; 
sizeIm = [1000 1000]; % size of image 
lineWidth = 1; % width of texture lines, check this seems to act weird for non 45 degree lines.. 

% figure 
sizeFig = [600 600]; % square image size 

% grating params 
% spatialFrequency = 0.5; 
% phase = 0;
% contrast = 1;
% tiltDegrees = 30;
% figRad = 260; % figure aperture size (radius) 
apertureEdgeType = 'square'; %  determines aperture edge, square=hard edge 
% figGrating = 1; % logical for "grating" figure 

%% checks 
% default inputs 
if nargin==0
    lineLength = 60; % length of texture lines
elseif nargin<1
    lineAngle = 45; % angle (degrees) of texture lines, scalar 
elseif nargin<2
    figTilt = 10; % tilt (degrees) for figure 
elseif nargin<3
    imContrast = .15; % proportion of image covered by line 
elseif nargin<4
    isFig = 1; % 1=figure+, 0=figure-
end
if max(sizeFig) > min(sizeIm) 
    error('figure size must be less than image size')
end

%% setup 
im = ones(sizeIm); % blank image
sizeDegrees = max(size(im))/pixelsPerDegree; % side length in degrees of visual angle
areaIm = sizeIm(1)*sizeIm(2); 
blackPerLine = lineLength*lineWidth; 
totalBlack = areaIm*imContrast; 
nLines = round(totalBlack/blackPerLine); 
% nLines = round(((sizeIm(1)*sizeIm(2))/(lineLength*lineWidth)) * imContrast); % number of lines to draw
if lineAngle == 90 
    bgSlope = 1;
    figSlope = 0; 
elseif lineAngle == 0 
    bgSlope = 0; 
    figSlope = 1; 
else
    bgSlope = tan(deg2rad(lineAngle)); % angle to rise/run 
    figSlope = tan(deg2rad(lineAngle)+pi/2); 
end
figTiltRad = deg2rad(figTilt);

%% draw bg lines 
randX = randi([1-lineLength/2,sizeIm(2)+lineLength/2],1,nLines)'; % randomly generate line middle points 
randY = randi([1-lineLength/2,sizeIm(1)+lineLength/2],1,nLines)'; 

% randX = randperm(sizeIm(2),nLines); 
if bgSlope == 1
    x = cat(2, randX, randX); 
else
    x = cat(2, randX-lineLength/2, randX+lineLength/2); 
end
y = cat(2, randY+bgSlope*lineLength/2, randY-bgSlope*lineLength/2); 

bg = im; 
bg = insertShape(im,'Line',[x(:,1) y(:,1) x(:,2) y(:,2)],'LineWidth',lineWidth,'Color','black','Opacity',1);
bg = rgb2gray(bg); 
bg(bg~=1) = 0; 
% bg(bg>=0.5) = 1; 
% figure
% imshow(bg)

if isFig == 0 
    fgIm = bg; 
else
%% draw fig lines 
figX = randi([1-lineLength/2,sizeIm(2)+lineLength/2],1,nLines)';
figY = randi([1-lineLength/2,sizeIm(1)+lineLength/2],1,nLines)'; 
if figSlope == 1
    x = cat(2, figX, figX); 
else
    x = cat(2, figX-lineLength/2, figX+lineLength/2); 
end
y = cat(2, figY+figSlope*lineLength/2, figY-figSlope*lineLength/2); 

fig = insertShape(im,'Line',[x(:,1) y(:,1) x(:,2) y(:,2)],'LineWidth',lineWidth,'Color','black','Opacity',1);
fig = rgb2gray(fig); 
fig(fig~=1) = 0; 
% fig(fig<0.5) = 0; 
% fig(fig>=0.5) = 1; 
% figure
% imshow(fig)

%% aperture fig 
% if figGrating
%     grating = rd_grating(pixelsPerDegree, sizeDegrees, spatialFrequency, tiltDegrees, phase, contrast);
%     grating(grating>.5) = 1; grating(grating<=.5) = 0; % hard edge
%     grating = grating(1:size(im,1),1:size(im,2));
%     fig(logical(grating)) = 1;
%     bg(~logical(grating)) = 1;
% end
% [figAp, ap] = twcf_aperture(fig, apertureEdgeType, figRad, 0); % cutout figure shape 

%% draw figure aperture 
figCoord = [sizeIm(2)/2+sizeFig(2)/2, sizeIm(1)/2-sizeFig(1)/2,...
    sizeIm(2)/2+sizeFig(2)/2, sizeIm(1)/2+sizeFig(1)/2,...
    sizeIm(2)/2-sizeFig(2)/2, sizeIm(1)/2+sizeFig(1)/2,...
    sizeIm(2)/2-sizeFig(2)/2, sizeIm(1)/2-sizeFig(1)/2]; 
c = cos(figTiltRad); 
s = sin(figTiltRad); 
ox = sizeIm(2)/2; % origin x 
oy = sizeIm(1)/2; % origin y 
% read on matrix transforms... probably more elegant.. 
figCoordTilt = [(figCoord(1)-ox)*c - (figCoord(2)-oy)*s + ox, (figCoord(2)-oy)*c + (figCoord(1)-ox)*s + oy,...
    (figCoord(3)-ox)*c - (figCoord(4)-oy)*s + ox, (figCoord(4)-oy)*c + (figCoord(3)-ox)*s + oy,...
    (figCoord(5)-ox)*c - (figCoord(6)-oy)*s + ox, (figCoord(6)-oy)*c + (figCoord(5)-ox)*s + oy,...
    (figCoord(7)-ox)*c - (figCoord(8)-oy)*s + ox, (figCoord(8)-oy)*c + (figCoord(7)-ox)*s + oy]; 
aperture = insertShape(im,'FilledPolygon',figCoordTilt,'Color','black'); 
aperture = sum(aperture,3); 
aperture(aperture~=3) = 0; 

%% combine fig + ground 
% if figGrating
%     fgIm = imfuse(bg,fig,'blend');
%     fgIm = double(fgIm)/255; 
%     fgIm(~logical(ap)) = 1; 
% else
%     fgIm = bg; 
%     fgIm(logical(ap)) = figAp(logical(ap)); 
% end
fgIm = bg; 
fgIm(~logical(aperture)) = fig(~logical(aperture)); 
end
%% circular aperture on combined fig + ground 
[fgIm, ap] = twcf_aperture(fgIm, apertureEdgeType, min(sizeIm)/2, 0); % cutout figure shape 
fgIm(fgIm~=0)=1; 

%% show final image 
figure
imshow(fgIm);
titleText = sprintf('FG_lineLength%d_angle%d_figAngle%d_contrast%0.1f_fig%d',lineLength,lineAngle,figTilt,imContrast,isFig); 
titleText = {strrep(titleText,'.','')}; 
title(sprintf('line length: %d; line angle: %d, fig angle: %d, contrast: %0.1f',lineLength,lineAngle,figTilt,imContrast),...
    'FontSize', 14)
fH = sort(double(findobj(0,'Type','figure')));
figDir = sprintf('%s/figs/test/contrast%d_lineLength%d',pwd,imContrast*100,lineLength); 
if ~exist(figDir,'dir')
    mkdir(figDir)
end
if saveFig 
    % export_fig(f,'-dpng','-painters',sprintf('%s/figs/test/%s.png',pwd,titleText))
    rd_saveAllFigs(fH, titleText, [], figDir, [])
end
