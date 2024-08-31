# How to reproduce the analyses of the RSAT team for the IBIS challenge 2024


## The short story

After having installed the required software [LINK TO ADD TO THE INSTALL.md], downloaded the data and organised it in the right way, all the aznalyses can be reproduced with one `make` target. 

```
make -f makefiles/all.mk all
```

## Synthetic description of the steps

The command ``make -f makefiles/all.mk all` calls the other makefiles to run the successive steps of the data preparation and analysis. 

### Choose your board

The environment variable `BOARD` should be set to either `leaderboard`or `final`. 
In the example below we set it to `leaderboard`. 

```
export BOARD=leaderboard
```

### Data preparation

Generate the metadata

```
@make BOARD=${BOARD} -f makefiles/01_init.mk all_metadata
```


#### Fetching sequences for all CHS and GHTS datasets

```
make BOARD=${BOARD} -f makefiles/01_init.mk fetch_sequences
```

#### Converting fastq to fasta for all HTS and SMS datasets

```
make BOARD=${BOARD} -f makefiles/01_init.mk fastq2fasta
```

#### Extracting sequences from data tables for PBM experiments

 ```
make BOARD=${BOARD} -f makefiles/03_PBM.mk tsv2fasta
```

#### Extracting top and background spots for PBM experiments

```
make BOARD=${BOARD} -f makefiles/03_PBM.mk top_bg_seq_all_datasets
```

 #### Selecting random genome fragments 

```
make BOARD=${BOARD} -f makefiles/01_init.mk rand_fragments_all_experiments
```

#### Collecting sequences for TF versus others analyses

```
make BOARD=${BOARD} -f makefiles/01_init.mk tf_vs_others_all_experiments
```


### Motif discovery

#### Motif discovery with peak-motifs

```
make BOARD=${BOARD} -f makefiles/02_peak-motifs.mk peakmo_all_experiments EXPERIMENTS='CHS GHTS SMS HTS'
```

#### Differential motif discovery with peak-motifs

```
make BOARD=${BOARD} -f makefiles/02_peak-motifs.mk peakmo_diff_all_experiments EXPERIMENTS='CHS GHTS SMS HTS'
make BOARD=${BOARD} -f makefiles/03_PBM.mk peakmo_diff_all_datasets
```

### Motif optimzation

#### Optimization with a genetic algorithm

```
make BOARD=${BOARD} -f makefiles/04_optimize-matrices.mk omga_all_experiments
make BOARD=${BOARD} -f makefiles/04_optimize-matrices.mk omga_collect_tables
```

### Selection of the motifs to be submitted

```
make BOARD=${BOARD} -f makefiles/04_optimize-matrices.mk omga_results_per_type
make BOARD=${BOARD} -f makefiles/04_optimize-matrices.mkomga_collect_tables

```


## Some details


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

All the other variables will be updated automatically for the GHTS (genomic high-throughput SELEX) data. 



## Generating metadata files

Metadata files are tab-delimited text files providing information about each dataset found in the data directory. They are generated automatically by searching input files
(peaks, fasta or fastq sequences, PBM tables depending on the data
type).

This can be done with the following commands.

```
export BOARD=leaderboard
## Note: for the final results just replace "leaderboard" by "final" in the previous statement

## Generate a metadata file for ChIP-seq experiments (CHS)
make -f makefiles/00_parameters.mk BOARD=${BOARD} EXPERIMENT=CHS metadata

## Check the content of the metadata file
cat metadata/${BOARD}/TF_DATASET_CHS.tsv

## Generate a metadata file for Protein Binding Microarray experiments (PBM)
make -f makefiles/04_PBM.mk BOARD=${BOARD} metadata_pbm
cat metadata/${BOARD}/TF_DATASET_PBM.tsv

## Generate a metadata file with all the experiments for the integration of all matrices
make -f makefiles/00_parameters.mk BOARD=${BOARD} all_metadata

## Check the date of the metadata files
ls -tlr metadata/${BOARD}/

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

The same can be done for the final data by replacing "leaderboard" by "final" in the above commands (`export BOARD=final`, then re-run all the commands above). 

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

## Getting genomic sequences for CHS and GHTS experiments

ChIP-seq (CHS) and genomic high throughput sequencing (GHTS) data are provided as coordinates (bed-formatted table with extension `.peak`). In order to get the corresponding sequences in fasta format, we use the RSAT tool `fetch-sequences`, which takes as input a bed file and retrieves the corresponding genomic sequences from (UCSC genome browser)[https://genome.ucsc.edu/].  


```
## Fetch genomic sequences from UCSC genome browser
make -f makefiles/00_parameters.mk BOARD=${BOARD} fetch_sequences

## Check the sizes of the sequence files
grep -v '^#' metadata/${BOARD}/TF_DATASET_CHS.tsv  | cut -f 7 | xargs du -sk
grep -v '^#' metadata/${BOARD}/TF_DATASET_GHTS.tsv  | cut -f 7 | xargs du -sk

```


## Motif discovery with `peak-motifs`

The `peak-motifs` workflow is used as main tool for motif discovery. 

### Single-dataset analysis

For **CHS, GHTS, HTS and SMS experiments**, it is used in the single dataset mode, which detects exceptional motifs, with two criteria of exceptionality : 

- k-mer **over-representation** relative to the background model (the significance of the over-representation is computed with a binomial test)
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
make -f makefiles/02_peak-motifs.mk BOARD=${BOARD} EXPERIMENT=CHS TF=GABPA DATASET=THC_0866 peakmo
````

You can get the information about result files with the `param` target

```
make -f makefiles/02_peak-motifs.mk BOARD=${BOARD} EXPERIMENT=CHS TF=GABPA DATASET=THC_0866 param

```

The following commands iterate the analyses over all the datasets of the 4 types of experiments for which we run single-dataset analysis. Beware, this represents a lot of analyses, which can take several hours or days. We parallelize it on a cluster to run it efficiently.  

```
for exp in CHS GHTS HTS SMS; do \
  make -f makefiles/02_peak-motifs.mk BOARD=${BOARD} EXPERIMENT=${exp} TASK=peakmo  iterate_datasets; \
done
```

### Differential analysis

For **PBM** (protein binding microarray) experiment, `peak-motifs` is used in a particular way by detecting differentially represented k-mers between two subsets of the PBM oligonucleotides : 

- **positive spots**, assumed to be bound by the TF of interest in the experiment
- **background / negative spots**, assumed not to be bound by the TF of interest

Positive and negative spots are selected as respectively the top and bottom entries in the list of spots ranked by signal intensity. 

#### Threshold on the number of top peaks

Since our primary analyses shown that the distribution of signal intensities does not follow a normal distribution, and each dataset shows a specific shape of signal distribution we avoid the recommended threshold of $4 \times \text{sd}$, and rather made practical tests by discovering over-represented k-mers in subsets of top-ranking spots with different arbitrary thresholds. This analysis showed that the discovered matrices are remarkably  robust to  the number of top-scoring peaks retained as positive. 

We finally retained, for each PBM dataset, 

- as **positive spots**, the 500 spots with the highest signal intensity; 
- as **background / negative spots**, the 35,000 peaks with the lowest signal intensity, which corresponds to the bulk of the signal intensity distribution. 


#### Commands to run peak-motifs in differential mode

For this challenge, the differential mode was only applied to PBM data. It is managed in the script `makefiles.04_PBM.mk`. 


```
## Get the list of targets for BPM data analysis
make -f makefiles/04_PBM.mk BOARD=${BOARD} targets

## Check the parameters for PBM data analysis
make -f makefiles/04_PBM.mk BOARD=${BOARD} param

## Extract spot sequences from the tab-separated values file
make -f makefiles/04_PBM.mk BOARD=${BOARD}  targets tsv2fasta

## Get the 500 spots with the highest signal as positive spots, and the 35,000 lowest spots as background sequences
make -f makefiles/04_PBM.mk BOARD=${BOARD}  targets top_bg_seq_all_datasets

## Run peak-motifs in differential mode on all the PBM datasets
make -f makefiles/04_PBM.mk BOARD=${BOARD} peakmo_diff_all_datasets


```

## Sequence scanning

The discovered motifs (after clustering and trimming) are used to scan sequences in order to evaluate the performance of each motif in discriminating the train sequences from background sequences. As background sequences, we use `rsat random-genome-fragments` to pick up at random genomic fragments of the same lengths as the positive training sequences. 

### Downloading the reference Human genome on your local RSAT instance

The selection of random genomic fragments require to dispose of a local version of the reference genome (Human genome release GRCh38). This genome can be downloaded with the following command. 

**Beware:** the genome requires ~10Gb storage, and its transfer may take some time depending on your internet speed. 

```
rsat download-organism -v 3 -org Homo_sapiens_GCF_000001405.40_GRCh38.p14 -server http://rsat-tagc.univ-mrs.fr/rsat
```

### Getting random genomic sequences (background sequences)

```
## Get random genome fragments for one dataset
make -f makefiles/02_peak-motifs.mk BOARD=${BOARD} rand_fragments 

## Get random genome fragments for all the datasets of a given experiment
make -f makefiles/02_peak-motifs.mk BOARD=${BOARD} EXPERIMENT=CHS rand_fragments_all_datasets


## Get random genome fragments for all the datasets of all experiments
make -f makefiles/02_peak-motifs.mk BOARD=${BOARD} rand_fragments_all_experiments

```

### Sequence scanning

We scan sequences using `rsat matrix-scan -quick`, with parameters mimicking the IBIS challenge procedure: 

- equiprobable background model (independently and identically distributed nucleotides)
- for each PWM, only count the best hit per sequence (i.e. the site that maximizes the weight, defined as the log-likelihood ratio between the sequence probabilities under the PWM model and under the background model)

We scan three types of sequences: 

- **train:** training sequences. Note that for PBM the training sequences are the 500 spots having the highest signal intensity, whereas for other experiments (CHS, GHTS, HTS, SMS) the train sequences are all the sequences downloaded from the IBIS web site ([leaderboard](https://ibis.autosome.org/download_data/leaderboard) or [final](https://ibis.autosome.org/download_data/final)).  

- **rand:** random genome fragments of the same sizes as the train sequences (see previous section)

- **test:** test sequences downloaded from the IBIS web site ([leaderboard](https://ibis.autosome.org/download_data/leaderboard) or [final](https://ibis.autosome.org/download_data/final)).  


```
## Get the list of make targets for scanning
make -f makefiles/02_peak-motifs.mk targets | grep scan

## Scan train sequences for a given dataset
make -f makefiles/02_peak-motifs.mk scan_sequences_train

## Scan random genome fragments for a given dataset
make -f makefiles/02_peak-motifs.mk scan_sequences_rand

## Scan test sequences for a given dataset
make -f makefiles/02_peak-motifs.mk scan_sequences_test

## Scan the three types of sequences (train, rand, test)
make -f makefiles/02_peak-motifs.mk scan_sequences

##  scan all the datasets for all the experiments
make -f makefiles/02_peak-motifs.mk scan_sequences_all_experiments

## Find the sequence scanning result files and print their size in kb
find results/${BOARD}/train -name '*_peakmo-clust-matrices*.tsv*' -exec du -sk {} \;
```






