% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));

%% PERSONAJES
% Directorios para cada personaje
dirPersonajes = dir('.\dataset\train\personajes\*');
dirPersonajes = dirPersonajes([dirPersonajes.isdir]);
% Eliminar directorios . y ..
dirPersonajes = dirPersonajes(~ismember({dirPersonajes.name}, {'.', '..'}));
numPersonajes = numel(dirPersonajes);

% Crear carpetas necesarias
outFolder = fullfile('out');
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
outFolderPersonajes = fullfile(outFolder, 'personajes');
if ~exist(outFolderPersonajes, 'dir')
    mkdir(outFolderPersonajes);
end

fprintf('Procesando características de %d personajes...\n', numPersonajes);
numBins = 20;

% Calcular el total de imágenes para un progreso global preciso
totalImagenesTodas = 0;
imagenesPorPersonaje = zeros(numPersonajes, 1);

% Primero contar todas las imágenes para calcular el progreso global
fprintf('Calculando total de imágenes a procesar...\n');
for p = 1:numPersonajes
    nombrePersonaje = dirPersonajes(p).name;
    % Crear nombre de archivo sin espacios
    nombreArchivo = strrep(nombrePersonaje, ' ', '_');
    % Ruta a la carpeta específica del personaje
    outFolderPersonajeEspecifico = fullfile(outFolderPersonajes, nombreArchivo);
    % Cargar datos de entrada para este personaje
    archT_entradas = ['T_entradas_', nombreArchivo, '.mat'];
    try
        datos = load(fullfile(outFolderPersonajeEspecifico, archT_entradas)); % Carga T_entradas
        T_entradas_temp = datos.T_entradas;
        % Contar solo imágenes de entrenamiento
        numImagenesEntrenamiento = sum(cellfun(@(x) x == "0", T_entradas_temp(:,4)));
        imagenesPorPersonaje(p) = numImagenesEntrenamiento;
        totalImagenesTodas = totalImagenesTodas + numImagenesEntrenamiento;
    catch
        fprintf('Error: No se puede cargar el archivo para %s\n', nombrePersonaje);
        imagenesPorPersonaje(p) = 0;
    end
end

% Crear una figura principal con dos barras de progreso
mainProgressFig = figure('Name', 'Progreso de Extracción de Características', 'NumberTitle', 'off', ...
                        'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 500 150]);

% Texto para el nombre del personaje actual
personajeLabel = uicontrol('Style', 'text', 'Position', [50 120 400 20], ...
                          'String', 'Iniciando procesamiento...', 'FontWeight', 'bold');

% Barra de progreso para el personaje actual
currentProgressBar = uicontrol('Style', 'text', 'Position', [50 90 1 20], ...
                              'BackgroundColor', [0.8 0.9 0.8]);

% Texto para el progreso del personaje actual
currentProgressText = uicontrol('Style', 'text', 'Position', [50 70 400 20], ...
                               'String', 'Preparando...');

% Barra de progreso global
globalProgressBar = uicontrol('Style', 'text', 'Position', [50 40 1 20], ...
                             'BackgroundColor', [0.8 0.8 0.9]);

% Texto para el progreso global
globalProgressText = uicontrol('Style', 'text', 'Position', [50 20 400 20], ...
                              'String', sprintf('Total a procesar: %d imágenes de %d personajes', totalImagenesTodas, numPersonajes));

drawnow;

% Variables para seguimiento del progreso global
imagenesProcesadasTotal = 0;
imagenesProcesadasAcumuladas = 0;

% Procesar cada personaje
for p = 1:numPersonajes
    nombrePersonaje = dirPersonajes(p).name;
    
    % Actualizar etiqueta del personaje
    set(personajeLabel, 'String', ['Procesando: ' nombrePersonaje]);
      % Crear nombre de archivo sin espacios
    nombreArchivo = strrep(nombrePersonaje, ' ', '_');
    
    % Ruta a la carpeta específica del personaje
    outFolderPersonajeEspecifico = fullfile(outFolderPersonajes, nombreArchivo);
    if ~exist(outFolderPersonajeEspecifico, 'dir')
        set(currentProgressText, 'String', sprintf('Error: No se encuentra la carpeta para %s', nombrePersonaje));
        pause(1);
        continue;
    end
    
    % Cargar datos de entrada para este personaje
    archT_entradas = ['T_entradas_', nombreArchivo, '.mat'];
    try
        load(fullfile(outFolderPersonajeEspecifico, archT_entradas)); % Carga T_entradas
    catch
        set(currentProgressText, 'String', sprintf('Error: No se puede cargar el archivo para %s', nombrePersonaje));
        pause(1);
        continue;
    end
    
    numImagenes = size(T_entradas, 1);
    numImagenesEntrenamiento = imagenesPorPersonaje(p);
    
    % Resetear barra de progreso del personaje actual
    set(currentProgressBar, 'Position', [50 90 1 20]);
    set(currentProgressText, 'String', sprintf('Preparando para procesar %d imágenes', numImagenesEntrenamiento));
    
    T_caracteristicasPersonaje = [];
      % Variable para contar las imágenes de entrenamiento procesadas para este personaje
    imagenesProcesadasPersonaje = 0;
    
    for i = 1:numImagenes
        if T_entradas(i,4) == "0" % Solo procesar imágenes de entrenamiento
            % Actualizar contador de imágenes procesadas para este personaje
            imagenesProcesadasPersonaje = imagenesProcesadasPersonaje + 1;
            porcentajePersonaje = imagenesProcesadasPersonaje / numImagenesEntrenamiento;
            set(currentProgressBar, 'Position', [50 90 floor(400 * porcentajePersonaje) 20]);
            set(currentProgressText, 'String', sprintf('Imagen %d/%d (%.1f%%)', ...
                imagenesProcesadasPersonaje, numImagenesEntrenamiento, porcentajePersonaje * 100));
              % Actualizar progreso global (avance suave)
            imagenesProcesadasTotal = imagenesProcesadasAcumuladas + imagenesProcesadasPersonaje;
            if totalImagenesTodas > 0
                porcentajeGlobal = imagenesProcesadasTotal / totalImagenesTodas;
                set(globalProgressBar, 'Position', [50 40 floor(400 * porcentajeGlobal) 20]);
                set(globalProgressText, 'String', sprintf('Progreso total: %.1f%% (%d/%d imágenes - personaje %d/%d)', ...
                    porcentajeGlobal * 100, imagenesProcesadasTotal, totalImagenesTodas, p, numPersonajes));
            end
            
            img = imread(fullfile(T_entradas{i,2}, T_entradas{i,1}));
            
            % Extraer características y normalizar por número de píxeles
            vector = extraer_caracteristicas(img, numBins);
            
            % Obtener el número total de píxeles de la imagen
            [alto, ancho, ~] = size(img);
            numPixeles = alto * ancho;
            
            % Normalizar las características de color dividiéndolas por el número de píxeles
            vector_normalizado = vector / numPixeles;
            
            % Añadir la etiqueta al final del vector (0=absent, 1=present)
            vector_normalizado = [vector_normalizado, str2double(T_entradas{i,3})];
            T_caracteristicasPersonaje = [T_caracteristicasPersonaje; vector_normalizado];
        end
        
        drawnow;
    end
    
    % Actualizar el contador de imágenes procesadas acumuladas
    imagenesProcesadasAcumuladas = imagenesProcesadasAcumuladas + imagenesProcesadasPersonaje;
    
    % Informar sobre el tamaño de los datos procesados
    numCaracteristicas = size(T_caracteristicasPersonaje, 1);
    set(currentProgressText, 'String', sprintf('Procesamiento completado: %d vectores de características', numCaracteristicas));
    
    % Guardamos los datos originales normalizados por número de píxeles
    X = T_caracteristicasPersonaje(:,1:end-1);
    y = T_caracteristicasPersonaje(:,end);
    
    % Guardamos la tabla normalizada por número de píxeles
    T_caracteristicasPersonajeNorm = T_caracteristicasPersonaje;
    
    % Nombre del archivo de salida
    archSalida = ['T_caracteristicas_', nombreArchivo, 'Norm.mat'];
    
    % Guardamos la tabla normalizada en la carpeta específica del personaje
    save(fullfile(outFolderPersonajeEspecifico, archSalida), 'T_caracteristicasPersonajeNorm');
    
    % Actualizar información de guardado
    set(currentProgressText, 'String', sprintf('Archivo guardado en %s', outFolderPersonajeEspecifico));
    
    % Pausa para que se vea la información de guardado
    pause(0.5);
end

% Actualizar progreso global a completado
set(globalProgressBar, 'Position', [50 40 400 20]);
set(globalProgressText, 'String', sprintf('Procesamiento completo: %d imágenes en %d personajes', imagenesProcesadasTotal, numPersonajes));
set(personajeLabel, 'String', 'Procesamiento finalizado');
pause(1);

% Cerrar la figura de progreso
if ishandle(mainProgressFig)
    close(mainProgressFig);
end

fprintf('Procesamiento de características completo.\n');
