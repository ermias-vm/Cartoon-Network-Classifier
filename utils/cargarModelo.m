function modelo = cargarModelo(modeloPath)
% CARGARMODELO Carga un modelo entrenado desde un archivo .mat
%
% Uso:
%   modelo = cargarModelo(modeloPath)
%
% Parámetros:
%   modeloPath - Ruta al archivo .mat que contiene el modelo
%
% Salida:
%   modelo - Modelo cargado

    try
        modeloVar = erase(basename(modeloPath), '.mat');
        tmp = load(modeloPath);
        modelo = tmp.(modeloVar);
    catch e
        error('Error al cargar el modelo desde %s: %s', modeloPath, e.message);
    end
end
