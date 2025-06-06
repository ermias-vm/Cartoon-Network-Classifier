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
while true
    fprintf('\n¿Qué quieres hacer?\n\n');
    fprintf('   1. Identificar una SERIE\n');
    fprintf('   2. Identificar PERSONAJES\n');
    fprintf('   3. Generar tablas: ENTRADAS y CARACTERISTICAS\n');
    fprintf('   4. Generar Carpetas de test\n');
    fprintf('   5. Salir\n\n');

    while true
        try
            userInput = input('Selecciona opción (1, 2, 3, 4 o 5): ', 's');
            opcion = str2double(userInput);
            
            % Verificar si el input es un número válido
            if isnan(opcion) || ~ismember(opcion, [1, 2, 3, 4, 5])
                mostrarEncabezado('Opción no válida.\nPor favor, selecciona 1, 2, 3, 4 o 5 únicamente.', '-');
                continue;
            end
            break;        catch
            mostrarEncabezado('Error en la entrada. Inténtalo nuevamente.', '-');
        end
    end
    
    if opcion == 5
        mostrarEncabezado('Saliendo del programa. ¡Hasta pronto!', '-');
        break;
    elseif opcion == 1
        % Identificación de series
        mostrarEncabezado('IDENTIFICACIÓN DE SERIE', '-');
        
        try
            % Cargar el modelo entrenado
            modelo = cargarModelo(modeloSeriesPath);            % Mostrar interfaz de selección
            seleccionarEntradaSerie(modelo, seriesNames, numBins);
        catch e
            fprintf('\n%s\n', repmat('!', 1, 60));
            fprintf('  Error al cargar el modelo de series: %s\n', e.message);
            fprintf('%s\n', repmat('!', 1, 60));
        end
    elseif opcion == 2
        % Identificación de personajes
        mostrarEncabezado('IDENTIFICACIÓN DE PERSONAJES', '-');
        
        % Ruta del modelo de personajes
        modeloPersonajesPath = fullfile('trainedModels', 'personajes', 'Peter Griffin', 'trainedModelPeter.mat');
        
        try
            % Cargar el modelo entrenado
            modelo = cargarModelo(modeloPersonajesPath);
            
            % Mostrar interfaz de selección
            seleccionarEntradaPersonaje(modelo);
        catch e
            fprintf('\n%s\n', repmat('!', 1, 60));
            fprintf('  Error al cargar el modelo de personajes: %s\n', e.message);
            fprintf('  \n');
            fprintf('  Posibles soluciones:\n');
            fprintf('  1. Asegúrate de que existe el archivo:\n');
            fprintf('     %s\n', modeloPersonajesPath);
            fprintf('  2. Genera las tablas de características desde el menú principal\n');
            fprintf('  3. Entrena el modelo usando Classification Learner de MATLAB\n');
            fprintf('%s\n', repmat('!', 1, 60));
        end
    elseif opcion == 4
        % Generar carpetas de test
        mostrarEncabezado('GENERACIÓN DE CARPETAS DE TEST', '-');
        
        while true
            fprintf('\n¿Qué quieres hacer?\n\n');
            fprintf('   1. Crear carpetas de test para SERIES\n');
            fprintf('   2. Crear carpetas de test para PERSONAJES\n');
            fprintf('   3. Volver al menú principal\n\n');
            
            while true
                try
                    userInputTest = input('Selecciona opción (1, 2 o 3): ', 's');
                    opcionTest = str2double(userInputTest);
                    
                    % Verificar si el input es un número válido
                    if isnan(opcionTest) || ~ismember(opcionTest, [1, 2, 3])
                        mostrarEncabezado('Opción no válida.\nPor favor, selecciona 1, 2 o 3 únicamente.', '-');
                        continue;
                    end
                    break;
                catch
                    mostrarEncabezado('Error en la entrada. Inténtalo nuevamente.', '-');
                end
            end
            
            if opcionTest == 3
                mostrarEncabezado('Volviendo al menú principal...', '-');
                break;
            elseif opcionTest == 1
                % Crear carpetas de test para series
                mostrarEncabezado('CREANDO CARPETAS DE TEST PARA SERIES', '-');
                prepararCarpetasTestSeries(seriesNames);
            elseif opcionTest == 2
                % Crear carpetas de test para personajes
                mostrarEncabezado('CREANDO CARPETAS DE TEST PARA PERSONAJES', '-');
                prepararCarpetasTestPersonajes();
            end
        end
    elseif opcion == 3
        % Submenu para generar tablas
        mostrarEncabezado('GESTIÓN DE DATOS Y CARACTERÍSTICAS', '-');
        
        while true
            fprintf('\n¿Qué quieres hacer?\n\n');
            fprintf('   1. Generar tabla de entradas series\n');
            fprintf('   2. Generar tabla de características series\n');
            fprintf('   3. Generar tabla de entradas personajes\n');
            fprintf('   4. Generar tabla de características personajes\n');
            fprintf('   5. Volver al menú principal\n\n');
            
            while true
                try
                    userInputSub = input('Selecciona opción (1, 2, 3, 4 o 5): ', 's');
                    opcionSub = str2double(userInputSub);
                    
                    % Verificar si el input es un número válido
                    if isnan(opcionSub) || ~ismember(opcionSub, [1, 2, 3, 4, 5])
                        mostrarEncabezado('Opción no válida.\nPor favor, selecciona 1, 2, 3, 4 o 5 únicamente.', '-');
                        continue;
                    end
                    break;                catch
                    mostrarEncabezado('Error en la entrada. Inténtalo nuevamente.', '-');
                end
            end
            
            if opcionSub == 5
                mostrarEncabezado('Volviendo al menú principal...', '-');
                break;
            elseif opcionSub == 1
                % Generar tabla de entradas series
                mostrarEncabezado('GENERANDO TABLA DE ENTRADAS SERIES', '-');
                tabla_entradas_series;            elseif opcionSub == 2
                % Generar tabla de características series
                mostrarEncabezado('GENERANDO TABLA DE CARACTERÍSTICAS SERIES', '-');
                tabla_caracteristicas_series;
            elseif opcionSub == 3
                % Generar tabla de entradas personajes
                mostrarEncabezado('GENERANDO TABLA DE ENTRADAS PERSONAJES', '-');
                tabla_entradas_personaje;
            elseif opcionSub == 4
                % Generar tabla de características personajes
                mostrarEncabezado('GENERANDO TABLA DE CARACTERÍSTICAS PERSONAJES', '-');
                tabla_caracteristicas_personaje;
            end
        end
    end
end
