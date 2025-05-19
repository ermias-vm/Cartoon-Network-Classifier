function directoriosCreados = crearEstructuraCarpetas(estructuraCarpetas, mostrarMensajes)
% CREARESTRUCTURACARPETAS Crea una estructura de directorios de forma modular
%
% Uso:
%   directoriosCreados = crearEstructuraCarpetas(estructuraCarpetas, mostrarMensajes)
%
% Entradas:
%   estructuraCarpetas - Celda con las rutas de los directorios a crear.
%                        Cada elemento debe ser un string con la ruta completa
%                        o relativa del directorio.
%   mostrarMensajes    - (Opcional) Booleano para mostrar mensajes de estado por
%                        consola. Por defecto es true.
%
% Salida:
%   directoriosCreados - Celda con las rutas de los directorios que se han
%                        creado correctamente.
%
% Ejemplo:
%   carpetas = {
%       'dataset',
%       fullfile('dataset', 'train'),
%       fullfile('dataset', 'test'),
%       fullfile('dataset', 'train', 'series'),
%       fullfile('dataset', 'train', 'personajes'),
%       fullfile('dataset', 'test', 'series'),
%       fullfile('dataset', 'test', 'misclassified'),
%       fullfile('dataset', 'test', 'personajes')
%   };
%   
%   crearEstructuraCarpetas(carpetas);

% Validar argumentos
if nargin < 1
    error('Se requiere al menos el argumento estructuraCarpetas');
end

if nargin < 2
    mostrarMensajes = true;
end

% Inicializar variable de salida
directoriosCreados = {};

% Verificar que estructuraCarpetas es una celda
if ~iscell(estructuraCarpetas)
    error('estructuraCarpetas debe ser una celda con las rutas de los directorios');
end

% Crear cada directorio
for i = 1:length(estructuraCarpetas)
    carpeta = estructuraCarpetas{i};
    
    % Verificar si el directorio ya existe
    if ~exist(carpeta, 'dir')
        try
            % Crear el directorio
            mkdir(carpeta);
            directoriosCreados{end+1} = carpeta;
            
            % Mostrar mensaje si está habilitado
            if mostrarMensajes
                fprintf('Carpeta "%s" creada correctamente.\n', carpeta);
            end
        catch e
            % Mostrar error si está habilitado
            if mostrarMensajes
                fprintf('Error al crear la carpeta "%s": %s\n', carpeta, e.message);
            end
        end
    else
        % Añadir a la lista de directorios existentes (para completitud)
        directoriosCreados{end+1} = carpeta;
        
        % Opcional: mostrar que ya existe
        if mostrarMensajes
            fprintf('La carpeta "%s" ya existe.\n', carpeta);
        end
    end
end

end
