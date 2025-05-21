function progressFig = crearBarraProgreso(titulo, ancho, alto)
% CREARBARRAPROGRESO Crea una figura con una barra de progreso
%
% Uso:
%   progressFig = crearBarraProgreso(titulo, ancho, alto)
%
% Parámetros:
%   titulo - Título para la ventana
%   ancho - Ancho de la ventana en pixels
%   alto - Alto de la ventana en pixels
%
% Salida:
%   progressFig - Estructura con los elementos de la interfaz

    if nargin < 1
        titulo = 'Progreso';
    end
    if nargin < 2
        ancho = 500;
    end
    if nargin < 3
        alto = 100;
    end

    % Crear la figura
    figura = figure('Name', titulo, 'NumberTitle', 'off', ...
                   'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 ancho alto]);
    
    % Para barra de progreso simple
    if alto <= 100
        % Crear una barra de progreso
        progressBar = uicontrol('Style', 'text', 'Position', [50 50 1 30], ...
                               'BackgroundColor', [0.8 0.9 0.8]);
        
        % Texto para mostrar el progreso
        progressText = uicontrol('Style', 'text', 'Position', [50 20 ancho-100 20], ...
                                'String', 'Iniciando procesamiento...');
        
        % Devolver la estructura con los elementos
        progressFig = struct('figura', figura, 'progressBar', progressBar, 'progressText', progressText);
    else
        % Para barra de progreso con más elementos (como el global + actual)
        
        % Texto para el nombre de la serie actual
        serieLabel = uicontrol('Style', 'text', 'Position', [50 alto-30 ancho-100 20], ...
                              'String', 'Iniciando procesamiento...', 'FontWeight', 'bold');
        
        % Barra de progreso para la serie actual
        currentProgressBar = uicontrol('Style', 'text', 'Position', [50 alto-60 1 20], ...
                                      'BackgroundColor', [0.8 0.9 0.8]);
        
        % Texto para el progreso de la serie actual
        currentProgressText = uicontrol('Style', 'text', 'Position', [50 alto-80 ancho-100 20], ...
                                       'String', 'Preparando...');
        
        % Barra de progreso global
        globalProgressBar = uicontrol('Style', 'text', 'Position', [50 40 1 20], ...
                                     'BackgroundColor', [0.8 0.8 0.9]);
        
        % Texto para el progreso global
        globalProgressText = uicontrol('Style', 'text', 'Position', [50 20 ancho-100 20], ...
                                      'String', 'Progreso total: 0%');
        
        % Si es para personajes, agregar un área para la tabla de resultados
        if contains(lower(titulo), 'personaje')
            resultTable = uicontrol('Style', 'text', 'Position', [50 80 ancho-100 40], ...
                                   'String', '', 'HorizontalAlignment', 'left');
            progressFig = struct('figura', figura, 'serieLabel', serieLabel, ...
                                'currentProgressBar', currentProgressBar, 'currentProgressText', currentProgressText, ...
                                'globalProgressBar', globalProgressBar, 'globalProgressText', globalProgressText, ...
                                'resultTable', resultTable);
        else
            progressFig = struct('figura', figura, 'serieLabel', serieLabel, ...
                                'currentProgressBar', currentProgressBar, 'currentProgressText', currentProgressText, ...
                                'globalProgressBar', globalProgressBar, 'globalProgressText', globalProgressText);
        end
    end
    
    drawnow;
end
