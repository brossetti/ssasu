# Source Code

This directory contains all of the source code using to produce the figures in the SSASU manuscript. Below you will find a list of the files and a brief description of their purpose.

#### `estimate-endmembers.jl` - 
A Julia module that contains functions for estimating endmembers from reference images using either the Mean method or the ANMF method.

#### `evaluate.jl` -
A Julia module that contains functions for calculating the Spectral Angle, Relative Reconstruction Error (RRE), and Proportion Indeterminacy (PI).

#### `figs.R` - 
An R script for generating figures from the results of `evaluate.jl`.

#### `nls.m` -
A MATLAB script for performing nonnegative least squares (NLS) on the test images

#### `poissonnmf.ijm` -
An ImageJ/Fiji macro for performing PoissonNMF with the settings used in the manuscript.

#### `ssasu.jl` -
A Julia module that performs semi-blind sparse affine spectral unmixing (SSASU) on the test images.
