################################################################
## Motif discovery for the IBIS challenge 2024
##
## Participants: Jacques van Helden and Bruno Contreiras Moreira

list_targets:
	@echo
	@echo "Targets"
	@echo "	targets		list targets"
	@echo "	param		list parameters"
	@echo "	datatable	build a table with the names of peaksets associated to each transcription factor"
	@echo "	peakseq		retrieve peak sequences from UCSC"
	@echo "	peakmo		discover motifs in peak sequences"
	@echo

param:
	@echo
	@echo "Parameters"
	@echo "	SCHEDULER	${SCHEDULER}"
#	@echo "	DISCIPLINE	${DISCIPLINE}"
	@echo "	MOTIFDB_DIR	${MOTIFDB_DIR}"
	@echo "	JASPAR_MOTIFS	${JASPAR_MOTIFS}"
	@echo "	HOCOMOCO_MOTIFS	${HOCOMOCO_MOTIFS}"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@echo "	PEAKSET_TABLE	${PEAKSET_TABLE}"
	@echo "	TF		${TF}"
	@echo "	PEAKSET		${PEAKSET}"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	@echo "	PEAK_SEQ	${PEAK_SEQ}"
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"
	@echo

MOTIFDB_DIR=/shared/projects/rsat_organism/motif_databases
JASPAR_MOTIFS=${MOTIFDB_DIR}/JASPAR/Jaspar_2020/nonredundant/JASPAR2020_CORE_vertebrates_non-redundant_pfms.tf
HOCOMOCO_MOTIFS=${MOTIFDB_DIR}/HOCOMOCO/HOCOMOCO_2017-10-17_Human.tf
SCHEDULER=srun time
DISCIPLINE=WET
BOARD=leaderboard
DATA_TYPE=CHS
TF=GABPA
PEAKSET=THC_0866
PEAK_PATH=data/${BOARD}/train/${DATA_TYPE}/${TF}/${PEAKSET}
PEAK_COORD=${PEAK_PATH}.peaks
PEAK_SEQ=${PEAK_PATH}.fasta
PEAKMO_DIR=results/${BOARD}/train/${DATA_TYPE}/${TF}/${PEAKSET}

################################################################
## Build a table with the peak sets associated to each transcription
## factor.
PEAKSET_TABLE=data/${BOARD}/TF_PEAKSET_${DATA_TYPE}.tsv
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
	${SCHEDULER} ${FETCH_CMD}
	@echo
	@echo "	PEAK_SEQ	${PEAK_SEQ}"

################################################################
## Run peak-motifs to discover motifs in peak sequences
PEAKMOTIFS_CMD=rsat peak-motifs  -v 1 -title 'IBIS24_${BOARD}_${TF}_${PEAKSET}' \
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
	-task purge,seqlen,composition,disco,merge_motifs,split_motifs,motifs_vs_motifs,timelog,archive,synthesis,small_summary,motifs_vs_db \
	-prefix peak-motifs \
	-img_format png \
	-motif_db Hocomoco_human tf ${HOCOMOCO_MOTIFS} \
	-motif_db jaspar_core_nonredundant_vertebrates tf ${JASPAR_MOTIFS} \
	-outdir ${PEAKMO_DIR}

peakmo: 
	@echo "Running peak-motifs"
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"
	@mkdir -p ${PEAKMO_DIR}
	@echo ${PEAKMOTIFS_CMD}
	${SCHEDULER} ${PEAKMOTIFS_CMD}

all:param peakseq peakmo
