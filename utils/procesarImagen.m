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
        mostrarEncabezado('RESULTADO DEL ANÁLISIS', '-');
        fprintf('\n  La imagen pertenece a la serie: ');
        fprintf('\n  >> %s <<\n\n', upper(prediccion));
        
        % Intentar determinar la serie real a partir de la ruta
        try
            [~, carpetaReal] = fileparts(fileparts(imgPath));
            % Ver si la carpeta coincide con alguna serie conocida
            idx = find(strcmpi(seriesNames, carpetaReal));
            if ~isempty(idx)
                esCorrecto = (resultados.prediccion == idx);
                if esCorrecto
                    fprintf('  Predicción: CORRECTA ✓\n');
                else
                    fprintf('  Predicción: INCORRECTA ✗\n');
                    fprintf('  La serie real es: %s\n', carpetaReal);
                end
            end
        catch
            % No se pudo determinar la serie real
        end
        
        fprintf('\n%s\n', repmat('-', 1, 60));
    catch e
        mostrarEncabezado(['Error al procesar la imagen: ' e.message], '!');
    end
end
