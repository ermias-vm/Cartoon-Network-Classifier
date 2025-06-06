function procesarDatasetCompletoPersonajes(datasetPath, modelo)
% PROCESARDATASETCOMPLETOPERSONAJES Procesa un dataset completo de personajes
%
% Uso:
%   procesarDatasetCompletoPersonajes(datasetPath, modelo)
%
% Parámetros:
%   datasetPath - Ruta a la carpeta que contiene subcarpetas para cada personaje
%   modelo - Modelo entrenado para la predicción de personajes

    mostrarEncabezado('PROCESANDO DATASET COMPLETO DE PERSONAJES', '*');
    
    totalImagenes = 0;
    totalAciertos = 0;
    resultadosPorPersonaje = [];
    
    % Inicializar tabla para imágenes mal clasificadas global
    misclassifiedTableGlobal = cell(0, 3);
    
    % Buscar carpetas de personajes (actualmente solo Peter Griffin)
    carpetasPerson = dir(datasetPath);
    carpetasPerson = carpetasPerson([carpetasPerson.isdir]);
    carpetasPerson = carpetasPerson(~ismember({carpetasPerson.name}, {'.', '..'}));
    
    % Crear figura principal para mostrar el progreso global
    mainProgressFig = crearBarraProgreso('Progreso global personajes');
    
    % Calcular el total de imágenes para tener una idea del progreso global
    totalImagenesTodas = 0;
    personajesValidos = {};
    
    for i = 1:length(carpetasPerson)
        carpetaPersonaje = fullfile(datasetPath, carpetasPerson(i).name);
          % Verificar si tiene subcarpetas present/absent
        presentPath = fullfile(carpetaPersonaje, 'present');
        absentPath = fullfile(carpetaPersonaje, 'absent');
        
        if exist(presentPath, 'dir') || exist(absentPath, 'dir')
            personajesValidos{end+1} = carpetasPerson(i).name;
              % Contar imágenes
            if exist(presentPath, 'dir')
                archivos = dir(fullfile(presentPath, '*.jpg'));
                totalImagenesTodas = totalImagenesTodas + numel(archivos);
            end
            if exist(absentPath, 'dir')
                archivos = dir(fullfile(absentPath, '*.jpg'));
                totalImagenesTodas = totalImagenesTodas + numel(archivos);
            end
        end
    end
    
    imagenesProcesadas = 0;
    
    % Procesar cada personaje válido
    for i = 1:length(personajesValidos)
        nombrePersonaje = personajesValidos{i};
        carpetaPersonaje = fullfile(datasetPath, nombrePersonaje);
        
        presentPath = fullfile(carpetaPersonaje, 'present');
        ausentePath = fullfile(carpetaPersonaje, 'ausente');
        
        aciertosPerson = 0;
        totalPerson = 0;
        
        mostrarEncabezado(['Procesando personaje "' nombrePersonaje '"...'], '-');
        
        % Procesar imágenes presentes
        if exist(presentPath, 'dir')
            archivos = dir(fullfile(presentPath, '*.jpg'));
            for j = 1:numel(archivos)
                imgPath = fullfile(archivos(j).folder, archivos(j).name);
                try
                    img = imread(imgPath);
                    resultados = procesarPrediccionPersonaje(img, modelo);
                    
                    % Verificar si es correcta la predicción (presente = 1)
                    esCorrecto = (resultados.prediccion == 1);
                    if esCorrecto
                        aciertosPerson = aciertosPerson + 1;
                        totalAciertos = totalAciertos + 1;                    else
                        % Añadir a tabla de imágenes mal clasificadas
                        if resultados.prediccion == 1
                            prediccionTexto = 'presente';
                        else
                            prediccionTexto = 'ausente';
                        end
                        misclassifiedTableGlobal(end+1, :) = {
                            imgPath, ... % Ruta completa
                            prediccionTexto, ... % Predicción
                            'presente' ... % Etiqueta real
                        };
                    end
                    
                    totalPerson = totalPerson + 1;
                    totalImagenes = totalImagenes + 1;
                    imagenesProcesadas = imagenesProcesadas + 1;
                    
                    % Actualizar barra de progreso global
                    if totalImagenesTodas > 0
                        actualizarBarraProgreso(mainProgressFig, imagenesProcesadas, totalImagenesTodas);
                    end
                    
                catch e
                    fprintf('Error al procesar la imagen %s: %s\n', archivos(j).name, e.message);
                end
            end
        end
        
        % Procesar imágenes ausentes
        if exist(ausentePath, 'dir')
            archivos = dir(fullfile(ausentePath, '*.jpg'));
            for j = 1:numel(archivos)
                imgPath = fullfile(archivos(j).folder, archivos(j).name);
                try
                    img = imread(imgPath);
                    resultados = procesarPrediccionPersonaje(img, modelo);
                    
                    % Verificar si es correcta la predicción (ausente = 0)
                    esCorrecto = (resultados.prediccion == 0);
                    if esCorrecto
                        aciertosPerson = aciertosPerson + 1;
                        totalAciertos = totalAciertos + 1;
                    else
                        % Añadir a tabla de imágenes mal clasificadas
                        prediccionTexto = resultados.prediccion == 1 ? 'presente' : 'ausente';
                        misclassifiedTableGlobal(end+1, :) = {
                            imgPath, ... % Ruta completa
                            prediccionTexto, ... % Predicción
                            'ausente' ... % Etiqueta real
                        };
                    end
                    
                    totalPerson = totalPerson + 1;
                    totalImagenes = totalImagenes + 1;
                    imagenesProcesadas = imagenesProcesadas + 1;
                    
                    % Actualizar barra de progreso global
                    if totalImagenesTodas > 0
                        actualizarBarraProgreso(mainProgressFig, imagenesProcesadas, totalImagenesTodas);
                    end
                    
                catch e
                    fprintf('Error al procesar la imagen %s: %s\n', archivos(j).name, e.message);
                end
            end
        end
        
        % Guardar resultados de este personaje
        resultadosPorPersonaje(end+1, :) = [aciertosPerson, totalPerson];
        
        % Mostrar resultados parciales
        if totalPerson > 0
            porcentajePerson = 100 * aciertosPerson / totalPerson;
            fprintf('  Resultados para "%s": %d de %d (%.2f%%)\n', nombrePersonaje, aciertosPerson, totalPerson, porcentajePerson);
        end
    end
    
    % Cerrar la figura de progreso
    cerrarBarraProgreso(mainProgressFig);
    
    % Mostrar resultados totales con formato mejorado
    if totalImagenes > 0
        mostrarResultadosDatasetPersonajes(totalAciertos, totalImagenes, resultadosPorPersonaje, personajesValidos, misclassifiedTableGlobal, datasetPath);
    else
        mostrarEncabezado('No se procesó ninguna imagen de personajes.', '-');
    end
end

% Función auxiliar para mostrar los resultados del procesamiento del dataset de personajes
function mostrarResultadosDatasetPersonajes(totalAciertos, totalImagenes, resultadosPorPersonaje, personajesValidos, misclassifiedTableGlobal, datasetPath)
    porcentajeTotal = 100 * totalAciertos / totalImagenes;
    mostrarEncabezado('RESULTADOS FINALES DEL ANÁLISIS DE PERSONAJES', '=');
    fprintf('\n  Aciertos totales: %d de %d (%.2f%%)\n\n', totalAciertos, totalImagenes, porcentajeTotal);
    
    fprintf('\n%s\n', repmat('-', 1, 60));
    fprintf('RESULTADOS DETALLADOS POR PERSONAJE:\n');
    fprintf('%s\n', repmat('-', 1, 60));
    
    for i = 1:length(personajesValidos)
        if i <= size(resultadosPorPersonaje, 1)
            aciertos = resultadosPorPersonaje(i, 1);
            total = resultadosPorPersonaje(i, 2);
            if total > 0
                porcentaje = 100 * aciertos / total;
                fprintf('  %s: %d/%d (%.2f%%)\n', personajesValidos{i}, aciertos, total, porcentaje);
            end
        end
    end
    
    % Guardar tabla de imágenes mal clasificadas
    if ~isempty(misclassifiedTableGlobal)
        % Crear directorio si no existe
        dirMisclassified = fullfile('dataset', 'test', 'misclassified');
        if ~exist(dirMisclassified, 'dir')
            mkdir(dirMisclassified);
        end
        
        % Crear nombre del archivo
        nombreArchivo = fullfile(dirMisclassified, 'dataset_completo_personajes.mat');
        
        % Crear tabla con encabezados
        T_misclassified = cell(size(misclassifiedTableGlobal, 1) + 1, 3);
        T_misclassified(1, :) = {'Ubicacion', 'Predicho', 'Correcto'};
        T_misclassified(2:end, :) = misclassifiedTableGlobal;
        
        % Guardar la tabla
        save(nombreArchivo, 'T_misclassified');
        fprintf('\n  Tabla de imágenes mal clasificadas guardada en: %s\n', nombreArchivo);
        fprintf('  Total de imágenes mal clasificadas: %d\n', size(misclassifiedTableGlobal, 1));
    end
    
    fprintf('\n%s\n', repmat('=', 1, 60));
end
