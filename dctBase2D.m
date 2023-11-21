function salida = dctBase2D(k1, k2, N)
    basek1 = dctBase1D(k1, N);
    basek2 = dctBase1D(k2, N);
    salida = basek1'*basek2;
    % pista: usar multiplicacion entre vectores columna y fila 
    % para crear una matriz NxN
end