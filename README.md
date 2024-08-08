# IBIS challenge (2024)

Evaluation of RSAT motif discovery tools for the IBIS challenge 2024. 

<https://ibis.autosome.org/>

Human reference used:
https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes

Docker image: rsat:20240507_cv1 at
<https://hub.docker.com/r/biocontainers/rsat/tags>
(see [docs](https://rsa-tools.github.io/installing-RSAT/RSAT-Docker/RSAT-Docker-tuto.html))

Support of the challenge presentation teleconference (video + slides):
<https://disk.yandex.ru/d/82FEnwPn158pog>

# RSAT distribution

The software suite Regulatory Sequence Analysis Tools (RSAT) used for
these anlayses is available as a Docker container

```
docker pull eeadcsiccompbio/rsat:20240808
```


# Methods

## Motif discovery approaches

We ran different approaches and statistical models to detect exceptional motifs. 

- `oligo-analysis`: over-represented k-mers

- `position-analysis`: k-mers with positional bias, i.e. their
  distribution along the sequences differs from a homogeneous
  distribution (chi-square test)

- `dyad-analysis`: over-represented dyads, i.e. pairs of 3-mers with a
  spacing of a given width (all widths from 0 to 20 were considered)

These 3 methods return k-mers or dyads declared significant according
to these criteria. These k-mers then serve as seeds to generate
position-specific scoring matrices (PSSM) based on a scanning of the
train sequences.

## Motif clustering

The different motif discovery methods return similar yet slightly different motifs, which are partly redundant. We use the RSAT program  `matrix-clustering` to cluster the motifs at different stages : 

- **Dataset-wise clustering.** Motifs discovered by `peak-motifs` for
    a given dataset. An interesing criterion is to check whether
    motifs discovered by the 3 different algorithms are clustered into
    a single cluster, which indicates that these motifs are both
    over-represented (`oligo-anlaysis` and `dyad-analysis`) and
    positionally biased relative to the peak centers (*a priori*, we
    expect to see a concentration of the TFBS close to the peak
    centers).

- **TF-wise clustering**. We cluster all the motifs discoverd for a
    given transcription factor in the different data types (CHS, GHTS,
    HTS, SMS, PBM). An interesting criterion is to check if a motif is
    robust to the experimental method used to characterize binding
    sites.

## Motif enrichment

- `matrix-quality`

## Motif selection criteria

The selection of motifs to be submitted for the IBIS challenge relied
on multiple criteria

- detected by several motif discovery algorithms. For CHS and GHTS
  datasets, we priorize motifs showing both over-representation and
  positional bias (`oligo-analysis`and `position-analysis`). The other
  approaches return sequences too short for `position-analysis` to be
  relevant.

- peak coverage : percent of the peaks that contain at least one
  instance (site) of the motif (PSSM)

- For motifs declared significant by `position-analysis`, visual
  inspection of the positional distribution of occurrences to check
  that they are enriched near the peak centers (in principle , the
  algorihtm can also return centrally empoverished motifs, or any othe
  rtyep of positional heterogeneity of the occurrences)

- enriched in the train sequences versus test sequences
  (`matrix-quality`)

- we discard poor complexity motifs

- ...



# How to reproduce our results?

All results are generated using `make` scripts in the
`makefiles`directory.

Detailed instructions to launch these `make` scripts are provided in
the [HOWTO.md](HOWTO.md) file.
