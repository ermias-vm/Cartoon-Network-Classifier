% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));

%% PERSONAJES (Peter Griffin)
try
    load(fullfile('out', 'personajes', 'Peter Griffin', 'T_entradasPersonajes.mat')); % Carga T_entradasPersonajes
catch
    fprintf('Error: No se encontró el archivo T_entradasPersonajes.mat en la carpeta Peter Griffin\n');
    fprintf('Ejecuta primero "tabla_entradas_personaje.m" para generar las tablas de entrada.\n');
    return;
end

numImagenes_P = size(T_entradasPersonajes,1);

% Parámetros HOG para Peter Griffin
cellSize = [8, 8];           % Tamaño de celda optimizado para personajes
blockSize = [2, 2];          % Tamaño de bloque en celdas
numBins = 9;                 % Orientaciones para HOG

T_caracteristicasPersonajes = [];

% Contar cuántas imágenes son de entrenamiento para calcular el progreso correctamente
fprintf('Calculando total de imágenes de personajes de entrenamiento a procesar...\n');
totalTrain = 0;
for i = 1:numImagenes_P
    if T_entradasPersonajes(i,4) == "0"
        totalTrain = totalTrain + 1;
    end
end
fprintf('Se procesarán %d imágenes de entrenamiento de un total de %d imágenes de personajes.\n', totalTrain, numImagenes_P);

% Crear una figura para mostrar el progreso
progressFig = figure('Name', 'Progreso de Extracción de Características Personajes', 'NumberTitle', 'off', ...
                        'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 500 100]);

% Crear barra de progreso
progressBar = uicontrol('Style', 'text', 'Position', [50 50 1 30], ...
                       'BackgroundColor', [0.9 0.8 0.8]);

% Texto para mostrar el progreso
progressText = uicontrol('Style', 'text', 'Position', [50 20 400 20], ...
                        'String', sprintf('Preparando para procesar %d imágenes de personajes...', totalTrain));

drawnow;

% Inicializar contador de imágenes procesadas
imagenesProcesadas = 0;

fprintf('\nProcesando características HOG para personajes...\n');

for i = 1:numImagenes_P
    if T_entradasPersonajes(i,4) == "0" % Solo procesar imágenes de entrenamiento
        % Actualizar contador para imágenes de entrenamiento
        imagenesProcesadas = imagenesProcesadas + 1;
        
        % Actualizar progreso basado únicamente en imágenes de entrenamiento
        porcentaje = imagenesProcesadas / totalTrain;
        set(progressBar, 'Position', [50 50 floor(400 * porcentaje) 30]);
        set(progressText, 'String', sprintf('Procesando: %d/%d imágenes de personajes (%.1f%%)', ...
            imagenesProcesadas, totalTrain, porcentaje * 100));
        
        try
            % Cargar imagen
            img = imread(fullfile(T_entradasPersonajes{i,2}, T_entradasPersonajes{i,1}));
            
            % Extraer características HOG para personajes
            vector = extraer_caracteristicas_personaje(img);
            
            % Añadir la etiqueta al final del vector
            vector_normalizado = [vector, str2double(T_entradasPersonajes{i,3})];
            T_caracteristicasPersonajes = [T_caracteristicasPersonajes; vector_normalizado];
            
        catch e
            fprintf('Error al procesar imagen %s: %s\n', T_entradasPersonajes{i,1}, e.message);
        end
    end
    
    drawnow;
end

% Actualizar progreso a completado
set(progressBar, 'Position', [50 50 400 30]);
set(progressText, 'String', sprintf('Procesamiento completo: %d/%d imágenes de personajes procesadas (%.1f%%)', ...
    imagenesProcesadas, totalTrain, (imagenesProcesadas/totalTrain)*100));

% Guardamos los datos HOG normalizados
X = T_caracteristicasPersonajes(:,1:end-1);
y = T_caracteristicasPersonajes(:,end);

% Guardamos la tabla de características HOG
T_caracteristicasPersonajesNorm = T_caracteristicasPersonajes;

% Crear carpetas necesarias
if ~exist('out','dir')
    mkdir('out')
end
if ~exist(fullfile('out','personajes'),'dir')
    mkdir(fullfile('out','personajes'))
end
if ~exist(fullfile('out','personajes','Peter Griffin'),'dir')
    mkdir(fullfile('out','personajes','Peter Griffin'))
end

% Guardamos la tabla normalizada en la subcarpeta Peter Griffin
save(fullfile('out','personajes','Peter Griffin','T_caracteristicasPersonajesNorm.mat'),'T_caracteristicasPersonajesNorm');

% Actualizar mensaje final
set(progressText, 'String', sprintf('Archivo guardado en %s', fullfile('out','personajes','Peter Griffin','T_caracteristicasPersonajesNorm.mat')));

fprintf('\n=== EXTRACCIÓN DE CARACTERÍSTICAS COMPLETADA ===\n');
fprintf('Total de vectores de características generados: %d\n', size(T_caracteristicasPersonajes, 1));
fprintf('Dimensiones del vector HOG: %d características por imagen\n', size(T_caracteristicasPersonajes, 2) - 1);
fprintf('Archivo guardado: %s\n', fullfile('out','personajes','Peter Griffin','T_caracteristicasPersonajesNorm.mat'));

pause(2);

% Cerrar la figura de progreso
if ishandle(progressFig)
    close(progressFig);
end