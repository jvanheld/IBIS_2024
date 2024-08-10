################################################################
## Analysis of Protein Binding Microarray (PBM) data for the IBIS
## challenge 2024

include makefiles/00_parameters.mk
MAKEFILE=makefiles/04_PBM.mk
include makefiles/config_PBM.mk

targets: targets_00
	@echo "PBM tasks"
	@echo "	metadata_pbm			build metadata table for PBM data, from the TSV file"
	@echo "	top_seq				extract top-raking ${TOP_SPOTS} sequences as test"
	@echo "	bg_seq				extract bottom ${BG_SPOTS} sequences as background"
	@echo "	top_seq_all_datasets		iterate top_seq over all datasets"
	@echo "	bg_seq_all_datasets		iterate bg_seq over all datasets"
	@echo "	top_bg_seq_all_datasets		iterate bg_seq and bg_seq over all datasets"
	@echo "	peakmo_diff_all_datasets	run peak-motifs differential analysis in all the datasets"
	@echo

TEST_SEQ=${BG_SEQ}
param: param_00
	@echo "PBM top / background sequences"
	@echo "	N_TOP_SPOTS	${N_TOP_SPOTS}"
	@echo "	N_TOP_ROWS	${N_TOP_ROWS}"
	@echo "	TOP_SUFFIX	${TOP_SUFFIX}"
	@echo "	TOP_SEQ		${TOP_SEQ}"
	@echo "	N_BG_SPOTS	${N_BG_SPOTS}"
	@echo "	N_BG_ROWS	${N_BG_ROWS}"
	@echo "	BG_SUFFIX	${BG_SUFFIX}"
	@echo "	BG_SEQ		${BG_SEQ}"
	@echo
	@echo "Redefining test sequences as background sequences"
	@echo "	TEST_SEQ	${TEST_SEQ}"
	@echo
	@echo "peak-motifs differential analysis options"
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"
	@echo "	PEAKMO_CMD	${PEAKMO_CMD}"
	@echo "	PEAKMO_SCRIPT	${PEAKMO_SCRIPT}"
	@echo

## Define the matrices to use as input for matrix-clustering and matrix-quality
MATRICES=${PEAKMO_MATRICES}

#metadata_pbm_all_datasets:
#	@${MAKE} iterate_datasets EXPERIMENT=PBM TASK=metadata_pbm

metadata_pbm:
	@echo
	@echo "Building metadata table for ${BOARD} ${EXPERIMENT} data (source data format: ${SOURCE_FORMAT})"
	@echo
	@echo ${METADATA_HEADER} > ${METADATA}
	du -sk data/${BOARD}/train/${EXPERIMENT}/*/*.tsv  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.tsv||' \
		| awk -F'\t' '$$6 != "" {print $$6"\t"$$7"\t"$$1"\t${EXPERIMENT}\t${BOARD}\t${SOURCE_FORMAT}\t"$$2"/"$$3"/"$$4"/"$$5"/"$$6"/"$$7"_top${N_TOP_SPOTS}.fasta"}'  >> ${METADATA}
	@echo
	@echo "	METADATA	${METADATA}"
	@echo


################################################################
## For PBM datasets, select an aribtrary number of top-ranking oligos
## and consider them as binding sites, and the bottom-ranking oligos
## as background
N_TOP_SPOTS=0500
N_TOP_ROWS=1000
N_BG_SPOTS=35000
N_BG_ROWS=70000
TOP_SUFFIX=top${N_TOP_SPOTS}
BG_SUFFIX=bg${N_BG_SPOTS}
TOP_SEQ=${DATASET_PATH}_${TOP_SUFFIX}.fasta
BG_SEQ=${DATASET_PATH}_bg${N_BG_SPOTS}.fasta
top_seq:
	@echo
	@echo "Selecting top-raking spot sequences as signal"
	@echo "	N_TOP_SPOTS	${N_TOP_SPOTS}"
	@echo "	N_TOP_ROWS	${N_TOP_ROWS}"
	@head -n ${N_TOP_ROWS} ${FASTA_SEQ} > ${TOP_SEQ}
	@echo "	TOP_SEQ	${TOP_SEQ}"

bg_seq:
	@echo
	@echo "Selecting bottom-raking spot sequences as background"
	@echo "	N_BG_SPOTS	${N_BG_SPOTS}"
	@echo "	N_BG_ROWS	${N_BG_ROWS}"
	@tail -n ${N_BG_ROWS} ${FASTA_SEQ} > ${BG_SEQ}
	@echo "	BG_SEQ	${BG_SEQ}"

top_seq_all_datasets:
	@${MAKE} iterate_datasets TASK=top_seq

bg_seq_all_datasets:
	@${MAKE} iterate_datasets TASK=bg_seq

top_bg_seq_all_datasets: top_seq_all_datasets bg_seq_all_datasets


################################################################
## Run differential analysis with peak-motifs, to discover motifs in
## train sequences that are over-represented with respecct to
## background sequences.
DIFF_SUFFIX=${TOP_SUFFIX}_vs_${BG_SUFFIX}
PEAKMO_DIR=${RESULT_DIR}/peak-motifs${PEAKMO_OPT}_${DIFF_SUFFIX}
PEAKMO_CMD=${SCHEDULER} ${RSAT_CMD} peak-motifs  \
	-v ${V} \
	-title ${BOARD}_${EXPERIMENT}_${TF}_${DATASET}_train_vs_bg  \
	-i ${TOP_SEQ} \
	-ctrl ${BG_SEQ} \
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
	-outdir ${PEAKMO_DIR}
PEAKMO_SCRIPT=${PEAKMO_DIR}/peak-motif${PEAKMO_OPT}_${DIFF_SUFFIX}_cmd.sh

peakmo_diff: top_seq
	@echo
	@echo "Running peak-motifs in differential analysis mode"
	@echo
	@echo "Writing peak-motif script for differential analysis	${PEAKMO_SCRIPT}"
	@mkdir -p ${PEAKMO_DIR}
	@echo ${RUNNER_HEADER} > ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@echo ${PEAKMO_CMD} >> ${PEAKMO_SCRIPT}
	@echo
	@echo "${CONVERT_MATRIX_CMD}" >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@mkdir -p ${PEAKMO_CLUSTERS_DIR}
	@echo ${CLUSTER_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@mkdir -p ${MATRIXQ_DIR}
	@echo ${MATRIXQ_CMD} >> ${PEAKMO_SCRIPT}
	@echo
	@echo "	PEAKMO_SCRIPT	${PEAKMO_SCRIPT}"
	@echo "Running peak-motifs"
	@${RUNNER} ${PEAKMO_SCRIPT}
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"

peakmo_diff_all_datasets:
	@${MAKE} iterate_datasets TASK=peakmo_diff
