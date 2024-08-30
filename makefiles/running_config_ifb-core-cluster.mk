################################################################
## Computer-specific settings


## Configuration for IFB core cluster (core.cluster.france-bioinformatique.fr)
RSAT_CMD=rsat
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
SLURM_OUT=${LOG_DIR}/${BOARD}_${EXPERIMENT}_${TF}_${DATASET}_slurm-job_%j.out
SCHEDULER=srun time
RUNNER=sbatch
#RUNNER_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem-per-cpu=16G\n"
RUNNER_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem=16G\n\nTMPDIR=/shared/projects/ibis_challenge/tmp/\nTMP=\$${TMPDIR}\nTEMP=\$${TMPDIR}\nmkdir -p \$${TMPDIR}\nexport TMPDIR TMP TEMP\n\n"


################################################################
## Configuration for optimize-matrix-GA
################################################################
THREADS=40
OMGA_DIR=/shared/projects/ibis_challenge/optimize-matrix-GA
OMGA_PATH=${OMGA_DIR}/optimize-matrix-GA.py
OMGA_PYTHON_PATH=${OMGA_DIR}/venv/bin/python
OMGA_CMD_PREFIX=${OMGA_PYTHON_PATH} ${OMGA_PATH}

