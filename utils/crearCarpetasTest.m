function creadas = crearCarpetasTest(seriesNames, rutaBase)
% CREARCARPETASTEST Crea carpetas para test de series si no existen
%   creadas = CREARCARPETASTEST(seriesNames, rutaBase) crea una carpeta para
%   cada serie en la ruta base especificada y devuelve un array con las carpetas
%   creadas con éxito.

    creadas = cell(0);
    
    % Verificar si existe la carpeta principal
    if ~exist(rutaBase, 'dir')
        if mkdir(rutaBase)
            fprintf('Creada carpeta principal: %s\n', rutaBase);
        else
            fprintf('Error al crear carpeta principal: %s\n', rutaBase);
            return;
        end
    end
    
    % Crear una subcarpeta para cada serie
    for i = 1:length(seriesNames)
        carpetaSerie = fullfile(rutaBase, seriesNames{i});
        if ~exist(carpetaSerie, 'dir')
            if mkdir(carpetaSerie)
                fprintf('Creada carpeta para la serie: %s\n', seriesNames{i});
                creadas{end+1} = carpetaSerie;
            else
                fprintf('Error al crear carpeta para la serie: %s\n', seriesNames{i});
            end
        else
            creadas{end+1} = carpetaSerie;
        end
    end
end
