% Se les provee la funcion dctBase1D
% Busque TO DO para encontrar lo que debe incluir en su informe
% Vamos a comprobar que las bases son ortogonales entre sí, en 1D
N=8;
fail = false;
matrizProductosInternos = zeros(N);
for i=0:N-1
    for j=0:N-1
        matrizProductosInternos(i +1, j +1) = sum(dctBase1D(i, N).*dctBase1D(j,N))
        % pista: usar producto interno y funcion dctBase1D
    end
end
imagesc(matrizProductosInternos);

%%
% Vamos a crear partiendo del siguiente código, la imagen de las
% bases DCT 2D que se ve en los apuntes de teoria, 
% concretamente en la transparencia 3a del bloque JPEG
N=8;
bases = zeros(N*N);
for i=0:N-1
    for j=0:N-1
        bases(i*N+[1:N], j*N+[1:N]) = dctBase2D(i,j,N)
    end
end
imagesc(bases); colomap(gray);


%%
% Vamos a descomponer una imagen trabajando por bloques
% ** TO DO opcional: trabajar en color
I = double(imread('pout.tif'));  % Sustituir por la que se quiera
N = 8;
sizeI = size(I);
% el siguiente código expande la imagen de entrada para asegurarse que es
% multiplo de N
sizeNewI = ceil(sizeI/N)*N;
newI = zeros(sizeNewI);
newI(1:sizeI(1), 1:sizeI(2))=I;
coeficientesDCT = newI*0;
coeficientesBloque = zeros(N);


for ySquare=0:sizeNewI(1)/8-1
    for xSquare=0:sizeNewI(2)/8-1
        region = newI(ySquare*N+[1:N], xSquare*N+[1:N]);
        
        for i=0:N-1
            for j=0:N-1
                coeficientesBloque(i +1, j +1) = sum(sum(region.*dctBase2D(i,j,N)))*2/sqrt(N*N);
                % nota: incluir normalización con un factor *2/sqrt(N*N);

            end
        end
        coeficientesDCT(ySquare*N+[1:N], xSquare*N+[1:N]) = coeficientesBloque;
    end
end
imshow(coeficientesDCT, []);

%%
% Vamos a mostrar los coeficientes
% ** TO DO: modificar para hacer zoom sobre los primeros 5x5 bloques. DONE
imagesc(abs(coeficientesDCT(1:5*N, 1:5*N))); colormap(gray); axis('equal');
% alternativamente: imshow(coeficientesDCT, []);

%%
% Vamos a recomponer la imagen, pero antes vamos a eliminar los 
% coeficientes con un valor absoluto por debajo de 2
newCoeficientesDCT = coeficientesDCT;
newCoeficientesDCT(abs(coeficientesDCT) < 2) = 0;
% ** TO DO: cuantificar qué tanto por ciento de coeficientes hemos hecho 0.
% DONE
total = sizeNewI(1)*sizeNewI(2);
percentage = sum(sum(abs(coeficientesDCT) < 2))/total*100;
% ** TO DO opcional: cortar no con un valor arbitrario, sino con el valor que
% represente el 95 por ciento de la energia, ojo, no es el 95% de los
% coeficientes. Revisar Imadjust de energía

% Resintetizamos la imagen
for ySquare=0:sizeNewI(1)/8-1
    for xSquare=0:sizeNewI(2)/8-1
        region = zeros(N);
        for i=0:N-1
            for j=0:N-1
                region = region + ...
                    newCoeficientesDCT(ySquare*N+i +1, xSquare*N+j +1)*...
                    bases(i*N+[1:N], j*N+[1:N])*2/sqrt(N*N);
            end
        end
        newI(ySquare*N+[1:N], xSquare*N+[1:N]) = region;
    end
end

%% Mostramos el resultado
% ** TO DO: quitar los píxeles de más que incluimos mediante sizeNewI. DONE
cropNewI = newI(1:sizeI(1), 1:sizeI(2));
imshow(uint8(cropNewI))

