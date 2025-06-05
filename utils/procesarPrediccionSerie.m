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
        [yfit, scores] = modelo.predictFcn(XtestTable);
    catch e
        % Si falla con nombres generados, intentar con el modelo directamente
        if isfield(modelo, 'ClassificationSVM')
            % Usar el modelo SVM directamente
            yfit = predict(modelo.ClassificationSVM, Xtest);
            scores = [];
        else
            rethrow(e);
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
