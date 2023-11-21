function [values] = myHist(I)
%genera Histograma no realiza cambios a la imagen
values = zeros(1,256);
for color = 0:255
   values(color+1) = sum(sum(I==color));
%imshow(imagen==color); title(color); pause(0.1);
end