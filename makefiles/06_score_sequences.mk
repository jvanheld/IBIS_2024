################################################################
## IBIS challenge 2024
##
## Score each sequence with matrix-scan for a 2-group classification
## problem


#include makefiles/00_parameters.mk 
include makefiles/05_integration.mk
MAKEFILE=makefiles/06_score_sequences.mk

targets: targets_00
	@echo
	@echo "Sequence scoring"
	@echo "	rand_fragments			select random genome fragment as negative set for a given dataset"e
	@echo "	rand_fragments_all_datasets	run rand_fragments for all the datasets of the current data type"
	@echo "	rand_fragments_all_datatypes	run rand_fragments for all the datasets of all the data types"
	@echo "	scan_one_dataset		scan one dataset with a set of matrices"
	@echo "		"

param:: param_00
	@echo
	@echo "Sequence scoring parameters"
	@echo "	RAND_SEQ		${RAND_SEQ}"
	@echo "	RAND_SCRIPT		${RAND_SCRIPT}"
	@echo "	SCAN_DIR		${SCAN_DIR}"

################################################################
## Select random genomic sequences of the same lengths as the current
## data set
RAND_SEQ=${DATASET_PATH}_random-genome-fragments.fa
RAND_CMD=${RSAT_CMD} random-genome-fragments  \
		-template_format fasta \
		-i ${FASTA_SEQ} \
		-org Homo_sapiens_GCF_000001405.40_GRCh38.p14  \
		-return seq \
		-o ${RAND_SEQ}
RAND_SCRIPT=${DATASET_PATH}_random-genome-fragments_cmd.sh
rand_fragments:
	@echo
	@echo "Selecting random genome fragments for ${BOARD} train ${DATASET}"
	@echo "	RAND_SCRIPT	${RAND_SCRIPT}"
	@echo "	RAND_SEQ	${RAND_SEQ}"
	@echo ${RUNNER_HEADER} > ${RAND_SCRIPT}
	@echo >> ${RAND_SCRIPT}
	@echo ${RAND_CMD} >> ${RAND_SCRIPT}
	@${RUNNER} ${RAND_SCRIPT}

rand_fragments_all_datasets:
	@echo "Running rand_fragments for all datasets ${BOARD}	${DATA_TYPE}"
	@${MAKE} iterate_datasets TASK=rand_fragments


rand_fragments_all_datatypes:
	@echo "Running rand_fragments for all data sets of all data types"
	@${MAKE} iterate_datatypes DATA_TYPE_TASK=rand_fragments_all_datasets

################################################################
## Scan one sequence set with a given matrix file
##
SCAN_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/scan
SCAN_RESULT=${SCAN_DIR}/${TF}_${DATASET}_scan_top-per-seq.tsv
SCAN_CMD=${RSAT_CMD} matrix-scan -v ${V} \
	-m ${MATRICES} \
	-matrix_format transfac \
	-i ${FASTA_SEQ} \
	-seq_format fasta \
	-bgfile ${BG_EQUIPROBA} \
	-bg_pseudo 0.01 \
	-pseudo 1 \
	-decimals 1 \
	-2str \
	-return sites \
	-return pval \
	-lth rank_pm 1 \
	-n score \
	-o ${SCAN_RESULT}

scan_one_dataset:
	@echo "Scanning sequences"
	@echo "	SCAN_DIR		${SCAN_DIR}"
	@echo "	MATRICES		${MATRICES}"
	@echo "	FASTA_SEQ		${FASTA_SEQ}"
	@echo "	SCAN_CMD		${SCAN_CMD}"
	${RUNNER} ${SCAN_CMD}
