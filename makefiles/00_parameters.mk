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
## Load data-type specific configuration
DATA_TYPES=CHS GHTS HTS SMS PBM
DATA_TYPE=CHS
include makefiles/config_${DATA_TYPE}.mk

V=2

DISCIPLINE=WET
BOARD=leaderboard
METADATA=metadata/${BOARD}/TF_DATASET_${DATA_TYPE}.tsv
TEST_SEQ=data/${BOARD}/test/${DATA_TYPE}_participants.fasta

#DATASET=`head -n 1 ${METADATA} | cut -f 2`
TF=`awk '$$2=="${DATASET}" {print $$1}' ${METADATA}`
DATASET_DIR=data/${BOARD}/train/${DATA_TYPE}/${TF}
DATASET_PATH=${DATASET_DIR}/${DATASET}
PEAK_COORD=${DATASET_PATH}.peaks
FASTA_SEQ=${DATASET_PATH}.fasta
TSV_SEQ=${DATASET_PATH}.tsv
FASTQ_SEQ=${DATASET_PATH}.fastq.gz
RESULT_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/${DATASET}

## Background models estimated based on the test sequences
BG_DIR=bg_models/${BOARD}/${DATA_TYPE}
BG_OL=2
BG_FILE=${BG_DIR}/${DATA_TYPE}_${BG_OL}nt-noov-2str.tsv

## Iteration parameters
TASK=oligo_tables
DATASETS=`cut -f 2 ${METADATA} | sort -u | xargs`
TFS=`cut -f 1 ${METADATA} | sort -u | xargs`

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
	@echo "	DATA_TYPES		${DATA_TYPES}"
	@echo "	DATA_TYPE		${DATA_TYPE}"
	@echo "	METADATA		${METADATA}"
	@echo "	TEST_SEQ		${TEST_SEQ}"
	@echo "	TF			${TF}"
	@echo "	RESULT_DIR		${RESULT_DIR}"
	@echo
	@echo "Fetch-sequences"
	@echo "	DATASET_DIR		${DATASET_DIR}"
	@echo "	DATASET			${DATASET}"
	@echo "	PEAK_COORD		${PEAK_COORD}"
	@echo "	FASTA_SEQ		${FASTA_SEQ}"
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
	@echo "	PEAKMO_MAXOL		${PEAKMO_MAXOL4}"
	@echo
	@echo "Matrix trimming"
	@echo "	TRIM_INFO		${TRIM_INFO}"
	@echo "	MATRICES		${MATRICES}"
	@echo "	TRIMMED_MATRICES	${TRIMMED_MATRICES}"
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
	@echo "	metadata		build metadata table for one data type"
	@echo "	  metadata_fasta	build metadata table by finding fasta files (CHS and GHTS data)"
	@echo "	  metadata_fastq	build metadata table by finding fastq files (HTS and SMS data)"
	@echo "	  metadata_pbm		build metadata table for PBM data, from the TSV file"
	@echo "	all_metadata		concatenate metadata files of all the data types"
	@echo "	fetch_sequences		retrieve peak sequences from UCSC (for CHS and GHTS data)"
	@echo "	fastq2fasta		convert sequences from fastq to fasta format (for HTS and SMS data)"
	@echo "	tsv2fasta		convert sequences from tsv files to fasta format (for PBM data)"
	@echo
	@echo "Matrix processing"
	@echo "	cluster_matrices	Cluster matrices discovered by peak-motifs"
	@echo "	trim_matrices		Trim matrices to suppress non-informative columns on both sides"
	@echo
	@echo "Iterators"
	@echo "	iterate_datasets	iterate a task over all the datasets of a given data type"
	@echo "	iterate_datatypes	iterate a task over all the data types"
	@echo

################################################################
## Run fetch-sequences to retrieve fasta sequences from the peak
## coordinates (bed) from the UCSC genome browser
FETCH_CMD=${RSAT_CMD} = fetch-sequences -v 1 \
	-genome hg38 \
	-header_format galaxy \
	-i ${PEAK_COORD} -o ${FASTA_SEQ}
fetch_sequences:
	@echo
	@echo "Retrieving peak sequences from UCSC"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	@${FETCH_CMD}
	@echo
	@echo "	FASTA_SEQ	${FASTA_SEQ}"

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
## Extract  fasta sequence file from the PBM data, sorted according to scores
PBM_SEQ_ID=${TF}_${DATASET}
TSV2FASTA_CMD=sort -nr -k 8 ${TSV_SEQ} \
	| awk -F'\t' '$$4 =="FALSE" {rank++; sig=sprintf("%.3f",$$8); bg=sprintf("%.3f", $$9); print ">${DATASET}_"spot-$$1"-"$$2"-"$$3"_signal_"sig"_bg_"bg"_rank_"rank"\n"$$6""}'\
	> ${FASTA_SEQ}
tsv2fasta:
	@echo "Extracting fasta sequences from TSV file"
	@echo "	TSV_SEQ		${TSV_SEQ}"
	${TSV2FASTA_CMD}
	@echo "	FASTA_SEQ	${FASTA_SEQ}"


################################################################
## Iterate a task over all datasets of the leaderboard for a given data type
iterate_datasets:
	@echo 
	@echo "Iterating over datasets"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@echo "	DATASETS	${DATASETS}"
	@for dataset in ${DATASETS} ; do ${MAKE} one_task DATASET=$${dataset}; done

one_task:
	@echo
	@echo "	BOARD=${BOARD}	DATATYPE=${DATA_TYPE}	TF=${TF}	DATASET=${DATASET}"
	${MAKE} ${TASK} TF=${TF} DATASET=${DATASET}

################################################################
## Iterate a task over all the data types
iterate_datatypes:
	@echo 
	@echo "Iterating over data types"
	@for datatype in ${DATA_TYPES} ; do \
		${MAKE} one_task_datatype DATA_TYPE=$${datatype} ;  \
	done

DATA_TYPE_TASK=metadata
one_task_datatype:
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@${MAKE} ${DATA_TYPE_TASK}


################################################################
## Build a table with the peak sets associated to each transcription
## factor.
metadata: metadata_${SEQ_FORMAT}

################################################################
## CHS and GHTS data (genomic data): peak coordinates, .peak files
metadata_fasta:
	@echo
	@echo "Building dataset table for ${DATA_TYPE} ${BOARD} ${SEQ_FORMAT} sequences"
	wc -l data/${BOARD}/train/${DATA_TYPE}/*/*.peaks  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.peaks||' \
		| awk -F'\t' '$$6 != "" {print $$7"\t"$$8"\t"$$2"\t${DATA_TYPE}\t${BOARD}\t${SEQ_FORMAT}"}'  > ${METADATA}
	@echo
	@echo "	METADATA	${METADATA}"
	@echo

################################################################
## HTS and SMS data: fastq.gz files
metadata_fastq:
	@echo
	@echo "Building dataset table for ${DATA_TYPE} ${BOARD} ${SEQ_FORMAT} sequences"
	du -sk data/${BOARD}/train/${DATA_TYPE}/*/*.fastq.gz  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.fastq.*||' \
		| awk -F'\t' '$$6 != "" {print $$6"\t"$$7"\t"$$1"\t${DATA_TYPE}\t${BOARD}\t${SEQ_FORMAT}"}'  > ${METADATA}
	@echo
	@echo "	METADATA	${METADATA}"
	@echo


################################################################
## PBM data: TSV files
metadata_pbm:
	@echo
	@echo "Building dataset table for ${DATA_TYPE} ${BOARD} ${SEQ_FORMAT} sequences"
	du -sk data/${BOARD}/train/${DATA_TYPE}/*/*.tsv  \
		| perl -pe 's|/|\t|g; s| +|\t|g; s|\.tsv||' \
		| awk -F'\t' '$$6 != "" {print $$6"\t"$$7"\t"$$1"\t${DATA_TYPE}\t${BOARD}\t${SEQ_FORMAT}"}'  > ${METADATA}
	@echo
	@echo "	METADATA	${METADATA}"
	@echo

################################################################
## Generate a metadata file with all the datasets for all the TFs
ALL_METADATA=metadata/${BOARD}/TF_DATASET_all-types.tsv
all_metadata:
	ls -1  metadata/${BOARD}/TF_DATASET_* \
		| grep -v ${ALL_METADATA} \
		| xargs cat > ${ALL_METADATA}
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



################################################################
## Convert matrices from Transfac to cluster-buster format
CONVERT_MATRIX_CMD=${RSAT_CMD} convert-matrix -from transfac -to transfac -i ${MATRICES}.tf -rescale 1 -decimals 4 -o ${MATRICES}_freq.tf ; ${RSAT_CMD} convert-matrix -from transfac -to cluster-buster -i ${MATRICES}_freq.tf -o ${MATRICES}_freq.cb ; cat ${MATRICES}_freq.cb | perl -pe 's/^>/>${TF} ${DATASET}_/; s/oligos_/oli_/; s/positions_/pos_/; s/\.Rep-MICHELLE/M/; s/\.Rep-DIANA/D/; s/ \/name.*//;' > ${MATRICES}_freq.txt
convert_matrices:
	@echo "Converting matrices from transfac to cluster-buster format"
	@echo "	MATRICES	${MATRICES}"
	@${CONVERT_MATRIX_CMD}
	@echo "	transfac counts	${MATRICES}.tf"
	@echo "	transfac freq	${MATRICES}_freq.tf"
	@echo "	cb format	${MATRICES}_freq.txt"

################################################################
## matrix-clusering command
CLUSTER_CMD=${RSAT_CMD} matrix-clustering -v ${V} \
	-max_matrices 50 \
	-matrix ${TF}_${DATASET} ${MATRICES}.tf transfac \
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
TRIMMED_MATRICES=${MATRICES}_trimmed-info_${TRIM_INFO}
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
MATRIXQ_DIR=${PEAKMO_DIR}/matrix-quality
MATRIXQ_PREFIX=${MATRIXQ_DIR}/matrix-quality
MATRIXQ_SEQ_OPT=-seq ${TF}_${DATASET} ${FASTA_SEQ} -seq 'test_seq' ${TEST_SEQ}
MATRIXQ_SEQ_PLOT_OPT=-plot ${TF}_${DATASET} nwd -plot 'test_seq' nwd
MATRIXQ_PERM=1
MATRIXQ_SEQ_PERM_OPT=-perm ${TF}_${DATASET} ${MATRIXQ_PERM} -perm 'test_seq' ${MATRIXQ_PERM}
MATRIXQ_TITLE=IBIS24_${BOARD}_${DATA_TYPE}_${TF}_${DATASET}
MATRIXQ_CMD=${RSAT_CMD} matrix-quality  -v ${V} \
	-html_title '${MATRIXQ_TITLE}'  \
	-ms ${MATRICES}.tf \
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
		| perl -pe 's/^>/>${TF} ${DATA_TYPE}_${DATASET}_/; s/oligos_/oli_/; s/positions_/pos_/; s/\.Rep-MICHELLE/M/; s/\.Rep-DIANA/D/; s/ \/name.*//;' \
		> $@

