%% CLASIFICADOR DE SERIES DE DIBUJOS ANIMADOS DE CARTOON NETWORK
% Este programa identifica series de dibujos animados a partir de imágenes
% utilizando modelos entrenados previamente.

% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));

% Verificar y crear estructura de carpetas
carpetas = {
    'dataset',
    fullfile('dataset', 'train'),
    fullfile('dataset', 'test'),
    fullfile('dataset', 'train', 'series'),
    fullfile('dataset', 'train', 'personajes'),
    fullfile('dataset', 'test', 'series'),
    fullfile('dataset', 'test', 'misclassified'),
    fullfile('dataset', 'test', 'personajes')
};

% Crear toda la estructura de directorios necesaria
crearEstructuraCarpetas(carpetas, true);

% Parámetros
modeloSeriesPath = fullfile('trainedModels', 'series', 'trainedModelSeries.mat');
numBins = 20;

% Nombres de las series
seriesNames = {'barrufets','Bob esponja','gat i gos','Gumball', ...
    'hora de aventuras','Oliver y Benji','padre de familia', ...
    'pokemon','southpark','Tom y Jerry'};

% Nombres de los personajes correspondientes a cada serie
personajesNames = {'gran_barrufet', 'Bob_esponja', 'gat_i_gos', 'Gumball', ...
    'Finn', 'Oliver', 'Peter_Griffin', ...
    'Ash_Ketchum', 'Cartman', 'Tom'};

% Mostrar menú principal
mostrarEncabezado('CARTOON NETWORK CLASSIFIER', '=');

% Interfaz de usuario
while true
    fprintf('\n¿Qué quieres hacer?\n\n');
    fprintf('   1. Identificar una SERIE\n');
    fprintf('   2. Identificar PERSONAJES\n');
    fprintf('   3. Preparar Carpetas de Test\n');
    fprintf('   4. Salir\n\n');

    % Obtener opción del usuario
    opcion = obtenerOpcionValida([1, 2, 3, 4]);
    
    if opcion == 4
        mostrarEncabezado('Saliendo del programa. ¡Hasta pronto!', '-');
        break;
    elseif opcion == 1
        procesarOpcionSerie(seriesNames, modeloSeriesPath, numBins);
    elseif opcion == 2
        procesarOpcionPersonaje(seriesNames, personajesNames, modeloSeriesPath, numBins);
    elseif opcion == 3
        prepararCarpetasTest(seriesNames);
    end
end

%% Funciones auxiliares

function opcion = obtenerOpcionValida(opcionesValidas)
% Función para obtener una opción válida del usuario
    while true
        try
            userInput = input('Selecciona opción (' + join(string(opcionesValidas), ', ') + '): ', 's');
            opcion = str2double(userInput);
            
            % Verificar si el input es una opción válida
            if isnan(opcion) || ~ismember(opcion, opcionesValidas)
                mostrarEncabezado('Opción no válida. Por favor, selecciona una opción válida.', '-');
                continue;
            end
            break;
        catch
            mostrarEncabezado('Error en la entrada. Inténtalo nuevamente.', '-');
        end
    end
end

function procesarOpcionSerie(seriesNames, modeloSeriesPath, numBins)
% Función para procesar la opción de identificar series
    mostrarEncabezado('IDENTIFICACIÓN DE SERIE', '-');
    
    % Cargar el modelo entrenado
    try
        modelo = cargarModelo(modeloSeriesPath);
        
        % Crear interfaz de selección
        callbacks = struct();
        callbacks.imagen = @(src, event) seleccionarImagenCallback(src, seriesNames, modelo, numBins);
        callbacks.carpeta = @(src, event) seleccionarCarpetaCallback(src, seriesNames, modelo, numBins);
        
        [seleccionFig, ~] = crearInterfazSeleccion('Selección de entrada', callbacks);
        
        % No continuar con el código hasta que se cierre la figura
        uiwait(seleccionFig);
    catch e
        fprintf('\nError al cargar el modelo: %s\n', e.message);
    end
end

function procesarOpcionPersonaje(seriesNames, personajesNames, modeloSeriesPath, numBins)
% Función para procesar la opción de identificar personajes
    mostrarEncabezado('IDENTIFICACIÓN DE PERSONAJES', '-');
    
    % Cargar el modelo de series
    try
        modeloSeries = cargarModelo(modeloSeriesPath);
        
        % Crear interfaz de selección
        callbacks = struct();
        callbacks.imagen = @(src, event) seleccionarImagenPersonajeCallback(src, seriesNames, personajesNames, modeloSeries, numBins);
        callbacks.carpeta = @(src, event) seleccionarCarpetaPersonajeCallback(src, seriesNames, personajesNames, modeloSeries, numBins);
        
        [seleccionFig, ~] = crearInterfazSeleccion('Selección de entrada para Personajes', callbacks);
        
        % No continuar con el código hasta que se cierre la figura
        uiwait(seleccionFig);
    catch e
        fprintf('\nError al cargar el modelo de series: %s\n', e.message);
    end
end

function seleccionarImagenCallback(src, seriesNames, modelo, numBins)
% Callback para el botón de seleccionar imagen (series)
    figHandle = ancestor(src, 'figure');
    rutaInicial = fullfile(pwd, 'dataset');
    imgPath = seleccionarArchivo('imagen', rutaInicial);
    
    if ~isempty(imgPath)
        % Cerrar la figura
        delete(figHandle);
        % Procesar la imagen
        procesarImagen(imgPath, modelo, seriesNames, numBins);
    end
end

function seleccionarCarpetaCallback(src, seriesNames, modelo, numBins)
% Callback para el botón de seleccionar carpeta (series)
    figHandle = ancestor(src, 'figure');
    rutaInicial = fullfile(pwd, 'dataset');
    carpetaPath = seleccionarArchivo('carpeta', rutaInicial);
    
    if ~isempty(carpetaPath)
        % Cerrar la figura
        delete(figHandle);
        
        % Verificar si contiene subcarpetas
        contenido = dir(carpetaPath);
        contenido = contenido(~ismember({contenido.name}, {'.', '..'}));
        
        contieneSubcarpetas = false;
        for i = 1:length(contenido)
            if contenido(i).isdir
                contieneSubcarpetas = true;
                break;
            end
        end
        
        if contieneSubcarpetas
            % Es una carpeta que contiene subcarpetas (dataset completo)
            procesarDatasetCompleto(carpetaPath, modelo, seriesNames, numBins);
        else
            % Es una carpeta sin subcarpetas (contiene imágenes de una serie)
            [~, nombreCarpeta] = fileparts(carpetaPath);
            procesarCarpetaSerie(carpetaPath, modelo, seriesNames, numBins, nombreCarpeta);
        end
    end
end

function seleccionarImagenPersonajeCallback(src, seriesNames, personajesNames, modeloSeries, numBins)
% Callback para el botón de seleccionar imagen (personajes)
    figHandle = ancestor(src, 'figure');
    rutaInicial = fullfile(pwd, 'dataset');
    imgPath = seleccionarArchivo('imagen', rutaInicial);
    
    if ~isempty(imgPath)
        % Cerrar la figura
        delete(figHandle);
        % Procesar la imagen para personajes
        procesarImagenPersonaje(imgPath, modeloSeries, seriesNames, personajesNames, numBins);
    end
end

function seleccionarCarpetaPersonajeCallback(src, seriesNames, personajesNames, modeloSeries, numBins)
% Callback para el botón de seleccionar carpeta (personajes)
    figHandle = ancestor(src, 'figure');
    rutaInicial = fullfile(pwd, 'dataset');
    carpetaPath = seleccionarArchivo('carpeta', rutaInicial);
    
    if ~isempty(carpetaPath)
        % Cerrar la figura
        delete(figHandle);
        
        % Verificar si contiene subcarpetas
        contenido = dir(carpetaPath);
        contenido = contenido(~ismember({contenido.name}, {'.', '..'}));
        
        contieneSubcarpetas = false;
        for i = 1:length(contenido)
            if contenido(i).isdir
                contieneSubcarpetas = true;
                break;
            end
        end
        
        if contieneSubcarpetas
            % Es una carpeta que contiene subcarpetas (dataset completo)
            mostrarEncabezado('Procesamiento de carpetas múltiples para personajes no implementado.\nPor favor, selecciona una carpeta que contenga solo imágenes.', '!');
        else
            % Es una carpeta sin subcarpetas (contiene imágenes)
            [~, nombreCarpeta] = fileparts(carpetaPath);
            procesarCarpetaPersonaje(carpetaPath, modeloSeries, seriesNames, personajesNames, numBins, nombreCarpeta);
        end
    end
end
