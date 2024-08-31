## Test configuration for S%S data
EXPERIMENT=SMS
ifeq (${BOARD},final)
	DATASET=SRR3405056
else
	DATASET=SRR3405069
#	TF=NFKB1
endif
SOURCE_FORMAT=fastq
SOURCE_EXT=fastq.gz
