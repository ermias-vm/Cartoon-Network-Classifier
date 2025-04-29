%% SERIES
load(fullfile('out', 'tablaImagenesSeries.mat'));
numImagenes_S = size(tablaImagenes_S,1);

numBins = 20;
caracteristicas_S = [];

for i = 1:numImagenes_S
    if tablaImagenes_S(i,4) == "0"
        img = imread(fullfile(tablaImagenes_S{i,2}, tablaImagenes_S{i,1}));
        vector = extraer_caracteristicas(img, numBins);
        vector = [vector, str2double(tablaImagenes_S{i,3})];
        caracteristicas_S = [caracteristicas_S; vector];
    end
    % Imprimir progreso cada 50 imágenes o al final
    if mod(i,10)==0 || i==numImagenes_S
        fprintf('Progreso: %.1f%% (%d/%d)\n', 100*i/numImagenes_S, i, numImagenes_S);
    end
end

% Normalización min-max de cada columna (excepto la etiqueta)
X = caracteristicas_S(:,1:end-1);
y = caracteristicas_S(:,end);
minXseries = min(X);
maxXseries = max(X);
Xnorm = (X - minXseries) ./ (maxXseries - minXseries);
caracteristicas_norm_S = [Xnorm, y];

% Crear carpeta "out"
if ~exist('out','dir')
    mkdir('out')
end

save(fullfile('out','caracteristicasSeries.mat'),'caracteristicas_norm_S');
save(fullfile('out','minXseries.mat'),'minXseries');
save(fullfile('out','maxXseries.mat'),'maxXseries');

%% PERSONAJES
load(fullfile('out', 'tablaImagenesPersonajes.mat'));
numImagenes_P = size(tablaImagenes_P,1);

numBins = 20;
caracteristicas_P = [];

for i = 1:numImagenes_P
    if tablaImagenes_P(i,4) == "0"
        img = imread(fullfile(tablaImagenes_P{i,2}, tablaImagenes_P{i,1}));
        vector = extraer_caracteristicas(img, numBins);
        vector = [vector, str2double(tablaImagenes_P{i,3})];
        caracteristicas_P = [caracteristicas_P; vector];
    end
    % Imprimir progreso cada 10 imágenes o al final
    if mod(i,10)==0 || i==numImagenes_P
        fprintf('Progreso personajes: %.1f%% (%d/%d)\n', 100*i/numImagenes_P, i, numImagenes_P);
    end
end

% Normalización min-max de cada columna (excepto la etiqueta)
X_P = caracteristicas_P(:,1:end-1);
y_P = caracteristicas_P(:,end);
minXpersonajes = min(X_P);
maxXpersonajes = max(X_P);
Xnorm_P = (X_P - minXpersonajes) ./ (maxXpersonajes - minXpersonajes);
caracteristicas_norm_P = [Xnorm_P, y_P];

% Crear carpeta "out" si no existe
if ~exist('out','dir')
    mkdir('out')
end

save(fullfile('out','caracteristicasPersonajes.mat'),'caracteristicas_norm_P');
save(fullfile('out','minXpersonajes.mat'),'minXpersonajes');
save(fullfile('out','maxXpersonajes.mat'),'maxXpersonajes');