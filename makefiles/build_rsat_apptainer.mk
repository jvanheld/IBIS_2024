################################################################
## Build RSAT apptainer container from a Docker release

MAKEFILE=makefiles/build_rsat_apptainer.mk
DOCKER_RELEASE=20240808
APPTAINER_DIR=rsat_apptainer
APPTAINER_DEF=${APPTAINER_DIR}/rsat_apptainer.def
RSAT_SIF=${APPTAINER_DIR}/rsat_${DOCKER_RELEASE}.sif
BUILD_CMD=srun --mem=10G --cpus-per-task=10 apptainer build ${RSAT_SIF} ${APPTAINER_DEF}
targets:
	@echo "Targets"
	@echo "	param	list parameters"
	@echo "	build	build apptainer container from RSAT Docker image"

param:
	@echo "Parameters"
	@echo "	DOCKER_RELEASE	${DOCKER_RELEASE}"
	@echo "	APPTAINER_DIR	${APPTAINER_DIR}"
	@echo "	RSAT_SIF	${RSAT_SIF}"
	@echo "	BUILD_CMD	${BUILD_CMD}"

build:
	${BUILD_CMD}
