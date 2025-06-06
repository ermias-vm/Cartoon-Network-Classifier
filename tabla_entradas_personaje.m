% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));

%% PERSONAJES (Peter Griffin)
% Buscar imágenes en las carpetas present y absent
imagenes_present = dir('.\dataset\train\personajes\Peter Griffin\present\*.jpg');
imagenes_absent = dir('.\dataset\train\personajes\Peter Griffin\absent\*.jpg');

% Combinar ambas listas
imagenes_P = [imagenes_present; imagenes_absent];
numImagenes_P = numel(imagenes_P);

fprintf('Encontradas %d imágenes de Peter Griffin en el dataset:\n', numImagenes_P);
fprintf('  - Presente: %d imágenes\n', numel(imagenes_present));
fprintf('  - Ausente: %d imágenes\n', numel(imagenes_absent));

% Mapeo de etiquetas: 1 = presente, 0 = ausente
% Esto se determinará por la carpeta (present/absent), no por el personaje
T_entradasPersonajes = [];
test_idx_P = false(numImagenes_P,1);

% Crear barra de progreso para la carga de imágenes
fprintf('Procesando estructura de imágenes de personajes...\n');
progressFig = figure('Name', 'Cargando Entradas de Personajes', 'NumberTitle', 'off', ...
                    'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 500 100]);

progressBar = uicontrol('Style', 'text', 'Position', [50 50 1 30], ...
                       'BackgroundColor', [0.8 0.9 0.8]);

progressText = uicontrol('Style', 'text', 'Position', [50 20 400 20], ...
                        'String', sprintf('Preparando para procesar %d imágenes...', numImagenes_P));

drawnow;

% Asignar 0 (entrenamiento) a 7 de cada 10 imágenes, 1 (test) a las 3 siguientes
for i = 1:numImagenes_P
    % Actualizar barra de progreso
    porcentaje = i / numImagenes_P;
    set(progressBar, 'Position', [50 50 floor(400 * porcentaje) 30]);
    set(progressText, 'String', sprintf('Procesando imagen %d de %d (%.1f%%)', ...
        i, numImagenes_P, porcentaje * 100));
    
    carpeta = imagenes_P(i).folder;
    [~, nombreCarpeta] = fileparts(carpeta);
    
    % Determinar etiqueta basándose en la carpeta (present/absent)
    if strcmp(nombreCarpeta, 'present')
        etiqueta = 1; % Peter Griffin presente
    elseif strcmp(nombreCarpeta, 'absent')
        etiqueta = 0; % Peter Griffin ausente
    else
        fprintf('Advertencia: Carpeta "%s" no reconocida en imagen %s\n', ...
                nombreCarpeta, imagenes_P(i).name);
        continue;
    end
    
    % Asignar entrenamiento/test (70/30)
    idx10 = mod(i-1,10) + 1;
    if idx10 <= 7
        esTest = 0; % entrenamiento
    else
        esTest = 1; % test
        test_idx_P(i) = true;
    end
    
    fila = [ string(imagenes_P(i).name), ...
             string(imagenes_P(i).folder), ...
             etiqueta, ...
             esTest ];
    T_entradasPersonajes = [T_entradasPersonajes; fila];
    
    drawnow;
end

% Cerrar barra de progreso
if ishandle(progressFig)
    close(progressFig);
end

% Crear carpetas necesarias
outFolder = fullfile('out');
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
outFolderPersonajes = fullfile(outFolder, 'personajes');
if ~exist(outFolderPersonajes, 'dir')
    mkdir(outFolderPersonajes);
end
outFolderPeterGriffin = fullfile(outFolderPersonajes, 'Peter Griffin');
if ~exist(outFolderPeterGriffin, 'dir')
    mkdir(outFolderPeterGriffin);
end

% Calcular y mostrar estadísticas
if ~isempty(T_entradasPersonajes)
    col4 = cellfun(@str2double, cellstr(T_entradasPersonajes(:,4)));
    numTrain = sum(col4 == 0);
    numTest = sum(col4 == 1);
    porcTrain = 100 * numTrain / size(T_entradasPersonajes, 1);
    
    fprintf('\n=== ESTADÍSTICAS DE PERSONAJES ===\n');
    fprintf('Total de imágenes procesadas: %d\n', size(T_entradasPersonajes, 1));
    fprintf('Imágenes de entrenamiento: %d (%.2f%%)\n', numTrain, porcTrain);
    fprintf('Imágenes de test: %d (%.2f%%)\n', numTest, 100 - porcTrain);
      % Mostrar distribución por etiqueta
    fprintf('\nDistribución por etiqueta:\n');
    col3 = cellfun(@str2double, cellstr(T_entradasPersonajes(:,3)));
    numPresente = sum(col3 == 1);
    numAusente = sum(col3 == 0);
    fprintf('  Peter Griffin presente (etiqueta 1): %d imágenes\n', numPresente);
    fprintf('  Peter Griffin ausente (etiqueta 0): %d imágenes\n', numAusente);
    
    % Generar tabla solo con las de test
    T_entradasPersonajesTest = T_entradasPersonajes(col4 == 1, :);
      % Guardar los archivos en la subcarpeta "Peter Griffin"
    save(fullfile(outFolderPeterGriffin, 'T_entradasPersonajes.mat'),'T_entradasPersonajes');
    save(fullfile(outFolderPeterGriffin, 'T_entradasPersonajesTest.mat'),'T_entradasPersonajesTest');
    
    fprintf('\nArchivos guardados exitosamente en:\n');
    fprintf('  %s\n', fullfile(outFolderPeterGriffin, 'T_entradasPersonajes.mat'));
    fprintf('  %s\n', fullfile(outFolderPeterGriffin, 'T_entradasPersonajesTest.mat'));
else
    fprintf('Error: No se procesaron imágenes de personajes.\n');
    fprintf('Verificar que existan imágenes en: %s\n', fullfile('dataset', 'train', 'personajes'));
end