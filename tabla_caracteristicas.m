% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));

%% SERIES
load(fullfile('out', 'series', 'T_entradasSeries.mat')); % Carga T_entradasSeries
numImagenes_S = size(T_entradasSeries,1);

numBins = 20;
T_caracteristicasSeries = [];

for i = 1:numImagenes_S
    if T_entradasSeries(i,4) == "0"
        img = imread(fullfile(T_entradasSeries{i,2}, T_entradasSeries{i,1}));
        
        % Extraer características y normalizar por número de píxeles
        vector = extraer_caracteristicas(img, numBins);
        
        % Obtener el número total de píxeles de la imagen
        [alto, ancho, ~] = size(img);
        numPixeles = alto * ancho;
        
        % Normalizar las características de color dividiéndolas por el número de píxeles
        vector_normalizado = vector / numPixeles;
        
        % Añadir la etiqueta al final del vector
        vector_normalizado = [vector_normalizado, str2double(T_entradasSeries{i,3})];
        T_caracteristicasSeries = [T_caracteristicasSeries; vector_normalizado];
    end
    % Imprimir progreso cada 100 imágenes o al final
    if mod(i,100)==0 || i==numImagenes_S
        fprintf('Progreso: %.1f%% (%d/%d)\n', 100*i/numImagenes_S, i, numImagenes_S);
    end
end

% Guardamos los datos originales normalizados por número de píxeles
X = T_caracteristicasSeries(:,1:end-1);
y = T_caracteristicasSeries(:,end);

% Guardamos la tabla normalizada por número de píxeles
T_caracteristicasSeriesNorm = T_caracteristicasSeries;

% Crear carpetas necesarias
if ~exist('out','dir')
    mkdir('out')
end
if ~exist(fullfile('out','series'),'dir')
    mkdir(fullfile('out','series'))
end

% Guardamos la tabla normalizada en la subcarpeta series
save(fullfile('out','series','T_caracteristicasSeriesNorm.mat'),'T_caracteristicasSeriesNorm');

%% PERSONAJES
%{
load(fullfile('out', 'personajes', 'T_entradasPersonajes.mat'));% Carga T_entradasPersonajes
numImagenes_P = size(T_entradasPersonajes,1);

numBins = 20;
T_caracteristicasPersonajes = [];

for i = 1:numImagenes_P
    if T_entradasPersonajes(i,4) == "0"
        img = imread(fullfile(T_entradasPersonajes{i,2}, T_entradasPersonajes{i,1}));
        
        % Extraer características y normalizar por número de píxeles
        vector = extraer_caracteristicas(img, numBins);
        
        % Obtener el número total de píxeles de la imagen
        [alto, ancho, ~] = size(img);
        numPixeles = alto * ancho;
        
        % Normalizar las características de color dividiéndolas por el número de píxeles
        % Nota: Asumiendo que todas las características de vector son histogramas de color
        vector_normalizado = vector / numPixeles;
        
        % Añadir la etiqueta al final del vector
        vector_normalizado = [vector_normalizado, str2double(T_entradasPersonajes{i,3})];
        T_caracteristicasPersonajes = [T_caracteristicasPersonajes; vector_normalizado];
    end
    % Imprimir progreso cada 10 imágenes o al final
    if mod(i,10)==0 || i==numImagenes_P
        fprintf('Progreso personajes: %.1f%% (%d/%d)\n', 100*i/numImagenes_P, i, numImagenes_P);
    end
end

% Guardamos los datos originales normalizados por número de píxeles
X_P = T_caracteristicasPersonajes(:,1:end-1);
y_P = T_caracteristicasPersonajes(:,end);

% Guardamos la tabla normalizada por número de píxeles
T_caracteristicasPersonajesNorm = T_caracteristicasPersonajes;

% Crear carpetas necesarias
if ~exist('out','dir')
    mkdir('out')
end
if ~exist(fullfile('out','personajes'),'dir')
    mkdir(fullfile('out','personajes'))
end

% Guardamos la tabla normalizada en la subcarpeta personajes
save(fullfile('out','personajes','T_caracteristicasPersonajesNorm.mat'),'T_caracteristicasPersonajesNorm');
%}