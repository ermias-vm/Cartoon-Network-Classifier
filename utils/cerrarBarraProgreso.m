function cerrarBarraProgreso(barra)
% CERRARBARRAPROGRESO Cierra la figura que contiene una barra de progreso
%   CERRARBARRAPROGRESO(barra) cierra la figura que contiene la barra de
%   progreso indicada.

    % Obtener la figura asociada a la barra
    fig = getappdata(barra, 'figura');
    
    % Cerrar la figura si existe
    if ishandle(fig)
        close(fig);
    end
end
