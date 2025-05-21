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

    % Normalizar por número de píxeles
    [alto, ancho, ~] = size(img);
    numPixeles = alto * ancho;
    vector = extraer_caracteristicas(img, numBins);
    Xtest = vector / numPixeles;
    
    % Predecir la serie
    if isfield(modelo, 'RequiredVariables')
        predictorNames = modelo.RequiredVariables;
        XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
        [yfit, scores] = modelo.predictFcn(XtestTable);
    else
        [yfit, scores] = modelo.predictFcn(Xtest);
    end
    
    % Crear estructura de resultados
    resultados = struct();
    resultados.prediccion = yfit;
    resultados.vector = Xtest;
    resultados.scores = scores;
end
