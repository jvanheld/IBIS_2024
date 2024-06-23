################################################################
## Motif discovery for the IBIS challenge 2024
##
## Participants: Jacques van Helden and Bruno Contreiras Moreira

list_targets:
	@echo
	@echo "Targets"
	@echo "	targets		list targets"
	@echo "	param		list parameters"
	@echo "	sequences	retrieve peak sequences from UCSC"
	@echo "	peak-motifs	discover motifs in peak sequences"
	@echo

param:
	@echo
	@echo "Parameters"
#	@echo "	DISCIPLINE	${DISCIPLINE}"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@echo "	TF		${TF}"
	@echo "	PEAKSET		${PEAKSET}"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	@echo "	PEAK_SEQ	${PEAK_SEQ}"
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"
	@echo

SCHEDULER=time srun
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
## Run fetch-sequences to retrieve fasta sequences from the peak
## coordinates (bed) from the UCSC genome browser
FETCH_CMD=fetch-sequences -v 1 \
	-genome hg38 \
	-header_format galaxy \
	-i ${PEAK_COORD} -o ${PEAK_SEQ}
sequences:
	@echo ""
	@echo "Retrieving peak sequences from UCSC"
	@echo "	PEAK_COORD	${PEAK_COORD}"
	${SCHEDULER} ${FETCH_CMD}
	@echo "	PEAK_SEQ	${PEAK_SEQ}"

################################################################
## Run peak-motifs to discover motifs in peak sequences
PEAKMOTIFS_CMD=rsat peak-motifs  -v 1 -title 'IBIS24_${BOARD}_${TF}_${PEAKSET}' \
	-i ${PEAK_SEQ} \
	-markov auto \
	-disco oligos,positions \
	-nmotifs 5 \
	-minol 6 -maxol 7 \
	-no_merge_lengths \
	-2str \
	-origin center \
	-task purge,seqlen,composition,disco,merge_motifs,split_motifs,motifs_vs_motifs,timelog,archive,synthesis,small_summary \
	-prefix peak-motifs \
	-noov \
	-img_format png \
	-motif_db Hocomoco_human tf ${RSAT}/public_html/motif_databases/HOCOMOCO/HOCOMOCO_2017-10-17_Human.tf \
	-motif_db jaspar_core_nonredundant_vertebrates tf ${RSAT}/public_html/motif_databases/JASPAR/Jaspar_2020/nonredundant/JASPAR2020_CORE_vertebrates_non-redundant_pfms.tf \
	-outdir ${PEAKMO_DIR}


#	-scan_markov 1 \
#	-max_seq_len 1000
peak_motifs:
	@echo "Running peak-motifs"
	@echo "	PEAKMO_DIR	${PEAKMO_DIR}"
	@mkdir -p ${PEAKMO_DIR}
	@echo ${PEAKMOTIFS_CMD}
	${SCHEDULER} ${PEAKMOTIFS_CMD}
