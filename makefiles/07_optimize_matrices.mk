##############################################################
## Run genetic algorithm to optimize the matrices produced by
## peak-motifs according to their capability to discriiminate positive
## from negative sequence sets.
##

include makefiles/00_parameters.mk
MAKEFILE=makefiles/07_optimize_matrices.mk

targets: targets_00
	@echo "optimize-matrix-GA targets (${MAKEFILE})"
	@echo "	help			get help message for optimize-matrix-GA"
	@echo "	omga_input_matrices	generate input matrices for optimize-matrix-GA for 1 dataset"
	@echo "	omga_one_dataset	run optimize-matrix-GA on one dataset"
	@echo "	omga_all_datasets	run optimize-matrix-GA on all datasets of a given experiment"
	@echo "	omga_all_experiments	run optimize-matrix-GA on all datasets of all experiments"
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
	@echo "	OMGA_INPUT_MATRICES	${OMGA_INPUT_MATRICES}"
	@echo "	TRAIN_SEQ		${TRAIN_SEQ}"
	@echo "	POS_SEQ			${POS_SEQ}"
	@echo "	RAND_SEQ		${RAND_SEQ}"
	@echo "	TF_SEQ			${TF_SEQ}"
	@echo "	OTHERS_SEQ		${OTHER_SEQ}"
	@echo "	NEG_SEQ			${NEG_SEQ}"
	@echo "	OUTPUT_DIR		${OUTPUT_DIR}"
	@echo "	OUTPUT_PREFIX		${OUTPUT_PREFIX}"
	@echo "	OMGA_CMD_PREFIX		${OMGA_CMD_PREFIX}"
	@echo "	OMGA_COMPA_CMD		${OMGA_COMPA_CMD}"
	@echo "	OMGA_CMD		${OMGA_CMD}"
	@echo "	PLOT_AUROC_CMD		${PLOT_AUROC_CMD}"
	@echo "	OMGA_SCRIPT		${OMGA_SCRIPT}"
	@echo "	OPTIMIZED_MATRICES_TF	${OPTIMIZED_MATRICES_TF}"
	@echo "	OPTIMIZED_MATRICES_CB	${OPTIMIZED_MATRICES_CB}"
	@echo "	OPTIMIZED_MATRICES_IBIS	${OPTIMIZED_MATRICES_IBIS}"
	@echo "	SCORE_TABLE		${SCORE_TABLE}"
	@echo "	AUROC_PLOT		${AUROC_PLOT}"
	@echo

help:
	${OMGA_CMD} -h

GENERATIONS=20
CHILDREN=10
SELECT=5
POS_SEQ=${TF_SEQ}
NEG_SEQ=${OTHERS_SEQ}
OMGA_PRESUFFIX=clust-trimmed-matrices_tf-vs-others

## Choice of the matrices to optimize
OMGA_INPUT_MATRICES=${TRIMMED_MATRICES}_c100000.tf
#OMGA_INPUT_MATRICES=${PEAKMO_MATRICES}_noBS.tf
#OMGA_PRESUFFIX=peakmo-matrices_train-vs-rand

OUTPUT_DIR=results/${BOARD}/${DATA_TYPE}/${EXPERIMENT}/${TF}/${DATASET}/optimized_matrices/${OMGA_PRESUFFIX}
OUTPUT_PREFIX=${OUTPUT_DIR}/${TF}_${EXPERIMENT}_${DATASET}_${OMGA_PRESUFFIX}
OMGA_SCRIPT=${OUTPUT_PREFIX}_cmd.sh
OMGA_CMD=${SCHEDULER} ${OMGA_CMD_PREFIX} -v ${V} \
		-t ${THREADS} \
		-g ${GENERATIONS} \
		-c ${CHILDREN} \
		-s ${SELECT} \
		-m ${OMGA_INPUT_MATRICES} \
		-p ${POS_SEQ} \
		-n ${NEG_SEQ} \
		-b ${BG_EQUIPROBA} \
		-r '"${RSAT_CMD}"' \
		--output_prefix ${OUTPUT_PREFIX}

SCORE_TABLE=${OUTPUT_PREFIX}_gen0-${GENERATIONS}_score_table.tsv
OPTIMIZED_MATRICES_TF=${OUTPUT_PREFIX}_gen${GENERATIONS}_scored_AuROC_top5.tf
OPTIMIZED_MATRICES_CB=${OUTPUT_PREFIX}_gen${GENERATIONS}_scored_AuROC_top5_freq.cb
OPTIMIZED_MATRICES_IBIS=${OUTPUT_PREFIX}_gen${GENERATIONS}_scored_AuROC_top5_ibis.txt
AUROC_PLOT=${OUTPUT_PREFIX}_gen0-${GENERATIONS}_auroc-profiles.pdf 
PLOT_AUROC_CMD=${OMGA_PYTHON_PATH} ${OMGA_DIR}/plot-auroc-profiles.py \
	-v 1 \
	-i ${SCORE_TABLE} \
	-t "${TF}_${EXPERIMENT}_${DATASET}_clust-trimmed-matrices" \
	-s "train-versus-rand" \
	--y_step1 0.05 --y_step2 0.01 \
	--min_y 0.0 --max_y 1.0 \
	--xsize 16 --ysize 8 \
	-f pdf \
	-o ${AUROC_PLOT}

OMGA_COMPA=${OUTPUT_PREFIX}_gen0-vs-gen20
OMGA_COMPA_TAB=${OMGA_COMPA}.tab
OMGA_COMPA_HTML=${OMGA_COMPA}.html
OMGA_COMPA_ALIGN=${OMGA_COMPA}_alignments_1ton.html
OMGA_COMPA_CMD=${RSAT_CMD} compare-matrices  -v ${V} \
	-file1 ${OPTIMIZED_MATRICES_TF} -format1 tf \
	-file2 ${OMGA_INPUT_MATRICES} \
	-format2 tf  -strand DR -lth cor 0.7 -lth Ncor 0.4 \
	-return cor,Ncor,logoDP,NsEucl,NSW,match_rank,matrix_id,matrix_name,width,strand,offset,consensus,alignments_1ton \
	-o ${OMGA_COMPA_TAB}
omga_compa:
	@echo "Comparing optimized matrices with initial matrices"
	@echo "	OMGA_COMMPA_CMD		${OMGA_COMPA_CMD}"
	${OMGA_COMPA_CMD}
	@echo "	OMGA_COMPA_TAB		${OMGA_COMPA_TAB}"
	@echo "	OMGA_COMPA_HTML		${OMGA_COMPA_HTML}"
	@echo "	OMGA_COMPA_ALIGN	${OMGA_COMPA_ALIGN}"

omga_input_matrices:
	@echo "Generating input matrices for opimize-matrix-GA"
	@${MAKE} ${OMGA_INPUT_MATRICES}
	@echo "	OMGA_INPUT_MATRICES	${OMGA_INPUT_MATRICES}"

omga_one_dataset: omga_input_matrices
	@echo "Optimizing matrices"
	@echo "	BOARD			${BOARD}"
	@echo "	EXPERIMENT		${EXPERIMENT}"
	@echo "	TF			${TF}"
	@echo "	DATASET			${DATASET}"
	@echo "	OMGA_INPUT_MATRICES	${OMGA_INPUT_MATRICES}"
	@echo "	POS_SEQ			${POS_SEQ}"
	@echo "	NEG_SEQ			${NEG_SEQ}"
	@echo "	OMGA_CMD		${OMGA_CMD}"
	@echo "	PLOT_AUROC_CMD		${PLOT_AUROC_CMD}"
	@echo "	Writing optimize-matrix-GA  script"
	@echo "	OMGA_SCRIPT		${OMGA_SCRIPT}"
	@${MAKE} ${OMGA_INPUT_MATRICES}
	@mkdir -p ${OUTPUT_DIR}
	@echo ${RUNNER_HEADER} > ${OMGA_SCRIPT}
	@echo "#SBATCH --cpus-per-task ${THREADS}\n" >> ${OMGA_SCRIPT}
	@echo >> ${OMGA_SCRIPT}
	@echo ${OMGA_CMD} >> ${OMGA_SCRIPT}
	@echo >> ${OMGA_SCRIPT}
	@echo ${PLOT_AUROC_CMD} >> ${OMGA_SCRIPT}
	@echo >> ${OMGA_SCRIPT}
	@echo ${OMGA_COMPA_CMD} >> ${OMGA_SCRIPT}
	@echo >> ${OMGA_SCRIPT}
	@echo ${MAKE} ${OPTIMIZED_MATRICES_TF} >> ${OMGA_SCRIPT}
	@echo ${MAKE} ${OPTIMIZED_MATRICES_CB} >> ${OMGA_SCRIPT}
	@echo ${MAKE} ${OPTIMIZED_MATRICES_IBIS} >> ${OMGA_SCRIPT}
	@${RUNNER} ${OMGA_SCRIPT}
	@echo "	OUTPUT_PREFIX		${OUTPUT_PREFIX}"
	@echo "	OPTIMIZED_MATRICES_TF	${OPTIMIZED_MATRICES_TF}"
	@echo "	OPTIMIZED_MATRICES_CB	${OPTIMIZED_MATRICES_CB}"
	@echo "	OPTIMIZED_MATRICES_IBIS	${OPTIMIZED_MATRICES_IBIS}"
	@echo "	SCORE_TABLE		${SCORE_TABLE}"
	@echo "	AUROC_PLOT		${AUROC_PLOT}"
	@echo


omga_all_datasets:
	@${MAKE} iterate_datasets TASK=omga_one_dataset

omga_all_experiments:
	@${MAKE} iterate_experiments EXPERIMENT_TASK=omga_all_datasets

