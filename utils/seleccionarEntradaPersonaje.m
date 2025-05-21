function seleccionarEntradaPersonaje(modeloSeries, seriesNames, personajesNames, numBins)
% SELECCIONARENTRADAPERSONAJE Muestra una interfaz para seleccionar entrada para análisis de personajes
%
% Uso:
%   seleccionarEntradaPersonaje(modeloSeries, seriesNames, personajesNames, numBins)
%
% Parámetros:
%   modeloSeries - Modelo entrenado para la predicción de series
%   seriesNames - Nombres de las series
%   personajesNames - Nombres de los personajes
%   numBins - Número de bins para la extracción de características

    % Definir callbacks para la interfaz
    callbacks = struct();
    callbacks.imagen = @(src, event) seleccionarImagenPersonaje(src, gcf, modeloSeries, seriesNames, personajesNames, numBins);
    callbacks.carpeta = @(src, event) seleccionarCarpetaPersonaje(src, gcf, modeloSeries, seriesNames, personajesNames, numBins);
    
    % Crear la interfaz
    seleccionFig = crearInterfazSeleccion('Selección de entrada para Personajes', callbacks);
    
    % No continuar con el código hasta que se cierre la figura
    uiwait(seleccionFig);
end

% Función auxiliar para manejar la selección de imagen para personajes
function seleccionarImagenPersonaje(~, figHandle, modeloSeries, seriesNames, personajesNames, numBins)
    % Ruta inicial para el diálogo
    rutaInicial = fullfile(pwd, 'dataset');
    
    % Seleccionar imagen
    rutaImagen = seleccionarArchivo('imagen', rutaInicial);
    
    % Si se seleccionó una imagen
    if ~isempty(rutaImagen)
        % Cerrar la figura para continuar con el procesamiento
        delete(figHandle);
        % Procesar la imagen para personajes
        procesarImagenPersonaje(rutaImagen, modeloSeries, seriesNames, personajesNames, numBins);
    end
end

% Función auxiliar para manejar la selección de carpeta para personajes
function seleccionarCarpetaPersonaje(~, figHandle, modeloSeries, seriesNames, personajesNames, numBins)
    % Ruta inicial para el diálogo
    rutaInicial = fullfile(pwd, 'dataset');
    
    % Seleccionar carpeta
    rutaCarpeta = seleccionarArchivo('carpeta', rutaInicial);
    
    % Si se seleccionó una carpeta
    if ~isempty(rutaCarpeta)
        % Cerrar la figura para continuar con el procesamiento
        delete(figHandle);
        
        % Verificar si contiene subcarpetas
        contenido = dir(rutaCarpeta);
        contieneSubcarpetas = false;
        
        % Filtrar . y ..
        contenido = contenido(~ismember({contenido.name}, {'.', '..'}));
        
        % Buscar subcarpetas
        for i = 1:length(contenido)
            if contenido(i).isdir
                contieneSubcarpetas = true;
                break;
            end
        end
        
        if contieneSubcarpetas
            % Es una carpeta que contiene subcarpetas (dataset completo)
            mostrarEncabezado('Procesamiento de carpetas múltiples para personajes no implementado.\nPor favor, selecciona una carpeta que contenga solo imágenes.', '!');
        else
            % Es una carpeta sin subcarpetas (contiene imágenes)
            [~, nombreCarpeta] = fileparts(rutaCarpeta);
            procesarCarpetaPersonaje(rutaCarpeta, modeloSeries, seriesNames, personajesNames, numBins, nombreCarpeta);
        end
    end
end
