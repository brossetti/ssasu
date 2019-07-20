# Source Code

This directory contains all of the source code used to produce the figures in the SSASU manuscript. Below you will find a list of the files and a brief description of their purpose.

#### `estimate-endmembers.jl` - 
A Julia module that contains functions for estimating endmembers from reference images using either the Mean method or the ANMF method.

#### `evaluate.jl` -
A Julia module that contains functions for calculating the Spectral Angle, Relative Reconstruction Error (RRE), and Proportion Indeterminacy (PI).

#### `figs.R` - 
An R script for generating figures from the results of `evaluate.jl`.

#### `nls.m` -
A MATLAB script for performing nonnegative least squares (NLS) on the test images.

#### `poissonnmf.ijm` -
An ImageJ/Fiji macro for performing PoissonNMF with the settings used in the manuscript.

#### `sparse_unmixing.m` -
A MATLAB script for performing SUnSAL (`sunsal.m`) and SUnSAL-TV (`sunsal_tv.m`) on the test images.

#### `ssasu.jl` -
A Julia module that performs semi-blind sparse affine spectral unmixing (SSASU) on the test images.

#### `sunsal.m` -
A MATLAB function for sparse unmixing via variable splitting and augmented Lagrangian methods (SUnSAL) written by Jose Bioucas-Dias in 2009 ([source](http://www.lx.it.pt/~bioucas/code/sunsal_demo.zip)). For more details, see Bioucas-Dias and Figueiredo, (2010). Alternating direction algorithms for constrained sparse regression: Application to hyperspectral unmixing. In *2nd Workshop on Hyperspectral Image and Signal Processing: Evolution in Remote Sensing* (pp. 1-4). IEEE.

#### `sunsal_tv.m` -
A MATLAB function for sparse unmixing with total variation via variable splitting and augmented Lagrangian methods (SUnSAL-TV) written by Jose Bioucas-Dias in 2010 ([source](http://www.lx.it.pt/~bioucas/code/demo_sparse_tv.rar)). For more details, see Iordache, Bioucas-Dias, and Plaza, (2012). Total variation spatial regularization for sparse hyperspectral unmixing. *IEEE Transactions on Geoscience and Remote Sensing*, 50(11), 4484-4502.
