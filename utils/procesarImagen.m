function procesarImagen(imgPath, modelo, seriesNames, numBins)
% PROCESARIMAGEN Procesa una sola imagen y muestra la predicción de la serie
%
% Uso:
%   procesarImagen(imgPath, modelo, seriesNames, numBins)
%
% Parámetros:
%   imgPath - Ruta de la imagen a procesar
%   modelo - Modelo entrenado para la predicción
%   seriesNames - Nombres de las series
%   numBins - Número de bins para la extracción de características

    try
        mostrarEncabezado(['ANALIZANDO IMAGEN: ' basename(imgPath)], '*');
        
        % Cargar y procesar la imagen
        img = imread(imgPath);
        resultados = procesarPrediccionSerie(img, modelo, numBins);
        
        % Mostrar resultado con formato mejorado
        prediccion = seriesNames{resultados.prediccion};
        mostrarEncabezado('RESULTADO DEL ANÁLISIS', '-');        fprintf('\n  La imagen pertenece a la serie: ');
        fprintf('\n  >> %s <<\n\n', upper(prediccion));
        
        % Intentar determinar la serie real a partir de la ruta
        esDeTest = false;
        try
            % Dividir la ruta en partes
            partesRuta = strsplit(imgPath, filesep);
            
            % Buscar si contiene 'test' y 'series'
            idxTest = find(strcmp(partesRuta, 'test'), 1);
            idxSeries = find(strcmp(partesRuta, 'series'), 1);
            
            if ~isempty(idxTest) && ~isempty(idxSeries) && idxTest < idxSeries
                % La imagen está en test/series/NombreSerie
                esDeTest = true;
                if idxSeries < length(partesRuta)
                    serieReal = partesRuta{idxSeries + 1};
                    
                    % Ver si la carpeta coincide con alguna serie conocida
                    idx = find(strcmpi(seriesNames, serieReal));
                    if ~isempty(idx)
                        esCorrecto = (resultados.prediccion == idx);
                        if esCorrecto
                            fprintf('  Predicción: CORRECTA ✓\n');
                            fprintf('  Serie real: %s\n', serieReal);
                        else
                            fprintf('  Predicción: INCORRECTA ✗\n');
                            fprintf('  Serie predicha: %s\n', prediccion);
                            fprintf('  Serie real: %s\n', serieReal);
                        end
                    end
                end
            end
        catch
            % No se pudo determinar la serie real
        end
        
        % Si no es de test, solo mostrar la predicción
        if ~esDeTest
            fprintf('  Imagen procesada desde ubicación externa\n');
        end
        
        fprintf('\n%s\n', repmat('-', 1, 60));
    catch e
        mostrarEncabezado(['Error al procesar la imagen: ' e.message], '!');
    end
end
