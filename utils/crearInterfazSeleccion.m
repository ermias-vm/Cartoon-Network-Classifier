function [figura, controles] = crearInterfazSeleccion(titulo, callbacks)
% CREARINTERFAZSELECCION Crea una interfaz de usuario con botones para seleccionar imagen o carpeta
%
% Uso:
%   [figura, controles] = crearInterfazSeleccion(titulo, callbacks)
%
% Parámetros:
%   titulo - Título para la ventana
%   callbacks - Estructura con callbacks para los botones:
%     .imagen - Función de callback para el botón de selección de imagen
%     .carpeta - Función de callback para el botón de selección de carpeta
%
% Salida:
%   figura - Handle de la figura creada
%   controles - Estructura con los controles de la interfaz

    % Crear la figura
    figura = figure('Name', titulo, 'NumberTitle', 'off', ...
                    'MenuBar', 'none', 'ToolBar', 'none', 'Position', [300 300 400 200]);
    
    % Crear los botones
    btnImagen = uicontrol('Style', 'pushbutton', 'String', 'Seleccionar Imagen', ...
                         'Position', [50 120 300 40], 'FontSize', 12, ...
                         'Callback', callbacks.imagen);
    
    btnCarpeta = uicontrol('Style', 'pushbutton', 'String', 'Seleccionar Carpeta', ...
                          'Position', [50 60 300 40], 'FontSize', 12, ...
                          'Callback', callbacks.carpeta);
    
    % Devolver los controles
    controles = struct('btnImagen', btnImagen, 'btnCarpeta', btnCarpeta);
end
