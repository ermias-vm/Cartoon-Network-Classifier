function cerrarBarraProgreso(progressFig)
% CERRARBARRAPROGRESO Cierra la figura que contiene una barra de progreso
%
% Uso:
%   cerrarBarraProgreso(progressFig)
%
% Parámetros:
%   progressFig - Estructura devuelta por crearBarraProgreso

    % Cerrar la figura si existe
    if isstruct(progressFig) && isfield(progressFig, 'figura') && ishandle(progressFig.figura)
        close(progressFig.figura);
    elseif ishandle(progressFig)
        % Para compatibilidad con versiones anteriores
        fig = getappdata(progressFig, 'figura');
        if ishandle(fig)
            close(fig);
        end
    end
end
