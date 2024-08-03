# How to reproduce the analyses of the RSAT team for the IBIS challenge 2024

## Generating data files

Metadata files are generated automatically by searching input files
(peaks, fasta or fastq sequences, PBM tables depending on the data
type).

This can be done with the following commands.

```
export BOARD=leaderboard

## Generate one metadata file per data type (CSH GHTS HTS SMS PBM)
make -f makefiles/00_parameters.mk iterate_datatypes DATA_TYPE_TASK=metadata BOARD=${BOARD}

## Check the date of the metadata files
ls -tlr metadata/${BOARD}/

## Generate a metadata file with all the data types for the integration of all matrices
make -f makefiles/05_integration.mk all_metadata  BOARD=${BOARD}

## Count the number of TFs per metadata file
cut -f 1 metadata/${BOARD}/TF_DATASET_all-types.tsv | sort | uniq -c | sort -nr
```

The same can be done for the final data by replacing "leadereboard" by "final" in the above commands. 

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