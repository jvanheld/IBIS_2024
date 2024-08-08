################################################################
## IBIS challenge 2024
##
## Score each sequence with matrix-scan for a 2-group classification
## problem

#include makefiles/00_parameters.mk 
include makefiles/00_parameters.mk
MAKEFILE=makefiles/06_score_sequences.mk

targets: targets_00
	@echo
	@echo "Sequence scoring with cross-data-type matrices"
	@echo "	scan_one_dataset		scan one dataset with a set of matrices"
	@echo "	scan_all_datasets		scan all dataset of a given data type"
	@echo "	scan_all_datatypes		scan all datasets of all data types"
	@echo " scan_one_dataset_rand		scan one random sequence set with a set of matrices"
	@echo "	scan_all_datasets_rand		scan all random sequence sets of a given data type"
	@echo "	scan_all_datatypes_rand		scan all random sequence sets datasets of all data types"
	@echo "		"

param: param_00
	@echo
	@echo "Sequence scoring parameters"
	@echo "==========================="
	@echo
	@echo "Matrices to evaluate"
	@echo "	MATRICES	${MATRICES}"
	@echo
	@echo "Scanning sequences"
	@echo "	SCAN_DIR	${SCAN_DIR}"
	@echo "	MATRICES	${MATRICES}"
	@echo "	FASTA_SEQ	${FASTA_SEQ}"
	@echo "	SCAN_SCRIPT	${SCAN_SCRIPT}"
	@echo "	SCAN_CMD	${SCAN_CMD}"
	@echo "	SCAN_RESULT	${SCAN_RESULT}"

################################################################
## Define the matrices to use as input for matrix-clustering and
## matrix-quality. We initially restricted the analysis to the root
## motifs but these motifs are too degenerated -> we apply it to all
## the nodes of the matrix clustering result tree.
DATA_TYPE=CHS
#TF=GABPA
#DATASET=THC_0866
MATRICES=${TFCLUST_ALL_MOTIFS}_trimmed

################################################################
## Scan one sequence set with a given matrix file, and only return the
## top-scoring site per sequence for each position-specific scoring
## matrix.
#SCAN_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/${DATASET}/scan
SCAN_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/${DATASET}/scan
SCAN_SCRIPT=${SCAN_DIR}/scanning_cmd.sh
SCAN_RESULT=${SCAN_DIR}/${TF}_${DATASET}_scan_top-per-seq.tsv
SCAN_CMD=${SCHEDULER} ${RSAT_CMD} matrix-scan -v ${V} \
	-m ${MATRICES}.tf \
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
	-uth rank_pm 1 \
	-n score \
	-o ${SCAN_RESULT}

scan_one_dataset:
	@echo "Scanning sequences"
	@echo "	SCAN_DIR		${SCAN_DIR}"
	@echo "	BOARD			${BOARD}"
	@echo "	DATA_TYPE		${DATA_TYPE}"
	@echo "	TF			${TF}"
	@echo "	DATASET			${DATASET}"
	@echo "	MATRICES		${MATRICES}"
	@echo "	FASTA_SEQ		${FASTA_SEQ}"
	@echo "	SCAN_CMD		${SCAN_CMD}"
	@echo "	Writing matrix-clustering script"
	@echo "	SCAN_SCRIPT	${SCAN_SCRIPT}"
	@mkdir -p ${SCAN_DIR}
	@echo ${RUNNER_HEADER} > ${SCAN_SCRIPT}
	@echo >> ${SCAN_SCRIPT}
	@echo ${SCAN_CMD} >> ${SCAN_SCRIPT}
	@${RUNNER} ${SCAN_SCRIPT}
	@echo "	SCAN_RESULT		${SCAN_RESULT}"
	@echo

scan_all_datasets:
	@${MAKE} iterate_datasets TASK=scan_one_dataset

scan_all_datatypes:
	@${MAKE} iterate_datatypes DATA_TYPE_TASK=scan_all_datasets


################################################################
## Scan random genome fragments
scan_one_dataset_rand:
	@echo "Scanning random genome fragments"
	@${MAKE} scan_one_dataset FASTA_SEQ=${RAND_SEQ} SCAN_RESULT=${SCAN_DIR}/${TF}_${DATASET}_random-genome-fragments_scan_top-per-seq.tsv

scan_all_datasets_rand:
	@${MAKE} iterate_datasets TASK=scan_one_dataset_rand

scan_all_datatypes_rand:
	@${MAKE} iterate_datatypes DATA_TYPE_TASK=scan_all_datasets_rand


################################################################
## Scan test sequences with the matrices 
scan_test_seq_one_type_one_tf:
	@echo "Scanning test sequences"
	@${MAKE} scan_one_dataset FASTA_SEQ=${TEST_SEQ} SCAN_RESULT=${SCAN_DIR}/${TF}_${DATASET}_random-genome-fragments_scan_top-per-seq.tsv

scan_test_one_type_all_tfs:

scan_test_all_types_all_tfs:
