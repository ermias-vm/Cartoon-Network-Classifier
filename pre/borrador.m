%% PROJECTE FINAL

%{
1 - Clasificar en una tabla: Nombre fichero / Clase (dibujo animado al que
pertenecen) (int) / SI es de test o de entrenamiento (bool)

2 - Tabla con: Nombre dibujo animado (String) / Clase (dibujo animado al que
pertenecen) (int)

3 - Pasar todas las fotos QUE NO SON test por el EXTRACTOR DE
CARACTERISTICAS.
Esto nos devuelve la tabla de caracteristicas:
IMG | C1 | C2 | ... | CN
1   | 0.7|0.2 | ... | 0.99 -> A una fila se le llama, vector de caracteristicas
Que dada una serie de caracteristicas -- o predictores --, nos indica como se ajusta cada
imagen a estas caracteristicas.

4- APRENENTATGE: Dada la tabla de Caract. devuelve una funcion de
clasificación.

5 - Usando las fotos que SON de test, pasarlo por el EXTRACTOR DE
CARACTERISTICAS (igual al de antes) y obtener la tabla de caracteristicas. Aplicar a la tabla
la FUNCIÓN DE CLASIFICACION y VER QUE RESULTADO DA. -> Se genera un report
que acabará en el informe.

1 PARTE: Reconocer las series
2 PARTE: Reconocer los personajes de las series

Esperamos entre 90 y 95 % de clasificació para la primera parte.
En general, un poco peor para la segunda. Es más dificil

En general, 70/30 o 80/20 para ratio entrenamiento/test. Se puede hacer
generando un numero random entre 1/1000 y si es mayor que 700 tests.

OBS: Un dibujante siempre dibuja con la misma paleta de colores para una
misma serie. Por tanto, la forma pasa a un segundo plano para la primera
parte, analizar caracteristicas de color deberia funcionar bastante bien.

Tengo fotos de la pipeline en la pizarra.

HACER CLASIFICADOR EN MATLAB: En APPS, en la seccion de machine
learning/deep learning -> Classification learner
Obs: Deep Network necesita muchas imagenes, mientras que en general,
Classification learner como usa metodos numericos y no redes neuronales
funciona bien para samples sizes pequeños. La alternativa seria usar una
Deep Network ya entrenada y hacer fine tunning.
%}

%% PARTE 1

%% GENERAR TABLA FICHEROS

close all
clear all

% Path relativo con desde dentro de la carpeta TRAIN
a = dir('./**/*.jpg');
nf = size(a);

keySet = {'barrufets','Bob esponja','gat i gos','Gumball', 'hora de aventuras', 'Oliver y Benji', 'padre de familia', 'pokemon', 'southpark', 'Tom y Jerry'};
valueSet = [1,2,3,4,5,6,7,8,9,10];
serieHash = containers.Map(keySet,valueSet);


% Tabla: name, folder, num, test
tablaImagenes = [];
ratioTest = 0.3;
for i= 1:nf
    file = a(i).folder;
    [filepath,name] = fileparts(file);
    r = randi([1 1000],1,1);
    tablaImagenes = [tablaImagenes; [string(a(i).name), string(a(i).folder), serieHash(name), (r > (1 - ratioTest)*1000)]];
end
%% EXTRACTOR DE CARACTERISTICAS

numBins = 30;
caracteristicasRGB = [];
close all;

for i= 1:nf
    
    if tablaImagenes(i,4) == "false"
        img = imread(tablaImagenes(i,2)+"/"+tablaImagenes(i,1));
        
        R = img(:,:,1);
        G = img(:,:,2);
        B = img(:,:,3);
    
        histR = (imhist(R, numBins)');
        histG = (imhist(G, numBins)');
        histB = (imhist(B, numBins)');
        
        imgHSV = rgb2hsv(img);
        V = imgHSV(:,:,3);
        S = imgHSV(:,:,2);
        H = imgHSV(:,:,1);
        histV = imhist(V,numBins)';
        histH = imhist(H,numBins)';

        meanR = mean(R(:));
        stdR  = std(double(R(:)));
        
        meanG = mean(G(:));
        stdG  = std(double(G(:)));
        
        meanB = mean(B(:));
        stdB  = std(double(B(:)));
        %RGB nos da con los tree clasifier un 85% lo cual ya es un
        %resultado muy bueno, el objetivo era mejorarlo. Si miramos un poco
        %los resultados, veremos que al modmodelo se le dificulta
        %distinguir por un lado entre gumball, los pitufos, horas de
        %aventuras. Y por otro le cuesta oliver y benji, south park y hora
        %de aventuras. La caracteristica comun que observamos en estos
        %resultados es que los protagonistas comparten una paleta de
        %colores similares, en el primer caso azul y en la segunda color
        %carne. Por tanto, intentaremos añadir informacion adicional sobre
        %los colores para que sea capaz de distinguir las distintas
        %tonalidades de estos colores. Para ello, añadiremos la informacion
        %sobre H y V, la S no nos interinteresa para distinguir
        %tonalidades. De forma analoga, vamvamos a intentar reforzar la
        %informacion que aporta RGB a traves de su media y desviacion
        %estandard, de esta forma sabremos como y "donde" se concentra cada
        %color, de forma que, por ejemplo, el rojo del gorro de papa pitufo
        %aporte mas informacion porque suele ser de los pocos elemntos
        %rojos de la escena.
        vectorCaracteristicasRGB = [histH,histV,...
                                    histR,meanR,stdR,...
                                    histG,meanG,stdG,...
                                    histB,meanB,stdB,...
                                    str2double(tablaImagenes(i,3))];
        caracteristicasRGB = [caracteristicasRGB;vectorCaracteristicasRGB];
    end
end
%% Classification learner

% Le das clic a la app y seleccionas la tabla de caracteristicas y como
% quieres entrenarlo

% Usamos la funcion PREDICT para usar la funcion y los datos para obtener
% una predicion

%Quadratic SVM da una accuracy del 93% con H,V, R,G,B + (mean % std)
%Quadratic SVM da una accuracy del 92% con R,G,B + (mean % std)
%% COMPROBAR TEST IMAGES

caracteristicasRGBTest = [];
close all;

for i= 1:nf
    
    if tablaImagenes(i,4) == "true"
        img = imread(tablaImagenes(i,2)+"/"+tablaImagenes(i,1));
        
        R = img(:,:,1);
        G = img(:,:,2);
        B = img(:,:,3);
    
        histR = (imhist(R, numBins)');
        histG = (imhist(G, numBins)');
        histB = (imhist(B, numBins)');
        
        imgHSV = rgb2hsv(img);
        V = imgHSV(:,:,3);
        S = imgHSV(:,:,2);
        H = imgHSV(:,:,1);
        histV = imhist(V,numBins)';
        histH = imhist(H,numBins)';

        meanR = mean(R(:));
        stdR  = std(double(R(:)));
        
        meanG = mean(G(:));
        stdG  = std(double(G(:)));
        
        meanB = mean(B(:));
        stdB  = std(double(B(:)));
        
        vectorCaracteristicasRGB = [histH,histV,...
                                    histR,meanR,stdR,...
                                    histG,meanG,stdG,...
                                    histB,meanB,stdB];
        caracteristicasRGBTest = [caracteristicasRGBTest;vectorCaracteristicasRGB];
    end
end
%% Mostrar resultados

labels = trainedModel.predictFcn(caracteristicasRGBTest);
X = tablaImagenes(tablaImagenes(:,4) == "true",:);
etiquetasReales = str2double(X(:,3));
cChart = confusionchart(etiquetasReales, labels);
cChart.Normalization = 'row-normalized';
cChart.RowSummary = "row-normalized";

cm = confusionmat(etiquetasReales, labels);
total = sum(cm(:));
aciertos = sum(diag(cm));
fallos = total - aciertos;

porcentajeAciertos = aciertos / total * 100