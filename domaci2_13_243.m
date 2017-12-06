%Digital Image Processing - homework 2
%This file contais solutions to 4 homework problems

%Define folder in which images are contained
dir = 'ulazne slike\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Problem 1 - Increase quality of an old printed image. Find a compromise
%between removing dots that are consequence of printing and too much 
%blurring. 
%-------------------------------------------------------------------------%
%Solution - A combination of selective non-pass and low pass filtering is
%used. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Read image
f = im2double(imread(strcat(dir,'girl_print.jpg')));
[M, N] = size(f);

%Do low pass filtering. No need to pad with zeros - doesn't make any 
%difference since it's periodic. 
%Filter type and size are empirically found
F = fft2(f);
H = lpfilter('gaussian', M, N, 75); 
G = F.*H;

%Use cnotch to do selective filtering
%Function ginput() is used to find the coordinates
%Filter type and size are empirically found
C = [100 133; 180 332];
H = cnotch('btw', 'reject', M, N, C, 20);
G = G.*H;

C = [138 233; 231 104];
H = cnotch('gaussian', 'reject', M, N, C, 15);
G = H.*G;

g = ifft2(G);
figure, imshow(g);
title('Filtered image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Problem 2 - create dos_dowscale(I, s) function which decimates image I by
%a factor s using the closet neighbour algorithm. Test it for s = 2, 4, 7
%and compare the results with Matlab's imresize using nearest and bicubic 
%methods, with and without antialiasing. 
%-------------------------------------------------------------------------%
%Solution - the definition of the function can be found in dos_downscale.m.
%In order not to clutter this program's output the results of Matlab's
%functions aren't shown. More detailed results are discussed in the report.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f = im2double(imread(strcat(dir,'roof.jpg')));

s = [2 4 7];
%set of images resized using dos_downscale
G_dos_downscale = cell(size(s));
% %set of images resized using bicubic with prefiltering
% G_bicubic_f = cell(size(s));
% %set of images resized using bicubic without prefiltering
% G_bicubic= cell(size(s));
% %set of images resized using nearest with prefiltering
% G_nearest_f = cell(size(s));
% %set of images resized using nearest without prefiltering
% G_nearest = cell(size(s));

for i = 1:size(s,2)
    G_dos_downscale{i} = dos_downscale(f, s(i));
%     G_bicubic_f{i} = imresize(f, 1/s(i), 'bicubic', 'antialiasing', true);
%     G_bicubic{i} = imresize(f, 1/s(i), 'bicubic', 'antialiasing', false);
%     G_nearest_f{i} = imresize(f, 1/s(i), 'nearest', 'antialiasing', true);
%     G_nearest{i} = imresize(f, 1/s(i), 'nearest', 'antialiasing', false);
end

%Show results of dos_downscale
for i = 1:size(s,2)
    figure, imshow(G_dos_downscale{i});
    title(strcat('dos downscale s = ', num2str(s(i))));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Problem 3 - given image has motion degradation. Motion kernel is given.
%Image needs to be restored. 
%-------------------------------------------------------------------------%
%Solution - Wiener filter is used to restore image. Simple median filter is
%used to remove noise. In the end, black patches are removed. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%read images
f = im2double(imread(strcat(dir,'etf_blur.tif')));
k = im2double(imread(strcat(dir,'kernel.tif')));
[M, N] = size(f);

%Apply Wiener filter
G = fft2(f);
H = fft2(k, M, N);

W = conj(H)./(abs(H).^2 + 1e-3);
G = G.*W;

g = ifft2(G);

%adjust and filter image with median filter
g = imadjust(g, stretchlim(g), [0 1]); 
g = medfilt2(g, [2,2], 'symmetric');

%remove black parts
%if this and second row are almost completely black we are at the
%begining of a black patch
for i =1:M
    if (mean(g(i,:)) < 0.1) && (mean(g(i+1,:)) < 0.1) 
        break;
    end
end
%if this and second column are almost completely black we are at the
%begining of a black patch
for j =1:N
    if (mean(g(:,j)) < 0.1) && (mean(g(:,j+1)) < 0.1) 
        break;
    end
end

g = g(1:i, 1:j);
figure, imshow(g);
title('Restored image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Problem 4 - Implement non local means algorithm in function
%dos_non_local_means and test it. 
%-------------------------------------------------------------------------%
%Solution - function is given in dos_non_local_means.m. The value of
%PSNR and the amount of time needed to calculate the function are
%calculated here. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

I = im2double(imread(strcat(dir, 'lena_noise.tif')));
original = im2double(imread(strcat(dir, 'lena.tif')));

h = 0.01; var = 0.0075;

K = 5; S = 25;
g = dos_non_local_means(I, K, S, var, h);
PSNR = psnr(g, original);
imshow(g);
title (strcat('K = 5, S = 25, PSNR = ', num2str(PSNR)));


