%% CARGAR LA IMAGEN Y SEPARAR LOS CANALES
I = imread('00153u.jpg'); % TO DO: En el informe sustituyan por otra imagen descargada de
I = imread('sunset.tif');
% https://www.loc.gov/collections/prokudin-gorskii/
% descarguen la version: "digital file from glass neg."
[Nf, Nc] = size(I);

imshow(I);

Nf = floor(Nf/3);
if mod(Nf,2)~= 0
    Nf = Nf-1;
end
if mod(Nc,2)~= 0
    Nc = Nc-1;
end

% TO DO.
B = I(1:Nf, 1:Nc);  % primer tercio de I, de tamaño Nf ilas x Nc olumnas
G = I(Nf+1:2*Nf, 1:Nc); % segundo tercio de I, idem
R = I(2*Nf+1:3*Nf, 1:Nc);% tercer tercio de I, idem
  
RGB = uint8(zeros(Nf, Nc, 3)); % reunidas como imagen de color, aun no alineadas
RGB(:, :, 1) = R;
RGB(:, :, 2) = G;
RGB(:, :, 3) = B;

figure;
imshow([reshape([R,R,R], Nf, Nc, 3), ... % fijense como pintar a la vez imagenes en grises y en color
        reshape([G,G,G], Nf, Nc, 3); ... % cada canal se repite tres veces para que se le pueda considerar
        reshape([B,B,B], Nf, Nc, 3), ... % imagen de grises, se adosan en horizontal Nf x (Nc·3) y se redimensionan como Nf x Nc x 3
        RGB]); % ésta es la única porción en color, porque las reunimos antes, lineas 20:23
title('entradas desalineadas');

figure;  % TO DO: ¿como pintar cada canal de su color?
z=zeros(Nf,Nc,"uint8");
imshow([reshape([R, z , z], Nf, Nc, 3), ... % pista: el resto de canales anulados
        reshape([z ,G, z], Nf, Nc, 3); ...
        reshape([z , z ,B], Nf, Nc, 3), ...
        RGB]);
title('entradas desalineadas');



%% Encajar los canales G y R mediante correlaciones en el dominio de Fourier
% con sizeF = 50; y  sizeG = 450; funciona
sizeF = 500;
sizeG = 900;
g = double(R(Nf/2+[1:sizeG]-sizeG/2, Nc/2+[1:sizeG]-sizeG/2));
g = g-mean(g(:)); g = g/norm(g(:));
f = double(G(Nf/2+[1:sizeF]-sizeF/2, Nc/2+[1:sizeF]-sizeF/2));
f = f-mean(f(:)); f = f/norm(f(:));

figure; imshowpair(g, f, 'montage')
map = corrFFT(g, f); % llamar corrFFT, antes mirar dentro de la función hay un TO DO
figure; surf(fliplr(map)), shading flat; %vista en 3D, noten el fliplr
az=-160; el=80; view(az, el);  % si queremos usar siempre el mismo punto de vista
[dispY,dispX] = find(map==max(map(:)),1); % hallamos el máximo
f0 = f;
f0(size(g,1), size(g,2)) = 0; %creamos una imagen de f, orlada a ceros para que sea del tamaño de la g
figure; imshowpair(g, circshift(f0, [dispY-1, dispX-1]), 'blend')
% dejamos el canal rojo alineado con el verde
RGB(:, :, 1) = circshift(R, -[(sizeF-sizeG)/2+dispY-1, (sizeF-sizeG)/2+dispX-1]);

%% Encajar los canales G y B mediante correlaciones en el dominio de Fourier
% TO DO: con sizeF = 50; y  sizeG = 450 ¿funciona? NO; con ¿100 y 900? SI en las
% siguientes comparativas, considere este algoritmo como rápido.
sizeF = 400; sizeG = 900;

g = double(B(Nf/2+[1:sizeG]-sizeG/2, Nc/2+[1:sizeG]-sizeG/2));
g = g-mean(g(:)); g = g/norm(g(:));
f = double(G(Nf/2+[1:sizeF]-sizeF/2, Nc/2+[1:sizeF]-sizeF/2));
f = f-mean(f(:)); f = f/norm(f(:));

map = corrFFT(g, f);
[dispY,dispX] = find(map==max(map(:)),1);
figure; imshowpair(g, f, 'montage');
figure; surf(fliplr(map)), shading flat, title('correlacion-FFT');
f0 = f; f0(size(g,1), size(g,2)) = 0;
figure; imshowpair(g, circshift(f0, [dispY-1, dispX-1]), 'blend')



%% Encajar los canales G y B pero ahora con SSD 
% TO DO: responder ¿funciona? Si ¿es rápido? NO.
tic();
sizeF = 400; sizeG = 900;

g = double(B(Nf/2+[1:sizeG]-sizeG/2, Nc/2+[1:sizeG]-sizeG/2));
f = double(G(Nf/2+[1:sizeF]-sizeF/2, Nc/2+[1:sizeF]-sizeF/2));
f = f-mean(f(:)); f = f/norm(f(:));
mapSSD = zeros(sizeG-sizeF);
for m=1:(sizeG-sizeF)
    for n=1:(sizeG-sizeF)
        g_mn = g(m+[0:sizeF-1],n+[0:sizeF-1]); % TO DO, acceder correctamente
        g_mn = g_mn-mean(g_mn(:));
        g_mn = g_mn/norm(g_mn(:));
        mapSSD(m,n) = sum(sum((f-g_mn).^2));
    end
end
toc();
[dispY,dispX] = find(mapSSD==min(mapSSD(:)),1);
figure; surf(fliplr(-mapSSD)), shading flat, title('SSD');
f0 = f; f0(size(g,1), size(g,2)) = 0;
figure; imshowpair(g, circshift(f0, [dispY-1, dispX-1]), 'blend')



%% Encajar los canales G y B pero ahora con NCC
% ¿funciona? Si ¿es rápido? mas rapido que ssd
tic();
sizeF = 400; sizeG = 900;

g = double(B(Nf/2+[1:sizeG]-sizeG/2, Nc/2+[1:sizeG]-sizeG/2));
f = double(G(Nf/2+[1:sizeF]-sizeF/2, Nc/2+[1:sizeF]-sizeF/2));
f = f-mean(f(:));
mapNCC = zeros(sizeG-sizeF);
for m=1:(sizeG-sizeF)
    for n=1:(sizeG-sizeF)
        g_mn = g(m+[0:sizeF-1],n+[0:sizeF-1]);
        mapNCC(m,n) = sum(sum(f.*g_mn)) ... % producto interno entre f y g_mn  ...
                      / sqrt(sum(sum( (g_mn-mean(g_mn(:))).^2  )));  % RMS: calculo lento lo arreglaremos luego
    end
end
toc();
[dispY,dispX] = find(mapNCC==max(mapNCC(:)),1);
figure; surf(fliplr(mapNCC)), shading flat, title('NCC');
f0 = f; f0(size(g,1), size(g,2)) = 0;
figure; imshowpair(g, circshift(f0, [dispY-1, dispX-1]), 'blend')


%% Encajar los canales B y G pero ahora con fast NCC
% TO DO: ¿funciona? ¿es rápido?
sizeF = 400; sizeG = 900;

g = double(B(Nf/2+[1:sizeG]-sizeG/2, Nc/2+[1:sizeG]-sizeG/2));
f = double(G(Nf/2+[1:sizeF]-sizeF/2, Nc/2+[1:sizeF]-sizeF/2));
f = f-mean(f(:)); 

mapCorr = corrFFT(g, f);
% TO DO: Calcular Summed Area Table de g y g al cuadrado. Visualizarlas
% for m for n (sqrt(area_g_squared-area_g*area_g/N))
SATg = cumsum(cumsum(g, 1), 2);
SATg_squared = cumsum(cumsum(g.^2, 1), 2);
N=sizeF^2;
for m = 1:sizeG-sizeF
    for n=1:sizeG-sizeF
        [startY startX endY endX] = deal(m,n,min(m+sizeF-1,sizeG-1),min(n+sizeF-1,sizeG-1));
        area_g = SATg(endY+1,endX+1) ...
            -SATg(endY+1,startX)-SATg(startY,endX+1)...
            +SATg(startY,startX);
        area_g_squared = SATg_squared(endY+1,endX+1) ...
            -SATg_squared(endY+1,startX)-SATg_squared(startY,endX+1)...
            +SATg_squared(startY,startX);
        aVisualizar(m,n) = sqrt(area_g_squared-area_g*area_g/N);
    end
end
imshowpair (g(1:sizeG-sizeF, 1:sizeG-sizeF), aVisualizar, "blend") % SATg y SATg_squared

mapfNCC = zeros(sizeG-sizeF);
N=sizeF^2;
for m = 1:sizeG-sizeF
    for n=1:sizeG-sizeF
        [startY startX endY endX] = deal(m,n,min(m+sizeF-1,sizeG-1),min(n+sizeF-1,sizeG-1));
        area_g = SATg(endY+1,endX+1) ...
            -SATg(endY+1,startX)-SATg(startY,endX+1)...
            +SATg(startY,startX);
        area_g_squared = SATg_squared(endY+1,endX+1) ...
            -SATg_squared(endY+1,startX)-SATg_squared(startY,endX+1)...
            +SATg_squared(startY,startX);
        mapfNCC(m,n) = mapCorr(m,n)/sqrt(area_g_squared-area_g*area_g/N);
    end
end

[dispY,dispX] = find(mapfNCC==max(mapfNCC(:)),1);
figure; surf(fliplr(mapfNCC)), shading flat, title('fast NCC');
f0 = f; f0(size(g,1), size(g,2)) = 0;
figure; imshowpair(g, circshift(f0, [dispY, dispX]), 'blend')

RGB(:, :, 3) = circshift(B, -[(sizeF-sizeG)/2+dispY-1, (sizeF-sizeG)/2+dispX-1]);

imshow(RGB)