load(fullfile('out', 'tablaImagenes.mat'));
numImagenes = size(tablaImagenes,1);

numBins = 20;
caracteristicas = [];

for i = 1:numImagenes
    if tablaImagenes(i,4) == "false"
        img = imread(fullfile(tablaImagenes{i,2}, tablaImagenes{i,1}));
        vector = extraer_caracteristicas(img, numBins);
        vector = [vector, str2double(tablaImagenes{i,3})];
        caracteristicas = [caracteristicas; vector];
    end
end

% Normalización min-max de cada columna (excepto la etiqueta)
X = caracteristicas(:,1:end-1);
y = caracteristicas(:,end);
Xnorm = (X - min(X)) ./ (max(X) - min(X));
caracteristicas_norm = [Xnorm, y];

% Crear carpeta "out"
if ~exist('out','dir')
    mkdir('out')
end

save(fullfile('out','caracteristicas.mat'),'caracteristicas_norm');