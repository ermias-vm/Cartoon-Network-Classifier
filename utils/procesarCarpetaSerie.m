function procesarCarpetaSerie(carpetaPath, modelo, seriesNames, numBins, nombreCarpeta)
% PROCESARCARPETASERIE Procesa una carpeta con imágenes de una serie
%
% Uso:
%   procesarCarpetaSerie(carpetaPath, modelo, seriesNames, numBins, nombreCarpeta)
%
% Parámetros:
%   carpetaPath - Ruta de la carpeta a procesar
%   modelo - Modelo entrenado para la predicción
%   seriesNames - Nombres de las series
%   numBins - Número de bins para la extracción de características
%   nombreCarpeta - Nombre de la carpeta para mostrar en resultados

    archivos = dir(fullfile(carpetaPath, '*.jpg'));
    total = numel(archivos);
    
    if total == 0
        mostrarEncabezado('No se encontraron imágenes en la carpeta.', '-');
        return;
    end
    
    mostrarEncabezado(['PROCESANDO ' num2str(total) ' IMÁGENES DE LA CARPETA "' nombreCarpeta '"'], '*');
    
    aciertos = 0;
    % Intentar encontrar la serie real basándose en el nombre de la carpeta
    serieRealIdx = 0;
    for i = 1:length(seriesNames)
        if strcmpi(seriesNames{i}, nombreCarpeta)
            serieRealIdx = i;
            break;
        end
    end
    
    % Crear barra de progreso
    [progressBar, progressText] = crearBarraProgreso('Progreso de procesamiento');
    
    % Inicializar la tabla para imágenes mal clasificadas
    misclassifiedTable = cell(0, 3);
    
    for j = 1:total
        imgPath = fullfile(archivos(j).folder, archivos(j).name);
        try
            img = imread(imgPath);
            resultados = procesarPrediccionSerie(img, modelo, numBins);
            
            % Si se conoce la serie real, comprobar si es correcta
            if serieRealIdx > 0
                esCorrecto = (resultados.prediccion == serieRealIdx);
                if esCorrecto
                    aciertos = aciertos + 1;
                else
                    % Añadir a tabla de imágenes mal clasificadas
                    misclassifiedTable(end+1, :) = {
                        imgPath, ... % Ruta completa
                        seriesNames{resultados.prediccion}, ... % Serie predicha
                        seriesNames{serieRealIdx} ... % Serie correcta
                    };
                end
            end
            
            % Actualizar barra de progreso
            actualizarBarraProgreso(progressBar, progressText, j, total);
            
        catch e
            fprintf('Error al procesar la imagen %s: %s\n', imgPath, e.message);
        end
    end
    
    % Cerrar la barra de progreso
    cerrarBarraProgreso(progressBar);
    
    % Mostrar resultados con formato mejorado
    if serieRealIdx > 0
        porcentaje = 100 * aciertos / total;
        mostrarEncabezado(['RESULTADOS PARA LA SERIE "' nombreCarpeta '"'], '-');
        fprintf('\n  Aciertos: %d de %d (%.2f%%)\n\n', aciertos, total, porcentaje);
        
        % Guardar tabla de imágenes mal clasificadas
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
        mostrarEncabezado(['No se pudo determinar la serie real a partir del nombre de la carpeta.\nLa carpeta "' nombreCarpeta '" no coincide con ninguna serie conocida.'], '-');
    end
end
