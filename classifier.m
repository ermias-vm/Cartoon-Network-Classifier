clc; clear; close all;

keySet = {'barrufets','Bob esponja','gat i gos','Gumball', ...
    'hora de aventuras','Oliver y Benji','padre de familia', ...
    'pokemon','southpark','Tom y Jerry'};
seriesNames = keySet;
personajeNames = {}; % 

fprintf('¿Qué quieres hacer?\n');
fprintf('1. Identificar una SERIE dada una imagen\n');
fprintf('2. Identificar un PERSONAJE dada una imagen\n');
fprintf('3. Salir\n');
opcion = input('Selecciona opción (1, 2 o 3): ');

if opcion == 3
    fprintf('Saliendo del programa.\n');
    return;
elseif opcion ~= 1 && opcion ~= 2
    fprintf('Opción no válida.\n');
    return;
end

if opcion == 1
    fprintf('\nIdentificación de SERIE\n');
    modeloPath = fullfile('trainedModels', 'SeriesSVM974.mat');
    modeloVar = 'SeriesSVM974';
    nombres = seriesNames;
    datasetFolder = '.\datasetSeries';
elseif opcion == 2
    fprintf('\nIdentificación de PERSONAJE\n');
    modeloPath = fullfile('trainedModels', 'PersonajesSVM.mat');
    modeloVar = 'trainedModelPersonajes'; 
    nombres = personajeNames;
    datasetFolder = '.\datasetPersonajes'; 
end

fprintf('1. Imagen aleatoria del dataset\n');
fprintf('2. Seleccionar una imagen manualmente\n');
modo = input('Selecciona opción (1 o 2): ');

if modo == 1
    idxCarpeta = randi(numel(keySet));
    carpeta = keySet{idxCarpeta};
    archivos = dir(fullfile(datasetFolder, carpeta, '*.jpg'));
    idxArchivo = randi(numel(archivos));
    archivoSeleccionado = fullfile(archivos(idxArchivo).folder, archivos(idxArchivo).name);
    fprintf('Imagen seleccionada aleatoriamente: %s\n', archivoSeleccionado);
    imgPath = archivoSeleccionado;
elseif modo == 2
    [filename, pathname] = uigetfile({'*.jpg'}, 'Selecciona una imagen', datasetFolder);
    if isequal(filename,0)
        disp('No se seleccionó ninguna imagen.');
        return;
    end
    imgPath = fullfile(pathname, filename);
    fprintf('Imagen seleccionada manualmente: %s\n', imgPath);
else
    fprintf('Opción no válida.\n');
    return;
end

tmp = load(modeloPath);
modelo = tmp.(modeloVar);

load(fullfile('out', 'caracteristicas.mat')); % caracteristicas_norm

Xnorm = caracteristicas_norm(:,1:end-1);
minX = min(Xnorm);
maxX = max(Xnorm);

img = imread(imgPath);
numBins = 16;
vector = extraer_caracteristicas(img, numBins);

Xtest = (vector - minX) ./ (maxX - minX);

[yfit, scores] = modelo.predictFcn(Xtest);

if isempty(nombres)
    fprintf('Predicción: clase %d\n', yfit);
else
    fprintf('Predicción: %s\n', nombres{yfit});
end