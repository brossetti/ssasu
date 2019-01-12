module Evaluate

using Images
using DelimitedFiles
using Statistics
using LinearAlgebra

export run

function rre(Y,Y_hat)
    mse = mean(sum((Y-Y_hat).^2,dims=1))
    return mse/mean(sum(Y.^2,dims=1))
end

function prop_ind(W)
    WW = W*transpose(W)
    D = diagm(0=>dropdims(sum(W.^2,dims=2),dims=2))
    return sqrt(sum((WW - D).^2))/sqrt(sum(D.^2))
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
    reconstruction_error = zeros(Float32,(nimgs,2))
    proportion_indeterminacy = zeros(Float32,(nimgs,2))

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
        reconstruction_error[i,1] = rre(Y,Y_hat)
        proportion_indeterminacy[i,1] = prop_ind(W)

        # evaluate SANMF
        S_sanmf = readdlm(joinpath("..","results","sanmf",string(exp_filenames[i],"-sanmf-S.csv")), ',', Float32)
        b = readdlm(joinpath("..","results","sanmf",string(exp_filenames[i],"-sanmf-b.csv")), ',', Float32)
        unmixed_filename = joinpath("..","results","sanmf",string(exp_filenames[i], "-sanmf.tif"))
        img = convert(Array{Float32},load(unmixed_filename))
        N = size(img,3)
        W = transpose(reshape(img,(P,N)))
        Y_hat = S_sanmf*W .+ b
        reconstruction_error[i,2] = rre(Y,Y_hat)
        proportion_indeterminacy[i,2] = prop_ind(W)

    end

    writedlm(joinpath("..","results","reconstruction-error.csv"), reconstruction_error, ",")
    writedlm(joinpath("..","results","proportion-indeterminacy.csv"), proportion_indeterminacy, ",")
end

end  # module Evaluate
