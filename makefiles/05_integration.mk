################################################################
## IBIS challenge 2024
##
## Integration of the motifs discovered across the different data
## types

include makefiles/00_parameters.mk 
MAKEFILE=makefiles/05_integration.mk


################################################################
## Specific parameters for this script
V=2
DATA_TYPE=all-types
DATASET=all-sets

ALL_TFS=`cat ${ALL_METADATA} | cut -f 1 | sort -u | xargs`
TF=LEF1

## Matrix clustering parameters
TFCLUST_DIR=results/${BOARD}/train/cross-data-types/${TF}
TFCLUST_INFILES=`find results/${BOARD}/train/*/${TF} -name 'peak-motifs*_motifs_discovered.tf' | awk -F'/' '{print " -matrix "$$4":"$$5":"$$6" "$$0" transfac"}' | xargs`
TFCLUST_PREFIX=${TFCLUST_DIR}/matrix-clustering
TFCLUST_ROOT_MOTIFS=${TFCLUST_PREFIX}_cluster_root_motifs
TFCLUST_ALL_MOTIFS=${TFCLUST_PREFIX}_aligned_logos/All_concatenated_motifs
TFCLUST_SCRIPT=${TFCLUST_PREFIX}_cmd.sh
TFCLUST_SLURM_OUT=./slurm_out/TFCLUST_${BOARD}_cross-data-types_${TF}_slurm-job_%j.out

## Matrix quality parameters
MATRIXQ_SLURM_OUT=./slurm_out/TFQUALITY_${BOARD}_cross-data-types-bench_${TF}_slurm-job_%j.out
MATRIXQ_DIR=${MATRICES}_matrix-quality
MATRIXQ_SCRIPT=${MATRIXQ_PREFIX}_cmd.sh
MATRIXQ_SEQ_OPT=`awk -F'\t' '$$1=="${TF}" {print "-seq "$$4"_"$$2" data/"$$5"/train/"$$4"/"$$1"/"$$2".fasta"}' metadata/leaderboard/TF_DATASET_all-types.tsv  | xargs`
MATRIXQ_SEQ_PLOT_OPT=`awk -F'\t' '$$1=="${TF}" {print "-plot "$$4"_"$$2" nwd"}' metadata/leaderboard/TF_DATASET_all-types.tsv  | xargs`
MATRIXQ_SEQ_PERM_OPT=`awk -F'\t' '$$1=="${TF}" {print "-perm "$$4"_"$$2" ${MATRIXQ_PERM}"}' metadata/leaderboard/TF_DATASET_all-types.tsv  | xargs`

################################################################
## Define the matrices to use as input for matrix-clustering and
## matrix-quality. We initially restricted the analysis to the root
## motifs but these motifs are too degenerated -> we apply it to all
## the nodes of the matrix clustering result tree.
# MATRICES=${TFCLUST_ROOT_MOTIFS}
#MATRICES=${TFCLUST_ALL_MOTIFS}
MATRICES=${TFCLUST_ALL_MOTIFS}_trimmed

################################################################
## Print targets
targets: targets_00
	@echo
	@echo "Clustering motifs across data types"
	@echo "	all_tfs			run a task of each TF"
	@echo "	cluster_one_tf		cluster motifs discovered across all the data types for a given transcription factor"
	@echo "	cluster_all_tfs		run cluster_on_tf on each TF"
	@echo "	quality_one_tf		run matrix-quality on the matrix-clustering result for a given transcription factor"
	@echo "	quality_all_tfs         run quality_one_tf on each TF"	

################################################################
## Print parameters
param:: param_00
	@echo
	@echo "Clustering all motifs for a transcription factor"
	@echo "	ALL_METADATA		${ALL_METADATA}"
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
	@echo "Quality of the clustered motifs"
	@echo "	MATRIXQ_CMD		${MATRIXQ_CMD}"
	@echo "	MATRICES		${MATRICES}"
	@echo "	MATRIXQ_SEQ_OPT		${MATRIXQ_SEQ_OPT}"
	@echo "	MATRIXQ_SEQ_PLOT_OPT	${MATRIXQ_SEQ_PLOT_OPT}"
	@echo "	MATRIXQ_SEQ_PERM	${MATRIXQ_SEQ_PERM}"
	@echo "	MATRIXQ_SEQ_PERM_OPT	${MATRIXQ_SEQ_PERM_OPT}"
	@echo "	MATRIXQ_DIR		${MATRIXQ_DIR}"
	@echo "	MATRIXQ_SCRIPT		${MATRIXQ_SCRIPT}"
	@echo

################################################################
## Iterate a task over each TF
TF_TASK=cluster_one_tf
all_tfs:
	@echo
	@echo "Running task on all TFs: ${TF_TASK}"
	@for tf in ${ALL_TFS} ; do \
		${MAKE} ${TF_TASK} TF=$${tf} ; \
	done


################################################################
## Run matrix-clustering on all the matrices discovered in all the
## datasets for a given transcription factor.
TFCLUST_CMD=${SCHEDULER} ${RSAT_CMD} matrix-clustering -v ${V} ${TFCLUST_INFILES} -hclust_method average -calc sum -title ${TF} -metric_build_tree Ncor -lth w 5 -lth cor 0.6 -lth Ncor 0.4 -quick -label_in_tree name -return json,heatmap  -o ${TFCLUST_PREFIX}
cluster_one_tf:
	@echo
	@echo "Clustering motifs across all data types for TF ${TF}"
	@echo
	@echo "Writing matrix-clustering script"
	@echo "	TFCLUST_SCRIPT	${TFCLUST_SCRIPT}"
	@mkdir -p ${TFCLUST_DIR}
	@echo ${RUNNER_HEADER} > ${TFCLUST_SCRIPT}
	@echo >> ${TFCLUST_SCRIPT}
	@echo ${TFCLUST_CMD} >> ${TFCLUST_SCRIPT}
	@echo
	@echo ${MAKE} ${TFCLUST_ROOT_MOTIFS}_freq.tf ${TFCLUST_ROOT_MOTIFS}_freq.cb ${TFCLUST_ROOT_MOTIFS}_freq.txt >>  ${TFCLUST_SCRIPT}
	@echo ${MAKE} ${TFCLUST_ALL_MOTIFS}_freq.tf ${TFCLUST_ALL_MOTIFS}_freq.cb ${TFCLUST_ALL_MOTIFS}_freq.txt >>  ${TFCLUST_SCRIPT}
	@echo
	@${RUNNER} ${TFCLUST_SCRIPT}
	@echo "	TFCLUST_DIR	${TFCLUST_DIR}"

################################################################
## Run matrix-clustering for each TF, with all the matrices discovered
## in all the datasets
cluster_all_tfs: all_metadata
	@echo "Clustering motifs per TF across all data types"
	@${MAKE} all_tfs TF_TASK=cluster_one_tf SLURM_OUT=${TFCLUST_SLURM_OUT}

################################################################
## Convert cluster matrices into format suitable for IBIS challenge submission
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


################################################################
## Run matrix-quality on all the matrices discovered in all the
## datasets for a given transcription factor.
## Note: no need to split input motifs in separate files, matrix-quality parses all
## csplit ${TFCLUST_ROOT_MOTIFS}.tf /^AC/ -z -f root -b %03d.tf {*}
quality_one_tf: ${MATRICES}.tf ${MATRICES}_info.tab
	@echo
	@echo "Running matrix-quality on matrix-clustering result for all the motifs of TF ${TF}"
	@echo "	MATRICES		${MATRICES}"
	@echo "	MATRIXQ_SCRIPT	${MATRIXQ_SCRIPT}"
	@mkdir -p ${MATRIXQ_DIR}
	@echo ${RUNNER_HEADER} > ${MATRIXQ_SCRIPT}
	@echo >> ${MATRIXQ_SCRIPT}
	@echo ${MATRIXQ_CMD} >> ${MATRIXQ_SCRIPT}
	@${RUNNER} ${MATRIXQ_SCRIPT}
	@echo "	MATRIXQ_DIR	${MATRIXQ_DIR}"

################################################################
## Run matrix-clustering for each TF, with all the matrices discovered
## in all the datasets
quality_all_tfs: all_metadata
	@echo
	@echo "Running matrix-quality on the matrix-clustering results for each TF"
	@${MAKE} all_tfs TF_TASK=quality_one_tf SLURM_OUT=${MATRIXQ_SLURM_OUT}

