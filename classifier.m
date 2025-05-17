%% CLASIFICADOR DE SERIES DE DIBUJOS ANIMADOS DE CARTOON NETWORK
% Este programa identifica series de dibujos animados a partir de imágenes
% utilizando modelos entrenados previamente.

% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));
disp(['Añadida carpeta utils: ', fullfile(pwd, 'utils')]);

% Verificar que las funciones están disponibles
if exist('copiarImagenesTest', 'file') ~= 2
    warning('La función copiarImagenesTest no se encontró. Comprobando...');
    dirUtils = dir(fullfile(pwd, 'utils', '*.m'));
    disp('Funciones disponibles en utils:');
    for i = 1:length(dirUtils)
        disp(['  - ', dirUtils(i).name]);
    end
end

% Verificar y crear estructura de carpetas
% Carpeta principal dataset
if ~exist('dataset', 'dir')
    mkdir('dataset');
    fprintf('Carpeta "dataset" creada correctamente.\n');
end

% Carpetas train y test
if ~exist(fullfile('dataset', 'train'), 'dir')
    mkdir(fullfile('dataset', 'train'));
    fprintf('Carpeta "dataset/train" creada correctamente.\n');
end

if ~exist(fullfile('dataset', 'test'), 'dir')
    mkdir(fullfile('dataset', 'test'));
    fprintf('Carpeta "dataset/test" creada correctamente.\n');
end

% Subcarpetas de train
if ~exist(fullfile('dataset', 'train', 'series'), 'dir')
    mkdir(fullfile('dataset', 'train', 'series'));
    fprintf('Carpeta "dataset/train/series" creada correctamente.\n');
end

if ~exist(fullfile('dataset', 'train', 'personajes'), 'dir')
    mkdir(fullfile('dataset', 'train', 'personajes'));
    fprintf('Carpeta "dataset/train/personajes" creada correctamente.\n');
end

% Subcarpetas de test
if ~exist(fullfile('dataset', 'test', 'series'), 'dir')
    mkdir(fullfile('dataset', 'test', 'series'));
    fprintf('Carpeta "dataset/test/series" creada correctamente.\n');
end

if ~exist(fullfile('dataset', 'test', 'misclassified'), 'dir')
    mkdir(fullfile('dataset', 'test', 'misclassified'));
    fprintf('Carpeta "dataset/test/misclassified" creada correctamente.\n');
end

if ~exist(fullfile('dataset', 'test', 'personajes'), 'dir')
    mkdir(fullfile('dataset', 'test', 'personajes'));
    fprintf('Carpeta "dataset/test/personajes" creada correctamente.\n');
end

% Carga el modelo de series
modeloSeries = fullfile('series', 'SeriesSVM983.mat');
numBins = 20;

% Nombres de las series
seriesNames = {'barrufets','Bob esponja','gat i gos','Gumball', ...
    'hora de aventuras','Oliver y Benji','padre de familia', ...
    'pokemon','southpark','Tom y Jerry'};


% Mostrar menú principal (inicio)
fprintf('\n%s\n', repmat('=', 1, 60));

fprintf('                   CARTOON NETWORK CLASSIFIER\n');
fprintf('%s\n', repmat('=', 1, 60));

% Interfaz de usuario
while true
    fprintf('\n¿Qué quieres hacer?\n\n');
    fprintf('   1. Identificar una SERIE\n');
    fprintf('   4. Preparar Carpetas de Test\n\n');
    fprintf('   2. Salir\n');    % Input con manejo de errores
    while true
        try
            userInput = input('Selecciona opción (1, 2 o 4): ', 's');
            opcion = str2double(userInput);
            
            % Verificar si el input es un número válido (1, 2 o 4)
            if isnan(opcion) || ~ismember(opcion, [1, 2, 4])
                fprintf('\n%s\n', repmat('-', 1, 60));
                fprintf('               Opción no válida.\n');
                fprintf('       Por favor, selecciona 1, 2 o 4 únicamente.\n');
                fprintf('%s\n', repmat('-', 1, 60));
                continue;
            end
            break;
        catch
            fprintf('\n%s\n', repmat('-', 1, 60));
            fprintf('       Error en la entrada. Inténtalo nuevamente.\n');
            fprintf('%s\n', repmat('-', 1, 60));
        end
    end
    
    if opcion == 2
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('          Saliendo del programa. ¡Hasta pronto!\n');
        fprintf('%s\n', repmat('-', 1, 60));
        break;    
    elseif opcion == 1
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('                IDENTIFICACIÓN DE SERIE\n');
        fprintf('%s\n', repmat('-', 1, 60));
        
        % Cargar el modelo entrenado
        modeloPath = fullfile('trainedModels', modeloSeries);
        modeloVar = erase(basename(modeloSeries), '.mat');
        
        try
            tmp = load(modeloPath);
            modelo = tmp.(modeloVar);
        catch
            error('No se encuentra el modelo entrenado. Verifica que exista el archivo %s', modeloPath);
        end
        
        % Crear una figura para mostrar los botones de selección
        seleccionFig = figure('Name', 'Selección de entrada', 'NumberTitle', 'off', ...
                            'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 400 200]);
        
        % Crear los botones para seleccionar imagen o carpeta
        uicontrol('Style', 'pushbutton', 'String', 'Seleccionar Imagen', ...
                 'Position', [50 120 300 40], 'FontSize', 12, ...
                 'Callback', @(src, event) seleccionarImagen(src, seleccionFig, modelo, seriesNames, numBins));
          uicontrol('Style', 'pushbutton', 'String', 'Seleccionar Carpeta', ...
                 'Position', [50 60 300 40], 'FontSize', 12, ...
                 'Callback', @(src, event) seleccionarCarpeta(src, seleccionFig, modelo, seriesNames, numBins));
        
        % No continuar con el código hasta que se cierre la figura
        uiwait(seleccionFig);
          % La figura se cerrará automáticamente en las funciones callback
    elseif opcion == 4
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('            PREPARACIÓN DE CARPETAS DE TEST\n');
        fprintf('%s\n', repmat('-', 1, 60));
        
        prepararCarpetasTest(seriesNames);
    else
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('               Opción no válida.\n');
        fprintf('       Por favor, selecciona 1, 2 o 4 únicamente.\n');
        fprintf('%s\n', repmat('-', 1, 60));
    end
end

%% Función para procesar una sola imagen
function procesarImagen(imgPath, modelo, seriesNames, numBins)
    try
        fprintf('\n%s\n', repmat('*', 1, 60));
        fprintf('           ANALIZANDO IMAGEN: %s\n', basename(imgPath));
        fprintf('%s\n', repmat('*', 1, 60));
        
        img = imread(imgPath);
        
        % Normalizar por número de píxeles
        [alto, ancho, ~] = size(img);
        numPixeles = alto * ancho;
        vector = extraer_caracteristicas(img, numBins);
        Xtest = vector / numPixeles;
        
        % Predecir la serie
        if isfield(modelo, 'RequiredVariables')
            predictorNames = modelo.RequiredVariables;
            XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
            [yfit, ~] = modelo.predictFcn(XtestTable);
        else
            [yfit, ~] = modelo.predictFcn(Xtest);
        end
        
        % Mostrar resultado con formato mejorado
        prediccion = seriesNames{yfit};
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('          RESULTADO DEL ANÁLISIS\n');
        fprintf('%s\n', repmat('-', 1, 60));
        fprintf('\n  La imagen pertenece a la serie: ');
        fprintf('\n  >> %s <<\n\n', upper(prediccion));
        
        % Intentar determinar la serie real a partir de la ruta
        try
            [~, carpetaReal] = fileparts(fileparts(imgPath));
            % Ver si la carpeta coincide con alguna serie conocida
            idx = find(strcmpi(seriesNames, carpetaReal));
            if ~isempty(idx)
                esCorrecto = (yfit == idx);
                if esCorrecto
                    fprintf('  Predicción: CORRECTA ✓\n');
                else
                    fprintf('  Predicción: INCORRECTA ✗\n');
                    fprintf('  La serie real es: %s\n', carpetaReal);
                end
            end
        catch
            % No se pudo determinar la serie real
        end
        
        fprintf('\n%s\n', repmat('-', 1, 60));
    catch e
        fprintf('\n%s\n', repmat('!', 1, 60));
        fprintf('  Error al procesar la imagen: %s\n', e.message);
        fprintf('%s\n', repmat('!', 1, 60));
    end
end

%% Función para procesar una carpeta con imágenes de una serie
function procesarCarpetaSerie(carpetaPath, modelo, seriesNames, numBins, nombreCarpeta)
    archivos = dir(fullfile(carpetaPath, '*.jpg'));
    total = numel(archivos);
    
    if total == 0
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('       No se encontraron imágenes en la carpeta.\n');
        fprintf('%s\n', repmat('-', 1, 60));
        return;
    end
    
    fprintf('\n%s\n', repmat('*', 1, 60));
    fprintf('     PROCESANDO %d IMÁGENES DE LA CARPETA "%s"\n', total, nombreCarpeta);
    fprintf('%s\n', repmat('*', 1, 60));
    
    aciertos = 0;
    % Intentar encontrar la serie real basándose en el nombre de la carpeta
    serieRealIdx = 0;
    for i = 1:length(seriesNames)
        if strcmpi(seriesNames{i}, nombreCarpeta)
            serieRealIdx = i;
            break;
        end
    end
    
    % Crear una figura para mostrar el progreso visualmente
    progressFig = figure('Name', 'Progreso de procesamiento', 'NumberTitle', 'off', ...
                         'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 500 100]);
    
    % Crear una barra de progreso
    progressBar = uicontrol('Style', 'text', 'Position', [50 50 1 30], ...
                           'BackgroundColor', [0.8 0.9 0.8]);
    
    % Texto para mostrar el progreso
    progressText = uicontrol('Style', 'text', 'Position', [50 20 400 20], ...
                            'String', 'Iniciando procesamiento...');
    
    % Inicializar la tabla para imágenes mal clasificadas
    misclassifiedTable = cell(0, 3);
    
    drawnow;
    
    for j = 1:total
        imgPath = fullfile(archivos(j).folder, archivos(j).name);
        try
            img = imread(imgPath);
            
            % Normalizar por número de píxeles
            [alto, ancho, ~] = size(img);
            numPixeles = alto * ancho;
            vector = extraer_caracteristicas(img, numBins);
            Xtest = vector / numPixeles;
            
            % Predecir la serie
            if isfield(modelo, 'RequiredVariables')
                predictorNames = modelo.RequiredVariables;
                XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
                [yfit, ~] = modelo.predictFcn(XtestTable);
            else
                [yfit, ~] = modelo.predictFcn(Xtest);
            end
              % Si se conoce la serie real, comprobar si es correcta
            if serieRealIdx > 0
                esCorrecto = (yfit == serieRealIdx);
                if esCorrecto
                    aciertos = aciertos + 1;
                else
                    % Añadir a tabla de imágenes mal clasificadas
                    misclassifiedTable(end+1, :) = {
                        imgPath, ... % Ruta completa
                        seriesNames{yfit}, ... % Serie predicha
                        seriesNames{serieRealIdx} ... % Serie correcta
                    };
                end
            end
            
            % Actualizar barra de progreso
            progressPct = j / total;
            set(progressBar, 'Position', [50 50 floor(400 * progressPct) 30]);
            
            % Actualizar texto de progreso
            set(progressText, 'String', sprintf('Procesando: %d/%d (%.1f%%)', j, total, progressPct * 100));
            
            drawnow;
        catch e
            disp(['Error al procesar la imagen: ' imgPath]);
            disp(['Mensaje de error: ' e.message]);
        end
    end
      % Cerrar la figura de progreso
    if ishandle(progressFig)
        close(progressFig);
    end
    
    % Mostrar resultados con formato mejorado
    if serieRealIdx > 0
        porcentaje = 100 * aciertos / total;
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('          RESULTADOS PARA LA SERIE "%s"\n', nombreCarpeta);
        fprintf('%s\n', repmat('-', 1, 60));
        fprintf('\n  Aciertos: %d de %d (%.2f%%)\n\n', aciertos, total, porcentaje);        % Guardar tabla de imágenes mal clasificadas
        if ~isempty(misclassifiedTable)
            % Crear nombre del archivo
            nombreArchivo = fullfile('dataset', 'test', 'misclassified', [nombreCarpeta, '.mat']);
            
            % Guardar la tabla
            T_misclassified = misclassifiedTable;
            save(nombreArchivo, 'T_misclassified');
            fprintf('  Tabla de imágenes mal clasificadas guardada en: %s\n', nombreArchivo);
            fprintf('  Total de imágenes mal clasificadas: %d\n\n', size(misclassifiedTable, 1));
        end
    else
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('  No se pudo determinar la serie real a partir del nombre de la carpeta.\n');
        fprintf('  La carpeta "%s" no coincide con ninguna serie conocida.\n', nombreCarpeta);
        fprintf('%s\n', repmat('-', 1, 60));
    end
end

%% Función para procesar un dataset completo (carpetas para cada serie)
function procesarDatasetCompleto(datasetPath, modelo, seriesNames, numBins)
    fprintf('\n%s\n', repmat('*', 1, 60));
    fprintf('                PROCESANDO DATASET COMPLETO\n');
    fprintf('%s\n', repmat('*', 1, 60));
    
    totalImagenes = 0;
    totalAciertos = 0;
    resultadosPorSerie = zeros(length(seriesNames), 2); % [aciertos, total]
    
    % Inicializar tabla para imágenes mal clasificadas global
    misclassifiedTableGlobal = cell(0, 3);
    
    % Crear figura principal para mostrar el progreso global
    mainProgressFig = figure('Name', 'Progreso global', 'NumberTitle', 'off', ...
                            'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 500 150]);
    
    % Texto para el nombre de la serie actual
    serieLabel = uicontrol('Style', 'text', 'Position', [50 120 400 20], ...
                          'String', 'Iniciando procesamiento...', 'FontWeight', 'bold');
    
    % Barra de progreso para la serie actual
    currentProgressBar = uicontrol('Style', 'text', 'Position', [50 90 1 20], ...
                                  'BackgroundColor', [0.8 0.9 0.8]);
    
    % Texto para el progreso de la serie actual
    currentProgressText = uicontrol('Style', 'text', 'Position', [50 70 400 20], ...
                                   'String', 'Preparando...');
    
    % Barra de progreso global
    globalProgressBar = uicontrol('Style', 'text', 'Position', [50 40 1 20], ...
                                 'BackgroundColor', [0.8 0.8 0.9]);
    
    % Texto para el progreso global
    globalProgressText = uicontrol('Style', 'text', 'Position', [50 20 400 20], ...
                                  'String', 'Progreso total: 0%');
    
    drawnow;
    
    % Calcular el total de imágenes para tener una idea del progreso global
    totalImagenesTodas = 0;
    for i = 1:length(seriesNames)
        carpetaSerie = fullfile(datasetPath, seriesNames{i});
        if isfolder(carpetaSerie)
            archivos = dir(fullfile(carpetaSerie, '*.jpg'));
            totalImagenesTodas = totalImagenesTodas + numel(archivos);
        end
    end
    
    imagenesProcesadas = 0;
    
    % Procesar cada serie
    for i = 1:length(seriesNames)
        carpetaSerie = fullfile(datasetPath, seriesNames{i});
        
        % Verificar si existe la carpeta
        if ~isfolder(carpetaSerie)
            fprintf('\n  No se encontró la carpeta para la serie "%s"\n', seriesNames{i});
            continue;
        end
        
        % Actualizar etiqueta de serie
        set(serieLabel, 'String', ['Procesando serie: ' seriesNames{i}]);
        
        % Procesar imágenes de esta serie
        archivos = dir(fullfile(carpetaSerie, '*.jpg'));
        totalSerie = numel(archivos);
        
        if totalSerie == 0
            fprintf('\n  No se encontraron imágenes para la serie "%s"\n', seriesNames{i});
            continue;
        end
        
        aciertosSerie = 0;
        
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('    Procesando %d imágenes de la serie "%s"...\n', totalSerie, seriesNames{i});
        fprintf('%s\n', repmat('-', 1, 60));
        
        % Resetear barra de progreso de la serie actual
        set(currentProgressBar, 'Position', [50 90 1 20]);
        set(currentProgressText, 'String', 'Iniciando...');
        drawnow;
        
        for j = 1:totalSerie
            imgPath = fullfile(archivos(j).folder, archivos(j).name);
            try
                img = imread(imgPath);
                
                % Normalizar por número de píxeles
                [alto, ancho, ~] = size(img);
                numPixeles = alto * ancho;
                vector = extraer_caracteristicas(img, numBins);
                Xtest = vector / numPixeles;
                
                % Predecir la serie
                if isfield(modelo, 'RequiredVariables')
                    predictorNames = modelo.RequiredVariables;
                    XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
                    [yfit, ~] = modelo.predictFcn(XtestTable);
                else
                    [yfit, ~] = modelo.predictFcn(Xtest);
                end
                  % Comprobar si es correcta
                esCorrecto = (yfit == i);
                if esCorrecto
                    aciertosSerie = aciertosSerie + 1;
                    totalAciertos = totalAciertos + 1;
                else
                    % Añadir a tabla de imágenes mal clasificadas global
                    misclassifiedTableGlobal(end+1, :) = {
                        imgPath, ... % Ruta completa
                        seriesNames{yfit}, ... % Serie predicha
                        seriesNames{i} ... % Serie correcta
                    };
                end
                
                totalImagenes = totalImagenes + 1;
                imagenesProcesadas = imagenesProcesadas + 1;
                
                % Actualizar progreso de la serie actual
                progressSeriePct = j / totalSerie;
                set(currentProgressBar, 'Position', [50 90 floor(400 * progressSeriePct) 20]);
                set(currentProgressText, 'String', sprintf('Serie %s: %d/%d (%.1f%%)', ...
                    seriesNames{i}, j, totalSerie, progressSeriePct * 100));
                
                % Actualizar progreso global
                if totalImagenesTodas > 0
                    progressGlobalPct = imagenesProcesadas / totalImagenesTodas;
                    set(globalProgressBar, 'Position', [50 40 floor(400 * progressGlobalPct) 20]);
                    set(globalProgressText, 'String', sprintf('Progreso total: %.1f%% (%d/%d imágenes)', ...
                        progressGlobalPct * 100, imagenesProcesadas, totalImagenesTodas));
                end
                
                drawnow;
            catch e
                fprintf('\nError al procesar la imagen: %s - %s\n', imgPath, e.message);
            end
        end
        
        resultadosPorSerie(i, :) = [aciertosSerie, totalSerie];
        
        % Mostrar resultados de esta serie
        porcentajeSerie = 100 * aciertosSerie / totalSerie;
        fprintf('\n  Resultados para "%s": %d de %d (%.2f%%)\n', seriesNames{i}, aciertosSerie, totalSerie, porcentajeSerie);
    end
      % Cerrar la figura de progreso
    if ishandle(mainProgressFig)
        close(mainProgressFig);
    end
    
    % Mostrar resultados totales con formato mejorado
    if totalImagenes > 0
        porcentajeTotal = 100 * totalAciertos / totalImagenes;
        fprintf('\n%s\n', repmat('=', 1, 60));
        fprintf('               RESULTADOS FINALES DEL ANÁLISIS\n');
        fprintf('%s\n', repmat('=', 1, 60));
        fprintf('\n  Aciertos totales: %d de %d (%.2f%%)\n\n', totalAciertos, totalImagenes, porcentajeTotal);
        
        % Mostrar tabla de resultados por serie
        fprintf('  RESULTADOS DETALLADOS POR SERIE:\n\n');
        fprintf('  %-20s %10s %10s %10s\n', 'SERIE', 'ACIERTOS', 'TOTAL', 'PORCENTAJE');
        fprintf('  %-20s %10s %10s %10s\n', '-----------------', '--------', '-----', '----------');
        
        for i = 1:length(seriesNames)
            aciertos = resultadosPorSerie(i, 1);
            total = resultadosPorSerie(i, 2);
            
            if total > 0
                porcentaje = 100 * aciertos / total;
                fprintf('  %-20s %10d %10d %10.2f%%\n', seriesNames{i}, aciertos, total, porcentaje);
            end
        end        % Guardar tabla de imágenes mal clasificadas
        if ~isempty(misclassifiedTableGlobal)
            % Extraer el nombre de la carpeta principal
            [~, nombreCarpeta] = fileparts(datasetPath);
            % Crear nombre del archivo
            nombreArchivo = fullfile('dataset', 'test', 'misclassified', [nombreCarpeta, '.mat']);
            
            % Guardar la tabla
            T_misclassified = misclassifiedTableGlobal;
            save(nombreArchivo, 'T_misclassified');
            fprintf('\n  Tabla de imágenes mal clasificadas guardada en: %s\n', nombreArchivo);
            fprintf('  Total de imágenes mal clasificadas: %d\n', size(misclassifiedTableGlobal, 1));
        end
        
        fprintf('\n%s\n', repmat('-', 1, 60));
    else
        fprintf('\n%s\n', repmat('-', 1, 60));
        fprintf('          No se procesó ninguna imagen.\n');
        fprintf('%s\n', repmat('-', 1, 60));
    end
end

%% Función para manejar la selección de imagen
function seleccionarImagen(~, figHandle, modelo, seriesNames, numBins)
    % Usar la carpeta dataset como ubicación inicial
    rutaInicial = fullfile(pwd, 'dataset');
    
    % Verificar que la carpeta existe, sino usar pwd
    if ~exist(rutaInicial, 'dir')
        rutaInicial = pwd;
    end
    
    [file, path] = uigetfile({'*.jpg;*.jpeg;*.png', 'Imágenes (*.jpg, *.jpeg, *.png)'; ...
                             '*.*', 'Todos los archivos (*.*)'}, ...
                            'Selecciona una imagen', rutaInicial);
    
    % Si se seleccionó un archivo
    if ~isequal(file, 0)
        imgPath = fullfile(path, file);
        % Cerrar la figura para continuar con el procesamiento
        delete(figHandle);
        % Procesar la imagen
        procesarImagen(imgPath, modelo, seriesNames, numBins);
    else
        % No hacer nada, mantener la figura abierta
    end
end

%% Función para manejar la selección de carpeta
function seleccionarCarpeta(~, figHandle, modelo, seriesNames, numBins)
    % Usar la carpeta dataset como ubicación inicial
    rutaInicial = fullfile(pwd, 'dataset');
    
    % Verificar si la carpeta existe, de lo contrario usar pwd
    if ~exist(rutaInicial, 'dir')
        rutaInicial = pwd;
    end
    
    carpeta = uigetdir(rutaInicial, 'Selecciona una carpeta');
    
    % Si se seleccionó una carpeta
    if ~isequal(carpeta, 0)
        % Cerrar la figura para continuar con el procesamiento
        delete(figHandle);
        
        % Verificar si contiene subcarpetas
        contenido = dir(carpeta);
        contieneSubcarpetas = false;
        
        % Filtrar . y ..
        contenido = contenido(~ismember({contenido.name}, {'.', '..'}));
        
        % Buscar subcarpetas
        for i = 1:length(contenido)
            if contenido(i).isdir
                contieneSubcarpetas = true;
                break;
            end
        end
        
        if contieneSubcarpetas
            % Es una carpeta que contiene subcarpetas (dataset completo)
            procesarDatasetCompleto(carpeta, modelo, seriesNames, numBins);
        else
            % Es una carpeta sin subcarpetas (contiene imágenes de una serie)
            [~, nombreCarpeta] = fileparts(carpeta);
            procesarCarpetaSerie(carpeta, modelo, seriesNames, numBins, nombreCarpeta);
        end
    else
        % No hacer nada, mantener la figura abierta
    end
end

%% Función para preparar carpetas de test
function prepararCarpetasTest(seriesNames)
    % Ruta del archivo de datos
    datosPath = fullfile('out', 'series', 'T_entradasSeriesTest.mat');
    
    % Verificar si existe el archivo
    if ~exist(datosPath, 'file')
        fprintf('\n%s\n', repmat('!', 1, 60));
        fprintf('  Error: No se encuentra el archivo %s\n', datosPath);
        fprintf('  Asegúrate de ejecutar primero el script tabla_entradas.m para crear el archivo.\n');
        fprintf('%s\n', repmat('!', 1, 60));
        return;
    end
    
    % Cargar los datos
    try
        datos = load(datosPath);
        if ~isfield(datos, 'T_entradasSeriesTest')
            fprintf('\n%s\n', repmat('!', 1, 60));
            fprintf('  Error: El archivo no contiene la variable T_entradasSeriesTest\n');
            fprintf('%s\n', repmat('!', 1, 60));
            return;
        end
        tablaTest = datos.T_entradasSeriesTest;
        
        % Verificar y convertir la estructura según sea necesario
        if ~iscell(tablaTest)
            fprintf('Convirtiendo datos a formato compatible...\n');
            % Intentar convertir si no es una celda
            if istable(tablaTest)
                tablaTest = table2cell(tablaTest);
            end
        end
    catch e
        fprintf('\n%s\n', repmat('!', 1, 60));
        fprintf('  Error al cargar el archivo: %s\n', e.message);
        fprintf('%s\n', repmat('!', 1, 60));
        return;
    end      % Ruta base para las carpetas de test
    rutaBaseTest = fullfile('dataset', 'test', 'series');
    
    % Crear las carpetas de test
    carpetasCreadas = crearCarpetasTest(seriesNames, rutaBaseTest);
    
    % Si no se pudieron crear carpetas, salir
    if isempty(carpetasCreadas)
        fprintf('\n%s\n', repmat('!', 1, 60));
        fprintf('  Error: No se pudieron crear las carpetas de test\n');
        fprintf('%s\n', repmat('!', 1, 60));
        return;
    end
      % Examinar la estructura de los datos antes de procesarlos
    fprintf('\n%s\n', repmat('-', 1, 60));
    fprintf('  Analizando estructura de datos...\n');
    tamanoTabla = size(tablaTest);
    fprintf('  Tamaño de tabla: %d filas x %d columnas\n', tamanoTabla(1), tamanoTabla(2));
    
    if tamanoTabla(2) >= 3            % Verificar el tipo de datos y extraer índices de serie con seguridad
        try
            indices = [];
            % Comprobar si podemos extraer los índices directamente
            if iscell(tablaTest)
                % Intentar convertir la tercera columna a números
                for i = 1:tamanoTabla(1)
                    if ~isempty(tablaTest{i, 3})
                        if isnumeric(tablaTest{i, 3})
                            indices(end+1) = tablaTest{i, 3};
                        elseif ischar(tablaTest{i, 3}) || isstring(tablaTest{i, 3})
                            indices(end+1) = str2double(tablaTest{i, 3});
                        end
                    end
                end
            elseif istable(tablaTest)
                indices = table2array(tablaTest(:, 3));
            end
            
            % Filtrar valores no numéricos o NaN
            indices = indices(~isnan(indices));
            
            if ~isempty(indices)
                minIndice = min(indices);
                maxIndice = max(indices);
                fprintf('  Rango de índices de series: %d a %d\n', minIndice, maxIndice);
                
                if maxIndice > length(seriesNames)
                    fprintf('  Advertencia: Algunos índices (%d) exceden el número de series (%d)\n', maxIndice, length(seriesNames));
                    fprintf('  Se remapearán los índices fuera de rango\n');
                end
            else
                fprintf('  Info: Análisis preliminar de índices incompleto. Se validarán durante la copia.\n');
            end
        catch e
            fprintf('  Info: Se validarán los índices durante el proceso de copia.\n');
        end
    end
    fprintf('%s\n', repmat('-', 1, 60));
   
      % Copiar las imágenes de test
    try
        fprintf('Llamando a la función copiarImagenesTest...\n');
        [copiados, errores] = copiarImagenesTest(tablaTest, seriesNames, rutaBaseTest);
        fprintf('Función copiarImagenesTest completada correctamente.\n');
    catch e
        fprintf('Error al llamar a copiarImagenesTest: %s\n', e.message);
        if strcmp(e.identifier, 'MATLAB:UndefinedFunction')
            fprintf('La función copiarImagenesTest no se encuentra. Verificando path...\n');
            path_info = path;
            fprintf('Path actual: %s\n', path_info);
            
            % Intentar resolver el problema
            fprintf('Intentando añadir carpeta utils de nuevo...\n');
            addpath(fullfile(pwd, 'utils'));
            
            % Intentar cargar la función directamente
            try
                run(fullfile(pwd, 'utils', 'copiarImagenesTest.m'));
                fprintf('Función cargada. Intentando ejecutar de nuevo...\n');
                [copiados, errores] = copiarImagenesTest(tablaTest, seriesNames, rutaBaseTest);
            catch e2
                fprintf('Error al cargar o ejecutar la función manualmente: %s\n', e2.message);
                copiados = 0;
                errores = size(tablaTest, 1);
            end
        else
            copiados = 0;
            errores = size(tablaTest, 1);
        end
    end
      % Mostrar resumen
    fprintf('\n%s\n', repmat('-', 1, 60));
    fprintf('          RESUMEN DE LA PREPARACIÓN DE CARPETAS\n');
    fprintf('%s\n', repmat('-', 1, 60));
    fprintf('\n  Total de imágenes procesadas: %d\n', size(tablaTest, 1));
    fprintf('  Imágenes copiadas con éxito: %d\n', copiados);
    fprintf('  Errores encontrados: %d\n\n', errores);
    
    % Mostrar distribución de imágenes por serie
    mostrarDistribucionSeries(seriesNames, rutaBaseTest);
    
    fprintf('\n%s\n', repmat('-', 1, 60));
end
