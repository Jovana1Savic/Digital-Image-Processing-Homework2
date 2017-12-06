function g = dos_non_local_means(I, K, S, var, h)
%dos_non_local_means implements non local averaging od image
%   Creates new image G by averaging image I, where K is the size of a
%   block for which structural similarity is calculated, S is the size of 
%   area around each pixel p in which pixels with which p is compared are
%   found, var is estimated picture variance (should be calculated from
%   most uniform parts of the picture) and h is the power of denoising. 

half = floor(S/2);
[M,N] = size(I);

%Symmetrically increase image by K/2+S/2 on each side, so that every pixel
%in the original image has the same number of neighbours 
G = padarray(I, [half+floor(K/2) half+floor(K/2)], 'symmetric');
g = zeros(M, N);

%go through each pixel in original image
for yp = 1+half+floor(K/2):M+half+floor(K/2)
    for xp = 1+half+floor(K/2):N+half+floor(K/2)
        sum = 0; C = 0;
        %go through each pixel that's current's neighbour
        for xq = xp-half:xp+half
            for yq = yp-half:yp+half
                w = weight(xp, yp, xq, yq, G, K, var, h);
                sum = sum + G(yq, xq)*w;
                C = C + w;
            end
        end
        %assign calculated value to corresponding pixel in new image
        g(yp-half-floor(K/2), xp-half-floor(K/2)) = sum/C;
    end
end

%Helper functions

%Distance between pixels
%-------------------------------------------------------------------------%
function D = distance(xp, yp, xq, yq, B, I)

N = B*B;
half = floor(B/2);
sum = 0;
%add square difference between corresponding pixels in each block
for i=-half:1:half
    for j=-half:1:half
        sum = sum + (I(yp+i, xp+j)-I(yq+i, xq+j))^2;
    end
end

%divide by number of pixels in block
D = sum/N;
%-------------------------------------------------------------------------%

%Weight function
%-------------------------------------------------------------------------%
function W = weight(xp, yp, xq, yq, I, B, var, h)

%see if variance between pixels p and q is within twice given variance
%if yes, weight function is 1, if not it's weight function exponentialy
%goes down as variance increases 
W = exp(-max(distance(xp, yp, xq, yq, B, I)-2*var, 0)/(h^2));
%-------------------------------------------------------------------------%

