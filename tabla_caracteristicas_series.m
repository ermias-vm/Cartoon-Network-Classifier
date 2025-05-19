% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));

%% SERIES
load(fullfile('out', 'series', 'T_entradasSeries.mat')); % Carga T_entradasSeries
numImagenes_S = size(T_entradasSeries,1);

numBins = 20;
T_caracteristicasSeries = [];

% Contar cuántas imágenes son de entrenamiento para calcular el progreso correctamente
fprintf('Calculando total de imágenes de entrenamiento a procesar...\n');
totalTrain = 0;
for i = 1:numImagenes_S
    if T_entradasSeries(i,4) == "0"
        totalTrain = totalTrain + 1;
    end
end
fprintf('Se procesarán %d imágenes de entrenamiento de un total de %d imágenes.\n', totalTrain, numImagenes_S);

% Crear una figura para mostrar el progreso
progressFig = figure('Name', 'Progreso de Extracción de Características Series', 'NumberTitle', 'off', ...
                        'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 500 100]);

% Crear barra de progreso
progressBar = uicontrol('Style', 'text', 'Position', [50 50 1 30], ...
                       'BackgroundColor', [0.8 0.9 0.8]);

% Texto para mostrar el progreso
progressText = uicontrol('Style', 'text', 'Position', [50 20 400 20], ...
                        'String', sprintf('Preparando para procesar %d imágenes...', numImagenes_S));

drawnow;

% Inicializar contador de imágenes procesadas
imagenesProcesadas = 0;

for i = 1:numImagenes_S
    if T_entradasSeries(i,4) == "0" % Solo procesar imágenes de entrenamiento
        % Actualizar contador para imágenes de entrenamiento
        imagenesProcesadas = imagenesProcesadas + 1;
          % Actualizar progreso basado únicamente en imágenes de entrenamiento
        porcentaje = imagenesProcesadas / totalTrain;
        set(progressBar, 'Position', [50 50 floor(400 * porcentaje) 30]);
        set(progressText, 'String', sprintf('Procesando: %d/%d imágenes de entrenamiento (%.1f%%)', ...
            imagenesProcesadas, totalTrain, porcentaje * 100));
        
        img = imread(fullfile(T_entradasSeries{i,2}, T_entradasSeries{i,1}));
        
        % Extraer características y normalizar por número de píxeles
        vector = extraer_caracteristicas(img, numBins);
        
        % Obtener el número total de píxeles de la imagen
        [alto, ancho, ~] = size(img);
        numPixeles = alto * ancho;
        
        % Normalizar las características de color dividiéndolas por el número de píxeles
        vector_normalizado = vector / numPixeles;
        
        % Añadir la etiqueta al final del vector
        vector_normalizado = [vector_normalizado, str2double(T_entradasSeries{i,3})];
        T_caracteristicasSeries = [T_caracteristicasSeries; vector_normalizado];
    end
    
    drawnow;
end

% Actualizar progreso a completado
set(progressBar, 'Position', [50 50 400 30]);
set(progressText, 'String', sprintf('Procesamiento completo: %d/%d imágenes procesadas (%.1f%%)', ...
    imagenesProcesadas, totalTrain, (imagenesProcesadas/totalTrain)*100));

% Guardamos los datos originales normalizados por número de píxeles
X = T_caracteristicasSeries(:,1:end-1);
y = T_caracteristicasSeries(:,end);

% Guardamos la tabla normalizada por número de píxeles
T_caracteristicasSeriesNorm = T_caracteristicasSeries;

% Crear carpetas necesarias
if ~exist('out','dir')
    mkdir('out')
end
if ~exist(fullfile('out','series'),'dir')
    mkdir(fullfile('out','series'))
end

% Guardamos la tabla normalizada en la subcarpeta series
save(fullfile('out','series','T_caracteristicasSeriesNorm.mat'),'T_caracteristicasSeriesNorm');

% Actualizar mensaje final
set(progressText, 'String', sprintf('Archivo guardado en %s', fullfile('out','series','T_caracteristicasSeriesNorm.mat')));
pause(1);

% Cerrar la figura de progreso
if ishandle(progressFig)
    close(progressFig);
end

