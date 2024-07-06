###############################################################
## Motif discovery for the IBIS challenge 2024
##
## Participants: Jacques van Helden and Bruno Contreiras Moreira

include makefiles/00_parameters.mk
MAKEFILE=makefiles/02_peak-motifs.mk

targets:
	@echo
	@echo "Targets"
	@echo "	targets			list targets"
	@echo "	param			list parameters"
	@echo "	datatable		build a table with the names of peaksets associated to each transcription factor"
	@echo "	peakseq			retrieve peak sequences from UCSC"
	@echo "	peakmo			discover motifs in peak sequences"
	@echo "	cluster_matrices	run matrix-clustering on the motifs discovered with peak-motifs"
	@echo "	peakmo_all_peaksets	run peak-motifs in all the peak sets"
	@echo

param: peak_param
	@echo
	@echo "Peak-motif parameters"
	@echo "	MOTIFDB_DIR		${MOTIFDB_DIR}"
	@echo "	JASPAR_MOTIFS		${JASPAR_MOTIFS}"
	@echo "	HOCOMOCO_MOTIFS		${HOCOMOCO_MOTIFS}"
	@echo "	PEAKMO_OPT		${PEAKMO_OPT}"
	@echo "	PEAKMO_DIR		${PEAKMO_DIR}"
	@echo "	PEAKMO_MATRICES		${PEAKMO_MATRICES}"
	@echo "	PEAKMO_CLUSTERS_DIR	${PEAKMO_CLUSTERS_DIR}"
	@echo "	PEAKMO_CLUSTERS		${PEAKMO_CLUSTERS}"
	@echo "	PEAKMO_TASKS		${PEAKMO_TASKS}"
	@echo "	PEAKMO_CMD		${PEAKMO_CMD}"
	@echo "	PEAKMO_SCRIPT		${PEAKMO_SCRIPT}"
	@echo
	@echo "	CONVERT_CMD		${CONVERT_CMD}"
	@echo

PEAKMO_OPT=
PEAKMO_DIR=${RESULT_DIR}/peak-motifs${PEAKMO_OPT}
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
JASPAR_MOTIFS=${MOTIFDB_DIR}/JASPAR/Jaspar_2020/nonredundant/JASPAR2020_CORE_vertebrates_non-redundant_pfms.tf
HOCOMOCO_MOTIFS=${MOTIFDB_DIR}/HOCOMOCO/HOCOMOCO_2017-10-17_Human.tf

PEAKMO_MATRICES=${PEAKMO_DIR}/results/discovered_motifs/peak-motifs_motifs_discovered

PEAKMO_CLUSTERS_DIR=${PEAKMO_DIR}/results/clustered_motifs
PEAKMO_CLUSTERS=${PEAKMO_CLUSTERS_DIR}/matrix-clusters

CONVERT_CMD=rsat convert-matrix -from transfac -to transfac -i ${PEAKMO_MATRICES}.tf -o ${PEAKMO_MATRICES}_freq.tf ; rsat convert-matrix -from transfac -to cluster-buster -i ${PEAKMO_MATRICES}_freq.tf -o ${PEAKMO_MATRICES}_freq.cb ; cat ${PEAKMO_MATRICES}_freq.cb | perl -pe 's/^>/>${TF} ${PEAKSET}_/; s/oligos_/oli_/; s/positions_/pos_/' > ${PEAKMO_MATRICES}_freq.txt

################################################################
## Build a table with the peak sets associated to each transcription
## factor.
datatable:
	@echo
	@echo "Building peakset table for ${DATA_TYPE} ${BOARD}"
	wc -l data/${BOARD}/train/${DATA_TYPE}/*/*.peaks  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.peaks||' \
		| awk -F'\t' '$$6 != "" {print $$7"\t"$$8"\t"$$2}'  > ${PEAKSET_TABLE}
	@echo "	PEAKSET_TABLE	${PEAKSET_TABLE}"
	@echo

################################################################
## Run fetch-sequences to retrieve fasta sequences from the peak
## coordinates (bed) from the UCSC genome browser
FETCH_CMD=fetch-sequences -v 1 \
	-genome hg38 \
	-header_format galaxy \
	-i ${PEAK_COORD} -o ${PEAK_SEQ}
peakseq:
	@echo
	@echo "Retrieving peak sequences from UCSC"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	${SCHEDULER} ${FETCH_CMD} ${POST_SCHEDULER}
	@echo
	@echo "	PEAK_SEQ	${PEAK_SEQ}"

################################################################
## Run peak-motifs to discover motifs in peak sequences
PEAKMO_TASKS=purge,seqlen,composition,disco,merge_motifs,split_motifs,motifs_vs_motifs,motifs_vs_db,timelog,archive,synthesis,small_summary
PEAKMO_CMD=${SCHEDULER} rsat peak-motifs -v ${V} -title 'IBIS24_${BOARD}_${TF}_${PEAKSET}' \
	-i ${PEAK_SEQ} \
	-2str \
	-noov \
	-origin center \
	-max_seq_len 1000 \
	-minol 6 -maxol 7 \
	-scan_markov 1 \
	-disco oligos,positions \
	-markov auto \
	-nmotifs 5 \
	-no_merge_lengths \
	-prefix peak-motifs \
	-img_format png \
	-motif_db Hocomoco_human tf ${HOCOMOCO_MOTIFS} \
	-motif_db jaspar_core_nonredundant_vertebrates tf ${JASPAR_MOTIFS} \
	-task ${PEAKMO_TASKS} \
	-outdir ${PEAKMO_DIR} ${PEAKMO_OPT}
PEAKMO_SCRIPT=${PEAKMO_DIR}/peak-motif_cmd.sh
peakmo: 
	@echo
	@echo "Writing peak-motif script"
	@mkdir -p ${PEAKMO_DIR}
	@echo ${SBATCH_HEADER} > ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@echo ${FETCH_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@echo ${PEAKMO_CMD} >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@echo "${CONVERT_CMD}" >> ${PEAKMO_SCRIPT}
	@echo >> ${PEAKMO_SCRIPT}
	@mkdir -p ${PEAKMO_CLUSTERS_DIR}
	@echo ${CLUSTER_CMD} >> ${PEAKMO_SCRIPT}
	@echo "	PEAKMO_SCRIPT	${PEAKMO_SCRIPT}"
	@echo "Running peak-motifs"
	@${SBATCH} ${PEAKMO_SCRIPT}
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"
#	${SCHEDULER} ${PEAKMO_CMD} ${POST_SCHEDULER}

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
	-matrix ${TF}_${PEAKSET} ${PEAKMO_MATRICES}.tf transfac \
	-hclust_method average -calc sum \
	-title '${TF}_${PEAKSET}' \
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

all: param peakseq peakmo

TASK=peakmo
peakmo_all_peaksets:
	@${MAKE} iterate_peaksets
