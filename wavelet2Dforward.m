function salida = wavelet2Dforward(x)
%wavelet2Dforward Realiza transformada Wavelet de Haar en 2D 
% hacia delante de la señal x
% x = double(imread('barbara.png'));
% salida = wavelet2Dforward(x);

% Separamos la imagen en 4 zonas
A = x(1:2:end-1, 1:2:end-1);
B = x(1:2:end-1, 2:2:end);
C = x(2:2:end, 1:2:end-1);
D = x(2:2:end, 2:2:end);

% Creamos las 4 zonas de filtro media, horizontal, vertical y diagonal
X = 1/4*(A+B+C+D);
Y = 1/4*(A-B+C-D);
W = 1/4*(A+B-C-D);
Z = 1/4*(A-B-C+D);

salida=[X, Y; W, Z];

