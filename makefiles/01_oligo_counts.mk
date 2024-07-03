################################################################
## Count occurrences of oligonucleotides (k-mers) in peakn sequences

include scripts/00_parameters.mk
MAKEFILE=scripts/01_oligo_counts.mk
MAKE=make -f ${MAKEFILE}

targets:
	@echo
	@echo "Targets"
	@echo "	targets		list targets"
	@echo "	param		list parameters"
	@echo "	oligo_table	count oligos of a given size (k) in one peakset"
	@echo "	oligo_tables	count oligos of sizes from ${MINOL} to ${MAXOL} in one peakset"

param: peak_param
	@echo
	@echo "oligo-analysis parameters"
	@echo "	OLIGO_DIR	${OLIGO_DIR}"
	@echo "	OL		${OL}"
	@echo "	NOOV		${NOOV)"
	@echo "	OLIGO_DIR	${OLIGO_DIR}"
	@echo "	OLIGO_TABLE	${OLIGO_TABLE}"

################################################################
## Count oligonucleotide occurrences in each peak

## Count k-mers with one length
OL=6
NOOV=-noov
OLIGO_DIR=${RESULT_DIR}/oligo_counts
OLIGO_PREFIX=${OLIGO_DIR}/${OL}nt-2str${NOOV}
OLIGO_TABLE=${OLIGO_PREFIX}.tsv
OLIGO_OUT=${OLIGO_PREFIX}_out.txt
OLIGO_ERR=${OLIGO_PREFIX}_err.txt
CMD=${SCHEDULER} oligo-analysis -v ${V} -i ${PEAK_SEQ} -l ${OL} -2str ${NOOV} -table -o ${OLIGO_TABLE} > ${OLIGO_OUT} 2> ${OLIGO_ERR}
SCRIPT=${OLIGO_PREFIX}_cmd.sh
oligo_table:
	@echo "Running oligo-analysis	${OL}	${BOARD} ${TF} ${PEAKSET}"
	@mkdir -p ${OLIGO_DIR}
	@echo ${SBATCH_HEADER} > ${SCRIPT}
	@echo ${CMD} >> ${SCRIPT}
	@echo "	SCRIPT	${SCRIPT}"
	@sbatch ${SCRIPT}
	@echo "OLIGO_TABLE	${OLIGO_TABLE}"

################################################################
## Iterate over oligonucleotide lengths
MINOL=1
MAXOL=8
OLS=`seq ${MINOL} ${MAXOL}`
oligo_tables:
	@for ol in ${OLS}; do \
		${MAKE} oligo_table OL=$${ol} ; \
	done
