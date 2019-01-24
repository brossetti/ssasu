# Spectral Micrographs
This `test` and `ref` directories contain the testing and reference spectral micrographs, respectively.

## Microscope Setup
All spectral micrographs were acquired on a Zeiss LSM 880 using a 63x/1.4NA Plan-Apochromat objective. Point scanning was performed simultaneously for the 405nm, 488nm, 561nm, and 633nm lasers using the 405 and 488/561/633 dichroic mirrors. Each micrograph was generated as the average of 4 consecutive scans.

## Preprocessing
Since the use of dichroic mirrors blocked the detection of emitted light near 405nm, 488nm, 561nm, and 633nm, each image was preprocessed by removing the dark spectral bands. Specifically, bands 9, 10, 17, 18, 25, and 26 of the original 32-band image were removed.

## Fluorescent Labels
Seven fluorescent labels were used in this data.

| Dye Name | Excitation Max. | Emission Max. | Source |
|----------|-----------------|---------------|--------|
| DY-415 | 418nm | 467nm | Dyomics GmbH |
| DY-490 | 491nm | 515nm | Dyomics GmbH |
| ATTO 520 | 517nm | 538nm | ATTO-TEC GmbH |
| ATTO 550 | 554nm | 576nm | ATTO-TEC GmbH |
| Texas Red-X | 596nm | 615nm | Thermo Fisher Scientific Inc. |
| ATTO 620 | 620nm | 642nm | ATTO-TEC GmbH |
| ATTO 655 | 663nm | 680nm | ATTO-TEC GmbH |

## Reference Images
The bacteria *Leptotrichia buccalis* was used as the biological target for generating reference samples for each of the seven fluorophores: DY-415, DY-490, ATTO 520, ATTO 550, Texas Red-X, ATTO 620, and ATTO 655 (Dyomics GmbH; ATTO-TEC GmbH; Thermo Fisher Scientific Inc.). *L. buccalis* cells were cultured, fixed, and then separately hybridized using custom fluorophore-conjugated oligonucleotide probes (biomers.net GmbH) as described by Mark Welch *et al.* [1]. A tongue biofilm sample was collected from subject D, chemically fixed, and hybridized without a fluorophore to generate a no-probe control sample (used to measure autofluorescence).

Each 16-bit reference image was acquired using dimensions of 512×512 pixels at 0.415μm/pixel resolution.

| Filename | Dye |
|----------|-----|
| DY415.tif | DY-415 |
| DY490.tif | DY-490 |
| AT520.tif | ATTO 520 |
| AT550.tif | ATTO 550 |
| TRX.tif | Texas Red-X |
| AT620.tif | ATTO 620 |
| AT655.tif | ATTO 655 |
| D-TDFH2-NP.tif | NA |


## Test Images
Test samples consisted of biofilms that were collected from the dorsum of the tongue, chemically fixed, and hybridized using a set of probes specific to different taxa of bacteria (see table below). Two samples were taken from each of five human subjects (A-E). 

| Probe ID | Taxon | Target | Dye |
|----------|-------|--------|-----|
| Smit651-DY415-2 | Species | *Streptococcus mitis* | DY-415 |
| Ssal372-DY490-2 | Species | *Streptococcus salivarius* | DY-490 |
| Prv392-AT520-2 | Genus | *Prevotella* | ATTO 520 |
| Vei488-AT550-1 | Genus | *Veillonella* | ATTO 550 |
| Act118-TRX-1 | Genus | *Actinomyces* | Texas Red-X |
| Nei1030-AT620-2 | Family | *Neisseriaceae* | ATTO 620 |
| Rot491-AT655-2 | Genus | *Rothia* | ATTO 655 |

## References
[1] Mark Welch JL, Rossetti BJ, Rieken CW, Dewhirst FE, Borisy GG. Biogeography of a human oral microbiome at the micron scale. Proceedings of the National Academy of Sciences. 2016 Feb 9;113(6):E791-800.
