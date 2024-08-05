################################################################
## IBIS challenge 2024
##
## Score each sequence with matrix-scan for a 2-group classification
## problem


include makefiles/00_parameters.mk 
MAKEFILE=makefiles/06_score_sequences.mk

targets: targets_00
	@echo
	@echo "Sequence scoring"
	@echo "	rand_fragments	select random genome fragment as negative set for a given dataset"
	@echo "		"

param:: param_00
	@echo


RAND_SEQ=${DATASET_PATH}_random-genome-fragments.fa
RAND_SEQ_CMD=${RSAT_CMD} random-genome-fragments  \
		-template_format fasta \
		-i ${FASTA_SEQ} \
		-org Homo_sapiens_GCF_000001405.40_GRCh38.p14  \
		-return seq \
		-o ${RAND_SEQ}
rand_fragments:
	@echo
	@echo "Selecting random genome fragments for ${BOARD} train ${DATASET}"
	@echo ${RAND_SEQ_CMD}


