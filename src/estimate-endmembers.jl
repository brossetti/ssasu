module EstimateEndmembers

using Images
using Statistics
using DelimitedFiles

export run

"""
```
thres = triangle_threshold(img)
thres = triangle_threshold(img, bins)
```
Computes threshold for grayscale image using the Triangle algorithm
Parameters:
-    img         = Grayscale input image
-    bins        = Number of bins used to compute the histogram. Needed for floating-point images.
#Citation
Zack GW, Rogers WE, Latt SA. Automatic measurement of sister chromatid exchange frequency. Journal of Histochemistry & Cytochemistry. 1977 Jul;25(7):741-53.
"""
function triangle_threshold(img::AbstractArray{T, N}, bins::Int = 256, offset=0.2) where {T<:Union{Gray, Real}, N}

    minval, maxval = extrema(img)
    if(minval == maxval)
        return T(minval)
    end

    hist_edges, hist_vals = imhist(img, range(gray(minval); stop=gray(maxval), length=bins))

    # find max and min histogram values and indices
    hist_minval = Inf
    hist_maxval = -1
    hist_mininds = Array{Int,1}(undef,0)
    hist_maxinds = Array{Int,1}(undef,0)
    for i = 1:bins
        if hist_vals[i] < hist_minval
            hist_minval = hist_vals[i]
            hist_mininds = [i]
        elseif hist_vals[i] == hist_minval
            append!(hist_mininds,i)
        elseif hist_vals[i] > hist_maxval
            hist_maxval = hist_vals[i]
            hist_maxinds = [i]
        elseif hist_vals[i] == hist_maxval
            append!(hist_maxinds,i)
        end
    end

    # determine best min and max
    hist_minidx = -1
    hist_maxidx= -1
    bin_dist = -1
    for i in hist_mininds, j in hist_maxinds
        dist_tmp = abs(i - j)
        if dist_tmp > bin_dist
            hist_minidx = i
            hist_maxidx = j
            bin_dist = dist_tmp
        end
    end

    # measure leg from histogram top to hypotenuse
    if hist_minidx < hist_maxidx
        start_idx = hist_minidx+1
        stop_idx = hist_maxidx-1
    else
        start_idx = hist_maxidx+1
        stop_idx = hist_minidx-1
    end

    h = -1.0
    t = 0
    for i = start_idx:stop_idx
        h_tmp = (abs(hist_minidx-i)/Float64(bin_dist))-((hist_vals[i]-hist_minval)/(hist_maxval-hist_minval))
        if h_tmp > h
            h = h_tmp
            t = i
        end
    end

    return T((hist_edges[t]+hist_edges[t+1])/2.0)
end

function img_mask(img)
    imgl1 = dropdims(sum(img,dims=3);dims=3)
    mask = imgl1 .> triangle_threshold(imgl1)
    return mask
end

function anmf(R; maxiter::Int=1000, tol::Float32=1f-4, ϵ::Float32=eps(Float32),
              verbose::Bool=true)
    M,P = size(R)

    # half-wave rectifier
    hwr = (x) -> max(x,ϵ)

    # euclidean cost function
    cost_fn = (x,x_hat) -> 0.5f0*sqrt(sum((x-x_hat).^2))

    # initialize
    s = hwr.(rand(M,1))
    w = hwr.(rand(1,P))
    b = hwr.(rand(M,1))
    Rhwr = hwr.(R)
    Rhwr_hat = zeros(M,P)
    err = [Inf]
    Rsum = sum(R,dims=2)

    # start minimization
    for iter = 0:(maxiter-1)
        # new estimate
        Rhwr_hat .= hwr.(s*w .+ b)

        # updates
        w .= w .* (transpose(s) * Rhwr) ./ (transpose(s) * Rhwr_hat)
        s .= s .* (Rhwr * transpose(w)) ./ (Rhwr_hat * transpose(w))
        s ./= maximum(s)
        b .= b .* (Rsum./sum(Rhwr_hat,dims=2))

        # correct for negatives
        @. w = hwr(w)
        @. s = hwr(s)
        @. b = hwr(b)

        # error
        if (mod(iter,20) == 0) || (iter == maxiter)
            append!(err, cost_fn(Rhwr,Rhwr_hat))
            Δ = abs(err[end] - err[end-1])
            verbose && println(err[end])

            if (err[end] < 1f-5) | (Δ < tol)
                break
            end
        end
    end

    # threshold
    s[s .<= ϵ] .= 0.0f0
    b[b .<= ϵ] .= 0.0f0

    return s,b
end

function estimate_endmember(img, mask)
    py,px,M = size(img)
    P = py*px

    # estimate s as average of foreground
    s_avg = zeros(Float32,M)
    @simd for m = 1:M
        s_avg[m] = mean(img[:,:,m][mask])
    end
    s_avg ./= maximum(s_avg);

    # estimate s using Affine NMF
    R = transpose(reshape(img,(P,M)))
    s_anmf,b = anmf(R; verbose=false)

    return s_avg,s_anmf
end

function run()
    println("Estimating endmembers from reference images...")
    ref_filenames = ["D-TDFH2-NP.tif",
                     "DY415.tif",
                     "DY490.tif",
                     "AT520.tif",
                     "AT550.tif",
                     "TRX.tif",
                     "AT620.tif",
                     "AT655.tif"]

    M = 26
    N = length(ref_filenames)

    S_avg = zeros(Float32,M,N)
    S_anmf = zeros(Float32,M,N)
    @simd for n = 1:N
        ref_filename = joinpath("..","data","ref",ref_filenames[n])
        img = convert(Array{Float32},load(ref_filename))
        mask = img_mask(img)
        mask_filename = joinpath("..","results","masks",
                            string(splitext(ref_filenames[n])[1],"-mask.tif"))
        save(mask_filename, Gray.(mask))
        S_avg[:,n],S_anmf[:,n] = estimate_endmember(img,mask)
    end

    writedlm(joinpath("..","results","mean-estimated-endmembers.csv"), S_avg, ",")
    writedlm(joinpath("..","results","anmf-estimated-endmembers.csv"), S_anmf, ",")

    return S_avg,S_anmf
end

end  # module EstimateEndmembers
