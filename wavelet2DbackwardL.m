function salida = wavelet2DbackwardL(x, L)
%wavelet2Dforward Realiza transformada Wavelet de Haar en 2D 
% hacia delante de la señal x
% x = double(imread('barbara.png'))/255;
% salida = wavelet2Dbackward(wavelet2Dforward(x));
% imshow(salida);
if L==1
    X = x(1:end/2, 1:end/2);
else
    X = wavelet2DforwardL(x(1:end/2, 1:end/2), L-1);
end
Y = x(1:end/2, end/2+1:end);
W = x(end/2+1:end, 1:end/2);
Z = x(end/2+1:end, end/2+1:end);

A = (X+Y+W+Z);
B = (X-Y+W-Z);
C = (X+Y-W-Z);
D = (X-Y-W+Z);

salida = x*0;
salida(1:2:end-1, 1:2:end-1) = A;
salida(1:2:end-1, 2:2:end) = B;
salida(2:2:end, 1:2:end-1) = C;
salida(2:2:end, 2:2:end) = D;
end
