imagenes_S = dir('.\datasetSeries\**\*.jpg');
numImagenes_S = numel(imagenes_S);

keySet_S = {'barrufets','Bob esponja','gat i gos','Gumball', 'hora de aventuras', 'Oliver y Benji', 'padre de familia', 'pokemon', 'southpark', 'Tom y Jerry'};
valueSet_S = 1:numel(keySet_S);
mapaSeries_S = containers.Map(keySet_S, valueSet_S);

tablaImagenes_S = [];
porcentajeTest = 0.3;

for i = 1:numImagenes_S
    carpeta = imagenes_S(i).folder;
    [~, nombreCarpeta] = fileparts(carpeta);
    esTest = rand() < porcentajeTest;
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

% Guardar el archivo en la carpeta "out"
save(fullfile(outFolder, 'tablaImagenesSeries.mat'),'tablaImagenes_S');