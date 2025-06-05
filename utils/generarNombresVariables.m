function nombres = generarNombresVariables(numBins)
% GENERARNOMBRESVARIABLES Genera los nombres de variables para la tabla de características
%
% Uso:
%   nombres = generarNombresVariables(numBins)
%
% Parámetros:
%   numBins - Número de bins para cada histograma
%
% Salida:
%   nombres - Cell array con los nombres de las variables

    nombres = cell(1, 5 * numBins);
    idx = 1;
    
    % Histograma H (Hue)
    for i = 1:numBins
        nombres{idx} = sprintf('H_%d', i);
        idx = idx + 1;
    end
    
    % Histograma V (Value)
    for i = 1:numBins
        nombres{idx} = sprintf('V_%d', i);
        idx = idx + 1;
    end
    
    % Histograma R (Red)
    for i = 1:numBins
        nombres{idx} = sprintf('R_%d', i);
        idx = idx + 1;
    end
    
    % Histograma G (Green)
    for i = 1:numBins
        nombres{idx} = sprintf('G_%d', i);
        idx = idx + 1;
    end
    
    % Histograma B (Blue)
    for i = 1:numBins
        nombres{idx} = sprintf('B_%d', i);
        idx = idx + 1;
    end
end
