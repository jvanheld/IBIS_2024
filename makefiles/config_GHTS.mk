## Test configuration for GHTS data
EXPERIMENT=GHTS
ifeq (${BOARD},final)
	DATASET=YWE_B_AffSeq_B02_SALL3.C3
#	TF=SALL3
else
	DATASET=YWE_B_AffSeq_C12_GABPA.C2
#	TF=GABPA
endif
SOURCE_FORMAT=fasta
SOURCE_EXT=fasta
