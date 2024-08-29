###############################################################
## Combination of commands to reproduce all the results of the RSAT
## team for the IBIS challenge. 
##
## Participants: Jacques van Helden and Bruno Contreiras Moreira

include makefiles/01_init.mk
MAKEFILE=makefiles/all.mk


param: param_00
	@echo "Parameters"

targets: targets_00
	@echo
	@echo "Targets"
	@echo "	all_one_board	run all the required task for one board"
	@echo "	all		run all the required tasks for both leaderbord and final boards"

all:
	@${MAKE} all_one_board BOARD=leaderboard
	@${MAKE} all_one_board BOARD=final

all_one_board:
	@echo
	@echo "DATA PREPARATION"
	@echo 
	@echo "Generating metadata"
	@make -f makefiles/01_init.mk all_metadata
	@echo
	@echo "Fetching sequences for all CHS and GHTS datasets"
	@make -f makefiles/01_init.mk fetch_sequences
	@echo
	@echo "Converting fastq to fasta for all HTS and SMS datasets"
	@make -f makefiles/01_init.mk fastq2fasta
	@echo
	@echo "Extracing sequences from data tables for PBM experiments"
	@make -f makefiles/02_PBM.mk tsv2fasta
	@echo
	@echo "Extracting top and background spots for PBM experiments"
	@make -f makefiles/02_PBM.mk top_bg_seq_all_datasets"
	@echo
	@echo "Selecting random genome fragments"
	@make -f makefiles/01_init.mk rand_fragments_all_experiments
	@echo
	@echo "Collecting sequences for TF versus others analyses"
	@make -f makefiles/01_init.mk tf_vs_others_all_experiments
	@echo
	@echo "MOTIF DISCOVERY"
	@echo
	@echo "Motif discovery with peak-motifs"
	@make -f makefiles/01_peak-motifs.mk peakmo_all_experiments EXPERIMENTS='CHS GHTS SMS HTS'
	@echo
	@echo "Differential motif discovery with peak-motifs"
	@make -f makefiles/01_peak-motifs.mk peakmo_diff_all_experiments EXPERIMENTS='CHS GHTS SMS HTS'
	@make -f makefiles/02_PBM.mk peakmo_diff_all_datasets
	@echo
	@echo "MOTIF OPTIMIZATION"
	@echo
