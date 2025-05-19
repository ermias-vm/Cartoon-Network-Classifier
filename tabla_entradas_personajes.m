% Añadir la carpeta utils al path
addpath(fullfile(pwd, 'utils'));

%% PERSONAJES
% Directorios para cada personaje
dirPersonajes = dir('.\dataset\train\personajes\*');
dirPersonajes = dirPersonajes([dirPersonajes.isdir]);
% Eliminar directorios . y ..
dirPersonajes = dirPersonajes(~ismember({dirPersonajes.name}, {'.', '..'}));
numPersonajes = numel(dirPersonajes);

% Crear carpetas necesarias
outFolder = fullfile('out');
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end
outFolderPersonajes = fullfile(outFolder, 'personajes');
if ~exist(outFolderPersonajes, 'dir')
    mkdir(outFolderPersonajes);
end

fprintf('Procesando datos de %d personajes...\n', numPersonajes);

% Procesar cada personaje
for p = 1:numPersonajes
    nombrePersonaje = dirPersonajes(p).name;
    fprintf('Procesando personaje: %s\n', nombrePersonaje);
    
    % Obtener imágenes tanto de absent como present
    rutaAbsent = fullfile('.\dataset\train\personajes', nombrePersonaje, 'absent', '*.jpg');
    rutaPresent = fullfile('.\dataset\train\personajes', nombrePersonaje, 'present', '*.jpg');
    
    imagenesAbsent = dir(rutaAbsent);
    imagenesPresent = dir(rutaPresent);
    
    % Total de imágenes para este personaje
    numImagenesAbsent = numel(imagenesAbsent);
    numImagenesPresent = numel(imagenesPresent);
    numTotalImagenes = numImagenesAbsent + numImagenesPresent;
    
    fprintf('  Imágenes absent: %d, Imágenes present: %d\n', numImagenesAbsent, numImagenesPresent);
    
    % Inicializar tabla y vector de índices de test
    T_entradasPersonaje = [];
    test_idx = false(numTotalImagenes, 1);
    
    % Procesar imágenes absent (clase 0)
    for i = 1:numImagenesAbsent
        idx10 = mod(i-1, 10) + 1;
        if idx10 <= 7
            esTest = 0; % entrenamiento
        else
            esTest = 1; % test
            test_idx(i) = true;
        end
        
        fila = [ string(imagenesAbsent(i).name), ...
                 string(imagenesAbsent(i).folder), ...
                 0, ... % Clase 0 (absent)
                 esTest ];
        T_entradasPersonaje = [T_entradasPersonaje; fila];
    end
    
    % Procesar imágenes present (clase 1)
    for i = 1:numImagenesPresent
        idx10 = mod(i-1, 10) + 1;
        if idx10 <= 7
            esTest = 0; % entrenamiento
        else
            esTest = 1; % test
            test_idx(i + numImagenesAbsent) = true;
        end
        
        fila = [ string(imagenesPresent(i).name), ...
                 string(imagenesPresent(i).folder), ...
                 1, ... % Clase 1 (present)
                 esTest ];
        T_entradasPersonaje = [T_entradasPersonaje; fila];
    end
    
    % Calcular y mostrar el porcentaje de imágenes de entrenamiento
    col4 = cellfun(@str2double, cellstr(T_entradasPersonaje(:,4)));
    numTrain = sum(col4 == 0);
    porcTrain = 100 * numTrain / numTotalImagenes;
    fprintf('  Porcentaje de imágenes de entrenamiento: %.2f%% (%d de %d)\n', porcTrain, numTrain, numTotalImagenes);
    
    % Generar tabla solo con las de test
    T_entradasPersonajeTest = T_entradasPersonaje(col4 == 1, :);
      % Crear nombres de archivos sin espacios y carpeta específica para este personaje
    nombreArchivo = strrep(nombrePersonaje, ' ', '_');
    
    % Crear carpeta específica para este personaje
    outFolderPersonajeEspecifico = fullfile(outFolderPersonajes, nombreArchivo);
    if ~exist(outFolderPersonajeEspecifico, 'dir')
        mkdir(outFolderPersonajeEspecifico);
    end
    
    % Nombrar los archivos
    archT_entradas = 'T_entradas_' + string(nombreArchivo) + '.mat';
    archT_entradasTest = 'T_entradas_' + string(nombreArchivo) + '_TEST.mat';
    
    % Guardar los archivos en la subcarpeta específica del personaje
    T_entradas = T_entradasPersonaje;
    T_entradasTest = T_entradasPersonajeTest;
    save(fullfile(outFolderPersonajeEspecifico, archT_entradas), 'T_entradas');
    save(fullfile(outFolderPersonajeEspecifico, archT_entradasTest), 'T_entradasTest');
    
    fprintf('  Archivos guardados en %s: %s y %s\n', outFolderPersonajeEspecifico, archT_entradas, archT_entradasTest);
end

fprintf('Procesamiento completo. Todos los archivos han sido guardados en %s\n', outFolderPersonajes);