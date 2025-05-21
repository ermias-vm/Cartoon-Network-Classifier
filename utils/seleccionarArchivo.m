function rutaSeleccionada = seleccionarArchivo(tipo, rutaInicial)
% SELECCIONARARCHIVO Muestra un diálogo para seleccionar una imagen o carpeta
%
% Uso:
%   rutaSeleccionada = seleccionarArchivo(tipo, rutaInicial)
%
% Parámetros:
%   tipo - Tipo de selección ('imagen' o 'carpeta')
%   rutaInicial - Ruta inicial para el diálogo
%
% Salida:
%   rutaSeleccionada - Ruta seleccionada (vací si se cancela)

    % Verificar que la carpeta existe, sino usar pwd
    if ~exist(rutaInicial, 'dir')
        rutaInicial = pwd;
    end
    
    rutaSeleccionada = '';
    
    if strcmpi(tipo, 'imagen')
        [file, path] = uigetfile({'*.jpg;*.jpeg;*.png', 'Imágenes (*.jpg, *.jpeg, *.png)'; ...
                                '*.*', 'Todos los archivos (*.*)'}, ...
                               'Selecciona una imagen', rutaInicial);
        
        % Si se seleccionó un archivo
        if ~isequal(file, 0)
            rutaSeleccionada = fullfile(path, file);
        end
    elseif strcmpi(tipo, 'carpeta')
        carpeta = uigetdir(rutaInicial, 'Selecciona una carpeta');
        
        % Si se seleccionó una carpeta
        if ~isequal(carpeta, 0)
            rutaSeleccionada = carpeta;
        end
    end
end
