function mostrarDistribucionSeries(seriesNames, rutaBase)
% MOSTRARDISTRIBUCIONSERIES Muestra estadísticas de distribución de imágenes por serie
%   MOSTRARDISTRIBUCIONSERIES(seriesNames, rutaBase) cuenta las imágenes en cada
%   carpeta de serie y muestra una tabla con los resultados.

    fprintf('\n  DISTRIBUCIÓN DE IMÁGENES POR SERIE:\n\n');
    fprintf('  %-20s %10s\n', 'SERIE', 'IMÁGENES');
    fprintf('  %-20s %10s\n', '-----------------', '--------');
    
    totalImagenes = 0;
    
    for i = 1:length(seriesNames)
        carpetaSerie = fullfile(rutaBase, seriesNames{i});
        numImagenes = 0;
        
        if exist(carpetaSerie, 'dir')
            archivos = dir(fullfile(carpetaSerie, '*.jpg'));
            numImagenes = numel(archivos);
            totalImagenes = totalImagenes + numImagenes;
        end
        
        fprintf('  %-20s %10d\n', seriesNames{i}, numImagenes);
    end
    
    % Mostrar el total
    fprintf('  %-20s %10s\n', '-----------------', '--------');
    fprintf('  %-20s %10d\n', 'TOTAL', totalImagenes);
end
