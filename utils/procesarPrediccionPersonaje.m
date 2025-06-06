function resultados = procesarPrediccionPersonaje(img, modelo)
% PROCESARPREDICCIONPERSONAJE Procesa una imagen y realiza la predicción de personaje
%
% Uso:
%   resultados = procesarPrediccionPersonaje(img, modelo)
%
% Parámetros:
%   img - Imagen a procesar
%   modelo - Modelo entrenado para la predicción de personajes
%
% Salida:
%   resultados - Estructura con los resultados de la predicción
%     .prediccion - Predicción binaria (1=presente, 0=ausente)
%     .vector - Vector de características HOG normalizado

    % Extraer características HOG para personajes
    Xtest = extraer_caracteristicas_personaje(img);
    
    % Predecir presencia del personaje
    try
        % Intentar primero con la función predict del modelo
        if isfield(modelo, 'predictFcn')
            % Crear tabla con nombres consistentes
            numFeatures = length(Xtest);
            predictorNames = cell(1, numFeatures);
            for i = 1:numFeatures
                predictorNames{i} = sprintf('HOG_feature_%d', i);
            end
            XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
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
