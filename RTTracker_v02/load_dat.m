function [image,dimx,dimy,dimz,no_dyn] = load_dat(file_name)

disp('Loading data file...');

%% Open the data file
% f = fopen(file_name, 'r');
info = dicominfo(file_name);
f1 = dicomread(info);

%% Extract the header size
% header_size = fread(f, 1, 'int');
header_size = 2;
%% Extract the header data
% header = fread(f, header_size, 'int');

%% Store image resolution parameters
% dimx = header(1);
% dimy = header(2);
% if (header_size == 3)
%   dimz   = 1;
%   no_dyn = header(3);
% end
% if (header_size == 4)
%   dimz   = header(3);
%   no_dyn = header(4);
% end
dimx = 256;
dimy = 216;
dimz = 1;
no_dyn = 1;
%% Extract data from file
% image = fread(f, 'float');
% image = reshape(dimx,dimy,dimz,no_dyn);
image = f;
%% Close data file
% fclose(f);
