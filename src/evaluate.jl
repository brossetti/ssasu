module Evaluate

using Images
using DelimitedFiles
using Statistics
using LinearAlgebra

export run

function rmse(error)
    return sqrt(mean(error.^2))
end

function run()
    exp_filenames = ["E-TDFH2-1",
                     "E-TDFH2-2",
                     "F-TDFH2-1",
                     "F-TDFH2-2",
                     "N-TDFH2-1",
                     "N-TDFH2-2",
                     "X-TDFH2-1",
                     "X-TDFH2-2",
                     "Z-TDFH2-1",
                     "Z-TDFH2-2"]
    nimgs = length(exp_filenames)
    rmse_residual = zeros(Float32,(nimgs,2))
    rmse_indeterminacy = zeros(Float32,(nimgs,2))

    # evaluate
    S_nls = readdlm(joinpath("..","results","mean-estimated-endmembers.csv"), ',', Float32)
    for i = 1:nimgs
        # load original image
        org_filename = joinpath("..","data","test",string(exp_filenames[i], ".tif"))
        img = convert(Array{Float32},load(org_filename))
        py,px,M = size(img)
        P = py*px
        Y = transpose(reshape(img,(P,M)))

        # evaluate NLS
        unmixed_filename = joinpath("..","results","nls",string(exp_filenames[i], "-nls.tif"))
        img = convert(Array{Float32},load(unmixed_filename))
        N = size(img,3)
        W = transpose(reshape(img,(P,N)))
        Y_hat = S_nls*W
        rmse_residual[i,1] = rmse(Y_hat - Y)
        rmse_indeterminacy[i,1] = rmse((W*transpose(W)) - diagm(0=>dropdims(sum(W.^2,dims=2),dims=2)))

        # evaluate SANMF
        S_sanmf = readdlm(joinpath("..","results","sanmf",string(exp_filenames[i],"-sanmf-S.csv")), ',', Float32)
        b = readdlm(joinpath("..","results","sanmf",string(exp_filenames[i],"-sanmf-b.csv")), ',', Float32)
        unmixed_filename = joinpath("..","results","sanmf",string(exp_filenames[i], "-sanmf.tif"))
        img = convert(Array{Float32},load(unmixed_filename))
        N = size(img,3)
        W = transpose(reshape(img,(P,N)))
        Y_hat = S_sanmf*W .+ b
        rmse_residual[i,2] = rmse(Y_hat - Y)
        rmse_indeterminacy[i,2] = rmse((W*transpose(W)) - diagm(0=>dropdims(sum(W.^2,dims=2),dims=2)))

    end

    writedlm(joinpath("..","results","rmse_residual.csv"), rmse_residual, ",")
    writedlm(joinpath("..","results","rmse_indeterminacy.csv"), rmse_indeterminacy, ",")
end

end  # module Evaluate
