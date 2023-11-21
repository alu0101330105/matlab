% Mapa de correlaciones entre las se�ales g y f
function mapCorr = corrFFT(g, f)
[Ny_g, Nx_g] = size(g);
[Ny_f, Nx_f] = size(f);

% preparamos los tama�os para realizar conv. lineal
Ny = 2.^ceil(log2(Ny_f+Ny_g-1));
Nx = 2.^ceil(log2(Nx_f+Nx_g-1));
% orlamos con 0s m�s all� de size(t)+size(f)-1
g(Ny,Nx) = 0;
f(Ny,Nx) = 0;

% pasamos al dominio transformado
G = fft2(g);

% TO DO: Qu� falta por hacer?
F = conj(fft2(f));

mapCorr=real(ifft2(G.*F));
% nos quedamos con la zona en que la plantilla f, encaj� con g
mapCorr = mapCorr(1:Ny_g, 1:Nx_g);
