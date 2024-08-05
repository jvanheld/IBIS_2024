################################################################
## IBIS challenge 2024
##
## Integration of the motifs discovered across the different data
## types

include makefiles/00_parameters.mk 
MAKEFILE=makefiles/05_integration.mk
TF=LEF1
V=2

targets: targets_00
	@echo
	@echo "Clustering motifs across data types"
	@echo "	all_tfs			run a task of each TF"
	@echo "	cluster_one_tf		cluster motifs discovered across all the data types for a given transcription factor"
	@echo "	cluster_all_tfs		run cluster_on_tf on each TF"
	@echo "	quality_one_tf		run matrix-quality on the matrix-clustering result for a given transcription factor"
	@echo "	quality_all_tfs         run quality_one_tf on each TF"	


param:: param_00
	@echo
	@echo "Clustering all motifs for a transcription factor"
#	@echo "	TFCLUST_INFILES		${TFCLUST_INFILES}"
#	@echo "	TFCLUST_CMD		${TFCLUST_CMD}"
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

DATA_TYPE=all-types
DATASET=all-sets

################################################################
## Iterate a task over each TF
ALL_TFS=`cat ${ALL_METADATA} | cut -f 1 | sort -u | xargs`
TF_TASK=cluster_one_tf
all_tfs:
	@echo
	@echo "Running task on all TFs: ${TF_TASK}"
	@for tf in ${ALL_TFS} ; do \
		${MAKE} ${TF_TASK} TF=$${tf} ; \
	done



TF=LEF1
TFCLUST_DIR=results/${BOARD}/train/cross-data-types/${TF}
TFCLUST_INFILES=`find results/${BOARD}/train/*/${TF} -name 'peak-motifs*_motifs_discovered.tf' | awk -F'/' '{print " -matrix "$$4":"$$5":"$$6" "$$0" transfac"}' | xargs`
TFCLUST_PREFIX=${TFCLUST_DIR}/matrix-clustering
TFCLUST_ROOT_MOTIFS=${TFCLUST_PREFIX}_cluster_root_motifs
TFCLUST_ALL_MOTIFS=${TFCLUST_PREFIX}_aligned_logos/All_concatenated_motifs
TFCLUST_SCRIPT=${TFCLUST_PREFIX}_cmd.sh
#TFCLUST_CMD=find results/${BOARD}/train/*/${TF} -name 'peak-motifs*_motifs_discovered.tf' | awk -F'/' '{print " -matrix "$$4":"$$5":"$$6" "$$0" transfac"}' | xargs ${SCHEDULER} ${RSAT_CMD} matrix-clustering -v ${V} -hclust_method average -calc sum -title ${TF} -metric_build_tree Ncor -lth w 5 -lth cor 0.6 -lth Ncor 0.4 -quick -label_in_tree name -return json,heatmap  -o ${TFCLUST_PREFIX}

## Define the matrices to use as input for matrix-clustering and matrix-quality
MATRICES=${TFCLUST_ROOT_MOTIFS}


################################################################
## Run matrix-quality on all the matrices discovered in all the
## datasets for a given transcription factor.
## Note: no need to split input motifs in separate files, matrix-quality parses all
## csplit ${TFCLUST_ROOT_MOTIFS}.tf /^AC/ -z -f root -b %03d.tf {*}
SLURM_OUT=./slurm_out/TFQUALITY_${BOARD}_cross-data-types-bench_${TF}_slurm-job_%j.out

#make -f makefiles/00_parameters.mk matrix_quality DATA_TYPE=CHS TF=GABPA DATASET=THC_0866 MATRICES=results/${BOARD}/train/cross-data-types/GABPA/matrix-clustering_cluster_root_motifs FASTA_SEQ=data/${BOARD}/train/CHS/GABPA/THC_0866.fasta TEST_SEQ=data/${BOARD}/test/CHS_participants.fasta MATRIXQ_DIR=results/${BOARD}/train/cross-data-types/GABPA/matrix-clustering_cluster_root_motifs


MATRICES=${TFCLUST_ROOT_MOTIFS}
MATRIXQ_DIR=${MATRICES}_matrix-quality
MATRIXQ_SCRIPT=${MATRIXQ_PREFIX}cmd.sh
MATRIXQ_SEQ_OPT=`awk -F'\t' '$$1=="${TF}" {print "-seq "$$2" data/"$$5"/train/"$$4"/"$$1"/"$$2".fasta"}' metadata/leaderboard/TF_DATASET_all-types.tsv  | xargs`
MATRIXQ_SEQ_PLOT_OPT=`awk -F'\t' '$$1=="${TF}" {print "-plot "$$2" nwd"}' metadata/leaderboard/TF_DATASET_all-types.tsv  | xargs`
MATRIXQ_SEQ_PERM_OPT=`awk -F'\t' '$$1=="${TF}" {print "-perm "$$2" ${MATRIXQ_PERM}"}' metadata/leaderboard/TF_DATASET_all-types.tsv  | xargs`
quality_one_tf:
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
	@${MAKE} all_tfs TF_TASK=quality_one_tf




################################################################
## Run matrix-clustering on all the matrices discovered in all the
## datasets for a given transcription factor.
TFCLUST_CMD=${SCHEDULER} ${RSAT_CMD} matrix-clustering -v ${V} ${TFCLUST_INFILES} -hclust_method average -calc sum -title ${TF} -metric_build_tree Ncor -lth w 5 -lth cor 0.6 -lth Ncor 0.4 -quick -label_in_tree name -return json,heatmap  -o ${TFCLUST_PREFIX}
SLURM_OUT=./slurm_out/TFCLUST_${BOARD}_cross-data-types_${TF}_slurm-job_%j.out
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
	@${MAKE} all_tfs TF_TASK=cluster_one_tf



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



