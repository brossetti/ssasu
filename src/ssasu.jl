module SSASU

using Images
using DelimitedFiles

export run

function ssasu(S, Y, free::Array{Int,1}; γ::Float32=0.0f0, maxiter::Int=1000,
               tol::Float32=1f-4, ϵ::Float32=eps(Float32), verbose::Bool=true)
    M,P = size(Y)
    N = size(S,2)

    # half-wave rectifier
    hwr = (x) -> max(x,ϵ)

    # euclidean cost function
    cost_fn = (x,x_hat) -> 0.5f0*sqrt(sum((x-x_hat).^2))

    # initialize
    b = hwr.(rand(M,1))
    W = hwr.(rand(N,P))
    Yhwr = hwr.(Y)
    Yhwr_hat = zeros(M,P)
    err = [Inf]
    S_e = copy(S)
    Ysum = sum(Y,dims=2)

    # start minimization
    for iter = 0:(maxiter-1)
        # new estimate
        Yhwr_hat .= hwr.(S_e*W .+ b)

        # updates
        W .= W .* (transpose(S_e) * Yhwr) ./ (transpose(S_e) * Yhwr_hat .+ γ)
        S_e[:,free] .= S_e[:,free] .* (Yhwr * transpose(W[free,:])) ./ (Yhwr_hat * transpose(W[free,:]))
        S_e[:,free] = S_e[:,free]./maximum(S_e[:,free],dims=1)
        b .= b .* (Ysum./sum(Yhwr_hat,dims=2))

        # correct for negatives
        @. W = hwr(W)
        @. S_e = hwr(S_e)
        @. b = hwr(b)

        # error
        if (mod(iter,20) == 0) || (iter == maxiter)
            append!(err, cost_fn(Yhwr,Yhwr_hat))
            Δ = abs(err[end] - err[end-1])
            verbose && println(err[end])

            if (err[end] < 1f-5) | (Δ < tol)
                break
            end
        end
    end

    # threshold
    S_e[S_e .<= ϵ] .= 0.0f0
    W[W .<= ϵ] .= 0.0f0
    b[b .<= ϵ] .= 0.0f0

    return S_e, W, b, err[2:end]
end

function run(S)
    exp_filenames = ["E-TDFH2-1.tif",
                     "E-TDFH2-2.tif",
                     "F-TDFH2-1.tif",
                     "F-TDFH2-2.tif",
                     "N-TDFH2-1.tif",
                     "N-TDFH2-2.tif",
                     "X-TDFH2-1.tif",
                     "X-TDFH2-2.tif",
                     "Z-TDFH2-1.tif",
                     "Z-TDFH2-2.tif"]
    N = size(S,2)

    println("Running SSASU...")
    for i = 1:length(exp_filenames)
        # load image
        exp_filename = joinpath("..","data","test",exp_filenames[i])
        img = convert(Array{Float32},load(exp_filename))
        py,px,M = size(img)
        P = py*px
        Y = transpose(reshape(img,(P,M)))

        # optimization
        S[:,1] = rand(M,1)
        S_e, W, b, err = ssasu(S,Y,[1]; γ=0.009f0, tol=1f-4, verbose=true)

        # save results
        filename = splitext(exp_filenames[i])[1]
        spectra_filename = joinpath("..","results","ssasu",
                            string(filename,"-ssasu-S.csv"))
        bgnd_filename = joinpath("..","results","ssasu",
                            string(filename,"-ssasu-b.csv"))
        unmixed_filename = joinpath("..","results","ssasu",
                            string(filename,"-ssasu.tif"))
        writedlm(spectra_filename, S_e, ",")
        writedlm(bgnd_filename, b, ",")
        save(unmixed_filename, Gray.(reshape(transpose(map(clamp01,W)),(py,px,N))))

    end

    return true
end

function run()
    S = Array{Float32,2}(undef,0,0)
    try
        S = readdlm(joinpath("..","results","anmf-estimated-endmembers.csv"), ',', Float32)
    catch
        error("No anmf-estimated-endmembers.csv file found")
    end

    return run(S)
end

end  # module SSASU
