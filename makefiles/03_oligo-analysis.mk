################################################################
## Run oligo-analysis on ChIp-seq peak sequences with a BG model
## estimated from the whole test dataset.

include makefiles/00_parameters.mk
MAKEFILE=makefiles/03_oligo-analysis.mk

param: param
	@echo "dataset parameters"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TUPE	${DATA_TYPE}"
	@echo oligo-anlaysis parameters
	@echo "	MINOL		${MINOL}"
	@echo "	MAXOL		${MAXOL}"
	@echo "	BG_DIR		${BG_DIR}"
	@echo "	BG_FILE		${BG_FILE}"
	@echo "	OLIGO_DIR	${OLIGO_DIR}"
	@echo "	OLIGO_SCRIPT	${OLIGO_SCRIPT}"
	@echo "	OLIGO_CMD	${OLIGO_CMD}"
	@echo "	OLIGOS		${OLIGOS}"
	@echo "	ASSEMBLY_CMD	${ASSEMBLY_CMD}"
	@echo "	ASSEMBLY	${ASSEMBLY}"
	@echo "	MATRICES_CMD	${MATRICES_CMD}"
	@echo "	MATRICES	${MATRICES}"
	@echo 

targets: targets
	@echo "Targets"
	@echo "	bg_freq		compute background frequencies"
	@echo "	oligos		detect over-represented oligos"


V=1
OL=6
BG_OL=${OL}
MINOL=6
MAXOL=7
SEQ_SET=YWE_B_AffSeq_C12
QUICK=quick

################################################################
## Compute background frequencies for oligonucleotide

bg_freq:
	@echo "Computing background frequencies from 1nt to ${MAXOL}nt for ${BOARD} ${DATA_TYPE}"
	@for ol in `seq 1 ${MAXOL}`; do \
		${MAKE} bg_freq_one_size BG_OL=$${ol}; \
	done

bg_freq_one_size:
	@echo
	@echo "Computing background frequencies for ${BG_OL}nt"
	@mkdir -p ${BG_DIR}
	time ${RSAT_CMD} oligo-analysis ${QUICK} \
		-v ${V} \
		-i ${TEST_SEQ} \
		-l ${BG_OL} \
		-noov \
		-2str \
		-grouprc \
		-format fasta \
		-seqtype dna \
		-type dna \
		-return freq,occ \
		-o ${BG_FILE}
	@echo "	BG_FILE	${BG_FILE}"

################################################################
## Detect over-represented oligonucleotides
OLIGO_DIR=${RESULT_DIR}/oligos
OLIGOS=
OLIGO_PATH=${OLIGO_DIR}/${OL}nt-noov-2str_${BOARD}_${TF}_${DATASET}
OLIGOS=${OLIGO_PATH}.tsv
MERGED_OLIGO_PATH=${OLIGO_DIR}/${MINOL}-${MAXOL}nt-noov-2str_${BOARD}_${TF}_${DATASET}
MERGED_OLIGOS=${MERGED_OLIGO_PATH}.tsv
ASSEMBLY=${MERGED_OLIGO_PATH}_asmb.txt
MATRICES=${MERGED_OLIGO_PATH}_pssm

OLIGO_CMD=${RSAT_CMD} oligo-analysis -v ${V} \
	-i ${FASTA_SEQ} \
	-l ${OL} \
	–noov \
	-2str \
	-grouprc \
	-seqtype dna \
	-format fasta \
	-expfreq ${BG_FILE} \
	-pseudo 0.05 \
	-return occ,freq,proba,rank \
	-sort \
	-lth occ_sig 10 \
	-uth rank 50 \
	-lth occ_sig 1 \
	-o ${OLIGOS}
ASSEMBLY_CMD=${RSAT_CMD} pattern-assembly -v ${V} \
	-subst 1 \
	-toppat 50 \
	-2str \
	-max_asmb_nb 20 \
	-i ${OLIGOS} \
	-o ${ASSEMBLY}
MATRIX_CMD=${RSAT_CMD} matrix-from-patterns \
	-v ${V} \
	-logo  \
	-seq ${FASTA_SEQ} \
	-format fasta \
	-asmb ${ASSEMBLY} \
	-min_weight 5 \
	-flanks 2 \
	-max_asmb_nb 20 \
	-cluster sig \
	-uth Pval 0.00025 \
	-bginput \
	-markov 0 \
	-o ${MATRICES}

OLIGO_SCRIPT=${OLIGO_DIR}/oligo_script.sh
oligos:
	@echo "Detecting over-represented oligonucleotides"
	@echo "	OLIGO_DIR	${OLIGO_DIR}"
	@mkdir -p ${OLIGO_DIR}
	@echo
	@echo "Writing oligo-analysis script	${OLIGO_SCRIPT}"
	@echo ${SBATCH_HEADER} > ${OLIGO_SCRIPT}
	@for ol in `seq ${MINOL} ${MAXOL}`; do \
		${MAKE} oligos_one_len OL=$${ol} ; \
	done
	@echo >> ${OLIGO_SCRIPT}
	@echo ${ASSEMBLY_CMD} >> ${OLIGO_SCRIPT}
	@echo >> ${OLIGO_SCRIPT}
	@echo ${MATRIX_CMD} >> ${OLIGO_SCRIPT}
	@echo
	@echo "	OLIGO_SCRIPT	${OLIGO_SCRIPT}"
	@echo "Running oligo-analysis to detect over-represented motifs"
	@${SBATCH} ${OLIGO_SCRIPT}
	@echo
	@echo "	OLIGO_DIR	${OLIGO_DIR}"
	@echo "	OLIGOS		${OLIGOS}"
	@echo "	ASSEMBLY	${ASSEMBLY}"
	@echo "	MATRICES	${MATRICES}"

oligos_one_len:
	@echo "oligo-analysis	${OL}nt"
	@echo >> ${OLIGO_SCRIPT}
	@echo ${OLIGO_CMD} >> ${OLIGO_SCRIPT}
