function prepararCarpetasTestPersonajes()
% PREPARARCARPETASTESTPERSONAJES Copia imágenes de test a carpetas de personajes
%
% Uso:
%   prepararCarpetasTestPersonajes()
%
% Esta función copia las imágenes de test para Peter Griffin desde el
% dataset de entrenamiento a las carpetas de test correspondientes.

    fprintf('\n=== COPIANDO IMÁGENES DE TEST PARA PERSONAJES ===\n\n');
    
    % Verificar archivo de test de personajes
    archivoTest = fullfile('out', 'personajes', 'Peter Griffin', 'T_entradasPersonajesTest.mat');
    if ~exist(archivoTest, 'file')
        fprintf('ERROR: No se encontró %s\n', archivoTest);
        fprintf('Ejecuta primero la generación de tablas de entrada para personajes.\n');
        return;
    end
    
    % Cargar datos de test
    load(archivoTest, 'T_entradasPersonajesTest');
    
    % Rutas de destino
    rutaDestino = fullfile('dataset', 'test', 'personajes');
    rutaPresente = fullfile(rutaDestino, 'Peter Griffin', 'present');
    rutaAusente = fullfile(rutaDestino, 'Peter Griffin', 'absent');
    
    % Crear carpetas de destino
    if ~exist(rutaPresente, 'dir')
        mkdir(rutaPresente);
        fprintf('Creada carpeta: %s\n', rutaPresente);
    end
    
    if ~exist(rutaAusente, 'dir')
        mkdir(rutaAusente);
        fprintf('Creada carpeta: %s\n', rutaAusente);
    end
    
    % Copiar imágenes
    copiados = 0;
    errores = 0;
    total = size(T_entradasPersonajesTest, 1);
    
    fprintf('\nCopiando %d imágenes...\n\n', total);
      for i = 1:total
        try
            nombreImg = T_entradasPersonajesTest{i, 1};
            rutaOrigen = T_entradasPersonajesTest{i, 2};
            etiqueta = str2double(T_entradasPersonajesTest{i, 3});
            
            % Determinar carpeta de destino según etiqueta
            if etiqueta == 1
                carpetaDestino = rutaPresente;
            else
                carpetaDestino = rutaAusente;
            end
            
            archivoOrigen = fullfile(rutaOrigen, nombreImg);
            archivoDestino = fullfile(carpetaDestino, nombreImg);
            
            if exist(archivoOrigen, 'file')
                copyfile(archivoOrigen, archivoDestino);
                copiados = copiados + 1;
            else
                errores = errores + 1;
            end
            
        catch
            errores = errores + 1;
        end
    end
    
    fprintf('Resultado:\n');
    fprintf('  Copiadas: %d\n', copiados);
    fprintf('  Errores: %d\n', errores);
    fprintf('  Total: %d\n\n', total);
end
