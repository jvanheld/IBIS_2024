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
	@echo "Sequence scoring"
	@echo "	rand_fragments			select random genome fragment as negative set for a given dataset"e
	@echo "	rand_fragments_all_datasets	run rand_fragments for all the datasets of the current data type"
	@echo "	rand_fragments_all_datatypes	run rand_fragments for all the datasets of all the data types"
	@echo "	scan_one_dataset		scan one dataset with a set of matrices"
	@echo "		"

param:: param_00
	@echo
	@echo "Sequence scoring parameters"
	@echo "==========================="
	@echo
	@echo "Random sequences"
	@echo "	RAND_SEQ	${RAND_SEQ}"
	@echo "	RAND_SCRIPT	${RAND_SCRIPT}"
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
DATA_TYPE=CSH
TF=GABPA
DATASET=THC_0866
MATRICES=${TFCLUST_ALL_MOTIFS}_trimmed

################################################################
## Select random genomic sequences of the same lengths as the current
## data set
RAND_SEQ=${DATASET_PATH}_random-genome-fragments.fa
RAND_CMD=${SCHEDULER} ${RSAT_CMD} random-genome-fragments  \
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
DATA_TYPE=CHS
DATASET=
SCAN_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/scan
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
	-lth rank_pm 1 \
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
