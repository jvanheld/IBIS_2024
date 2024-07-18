###############################################################
## Motif discovery for the IBIS challenge 2024
##
## Participants: Jacques van Helden and Bruno Contreiras Moreira

include makefiles/00_parameters.mk
MAKEFILE=makefiles/02_peak-motifs.mk

targets: targets_00
	@echo "Peak-motifs targets (${MAKEFILE})"
	@echo "	peakmo			discover motifs in peak sequences"
	@echo "	cluster_matrices	run matrix-clustering on the motifs discovered with peak-motifs"
	@echo "	peakmo_all_datasets	run peak-motifs in all the peak sets"
	@echo

param: param_00
	@echo
	@echo "Peak-motif parameters"
	@echo "	MOTIFDB_DIR		${MOTIFDB_DIR}"
	@echo "	JASPAR_MOTIFS		${JASPAR_MOTIFS}"
	@echo "	HOCOMOCO_MOTIFS		${HOCOMOCO_MOTIFS}"
	@echo
	@echo "peak-motifs options"
	@echo "	PEAKMO_OPT		${PEAKMO_OPT}"
	@echo "	PEAKMO_DIR		${PEAKMO_DIR}"
	@echo "	PEAKMO_MATRICES		${PEAKMO_MATRICES}"
	@echo "	PEAKMO_TASKS		${PEAKMO_TASKS}"
	@echo "	PEAKMO_CMD		${PEAKMO_CMD}"
	@echo "	PEAKMO_SCRIPT		${PEAKMO_SCRIPT}"
	@echo
	@echo "matrix-clustering options"
	@echo "	PEAKMO_CLUSTERS_DIR	${PEAKMO_CLUSTERS_DIR}"
	@echo "	PEAKMO_CLUSTERS		${PEAKMO_CLUSTERS}"
	@echo "	CLUSTER_CMD		${CLUSTER_CMD}"
	@echo
	@echo "convert-matrix"
	@echo "	CONVERT_CMD		${CONVERT_CMD}"
	@echo
	@echo "matrix-quality"
	@echo "	QUALITY_DIR		${QUALITY_DIR}"
	@echo "	QUALITY_PREFIX		${QUALITY_PREFIX}"
	@echo "	QUALITY_CMD		${QUALITY_CMD}"
	@echo

PEAKMO_OPT=-nopurge
PEAKMO_DIR=${RESULT_DIR}/peak-motifs${PEAKMO_OPT}
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
JASPAR_MOTIFS=${MOTIFDB_DIR}/JASPAR/Jaspar_2020/nonredundant/JASPAR2020_CORE_vertebrates_non-redundant_pfms.tf
HOCOMOCO_MOTIFS=${MOTIFDB_DIR}/HOCOMOCO/HOCOMOCO_2017-10-17_Human.tf

PEAKMO_MATRICES=${PEAKMO_DIR}/results/discovered_motifs/peak-motifs${PEAKMO_OPT}_motifs_discovered
PEAKMO_CLUSTERS_DIR=${PEAKMO_DIR}/clustered_motifs
PEAKMO_CLUSTERS=${PEAKMO_CLUSTERS_DIR}/matrix-clusters

CONVERT_CMD=rsat convert-matrix -from transfac -to transfac -i ${PEAKMO_MATRICES}.tf -rescale 1 -decimals 4 -o ${PEAKMO_MATRICES}_freq.tf ; rsat convert-matrix -from transfac -to cluster-buster -i ${PEAKMO_MATRICES}_freq.tf -o ${PEAKMO_MATRICES}_freq.cb ; cat ${PEAKMO_MATRICES}_freq.cb | perl -pe 's/^>/>${TF} ${DATASET}_/; s/oligos_/oli_/; s/positions_/pos_/; s/\.Rep-MICHELLE/M/; s/\.Rep-DIANA/D/; s/ \/name.*//;' > ${PEAKMO_MATRICES}_freq.txt


################################################################
## Run peak-motifs to discover motifs in peak sequences
PEAKMO_TASKS=purge,seqlen,composition,disco,merge_motifs,split_motifs,motifs_vs_motifs,motifs_vs_db,scan,timelog,synthesis,small_summary
PEAKMO_CMD=${SCHEDULER} rsat peak-motifs \
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
PEAKMO_SCRIPT=${PEAKMO_DIR}/peak-motif_cmd.sh
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
	@echo "${CONVERT_CMD}" >> ${PEAKMO_SCRIPT}
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


################################################################
## Convert matrices from Transfac to cluster-buster format
# convert_matrices:
# 	@echo "Converting matrices from transfac to cluster-buster format"
# 	@echo "	PEAKMO_MATRICES	${PEAKMO_MATRICES}"
# 	@${CONVERT_CMD}
# 	@echo "	transfac counts	${PEAKMO_MATRICES}.tf"
# 	@echo "	transfac freq	${PEAKMO_MATRICES}_freq.tf"
# 	@echo "	cb format	${PEAKMO_MATRICES}_freq.txt"

################################################################
## matrix-clusering command
CLUSTER_CMD=rsat matrix-clustering -v ${V} \
	-max_matrices 50 \
	-matrix ${TF}_${DATASET} ${PEAKMO_MATRICES}.tf transfac \
	-hclust_method average -calc sum \
	-title '${TF}_${DATASET}' \
	-metric_build_tree 'Ncor' \
	-lth w 5 -lth cor 0.6 -lth Ncor 0.4 \
	-quick \
	-label_in_tree name \
	-return json,heatmap \
	-o ${PEAKMO_CLUSTERS} \
	2> ${PEAKMO_CLUSTERS}_err.txt

################################################################
## Cluster matrices discovered by peak-motifs
cluster_matrices:
	@mkdir -p ${PEAKMO_CLUSTERS_DIR}
#	@echo "	CLUSTER_CMD	${CLUSTER_CMD}"
	${CLUSTER_CMD}
	@echo "	PEAKMO_CLUSTERS_DIR	${PEAKMO_CLUSTERS_DIR}"
	@echo "	PEAKMO_CLUSTERS		${PEAKMO_CLUSTERS}"

################################################################
## Run matrix-quality on discovered motifs in order to measure the
## peak enrichment
BG_OL=2
QUALITY_DIR=${PEAKMO_DIR}/matrix-quality
QUALITY_PREFIX=${QUALITY_DIR}/matrix-quality
QUALITY_CMD=matrix-quality  -v ${V} \
	-html_title 'IBIS24_${BOARD}_${DATA_TYPE}_${TF}_${DATASET}'  \
	-ms ${PEAKMO_MATRICES}.tf \
	-matrix_format transfac \
	-pseudo 1 \
	-seq ${TF}_${DATASET} ${FASTA_SEQ} \
	-seq_format fasta \
	-plot ${TF}_${DATASET} nwd \
	-seq 'test_seq' ${TEST_SEQ} \
	-plot 'test_seq' nwd \
	-perm ${TF}_${DATASET} 1 \
	-perm 'test_seq' 1 \
	-bgfile ${BG_FILE} \
	-bg_format oligo-analysis \
	-archive \
	-o ${QUALITY_PREFIX}
#	-bg_pseudo 0.01 \

matrix_quality:
	@mkdir -p ${QUALITY_DIR}
	@echo "	QUALITY_DIR	${QUALITY_DIR}"
	@echo "	QUALITY_CMD	${QUALITY_CMD}"
	${QUALITY_CMD}
	@echo "	QUALITY_PREFIX	${QUALITY_PREFIX}"


# all: param sequences peakmo

TASK=peakmo
peakmo_all_datasets:
	@${MAKE} iterate_datasets
