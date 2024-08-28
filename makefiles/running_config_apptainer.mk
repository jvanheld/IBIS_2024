################################################################
## Computer-specific settings

################################################################
## Running configuration
################################################################
## Configuration for IFB core cluster (core.cluster.france-bioinformatique.fr)
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
SLURM_OUT=${LOG_DIR}/${BOARD}_${EXPERIMENT}_${TF}_${DATASET}_slurm-job_%j.out
SCHEDULER=srun time
RUNNER=sbatch
#RUNNER_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem-per-cpu=16G\n\n"
RUNNER_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem=16G\n\n"


################################################################
## Local configuration for Apptainer on IFB core cluster
################################################################
DOCKER_RELEASE=2024-08-28
DOCKER_IMAGE=eeadcsiccompbio/rsat:${DOCKER_RELEASE}
APPTAINER_DEF=makefiles/rsat_apptainer.def
APPTAINER_CONTAINER=rsat_apptainer/rsat_${DOCKER_RELEASE}.sif
#RSAT_CMD=docker run -v $$PWD:/home/rsat_user -v $$PWD/results:/home/rsat_user/out ${DOCKER_IMAGE} rsat
RSAT_CMD=apptainer run rsat_apptainer/rsat_${DOCKER_RELEASE}.sif rsat

usage:
	@echo
	@echo "Apptainer mode for RSAT"
	@echo
	@echo "Parameters"
	@echo "	DOCKER_RELEASE		${DOCKER_RELEASE}"
	@echo "	APPTAINER_DEF		${APPTAINER_DEF}"
	@echo "	APPTAINER_CONTAINER	${APPTAINER_CONTAINER}"
	@echo "	BUILD_CMD		${BUILD_CMD}"
	@echo "	RSAT_CMD		${RSAT_CMD}"
	@echo
	@echo "Targets"
	@echo "	usage			print usage for the current makefile"
	@echo "	build			build apptainer container"
	@echo "	run			run RSAT with apptainer container"

################################################################
## Build apptainer container from the RSAT Docker image
## The configuration is defined in the file 
BUILD_CMD=srun --mem=10G --cpus-per-task=10 apptainer build ${APPTAINER_CONTAINER} ${APPTAINER_DEF}
build:
	${BUILD_CMD}

run:
	${RSAT_CMD}

################################################################
## Configuration for optimize-matrix-GA
################################################################
THREADS=40
OMGA_DIR=/shared/projects/ibis_challenge/optimize-matrix-GA
OMGA_PATH=${OMGA_DIR}/optimize-matrix-GA.py
OMGA_PYTHON_PATH=${OMGA_DIR}/venv/bin/python
OMGA_CMD_PREFIX=${OMGA_PYTHON_PATH} ${OMGA_PATH}

