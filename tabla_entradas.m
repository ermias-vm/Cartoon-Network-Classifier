clc; clearvars; close all;
imagenes = dir('.\datasetSeries\**\*.jpg');
numImagenes = numel(imagenes);

keySet = {'barrufets','Bob esponja','gat i gos','Gumball', 'hora de aventuras', 'Oliver y Benji', 'padre de familia', 'pokemon', 'southpark', 'Tom y Jerry'};
valueSet = 1:numel(keySet);
mapaSeries = containers.Map(keySet, valueSet);

tablaImagenes = [];
porcentajeTest = 0.3;

for i = 1:numImagenes
    carpeta = imagenes(i).folder;
    [~, nombreCarpeta] = fileparts(carpeta);
    esTest = rand() < porcentajeTest;
    fila = [ string(imagenes(i).name), ...
             string(imagenes(i).folder), ...
             mapaSeries(nombreCarpeta), ...
             esTest ];
    tablaImagenes = [tablaImagenes; fila];
end

% Crear carpeta "out" 
outFolder = 'out';
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

% Guardar el archivo en la carpeta "out"
save(fullfile(outFolder, 'tablaImagenes.mat'),'tablaImagenes');