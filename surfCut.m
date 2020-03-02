function [imgOut,param] = surfCut(imgPath, varargin)
%[imgOut,param] = surfCut(imgPath)
%    imgPath, path to image
%    imgOut, output max projection over Z
%    param, output parameters [gs, th, s1, s2]
%[imgOut,param] = surfCut(imgPath, gs, th, s1, s2)
%    imgPath, path to image
%    gs, sigma for gauss filter
%    th, threshold value
%    s1, size of first kernel, used to peel of top surface (regular size is 2*s1)
%    s2, size of second kernel, size of mask used for projection (regular size is 2*s2)
%    imgOut, output max projection over Z
%    param, output parameters [gs, th, s1, s2]
%[imgOut,param] = surfCut(imgPath, param)
%    imgPath, path to image
%    param, input parameters [gs, th, s1, s2], can be used from prerun with
%    just image as function
%    imgOut, output max projection over Z
%    param, output parameters [gs, th, s1, s2]
ask=0;
    switch nargin
        case 1
%             disp('Just image')
            ask=1;
        case 2
            if length(varargin{1,1}) == 4
                th=(varargin{1,1}(2));
                gs=(varargin{1,1}(1));
                s1=(varargin{1,1}(3));
                s2=(varargin{1,1}(4));
            else
                disp('Wrong input!');
            end
        case 5
            th=cell2mat(varargin(2));
            gs=cell2mat(varargin(1));
            s1=cell2mat(varargin(3));
            s2=cell2mat(varargin(4));
%             disp([num2str(gs) ' ' num2str(th)]);
        otherwise
            disp('Wrong input!');
    end
    
    in=imfinfo(imgPath);
    Im=zeros(in(1).Height,in(1).Width,length(in));

    for i=1:length(in)
        Im(:,:,i)=imread(imgPath,i);
    end
    
    %% apply gauss filter
    if ask == 0
        ImG = imgaussfilt(Im,gs);
    else
        gs=input('Sigma of Gauss filter: ');
        ImG = imgaussfilt(Im,gs);
    end

%     figure
%     for i=1:size(ImG,3)
%         imagesc(ImG(:,:,i));
%         pause(0.1);
%     end
    %% threshold image

    
    if ask == 0
        BW = imbinarize(ImG,th);
    else
        th=input('Threshold: ');
        BW = imbinarize(ImG,th);
    end

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
     if ask == 0
        [xx,yy,zz] = ndgrid(-s1:s1);
    else
        s1=input('Size to peel of: ');
        [xx,yy,zz] = ndgrid(-s1:s1);
    end
    
    SE = sqrt(xx.^2 + yy.^2 + zz.^2) <= 5.0;
     
    if ask == 0
        [xx,yy,zz] = ndgrid(-s2:s2);
    else
        s2=input('Thickness of mask: ');
        [xx,yy,zz] = ndgrid(-s2:s2);
    end
    
    SE2 = sqrt(xx.^2 + yy.^2 + zz.^2) <= 5.0;

    % volshow(SE);

    mask1 = imerode(mask,SE); % peel of outer layer
    mask2 = imerode(mask1,SE2); % erode more to get thicknes for final mask
    mask_final = mask1-mask2; % by substracting create a mask for layer we will use for projection

%     figure
%     for i=1:size(mask,3)
%         imagesc(mask_final(:,:,i));
%         pause(0.1);
%     end

    toZproject=Im.*mask_final; % data for Z max projection
    %% experimetal part
    % for x=1:size(mask,1)
    %     for y=1:size(mask,2)
    %         toZproject(x,y,:)=smooth(toZproject(x,y,:),'sgolay',2);
    %     end
    % end

    % for i=1:length(mask)
    %     toZproject(:,:,i)=medfilt2(toZproject(:,:,i),[7 7]);
    % end
%     toZproject2=toZproject;
%     sdm=zeros(size(mask));
%     for i=1:size(mask_final,3)
%         sdm(:,:,i)=stdfilt(toZproject(:,:,i));
%         toZproject2(sdm(:,:,i)<40)=0;
%     end
% 
%     MOP=sum(mask_final,3)./size(mask_final,3);
%     figure
%     imagesc(MOP);
%     colorbar
%     colormap jet

    %% Outputs
    imgOut=max(toZproject,[],3);
    param=[gs th s1 s2];

%     figure
%     imagesc(imgOut);
%     colorbar
%     colormap gray
%     title('surfcut')
end

