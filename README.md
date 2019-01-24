# Semi-blind Sparse Affine Spectral Unmixing (SSASU)

bioRxiv: [https://doi.org/10.1101/529008](https://doi.org/10.1101/529008)

Spectral unmixing methods attempt to determine the concentrations of different fluorophores present at each pixel location in an image by analyzing a set of measured emission spectra. Unmixing algorithms have shown great promise for applications where samples contain many fluorescent labels; however, existing methods perform poorly when confronted with autofluorescence-contaminated images. We propose an unmixing algorithm designed to separate fluorophores with overlapping emission spectra from contamination by autofluorescence and background fluorescence. The semi-blind sparse affine spectral unmixing (SSASU) algorithm uses knowledge of fluorophore endmembers to learn the autofluorescence and background fluorescence spectra on a per-image basis. When unmixing real-world spectral images contaminated by autofluorescence, SSASU has shown similar reconstruction error but greatly improved proportion indeterminacy as compared to existing methods. This repository contains the source code and test images used to evaluate SSASU.

## Source Code

The Julia source code for SSASU can be found in the `src` directory. There, you will also find the source code for a novel endmember estimation method based on affine nonnegative matrix factorization, a script for performing nonnegative least squares in MATLAB, a plugin for performing PoissonNMF in ImageJ, and evaluation scripts for benchmarking.

## Data

Test images and their associated reference images can be found in the `data` directory.
