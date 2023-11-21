%% Dominios transformados: Wavelet 2D
% revisemos los algoritmos hacia delante y hacia atrás en 2D
I = double(imread('barbara.png'))/255;
wI = wavelet2Dforward(I);
imshow(wI);
imshow(wavelet2Dbackward(wI));

% TO DO: modificar los algoritmos para mediante llamadas recursivas para
% anidar L niveles de transformación.
% Debería probar las funciones resultantes con el siguiente código:
% wI = wavelet2Dforward(I, 3);
% imshow(wI); % debería verse como la transparencia 52 de la tanda 6a de transparencias
% imshow(wavelet2Dbackward(wI, 3)); % Prueba de que funciona

%% TO DO opcional: cuando disponga de wavelet por niveles... 
% ... ilustre qué sucede si en una descomposición en varios niveles 
% elimina las componentes de alta frecuencia de los niveles intermedios y final,
% pero respeta las altas frecuencias del nivel más externo y las bajas frecuencias 
% del nivel más interno y reconstruye solo con estos componentes 





%% Dominios transformados: Fourier 2D
% Atienda a la explicación de los siguientes fragmentos de código 
% que se dará en el laboratorio

% Uso de FFT bidimensional: fft2, abs, log y fftshift
fI = fft2(I);
imagesc(abs(fI));
imagesc(log(abs(fI)+eps));
imagesc(fftshift(log(abs(fI)+eps)));

% Discos y anillos como resta de discos
d=fspecial("disk",25); % disco de radio 25
d=d/max(d(:));
nD = zeros(size(I));
nD(end/2+[-25:25], end/2+[-25:25]) = d;
imshow([D, 1-D]);
D= fftshift(D);
% Transformada inversa, uso de real
imshow(real(ifft2(fI.*D)))
imshow(real(ifft2(fI.*(1-D))))

% TO DO: crear un filtro pasabanda componiendo discos internos de diametros 25 y 75
% Aplicarlo a la imagen de ejemplo.
e = fspecial("disk", 75);
e=e/max(e(:));
E = zeros(size(I));
E(end/2+[-75:75], end/2+[-75:75]) = e;
imshow(E);
nD = zeros(size(I));
nD(end/2+[-25:25], end/2+[-25:25]) = d;
E = E-nD;
imshow([E, 1-E])
E=fftshift(E);
% Transformada inversa, uso de real
imshow(real(ifft2(fI.*E)))
imshow(real(ifft2(fI.*(1-E))))

% TO DO Ilustre qué sucede cuando se resta 
% de la imagen original el resultado del filtrado
img1 = I - real(ifft2(fI.*E));
img2 = I - real(ifft2(fI.*(1-E)));
imshow([I, img1, img2]);


%% Filtros detectores de características: Sobel
% Sobel, sobre un disco, ver modulo y ángulo
D = ifftshift(D); % deshacemos el fftshift anterior

Gx = [1 2 1]'*[-1 0 1];
Gy = [-1 0 1]'*[1 2 1];

Dx = imfilter(D, Gx);      imagesc(Dx);
Dy = imfilter(D, Gy);      imagesc(Dy);

mag = sqrt(Dx.^2+Dy.^2);   imagesc(mag)
dir = atan2(Dy, Dx);       imagesc(dir)


% TO DO: Ahora aplicar Sobel en x e y a la imagen suministrada "valve.png" 
% Adaptar para que trabaje con una imagen en color. No nos interesa el
% ángulo. Mostrar conjuntamente la magnitud del filtrado en los 3 canales RGB
I = im2double(imread('valve.png'));
res = zeros(size(I));

Gx = [1 2 1]'*[-1 0 1];
Gy = [-1 0 1]'*[1 2 1];

for c=1:3
    Dx = imfilter(I(:,:,c), Gx);
    Dy = imfilter(I(:,:,c), Gy);
    
    mag = sqrt(Dx.^2+Dy.^2);
    res(:,:,c) = mag;
end

imshow(res);

%% Filtros separables
% TO DO: probar que podemos obtener el mismo filtrado que produce en 2D Gx 
% si hacemos pasadas 1D en columnas de [1 2 1]'
% y luego en filas de [-1 0 1]

Igray = rgb2gray(I);

paso1x = imfilter(Igray, [1 2 1]');
imshow(paso1y);
paso2x = imfilter(paso1x, [-1 0 1]);

imshow([imfilter(I(:,:,c), Gx), paso2x]);
% TO DO Similarmente para Gy

paso1y = imfilter(Igray, [-1 0 1]');
imshow(paso1y);
paso2y = imfilter(paso1y, [1 2 1]);

imshow([imfilter(I(:,:,c), Gx), paso2y]);

imshow([paso2x, paso2y]);

% TO DO ¿Cuál método creen que será más rápido 1 pasada con Gx 2D o 
% 2 pasadas con filtros 1D? Ayudarse de las funciones tic() toc()

Igray = rgb2gray(I);

tic();
paso1x = imfilter(Igray, [1 2 1]');
paso2x = imfilter(paso1x, [-1 0 1]);
paso1y = imfilter(Igray, [-1 0 1]');
paso2y = imfilter(paso1y, [1 2 1]);
magMan = sqrt(paso2x.^2+paso2y.^2);
toc();

tic();
Dx = imfilter(Igray, Gx);
Dy = imfilter(Igray, Gy);
mag = sqrt(Dx.^2+Dy.^2);
toc();



