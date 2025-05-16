function actualizarBarraProgreso(barra, texto, actual, total, mensaje)
% ACTUALIZARBARRAPROGRESO Actualiza una barra de progreso visual
%   ACTUALIZARBARRAPROGRESO(barra, texto, actual, total, mensaje) actualiza
%   la barra de progreso y el texto informativo según el progreso actual.

    % Calcular porcentaje
    if total > 0
        porcentaje = actual / total;
    else
        porcentaje = 0;
    end
    
    % Actualizar barra
    set(barra, 'Position', [50 50 floor(400 * porcentaje) 30]);
    
    % Mensaje por defecto
    if nargin < 5 || isempty(mensaje)
        mensaje = sprintf('Procesando: %d/%d (%.1f%%)', actual, total, porcentaje * 100);
    end
    
    % Actualizar texto
    set(texto, 'String', mensaje);
    
    % Refrescar pantalla
    drawnow;
end
