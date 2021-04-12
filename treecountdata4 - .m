im=imread('data4.jpg');

im=im(58:500,86:585,:);
imOrig=im;

%% Emphasize trees

im=double(im);
r=im(:,:,1);
g=im(:,:,2);
b=im(:,:,3);

tmp=((g-r)./(r-b));

figure
subplot(121);imagesc(tmp),axis image;colorbar
subplot(122);imagesc(tmp>0),axis image;colorbar

%% Transforms

% Distance transform
im_dist=bwdist(tmp<0);

% Blur
sigma=10;
kernel = fspecial('gaussian',4*sigma+1,sigma);
im_blured=imfilter(im_dist,kernel,'symmetric');

figure
subplot(121);imagesc(im_dist),axis image;colorbar
subplot(122);imagesc(im_blured),axis image;colorbar

% Watershed
L = watershed(max(im_blured(:))-im_blured);
[x,y]=find(L==0);

figure
subplot(121);
imagesc(imOrig),axis image
hold on, plot(y,x,'r.','MarkerSize',3)

%% Local thresholding 

trees=zeros(size(im_dist));
centers= [];
for i=1:max(L(:))    
    ind=find(L==i & im_blured>1);
    mask=L==i;

    [thr,metric] =multithresh(g(ind),1);
    trees(ind)=g(ind)>thr*1;

    trees_individual=trees*0;
    trees_individual(ind)=g(ind)>thr*1;

    s=regionprops(trees_individual,'Centroid');
    centers=[centers; cat(1,[],s.Centroid)];
end

subplot(122);
imagesc(trees),axis image
hold on, plot(y,x,'r.','MarkerSize',3)

subplot(121);
hold on, plot(centers(:,1),centers(:,2),'k^','MarkerFaceColor','r','MarkerSize',8)
fprintf('thr');
