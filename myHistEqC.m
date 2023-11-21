function [newI] = myHistEqC(I)
newI = I*0;
for c=1:3
    Ic = I(:,:,c);
    newIc = Ic*0;
    val = miHist(Ic);
    cdf = cumsum(val);
    cdf = cdf./cdf(end);
    nuevoColor = uint8(cdf*255);
    for color = 0:255
        newIc(Ic == color) = nuevoColor(color+1);
    end
    newI(:,:,c) = newIc;
end
end