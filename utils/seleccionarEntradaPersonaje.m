function seleccionarEntradaPersonaje(modelo)
% SELECCIONARENTRADAPERSONAJE Muestra una interfaz para seleccionar entrada para análisis de personajes
%
% Uso:
%   seleccionarEntradaPersonaje(modelo)
%
% Parámetros:
%   modelo - Modelo entrenado para la predicción de personajes

    % Definir callbacks para la interfaz
    callbacks = struct();
    callbacks.imagen = @(src, event) seleccionarImagenPersonaje(src, gcf, modelo);
    callbacks.carpeta = @(src, event) seleccionarCarpetaPersonaje(src, gcf, modelo);
    
    % Crear la interfaz
    seleccionFig = crearInterfazSeleccion('Selección de entrada para Personajes', callbacks);
    
    % No continuar con el código hasta que se cierre la figura
    uiwait(seleccionFig);
end

% Función auxiliar para manejar la selección de imagen para personajes
function seleccionarImagenPersonaje(~, figHandle, modelo)
    % Ruta inicial para el diálogo
    rutaInicial = fullfile(pwd, 'dataset');
    
    % Seleccionar imagen
    rutaImagen = seleccionarArchivo('imagen', rutaInicial);
    
    % Si se seleccionó una imagen
    if ~isempty(rutaImagen)
        % Cerrar la figura para continuar con el procesamiento
        delete(figHandle);
        % Procesar la imagen
        procesarImagenPersonaje(rutaImagen, modelo);
    end
end

% Función auxiliar para manejar la selección de carpeta para personajes
function seleccionarCarpetaPersonaje(~, figHandle, modelo)
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
        
        % Verificar si es una subcarpeta present/absent
        if strcmpi(nombreCarpeta, 'present') || strcmpi(nombreCarpeta, 'absent')
            % Es una subcarpeta, procesar la carpeta padre (Peter Griffin)
            [carpetaPadre, ~] = fileparts(rutaCarpeta);
            [~, nombrePersonaje] = fileparts(carpetaPadre);
            
            % Verificar si la carpeta padre es Peter Griffin
            if strcmpi(nombrePersonaje, 'Peter Griffin')
                procesarCarpetaPersonaje(carpetaPadre, modelo, nombrePersonaje);
            else
                % Si no es Peter Griffin, procesar como carpeta simple
                procesarCarpetaPersonaje(rutaCarpeta, modelo, nombreCarpeta);
            end
            return;
        end
        
        % Verificar si es la carpeta "Peter Griffin" directamente
        if strcmpi(nombreCarpeta, 'Peter Griffin')
            % Verificar si tiene subcarpetas present/absent
            presentPath = fullfile(rutaCarpeta, 'present');
            absentPath = fullfile(rutaCarpeta, 'absent');
            
            if exist(presentPath, 'dir') || exist(absentPath, 'dir')
                % Es la carpeta Peter Griffin con subcarpetas, procesarla directamente
                procesarCarpetaPersonaje(rutaCarpeta, modelo, nombreCarpeta);
                return;
            end
        end
        
        % Verificar si es la carpeta "personajes" que contiene todas las subcarpetas
        contenido = dir(rutaCarpeta);
        contenido = contenido(~ismember({contenido.name}, {'.', '..'}));
        
        % Contar cuántas subcarpetas son de personajes conocidos
        subcarpetasPersonajes = 0;
        personajesConocidos = {'Peter Griffin'}; % Expandible para más personajes
        
        for i = 1:length(contenido)
            if contenido(i).isdir
                for j = 1:length(personajesConocidos)
                    if strcmpi(contenido(i).name, personajesConocidos{j})
                        subcarpetasPersonajes = subcarpetasPersonajes + 1;
                        break;
                    end
                end
            end
        end
        
        % Si tiene subcarpetas de personajes conocidos, es el dataset completo
        if subcarpetasPersonajes >= 1  % Al menos 1 personaje conocido
            procesarDatasetCompletoPersonajes(rutaCarpeta, modelo);
        else
            % Es una carpeta individual con imágenes de un personaje
            procesarCarpetaPersonaje(rutaCarpeta, modelo, nombreCarpeta);
        end
    end
end
