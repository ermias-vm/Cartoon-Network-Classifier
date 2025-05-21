function actualizarBarraProgreso(progressFig, actual, total, mensaje, tipo)
% ACTUALIZARBARRAPROGRESO Actualiza una barra de progreso visual
%
% Uso:
%   actualizarBarraProgreso(progressFig, actual, total, mensaje, tipo)
%
% Parámetros:
%   progressFig - Estructura devuelta por crearBarraProgreso
%   actual - Valor actual del progreso
%   total - Valor total para el progreso
%   mensaje - Mensaje a mostrar (opcional)
%   tipo - Tipo de barra a actualizar ('simple', 'current', 'global')

    % Valor por defecto para tipo
    if nargin < 5 || isempty(tipo)
        if ~isstruct(progressFig) || ~isfield(progressFig, 'currentProgressBar')
            tipo = 'simple';
        else
            tipo = 'current';
        end
    end
    
    % Calcular porcentaje
    if total > 0
        porcentaje = actual / total;
    else
        porcentaje = 0;
    end
    
    % Mensaje por defecto
    if nargin < 4 || isempty(mensaje)
        mensaje = sprintf('Procesando: %d/%d (%.1f%%)', actual, total, porcentaje * 100);
    end
    
    % Actualizar según el tipo
    switch lower(tipo)
        case 'simple'
            if isfield(progressFig, 'progressBar') && ishandle(progressFig.progressBar)
                set(progressFig.progressBar, 'Position', [50 50 floor(400 * porcentaje) 30]);
            end
            if isfield(progressFig, 'progressText') && ishandle(progressFig.progressText)
                set(progressFig.progressText, 'String', mensaje);
            end
            
        case 'current'
            if isfield(progressFig, 'currentProgressBar') && ishandle(progressFig.currentProgressBar)
                set(progressFig.currentProgressBar, 'Position', [50 progressFig.currentProgressBar.Position(2) floor(400 * porcentaje) 20]);
            end
            if isfield(progressFig, 'currentProgressText') && ishandle(progressFig.currentProgressText)
                set(progressFig.currentProgressText, 'String', mensaje);
            end
            
        case 'global'
            if isfield(progressFig, 'globalProgressBar') && ishandle(progressFig.globalProgressBar)
                set(progressFig.globalProgressBar, 'Position', [50 40 floor(400 * porcentaje) 20]);
            end
            if isfield(progressFig, 'globalProgressText') && ishandle(progressFig.globalProgressText)
                set(progressFig.globalProgressText, 'String', mensaje);
            end
    end
    
    % Refrescar pantalla
    drawnow;
end
