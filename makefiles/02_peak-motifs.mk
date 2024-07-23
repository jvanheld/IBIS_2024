###############################################################
## Motif discovery for the IBIS challenge 2024
##
## Participants: Jacques van Helden and Bruno Contreiras Moreira

include makefiles/00_parameters.mk
MAKEFILE=makefiles/02_peak-motifs.mk

targets: targets_00
	@echo "Peak-motifs targets (${MAKEFILE})"
	@echo "	peakmo			discover motifs in peak sequences"
	@echo "	peakmo_diff		run peak-motifs tp detect over-represented motifs in top versus background sequences"
	@echo "	cluster_matrices	run matrix-clustering on the motifs discovered with peak-motifs"
	@echo

param: param_00
	@echo
	@echo "peak-motifs options"
	@echo "	PEAKMO_OPT		${PEAKMO_OPT}"
	@echo "	PEAKMO_DIR		${PEAKMO_DIR}"
	@echo "	PEAKMO_MATRICES		${PEAKMO_MATRICES}"
	@echo "	PEAKMO_TASKS		${PEAKMO_TASKS}"
	@echo "	PEAKMO_CMD		${PEAKMO_CMD}"
	@echo "	PEAKMO_SCRIPT		${PEAKMO_SCRIPT}"
	@echo

################################################################
## Run peak-motifs to discover motifs in peak sequences
PEAKMO_TASKS=purge,seqlen,composition,disco,merge_motifs,split_motifs,motifs_vs_motifs,motifs_vs_db,scan,timelog,synthesis,small_summary
PEAKMO_CMD=${SCHEDULER} ${RSAT_CMD} peak-motifs \
	-v ${V} \
	-title 'IBIS24_${BOARD}_${DATA_TYPE}_${TF}_${DATASET}' \
	-i ${FASTA_SEQ} \
	-2str \
	-noov \
	-origin center \
	-max_seq_len 500 \
	-minol 6 -maxol 7 \
	-scan_markov 1 \
	-disco oligos,positions,dyads,local_words \
	-markov auto \
	-nmotifs 5 \
	-no_merge_lengths \
	-prefix peak-motifs${PEAKMO_OPT} \
	-img_format png \
	-motif_db Hocomoco_human tf ${HOCOMOCO_MOTIFS} \
	-motif_db jaspar_core_nonredundant_vertebrates tf ${JASPAR_MOTIFS} \
	-task ${PEAKMO_TASKS} \
	-outdir ${PEAKMO_DIR} ${PEAKMO_OPT}
PEAKMO_SCRIPT=${PEAKMO_DIR}/peak-motif${PEAKMO_OPT}_cmd.sh
peakmo: 
	@echo
	@echo "Writing peak-motif script	${PEAKMO_SCRIPT}"
	@mkdir -p ${PEAKMO_DIR}
	@echo ${SBATCH_HEADER} > ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
ifeq (${SEQ_FORMAT}, fasta)
	@echo "Including fetch-sequences command in the script to get sequences from peak coordinates"
	@echo ${FETCH_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
else ifeq (${SEQ_FORMAT}, tsv)
	@echo "Including command in the script to extract fasta sequences from tsv files (PBM data)"
	@echo ${TSV2FASTA_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
else ifeq (${SEQ_FORMAT}, fastq)
	@echo "Including command in the script to convert fastq.gz to fasta sequences"
	@echo ${FASTQ2FASTA_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
endif
	@echo ${PEAKMO_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@echo "${CONVERT_MATRIX_CMD}" >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@mkdir -p ${PEAKMO_CLUSTERS_DIR}
	@echo ${CLUSTER_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@mkdir -p ${QUALITY_DIR}
	@echo ${QUALITY_CMD} >> ${PEAKMO_SCRIPT}
	@echo
	@echo "	PEAKMO_SCRIPT	${PEAKMO_SCRIPT}"
	@echo "Running peak-motifs"
	@${SBATCH} ${PEAKMO_SCRIPT}
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"


# all: param sequences peakmo
################################################################
## Iterate over all datasets of a given data type
TASK=peakmo
peakmo_all_datasets:
	@${MAKE} iterate_datasets TASK=peakmo


