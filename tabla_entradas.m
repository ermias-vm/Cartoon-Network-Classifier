imagenes_S = dir('.\datasetSeries\**\*.jpg');
numImagenes_S = numel(imagenes_S);

keySet_S = {'barrufets','Bob esponja','gat i gos','Gumball', ...
    'hora de aventuras','Oliver y Benji','padre de familia', ...
    'pokemon','southpark','Tom y Jerry'};
valueSet_S = 1:numel(keySet_S);
mapaSeries_S = containers.Map(keySet_S, valueSet_S);

tablaImagenes_S = [];
test_idx = false(numImagenes_S,1);

% Asignar 0 (entrenamiento) a 7 de cada 10 imágenes, 1 (test) a las 3 siguientes
for i = 1:numImagenes_S
    carpeta = imagenes_S(i).folder;
    [~, nombreCarpeta] = fileparts(carpeta);
    idx10 = mod(i-1,10) + 1;
    if idx10 <= 7
        esTest = 0; % entrenamiento
    else
        esTest = 1; % test
        test_idx(i) = true;
    end
    fila = [ string(imagenes_S(i).name), ...
             string(imagenes_S(i).folder), ...
             mapaSeries_S(nombreCarpeta), ...
             esTest ];
    tablaImagenes_S = [tablaImagenes_S; fila];
end

% Crear carpeta "out" 
outFolder = 'out';
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

% Calcular y mostrar el porcentaje de imágenes de entrenamiento
col4 = cellfun(@str2double, cellstr(tablaImagenes_S(:,4)));
numTrain = sum(col4 == 0);
porcTrain = 100 * numTrain / numImagenes_S;
fprintf('Porcentaje de imágenes de entrenamiento: %.2f%% (%d de %d)\n', porcTrain, numTrain, numImagenes_S);

% Generar tabla solo con las de test
tablaTest_S = tablaImagenes_S(col4 == 1, :);

% Guardar los archivos en la carpeta "out"
save(fullfile(outFolder, 'tablaImagenesSeries.mat'),'tablaImagenes_S')
save(fullfile(outFolder, 'tablaImagenesSeriesTest.mat'),'tablaTest_S')
