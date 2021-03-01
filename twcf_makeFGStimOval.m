function [fgIm,randSeed] = twcf_makeFGStimOval(lineLength,theta,isFig,sizeOval)

% function [fgIm,randSeed] = twcf_makeFGStimOval(lineLength,theta,isFig)
% 
% Generates figure ground stimuli (Lamme) for TWCF expt 1. 
% 
% INPUTS
%   lineLength: default 100
%   theta: rotation of ellipse 
%   isFig: 1 = figure+, 0 = figure-
%   sizeOval: [width radius, height radius] in pixels, default [300/2 600/2]
% 
% OUTPUTS 
%   fgIm: figure ground image matrix 
%   randSeed: random seed texture lines 
%
% Febraury 2021 
% Karen Tian

%% params 
saveFig = 0; % save fig to directory 

% ground 
pixelsPerDegree = 99; 
sizeIm = [1000 1000]; % size of image 
lineWidth = 1; % width of texture lines
imContrast = 0.3; % proportion of screen in black 

% figure 
apertureEdgeType = 'square'; %  determines aperture edge, square=hard edge 

%% checks 
% default inputs 
if nargin==0
    lineLength = 60; % length of texture lines
elseif nargin<1
    theta = 45; % angle (degrees) of texture lines
elseif nargin<2
    isFig = 1; % 1=figure+, 0=figure-
elseif nargin<3
    sizeOval = [300/2 600/2]; % oval [width radius, height radius] 
end
if max(sizeOval) > min(sizeIm) 
    error('figure size must be less than image size')
end
if sizeOval(1)==sizeOval(2)
    error('figure must be oval, not circular')
end

%% setup 
im = ones(sizeIm); % blank image
sizeDegrees = max(size(im))/pixelsPerDegree; % side length in degrees of visual angle
areaIm = sizeIm(1)*sizeIm(2); 
blackPerLine = lineLength*lineWidth; 
totalBlack = areaIm*imContrast; 
nLines = round(totalBlack/blackPerLine); 
bgSlope = 1;
figSlope = 0;

%% draw bg lines canonical 90deg 

randX = randi([1-lineLength/2,sizeIm(2)+lineLength/2],1,nLines)'; % randomly generate line middle points
randY = randi([1-lineLength/2,sizeIm(1)+lineLength/2],1,nLines)';
randSeed = rng; % EDIT seed 

% randX = randperm(sizeIm(2),nLines);
x = cat(2, randX, randX);
y = cat(2, randY+bgSlope*lineLength/2, randY-bgSlope*lineLength/2);

bg = im;
bg = insertShape(im,'Line',[x(:,1) y(:,1) x(:,2) y(:,2)],'LineWidth',lineWidth,'Color','black','Opacity',1);
bg = rgb2gray(bg);
bg(bg~=1) = 0;

%% FIGURE 
if isFig == 0
    fgIm = bg;
else
    %% draw fig lines, orthogonal to bg 
    fig = bg; 
    fig = imrotate(bg,90,'nearest'); 
    
    %% draw oval 
    %% add jitter! to oval origin 
    [imColumns, imRows] = meshgrid(1:size(fig,1), 1:size(fig,2)); % meshgrid 
    oval = (imRows - round(size(fig,2)/2)).^2 ./ sizeOval(2)^2 ...
        + (imColumns - round(size(fig,1)/2)).^2 ./ sizeOval(1)^2 <= 1; % logical oval 
    oval = imrotate(oval,theta,'crop'); 
    
    %% combine figure oval and bg 
    fgIm = bg; 
    fgIm(oval) = fig(oval);    
end

%% circular aperture on combined fig + ground 
[fgIm, ap] = twcf_aperture(fgIm, apertureEdgeType, min(sizeIm)/2, 0); % cutout figure shape 
% [fgIm, ap] = twcf_aperture(fgIm, 'cosine', min(sizeIm)/2, 50); %
% fgIm(fgIm~=0)=1; 

%% show final image 
figure
imshow(fgIm);
titleText = sprintf('FG_lineLength%d_angle%d_contrast%0.1f_fig%d',lineLength,theta,imContrast,isFig); 
titleText = {strrep(titleText,'.','')}; 
title(sprintf('line length: %d; angle: %d, contrast: %0.1f',lineLength,theta,imContrast),...
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
