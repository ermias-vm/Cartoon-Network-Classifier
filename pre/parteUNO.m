%% PROJECTE FINAL
clc; clear; close all;

%% 1) Parámetros y listado de imágenes
srcDir    = pwd;  % directorio base
files     = dir(fullfile(srcDir,'**','*.jpg'));
ratioTest = 0.3;
seriesNames = {'barrufets','Bob esponja','gat i gos','Gumball',...    
    'hora de aventuras','Oliver y Benji','padre de familia',...    
    'pokemon','southpark','Tom y Jerry'};
serieHash   = containers.Map(seriesNames,1:numel(seriesNames));

% Generar tabla de metadatos
n = numel(files);
tbl = table('Size',[n,4], ...
    'VariableTypes',{'string','string','double','logical'}, ...
    'VariableNames',{'Name','Folder','Class','IsTest'});
for k = 1:n
    tbl.Name(k)   = string(files(k).name);
    tbl.Folder(k) = string(files(k).folder);
    [~,fld]      = fileparts(files(k).folder);
    tbl.Class(k)  = serieHash(fld);
    tbl.IsTest(k) = rand < ratioTest;
end

%% 2) Función de extracción de características
function featVec = extractFeatures(row, numBins)
    % Lee la imagen
    img = imread(fullfile(row.Folder, row.Name));
    % Canales RGB y HSV
    R = img(:,:,1); G = img(:,:,2); B = img(:,:,3);
    hsv = rgb2hsv(img);
    H = hsv(:,:,1); V = hsv(:,:,3);
    % Histogramas de H,V,R,G,B
    hH = imhist(H, numBins)'; 
    hV = imhist(V, numBins)';
    
    hR = imhist(R, numBins)';
    hG = imhist(G, numBins)';
    hB = imhist(B, numBins)';
    % Caracteristicas de R,G,B
    mR = mean(R(:));  sR = std(double(R(:)));
    mG = mean(G(:));  sG = std(double(G(:)));
    mB = mean(B(:));  sB = std(double(B(:)));
    % Vector de características
    featVec = [hH, hV, hR, mR, sR, hG, mG, sG, hB, mB, sB, row.Class];
    
end

%% 3) Generar matrices de características y etiquetas
numBins = 30;
trainRows = tbl(~tbl.IsTest,:);
testRows  = tbl( tbl.IsTest,:);

% 5 histogramas, 6 caracteristicas y la label
Train = zeros(height(trainRows), 5*numBins + 7);
Test  = zeros(height(testRows),  5*numBins + 7);

% Extraer para entrenamiento
n = size(trainRows); n = n(1);
for i = 1:n
    Train(i,:) = extractFeatures(trainRows(i,:), numBins);
end

n = size(testRows); n = n(1);
% Extraer para test
for i = 1:n
    Test(i,:) = extractFeatures(testRows(i,:), numBins);
end

%% 4) Entrenamiento: SVM cuadrático
t = templateSVM( ...
    'KernelFunction', 'polynomial', ...
    'PolynomialOrder', 2, ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true);

% Entrenamiento del modelo con codificación one-vs-one (por defecto)
SVMModel = fitcecoc(Train(:, 1:end-1), Train(:, end), ...
    'Learners', t, ...
    'ClassNames', 1:10);
%% 5) Evaluación
yPred = predict(SVMModel, Test(:, 1:end-1));

% Matriz de confusión normalizada
cc = confusionchart(Test(:, end), yPred);
cc.Normalization = 'row-normalized';
cc.RowSummary    = 'row-normalized';
cc.Title         = 'Confusion Chart (por clase)';

% Precisión global
acc = mean(yPred == Test(:, end))*100
