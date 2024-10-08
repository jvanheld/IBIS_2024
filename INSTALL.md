# Software environment

This doc describes the software environment required to reproduce the results submitted byb the RSAT team at the [IBIS challenge 2024](https://ibis.autosome.org/). 



# RSAT distribution


The software suite Regulatory Sequence Analysis Tools (RSAT) used for
these analyses is available as a development Docker container, which can be found at
<https://hub.docker.com/r/eeadcsiccompbio/rsat/tags>
 
Note that stable Docker containers are regularly updated at
<https://hub.docker.com/r/biocontainers/rsat/tags>

The installation requires to dispose of the `docker` command. 
The RSAT suite can be installed with this command, see the full documentation at
[installing-RSAT](https://rsa-tools.github.io/installing-RSAT/RSAT-Docker/RSAT-Docker-tuto.html):

```
docker pull eeadcsiccompbio/rsat:2024-08-28c
```

The version 2024-08-28c was used to produce the final results that were submitted to IBIS challenge 2024. 


## Reference Human genome

https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes


## optimize-matrix-GA


