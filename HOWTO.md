# How to reproduce the analyses of the RSAT team for the IBIS challenge 2024

## Generating data files

Metadata files are generated automatically by searching input files
(peaks, fasta or fastq sequences, PBM tables depending on the data
type).

This can be done with the following commands.

```
export BOARD=leaderboard

## Generate one metadata file per data type (CHS GHTS HTS SMS PBM)
make -f makefiles/00_parameters.mk iterate_datatypes DATA_TYPE_TASK=metadata BOARD=${BOARD}

## Check the date of the metadata files
ls -tlr metadata/${BOARD}/

## Generate a metadata file with all the data types for the integration of all matrices
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

