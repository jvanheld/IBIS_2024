################################################################
## Computer-specific settings


## Configuration for IFB core cluster (core.cluster.france-bioinformatique.fr)
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
SCHEDULER=srun time
SLURM_OUT=./slurm_out/${BOARD}_${DATA_TYPE}_${TF}_${DATASET}_slurm-job_%j.out
RUNNER=sbatch
RUNNER_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem-per-cpu=16G\n"


## Local configuration for Apptainer on IFB core cluster
DOCKER_RELEASE=20240808
DOCKER_IMAGE=eeadcsiccompbio/rsat:${DOCKER_RELEASE}
#RSAT_CMD=docker run -v $$PWD:/home/rsat_user -v $$PWD/results:/home/rsat_user/out ${DOCKER_IMAGE} rsat
RSAT_CMD=apptainer run rsat_apptainer/rsat_${DOCKER_RELEASE}.sif rsat

