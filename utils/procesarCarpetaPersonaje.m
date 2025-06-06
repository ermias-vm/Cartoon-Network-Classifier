function procesarCarpetaPersonaje(carpetaPath, modelo, nombreCarpeta)
% PROCESARCARPETAPERSONAJE Procesa una carpeta con imágenes de personajes
%
% Uso:
%   procesarCarpetaPersonaje(carpetaPath, modelo, nombreCarpeta)
%
% Parámetros:
%   carpetaPath - Ruta de la carpeta a procesar
%   modelo - Modelo entrenado para la predicción de personajes
%   nombreCarpeta - Nombre de la carpeta para mostrar en resultados    % Verificar si es una carpeta con subcarpetas present/absent
    presentPath = fullfile(carpetaPath, 'present');
    absentPath = fullfile(carpetaPath, 'absent');
    
    if exist(presentPath, 'dir') || exist(absentPath, 'dir')
        % Es una carpeta de personaje con subcarpetas present/absent
        procesarCarpetaPersonajeConSubcarpetas(carpetaPath, modelo, nombreCarpeta);
    else
        % Es una carpeta simple con imágenes
        procesarCarpetaPersonajeSimple(carpetaPath, modelo, nombreCarpeta);
    end
end

function procesarCarpetaPersonajeConSubcarpetas(carpetaPath, modelo, nombreCarpeta)
% Procesar carpeta con subcarpetas present/absent
    
    presentPath = fullfile(carpetaPath, 'present');
    absentPath = fullfile(carpetaPath, 'absent');
    
    archivosPresent = [];
    archivosAbsent = [];
    
    if exist(presentPath, 'dir')
        archivosPresent = dir(fullfile(presentPath, '*.jpg'));
    end
    
    if exist(absentPath, 'dir')
        archivosAbsent = dir(fullfile(absentPath, '*.jpg'));
    end
    
    totalPresent = numel(archivosPresent);
    totalAbsent = numel(archivosAbsent);
    total = totalPresent + totalAbsent;
    
    if total == 0
        mostrarEncabezado('No se encontraron imágenes en las carpetas present/ausente.', '-');
        return;
    end
      mostrarEncabezado(['PROCESANDO ' num2str(total) ' IMÁGENES DE PERSONAJE "' nombreCarpeta '"'], '*');
    fprintf('  - Imágenes con personaje presente: %d\n', totalPresent);
    fprintf('  - Imágenes con personaje ausente: %d\n', totalAbsent);
    
    aciertos = 0;
    aciertosPresentCount = 0;
    aciertosAbsentCount = 0;
      % Determinar si estamos procesando una carpeta de test
    esDeTest = false;
    
    % Dividir la ruta en partes para determinar si es de test
    partesRuta = strsplit(carpetaPath, filesep);
    idxTest = find(strcmp(partesRuta, 'test'), 1);
    idxPersonajes = find(strcmp(partesRuta, 'personajes'), 1);
      if ~isempty(idxTest) && ~isempty(idxPersonajes) && idxTest < idxPersonajes
        esDeTest = true;
    end
    
    % Crear barra de progreso
    progressFig = crearBarraProgreso('Progreso de procesamiento personajes');
    
    % Inicializar la tabla para imágenes mal clasificadas
    misclassifiedTable = cell(0, 3);
    
    imagenesProcesadas = 0;
    
    % Procesar imágenes presentes
    for j = 1:totalPresent
        imgPath = fullfile(archivosPresent(j).folder, archivosPresent(j).name);
        try
            img = imread(imgPath);
            resultados = procesarPrediccionPersonaje(img, modelo);
            
            % Etiqueta real: 1 (presente)
            etiquetaReal = 1;
            
            % Si es de test, comprobar si es correcta la predicción
            if esDeTest
                esCorrecto = (resultados.prediccion == etiquetaReal);
                if esCorrecto
                    aciertos = aciertos + 1;
                    aciertosPresentCount = aciertosPresentCount + 1;
                else
                    % Añadir a tabla de imágenes mal clasificadas
                    if resultados.prediccion == 1
                        prediccionTexto = 'presente';
                    else
                        prediccionTexto = 'ausente';
                    end
                    misclassifiedTable(end+1, :) = {
                        imgPath, ... % Ruta completa
                        prediccionTexto, ... % Predicción
                        'presente' ... % Etiqueta real
                    };
                end
            end
            
            imagenesProcesadas = imagenesProcesadas + 1;
            % Actualizar barra de progreso
            actualizarBarraProgreso(progressFig, imagenesProcesadas, total);
            
        catch e
            fprintf('Error al procesar la imagen %s: %s\n', archivosPresent(j).name, e.message);
        end
    end
    
    % Procesar imágenes ausentes
    for j = 1:totalAbsent
        imgPath = fullfile(archivosAbsent(j).folder, archivosAbsent(j).name);
        try
            img = imread(imgPath);
            resultados = procesarPrediccionPersonaje(img, modelo);
            
            % Etiqueta real: 0 (ausente)
            etiquetaReal = 0;
            
            % Si es de test, comprobar si es correcta la predicción
            if esDeTest
                esCorrecto = (resultados.prediccion == etiquetaReal);
                if esCorrecto
                    aciertos = aciertos + 1;
                    aciertosAbsentCount = aciertosAbsentCount + 1;
                else
                    % Añadir a tabla de imágenes mal clasificadas
                    if resultados.prediccion == 1
                        prediccionTexto = 'presente';
                    else
                        prediccionTexto = 'ausente';
                    end
                    misclassifiedTable(end+1, :) = {
                        imgPath, ... % Ruta completa
                        prediccionTexto, ... % Predicción
                        'ausente' ... % Etiqueta real
                    };
                end
            end
            
            imagenesProcesadas = imagenesProcesadas + 1;
            % Actualizar barra de progreso
            actualizarBarraProgreso(progressFig, imagenesProcesadas, total);
            
        catch e
            fprintf('Error al procesar la imagen %s: %s\n', archivosAbsent(j).name, e.message);
        end
    end
    
    % Cerrar la barra de progreso
    cerrarBarraProgreso(progressFig);    % Mostrar resultados con formato mejorado
    if esDeTest
        porcentaje = 100 * aciertos / total;
        mostrarEncabezado(['RESULTADOS PARA EL PERSONAJE "' nombreCarpeta '"'], '-');
        fprintf('\n  Aciertos totales: %d de %d (%.2f%%)\n', aciertos, total, porcentaje);
        
        % Mostrar estadísticas detalladas
        if totalPresent > 0
            porcentajePresent = 100 * aciertosPresentCount / totalPresent;
            fprintf('  - Imágenes "presente": %d aciertos de %d (%.2f%%)\n', aciertosPresentCount, totalPresent, porcentajePresent);
        end
        
        if totalAbsent > 0
            porcentajeAbsent = 100 * aciertosAbsentCount / totalAbsent;
            fprintf('  - Imágenes "ausente": %d aciertos de %d (%.2f%%)\n', aciertosAbsentCount, totalAbsent, porcentajeAbsent);
        end
        
        fprintf('\n');
        
        % Guardar tabla de imágenes mal clasificadas si existe la carpeta
        if ~isempty(misclassifiedTable)
            % Crear directorio si no existe
            dirMisclassified = fullfile('dataset', 'test', 'misclassified');
            if ~exist(dirMisclassified, 'dir')
                mkdir(dirMisclassified);
            end
            
            % Crear nombre del archivo
            nombreArchivo = fullfile(dirMisclassified, [nombreCarpeta, '_personaje.mat']);
            
            % Crear tabla con encabezados
            T_misclassified = cell(size(misclassifiedTable, 1) + 1, 3);
            T_misclassified(1, :) = {'Ubicacion', 'Predicho', 'Correcto'};
            T_misclassified(2:end, :) = misclassifiedTable;
            
            % Guardar la tabla
            save(nombreArchivo, 'T_misclassified');
            fprintf('  Tabla de imágenes mal clasificadas guardada en: %s\n', nombreArchivo);
            fprintf('  Total de imágenes mal clasificadas: %d\n\n', size(misclassifiedTable, 1));
        end
    else
        % Para carpetas no de test, mostrar estadísticas de predicción
        mostrarEncabezado(['RESULTADOS PARA EL PERSONAJE "' nombreCarpeta '"'], '-');
        
        % Contar predicciones
        prediccionesPresenteCount = 0;
        prediccionesAusenteCount = 0;
        
        % Las predicciones ya se han hecho en el bucle anterior, necesitamos contarlas
        % Como no guardamos las predicciones individuales para carpetas no-test,
        % vamos a mostrar información general
        fprintf('\n  Total de imágenes procesadas: %d\n', total);
        if totalPresent > 0
            fprintf('  - Imágenes de carpeta "present": %d\n', totalPresent);
        end
        if totalAbsent > 0
            fprintf('  - Imágenes de carpeta "absent": %d\n', totalAbsent);
        end
        fprintf('  Solo se muestra la predicción (no hay verificación de exactitud).\n\n');
    end
end

function procesarCarpetaPersonajeSimple(carpetaPath, modelo, nombreCarpeta)
% Procesar carpeta simple con imágenes
    
    archivos = dir(fullfile(carpetaPath, '*.jpg'));
    total = numel(archivos);
    
    if total == 0
        mostrarEncabezado('No se encontraron imágenes en la carpeta.', '-');
        return;
    end
    
    mostrarEncabezado(['PROCESANDO ' num2str(total) ' IMÁGENES DE LA CARPETA "' nombreCarpeta '"'], '*');
    
    % Crear barra de progreso
    progressFig = crearBarraProgreso('Progreso de procesamiento');
    
    for j = 1:total
        imgPath = fullfile(archivos(j).folder, archivos(j).name);
        try
            img = imread(imgPath);
            resultados = procesarPrediccionPersonaje(img, modelo);
            
            % Actualizar barra de progreso
            actualizarBarraProgreso(progressFig, j, total);
            
        catch e
            fprintf('Error al procesar la imagen %s: %s\n', archivos(j).name, e.message);
        end
    end
    
    % Cerrar la barra de progreso
    cerrarBarraProgreso(progressFig);
    
    mostrarEncabezado(['PROCESAMIENTO COMPLETADO PARA "' nombreCarpeta '"'], '-');
    fprintf('\n  Se procesaron %d imágenes de la carpeta externa.\n', total);
    fprintf('  Solo se muestra la predicción (no hay verificación de exactitud).\n\n');
end
