function puntos = myHarris(I, umbral, tamVentana, sigmaVentana)
I = rgb2gray(im2double(I));

% I = im2double(imread('moon.tif'));   % en el informe sustituir por la que prefieran

%%  1) Calcular los gradientes horizontal y vertical
Gx = [1 2 1]'*[-1 0 1];
Gy = [-1 0 1]'*[1 2 1];
Ix = imfilter(I, Gx);
Iy = imfilter(I, Gy);
% imshowpair(Ix, Iy, 'montage') %util para pintar dos imagenes una al lado de la otra

%% 2) Calcular los productos cruzados
Ixx = Ix .* Ix;
Ixy = Ix .* Iy;
Iyy = Iy .* Iy;

% imshow([Ixx, Ixy, Iyy], []);


%% 3) Ponderar con ventana
% tamVentana = 10;        % pasar luego a parámetro de función
% sigmaVentana = 15/2/3;  % pasar luego a parámetro de función
G = fspecial('gaussian', tamVentana, sigmaVentana);   % ventana gaussiana
Sxx = imfilter(Ixx, G);
Sxy = imfilter(Ixy, G);
Syy = imfilter(Iyy, G);
% imshow([Sxx, Sxy, Syy], [])


%% 4) Calcular la R
% 
R = Sxx.*Syy-Sxy.^2-0.05*(Sxx+Syy).^2;

% --- det/trace
% determinante = Sxx.*Syy - Sxy.^2;
% traza = Sxx + Syy ;
% 
% R1 = determinante./(traza+eps);

% --- min(lambda1, lambda2)


% TO DO opcional probar las otras dos técnicas: det/traza y min(lambda1,
% lambda2), en el último caso debe formar la matriz Mxy para cada posición x, y 
% para luego poder aplicar [~, lambdas, ~] = svd(Mxy); 
% imshow(R, []); pause;  % ver como imagen y como malla
% mesh(fliplr(R1));

%% 5 y 6) Umbralizar y quedarnos con máximos regionales 
% umbral = .08;  % probar distintos valores
% umbral = u;
R_umbralizado = R.*(R > umbral);
% R1_umbralizado = R.*(R1 > umbral);
% imshowpair(I, imregionalmax(R_umbralizado), 'blend')
maximos =  imregionalmax(R_umbralizado);
% maximos1 =  imregionalmax(R1_umbralizado);
[y, x] = find(maximos);
% [y1, x1] = find(maximos1);
% clf; imshow(I); hold on;
% plot(x1,y1,'+g');   % truco para ver mejor los puntos

puntos = [y, x];


%% PARA COMPARAR
% figure;
% points = detectHarrisFeatures(I);
% imshow(I); hold on;
% plot(points.selectStrongest(10))
end
