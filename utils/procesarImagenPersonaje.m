function procesarImagenPersonaje(imgPath, modelo)
% PROCESARIMAGENPERSONAJE Procesa una sola imagen y muestra la predicción del personaje
%
% Uso:
%   procesarImagenPersonaje(imgPath, modelo)
%
% Parámetros:
%   imgPath - Ruta de la imagen a procesar
%   modelo - Modelo entrenado para la predicción de personajes

    try
        mostrarEncabezado(['ANALIZANDO IMAGEN: ' basename(imgPath)], '*');
        
        % Cargar y procesar la imagen
        img = imread(imgPath);
        resultados = procesarPrediccionPersonaje(img, modelo);
        
        % Mostrar resultado con formato mejorado
        if resultados.prediccion == 1
            prediccion = 'PETER GRIFFIN PRESENTE';
            simbolo = '✓';
        else
            prediccion = 'PETER GRIFFIN AUSENTE';
            simbolo = '✗';
        end
        
        mostrarEncabezado('RESULTADO DEL ANÁLISIS', '-');
        fprintf('\n  Predicción del personaje: ');
        fprintf('\n  >> %s %s <<\n\n', prediccion, simbolo);
        
        % Intentar determinar la clasificación real a partir de la ruta
        esDeTest = false;
        try
            % Dividir la ruta en partes
            partesRuta = strsplit(imgPath, filesep);
            
            % Buscar si contiene 'test' y 'personajes'
            idxTest = find(strcmp(partesRuta, 'test'), 1);
            idxPersonajes = find(strcmp(partesRuta, 'personajes'), 1);
            
            if ~isempty(idxTest) && ~isempty(idxPersonajes) && idxTest < idxPersonajes
                % La imagen está en test/personajes/Peter Griffin/present o absent
                esDeTest = true;
                
                % Buscar las carpetas present/absent
                idxPresent = find(strcmp(partesRuta, 'present'), 1);
                idxAusente = find(strcmp(partesRuta, 'ausente'), 1);
                
                if ~isempty(idxPresent)
                    etiquetaReal = 1; % Presente
                    categoriaReal = 'presente';
                elseif ~isempty(idxAusente)
                    etiquetaReal = 0; % Ausente
                    categoriaReal = 'ausente';
                else
                    esDeTest = false; % No se pudo determinar
                end
                
                if esDeTest
                    esCorrecto = (resultados.prediccion == etiquetaReal);
                    if esCorrecto
                        fprintf('  Predicción: CORRECTA ✓\n');
                        fprintf('  Estado real: Peter Griffin %s\n', categoriaReal);
                    else
                        fprintf('  Predicción: INCORRECTA ✗\n');
                        fprintf('  Predicción: Peter Griffin %s\n', prediccion);
                        fprintf('  Estado real: Peter Griffin %s\n', categoriaReal);
                    end
                end
            end
        catch
            % No se pudo determinar la clasificación real
        end
        
        % Si no es de test, solo mostrar la predicción
        if ~esDeTest
            fprintf('  Imagen procesada desde ubicación externa\n');
        end
        
        fprintf('\n%s\n', repmat('-', 1, 60));
    catch e
        mostrarEncabezado(['Error al procesar la imagen: ' e.message], '!');
    end
end
