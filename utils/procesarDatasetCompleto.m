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
    mainProgressFig = crearBarraProgreso('Progreso global', 500, 150);
    
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
        
        % Actualizar etiqueta de serie en la barra de progreso
        if isfield(mainProgressFig, 'serieLabel') && ishandle(mainProgressFig.serieLabel)
            set(mainProgressFig.serieLabel, 'String', ['Procesando serie: ' seriesNames{i}]);
        end
        
        % Procesar imágenes de esta serie
        archivos = dir(fullfile(carpetaSerie, '*.jpg'));
        totalSerie = numel(archivos);
        
        if totalSerie == 0
            fprintf('\n  No se encontraron imágenes para la serie "%s"\n', seriesNames{i});
            continue;
        end
        
        aciertosSerie = 0;
        
        mostrarEncabezado(['Procesando ' num2str(totalSerie) ' imágenes de la serie "' seriesNames{i} '"...'], '-');
        
        % Resetear barra de progreso de la serie actual
        if isfield(mainProgressFig, 'currentProgressBar') && ishandle(mainProgressFig.currentProgressBar)
            set(mainProgressFig.currentProgressBar, 'Position', [50 90 1 20]);
        end
        if isfield(mainProgressFig, 'currentProgressText') && ishandle(mainProgressFig.currentProgressText)
            set(mainProgressFig.currentProgressText, 'String', 'Iniciando...');
        end
        drawnow;
        
        for j = 1:totalSerie
            imgPath = fullfile(archivos(j).folder, archivos(j).name);
            try
                img = imread(imgPath);
                
                % Usar la función procesarPrediccionSerie para obtener la predicción
                resultados = procesarPrediccionSerie(img, modelo, numBins);
                yfit = resultados.prediccion;
                
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
                actualizarBarraProgreso(mainProgressFig, j, totalSerie, sprintf('Serie %s: %d/%d (%.1f%%)', ...
                    seriesNames{i}, j, totalSerie, progressSeriePct * 100), 'current');
                
                % Actualizar progreso global
                if totalImagenesTodas > 0
                    progressGlobalPct = imagenesProcesadas / totalImagenesTodas;
                    actualizarBarraProgreso(mainProgressFig, imagenesProcesadas, totalImagenesTodas, 
                        sprintf('Progreso total: %.1f%% (%d/%d imágenes)', ...
                        progressGlobalPct * 100, imagenesProcesadas, totalImagenesTodas), 'global');
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
        aciertos = resultadosPorSerie(i, 1);
        total = resultadosPorSerie(i, 2);
        
        if total > 0
            porcentaje = 100 * aciertos / total;
            fprintf('  %-20s %10d %10d %10.2f%%\n', seriesNames{i}, aciertos, total, porcentaje);
        end
    end
    
    % Guardar tabla de imágenes mal clasificadas
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
end
