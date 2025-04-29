modeloSeries = 'SeriesSVM957.mat';
modeloPersonajes = 'PersonajesSVM969.mat';
numBins = 20;

keySet_S = {'barrufets','Bob esponja','gat i gos','Gumball', ...
    'hora de aventuras','Oliver y Benji','padre de familia', ...
    'pokemon','southpark','Tom y Jerry'};
seriesNames = keySet_S;

keySet_P = {'Ash Ketchum','Bob esponja','Cartman','finn', ...
    'gat i gos','gran barrufet','Gumball', ...
    'Oliver','Peter Griffin','Tom'};
personajeNames = keySet_P;

% Cargar minXseries y maxXseries 
minXseries = load(fullfile('out','minXseries.mat')); minXseries = minXseries.minXseries;
maxXseries = load(fullfile('out','maxXseries.mat')); maxXseries = maxXseries.maxXseries;
minXpersonajes = load(fullfile('out','minXpersonajes.mat')); minXpersonajes = minXpersonajes.minXpersonajes;
maxXpersonajes = load(fullfile('out','maxXpersonajes.mat')); maxXpersonajes = maxXpersonajes.maxXpersonajes;

while true
    fprintf('\n¿Qué quieres hacer?\n');
    fprintf('1. Identificar una SERIE dada una imagen\n');
    fprintf('2. Identificar un PERSONAJE dada una imagen\n');
    fprintf('3. Test Detección de Series\n');
    fprintf('4. Test Detección de Personajes\n');
    fprintf('5. Generar tabla de entradas y tabla de características\n');
    fprintf('6. Salir\n');
    opcion = input('Selecciona opción (1, 2, 3, 4, 5 o 6): ');

    if opcion == 6
        fprintf('Saliendo del programa.\n');
        break;
    elseif opcion == 5
        fprintf('\nGenerando tabla de entradas y tabla de características...\n');
        run('tabla_entradas.m');
        run('tabla_caracteristicas.m');
        fprintf('Tablas generadas correctamente.\n');
        continue;
    elseif opcion == 3
        fprintf('\nTest Detección de Series\n');
        fprintf('Selecciona la carpeta a testear:\n');
        for idxSerie = 1:numel(seriesNames)
            fprintf('%d. %s\n', idxSerie, seriesNames{idxSerie});
        end
        idxSeleccion = input('Introduce el número de la carpeta: ');
        if idxSeleccion < 1 || idxSeleccion > numel(seriesNames)
            fprintf('Selección no válida.\n');
            continue;
        end
        carpeta = seriesNames{idxSeleccion};
        modeloPath = fullfile('trainedModels', modeloSeries);
        modeloVar = erase(modeloSeries, '.mat');
        nombres = seriesNames;
        datasetFolder = '.\datasetSeries';
        caracteristicasFile = fullfile('out', 'caracteristicasSeries.mat');
        tmp = load(modeloPath);
        modelo = tmp.(modeloVar);

        try
            datos = load(caracteristicasFile);
            caracteristicas_norm = datos.caracteristicas_norm_S;
            minX = minXseries;
            maxX = maxXseries;
        catch
            error('No se encuentra el archivo de características. Genera primero la tabla de características (opción 5).');
        end

        archivos = dir(fullfile(datasetFolder, carpeta, '*.jpg'));
        total = numel(archivos);
        aciertos = 0;

        for j = 1:total
            imgPath = fullfile(archivos(j).folder, archivos(j).name);
            img = imread(imgPath);
            vector = extraer_caracteristicas(img, numBins);
            Xtest = (vector - minX) ./ (maxX - minX);

            % Compatibilidad con modelos que esperan tabla
            if isfield(modelo, 'RequiredVariables')
                predictorNames = modelo.RequiredVariables;
                XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
                [yfit, ~] = modelo.predictFcn(XtestTable);
            else
                [yfit, ~] = modelo.predictFcn(Xtest);
            end

            esCorrecto = (yfit == idxSeleccion);
            if esCorrecto
                aciertos = aciertos + 1;
            end

            fprintf('Progreso: %d/%d\n', j, total);
        end

        porcentaje = 100 * aciertos / total;
        fprintf('\nResultados del test de detección de series para "%s":\n', carpeta);
        fprintf('Aciertos: %d de %d (%.2f%%)\n\n', aciertos, total, porcentaje);
        continue;
    elseif opcion == 4
        fprintf('\nTest Detección de Personajes\n');
        fprintf('Selecciona la carpeta a testear:\n');
        for idxPers = 1:numel(personajeNames)
            fprintf('%d. %s\n', idxPers, personajeNames{idxPers});
        end
        idxSeleccion = input('Introduce el número de la carpeta: ');
        if idxSeleccion < 1 || idxSeleccion > numel(personajeNames)
            fprintf('Selección no válida.\n');
            continue;
        end
        carpeta = personajeNames{idxSeleccion};
        modeloPath = fullfile('trainedModels', modeloPersonajes);
        modeloVar = erase(modeloPersonajes, '.mat');
        nombres = personajeNames;
        datasetFolder = '.\datasetPersonajes\Implementados';
        caracteristicasFile = fullfile('out', 'caracteristicasPersonajes.mat');
        minX = minXpersonajes;
        maxX = maxXpersonajes;

        tmp = load(modeloPath);
        modelo = tmp.(modeloVar);

        try
            datos = load(caracteristicasFile);
            caracteristicas_norm = datos.caracteristicas_norm_P;
        catch
            error('No se encuentra el archivo de características. Genera primero la tabla de características (opción 5).');
        end

        archivos = dir(fullfile(datasetFolder, carpeta, '*.jpg'));
        total = numel(archivos);
        aciertos = 0;

        for j = 1:total
            imgPath = fullfile(archivos(j).folder, archivos(j).name);
            img = imread(imgPath);
            vector = extraer_caracteristicas(img, numBins);
            Xtest = (vector - minX) ./ (maxX - minX);

            if isfield(modelo, 'RequiredVariables')
                predictorNames = modelo.RequiredVariables;
                XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
                [yfit, ~] = modelo.predictFcn(XtestTable);
            else
                [yfit, ~] = modelo.predictFcn(Xtest);
            end

            esCorrecto = (yfit == idxSeleccion);
            if esCorrecto
                aciertos = aciertos + 1;
            end

            fprintf('Progreso: %d/%d\n', j, total);
        end

        porcentaje = 100 * aciertos / total;
        fprintf('\nResultados del test de detección de personajes para "%s":\n', carpeta);
        fprintf('Aciertos: %d de %d (%.2f%%)\n\n', aciertos, total, porcentaje);
        continue;
    elseif opcion ~= 1 && opcion ~= 2
        fprintf('Opción no válida.\n');
        continue;
    end

    if opcion == 1
        fprintf('\nIdentificación de SERIE\n');
        modeloPath = fullfile('trainedModels', modeloSeries);
        modeloVar = erase(modeloSeries, '.mat');
        nombres = seriesNames;
        datasetFolder = '.\datasetSeries';
        caracteristicasFile = fullfile('out', 'caracteristicasSeries.mat');
        minX = minXseries;
        maxX = maxXseries;
    elseif opcion == 2
        fprintf('\nIdentificación de PERSONAJE\n');
        modeloPath = fullfile('trainedModels', modeloPersonajes);
        modeloVar = erase(modeloPersonajes, '.mat');
        nombres = personajeNames;
        datasetFolder = '.\datasetPersonajes\Implementados';
        caracteristicasFile = fullfile('out', 'caracteristicasPersonajes.mat');
        minX = minXpersonajes;
        maxX = maxXpersonajes;
    end

    fprintf('1. Imagen aleatoria del dataset\n');
    fprintf('2. Seleccionar una imagen manualmente\n');
    modo = input('Selecciona opción (1 o 2): ');

    if modo == 1
        idxCarpeta = randi(numel(keySet_S));
        carpeta = keySet_S{idxCarpeta};
        archivos = dir(fullfile(datasetFolder, carpeta, '*.jpg'));
        idxArchivo = randi(numel(archivos));
        archivoSeleccionado = fullfile(archivos(idxArchivo).folder, archivos(idxArchivo).name);
        fprintf('Imagen seleccionada aleatoriamente: %s\n', archivoSeleccionado);
        imgPath = archivoSeleccionado;
    elseif modo == 2
        [filename, pathname] = uigetfile({'*.jpg'}, 'Selecciona una imagen', datasetFolder);
        if isequal(filename,0)
            disp('No se seleccionó ninguna imagen.');
            continue;
        end
        imgPath = fullfile(pathname, filename);
        fprintf('Imagen seleccionada manualmente: %s\n', imgPath);
    else
        fprintf('Opción no válida.\n');
        continue;
    end

    tmp = load(modeloPath);
    modelo = tmp.(modeloVar);

    try
        datos = load(caracteristicasFile); % caracteristicas_norm_S o caracteristicas_norm_P
        if opcion == 1
            caracteristicas_norm = datos.caracteristicas_norm_S;
           
        else
            caracteristicas_norm = datos.caracteristicas_norm_P;
    
        end
    catch
        error('No se encuentra el archivo de características. Genera primero la tabla de características (opción 5).');
    end

    img = imread(imgPath);
    vector = extraer_caracteristicas(img, numBins);
    Xtest = (vector - minX) ./ (maxX - minX);

    % Compatibilidad con modelos que esperan tabla
    if isfield(modelo, 'RequiredVariables')
        predictorNames = modelo.RequiredVariables;
        XtestTable = array2table(Xtest, 'VariableNames', predictorNames);
        [yfit, scores] = modelo.predictFcn(XtestTable);
    else
        [yfit, scores] = modelo.predictFcn(Xtest);
    end

    if isempty(nombres)
        fprintf('Predicción: clase %d\n\n', yfit);
    else
        [~, carpetaReal] = fileparts(fileparts(imgPath)); % Carpeta real de la imagen
        prediccion = nombres{yfit};

        esCorrecto = strcmpi(carpetaReal, prediccion);

        if esCorrecto
            fprintf('Predicción: %s (true)\n\n', prediccion);
        else
            fprintf('Predicción: %s (false)\n', prediccion);
            fprintf('  (La carpeta real es: %s)\n\n', carpetaReal);
        end
    end
end