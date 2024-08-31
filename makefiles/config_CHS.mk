## Default configuration for CHS data
EXPERIMENT=CHS
ifeq (${BOARD},final)
	DATASET=THC_0757
else
	DATASET=THC_0866
endif
SOURCE_FORMAT=fasta
SOURCE_EXT=fasta
