%% Leer un archivo de video, modificar, escribir en otro
videoHandleIn = VideoReader('shuttle.avi');        % de donde leeremos
videoHandleOut = VideoWriter('shuttle_out.avi');   % a donde escribiremos
videoHandleOut.FrameRate = videoHandleIn.FrameRate; % heredamos el frame rate
videoHandleOut.Quality = 100;

open(videoHandleOut); % creamos realmente el fichero de salida

f = uint8(checkerboard(2)*255);    % pequeña imagen que vamos a insertar en el video
sizeF = length(f);
f=reshape([f,f,f], sizeF, sizeF, 3);
r = [1:sizeF];

posF = 1; inc = +15;    % haremos que se desplaze en horizontal, en pasos inc

while hasFrame(videoHandleIn)  % mientras hayan frames que procesar
   frameActual = readFrame(videoHandleIn); % sacamos el frame actual como imagen

   result = myHarris(frameActual, .01, 10, 15/3/2);
   for x=1:size(result,1)
        frameActual(result(x,1), result(x,2), :) = [0, 255, 0];
        frameActual(result(x,1)+1, result(x,2), :) = [0, 255, 0];
        frameActual(result(x,1)-1, result(x,2), :) = [0, 255, 0];
        frameActual(result(x,1), result(x,2)+1, :) = [0, 255, 0];
        frameActual(result(x,1), result(x,2)-1, :) = [0, 255, 0];
   end
   imshow(frameActual); pause;
   writeVideo(videoHandleOut,frameActual);
   
%    frameActual(end/2+r, posF+r, :) = f;  % insertamos la imagen móvil sobre el frame actual
% 
%    writeVideo(videoHandleOut,frameActual); % lo escribimos
% 
%    if ( ((sign(inc)>0) && (posF+sizeF+inc > size(frameActual, 2))) || ((sign(inc)<0) && ((posF+inc) < 1)) )
%        inc = -inc;  % comprobamos si estamos en un borde para cambiar de direccion
%    end
%    posF = posF+inc;  % actualizamos posición de la f, de cara al siguiente frame
end
close(videoHandleOut);  % cerramos el de escritura

%% Leer y visualizar
videoHandleIn = VideoReader('shuttle_out.avi');

frameNumber = 1;
while hasFrame(videoHandleIn)
   mov(frameNumber) = im2frame(readFrame(videoHandleIn)); % mov: secuencia de frames
   frameNumber = frameNumber+1;
end

figure % nueva figura donde se muestra el primer frame
imshow(mov(1).cdata, 'Border', 'tight') % suprimiendo bordes

movie(mov,1,videoHandleIn.FrameRate)  % se llama a movie con la secuencia mov

