% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));

%% SERIES
imagenes_S = dir('.\dataset\train\series\**\*.jpg');
numImagenes_S = numel(imagenes_S);

keySet_S = {'barrufets','Bob esponja','gat i gos','Gumball', ...
    'hora de aventuras','Oliver y Benji','padre de familia', ...
    'pokemon','southpark','Tom y Jerry'};
valueSet_S = 1:numel(keySet_S);
mapaSeries_S = containers.Map(keySet_S, valueSet_S);

T_entradasSeries = [];
test_idx_S = false(numImagenes_S,1);

% Asignar 0 (entrenamiento) a 7 de cada 10 imágenes, 1 (test) a las 3 siguientes
for i = 1:numImagenes_S
    carpeta = imagenes_S(i).folder;
    [~, nombreCarpeta] = fileparts(carpeta);
    idx10 = mod(i-1,10) + 1;
    if idx10 <= 7
        esTest = 0; % entrenamiento
    else
        esTest = 1; % test
        test_idx_S(i) = true;
    end
    fila = [ string(imagenes_S(i).name), ...
             string(imagenes_S(i).folder), ...
             mapaSeries_S(nombreCarpeta), ...
             esTest ];
    T_entradasSeries = [T_entradasSeries; fila];
end

% Crear carpetas necesarias
outFolder = fullfile('out');
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
outFolderSeries = fullfile(outFolder, 'series');
if ~exist(outFolderSeries, 'dir')
    mkdir(outFolderSeries);
end

% Calcular y mostrar el porcentaje de imágenes de entrenamiento
col4 = cellfun(@str2double, cellstr(T_entradasSeries(:,4)));
numTrain = sum(col4 == 0);
porcTrain = 100 * numTrain / numImagenes_S;
fprintf('Porcentaje de imágenes de entrenamiento (series): %.2f%% (%d de %d)\n', porcTrain, numTrain, numImagenes_S);

% Generar tabla solo con las de test
T_entradasSeriesTest = T_entradasSeries(col4 == 1, :);

% Guardar los archivos en la subcarpeta "series"
save(fullfile(outFolderSeries, 'T_entradasSeries.mat'),'T_entradasSeries')
save(fullfile(outFolderSeries, 'T_entradasSeriesTest.mat'),'T_entradasSeriesTest')

