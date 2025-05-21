function resultados = procesarPrediccionPersonaje(img, modeloSeries, modeloPersonaje, numBins)
% PROCESARPREDICCIONPERSONAJE Procesa una imagen y realiza la predicción del personaje
%
% Uso:
%   resultados = procesarPrediccionPersonaje(img, modeloSeries, modeloPersonaje, numBins)
%
% Parámetros:
%   img - Imagen a procesar
%   modeloSeries - Modelo entrenado para la predicción de series
%   modeloPersonaje - Modelo entrenado para la predicción del personaje
%   numBins - Número de bins para la extracción de características
%
% Salida:
%   resultados - Estructura con los resultados de la predicción
%     .seriePredicha - Índice de la serie predicha
%     .personajePresente - 1 si el personaje está presente, 0 en caso contrario
%     .vector - Vector de características normalizado

    % Obtener resultados de la predicción de serie
    resultadosSerie = procesarPrediccionSerie(img, modeloSeries, numBins);
    
    % Predecir si el personaje está presente
    if isfield(modeloPersonaje, 'RequiredVariables')
        predictorNamesPersonaje = modeloPersonaje.RequiredVariables;
        XtestTablePersonaje = array2table(resultadosSerie.vector, 'VariableNames', predictorNamesPersonaje);
        [personajePresente, scores] = modeloPersonaje.predictFcn(XtestTablePersonaje);
    else
        [personajePresente, scores] = modeloPersonaje.predictFcn(resultadosSerie.vector);
    end
    
    % Crear estructura de resultados
    resultados = struct();
    resultados.seriePredicha = resultadosSerie.prediccion;
    resultados.personajePresente = personajePresente;
    resultados.vector = resultadosSerie.vector;
    resultados.scores = scores;
end
