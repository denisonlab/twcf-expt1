<h1>twcf-expt1: subjective inflation</h1>

<p>Generating texture-defined figure ground stimuli, in which figure strength is parametrically controlled using texture line length (Nothdurft, 1985; Supèr et al., 2001).</p>
 
```matlab 
    sizeIm = [1000 1000]; 
    lineLength = 100; 
    lineWidth = 2; 
    slopeAngle = 0; % or random 
    density = 1000; % how many lines 
    figRad = 300; % figure aperture size
    apertureType = 'square'; % 'grating'

    % if grating figure, params: 
    pixelsPerDegree = 99; 
    spatialFrequency = 0.5; 
    tiltDegrees = 45;
    phase = 0;
    contrast = 1;
```