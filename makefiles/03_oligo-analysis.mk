################################################################
## Run oligo-analysis on ChIp-seq peak sequences with a BG model
## estimated from the whole test dataset.

include makefiles/00_parameters.mk
MAKEFILE=makefiles/03_oligo-analysis.mk

param:
	@echo "dataset parameters"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TUPE	${DATA_TYPE}"
	@echo "	TEST_SEQ	${TEST_SEQ}"
	@echo oligo-anlaysis parameters
	@echo "	MINOL		${MINOL}"
	@echo "	MAXOL		${MAXOL}"
	@echo "	BG_DIR		${BG_DIR}"
	@echo "	BG_FILE		${BG_FILE}"
	@echo "	OLIGO_CMD	${OLIGO_CMD}"
	@echo 

targets:
	@echo "Targets"
	@echo "	bg_freq		compute background frequencies"


V=1
OL=6
MINOL=6
MAXOL=7
TEST_SEQ=data/${BOARD}/test/${DATA_TYPE}_participants.fasta
SEQ_SET=YWE_B_AffSeq_C12
TRAIN_PATH=data/${BOARD}/train/${DATA_TYPE}/${TF}/${SEQSET}_${TF}.C2
TRAIN_COORD=${TRAIN_PATH}.peaks
TRAIN_SEQ=${TRAIN_PATH}.fasta
BG_DIR=bg_models/${BOARD}/${DATA_TYPE}
BG_FILE=${BG_DIR}/${DATA_TYPE}_${OL}nt-noov-2str.tsv

################################################################
## Compute background frequencies for oligonucleotide

bg_freq:
	@echo "Computing background frequencies from ${MINOL}nt to ${MAXOL}nt for ${BOARD} ${DATA_TYPE}"
	@for ol in `seq ${MINOL} ${MAXOL}`; do \
		${MAKE} bg_freq_one_size OL=$${ol}; \
	done

bg_freq_one_size:
	@echo
	@echo "Computing background frequencies for ${OL}nt"
	@mkdir -p ${BG_DIR}
	time oligo-analysis -quick -v ${V} -i ${TEST_SEQ} -l ${OL} -noov -2str -grouprc -return occ,freq -format fasta -seqtype dna -noov -l ${OL} -type dna -return freq,occ -o ${BG_FILE}
	@echo "	BG_FILE	${BG_FILE}"

################################################################
## Detect over-represented oligonucleotides
OLIGO_CMD=oligo-analysis -v ${V} -i ${TRAIN_SEQ} \
	–noov -2str -grouprc -seqtype dna \
	-format fasta -expfreq ${BG_FILE} \
	-pseudo 0.05 \
	-return occ,freq,proba,rank -sort \
	-lth occ_sig 10 -uth rank 50 -lth sig 1 \
	-o ${OLIGOS}
oligos:
	@echo
	@echo "Detecting over-represented oligonucleotides"



