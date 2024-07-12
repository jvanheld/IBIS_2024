################################################################
## Parameters for the analysis of ChIP-seq peaks

MAKE=make -s -f ${MAKEFILE}

V=1

## Job scheduler parameters
NOW=`date +%Y-%m-%d_%H%M`
ERR_DIR=sbatch_errors
ERR_FILE=${ERR_DIR}/sbatch_error_${NOW}.txt

SCHEDULER=srun time
#SCHEDULER=echo \#!/bin/bash ; echo srun time 
SBATCH=sbatch
SBATCH_HEADER="\#!/bin/bash"

DISCIPLINE=WET
BOARD=leaderboard
PEAKSET_TABLE=metadata/${BOARD}/TF_PEAKSET_${DATA_TYPE}.tsv
#TF=GABPA
DATA_TYPE=GHTS
PEAKSET=YWE_B_AffSeq_C12_GABPA.C2
#DATA_TYPE=CHS
#PEAKSET=THC_0866
#PEAKSET=`head -n 1 ${PEAKSET_TABLE} | cut -f 2`
TF=`awk '$$2=="${PEAKSET}" {print $$1}' ${PEAKSET_TABLE}`
PEAK_PATH=data/${BOARD}/train/${DATA_TYPE}/${TF}/${PEAKSET}
PEAK_COORD=${PEAK_PATH}.peaks
PEAK_SEQ=${PEAK_PATH}.fasta
RESULT_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/${PEAKSET}

## Iteration parameters
TASK=oligo_tables
PEAKSETS=`cut -f 2 ${PEAKSET_TABLE} | sort -u | xargs`
TFS=`cut -f 1 ${PEAKSET_TABLE} | sort -u | xargs`b

param_00:
	@echo
	@echo "Common parameters"
	@echo "	SCHEDULER	${SCHEDULER}"
	@echo "	SBATCH		${SBATCH}"
	@echo "	SBATCH_HEADER	${SBATCH_HEADER}"
#	@echo "	DISCIPLINE	${DISCIPLINE}"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@echo "	PEAKSET_TABLE	${PEAKSET_TABLE}"
	@echo "	TF		${TF}"
	@echo "	RESULT_DIR	${RESULT_DIR}"
	@echo
	@echo "Fetch-sequences"
	@echo "	PEAKSET		${PEAKSET}"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	@echo "	PEAK_SEQ	${PEAK_SEQ}"
	@echo "	FETCH_CMD	${FETCH_CMD}"
	@echo
	@echo "Iteration parameters"
	@echo "	PEAKSETS	${PEAKSETS}"
	@echo "	TFS		${TFS}"
	@echo "	TASK		${TASK}"
	@echo

targets_00:
	@echo
	@echo "Common targets (makefiles/00_parameters.mk)"
	@echo "	targets			list targets"
	@echo "	param			list parameters"
	@echo "	peakset_table		build a table with the names of peaksets associated to each transcription factor"
	@echo "	sequences		retrieve peak sequences from UCSC"
	@echo

################################################################
## Run fetch-sequences to retrieve fasta sequences from the peak
## coordinates (bed) from the UCSC genome browser
FETCH_CMD=fetch-sequences -v 1 \
	-genome hg38 \
	-header_format galaxy \
	-i ${PEAK_COORD} -o ${PEAK_SEQ}
sequences:
	@echo
	@echo "Retrieving peak sequences from UCSC"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	${SCHEDULER} ${FETCH_CMD} ${POST_SCHEDULER}
	@echo
	@echo "	PEAK_SEQ	${PEAK_SEQ}"

################################################################
## Iterate a task over all peaksets of the leaderboard
iterate_peaksets:
	@echo 
	@echo "Iterating over peaksets"
	@echo "	PEAKSETS	${PEAKSETS}"
	@for peakset in ${PEAKSETS} ; do ${MAKE} one_task PEAKSET=$${peakset}; done

one_task:
#	@echo
	@echo "	TF=${TF}	PEAKSET=${PEAKSET}"; \
	${MAKE} ${TASK} TF=${TF} PEAKSET=${PEAKSET} ; \


#	${MAKE} ${TASK} TF=GABPA PEAKSET=THC_0866
#	${MAKE} ${TASK} TF=PRDM5 PEAKSET=THC_0307.Rep-DIANA_0293
#	${MAKE} ${TASK} TF=PRDM5 PEAKSET=THC_0307.Rep-MICHELLE_0314
#	${MAKE} ${TASK} TF=SP140 PEAKSET=THC_0193
#	${MAKE} ${TASK} TF=ZNF362 PEAKSET=THC_0364.Rep-DIANA_0293
#	${MAKE} ${TASK} TF=ZNF362 PEAKSET=THC_0364.Rep-MICHELLE_0314
#	${MAKE} ${TASK} TF=ZNF362 PEAKSET=THC_0411.Rep-DIANA_0293
#	${MAKE} ${TASK} TF=ZNF407 PEAKSET=THC_0668

################################################################
## Build a table with the peak sets associated to each transcription
## factor.
peakset_table:
	@echo
	@echo "Building peakset table for ${DATA_TYPE} ${BOARD}"
	wc -l data/${BOARD}/train/${DATA_TYPE}/*/*.peaks  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.peaks||' \
		| awk -F'\t' '$$6 != "" {print $$7"\t"$$8"\t"$$2}'  > ${PEAKSET_TABLE}
	@echo "	PEAKSET_TABLE	${PEAKSET_TABLE}"
	@echo
