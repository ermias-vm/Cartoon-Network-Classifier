function vector = extraer_caracteristicas_series(img, numBins)
    R = img(:,:,1); G = img(:,:,2); B = img(:,:,3);
    hsv = rgb2hsv(img);
    H = hsv(:,:,1); V = hsv(:,:,3);

    hH = imhist(H, numBins)';
    hV = imhist(V, numBins)';
    hR = imhist(R, numBins)';
    hG = imhist(G, numBins)';
    hB = imhist(B, numBins)';
    
    % Obtener el número total de píxeles de la imagen
    [alto, ancho, ~] = size(img);
    numPixeles = alto * ancho;
    
    % Normalizar las características dividiendo por el número de píxeles
    vector = [hH, hV, hR, hG, hB] / numPixeles;
end