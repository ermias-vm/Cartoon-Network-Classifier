function [barra, texto] = crearBarraProgreso(titulo, posicion)
% CREARBARRAPROGRESO Crea una barra de progreso visual
%   [barra, texto] = CREARBARRAPROGRESO(titulo, posicion) crea una figura con
%   una barra de progreso y texto informativo. Devuelve handles a la barra y al
%   texto para actualizarlos durante el proceso.

    % Valores por defecto
    if nargin < 1
        titulo = 'Progreso';
    end
    if nargin < 2
        posicion = [300 300 500 100];
    end
    
    % Crear figura
    fig = figure('Name', titulo, 'NumberTitle', 'off', ...
                 'MenuBar', 'none', 'ToolBar', 'none', 'Position', posicion);
    
    % Crear barra de progreso (inicialmente vacía)
    barra = uicontrol('Style', 'text', 'Position', [50 50 1 30], ...
                     'BackgroundColor', [0.8 0.9 0.8]);
    
    % Crear texto informativo
    texto = uicontrol('Style', 'text', 'Position', [50 20 400 20], ...
                      'String', 'Iniciando...');
    
    % Asegurar que la figura se actualiza
    drawnow;
    
    % Añadir la figura al handle para poder cerrarla después
    setappdata(barra, 'figura', fig);
end
