function G = dos_downscale(I, s)
%dos_downscale decimates image I by a factor s
%   G = dos_downscale(I, s) creates new image G which is a result of
%   downsizing image I by a factor s. Image is filtered before
%   downsampling in order to avoid aliasing. If s is an integer it's
%   equivalent to downsampling image by an integer s. If not, it uses the
%   nearest neighbour algorithm. 

[M, N] = size(I);

%Pad with zeros and filter image; g is the filtered image
M1 = floor(M/s); N1 = floor(N/s);
P = 2*M-1; Q = 2*N-1;

cutoff = min(M1, N1); %low pass limit

Fp = fft2(I, P, Q);
H = lpfilter('ideal', P, Q, cutoff);
Fp = Fp.*H;
g = ifft2(Fp);
g = g(1:M, 1:N);

%Downscale image using closest neighbour algorithm 
G = ones(M1,N1);
for i=1:M1
    for j=1:N1
        G(i,j) = g(round(s*i), round(s*j));
    end
end

