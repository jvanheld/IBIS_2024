###############################################################
## Run genetic algorithm to optimize the matrices produced by
## peak-motifs according to their capability to discriiminate positive
## from negative sequence sets.
##

include makefiles/00_parameters.mk
MAKEFILE=makefiles/07_optimize_matrices.mk

targets: targets_00
	@echo "optimize-matrix-GA targets (${MAKEFILE})"
	@echo "	help	get help message for optimize-matrix-GA"
	@echo "	omga	run optimize-matrix-GA on one dataset"
	@echo

param: param_00
	@echo
	@echo "Options for optimize-matrices-GA"
	@echo "	OMGA_DIR		${OMGA_DIR}"
	@echo "	OMGA_PATH		${OMGA_PATH}"
	@echo "	OMGA_PYTHON_PATH	${OMGA_PYTHON_PATH}"
	@echo "	THREADS			${THREADS}"
	@echo "	GENERATIONS		${GENERATIONS}"
	@echo "	CHILDREN		${CHILDREN}"
	@echo "	SELECT			${SELECT}"
	@echo "	OMGA_MATRICES		${OMGA_MATRICES}"
	@echo "	POS_SEQ			${POS_SEQ}"
	@echo "	NEG_SEQ			${NEG_SEQ}"
	@echo "	OUTPUT_DIR		${OUTPUT_DIR}"
	@echo "	OUTPUT_PREFIX		${OUTPUT_PREFIX}"
	@echo "	OMGA_CMD		${OMGA_CMD}"
	@echo "	OMGA_CMD_FULL		${OMGA_CMD_FULL}"
	@echo

help:
	${OMGA_CMD} -h

THREADS=10
GENERATIONS=5
CHILDREN=10
SELECT=5
POS_SEQ=${TRAIN_SEQ}
NEG_SEQ=${RAND_SEQ}
OMGA_MATRICES=${TRIMMED_MATRICES}.tf
OUTPUT_DIR=results/${BOARD}/optimized_matrices/${TF}/${EXPERIMENT}/${DATASET}
OUTPUT_PREFIX=${OUTPUT_DIR}/${TF}_${EXPERIMENT}_${DATASET}_clust-trimmed
OMGA_CMD_FULL=${SCHEDULER} ${OMGA_CMD} -v ${V} -t ${THREADS} -g ${GENERATIONS} -c ${CHILDREN} -s ${SELECT} \
		-m ${OMGA_MATRICES} \
		-p ${POS_SEQ} \
		-n ${NEG_SEQ} \
		-b ${BG_EQUIPROBA} \
		-r "${RSAT_CMD}" \
		--output_prefix ${OUTPUT_PREFIX}
omga:
	@mkdir -p ${OUTPUT_DIR}
	${OMGA_CMD_FULL}
