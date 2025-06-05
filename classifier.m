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
    fullfile('dataset', 'test', 'series'),
    fullfile('dataset', 'test', 'misclassified')
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

% Mostrar menú principal
mostrarEncabezado('CARTOON NETWORK CLASSIFIER', '=');

% Interfaz de usuario
while true    fprintf('\n¿Qué quieres hacer?\n\n');
    fprintf('   1. Identificar una SERIE\n');
    fprintf('   2. Identificar PERSONAJES (No implementado)\n');
    fprintf('   3. Generar tablas: ENTRADAS y CARACTERISTICAS\n');
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
        % Opción no implementada
        mostrarEncabezado('FUNCIONALIDAD NO IMPLEMENTADA', '-');        fprintf('\nLa identificación de personajes ha sido removida de esta versión.\n');
        fprintf('Esta versión se enfoca únicamente en la clasificación de series.\n');
        fprintf('\nPresiona cualquier tecla para continuar...\n');
        pause;    elseif opcion == 3
        % Submenu para generar tablas
        mostrarEncabezado('GESTIÓN DE DATOS Y CARACTERÍSTICAS', '-');
        
        while true
            fprintf('\n¿Qué quieres hacer?\n\n');
            fprintf('   1. Generar tabla de entradas series\n');
            fprintf('   2. Generar tabla de características series\n');
            fprintf('   3. Volver al menú principal\n\n');
            
            while true
                try
                    userInputSub = input('Selecciona opción (1, 2 o 3): ', 's');
                    opcionSub = str2double(userInputSub);
                    
                    % Verificar si el input es un número válido
                    if isnan(opcionSub) || ~ismember(opcionSub, [1, 2, 3])
                        mostrarEncabezado('Opción no válida.\nPor favor, selecciona 1, 2 o 3 únicamente.', '-');
                        continue;
                    end
                    break;
                catch
                    mostrarEncabezado('Error en la entrada. Inténtalo nuevamente.', '-');
                end
            end
            
            if opcionSub == 3
                mostrarEncabezado('Volviendo al menú principal...', '-');
                break;
            elseif opcionSub == 1
                % Generar tabla de entradas series
                mostrarEncabezado('GENERANDO TABLA DE ENTRADAS SERIES', '-');
                tabla_entradas_series;
            elseif opcionSub == 2
                % Generar tabla de características series
                mostrarEncabezado('GENERANDO TABLA DE CARACTERÍSTICAS SERIES', '-');
                tabla_caracteristicas_series;
            end
        end
    end
end
