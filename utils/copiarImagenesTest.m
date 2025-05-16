function [copiados, errores] = copiarImagenesTest(tablaTest, seriesNames, rutaDestino)
% COPIARIMAGENESTEST Copia imágenes de test a carpetas de destino
% [copiados, errores] = copiarImagenesTest(tablaTest, seriesNames, rutaDestino)
%
% Parámetros:
%   tablaTest - Tabla con datos de las imágenes (nombre, ruta, índice serie)
%   seriesNames - Nombres de las series
%   rutaDestino - Ruta base donde crear las carpetas de series

copiados = 0;
errores = 0;
total = size(tablaTest, 1);

% Configurar barra de progreso
h = waitbar(0, 'Iniciando copia de imágenes...', 'Name', 'Copiando imágenes');

for i = 1:total
    try
        % Actualizar barra de progreso cada 10 imágenes
        if mod(i, 10) == 0
            waitbar(i/total, h, sprintf('Procesando imagen %d de %d...', i, total));
        end
        
        % Extraer datos de la tabla
        nombreArchivo = tablaTest{i,1};
        carpetaOrigen = tablaTest{i,2};
        idxSerie = str2double(tablaTest{i,3});
        
        % Validar índice de serie
        if isnan(idxSerie) || idxSerie < 1 || idxSerie > numel(seriesNames)
            errores = errores + 1;
            continue;
        end
        
        % Crear carpeta destino si no existe
        carpetaDestino = fullfile(rutaDestino, seriesNames{idxSerie});
        if ~exist(carpetaDestino, 'dir')
            mkdir(carpetaDestino);
        end
        
        % Copiar archivo
        origen = fullfile(carpetaOrigen, nombreArchivo);
        destino = fullfile(carpetaDestino, nombreArchivo);
        
        if exist(origen, 'file')
            copyfile(origen, destino);
            copiados = copiados + 1;
        else
            errores = errores + 1;
        end
    catch
        errores = errores + 1;
    end
end

% Cerrar barra de progreso
if ishandle(h)
    close(h);
end

% Mostrar resultados
fprintf('\nCopia finalizada:\n');
fprintf('- Imágenes copiadas: %d\n', copiados);
fprintf('- Errores: %d\n', errores);
end