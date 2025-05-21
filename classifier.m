%% CLASIFICADOR DE SERIES DE DIBUJOS ANIMADOS DE CARTOON NETWORK
% Este programa identifica series de dibujos animados a partir de imágenes
% utilizando modelos entrenados previamente.
%
% Esta versión utiliza funciones modularizadas para mejorar la legibilidad
% y mantenibilidad del código.

% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));
disp(['Añadida carpeta utils: ', fullfile(pwd, 'utils')]);

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

% Carga el modelo de series
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

    while true
        try
            userInput = input('Selecciona opción (1, 2, 3 o 4): ', 's');
            opcion = str2double(userInput);
            
            % Verificar si el input es un número válido
            if isnan(opcion) || ~ismember(opcion, [1, 2, 3, 4])
                mostrarEncabezado('Opción no válida.\nPor favor, selecciona 1, 2, 3 o 4 únicamente.', '-');
                continue;
            end
            break;
        catch
            mostrarEncabezado('Error en la entrada. Inténtalo nuevamente.', '-');
        end
    end
    
    if opcion == 4
        mostrarEncabezado('Saliendo del programa. ¡Hasta pronto!', '-');
        break;
    elseif opcion == 1
        % Identificación de series
        mostrarEncabezado('IDENTIFICACIÓN DE SERIE', '-');
        
        try
            % Cargar el modelo entrenado
            modelo = cargarModelo(modeloSeriesPath);
            
            % Mostrar interfaz de selección
            seleccionarEntradaSerie(modelo, seriesNames, numBins);
        catch e
            fprintf('\n%s\n', repmat('!', 1, 60));
            fprintf('  Error al cargar el modelo de series: %s\n', e.message);
            fprintf('%s\n', repmat('!', 1, 60));
        end
    elseif opcion == 2
        % Identificación de personajes
        mostrarEncabezado('IDENTIFICACIÓN DE PERSONAJES', '-');
        
        try
            % Cargar el modelo de series
            modeloSeries = cargarModelo(modeloSeriesPath);
            
            % Mostrar interfaz de selección para personajes
            seleccionarEntradaPersonaje(modeloSeries, seriesNames, personajesNames, numBins);
        catch e
            fprintf('\n%s\n', repmat('!', 1, 60));
            fprintf('  Error al cargar el modelo de series: %s\n', e.message);
            fprintf('%s\n', repmat('!', 1, 60));
        end
    elseif opcion == 3
        % Preparación de carpetas de test
        mostrarEncabezado('PREPARACIÓN DE CARPETAS DE TEST', '-');
        prepararCarpetasTest(seriesNames);
    end
end
