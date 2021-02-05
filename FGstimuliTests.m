% TWCF FG stimuli test 
% Febraury 4 2021 
% Karen Tian

saveFig = 1; 

%% params 
sizeIm = [1000 1000]; 
lineLength = 50; 
lineWidth = 2; 
slopeAngle = 0; % or random 
contrast = .1; % proportion black
density = ((sizeIm(1)*sizeIm(2))/(lineLength*lineWidth)) * contrast; % how many lines 
figRad = 300; % figure aperture size
apertureType = 'square'; % 'grating'

% if grating figure, params: 
pixelsPerDegree = 99; 
spatialFrequency = 0.5; 
tiltDegrees = 45;
phase = 0;
contrast = 1;

%% draw bg lines 
slope = tan(deg2rad(slopeAngle));
randX = randi([1-lineLength,sizeIm(1)+lineLength],1,density); 
randY = randi([1-lineLength,sizeIm(2)+lineLength],1,density); 

slopeBg = repmat(slope,density,1);  
% slopeBg = -1 + (1+1)*rand([density,1]);
figure
hold on 
for i = 1:density
    plot([randX(i),randX(i)+lineLength],[randY(i),(slopeBg(i)*lineLength)+randY(i)],'LineWidth',lineWidth,'Color','k')
end
xlim([1 sizeIm(1)])
ylim([1 sizeIm(2)])

F = getframe(gcf);
bg = frame2im(F);
bg(bg~=0) = 1; 
bg = double(bg); 
bg = squeeze(bg(:,:,1)); 

sizeDegrees = max(size(bg))/pixelsPerDegree; % side length in degrees of visual angle

%% draw fig lines 
slopeFig = slope-pi/2; 
figX = randi([1-lineLength,sizeIm(1)+lineLength],1,density); 
figY = randi([1-lineLength,sizeIm(2)+lineLength],1,density); 
figure
hold on 
for i = 1:density
    plot([figX(i),figX(i)+lineLength],[figY(i),(slopeFig*lineLength)+figY(i)],'LineWidth',lineWidth,'Color','k')
end
xlim([1 sizeIm(1)])
ylim([1 sizeIm(2)])

F = getframe(gcf);
fig = frame2im(F);
fig(fig~=0) = 1;
fig = double(fig); 
fig = squeeze(fig(:,:,1)); 
% aperture
[figAp, ap] = rd_aperture(fig, apertureType, figRad, 0);

% alternatively, grating figure 
grating = rd_grating(pixelsPerDegree, sizeDegrees, ...
    spatialFrequency, tiltDegrees, phase, contrast);
grating(grating>.5) = 1; 
grating(grating<=.5) = 0; % hard edge 
grating = grating(1:size(bg,1),1:size(bg,2)); % temp dimension change, why sizing with frame2im off 
fig(logical(grating)) = 1; 
bg(~logical(grating)) = 1; 
% combine
FGIm2 = imfuse(bg,fig,'blend');
FGIm2 = double(FGIm2); 
% FGIm2(FGIm2==255) = 1;
% FGIm2(FGIm2==128) = 0;

%% combined image 
% FGIm = bg; 
FGIm = ones(size(FGIm2)); 
FGIm(logical(ap)) = FGIm2(logical(ap)); 

%% show final image 
figure
imshow(FGIm)
titleText = sprintf('FG_lineLength%d_density%d_gratingAngle%d',lineLength,density,tiltDegrees); 
title(sprintf('line length: %d; density: %d; line angle: %d, grating angle: %d',lineLength,density,slopeAngle,tiltDegrees))
if saveFig 
    print(gcf,'-dpng','-painters',sprintf('%s.png',titleText))
end
