################################################################
## Computer-specific settings


## Configuration for IFB core cluster (core.cluster.france-bioinformatique.fr)
RSAT_CMD=rsat
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
SLURM_OUT=${LOG_DIR}/${BOARD}_${EXPERIMENT}_${TF}_${DATASET}_slurm-job_%j.out
SCHEDULER=srun time
RUNNER=sbatch
RUNNER_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem-per-cpu=16G\n"


