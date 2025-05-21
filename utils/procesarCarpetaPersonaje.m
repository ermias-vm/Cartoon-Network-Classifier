function procesarCarpetaPersonaje(carpetaPath, modeloSeries, seriesNames, personajesNames, numBins, nombreCarpeta)
% PROCESARCARPETAPERSONAJE Procesa una carpeta con imágenes para la detección de personajes
%
% Uso:
%   procesarCarpetaPersonaje(carpetaPath, modeloSeries, seriesNames, personajesNames, numBins, nombreCarpeta)
%
% Parámetros:
%   carpetaPath - Ruta de la carpeta a procesar
%   modeloSeries - Modelo entrenado para la predicción de series
%   seriesNames - Nombres de las series
%   personajesNames - Nombres de los personajes
%   numBins - Número de bins para la extracción de características
%   nombreCarpeta - Nombre de la carpeta para mostrar en resultados

    archivos = dir(fullfile(carpetaPath, '*.jpg'));
    total = numel(archivos);
    
    if total == 0
        mostrarEncabezado('No se encontraron imágenes en la carpeta.', '-');
        return;
    end
    
    mostrarEncabezado(['PROCESANDO ' num2str(total) ' IMÁGENES DE LA CARPETA "' nombreCarpeta '" PARA PERSONAJES'], '*');
    
    % Crear una figura para mostrar el progreso visualmente
    progressFig = crearBarraProgreso('Progreso de procesamiento de personajes', 600, 150);
    
    % Contadores para cada serie y personaje
    resultadosPorSerie = zeros(length(seriesNames), 3); % [detecciones_serie, detecciones_personaje, total_serie]
    
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
            if isfield(modeloSeries, 'RequiredVariables')
                predictorNames = modeloSeries.RequiredVariables;
                XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
                [serieIdx, ~] = modeloSeries.predictFcn(XtestTable);
            else
                [serieIdx, ~] = modeloSeries.predictFcn(Xtest);
            end
            
            % Incrementar contador de detección de serie
            resultadosPorSerie(serieIdx, 1) = resultadosPorSerie(serieIdx, 1) + 1;
            
            % Obtener el personaje correspondiente a la serie
            personajeSerie = personajesNames{serieIdx};
            
            % Cargar el modelo del personaje
            modeloPersonajePath = fullfile('trainedModels', 'personajes', personajeSerie, ['trainedModel' personajeSerie '.mat']);
            
            % Verificar si existe el modelo del personaje
            if exist(modeloPersonajePath, 'file')
                % Cargar el modelo del personaje
                modeloPersonaje = cargarModelo(modeloPersonajePath);
                
                % Predecir si el personaje está presente
                if isfield(modeloPersonaje, 'RequiredVariables')
                    predictorNamesPersonaje = modeloPersonaje.RequiredVariables;
                    XtestTablePersonaje = array2table(Xtest, 'VariableNames', predictorNamesPersonaje);
                    [personajePresente, ~] = modeloPersonaje.predictFcn(XtestTablePersonaje);
                else
                    [personajePresente, ~] = modeloPersonaje.predictFcn(Xtest);
                end
                
                % Si se detectó el personaje, incrementar contador
                if personajePresente == 1
                    resultadosPorSerie(serieIdx, 2) = resultadosPorSerie(serieIdx, 2) + 1;
                end
            else
                % Si es la primera detección de esta serie, mostrar mensaje sobre modelo faltante
                if j == 1 || (resultadosPorSerie(serieIdx, 1) == 1)
                    fprintf('  Nota: No se encontró el modelo para el personaje %s\n', personajeSerie);
                    fprintf('  Ruta esperada: %s\n', modeloPersonajePath);
                end
            end
            
            % Actualizar barra de progreso
            actualizarBarraProgreso(progressFig, j, total, sprintf('Procesando: %d/%d (%.1f%%)', j, total, j/total*100));
            
            % Construir y actualizar tabla de resultados
            tableStr = '';
            for i = 1:length(seriesNames)
                if resultadosPorSerie(i, 1) > 0
                    pctSerie = 100 * resultadosPorSerie(i, 1) / total;
                    pctPersonaje = 100 * resultadosPorSerie(i, 2) / resultadosPorSerie(i, 1);
                    tableStr = [tableStr, sprintf('%s: %d/%d (%.1f%%) - %s: %d/%d (%.1f%%)\n', ...
                        seriesNames{i}, resultadosPorSerie(i, 1), total, pctSerie, ...
                        personajesNames{i}, resultadosPorSerie(i, 2), resultadosPorSerie(i, 1), pctPersonaje)];
                end
            end
            
            % Actualizar tabla de resultados si hay un control para ello
            if isfield(progressFig, 'resultTable') && ishandle(progressFig.resultTable)
                set(progressFig.resultTable, 'String', tableStr);
            end
            
            drawnow;
        catch e
            disp(['Error al procesar la imagen: ' imgPath]);
            disp(['Mensaje de error: ' e.message]);
        end
    end
    
    % Cerrar la figura de progreso
    cerrarBarraProgreso(progressFig);
    
    % Mostrar resultados finales
    mostrarEncabezado('RESULTADOS DE DETECCIÓN DE PERSONAJES', '-');
    fprintf('\n  Total de imágenes procesadas: %d\n\n', total);
    
    % Tabla de resultados
    fprintf('  %-20s %-30s %-30s\n', 'SERIE', 'DETECCIÓN SERIE', 'DETECCIÓN PERSONAJE');
    fprintf('  %-20s %-30s %-30s\n', '-----------------', '--------------------', '----------------------');
    
    for i = 1:length(seriesNames)
        if resultadosPorSerie(i, 1) > 0
            pctSerie = 100 * resultadosPorSerie(i, 1) / total;
            pctPersonaje = 100 * resultadosPorSerie(i, 2) / resultadosPorSerie(i, 1);
            
            fprintf('  %-20s %4d/%-6d (%6.2f%%) %15d/%-6d (%6.2f%%)\n', ...
                seriesNames{i}, resultadosPorSerie(i, 1), total, pctSerie, ...
                resultadosPorSerie(i, 2), resultadosPorSerie(i, 1), pctPersonaje);
        end
    end
    
    fprintf('\n%s\n', repmat('-', 1, 60));
end
