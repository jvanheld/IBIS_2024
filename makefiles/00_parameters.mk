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
DATA_TYPE=CHS
#TF=GABPA
PEAKSET=THC_0866
TF=`awk '$$2=="${PEAKSET}" {print $$1}' ${PEAKSET_TABLE}`
PEAK_PATH=data/${BOARD}/train/${DATA_TYPE}/${TF}/${PEAKSET}
PEAK_COORD=${PEAK_PATH}.peaks
PEAK_SEQ=${PEAK_PATH}.fasta
RESULT_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/${PEAKSET}

## Iteration parameters
TASK=oligo_tables
PEAKSETS=`cut -f 2 ${PEAKSET_TABLE} | sort -u | xargs`
TFS=`cut -f 1 ${PEAKSET_TABLE} | sort -u | xargs`b

peak_param:
	@echo
	@echo "Peak parameters"
	@echo "	SCHEDULER	${SCHEDULER}"
	@echo "	SBATCH		${SBATCH}"
	@echo "	SBATCH_HEADER	${SBATCH_HEADER}"
#	@echo "	DISCIPLINE	${DISCIPLINE}"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@echo "	PEAKSET_TABLE	${PEAKSET_TABLE}"
	@echo "	TF		${TF}"
	@echo "	PEAKSET		${PEAKSET}"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	@echo "	PEAK_SEQ	${PEAK_SEQ}"
	@echo "	RESULT_DIR	${RESULT_DIR}"
	@echo
	@echo "Iteration parameters"
	@echo "	PEAKSETS	${PEAKSETS}"
	@echo "	TFS		${TFS}"
	@echo "	TASK		${TASK}"

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
