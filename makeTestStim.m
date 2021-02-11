
lineLength2 = [10, 30, 50, 100, 200]; 
lineAngle2 = [45]; 
figTilt2 = [5];
imContrast2 = [0.2]; 

for iContrast = 1:numel(imContrast2)
    for iLength = 1:numel(lineLength2)
        for iAngle = 1:numel(lineAngle2)
            for iTilt = 1:numel(figTilt2)
                im = twcf_makeFGStim(lineLength2(iLength),lineAngle2(iAngle),figTilt2(iTilt),imContrast2(iContrast));
                pause(3)
                close all
            end
        end
    end
end