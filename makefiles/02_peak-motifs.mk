###############################################################
## Motif discovery for the IBIS challenge 2024
##
## Participants: Jacques van Helden and Bruno Contreiras Moreira

include makefiles/01_init.mk
MAKEFILE=makefiles/02_peak-motifs.mk

targets: targets_00
	@echo "Peak-motifs targets (${MAKEFILE})"
	@echo
	@echo "Single-dataset motif discovery"
	@echo "	peakmo			discover motifs in peak sequences"
	@echo "	peakmo_all_datasets	run peak-motifs in all the datasets of this type of experiment"
	@echo "	peakmo_all_experiments	run peak-motifs in all the datasets of all experiments"
	@echo
	@echo "Differential motif discovery"
	@echo "	peakmo_diff_one_dataset		run differential motif discovery on one dataset"
	@echo "	peakmo_diff_all_datasets	run differential motif discovery on all datasets of a given experiment"
	@echo "	peakmo_diff_all_experiments	run differential motif discovery on all datasets of all experiments"
	@echo

param: param_00
	@echo
	@echo "peak-motifs options, single-dataset mode"
	@echo "	PEAKMO_OPT		${PEAKMO_OPT}"
	@echo "	PEAKMO_PRERIX		${PEAKMO_PREFIX}"
	@echo "	PEAKMO_DIR		${PEAKMO_DIR}"
	@echo "	PEAKMO_MATRICES		${PEAKMO_MATRICES}"
	@echo "	PEAKMO_TASKS		${PEAKMO_TASKS}"
	@echo "	PEAKMO_CMD		${PEAKMO_CMD}"
	@echo " PEAKMO_SCAN_DIR		${PEAKMO_SCAN_DIR}"
	@echo " PEAKMO_SCAN_PREFIX	${PEAKMO_SCAN_PREFIX}"
	@echo "	PEAKMO_SCRIPT		${PEAKMO_SCRIPT}"
	@echo
	@echo "peak-motifs options, differential mode"
	@echo "	POS_SEQ			${POS_SEQ}"
	@echo "	NEG_SEQ			${NEG_SEQ}"
	@echo "	DIFF_SUFFIX		${DIFF_SUFFIX}"
	@echo "	PEAKMO_DIFF_CMD		${PEAKMO_DIFF_CMD}"
	@echo "	PEAKMO_DIFF_SCRIPT	${PEAKMO_DIFF_SCRIPT}"
	@echo


## Define the matrices to use as input for matrix-clustering
#MATRICES=${PEAKMO_MATRICES}

################################################################
## Run peak-motifs to discover motifs in peak sequences
PEAKMO_TASKS=purge,seqlen,composition,disco,merge_motifs,split_motifs,motifs_vs_motifs,motifs_vs_db,scan,timelog,synthesis,small_summary
PEAKMO_CMD=${SCHEDULER} ${RSAT_CMD} peak-motifs \
	-v ${V} \
	-title 'IBIS24_${BOARD}_${EXPERIMENT}_${TF}_${DATASET}' \
	-i ${TRAIN_SEQ} \
	-2str \
	-noov \
	-origin center \
	-max_seq_len 500 \
	-minol ${PEAKMO_MINOL} -maxol ${PEAKMO_MAXOL} \
	-scan_markov 1 \
	-disco oligos,positions,dyads,local_words \
	-markov auto \
	-nmotifs ${PEAKMO_NMOTIFS} \
	-no_merge_lengths \
	-prefix ${PEAKMO_PREFIX} \
	-img_format png \
	-motif_db Hocomoco_human tf ${HOCOMOCO_MOTIFS} \
	-motif_db jaspar_core_nonredundant_vertebrates tf ${JASPAR_MOTIFS} \
	-task ${PEAKMO_TASKS} \
	${PEAKMO_OPT} \
	-outdir ${PEAKMO_DIR}
PEAKMO_SCRIPT=${PEAKMO_DIR}/peak-motif${PEAKMO_OPT}_cmd.sh
peakmo: 
	@echo
	@echo "Writing peak-motif script	${PEAKMO_SCRIPT}"
	@mkdir -p ${PEAKMO_DIR}
	@echo -e ${RUNNER_HEADER} > ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
ifeq (${SOURCE_FORMAT}, fasta)
	@echo "Including fetch-sequences command in the script to get sequences from peak coordinates"
	@echo ${FETCH_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
else ifeq (${SOURCE_FORMAT}, tsv)
	@echo "Including command in the script to extract fasta sequences from tsv files (PBM data)"
	@echo ${TSV2FASTA_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
else ifeq (${SOURCE_FORMAT}, fastq)
	@echo "Including command in the script to convert fastq.gz to fasta sequences"
	@echo ${FASTQ2FASTA_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
endif
	@echo ${PEAKMO_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@mkdir -p ${PEAKMO_CLUSTERS_DIR}
	@echo ${CLUSTER_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@mkdir -p ${MATRIXQ_DIR}
	@echo "${CONVERT_MATRIX_CMD}" >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@echo ${MATRIXQ_CMD} >> ${PEAKMO_SCRIPT}
	@echo
	@echo "	PEAKMO_SCRIPT	${PEAKMO_SCRIPT}"
	@echo "Running peak-motifs"
	@${RUNNER} ${PEAKMO_SCRIPT}
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"

# all: param sequences peakmo
################################################################
## Iterate over all datasets of a given experiment
TASK=peakmo
peakmo_all_datasets:
	@${MAKE} iterate_datasets TASK=peakmo

peakmo_all_experiments:
	@${MAKE} iterate_experiments EXPERIMENT_TASK=peakmo_all_datasets

################################################################
## Run differential analysis with peak-motifs, to discover motifs in
## train sequences that are over-represented with respecct to
## background sequences.
POS_SEQ=${TRAIN_SEQ}
POS_SUFFIX=train
NEG_SEQ=${OTHERS_SEQ}
NEG_SUFFIX=others
DIFF_SUFFIX=${POS_SUFFIX}-vs-${NEG_SUFFIX}
PEAKMO_DIFF_DIR=${RESULT_DIR}/peak-motifs${PEAKMO_OPT}_${DIFF_SUFFIX}
PEAKMO_DIFF_CMD=${SCHEDULER} ${RSAT_CMD} peak-motifs  \
	-v ${V} \
	-title ${BOARD}_${EXPERIMENT}_${TF}_${DATASET}_train_vs_bg  \
	-i ${POS_SEQ} \
	-ctrl ${NEG_SEQ} \
	-max_seq_len 500 \
	-markov auto \
	-disco oligos,dyads \
	-nmotifs ${PEAKMO_NMOTIFS}  \
	-minol  ${PEAKMO_MINOL} \
	-maxol ${PEAKMO_MAXOL} \
	-2str  \
	-origin center  \
	-motif_db Hocomoco_human tf ${HOCOMOCO_MOTIFS} \
	-motif_db jaspar_core_redundant_vertebrates tf ${JASPAR_MOTIFS} \
	-scan_markov 1 \
	-task purge,seqlen,composition,disco,merge_motifs,split_motifs,motifs_vs_motifs,timelog,synthesis,small_summary,motifs_vs_db,scan \
	-prefix peak-motifs \
	-noov \
	-img_format png  \
	${PEAKMO_OPT} \
	-outdir ${PEAKMO_DIFF_DIR}
PEAKMO_DIFF_SCRIPT=${PEAKMO_DIFF_DIR}/peak-motif${PEAKMO_OPT}_${DIFF_SUFFIX}_cmd.sh

peakmo_diff_one_dataset:
	@echo
	@echo "Running peak-motifs in differential analysis mode"
	@echo
	@echo "Writing peak-motif script for differential analysis	${PEAKMO_DIFF_SCRIPT}"
	@mkdir -p ${PEAKMO_DIFF_DIR}
	@echo -e ${RUNNER_HEADER} > ${PEAKMO_DIFF_SCRIPT}
	@echo >> ${PEAKMO_DIFF_SCRIPT}
	@echo ${PEAKMO_DIFF_CMD} >> ${PEAKMO_DIFF_SCRIPT}
	@echo >> ${PEAKMO_DIFF_SCRIPT}
	@mkdir -p ${PEAKMO_CLUSTERS_DIR}
	@echo ${CLUSTER_CMD} >> ${PEAKMO_DIFF_SCRIPT}
	@echo  >> ${PEAKMO_DIFF_SCRIPT}
	@echo "${CONVERT_MATRIX_CMD}" >> ${PEAKMO_DIFF_SCRIPT}
	@echo >> ${PEAKMO_DIFF_SCRIPT}
	@mkdir -p ${MATRIXQ_DIR}
	@echo ${MATRIXQ_CMD} >> ${PEAKMO_DIFF_SCRIPT}
	@echo
	@echo "	PEAKMO_DIFF_SCRIPT	${PEAKMO_DIFF_SCRIPT}"
	@echo "Running peak-motifs"
	@${RUNNER} ${PEAKMO_DIFF_SCRIPT}
	@echo "	PEAKMO_DIFF_DIR	${PEAKMO_DIFF_DIR}"

peakmo_diff_all_datasets:
	@${MAKE} iterate_datasets TASK=peakmo_diff_one_dataset

peakmo_diff_all_experiments:
	@${MAKE} iterate_experiments EXPERIMENT_TASK=peakmo_diff_all_datasets

