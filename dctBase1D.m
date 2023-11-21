function [output] = dctBase1D(k,N)
%dctBase1D base Discrete Cosine Transform de k semiciclos en N muestras
n = [0:N-1]+0.5;
output = ((k==0)*1/sqrt(2)+(k~=0)*1).*cos(pi/N*n*k);
end

