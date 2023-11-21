function [res] = miHistEqCL(I, lim)
val = myHist(I);

minVal = min(val, sum(val)*lim); % Establecemos el límite y cortamos exceso
excesoValores = sum(val-minVal); % recojemos el exceso
val = minVal + excesoValores/256; % reasignamos el exceso

normalizedval = cumsum(val)/sum(val);
nuevoColor = uint8(normalizedval*255);
res = I*0;
for color = 0:255
    res(I==color) = nuevoColor(color+1);
end

% Visualization
subplot(121); imshow(res)
val = myHist(res);
normalizedval = cumsum(val)/sum(val);
subplot(122); imhist(res); axis('tight'); hold on; plot(normalizedval*max(val), 'r', 'LineWidth',2)
end
