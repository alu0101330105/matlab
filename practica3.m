%% cargar una imagen, pasar a Lab
I = imread('ventanaHiedra.png');
I_lab = rgb2lab(I);     % imagen en CIE L*a*b*
nI_lab = I_lab;

% HACER: aplicar corrección gamma de 0.8, a la L, mostrar, deshacer y aplicar 0.8 pero a los canales de color. Repetir ambas pruebas pero con 1.2

variance = 0.8;

nI_lab(:,:,1) = ((nI_lab(:,:,1)./100).^0.8)*100;

for c=1:3
    A = nI_lab(:,:,c);
    sA = sign(A);
    A = A.*sA;
    A_0_8 = ((A/64).^variance)*64;
    A_0_8 = A_0_8.*sA;
end
imshow(lab2rgb(nI_lab));

%% Denoising de una imagen

% filtro bilateral con DoS 10 a la L
nI_lab(:,:,1)=imbilatfilt(I_lab(:,:,1),10);

% posteriormente realce
nI_lab(:,:,1)=imfilter(nI_lab(:,:,1),[0 -1.25 0; -1.25 10 -1.25; 0 -1.25 0]/5);

% filtro de mediana a los dos canales de crominancia
nI_lab(:,:,2)=medfilt2(I_lab(:,:,2), [10, 10]);
nI_lab(:,:,3)=medfilt2(I_lab(:,:,3), [10, 10]);

% comparar imagen sin tratar y tratada
figure(1); subplot(211); imshow(I); subplot(212); imshow(lab2rgb(nI_lab))

%% filtros en 1D
N = 16;
f = [zeros(1,N/2), ones(1,N/2)*10];

fNoise = f+randn(1,16)*0.5;  % señal con ruido
figure(2); plot([1:N], f, [1:N], fNoise); legend('f', 'f noisy');

h = [1 2 1]; h = h/sum(h);    % filtro suavizador
ss = 1; ws = 2*ss+1; r = [-ss:ss]; %% ss: semiSize; ws: windowsSize
fNoiseExt = padarray(fNoise,[0,ss],"replicate"); % adosar réplicas en 1D
fFiltered = f.*0;   % inicializamos a 0 el resultado

% forma habitual en Matlab
% for i=1:length(f)
%     fFiltered(i) = sum(fNoiseExt(i+ss+r).*h);
% end

% versión similar a C
for i=0:length(f)-1
    res = 0;
    for u = -ss:ss  % for (u = -ss; u <= ss; u++)
        res = res + fNoiseExt(ss+i+u +1)*h(u+ss +1);
    end
    fFiltered(i +1) = res;
end

figure(2); hold on; plot([1:N], fFiltered); legend('f', 'f noisy', 'f blur');

figure(3); plot([1:N], f, [1:N], fNoise,[1:N],miFiltroBilateral(fNoise, 9, 3)); legend('f', 'f noisy', 'f bilateral');


%%
% HACER
%  * lo indicado en la línea 7, compresión gamma -> recuerde normalizar el rango a 1, antes de aplicar el exponente, y regresar al rango original al finalizar

% PROGRAMAR por ustedes mismos: 
%  * el filtro de ventana deslizante 2D con kernel genérico para sustituir al imfilter(i, h) de la linea 16. Hagan uso de padarray "replicate"
%  * ayudarse de gausswin -> para crear h de suavizado, recibirá como parámetros el diámetro y la sigma
%  * mostrar el resultado de aplicar h gausiana con 3 sigmas diferentes sobre la L
%  * el filtro de mediana bidimensional para sustituir al medfilt2(i, h) de la linea 16
%  * el filtro bilateral, al menos en 1 dimension, y mostrar el resultado al pasarlo sobre el ejemplo de señal 1D ruidosa discontinua de la segunda sección

% Ayudas: https://people.csail.mit.edu/sparis/bf_course/course_notes.pdf
% en esos apuntes, en la fórmula 2, se describe el filtro gausiano (que pueden encontrar en 'edit gausswin') las fórmulas 3 y 4 describen el filtro bilateral

nI_labExt = padarray(I_lab, [5,5], "replicate");
h = gausswin(10)*gausswin(10)';
h = h./sum(sum(h));

ss = 5; ws = 2*ss+1;

r = [-ss:ss];

for i=0:length(nI_lab)
    for j=0:lengnth(nI_lab)
        res = 0;
        for u = -ss:ss
            for v = -ss:ss
                res = res + nI_labExt(ss+i+u, ss+j+v)*h(u+ss+1: v+ss+1);
            end
        end
        nI_labExt(i+1, j+1) = res;
    end
end
imshow(lab2rgb(nI_labExt))

