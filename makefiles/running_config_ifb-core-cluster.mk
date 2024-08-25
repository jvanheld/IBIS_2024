################################################################
## Computer-specific settings


## Configuration for IFB core cluster (core.cluster.france-bioinformatique.fr)
RSAT_CMD=rsat
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
SCHEDULER=srun time
TODAY=date '+%Y-%m-%d'
SLURM_OUT=./slurm_out/${TODAY}/${BOARD}_${EXPERIMENT}_${TF}_${DATASET}_slurm-job_%j.out
RUNNER=sbatch
RUNNER_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem-per-cpu=16G\n"


## Local configuration for Apptainer on IFB core cluster
#MOTIFDB_DIR=/packages/rsat/public_html/motif_databases
#DOCKER_RELEASE=20240806
#DOCKER_IMAGE=eeadcsiccompbio/rsat:${DOCKER_RELEASE}
#RSAT_CMD=docker run -v $$PWD:/home/rsat_user -v $$PWD/results:/home/rsat_user/out ${DOCKER_IMAGE} rsat
#RSAT_CMD=/shared/projects/ibis_challenge/rsat_${DOCKER_RELEASE}.sif rsat

