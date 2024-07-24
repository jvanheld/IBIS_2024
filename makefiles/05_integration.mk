################################################################
## IBIS challenge 2024
## Integration of the motifs discovered across the different data types

targets: targets_00
	@echo
	@echo "Clustering motifs across data types"
	@echo "	cluster_one_tf	cluster motifs discovered across all the data types for a given transcription factor"

param:: param_00
	@echo
	@echo "	CLUSTER_TF_CMD	${CLUSTER_TF_CMD}"

include makefiles/00_parameters.mk 
MAKEFILE=makefile/05_integration.mk
TF=LEF1
V=2
CLUSTER_TF_CMD=find results/leaderboard/train/*/${TF} -name 'peak-motifs*_motifs_discovered.tf' \
	| awk -F'/' '{print " -matrix "$$4":"$$5":"$$6" "$$0" transfac"}' \
	| xargs ${RSAT_CMD} matrix-clustering  -v ${V} \
	-hclust_method average \
	-calc sum \
	-title ${TF} \
	-metric_build_tree Ncor \
	-lth w 5 \
	-lth cor 0.6 \
	-lth Ncor 0.4 \
	-quick \
	-label_in_tree name \
	-return json,heatmap  \
	-o results/leaderboard/train/cross-data-types/${TF}/matrix-clustering
cluster_one_tf:
	${CLUSTER_TF_CMD}
