################################################################
## IBIS challenge 2024
## Integration of the motifs discovered across the different data types

include makefiles/00_parameters.mk 
MAKEFILE=makefiles/05_integration.mk
TF=LEF1
V=2

targets: targets_00
	@echo
	@echo "Clustering motifs across data types"
	@echo "	cluster_one_tf		cluster motifs discovered across all the data types for a given transcription factor"
	@echo "	cluster_all_tfs		cluster motifs for each TF"
	@echo "	all_tfs			run a task of each TF"

param:: param_00
	@echo
	@echo "Clustering all motifs for a transcription factor"
#	@echo "	TFCLUST_INFILES		${TFCLUST_INFILES}"
#	@echo "	TFCLUST_CMD		${TFCLUST_CMD}"
	@echo "	ALL_TFS			${ALL_TFS}"
	@echo "	DATA_TYPE		${DATA_TYPE}"
	@echo "	TF			${TF}"
	@echo "	TF_TASK			${TF_TASK}"
	@echo "	TFCLUST_DIR		${TFCLUST_DIR}"
	@echo "	TFCLUST_PREFIX		${TFCLUST_PREFIX}"
	@echo "	TFCLUST_SCRIPT		${TFCLUST_SCRIPT}"
	@echo "	TFCLUST_ALL_MOTIFS	${TFCLUST_ALL_MOTIFS}"
	@echo "	TFCLUST_ROOT_MOTIFS	${TFCLUST_ROOT_MOTIFS}"
	@echo

DATA_TYPE=all-datatypes
DATASET=all-datasets
TF=LEF1
TFCLUST_DIR=results/${BOARD}/train/cross-data-types/${TF}
TFCLUST_INFILES=`find results/leaderboard/train/*/${TF} -name 'peak-motifs*_motifs_discovered.tf' | awk -F'/' '{print " -matrix "$$4":"$$5":"$$6" "$$0" transfac"}' | xargs`
TFCLUST_PREFIX=${TFCLUST_DIR}/matrix-clustering
TFCLUST_ROOT_MOTIFS=${TFCLUST_PREFIX}_cluster_root_motifs
TFCLUST_ALL_MOTIFS=${TFCLUST_PREFIX}_aligned_logos/All_concatenated_motifs
TFCLUST_SCRIPT=${TFCLUST_PREFIX}_cmd.sh
#TFCLUST_CMD=find results/leaderboard/train/*/${TF} -name 'peak-motifs*_motifs_discovered.tf' | awk -F'/' '{print " -matrix "$$4":"$$5":"$$6" "$$0" transfac"}' | xargs ${SCHEDULER} ${RSAT_CMD} matrix-clustering -v ${V} -hclust_method average -calc sum -title ${TF} -metric_build_tree Ncor -lth w 5 -lth cor 0.6 -lth Ncor 0.4 -quick -label_in_tree name -return json,heatmap  -o ${TFCLUST_PREFIX}

TFCLUST_CMD=${SCHEDULER} ${RSAT_CMD} matrix-clustering -v ${V} ${TFCLUST_INFILES} -hclust_method average -calc sum -title ${TF} -metric_build_tree Ncor -lth w 5 -lth cor 0.6 -lth Ncor 0.4 -quick -label_in_tree name -return json,heatmap  -o ${TFCLUST_PREFIX}
SLURM_OUT=./slurm_out/TFCLUST_${BOARD}_cross-data-types_${TF}_slurm-job_%j.out
cluster_one_tf:
	@echo
	@echo "Clustering motifs across all data types for TF ${TF}"
	@echo
	@echo "Writing matrix-clustering script	${TFCLUST_SCRIPT}"
	@mkdir -p ${TFCLUST_DIR}
	@echo ${SBATCH_HEADER} > ${TFCLUST_SCRIPT}
	@echo >> ${TFCLUST_SCRIPT}
	@echo ${TFCLUST_CMD} >> ${TFCLUST_SCRIPT}
	@echo
	@echo ${MAKE} ${TFCLUST_ROOT_MOTIFS}_freq.tf ${TFCLUST_ROOT_MOTIFS}_freq.cb ${TFCLUST_ROOT_MOTIFS}_freq.txt >>  ${TFCLUST_SCRIPT}
	@echo ${MAKE} ${TFCLUST_ALL_MOTIFS}_freq.tf ${TFCLUST_ALL_MOTIFS}_freq.cb ${TFCLUST_ALL_MOTIFS}_freq.txt >>  ${TFCLUST_SCRIPT}
	@echo
	@${SBATCH} ${TFCLUST_SCRIPT}
	@echo "	TFCLUST_DIR	${TFCLUST_DIR}"

tfclust_to_ibis:
	@echo
	@echo "Converting cluster matrices into format suitable for IBIS challenge submission"
	@${MAKE} ${TFCLUST_ROOT_MOTIFS}_freq.tf ${TFCLUST_ROOT_MOTIFS}_freq.cb ${TFCLUST_ROOT_MOTIFS}_freq.txt
	@echo "	TFCLUST_ROOT_MOTIFS	${TFCLUST_ROOT_MOTIFS}"
	@echo "	${TFCLUST_ROOT_MOTIFS}.tf"
	@echo "	${TFCLUST_ROOT_MOTIFS}_freq.tf"
	@echo "	${TFCLUST_ROOT_MOTIFS}_freq.cb"
	@echo "	${TFCLUST_ROOT_MOTIFS}_freq.txt"
	@${MAKE} ${TFCLUST_ALL_MOTIFS}_freq.tf ${TFCLUST_ALL_MOTIFS}_freq.cb ${TFCLUST_ALL_MOTIFS}_freq.txt
	@echo "	TFCLUST_ALL_MOTIFS	${TFCLUST_ALL_MOTIFS}"
	@echo "	${TFCLUST_ALL_MOTIFS}.tf"
	@echo "	${TFCLUST_ALL_MOTIFS}_freq.tf"
	@echo "	${TFCLUST_ALL_MOTIFS}_freq.cb"
	@echo "	${TFCLUST_ALL_MOTIFS}_freq.txt"


ALL_TFS=`cat metadata/leaderboard/TF_DATASET_*.tsv | cut -f 1 | sort -u | xargs`
TF_TASK=cluster_one_tf
cluster_all_tfs:
	@echo "Clustering motifs per TF across all data types"
	@${MAKE} all_tfs TF_TASK=cluster_one_tf

all_tfs:
	@echo
	@echo "Running task on all TFs: ${TF_TASK}"
	@for tf in ${ALL_TFS} ; do \
		${MAKE} ${TF_TASK} TF=$${tf} ; \
	done


