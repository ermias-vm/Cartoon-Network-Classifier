function procesarDatasetCompleto(datasetPath, modelo, seriesNames, numBins)
% PROCESARDATASETCOMPLETO Procesa un dataset completo con subcarpetas para cada serie
%
% Uso:
%   procesarDatasetCompleto(datasetPath, modelo, seriesNames, numBins)
%
% Parámetros:
%   datasetPath - Ruta a la carpeta que contiene subcarpetas para cada serie
%   modelo - Modelo entrenado para la predicción
%   seriesNames - Nombres de las series
%   numBins - Número de bins para la extracción de características

    mostrarEncabezado('PROCESANDO DATASET COMPLETO', '*');
    
    totalImagenes = 0;
    totalAciertos = 0;
    resultadosPorSerie = zeros(length(seriesNames), 2); % [aciertos, total]
    
    % Inicializar tabla para imágenes mal clasificadas global
    misclassifiedTableGlobal = cell(0, 3);
    
    % Crear figura principal para mostrar el progreso global
    mainProgressFig = crearBarraProgreso('Progreso global');
    
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
            continue;
        end
        
        % Procesar imágenes de esta serie
        archivos = dir(fullfile(carpetaSerie, '*.jpg'));
        totalSerie = numel(archivos);
        
        if totalSerie == 0
            continue;
        end
        
        aciertosSerie = 0;
        
        mostrarEncabezado(['Procesando ' num2str(totalSerie) ' imágenes de la serie "' seriesNames{i} '"...'], '-');
        
        % Procesar cada imagen de la serie
        for j = 1:totalSerie
            imgPath = fullfile(archivos(j).folder, archivos(j).name);
            try
                img = imread(imgPath);
                resultados = procesarPrediccionSerie(img, modelo, numBins);
                
                % Verificar si es correcta la predicción
                esCorrecto = (resultados.prediccion == i);
                if esCorrecto
                    aciertosSerie = aciertosSerie + 1;
                    totalAciertos = totalAciertos + 1;
                else
                    % Añadir a tabla de imágenes mal clasificadas
                    misclassifiedTableGlobal(end+1, :) = {
                        imgPath, ... % Ruta completa
                        seriesNames{resultados.prediccion}, ... % Serie predicha
                        seriesNames{i} ... % Serie correcta
                    };
                end
                
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
        
        % Guardar resultados de esta serie
        resultadosPorSerie(i, 1) = aciertosSerie;
        resultadosPorSerie(i, 2) = totalSerie;
        
        % Mostrar resultados parciales
        porcentajeSerie = 100 * aciertosSerie / totalSerie;
        fprintf('  Resultados para "%s": %d de %d (%.2f%%)\n', seriesNames{i}, aciertosSerie, totalSerie, porcentajeSerie);
    end
    
    % Cerrar la figura de progreso
    cerrarBarraProgreso(mainProgressFig);
    
    % Mostrar resultados totales con formato mejorado
    if totalImagenes > 0
        mostrarResultadosDataset(totalAciertos, totalImagenes, resultadosPorSerie, seriesNames, misclassifiedTableGlobal, datasetPath);
    else
        mostrarEncabezado('No se procesó ninguna imagen.', '-');
    end
end

% Función auxiliar para mostrar los resultados del procesamiento del dataset
function mostrarResultadosDataset(totalAciertos, totalImagenes, resultadosPorSerie, seriesNames, misclassifiedTableGlobal, datasetPath)
    porcentajeTotal = 100 * totalAciertos / totalImagenes;
    mostrarEncabezado('RESULTADOS FINALES DEL ANÁLISIS', '=');
    fprintf('\n  Aciertos totales: %d de %d (%.2f%%)\n\n', totalAciertos, totalImagenes, porcentajeTotal);
    
    % Mostrar tabla de resultados por serie
    fprintf('  RESULTADOS DETALLADOS POR SERIE:\n\n');
    fprintf('  %-20s %10s %10s %10s\n', 'SERIE', 'ACIERTOS', 'TOTAL', 'PORCENTAJE');
    fprintf('  %-20s %10s %10s %10s\n', '-----------------', '--------', '-----', '----------');
    
    for i = 1:length(seriesNames)
        if resultadosPorSerie(i, 2) > 0
            porcentaje = 100 * resultadosPorSerie(i, 1) / resultadosPorSerie(i, 2);
            fprintf('  %-20s %10d %10d %9.2f%%\n', seriesNames{i}, resultadosPorSerie(i, 1), resultadosPorSerie(i, 2), porcentaje);
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
        nombreArchivo = fullfile(dirMisclassified, 'dataset_completo.mat');
        
        % Crear tabla con encabezados
        T_misclassified = cell(size(misclassifiedTableGlobal, 1) + 1, 3);
        T_misclassified(1, :) = {'Ubicacion', 'Predicho', 'Correcto'};
        T_misclassified(2:end, :) = misclassifiedTableGlobal;
        
        % Guardar la tabla
        save(nombreArchivo, 'T_misclassified');
        fprintf('\n  Tabla de imágenes mal clasificadas guardada en: %s\n', nombreArchivo);
        fprintf('  Total de imágenes mal clasificadas: %d\n', size(misclassifiedTableGlobal, 1));
    end
    
    fprintf('\n%s\n', repmat('-', 1, 60));
end
