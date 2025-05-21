function procesarImagenPersonaje(imgPath, modeloSeries, seriesNames, personajesNames, numBins)
% PROCESARIMAGENPERSONAJE Procesa una imagen para la detección de personajes
%
% Uso:
%   procesarImagenPersonaje(imgPath, modeloSeries, seriesNames, personajesNames, numBins)
%
% Parámetros:
%   imgPath - Ruta de la imagen a procesar
%   modeloSeries - Modelo entrenado para la predicción de series
%   seriesNames - Nombres de las series
%   personajesNames - Nombres de los personajes
%   numBins - Número de bins para la extracción de características

    try
        mostrarEncabezado(['ANALIZANDO IMAGEN PARA PERSONAJE: ' basename(imgPath)], '*');
        
        img = imread(imgPath);
        
        % Normalizar por número de píxeles para el modelo de series
        [alto, ancho, ~] = size(img);
        numPixeles = alto * ancho;
        vector = extraer_caracteristicas(img, numBins);
        Xtest = vector / numPixeles;
        
        % Predecir la serie primero
        if isfield(modeloSeries, 'RequiredVariables')
            predictorNames = modeloSeries.RequiredVariables;
            XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
            [serieIdx, ~] = modeloSeries.predictFcn(XtestTable);
        else
            [serieIdx, ~] = modeloSeries.predictFcn(Xtest);
        end
        
        % Obtener el nombre de la serie y personaje correspondiente
        seriePredecida = seriesNames{serieIdx};
        personajeSerie = personajesNames{serieIdx};
                
        mostrarEncabezado(['SERIE DETECTADA: ' upper(seriePredecida) '\nBUSCANDO PERSONAJE: ' upper(personajeSerie)], '-');
        
        % Cargar el modelo del personaje correspondiente a la serie
        modeloPersonajePath = fullfile('trainedModels', 'personajes', personajeSerie, ['trainedModel' personajeSerie '.mat']);
        
        % Verificar si existe el modelo del personaje
        if exist(modeloPersonajePath, 'file')
            try
                % Cargar el modelo del personaje
                modeloPersonaje = cargarModelo(modeloPersonajePath);
                
                % Predecir si el personaje está presente en la imagen
                if isfield(modeloPersonaje, 'RequiredVariables')
                    predictorNamesPersonaje = modeloPersonaje.RequiredVariables;
                    XtestTablePersonaje = array2table(Xtest, 'VariableNames', predictorNamesPersonaje);
                    [personajePresente, ~] = modeloPersonaje.predictFcn(XtestTablePersonaje);
                else
                    [personajePresente, ~] = modeloPersonaje.predictFcn(Xtest);
                end
                
                % Mostrar resultado con formato mejorado
                mostrarEncabezado('RESULTADO DEL ANÁLISIS DE PERSONAJE', '-');
                
                % Interpretar el resultado según el modelo (puede variar dependiendo del modelo)
                if personajePresente == 1
                    fprintf('\n  PERSONAJE DETECTADO: ');
                    fprintf('\n  >> %s <<\n\n', upper(personajeSerie));
                else
                    fprintf('\n  El personaje %s NO ha sido detectado en la imagen.\n\n', upper(personajeSerie));
                end
                
                fprintf('\n%s\n', repmat('-', 1, 60));
            catch e
                fprintf('\n%s\n', repmat('!', 1, 60));
                fprintf('  Error al cargar o usar el modelo del personaje: %s\n', e.message);
                fprintf('%s\n', repmat('!', 1, 60));
            end
        else
            fprintf('\n%s\n', repmat('!', 1, 60));
            fprintf('  No se encontró el modelo para el personaje %s\n', personajeSerie);
            fprintf('  Ruta esperada: %s\n', modeloPersonajePath);
            fprintf('%s\n', repmat('!', 1, 60));
        end
    catch e
        fprintf('\n%s\n', repmat('!', 1, 60));
        fprintf('  Error al procesar la imagen: %s\n', e.message);
        fprintf('%s\n', repmat('!', 1, 60));
    end
end
