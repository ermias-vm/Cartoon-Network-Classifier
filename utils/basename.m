function name = basename(path)
% BASENAME devuelve el nombre del archivo sin la extensión
% Syntax: name = basename('c:/folder/file.ext') devuelve 'file'

[~, name, ~] = fileparts(path);
end
