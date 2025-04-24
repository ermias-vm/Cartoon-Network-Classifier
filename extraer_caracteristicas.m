load('tablaImagenes.mat');
numImagenes = size(tablaImagenes,1);

numBins = 256;
caracteristicasRGB = [];

for i = 1:numImagenes
    if tablaImagenes(i,4) == "false"
        rutaImagen = fullfile(tablaImagenes(i,2), tablaImagenes(i,1));
        img = imread(rutaImagen);
        img = im2double(img);

        R = img(:,:,1); G = img(:,:,2); B = img(:,:,3);

        edges = linspace(0,1,numBins+1);

        histR = histcounts(R, edges, 'Normalization', 'probability');
        meanR = mean(R(:));
        stdR = std(R(:));
        skewR = skewness(R(:));

        histG = histcounts(G, edges, 'Normalization', 'probability');
        meanG = mean(G(:));
        stdG = std(G(:));
        skewG = skewness(G(:));

        histB = histcounts(B, edges, 'Normalization', 'probability');
        meanB = mean(B(:));
        stdB = std(B(:));
        skewB = skewness(B(:));

        vector = [histR, meanR, stdR, skewR, ...
                  histG, meanG, stdG, skewG, ...
                  histB, meanB, stdB, skewB, ...
                  str2double(tablaImagenes(i,3))];

        caracteristicasRGB = [caracteristicasRGB; vector];
    end
end

save('caracteristicasRGB.mat','caracteristicasRGB');