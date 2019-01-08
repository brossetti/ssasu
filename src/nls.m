% Spectral Unmixing by Lawson-Hanson NLS

% load endmember data from CSV
try
    S = csvread(fullfile("..","results","estimated-endmembers.csv"));
catch
    error("No estimated-endmembers.csv file found");
end

% test images
exp_filenames = ["E-TDFH2-1.tif";
                 "E-TDFH2-2.tif";
                 "F-TDFH2-1.tif";
                 "F-TDFH2-2.tif";
                 "N-TDFH2-1.tif";
                 "N-TDFH2-2.tif";
                 "X-TDFH2-1.tif";
                 "X-TDFH2-2.tif";
                 "Z-TDFH2-1.tif";
                 "Z-TDFH2-2.tif"];

% image dimensions
[M,N] = size(S);
py = 1024;
px = 1024;
P = py*px;

% load data and run NLS
Y = zeros(M,P);             
for i = 1:length(exp_filenames)
    for m = 1:M
        tmp = imread(fullfile("..","data","test",exp_filenames(i)),m);
        Y(m,:) = double(tmp(:))./65535;
    end
    
    W = zeros(P,N);
    parfor p = 1:P
        W(p,:) = lsqnonneg(S,Y(:,p));
    end
    
    W = uint8(reshape(W, [py,px,N]).*255);
    
    [~,filename,~] = fileparts(exp_filenames(i));
    result_path = fullfile("..","results","nls",strcat(filename, "-nls.tif"));
    imwrite(W(:,:,1), result_path);
    for n = 2:N
        imwrite(W(:,:,n), result_path, 'writemode', 'append')
    end
end