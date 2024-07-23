################################################################
## Analysis of Protein Binding Microarray (PBM) data for the IBIS
## challenge 2024

include makefiles/00_parameters.mk
MAKEFILE=makefiles/04_PBM.mk

targets: targets_00
	@echo "PBM tasks"
	@echo "	metadata_pbm		build metadata table for PBM data, from the TSV file"
	@echo "	top_seq			extract top-raking ${TOP_SPOTS} sequences as test"
	@echo "	bg_seq			extract bottom ${BG_SPOTS} sequences as background"
	@echo "	top_seq_all_datasets	iterate top_seq over all datasets"
	@echo "	bg_seq_all_datasets	iterate bg_seq over all datasets"
	@echo "	top_bg_seq_all_datasets	iterate bg_seq and bg_seq over all datasets"
	@echo "	peakmodiff_all_datasets	run peak-motifs differential analysis in all the datasets"
	@echo

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
	@echo "peak-motifs differential analysis options"
	@echo "	PEAKMODIFF_DIR		${PEAKMODIFF_DIR}"
	@echo "	PEAKMODIFF_CMD		${PEAKMODIFF_CMD}"
	@echo "	PEAKMODIFF_SCRIPT	${PEAKMODIFF_SCRIPT}"
	@echo

################################################################
## PBM data: TSV files
metadata_pbm:
	@echo
	@echo "Building dataset table for ${DATA_TYPE} ${BOARD} ${SEQ_FORMAT} sequences"
	du -sk data/${BOARD}/train/${DATA_TYPE}/*/*.tsv  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.tsv||' \
		| awk -F'\t' '$$6 != "" {print $$6"\t"$$7"\t"$$1}'  > ${METADATA}
	@echo
	@echo "	METADATA	${METADATA}"
	@echo

metadata_pbm_all_datasets:
	@${MAKE} iterate_datasets DATA_TYPE=PBM TASK=metadata_pbm

################################################################
## For PBM datasets, select an aribtrary number of top-ranking oligos
## and consider them as binding sites, and the bottom-ranking oligos
## as background
N_TOP_SPOTS=2000
N_TOP_ROWS=4000
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
PEAKMODIFF_DIR=${RESULT_DIR}/peak-motifs${PEAKMO_OPT}
PEAKMODIFF_CMD=	${RSAT_CMD} peak-motifs  \
	-v ${V} \
	-title ${BOARD}_${DATA_TYPE}_${TF}_${DATASET}_train_vs_bg  \
	-i ${TOP_SEQ} \
	-ctrl ${BG_SEQ} \
	${PEAKMO_OPT} \
	-max_seq_len 1000 \
	-markov auto \
	-disco oligos,dyads \
	-nmotifs 5  \
	-minol 6 \
	-maxol 7  \
	-2str  \
	-origin center  \
	-motif_db Hocomoco_human tf ${MOTIFDB_DIR}/HOCOMOCO/HOCOMOCO_2017-10-17_Human.tf \
	-motif_db jaspar_core_redundant_vertebrates tf ${MOTIFDB_DIR}/JASPAR/Jaspar_2020/redundant/JASPAR2020_CORE_vertebrates_redundant_pfms.tf \
	-scan_markov 1 \
	-task purge,seqlen,composition,disco,merge_motifs,split_motifs,motifs_vs_motifs,timelog,synthesis,small_summary,motifs_vs_db,scan \
	-prefix peak-motifs \
	-noov \
	-img_format png  \
	-outdir ${PEAKMODIFF_DIR}
PEAKMODIFF_SCRIPT=${PEAKMODIFF_DIR}/peak-motif${PEAKMO_OPT}_${DIFF_SUFFIX}_cmd.sh
peakmo_diff: top_seq
	@echo
	@echo "Running peak-motifs in differential analysis mode"
	@echo
	@echo "Writing peak-motif script for differential analysis	${PEAKMODIFF_SCRIPT}"
	@mkdir -p ${PEAKMODIFF_DIR}
	@echo ${SBATCH_HEADER} > ${PEAKMODIFF_SCRIPT}
	@echo >> ${PEAKMODIFF_SCRIPT}
	@echo ${PEAKMODIFF_CMD} >> ${PEAKMODIFF_SCRIPT}
	@echo
	@echo "${CONVERT_MATRIX_CMD}" >> ${PEAKMODIFF_SCRIPT}
	@echo >> ${PEAKMODIFF_SCRIPT}
	@mkdir -p ${PEAKMO_CLUSTERS_DIR}
	@echo ${CLUSTER_CMD} >> ${PEAKMODIFF_SCRIPT}
	@echo >> ${PEAKMODIFF_SCRIPT}
	@mkdir -p ${QUALITY_DIR}
	@echo ${QUALITY_CMD} >> ${PEAKMODIFF_SCRIPT}
	@echo
	@echo "	PEAKMODIFF_SCRIPT	${PEAKMODIFF_SCRIPT}"
	@echo "Running peak-motifs"
	@${SBATCH} ${PEAKMODIFF_SCRIPT}
	@echo "	PEAKMODIFF_DIR	${PEAKMODIFF_DIR}"

peakmodiff_all_datasets:
	@${MAKE} iterate_datasets TASK=peakmo_diff
