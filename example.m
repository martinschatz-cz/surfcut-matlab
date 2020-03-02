clear all, close all, clc

[file,path] = uigetfile('*.tif');
imgPath=([path '\' file]);

[imgOut,param] = surfCut(imgPath);
figure
imagesc(imgOut);
colorbar
colormap gray
title('surfcut')

[imgOut,param] = surfCut(imgPath, param);
figure
imagesc(imgOut);
colorbar
colormap gray
title('surfcut')