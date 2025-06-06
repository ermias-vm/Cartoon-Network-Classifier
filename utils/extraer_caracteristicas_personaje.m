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
    
    % Extraer características HOG
    try
        % Usar extractHOGFeatures si está disponible (Computer Vision Toolbox)
        hogFeatures = extractHOGFeatures(imgResized, 'CellSize', cellSize, ...
                                       'BlockSize', blockSize, ...
                                       'BlockOverlap', blockOverlap, ...
                                       'NumBins', numBins);
    catch
        % Fallback: implementación manual básica de HOG
        hogFeatures = computeBasicHOG(imgResized, cellSize, numBins);
    end
    
    % Normalizar el vector de características (L2 normalization)
    vector = hogFeatures / (norm(hogFeatures) + eps);
    
    % Asegurar que el vector sea una fila
    if size(vector, 1) > 1
        vector = vector';
    end
end

function hogFeatures = computeBasicHOG(img, cellSize, numBins)
    % Implementación básica de HOG sin Computer Vision Toolbox
    
    [rows, cols] = size(img);
    img = double(img);
    
    % Calcular gradientes
    Gx = [-1, 0, 1; -2, 0, 2; -1, 0, 1];
    Gy = [-1, -2, -1; 0, 0, 0; 1, 2, 1];
    
    Ix = conv2(img, Gx, 'same');
    Iy = conv2(img, Gy, 'same');
    
    % Magnitud y orientación del gradiente
    magnitude = sqrt(Ix.^2 + Iy.^2);
    orientation = atan2(Iy, Ix);
    
    % Convertir orientación a grados [0, 180]
    orientation = mod(orientation * 180 / pi, 180);
    
    % Dividir en celdas
    cellRows = cellSize(1);
    cellCols = cellSize(2);
    
    numCellsY = floor(rows / cellRows);
    numCellsX = floor(cols / cellCols);
    
    hogFeatures = [];
    
    % Para cada celda
    for i = 1:numCellsY
        for j = 1:numCellsX
            % Obtener región de la celda
            rowStart = (i-1) * cellRows + 1;
            rowEnd = i * cellRows;
            colStart = (j-1) * cellCols + 1;
            colEnd = j * cellCols;
            
            cellMag = magnitude(rowStart:rowEnd, colStart:colEnd);
            cellOri = orientation(rowStart:rowEnd, colStart:colEnd);
            
            % Crear histograma de orientaciones para esta celda
            hist = zeros(1, numBins);
            binWidth = 180 / numBins;
            
            for r = 1:size(cellMag, 1)
                for c = 1:size(cellMag, 2)
                    angle = cellOri(r, c);
                    mag = cellMag(r, c);
                    
                    % Encontrar bin apropiado
                    binIdx = floor(angle / binWidth) + 1;
                    if binIdx > numBins
                        binIdx = numBins;
                    end
                    
                    hist(binIdx) = hist(binIdx) + mag;
                end
            end
            
            hogFeatures = [hogFeatures, hist];
        end
    end
end
