function prepararCarpetasTestSeries(seriesNames)
% PREPARARCARPETASTESTSERIES Copia imágenes de test a carpetas de series
%
% Uso:
%   prepararCarpetasTestSeries(seriesNames)
%
% Parámetros:
%   seriesNames - Nombres de las series

    fprintf('\n=== COPIANDO IMÁGENES DE TEST PARA SERIES ===\n\n');
    
    % Verificar archivo de test
    archivoTest = fullfile('out', 'series', 'T_entradasSeriesTest.mat');
    if ~exist(archivoTest, 'file')
        fprintf('ERROR: No se encontró %s\n', archivoTest);
        fprintf('Ejecuta primero la generación de tablas de entrada.\n');
        return;
    end
    
    % Cargar datos de test
    load(archivoTest, 'T_entradasSeriesTest');
    
    % Ruta de destino
    rutaDestino = fullfile('dataset', 'test', 'series');
    
    % Crear carpetas de destino
    for i = 1:length(seriesNames)
        carpetaDestino = fullfile(rutaDestino, seriesNames{i});
        if ~exist(carpetaDestino, 'dir')
            mkdir(carpetaDestino);
        end
    end
    
    % Copiar imágenes
    copiados = 0;
    errores = 0;
    total = size(T_entradasSeriesTest, 1);
    
    fprintf('Copiando %d imágenes...\n\n', total);
    
    for i = 1:total
        try
            nombreImg = T_entradasSeriesTest{i, 1};
            rutaOrigen = T_entradasSeriesTest{i, 2};
            etiquetaSerie = str2double(T_entradasSeriesTest{i, 3});
            
            nombreSerie = seriesNames{etiquetaSerie};
            archivoOrigen = fullfile(rutaOrigen, nombreImg);
            archivoDestino = fullfile(rutaDestino, nombreSerie, nombreImg);
            
            if exist(archivoOrigen, 'file')
                copyfile(archivoOrigen, archivoDestino);
                copiados = copiados + 1;
            else
                errores = errores + 1;
            end
            
        catch
            errores = errores + 1;
        end
    end
    
    fprintf('Resultado:\n');
    fprintf('  Copiadas: %d\n', copiados);
    fprintf('  Errores: %d\n', errores);
    fprintf('  Total: %d\n\n', total);
end
