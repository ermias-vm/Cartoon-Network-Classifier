function resultados = procesarPrediccionSerie(img, modelo, numBins)
% PROCESARPREDICCIONSERIE Procesa una imagen y realiza la predicción de la serie
%
% Uso:
%   resultados = procesarPrediccionSerie(img, modelo, numBins)
%
% Parámetros:
%   img - Imagen a procesar
%   modelo - Modelo entrenado para la predicción
%   numBins - Número de bins para la extracción de características
%
% Salida:
%   resultados - Estructura con los resultados de la predicción
%     .prediccion - Índice de la serie predicha
%     .vector - Vector de características normalizado

    % Extraer características ya normalizadas por número de píxeles
    Xtest = extraer_caracteristicas_series(img, numBins);
    
    % Generar nombres de variables consistentes con el entrenamiento
    predictorNames = generarNombresVariables(numBins);
    
    % Crear tabla con los nombres correctos
    XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
      % Predecir la serie
    try
        % Intentar primero con la función predict del modelo
        if isfield(modelo, 'predictFcn')
            [yfit, scores] = modelo.predictFcn(XtestTable);
        elseif isfield(modelo, 'ClassificationSVM')
            % Usar el modelo SVM directamente
            yfit = predict(modelo.ClassificationSVM, Xtest);
            scores = [];
        else
            error('Modelo no válido o no compatible');
        end
    catch e
        % Como último recurso, intentar con el modelo SVM directamente
        try
            if isfield(modelo, 'ClassificationSVM')
                yfit = predict(modelo.ClassificationSVM, Xtest);
                scores = [];
            else
                error('No se pudo hacer la predicción: %s', e.message);
            end
        catch
            % Si todo falla, crear tabla con nombres por defecto
            XtestTable = array2table(Xtest);
            if isfield(modelo, 'predictFcn')
                [yfit, scores] = modelo.predictFcn(XtestTable);
            else
                error('Error al procesar la imagen: %s', e.message);
            end
        end
    end
    
    % Crear estructura de resultados
    resultados = struct();
    resultados.prediccion = yfit;
    resultados.vector = Xtest;
    if ~isempty(scores)
        resultados.scores = scores;
    end
end
