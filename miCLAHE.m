pout = imread('pout.tif'); %im2double(imread('pout.tif'));

halfWin = 5; winSize = halfWin*2+1; r = [-halfWin:halfWin];
poutExt = double(padarray(pout, [halfWin,halfWin], 'symmetric'));
res = poutExt*0;

r = -halfWin:halfWin;
weightedMask = halfWin-abs(ones(1, winSize)'*r);
weights = weightedMask.*weightedMask'/halfWin/halfWin;

for i=1:halfWin:size(pout, 1)
    for j=1:halfWin:size(pout, 2)
        imRegion = poutExt(i+halfWin+r, j+halfWin+r);
        resAux = miHistEqCL(imRegion, 0.003).* weights;
        res(i+[0:winSize-1],j+[0:winSize-1])=res(i+[0:winSize-1],j+[0:winSize-1]) + resAux;
    end
end
newI = res(halfWin+1:size(pout, 1)+halfWin, halfWin+1:size(pout, 2)+halfWin);
subplot(131);
imshow(res/255);
subplot(132);
imshow(pout);
subplot(133); imshow(newI/255);