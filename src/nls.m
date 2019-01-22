% Spectral Unmixing by Lawson-Hanson NLS

% load endmember data from CSV
try
    S = csvread(fullfile("..","results","anmf-estimated-endmembers.csv"));
catch
    error("No anmf-estimated-endmembers.csv file found");
end

% test images
exp_filenames = ["A-TDFH2-1.tif";
                 "A-TDFH2-2.tif";
                 "B-TDFH2-1.tif";
                 "B-TDFH2-2.tif";
                 "C-TDFH2-1.tif";
                 "C-TDFH2-2.tif";
                 "D-TDFH2-1.tif";
                 "D-TDFH2-2.tif";
                 "E-TDFH2-1.tif";
                 "E-TDFH2-2.tif"];

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
