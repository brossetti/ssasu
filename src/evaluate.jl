module Evaluate

using Images
using DelimitedFiles
using Statistics
using LinearAlgebra

export run

function rre(Y,Y_hat)
    fnormerr = sqrt(sum((Y-Y_hat).^2))
    return fnormerr/sqrt(sum(Y.^2))
end

function prop_ind(W)
    WW = W*transpose(W)
    D = diagm(0=>dropdims(sum(W.^2,dims=2),dims=2))
    return sqrt(sum((WW - D).^2))/sqrt(sum(D.^2))
end

function sad(X,Y)
    denom = dropdims(sqrt.(sum(X.^2,dims=1)).*sqrt.(sum(Y.^2,dims=1)),dims=1)
    return acos.(diag(transpose(X)*Y)./denom)
end

function run()
    exp_filenames = ["A-TDFH2-1",
                     "A-TDFH2-2",
                     "B-TDFH2-1",
                     "B-TDFH2-2",
                     "C-TDFH2-1",
                     "C-TDFH2-2",
                     "D-TDFH2-1",
                     "D-TDFH2-2",
                     "E-TDFH2-1",
                     "E-TDFH2-2"]
    nimgs = length(exp_filenames)
    reconstruction_error = zeros(Float32,(nimgs,5))
    proportion_indeterminacy = zeros(Float32,(nimgs,5))

    # evaluate unmixing
    S_anmf = readdlm(joinpath("..","results","anmf-estimated-endmembers.csv"), ',', Float32)
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
        Y_hat = S_anmf*W
        reconstruction_error[i,1] = rre(Y,Y_hat)
        proportion_indeterminacy[i,1] = prop_ind(W)

        # evaluate PoissonNMF
        S_pnmf = readdlm(joinpath("..","results","poissonnmf",string(exp_filenames[i],"-pnmf-S.csv")), ',', Float32)
        unmixed_filename = joinpath("..","results","poissonnmf",string(exp_filenames[i], "-pnmf.nrrd"))
        img = convert(Array{Float32},load(unmixed_filename))
        N = size(img,3)
        for n = 1:N
            img[:,:,n] = transpose(img[:,:,n]) # flip each unmixed channel
        end
        W = transpose(reshape(img,(P,N)))
        S_pnmf = S_pnmf.*6.8f0 # undo division by 6.8 from saving spectra in PoissonNMF
        W = (W.-1.0f0)./2^16 # properly scale weights to original image
        Y_hat = S_pnmf*W
        reconstruction_error[i,2] = rre(Y,Y_hat)
        proportion_indeterminacy[i,2] = prop_ind(W)

        # evaluate SSASU
        S_ssasu = readdlm(joinpath("..","results","ssasu",string(exp_filenames[i],"-ssasu-S.csv")), ',', Float32)
        b = readdlm(joinpath("..","results","ssasu",string(exp_filenames[i],"-ssasu-b.csv")), ',', Float32)
        unmixed_filename = joinpath("..","results","ssasu",string(exp_filenames[i], "-ssasu.tif"))
        img = convert(Array{Float32},load(unmixed_filename))
        N = size(img,3)
        W = transpose(reshape(img,(P,N)))
        Y_hat = S_ssasu*W .+ b
        reconstruction_error[i,3] = rre(Y,Y_hat)
        proportion_indeterminacy[i,3] = prop_ind(W)

        # evaluate SUnSAL
        unmixed_filename = joinpath("..","results","sunsal",string(exp_filenames[i], "-sunsal.tif"))
        img = convert(Array{Float32},load(unmixed_filename))
        N = size(img,3)
        W = transpose(reshape(img,(P,N)))
        Y_hat = S_anmf*W
        reconstruction_error[i,4] = rre(Y,Y_hat)
        proportion_indeterminacy[i,4] = prop_ind(W)

        # evaluate SUnSAL-TV
        unmixed_filename = joinpath("..","results","sunsal-tv",string(exp_filenames[i], "-sunsal-tv.tif"))
        img = convert(Array{Float32},load(unmixed_filename))
        N = size(img,3)
        W = transpose(reshape(img,(P,N)))
        Y_hat = S_anmf*W
        reconstruction_error[i,5] = rre(Y,Y_hat)
        proportion_indeterminacy[i,5] = prop_ind(W)

    end

    writedlm(joinpath("..","results","reconstruction-error.csv"), reconstruction_error, ",")
    writedlm(joinpath("..","results","proportion-indeterminacy.csv"), proportion_indeterminacy, ",")

    # evaluate endmember estimation
    S_true = readdlm(joinpath("..","data","ref","fluorometer-endmembers.csv"),',',Float32;header=true)[1]
    S_mean = readdlm(joinpath("..","results","mean-estimated-endmembers.csv"), ',', Float32)

    S_true = S_true[:,2:end]
    S_mean = S_mean[:,2:end]
    S_anmf = S_anmf[:,2:end]

    spectral_angle = zeros(Float32,(size(S_true,2),2))
    spectral_angle[:,1] = sad(S_true,S_mean)
    spectral_angle[:,2] = sad(S_true,S_anmf)

    writedlm(joinpath("..","results","spectral-angle.csv"), spectral_angle, ",")

end

end  # module Evaluate
