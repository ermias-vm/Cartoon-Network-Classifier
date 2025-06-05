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
    % Determinar si estamos procesando una carpeta de test
    esDeTest = false;
    serieRealIdx = 0;
    
    % Dividir la ruta en partes para determinar si es de test
    partesRuta = strsplit(carpetaPath, filesep);
    idxTest = find(strcmp(partesRuta, 'test'), 1);
    idxSeries = find(strcmp(partesRuta, 'series'), 1);
    
    if ~isempty(idxTest) && ~isempty(idxSeries) && idxTest < idxSeries
        % Es una carpeta de test/series/NombreSerie
        esDeTest = true;
        % Buscar la serie real basándose en el nombre de la carpeta
        for i = 1:length(seriesNames)
            if strcmpi(seriesNames{i}, nombreCarpeta)
                serieRealIdx = i;
                break;
            end
        end
    end
    
    % Crear barra de progreso
    progressFig = crearBarraProgreso('Progreso de procesamiento');
    
    % Inicializar la tabla para imágenes mal clasificadas
    misclassifiedTable = cell(0, 3);
    
    for j = 1:total
        imgPath = fullfile(archivos(j).folder, archivos(j).name);
        try
            img = imread(imgPath);
            resultados = procesarPrediccionSerie(img, modelo, numBins);
            
            % Si es de test, comprobar si es correcta la predicción
            if esDeTest && serieRealIdx > 0
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
            actualizarBarraProgreso(progressFig, j, total);
            
        catch e
            fprintf('Error al procesar la imagen %s: %s\n', archivos(j).name, e.message);
        end
    end
    
    % Cerrar la barra de progreso
    cerrarBarraProgreso(progressFig);
    
    % Mostrar resultados con formato mejorado
    if esDeTest && serieRealIdx > 0
        porcentaje = 100 * aciertos / total;
        mostrarEncabezado(['RESULTADOS PARA LA SERIE "' nombreCarpeta '"'], '-');
        fprintf('\n  Aciertos: %d de %d (%.2f%%)\n\n', aciertos, total, porcentaje);
          % Guardar tabla de imágenes mal clasificadas si existe la carpeta
        if ~isempty(misclassifiedTable)
            % Crear directorio si no existe
            dirMisclassified = fullfile('dataset', 'test', 'misclassified');
            if ~exist(dirMisclassified, 'dir')
                mkdir(dirMisclassified);
            end
            
            % Crear nombre del archivo
            nombreArchivo = fullfile(dirMisclassified, [nombreCarpeta, '.mat']);
            
            % Crear tabla con encabezados
            T_misclassified = cell(size(misclassifiedTable, 1) + 1, 3);
            T_misclassified(1, :) = {'Ubicacion', 'Predicho', 'Correcto'};
            T_misclassified(2:end, :) = misclassifiedTable;
            
            % Guardar la tabla
            save(nombreArchivo, 'T_misclassified');
            fprintf('  Tabla de imágenes mal clasificadas guardada en: %s\n', nombreArchivo);
            fprintf('  Total de imágenes mal clasificadas: %d\n\n', size(misclassifiedTable, 1));
        end
    elseif esDeTest
        mostrarEncabezado(['No se pudo determinar la serie real para "' nombreCarpeta '"'], '-');
        fprintf('\n  La carpeta no coincide con ninguna serie conocida.\n\n');
    else
        mostrarEncabezado(['PROCESAMIENTO COMPLETADO PARA "' nombreCarpeta '"'], '-');
        fprintf('\n  Se procesaron %d imágenes de la carpeta externa.\n', total);
        fprintf('  Solo se muestra la predicción (no hay verificación de exactitud).\n\n');
    end
end
