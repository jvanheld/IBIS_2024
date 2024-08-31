# Software environment

This doc describes the software environment requireed to reproduce the results submitted byb the RSAT team at the [IBIS challenge 2024](https://ibis.autosome.org/). 



# RSAT distribution


The software suite Regulatory Sequence Analysis Tools (RSAT) used for
these anlayses is available as a Docker container, which can be found at
<https://hub.docker.com/r/eeadcsiccompbio/rsat/tags>
(see [docs](https://rsa-tools.github.io/installing-RSAT/RSAT-Docker/RSAT-Docker-tuto.html))

The installation requires to dispose of the `docker` command. 
The RSAT suite can be installed with this command. 

```
docker pull eeadcsiccompbio/rsat:2024-08-28c
```

The version 2024-08-28c was used to produce the final results that were submitted to IBIS challenge 2024. 

## Reference Human genome

https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes


## optimize-matrix-GA


