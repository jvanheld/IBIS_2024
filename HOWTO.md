# How to reproduce the analyses of the RSAT team for the IBIS challenge 2024

## make basics

All results are generated using `make` scripts in the
`makefiles`directory.

Each makefile comes with two targets documenting its use : 

- `make -f makefiles/[myfile.mk] targets` lists the targets and indicates what they do
- `make -f makefiles/[myfile.mk] param` lists the parameters used for the analyses

Note that all the makefiles first load `makefiles/00_parameters.mk`, which contains general parameters and targets, which are used by several makefiles. 

For example, the following command lists the targets for motif discovery with `peak-motifs`. 

```
make -f makefiles/02_peak-motifs.mk targets
```

and the default parameters can be obtained as follows

```
make -f makefiles/02_peak-motifs.mk param
```

The make variables can be redefined on the flight by specifying another value on the command line. 

For example, the default experiment is CHS (ChIP-seq)

```
make -f makefiles/02_peak-motifs.mk param | grep EXPERIMENT
```

It can be overwritten as follows

```
make -f makefiles/02_peak-motifs.mk param EXPERIMENT=GHTS
```

All the other variables will be updated automatically for the GHTS (genomic high-throughput selex) data. 



## Generating metadata files

Metadata files are tab-delimited text files providing information about each dataset found in the data directory. They are generated automatically by searching input files
(peaks, fasta or fastq sequences, PBM tables depending on the data
type).

This can be done with the following commands.

```
export BOARD=leaderboard

## Generate a metadata file for ChIP-seq experiments (CHS)
make -f makefiles/00_parameters.mk EXPERIMENT=CHS metadata

## Check the content of the metadata file
more metadata/leaderboard/TF_DATASET_CHS.tsv

## Generate one metadata file per experiment (CHS GHTS HTS SMS PBM)
make -f makefiles/00_parameters.mk iterate_experiments EXPERIMENT_TASK=metadata BOARD=${BOARD}

## Check the date of the metadata files
ls -tlr metadata/${BOARD}/

## Generate a metadata file with all the experiments for the integration of all matrices
make -f makefiles/05_integration.mk all_metadata  BOARD=${BOARD}

## Count the number of datasets per TF across the metadata file
cut -f 1 metadata/${BOARD}/TF_DATASET_all-types.tsv | sort | uniq -c | sort -nr

```


Here is the result for the leaderboard:

```
     10 NACC2
      7 TIGD3
      7 RORB
      7 PRDM5
      7 LEF1
      6 ZNF362
      5 NFKB1
      4 ZNF407
      3 SP140
      2 GABPA							   
```

You can also count, for each TF, the number of experimental methods for which training data is available. 

```
rsat contingency-table -i metadata/${BOARD}/TF_DATASET_all-types.tsv -col1 1 -col2 4 \
  -margin -sort freq
```

Which gives the following result. 

  TF       Sum   HTS   GHTS   PBM   CHS   SMS
  -------- ----- ----- ------ ----- ----- -----
  Sum      58    23    14     8     8     5
  NACC2    10    7     0      2     0     1
  RORB     7     4     0      2     0     1
  LEF1     7     4     0      2     0     1
  PRDM5    7     0     5      0     2     0
  TIGD3    7     4     0      2     0     1
  ZNF362   6     0     3      0     3     0
  NFKB1    5     4     0      0     0     1
  ZNF407   4     0     3      0     1     0
  SP140    3     0     2      0     1     0
  GABPA    2     0     1      0     1     0

The same can be done for the final data by replacing "leadereboard" by "final" in the above commands (`export BOARD=final`, then re-run all the commands above). 

  TF        Sum   HTS   GHTS   CHS   PBM   SMS
  --------- ----- ----- ------ ----- ----- -----
  Sum       185   74    63     23    14    11
  TPRX1     11    8     0      0     2     1
  SP140L    10    7     0      0     2     1
  MYPOP     10    8     0      0     2     0
  SALL3     10    0     9      1     0     0
  MKX       9     6     0      0     2     1
  ZBED2     9     0     8      1     0     0
  PRDM13    8     0     7      1     0     0
  CREB3L3   8     7     0      0     0     1
  GCM1      7     4     0      0     2     1
  ZBTB47    7     7     0      0     0     0
  ZNF395    7     0     6      1     0     0
  ZNF518B   7     0     6      1     0     0
  ZFTA      7     4     0      0     2     1
  ZNF493    6     0     3      3     0     0
  MSANTD1   6     3     0      0     2     1
  LEUTX     6     0     3      3     0     0
  ZNF20     6     0     3      3     0     0
  ZNF251    5     0     2      3     0     0
  USF3      5     0     4      1     0     0
  FIZ1      5     4     0      0     0     1
  ZNF831    5     4     0      0     0     1
  ZNF367    4     0     3      1     0     0
  ZNF500    4     3     0      0     0     1
  ZBED5     4     0     3      1     0     0
  ZNF780B   4     3     0      0     0     1
  ZNF648    4     0     3      1     0     0
  ZNF721    3     3     0      0     0     0
  ZNF286B   3     3     0      0     0     0
  CAMTA1    3     0     2      1     0     0
  MYF6      2     0     1      1     0     0


## Motif discoery with `peak-motifs`

The `peak-motifs` workflow is used as main tool for motif discovery. 

### Single-dataset analysis

For **CHS, GHTS, HTS and SMS experiments**, it is used in the single dataset mode, which detects exceptional motifs, with two crieria of exceptionality : 

- k-mer **over-representation** relative to the background model (the significance of the over-représntation is computed with a binomial test)
- k-mer **positional bias**¨ along the peak sequences relative to peak center (a chi-squared homogeneity test)

The k-mers declared significant are then used as seeds to build position-specific scoring matrices (in absolute counts), which are further converted to position frequency matrices (PFM) following the IBIS challenge specifications. 

#### Commands to run peak-motifs in single-dataset mode

The target `peakmo` of `makefiles/02_peak-motifs.mk` runs the single-dataset analysis on a given dataset: 

- `peak-motifs` to discover over-represented and positionally biased motifs;
- `matrix-clustering` to cluster the motifs discovered by the different algorithms (`oligo-analysis`, `position-analysis` and `dyad-analysis`);
- `convert-matrix` with the option `-trim_info` to suppress the non-informative columns on the left and right sides of the position-specific scoring matrices resulting from the clustering;
- `matrix-quality` to estimate, for each trimmed motif, the enrichment in the train dataset relative to the theoretical expectation, and relative to the randomized (column-permuted) matrices. 


Here is the command to analyse a single dataset. 
Beware, this analysis can take several minutes or more depending on the size of the dataset. 

```
make -f makefiles/02_peak-motifs.mk EXPERIMENT=CHS TF=GABPA DATASET=THC_0866 peakmo
````

You can get the information about result files with the `param` target

```
make -f makefiles/02_peak-motifs.mk EXPERIMENT=CHS TF=GABPA DATASET=THC_0866 param

```

The following commands iterate the analyses over all the datasets of the 4 types of experiments for which we run single-dataset analysis. Beware, this represents a lof of analyses, which can take several hours or days. We parallelise it on a cluster to run it efficiently.  

```
for exp in CHS GHTS HTS SMS; do \
  make -f makefiles/02_peak-motifs.mk iterate_datasets TASK=peakmo; \
done
```

### Differential analysis

For **PBM** (protein binding microarray) experiment, `peak-motifs` is used in a particular way by detecting differentially represented k-mers between two subsets of the PBM oligonucleotides : 

- **positive spots**, assumed to be bound by the TF of interest in the experiment
- **background / negativespots**, assumed not to be bound by the TF of interest

Positive and negative spots are selected as respectively the top and bottom entries in the lis tof spots ranked by signal intensity. 

#### Threshold on the number of top peaks

Since our primary analyses shown that the distribution of signal intensities does not follow a normal distribution, and each dataset shows a specific shape of signal distribution we avoid the recommended threshold of $4 \times \text{sd}$, and rather made practical tests by discovering over-represented k-mers in subsets of top-ranking spots with different aribtrary thresdholds. This analysis showed that the discovered matrices are remarkably  robust to  the number of top-scoring peaks retained as positive. 

We finally retained, for each PBM dataset, 

- as **positive spots**, the 500 spots with the highest signal intensity; 
- as **background / negative spots**, the 35,000 peaks with the lowest signal intensity, which corresponds to the bulk of the signal intensity distribution. 





