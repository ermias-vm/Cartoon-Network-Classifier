function seleccionarEntradaSerie(modelo, seriesNames, numBins)
% SELECCIONARENTRADASERIE Muestra una interfaz para seleccionar entrada para análisis de series
%
% Uso:
%   seleccionarEntradaSerie(modelo, seriesNames, numBins)
%
% Parámetros:
%   modelo - Modelo entrenado para la predicción de series
%   seriesNames - Nombres de las series
%   numBins - Número de bins para la extracción de características

    % Definir callbacks para la interfaz
    callbacks = struct();
    callbacks.imagen = @(src, event) seleccionarImagenSerie(src, gcf, modelo, seriesNames, numBins);
    callbacks.carpeta = @(src, event) seleccionarCarpetaSerie(src, gcf, modelo, seriesNames, numBins);
    
    % Crear la interfaz
    seleccionFig = crearInterfazSeleccion('Selección de entrada para Series', callbacks);
    
    % No continuar con el código hasta que se cierre la figura
    uiwait(seleccionFig);
end

% Función auxiliar para manejar la selección de imagen para series
function seleccionarImagenSerie(~, figHandle, modelo, seriesNames, numBins)
    % Ruta inicial para el diálogo
    rutaInicial = fullfile(pwd, 'dataset');
    
    % Seleccionar imagen
    rutaImagen = seleccionarArchivo('imagen', rutaInicial);
    
    % Si se seleccionó una imagen
    if ~isempty(rutaImagen)
        % Cerrar la figura para continuar con el procesamiento
        delete(figHandle);
        % Procesar la imagen
        procesarImagen(rutaImagen, modelo, seriesNames, numBins);
    end
end

% Función auxiliar para manejar la selección de carpeta para series
function seleccionarCarpetaSerie(~, figHandle, modelo, seriesNames, numBins)
    % Ruta inicial para el diálogo
    rutaInicial = fullfile(pwd, 'dataset');
    
    % Seleccionar carpeta
    rutaCarpeta = seleccionarArchivo('carpeta', rutaInicial);
    
    % Si se seleccionó una carpeta
    if ~isempty(rutaCarpeta)
        % Cerrar la figura para continuar con el procesamiento
        delete(figHandle);
        
        % Obtener el nombre de la carpeta
        [~, nombreCarpeta] = fileparts(rutaCarpeta);
        
        % Verificar si es la carpeta "series" que contiene todas las subcarpetas
        contenido = dir(rutaCarpeta);
        contenido = contenido(~ismember({contenido.name}, {'.', '..'}));
        
        % Contar cuántas subcarpetas coinciden con nombres de series conocidas
        subcarpetasConocidas = 0;
        for i = 1:length(contenido)
            if contenido(i).isdir
                for j = 1:length(seriesNames)
                    if strcmpi(contenido(i).name, seriesNames{j})
                        subcarpetasConocidas = subcarpetasConocidas + 1;
                        break;
                    end
                end
            end
        end
        
        % Si tiene muchas subcarpetas conocidas, es el dataset completo
        if subcarpetasConocidas >= 3  % Al menos 3 series conocidas
            procesarDatasetCompleto(rutaCarpeta, modelo, seriesNames, numBins);
        else
            % Es una carpeta individual con imágenes de una serie
            procesarCarpetaSerie(rutaCarpeta, modelo, seriesNames, numBins, nombreCarpeta);
        end
    end
end
