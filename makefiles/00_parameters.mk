################################################################
## Parameters for the analysis of ChIP-seq peaks

MAKE=make -s -f ${MAKEFILE}
MAKEFILE=makefiles/00_parameters.mk

################################################################
## Path or command to run RSAT command, depending on the local
## configuration. Byb default, it is set to "rsat" (the main command,
## which runs all the rsat tools as sub-commands), but can be adapted
## to run rsat from a specific path, or from a container (e.g. docker
## or apptainer)

include makefiles/running_config.mk

################################################################
## Job scheduler parameters
NOW=`date +%Y-%m-%d_%H%M`
ERR_DIR=sbatch_errors
ERR_FILE=${ERR_DIR}/sbatch_error_${NOW}.txt

################################################################
## Table containing the metadata for each dataset
ALL_METADATA=metadata/${BOARD}/TF_DATASET_all-types.tsv

################################################################
## Load data-type specific configuration
EXPERIMENTS=CHS GHTS HTS SMS PBM

## Detault dataset for testing
DATASET=THC_0866

## Extract parameters from metadata for the selected dataset
#EXPERIMENT=`awk '$$2=="${DATASET}" {print $$4}' ${ALL_METADATA}`
EXPERIMENT=CHS
include makefiles/config_${EXPERIMENT}.mk

V=2

DISCIPLINE=WET
BOARD=leaderboard
METADATA=metadata/${BOARD}/TF_DATASET_${EXPERIMENT}.tsv
TEST_SEQ=data/${BOARD}/test/${EXPERIMENT}_participants.fasta
TF=`awk '$$2=="${DATASET}" {print $$1}' ${ALL_METADATA}`

#DATASET=`head -n 1 ${METADATA} | cut -f 2`
DATASET_DIR=data/${BOARD}/train/${EXPERIMENT}/${TF}
DATASET_PATH=${DATASET_DIR}/${DATASET}
PEAK_COORD=${DATASET_PATH}.peaks
FASTA_SEQ=${DATASET_PATH}.fasta
TRAIN_SEQ=`awk '$$2=="${DATASET}" {print $$7}' ${ALL_METADATA}`
TSV_SEQ=${DATASET_PATH}.tsv
FASTQ_SEQ=${DATASET_PATH}.fastq.gz
RESULT_DIR=results/${BOARD}/train/${EXPERIMENT}/${TF}/${DATASET}

## Background models estimated based on the test sequences
BG_DIR=bg_models/${BOARD}/${EXPERIMENT}
BG_OL=2
BG_FILE=${BG_DIR}/${EXPERIMENT}_${BG_OL}nt-noov-2str.tsv

## Iteration parameters
TASK=oligo_tables
DATASETS=`grep -v '^\#' ${METADATA} | cut -f 2 | sort -u | xargs`
TFS=`grep -v '^\#' ${METADATA} | cut -f 1 | sort -u | xargs`

param_00:
	@echo
	@echo
	@echo "Regulatory Sequence Analysis Tools"
	@echo "	RSAT_CMD		${RSAT_CMD}"
	@echo "	Motif databases"
	@echo "	  MOTIFDB_DIR		${MOTIFDB_DIR}"
	@echo "	  JASPAR_MOTIFS		${JASPAR_MOTIFS}"
	@echo "	  HOCOMOCO_MOTIFS	${HOCOMOCO_MOTIFS}"
	@echo
	@echo "Task execution parameters"
	@echo "	SCHEDULER		${SCHEDULER}"
	@echo "	SLURM_OUT		${SLURM_OUT}"
	@echo "	RUNNER			${RUNNER}"
	@echo "	RUNNER_HEADER		${RUNNER_HEADER}"
	@echo
	@echo "Data set specification"
#	@echo "	DISCIPLINE		${DISCIPLINE}"
	@echo "	BOARD			${BOARD}"
	@echo "	EXPERIMENTS		${EXPERIMENTS}"
	@echo "	EXPERIMENT		${EXPERIMENT}"
	@echo "	METADATA		${METADATA}"
	@echo "	ALL_METADATA		${ALL_METADATA}"
	@echo "	TEST_SEQ		${TEST_SEQ}"
	@echo "	TF			${TF}"
	@echo "	RESULT_DIR		${RESULT_DIR}"
	@echo
	@echo "Fetch-sequences"
	@echo "	DATASET_DIR		${DATASET_DIR}"
	@echo "	DATASET			${DATASET}"
	@echo "	PEAK_COORD		${PEAK_COORD}"
	@echo "	FASTA_SEQ		${FASTA_SEQ}"
	@echo "	TRAIN_SEQ		${TRAIN_SEQ}"
	@echo "	FETCH_CMD		${FETCH_CMD}"
	@echo "	FASTQ2FASTA_CMD		${FASTQ2FASTA_CMD}"
	@echo
	@echo "matrix-clustering options"
	@echo "	PEAKMO_CLUSTERS_DIR	${PEAKMO_CLUSTERS_DIR}"
	@echo "	PEAKMO_CLUSTERS		${PEAKMO_CLUSTERS}"
	@echo "	CLUSTER_CMD		${CLUSTER_CMD}"
	@echo
	@echo "convert-matrix"
	@echo "	CONVERT_MATRIX_CMD	${CONVERT_MATRIX_CMD}"
	@echo
	@echo "matrix-quality"
	@echo "	BG_EQUIPROBA		${BG_EQUIPROBA}"
	@echo "	MATRIXQ_DIR		${MATRIXQ_DIR}"
	@echo "	MATRIXQ_PREFIX		${MATRIXQ_PREFIX}"
	@echo "	MATRIXQ_CMD		${MATRIXQ_CMD}"
	@echo
	@echo "peak-motif options"
	@echo "	PEAKMO_OPT		${PEAKMO_OPT}"
	@echo "	PEAKMO_NMOTIFS		${PEAKMO_NMOTIFS}"
	@echo "	PEAKMO_MINOL		${PEAKMO_MINOL}"
	@echo "	PEAKMO_MAXOL		${PEAKMO_MAXOL}"
	@echo
	@echo "Matrix post-processing"
	@echo "	MATRICES		${MATRICES}"
	@echo "	PEAKMO_MATRICES		${PEAKMO_MATRICES}"
	@echo "	CLUSTER_MATRICES	${CLUSTER_MATRICES}"
	@echo "	TRIM_INFO		${TRIM_INFO}"
	@echo "	TRIMMED_MATRICES	${TRIMMED_MATRICES}"
	@echo "	transfac counts		${MATRICES}.tf"
	@echo "	cluster matrices	${CLUSTER_MATRICES}.tf"
	@echo "	transfac trimmed	${TRIMMED_MATRICES}.tf"
	@echo "	transfac freq		${TRIMMED_MATRICES}_freq.tf"
	@echo "	cb freq			${TRIMMED_MATRICES}_freq.cb"
	@echo "	IBIS format		${TRIMMED_MATRICES}_freq.txt"
	@echo
	@echo "Random sequences"
	@echo "	RAND_SEQ		${RAND_SEQ}"
	@echo "	RAND_SCRIPT		${RAND_SCRIPT}"
	@echo
	@echo "Sequence scanning"
	@echo "	SCAN_MATRICES		${SCAN_MATRICES}"
	@echo "	SCAN_SEQ		${SCAN_SEQ}"
	@echo "	SCAN_DIR		${SCAN_DIR}"
	@echo "	SCAN_TYPE		${SCAN_TYPE}"
	@echo "	SCAN_THREADS		${SCAN_THREADS}"
	@echo "	SCAN_PREFIX		${SCAN_PREFIX}"
	@echo "	SCAN_RESULT		${SCAN_RESULT}"
	@echo "	SCAN_CMD		${SCAN_CMD}"
	@echo "	SCAN_SCRIPT		${SCAN_SCRIPT}"
	@echo
	@echo "Iteration parameters"
	@echo "	DATASETS		${DATASETS}"
	@echo "	TFS			${TFS}"
	@echo "	TASK			${TASK}"
	@echo


targets_00:
	@echo
	@echo "Common targets (makefiles/00_parameters.mk)"
	@echo "	targets			list targets"
	@echo "	param			list parameters"
	@echo "	metadata		build metadata table for one experiment"
	@echo "	  metadata_fasta	build metadata table by finding fasta files (CHS and GHTS data)"
	@echo "	  metadata_fastq	build metadata table by finding fastq files (HTS and SMS data)"
	@echo "	  metadata_pbm		build metadata table for PBM data, from the TSV file"
	@echo "	all_metadata		concatenate metadata files of all the experiments"
	@echo "	fetch_sequences		retrieve peak sequences from UCSC (for CHS and GHTS data)"
	@echo "	fastq2fasta		convert sequences from fastq to fasta format (for HTS and SMS data)"
	@echo
	@echo "Matrix processing"
	@echo "	cluster_matrices	Cluster matrices discovered by peak-motifs"
	@echo "	trim_matrices		Trim matrices to suppress non-informative columns on both sides"
	@echo
	@echo "Random genome fragments"
	@echo "	rand_fragments			select random genome fragment as negative set for a given dataset"e
	@echo "	rand_fragments_all_datasets	run rand_fragments for all the datasets of the current experiment"
	@echo "	rand_fragments_all_experiments	run rand_fragments for all the datasets of all the experiments"
	@echo
	@echo "Sequence scanning with discovered motifs"
	@echo "	scan_sequences		scan sequences with matrices discovered with peak-motifs"
	@echo "	  scan_sequences_train	scan training sequences"
	@echo "	  scan_sequences_rand	scan random genome fragments sequences"
	@echo "	  scan_sequences_test	scan test sequences"
	@echo "	scan_sequences_all_datasets	scan all the datasets for a given experiment"
	@echo "	scan_sequences_all_experiments	scan all the datasets for all the experiments"
	@echo
	@echo "Iterators"
	@echo "	iterate_datasets	iterate a task over all the datasets of a given experiment"
	@echo "	iterate_experiments	iterate a task over all the experiments"
	@echo

################################################################
## Run fetch-sequences to retrieve fasta sequences from the peak
## coordinates (bed) from the UCSC genome browser
FETCH_CMD=${RSAT_CMD} fetch-sequences -v 1 \
	-genome hg38 \
	-header_format galaxy \
	-i ${PEAK_COORD} -o ${FASTA_SEQ}
fetch_sequences_one_dataset:
	@echo
	@echo "Retrieving peak sequences from UCSC"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	${FETCH_CMD}
	@echo
	@echo "	FASTA_SEQ	${FASTA_SEQ}"

################################################################
## Fetch peak sequences from UCSC for the genomic data
fetch_sequences:
	@for exp in CHS GHTS; do \
		${MAKE} iterate_datasets EXPERIMENT=$${exp} TASK=fetch_sequences_one_dataset; \
	done

################################################################
## For HTS and SMS data, convert fastq sequences to fasta format
FASTQ2FASTA_CMD=${RSAT_CMD} convert-seq -from fastq -to fasta -i ${FASTQ_SEQ} -o ${FASTA_SEQ}
fastq2fasta:
	@echo
	@echo "Converting sequences from fastq.gz to fasta"
	@echo "	FASTQ_SEQ	${FASTQ_SEQ}"
	@${FASTQ2FASTA_CMD}
	@echo
	@echo "	FASTA_SEQ	${FASTA_SEQ}"


################################################################
## Iterate a task over all datasets of the leaderboard for a given experiment
iterate_datasets:
	@echo 
	@echo "Iterating over datasets"
	@echo "	BOARD		${BOARD}"
	@echo "	EXPERIMENT	${EXPERIMENT}"
	@echo "	DATASETS	${DATASETS}"
	@echo "	TASK		${TASK}"
	@for dataset in ${DATASETS} ; do ${MAKE} one_task DATASET=$${dataset}; done

one_task:
	@echo
	@echo "	BOARD=${BOARD}	EXPERIMENT=${EXPERIMENT}	TF=${TF}	DATASET=${DATASET}"
	${MAKE}  TF=${TF} EXPERIMENT=${EXPERIMENT} DATASET=${DATASET} ${TASK}

################################################################
## Iterate a task over all the experiments
iterate_experiments:
	@echo 
	@echo "Iterating over experiments"
	@for experiment in ${EXPERIMENTS} ; do \
		${MAKE} one_task_experiment EXPERIMENT=$${experiment} ;  \
	done

EXPERIMENT_TASK=metadata
one_task_experiment:
	@echo "	EXPERIMENT	${EXPERIMENT}"
	@${MAKE} ${EXPERIMENT_TASK}


################################################################
## Build a table with the peak sets associated to each transcription
## factor.
metadata: metadata_${SOURCE_FORMAT}

################################################################
## CHS and GHTS data (genomic data): peak coordinates, .peak files
METADATA_HEADER="\#TF	DATASET	SIZE	EXPERIMENT	BOARD	SOURCE_FORMAT	FASTA_SEQ"
metadata_fasta:
	@echo
	@echo "Building metadata table for ${BOARD} ${EXPERIMENT} data (source data format: ${SOURCE_FORMAT})"
	@echo
	@echo ${METADATA_HEADER} > ${METADATA}
	wc -l data/${BOARD}/train/${EXPERIMENT}/*/*.peaks  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.peaks||' \
		| awk -F'\t' '$$6 != "" {print $$7"\t"$$8"\t"$$2"\t${EXPERIMENT}\t${BOARD}\t${SOURCE_FORMAT}\t"$$3"/"$$4"/"$$5"/"$$6"/"$$7"/"$$8".fasta"}'  >> ${METADATA}
	@echo
	@echo "	METADATA	${METADATA}"
	@echo

################################################################
## HTS and SMS data: fastq.gz files
metadata_fastq:
	@echo
	@echo "Building metadata table for ${BOARD} ${EXPERIMENT} data (source data format: ${SOURCE_FORMAT})"
	@echo
	@echo ${METADATA_HEADER} > ${METADATA}
	du -sk data/${BOARD}/train/${EXPERIMENT}/*/*.fastq.gz  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.fastq.gz||' \
		| awk -F'\t' '$$6 != "" {print $$6"\t"$$7"\t"$$1"\t${EXPERIMENT}\t${BOARD}\t${SOURCE_FORMAT}\t"$$2"/"$$3"/"$$4"/"$$5"/"$$6"/"$$7".fasta"}' >> ${METADATA}
	@echo
	@echo "	METADATA	${METADATA}"
	@echo


# ################################################################
# ## PBM data: TSV files
# metadata_pbm:
# 	@${MAKE} -f makefiles/04_PBM.mk metadata_pbm

################################################################
## Generate a metadata file with all the datasets for all the TFs
all_metadata:
	@echo
	@echo "Building metadata file for each experiments"
	@for exp in CHS GHTS HTS SMS; do \
		${MAKE} metadata EXPERIMENT=$${exp} ; \
	done
	@make -f makefiles/04_PBM.mk metadata_pbm
	@echo
	@echo "Merging metadata for all experiments"
	ls -1  metadata/${BOARD}/TF_DATASET_* \
		| grep -v ${ALL_METADATA} \
		| xargs cat | sort -u > ${ALL_METADATA}
	@echo "	ALL_METADATA	${ALL_METADATA}"


################################################################
## Parameters for peak-motifs shared by several scripts
PEAKMO_OPT=-nopurge
PEAKMO_PREFIX=peak-motifs${PEAKMO_OPT}
PEAKMO_NMOTIFS=3
PEAKMO_MINOL=6
PEAKMO_MAXOL=7
JASPAR_MOTIFS=${MOTIFDB_DIR}/JASPAR/Jaspar_2020/nonredundant/JASPAR2020_CORE_vertebrates_non-redundant_pfms.tf
HOCOMOCO_MOTIFS=${MOTIFDB_DIR}/HOCOMOCO/HOCOMOCO_2017-10-17_Human.tf
PEAKMO_DIR=${RESULT_DIR}/${PEAKMO_PREFIX}
PEAKMO_MATRICES=${PEAKMO_DIR}/results/discovered_motifs/${PEAKMO_PREFIX}_motifs_discovered
PEAKMO_CLUSTERS_DIR=${PEAKMO_DIR}/clustered_motifs
PEAKMO_CLUSTERS=${PEAKMO_CLUSTERS_DIR}/matrix-clusters

################################################################
## Choose a matrix file for post-processing commands:
## matrix-clustering, matrix-quality By default, we use peak-motifs
## discovered motifs, but the commands can alo be used for other
## matrices. 
MATRICES=${PEAKMO_MATRICES}
CLUSTER_MATRICES=${PEAKMO_CLUSTERS}_aligned_logos/All_concatenated_motifs
TRIMMED_MATRICES=${CLUSTER_MATRICES}_trimmed-info_${TRIM_INFO}


################################################################
## Convert matrices from Transfac to cluster-buster format
HEADER_CLEAN_CMD=perl -pe 's/^>/>${TF} ${DATASET}_/; s/oligos_/oli_/; s/positions_/pos_/; s/\.Rep-MICHELLE/M/; s/\.Rep-DIANA/D/; s/ \/name.*//; s/cluster_/c/; s/node_/n/; s/motifs/m/'
CONVERT_MATRIX_CMD=${RSAT_CMD} convert-matrix -v ${V} -i ${CLUSTER_MATRICES}.tf -from transfac -to transfac -trim_info ${TRIM_INFO} -return counts -o ${TRIMMED_MATRICES}.tf; ${RSAT_CMD}; ${RSAT_CMD} convert-matrix -v ${V} -i ${TRIMMED_MATRICES}.tf  -from transfac -to cluster-buster -return frequencies -decimals 5 -o ${TRIMMED_MATRICES}_freq.cb ; cat ${TRIMMED_MATRICES}_freq.cb | ${HEADER_CLEAN_CMD} > ${TRIMMED_MATRICES}_freq.txt
convert_matrices: 
	@echo "Converting matrices from transfac to cluster-buster format"
	@echo "	MATRICES		${MATRICES}"
	@echo "	PEAKMO_MATRICES		${PEAKMO_MATRICES}"
	@echo "	CLUSTER_MATRICES	${CLUSTER_MATRICES}"
	@echo "	TRIMMED_MATRICES	${TRIMMED_MATRICES}"
	@${CONVERT_MATRIX_CMD}
	@echo "	transfac counts		${MATRICES}.tf"
	@echo "	cluster matrices	${CLUSTER_MATRICES}.tf"
	@echo "	transfac trimmed	${TRIMMED_MATRICES}.tf"
	@echo "	transfac freq		${TRIMMED_MATRICES}_freq.tf"
	@echo "	cb freq			${TRIMMED_MATRICES}_freq.cb"
	@echo "	IBIS format		${TRIMMED_MATRICES}_freq.txt"

################################################################
## matrix-clusering command
CLUSTER_CMD=${RSAT_CMD} matrix-clustering -v ${V} \
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
## Trim the non-informative columns at the left and right sides of
## position-specific scoring matrices.
TRIM_INFO=0.1
TRIM_CMD=${RSAT_CMD} convert-matrix -v ${V} -i ${MATRICES}.tf \
	-from transfac -to transfac \
	-trim_info ${TRIM_INFO} \
	-return counts \
	-o ${TRIMMED_MATRICES}.tf
trim_matrices:
	@echo "Trimming position-specific scoring matrices"
	@echo "	INFO_TRHESHOLD		${TRIM_INFO}"
	@echo "	MATRICES		${MATRICES}"
	@echo "	TRIMMED_MATRICES	${TRIMMED_MATRICES}"
	${RUNNER} ${TRIM_CMD}

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
##
## Specific options:
##
## -uth rank 1 : return only the top-scoring site per sequence
##
## -bgfile : we use an independently and identically distributed model
##           (all nucleotides have a proba of 0.25) for consistency
##           with the IBIS benchmarking protocol, even though this
##           model does not reflect the actual composition of human
##           regulatory sequences. .
BG_OL=2
BG_EQUIPROBA=bg_models/equiprobable_1str.tsv
#MATRIXQ_DIR=${PEAKMO_DIR}/matrix-quality
MATRIXQ_DIR=${TRIMMED_MATRICES}_matrix-quality
MATRIXQ_PREFIX=${MATRIXQ_DIR}/matrix-quality
#MATRIXQ_MATRIX_OPT=-ms ${MATRICES}.tf
MATRIXQ_MATRIX_OPT=-m ${TRIMMED_MATRICES}.tf
MATRIXQ_SEQ_OPT=-seq ${TF}_${DATASET} ${FASTA_SEQ} -seq 'test_seq' ${TEST_SEQ}
MATRIXQ_SEQ_PLOT_OPT=-plot ${TF}_${DATASET} nwd -plot 'test_seq' nwd
MATRIXQ_PERM=1
MATRIXQ_SEQ_PERM_OPT=-perm ${TF}_${DATASET} ${MATRIXQ_PERM} -perm 'test_seq' ${MATRIXQ_PERM}
MATRIXQ_TITLE=IBIS24_${BOARD}_${EXPERIMENT}_${TF}_${DATASET}
MATRIXQ_CMD=${RSAT_CMD} matrix-quality  -v ${V} \
	${MATRIXQ_MATRIX_OPT} \
	-html_title '${MATRIXQ_TITLE}'  \
	-matrix_format transfac \
	-bgfile ${BG_EQUIPROBA} \
	-bg_format oligo-analysis \
	-pseudo 1 \
	-seq_format fasta \
	${MATRIXQ_SEQ_OPT} \
	${MATRIXQ_SEQ_PLOT_OPT} \
	${MATRIXQ_SEQ_PERM_OPT} \
	-o ${MATRIXQ_PREFIX}

#	-archive \
#	-uth rank 1 \

## JvH: THERE SEEMS TO BE A BUG WITH THE -bg_pseudo OPTION. I SHOULD CHECK THIS
#	-bg_pseudo 0.01 \


matrix_quality:
	@mkdir -p ${MATRIXQ_DIR}
	@echo "	MATRIXQ_DIR	${MATRIXQ_DIR}"
	@echo "	MATRIXQ_CMD	${MATRIXQ_CMD}"
	${MATRIXQ_CMD}
	@echo "	MATRIXQ_PREFIX	${MATRIXQ_PREFIX}"

################################################################
## Select random genomic sequences of the same lengths as the current
## data set
RAND_SEQ=`awk '$$2=="${DATASET}" {sub(/\.fasta/,"_rand-loci.fa",$$7); print $$7}' ${ALL_METADATA}`
RAND_CMD="${SCHEDULER} ${RSAT_CMD} random-genome-fragments  \
		-template_format fasta \
		-i ${FASTA_SEQ} \
		-org Homo_sapiens_GCF_000001405.40_GRCh38.p14  -return seq \
		| ${RSAT_CMD} convert-seq -from fasta -to fasta -skip_polyN -lw 0 \
		-o ${RAND_SEQ}"
RAND_SCRIPT=${DATASET_PATH}_rand-loci.sh
rand_fragments:
	@echo
	@echo "Selecting random genome fragments for ${BOARD} train ${DATASET}"
	@echo "	RAND_SCRIPT	${RAND_SCRIPT}"
	@echo "	RAND_SEQ	${RAND_SEQ}"
	@echo ${RUNNER_HEADER} > ${RAND_SCRIPT}
	@echo >> ${RAND_SCRIPT}
	@echo ${RAND_CMD} >> ${RAND_SCRIPT}
	@${RUNNER} ${RAND_SCRIPT}

rand_fragments_all_datasets:
	@echo "Running rand_fragments for all datasets ${BOARD}	${EXPERIMENT}"
	@${MAKE} iterate_datasets TASK=rand_fragments


rand_fragments_all_experiments:
	@echo "Running rand_fragments for all data sets of all experiments"
	@${MAKE} iterate_experiments EXPERIMENT_TASK=rand_fragments_all_datasets


################################################################
## Scan sequences with matrices
#SCAN_MATRICES=${PEAKMO_CLUSTERS}_aligned_logos/All_concatenated_motifs
SCAN_MATRICES=${TRIMMED_MATRICES}
#SCAN_DIR=${PEAKMO_DIR}/sequence-scan
SCAN_DIR=${SCAN_MATRICES}/sequence-scan
#SCAN_SEQ=${FASTA_SEQ}
SCAN_TYPE=train
SCAN_SEQ=${TRAIN_SEQ}
SCAN_PREFIX=${SCAN_DIR}/${EXPERIMENT}_${TF}_${DATASET}_peakmo-clust-matrices_${SCAN_TYPE}
SCAN_SCRIPT=${SCAN_PREFIX}_cmd.sh
SCAN_RESULT=${SCAN_PREFIX}.tsv
SCAN_CMD=${SCHEDULER} ${RSAT_CMD} matrix-scan -quick -v ${V} \
	-m ${SCAN_MATRICES}.tf \
	-matrix_format transfac \
	-i ${SCAN_SEQ} \
	-seq_format fasta \
	-bgfile ${BG_EQUIPROBA} \
	-bg_pseudo 0.01 \
	-pseudo 1 \
	-decimals 1 \
	-2str \
	-return sites \
	-uth rank_pm 1 \
	-n score \
	| cut -f 1,3-6,8 \
	> ${SCAN_RESULT}
scan_sequences_one_type:
	@echo "Scanning sequences"
	@echo "	SCAN_MATRICES		${SCAN_MATRICES}"
	@echo "	SCAN_SEQ		${SCAN_SEQ}"
	@echo "	SCAN_DIR		${SCAN_DIR}"
	@echo "	SCAN_TYPE		${SCAN_TYPE}"
	@echo "	SCAN_PREFIX		${SCAN_PREFIX}"
	@echo "	SCAN_RESULT		${SCAN_RESULT}"
	@echo "	SCAN_CMD		${SCAN_CMD}"
	@echo "	SCAN_SCRIPT		${SCAN_SCRIPT}"
	@mkdir -p ${SCAN_DIR}
	@echo ${RUNNER_HEADER} > ${SCAN_SCRIPT}
	@echo >> ${SCAN_SCRIPT}
	@echo "${SCAN_CMD}" >> ${SCAN_SCRIPT}
	@echo >> ${SCAN_SCRIPT}
	@echo gzip --force ${SCAN_RESULT} >> ${SCAN_SCRIPT}
	@${RUNNER} ${SCAN_SCRIPT}
#	@echo "	SCAN_RESULT		${SCAN_RESULT}"
	@echo "	SCAN_RESULT (gzipped)	${SCAN_RESULT}.gz"
	@echo

scan_sequences_train:
	@${MAKE} scan_sequences_one_type SCAN_SEQ=${TRAIN_SEQ} SCAN_TYPE=train

scan_sequences_rand:
	@${MAKE} scan_sequences_one_type SCAN_SEQ=${RAND_SEQ} SCAN_TYPE=rand

scan_sequences_test:
	@${MAKE} scan_sequences_one_type SCAN_SEQ=${TEST_SEQ} SCAN_TYPE=test

scan_sequences: scan_sequences_train scan_sequences_rand scan_sequences_test

scan_sequences_all_datasets:
	@${MAKE} iterate_datasets TASK=scan_sequences

scan_sequences_all_experiments:
	@${MAKE} iterate_experiments EXPERIMENT_TASK=scan_sequences_all_datasets

################################################################
## Parameters for the clustering of all motifs discovered for a given transcription factor
TFCLUST_DIR=results/${BOARD}/train/cross-data-types/${TF}
TFCLUST_INFILES=`find results/${BOARD}/train/*/${TF} -name 'peak-motifs*_motifs_discovered.tf' | awk -F'/' '{print " -matrix "$$4":"$$5":"$$6" "$$0" transfac"}' | xargs`
TFCLUST_PREFIX=${TFCLUST_DIR}/matrix-clustering
TFCLUST_ROOT_MOTIFS=${TFCLUST_PREFIX}_cluster_root_motifs
TFCLUST_ALL_MOTIFS=${TFCLUST_PREFIX}_aligned_logos/All_concatenated_motifs
TFCLUST_SCRIPT=${TFCLUST_PREFIX}_cmd.sh
TFCLUST_SLURM_OUT=./slurm_out/TFCLUST_${BOARD}_cross-data-types_${TF}_slurm-job_%j.out

################################################################
## Define rules based on extensions to convert transfac-formatted
## (.tf) motif file sinto frequency matrices suitable for submission
## to IBIS challenge.

## Trim the non-informative left and right columns of a PSSM
%_trimmed.tf : %.tf
	${RSAT_CMD} convert-matrix -i $< \
		-from transfac -to transfac \
		-bgfile ${BG_EQUIPROBA} \
		-decimals 3 \
		-trim_info ${TRIM_INFO} \
		-return counts \
		-o $@

## Convert a transfac-formatted into tab-formatted matrix and add information 
%_info.tab : %.tf
	${RSAT_CMD} convert-matrix -i $< \
		-from transfac -to tab \
		-bgfile ${BG_EQUIPROBA} \
		-decimals 3 \
		-return parameters,counts,frequencies,weights,info,margins \
		-o $@

## Convert count matrix into frequency matrix in transfac format
%_freq.tf : %.tf
	${RSAT_CMD} convert-matrix -i $< \
		-from transfac -to transfac \
		-rescale 1 -decimals 4 -o $@

## Convert matrix from transfac to cluster-buster format
%.cb : %.tf
	${RSAT_CMD} convert-matrix -i $< \
		-from transfac -to cluster-buster \
		-o $@

## Add transcription factor name as first item in the motif header of a cluster-buster file + shorten the motif ID
%.txt : %.cb
	cat $< \
		| perl -pe 's/^>/>${TF} ${EXPERIMENT}_${DATASET}_/; s/oligos_/oli_/; s/positions_/pos_/; s/\.Rep-MICHELLE/M/; s/\.Rep-DIANA/D/; s/ \/name.*//;' \
		> $@

