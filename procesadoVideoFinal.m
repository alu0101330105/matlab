%% Leer un archivo de video, modificar, escribir en otro
videoHandleIn = VideoReader('yugi2.mp4');        % de donde leeremos
videoHandleOut = VideoWriter('salidaHolo.avi');   % a donde escribiremos
videoHandleOut.Quality=95;
videoHandleOut.FrameRate = videoHandleIn.FrameRate; % heredamos el frame rate

open(videoHandleOut); % creamos realmente el fichero de salida

[I,map,alpha] = imread("exodiaChiquito.png");
I = im2uint8(I);
alpha = im2uint8(alpha);
I2 = imread("exodia2.png");
alpha2 = imread("exodia2-A.png");

%%
frameBefore = readFrame(videoHandleIn);
[BW, xind, yind] = roipoly(frameBefore); % se pide al usuario que dibuje un poligono alrededor de la zona de interés
R = round(sqrt((max(xind)-min(xind))/2 + (max(yind)-min(yind))/2)); % calculamos automaticamente una gaussiana adecuada
D = 2*R+1; % lo doblamos y nos aseguramos de que sea impar
g = fspecial('gaussian', D, R/3);
BWfiltered = imfilter(double(BW), g);
frameBeforeROI = im2uint8(im2double(frameBefore).*BWfiltered);

roi = images.roi.Polygon;  % creamos el objeto ROI que luego necesitaremos para actualizar máscara y posición de la ROI
roi.Position = [xind, yind];

% [y, x] = find(BW);
% centroid = round(mean([x, y]));
% % imshow(BW); hold on; plot(centroid(1), centroid(2), 'b*'); hold off;
% newFrame = frameBefore;
% BannerA = I.*alpha;
% newFrame(centroid(2) + 50 : centroid(2) + 50 + size(BannerA, 1) - 1, centroid(1) + 50 : centroid(1) + 50 + size(BannerA, 2) - 1,:) = ...
%     newFrame(centroid(2) + 50 : centroid(2) + 50 + size(BannerA, 1) - 1, centroid(1) + 50 : centroid(1) + 50 + size(BannerA, 2) - 1,:).*(1-alpha) + BannerA;
% imshow(newFrame);

%%
pointsBefore = detectHarrisFeatures(rgb2gray(frameBeforeROI)); %% Llamar a Harris limitándolo a que analice la imagen en la ROI, esto es, frameBeforeROI
[featuresBefore,validPointsBefore] = extractFeatures(rgb2gray(frameBeforeROI), pointsBefore);

counter = 0;
%%
while hasFrame(videoHandleIn)  % mientras hayan frames que procesar
   frameNext = readFrame(videoHandleIn); % sacamos el frame actual como imagen
   
   frameNextROI = im2uint8(im2double(frameNext).*BWfiltered);
   pointsNext = detectHarrisFeatures(rgb2gray(frameNextROI));
   [featuresNext,validPointsNext] = extractFeatures(rgb2gray(frameNextROI), pointsNext);

   indexPairs = matchFeatures(featuresBefore, featuresNext);
   matchedPointsB = validPointsBefore(indexPairs(:,1),:);
   matchedPointsN = validPointsNext(indexPairs(:,2),:);
   % showMatchedFeatures(frameBeforeROI,frameNextROI, matchedPointsB, matchedPointsN);
   if matchedPointsN.Count < 4 % si no tenemos suficientes para montar el modelo abortamos
       matchedPointsN.Count
       break;
   end

   [y, x] = find(BW);
   centroid = round(mean([x, y]));
   % imshow(BW); hold on; plot(centroid(1), centroid(2), 'b*'); hold off;
   newFrame = frameNext;
   % BannerA = I.*alpha;
   BannerA = I;
   BannerB = I2;
   [sizeX,sizeY,trash] = size(I);
   offsetx = -sizeX/2;
   offsety = -sizeY/2;
   newFrame(centroid(2) + offsetx : centroid(2) + offsetx + size(BannerA, 1) - 1, centroid(1) + offsety : centroid(1) + offsety + size(BannerA, 2) - 1,:) = ...
       newFrame(centroid(2) + offsetx : centroid(2) + offsetx + size(BannerA, 1) - 1, centroid(1) + offsety : centroid(1) + offsety + size(BannerA, 2) - 1,:).*(1-alpha) + BannerA;
   newFrame(centroid(2) - size(BannerA, 1)/2 - 75 : centroid(2) - size(BannerA, 1)/2 - 75 + size(BannerB, 1) - 1, centroid(1) - offsety : centroid(1) - offsety + size(BannerB, 2) - 1,:) = ...
       newFrame(centroid(2) - size(BannerA, 1)/2 - 75 : centroid(2) - size(BannerA, 1)/2 - 75 + size(BannerB, 1) - 1, centroid(1) - offsety : centroid(1) - offsety + size(BannerB, 2) - 1,:).*(1-alpha2) + BannerB;
   imshow(newFrame);

   % showMatchedFeatures(frameBeforeROI,frameNextROI, matchedPointsB, matchedPointsN);
   % imageCapture = getframe(gcf);
   % % legend('frame anterior','frame siguiente');
   % pause(1/videoHandleIn.FrameRate);
   
   tform = estimateGeometricTransform(matchedPointsB, matchedPointsN, "similarity");
   [xind,yind] = transformPointsForward(tform, xind, yind);


   roi.Position = [xind, yind];                    % actualizamos valores para... 
   BW = roi.createMask(rgb2gray(frameNext));     % comenzar un nuevo ciclo...
   BWfiltered = imfilter(double(BW), g);           % donde el frame actual pasar a ...
   frameBeforeROI = im2uint8(im2double(frameNext).*BWfiltered); % ser el frame anterior
   pointsBefore = pointsNext;
   featuresBefore = featuresNext;
   validPointsBefore = validPointsNext;

   writeVideo(videoHandleOut, newFrame); % lo escribimos
end

close(videoHandleOut);  % cerramos el video que estamos creando