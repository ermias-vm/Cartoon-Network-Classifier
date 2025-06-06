function vector = extraer_caracteristicas_personaje(img)
    % Extraer características HOG para identificación de personajes (Peter Griffin)
    % Entrada: img - imagen en formato RGB
    % Salida: vector - vector de características HOG normalizado
    
    % Convertir a escala de grises si es necesario
    if size(img, 3) == 3
        imgGray = rgb2gray(img);
    else
        imgGray = img;
    end
    
    % Redimensionar la imagen a un tamaño estándar para consistencia
    imgResized = imresize(imgGray, [128, 128]);
    
    % Parámetros HOG optimizados para detección de personajes
    cellSize = [8, 8];           % Tamaño de celda en píxeles
    blockSize = [2, 2];          % Tamaño de bloque en celdas
    blockOverlap = [1, 1];       % Solapamiento de bloques
    numBins = 9;                 % Número de bins para orientaciones
    
    % Extraer características HOG usando Computer Vision Toolbox
    hogFeatures = extractHOGFeatures(imgResized, 'CellSize', cellSize, ...
                                   'BlockSize', blockSize, ...
                                   'BlockOverlap', blockOverlap, ...
                                   'NumBins', numBins);
    
    % Normalizar el vector de características (L2 normalization)
    vector = hogFeatures / (norm(hogFeatures) + eps);
    
    % Asegurar que el vector sea una fila
    if size(vector, 1) > 1
        vector = vector';
    end
end
