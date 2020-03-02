clear all, close all, clc
%% load image to Im

[file,path] = uigetfile('*.tif');

in=imfinfo([path '\' file]);
Im=zeros(in(1).Height,in(1).Width,length(in));

for i=1:length(in)
    Im(:,:,i)=imread([path '\' file],i);
end

%% apply gauss filter

ImG = imgaussfilt(Im,3);

figure
for i=1:size(ImG,3)
    imagesc(ImG(:,:,i));
    pause(0.1);
end

%% threshold image

BW = imbinarize(ImG,25);

% figure
% for i=1:size(ImG,3)
%     imagesc(BW(:,:,i));
%     pause(0.1);
% end

%% make mask based on sum of previous layers
mask=logical(zeros(size(BW)));
for i=1:size(ImG,3)
    mask(:,:,i)=logical(sum(BW(:,:,1:i),3));
end

% figure
% for i=1:size(mask,3)
%     imagesc(mask(:,:,i));
%     pause(0.1);
% end

%% final mask through 3D erosion

[xx,yy,zz] = ndgrid(-7:7);
SE = sqrt(xx.^2 + yy.^2 + zz.^2) <= 5.0;

[xx,yy,zz] = ndgrid(-3:3);
SE2 = sqrt(xx.^2 + yy.^2 + zz.^2) <= 5.0;

% volshow(SE);

mask1 = imerode(mask,SE); % peel of outer layer
mask2 = imerode(mask1,SE2); % erode more to get thicknes for final mask
mask_final = mask1-mask2; % by substracting create a mask for layer we will use for projection

figure
for i=1:size(mask,3)
    imagesc(mask_final(:,:,i));
    pause(0.1);
end

toZproject=Im.*mask_final; % data for Z max projection
%%
% for x=1:size(mask,1)
%     for y=1:size(mask,2)
%         toZproject(x,y,:)=smooth(toZproject(x,y,:),'sgolay',2);
%     end
% end

% for i=1:length(mask)
%     toZproject(:,:,i)=medfilt2(toZproject(:,:,i),[7 7]);
% end
toZproject2=toZproject;
sdm=zeros(size(mask));
for i=1:size(mask_final,3)
    sdm(:,:,i)=stdfilt(toZproject(:,:,i));
    toZproject2(sdm(:,:,i)<40)=0;
end

MOP=sum(mask_final,3)./size(mask_final,3);
figure
imagesc(MOP);
colorbar
colormap jet

%% Outputs
MIP=max(toZproject,[],3);

figure
imagesc(MIP);
colorbar
colormap gray
title('surfcut')

MIP3=mean(toZproject2,3);

figure
imagesc(MIP3);
colorbar
colormap gray
title('surfcut sd')

MIP2=max(Im,[],3);

figure
imagesc(MIP2);
colorbar
colormap gray
title('max proj')