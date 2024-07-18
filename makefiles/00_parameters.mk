################################################################
## Parameters for the analysis of ChIP-seq peaks

MAKE=make -s -f ${MAKEFILE}
MAKEFILE=makefiles/00_parameters.mk

## Load data-type specific configuration
DATA_TYPE=PBM
include makefiles/config_${DATA_TYPE}.mk

V=2

## Job scheduler parameters
NOW=`date +%Y-%m-%d_%H%M`
ERR_DIR=sbatch_errors
ERR_FILE=${ERR_DIR}/sbatch_error_${NOW}.txt
SCHEDULER=srun time
#SCHEDULER=echo \#!/bin/bash ; echo srun time 
SBATCH=sbatch
SBATCH_HEADER="\#!/bin/bash\n\#SBATCH -o ./slurm_out/slurm_${BOARD}_${DATA_TYPE}_${TF}_${DATASET}_%j.out"

DISCIPLINE=WET
BOARD=leaderboard
DATASET_TABLE=metadata/${BOARD}/TF_DATASET_${DATA_TYPE}.tsv

TEST_SEQ=data/${BOARD}/test/${DATA_TYPE}_participants.fasta

#DATASET=`head -n 1 ${DATASET_TABLE} | cut -f 2`
TF=`awk '$$2=="${DATASET}" {print $$1}' ${DATASET_TABLE}`
DATASET_DIR=data/${BOARD}/train/${DATA_TYPE}/${TF}
DATASET_PATH=${DATASET_DIR}/${DATASET}
PEAK_COORD=${DATASET_PATH}.peaks
FASTA_SEQ=${DATASET_PATH}.fasta
TSV_SEQ=${DATASET_PATH}.tsv
FASTQ_SEQ=${DATASET_PATH}.fastq.gz
RESULT_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/${DATASET}

## Background models estimated based on the test sequences
BG_DIR=bg_models/${BOARD}/${DATA_TYPE}
BG_OL=2
BG_FILE=${BG_DIR}/${DATA_TYPE}_${BG_OL}nt-noov-2str.tsv

## Iteration parameters
TASK=oligo_tables
DATASETS=`cut -f 2 ${DATASET_TABLE} | sort -u | xargs`
TFS=`cut -f 1 ${DATASET_TABLE} | sort -u | xargs`

param_00:
	@echo
	@echo "Common parameters"
	@echo "	SCHEDULER	${SCHEDULER}"
	@echo "	SBATCH		${SBATCH}"
	@echo "	SBATCH_HEADER	${SBATCH_HEADER}"
#	@echo "	DISCIPLINE	${DISCIPLINE}"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@echo "	DATASET_TABLE	${DATASET_TABLE}"
	@echo "	TEST_SEQ	${TEST_SEQ}"
	@echo "	TF		${TF}"
	@echo "	RESULT_DIR	${RESULT_DIR}"
	@echo
	@echo "Fetch-sequences"
	@echo "	DATASET_DIR	${DATASET_DIR}"
	@echo "	DATASET		${DATASET}"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	@echo "	FASTA_SEQ	${FASTA_SEQ}"
	@echo "	FETCH_CMD	${FETCH_CMD}"
	@echo "	FASTQ2FASTA_CMD	${FASTQ2FASTA_CMD}"
	@echo
	@echo "Iteration parameters"
	@echo "	DATASETS	${DATASETS}"
	@echo "	TFS		${TFS}"
	@echo "	TASK		${TASK}"
	@echo

targets_00:
	@echo
	@echo "Common targets (makefiles/00_parameters.mk)"
	@echo "	targets			list targets"
	@echo "	param			list parameters"
	@echo "	dataset_table		build a table with the names of datasets associated to each transcription factor"
	@echo "	fetch_sequences		retrieve peak sequences from UCSC (for CHS and GHTS data)"
	@echo "	fastq2fasta		convert sequences from fastq to fasta format (for HTS and SMS data)"
	@echo "	tsv2fasta		convert sequences from tsv files to fasta format (for PBM data)"
	@echo

################################################################
## Run fetch-sequences to retrieve fasta sequences from the peak
## coordinates (bed) from the UCSC genome browser
FETCH_CMD=fetch-sequences -v 1 \
	-genome hg38 \
	-header_format galaxy \
	-i ${PEAK_COORD} -o ${FASTA_SEQ}
fetch_sequences:
	@echo
	@echo "Retrieving peak sequences from UCSC"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	@${FETCH_CMD}
	@echo
	@echo "	FASTA_SEQ	${FASTA_SEQ}"

################################################################
## For HTS and SMS data, convert fastq sequences to fasta format
FASTQ2FASTA_CMD=convert-seq -from fastq -to fasta -i ${FASTQ_SEQ} -o ${FASTA_SEQ}
fastq2fasta:
	@echo
	@echo "Converting sequences from fastq.gz to fasta"
	@echo "	FASTQ_SEQ	${FASTQ_SEQ}"
	@${FASTQ2FASTA_CMD}
	@echo
	@echo "	FASTA_SEQ	${FASTA_SEQ}"

################################################################
## Extract  fasta sequence file from the PBM data, sorted according to scores
PBM_SEQ_ID=${TF}_${DATASET}
TSV2FASTA_CMD=sort -nr -k 8 ${TSV_SEQ} \
	| awk -F'\t' '$$4 =="FALSE" {sig=sprintf("%.3f",$$8); bg=sprintf("%.3f", $$9); print ">${DATASET}_"spot-$$1"-"$$2"-"$$3"_signal_"sig"_bg_"bg"\n"$$6""}'\
	> ${FASTA_SEQ}
tsv2fasta:
	@echo "Extracting fasta sequences from TSV file"
	@echo "	TSV_SEQ		${TSV_SEQ}"
	${TSV2FASTA_CMD}
	@echo "	FASTA_SEQ	${FASTA_SEQ}"

################################################################
## Iterate a task over all datasets of the leaderboard
iterate_datasets:
	@echo 
	@echo "Iterating over datasets"
	@echo "	DATASETS	${DATASETS}"
	@for dataset in ${DATASETS} ; do ${MAKE} one_task DATASET=$${dataset}; done

one_task:
	@echo
	@echo "	BOARD=${BOARD}	DATATYPE=${DATA_TYPE}	TF=${TF}	DATASET=${DATASET}"; \
	${MAKE} ${TASK} TF=${TF} DATASET=${DATASET} ; \


#	${MAKE} ${TASK} TF=GABPA DATASET=THC_0866
#	${MAKE} ${TASK} TF=PRDM5 DATASET=THC_0307.Rep-DIANA_0293
#	${MAKE} ${TASK} TF=PRDM5 DATASET=THC_0307.Rep-MICHELLE_0314
#	${MAKE} ${TASK} TF=SP140 DATASET=THC_0193
#	${MAKE} ${TASK} TF=ZNF362 DATASET=THC_0364.Rep-DIANA_0293
#	${MAKE} ${TASK} TF=ZNF362 DATASET=THC_0364.Rep-MICHELLE_0314
#	${MAKE} ${TASK} TF=ZNF362 DATASET=THC_0411.Rep-DIANA_0293
#	${MAKE} ${TASK} TF=ZNF407 DATASET=THC_0668

################################################################
## Build a table with the peak sets associated to each transcription
## factor.
dataset_table: dataset_table_${SEQ_FORMAT}

################################################################
## CHS and GHTS data (genomic data): peak coordinates, .peak files
dataset_table_fasta:
	@echo
	@echo "Building dataset table for ${DATA_TYPE} ${BOARD} ${SEQ_FORMAT} sequences"
	wc -l data/${BOARD}/train/${DATA_TYPE}/*/*.peaks  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.peaks||' \
		| awk -F'\t' '$$6 != "" {print $$7"\t"$$8"\t"$$2}'  > ${DATASET_TABLE}
	@echo
	@echo "	DATASET_TABLE	${DATASET_TABLE}"
	@echo

################################################################
## HTS and SMS data: fastq.gz files
dataset_table_fastq:
	@echo
	@echo "Building dataset table for ${DATA_TYPE} ${BOARD} ${SEQ_FORMAT} sequences"
	du -sk data/${BOARD}/train/${DATA_TYPE}/*/*.fastq.gz  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.fastq.*||' \
		| awk -F'\t' '$$6 != "" {print $$6"\t"$$7"\t"$$1}'  > ${DATASET_TABLE}
	@echo
	@echo "	DATASET_TABLE	${DATASET_TABLE}"
	@echo
################################################################
## PBM data: TSV files
dataset_table_tsv:
	@echo
	@echo "Building dataset table for ${DATA_TYPE} ${BOARD} ${SEQ_FORMAT} sequences"
	du -sk data/${BOARD}/train/${DATA_TYPE}/*/*.tsv  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.tsv||' \
		| awk -F'\t' '$$6 != "" {print $$6"\t"$$7"\t"$$1}'  > ${DATASET_TABLE}
	@echo
	@echo "	DATASET_TABLE	${DATASET_TABLE}"
	@echo
