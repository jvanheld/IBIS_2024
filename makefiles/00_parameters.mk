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

## Configuration for IFB server
RSAT_CMD=rsat
MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases

## Local configuration for Jacques van Helden
# MOTIFDB_DIR=~/packages/rsat/motif_databases
# MOTIFDB_DIR=/packages/rsat/public_html/motif_databases
# RSAT_CMD=docker run -v $$PWD:/home/rsat_user -v $$PWD/results:/home/rsat_user/out eeadcsiccompbio/rsat:20240725 rsat


################################################################
## Job scheduler parameters
NOW=`date +%Y-%m-%d_%H%M`
ERR_DIR=sbatch_errors
ERR_FILE=${ERR_DIR}/sbatch_error_${NOW}.txt
SCHEDULER=srun time # this can be used to run commands either from the shell or in a script
#SCHEDULER=echo \#!/bin/bash ; echo srun time 
SBATCH=sbatch
SLURM_OUT=./slurm_out/${BOARD}_${DATA_TYPE}_${TF}_${DATASET}_slurm-job_%j.out
SBATCH_HEADER="\#!/bin/bash\n\#SBATCH -o ${SLURM_OUT}\n\#SBATCH --mem-per-cpu=16G\n"

################################################################
## Load data-type specific configuration
DATA_TYPE=PBM
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
	@echo "Task execution parameters"
	@echo "	SCHEDULER	${SCHEDULER}"
	@echo "	SLURM_OUT	${SLURM_OUT}"
	@echo "	SBATCH		${SBATCH}"
	@echo "	SBATCH_HEADER	${SBATCH_HEADER}"
	@echo
	@echo "Data set specification"
#	@echo "	DISCIPLINE	${DISCIPLINE}"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@echo "	METADATA	${METADATA}"
	@echo "	TEST_SEQ	${TEST_SEQ}"
	@echo "	TF		${TF}"
	@echo "	RESULT_DIR	${RESULT_DIR}"
	@echo
	@echo "Fetch-sequences"
	@echo "	DATASET_DIR	${DATASET_DIR}"
	@echo "	DATASET		${DATASET}"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	@echo "	FASTA_SEQ	${FASTA_SEQ}"
	@echo "	FETCH_CMD	${FETCH_CMD}"
	@echo "	FASTQ2FASTA_CMD	${FASTQ2FASTA_CMD}"
	@echo
	@echo "matrix-clustering options"
	@echo "	PEAKMO_CLUSTERS_DIR	${PEAKMO_CLUSTERS_DIR}"
	@echo "	PEAKMO_CLUSTERS		${PEAKMO_CLUSTERS}"
	@echo "	CLUSTER_CMD		${CLUSTER_CMD}"
	@echo
	@echo "convert-matrix"
	@echo "	CONVERT_MATRIX_CMD		${CONVERT_MATRIX_CMD}"
	@echo
	@echo "matrix-quality"
	@echo "	QUALITY_DIR		${QUALITY_DIR}"
	@echo "	QUALITY_PREFIX		${QUALITY_PREFIX}"
	@echo "	QUALITY_CMD		${QUALITY_CMD}"
	@echo
	@echo "Motif databases"
	@echo "	MOTIFDB_DIR		${MOTIFDB_DIR}"
	@echo "	JASPAR_MOTIFS		${JASPAR_MOTIFS}"
	@echo "	HOCOMOCO_MOTIFS		${HOCOMOCO_MOTIFS}"
	@echo
	@echo "peak-motif options"
	@echo "	PEAKMO_OPT	${PEAKMO_OPT}"
	@echo "	PEAKMO_NMOTIFS	${PEAKMO_NMOTIFS}"
	@echo "	PEAKMO_MINOL	${PEAKMO_MINOL}"
	@echo "	PEAKMO_MAXOL	${PEAKMO_MAXOL4}"
	@echo
	@echo "Iteration parameters"
	@echo "	DATASETS	${DATASETS}"
	@echo "	TFS		${TFS}"
	@echo "	TASK		${TASK}"
	@echo

PEAKMO_DIR=${RESULT_DIR}/peak-motifs${PEAKMO_OPT}


targets_00:
	@echo
	@echo "Common targets (makefiles/00_parameters.mk)"
	@echo "	targets			list targets"
	@echo "	param			list parameters"
	@echo "	metadata		build metadata table for one data type"
	@echo "	fetch_sequences		retrieve peak sequences from UCSC (for CHS and GHTS data)"
	@echo "	fastq2fasta		convert sequences from fastq to fasta format (for HTS and SMS data)"
	@echo "	tsv2fasta		convert sequences from tsv files to fasta format (for PBM data)"
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
## Iterate a task over all datasets of the leaderboard
iterate_datasets:
	@echo 
	@echo "Iterating over datasets"
	@echo "	DATASETS	${DATASETS}"
	@for dataset in ${DATASETS} ; do ${MAKE} one_task DATASET=$${dataset}; done

one_task:
	@echo
	@echo "	BOARD=${BOARD}	DATATYPE=${DATA_TYPE}	TF=${TF}	DATASET=${DATASET}"; \
	${MAKE} ${TASK} TF=${TF} DATASET=${DATASET} ; \

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
		| awk -F'\t' '$$6 != "" {print $$7"\t"$$8"\t"$$2}'  > ${METADATA}
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
		| awk -F'\t' '$$6 != "" {print $$6"\t"$$7"\t"$$1}'  > ${METADATA}
	@echo
	@echo "	METADATA	${METADATA}"
	@echo

################################################################
## Parameters for peak-motifs shared by several scripts
PEAKMO_OPT=-nopurge
PEAKMO_NMOTIFS=3
PEAKMO_MINOL=6
PEAKMO_MAXOL=7
JASPAR_MOTIFS=${MOTIFDB_DIR}/JASPAR/Jaspar_2020/nonredundant/JASPAR2020_CORE_vertebrates_non-redundant_pfms.tf
HOCOMOCO_MOTIFS=${MOTIFDB_DIR}/HOCOMOCO/HOCOMOCO_2017-10-17_Human.tf
PEAKMO_MATRICES=${PEAKMO_DIR}/results/discovered_motifs/peak-motifs_motifs_discovered
PEAKMO_CLUSTERS_DIR=${PEAKMO_DIR}/clustered_motifs
PEAKMO_CLUSTERS=${PEAKMO_CLUSTERS_DIR}/matrix-clusters

CONVERT_MATRIX_CMD=${RSAT_CMD} convert-matrix -from transfac -to transfac -i ${PEAKMO_MATRICES}.tf -rescale 1 -decimals 4 -o ${PEAKMO_MATRICES}_freq.tf ; ${RSAT_CMD} convert-matrix -from transfac -to cluster-buster -i ${PEAKMO_MATRICES}_freq.tf -o ${PEAKMO_MATRICES}_freq.cb ; cat ${PEAKMO_MATRICES}_freq.cb | perl -pe 's/^>/>${TF} ${DATASET}_/; s/oligos_/oli_/; s/positions_/pos_/; s/\.Rep-MICHELLE/M/; s/\.Rep-DIANA/D/; s/ \/name.*//;' > ${PEAKMO_MATRICES}_freq.txt


################################################################
## Convert matrices from Transfac to cluster-buster format
# convert_matrices:
# 	@echo "Converting matrices from transfac to cluster-buster format"
# 	@echo "	PEAKMO_MATRICES	${PEAKMO_MATRICES}"
# 	@${CONVERT_MATRIX_CMD}
# 	@echo "	transfac counts	${PEAKMO_MATRICES}.tf"
# 	@echo "	transfac freq	${PEAKMO_MATRICES}_freq.tf"
# 	@echo "	cb format	${PEAKMO_MATRICES}_freq.txt"

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
QUALITY_CMD=${RSAT_CMD} matrix-quality  -v ${V} \
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

