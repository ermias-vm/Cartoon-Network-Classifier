function mostrarEncabezado(titulo, caracter)
% MOSTRARENCABEZADO Muestra un título con formato de encabezado
% 
% Uso:
%   mostrarEncabezado(titulo, caracter)
%
% Parámetros:
%   titulo - Texto del título
%   caracter - (Opcional) Caracter para la línea (por defecto: '-')

    if nargin < 2
        caracter = '-';
    end
    
    lineaDecorativa = repmat(caracter, 1, 60);
    
    % Mostrar encabezado con formato
    fprintf('\n%s\n', lineaDecorativa);
    fprintf('          %s\n', upper(titulo));
    fprintf('%s\n', lineaDecorativa);
end
