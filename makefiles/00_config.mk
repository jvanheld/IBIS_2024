################################################################
## Computer-specific settings


## Configuration for IFB server
RSAT_CMD=rsat
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
SCHEDULER=srun time
SLURM_OUT=./slurm_out/${BOARD}_${DATA_TYPE}_${TF}_${DATASET}_slurm-job_%j.out
RUNNER=sbatch
RUNNER_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem-per-cpu=16G\n"


## Local configuration for Jacques van Helden's laptop
# MOTIFDB_DIR=~/packages/rsat/motif_databases
# MOTIFDB_DIR=/packages/rsat/public_html/motif_databases
# RSAT_CMD=docker run -v $$PWD:/home/rsat_user -v $$PWD/results:/home/rsat_user/out eeadcsiccompbio/rsat:20240725 rsat
# SCHEDULER=time
# SLURM_OUT=
# RUNNER=bash
# RUNNER_HEADER="\#!/bin/bash"


