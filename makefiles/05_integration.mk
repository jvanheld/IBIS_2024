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
	@echo "	cluster_one_tf	cluster motifs discovered across all the data types for a given transcription factor"
	@echo "	cluster_all_tfs	cluster motifs for each TF"

param:: param_00
	@echo
	@echo "	TFCLUST_DIR	${TFCLUST_DIR}"
	@echo "	TFCLUST_PREFIX	${TFCLUST_PREFIX}"
	@echo "	TFCLUST_SCRIPT	${TFCLUST_SCRIPT}"
	@echo "	TFCLUST_INFILES	${TFCLUST_INFILES}"
	@echo "	TFCLUST_CMD	${TFCLUST_CMD}"
	@echo "	ALL_TFS		${ALL_TFS}"
	@echo "	TF		${TF}"
	@echo

TF=LEF1
TFCLUST_DIR=results/${BOARD}/train/cross-data-types/${TF}
TFCLUST_INFILES=`find results/leaderboard/train/*/${TF} -name 'peak-motifs*_motifs_discovered.tf' | awk -F'/' '{print " -matrix "$$4":"$$5":"$$6" "$$0" transfac"}' | xargs`
TFCLUST_PREFIX=${TFCLUST_DIR}/matrix-clustering
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
	@${SBATCH} ${TFCLUST_SCRIPT}
	@echo "	TFCLUST_DIR	${TFCLUST_DIR}"

ALL_TFS=`cat metadata/leaderboard/TF_DATASET_*.tsv | cut -f 1 | sort -u | xargs`
cluster_all_tfs:
	@echo
	@echo "Clustering motifs per TF across all data types"
	@for tf in ${ALL_TFS} ; do \
		${MAKE} cluster_one_tf TF=$${tf} ; \
	done
