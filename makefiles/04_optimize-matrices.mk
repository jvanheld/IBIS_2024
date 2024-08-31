##############################################################
## Run genetic algorithm to optimize the matrices produced by
## peak-motifs according to their capability to discriiminate positive
## from negative sequence sets.
##

include makefiles/01_init.mk
MAKEFILE=makefiles/04_optimize-matrices.mk

## Matrix optimization parameters
OMGA_GENERATIONS=20
CHILDREN=10
SELECT=5
POS_SEQ=${TF_SEQ}
NEG_SEQ=${OTHERS_SEQ}


targets: targets_00
	@echo "optimize-matrix-GA targets (${MAKEFILE})"
	@echo "	help				get help message for optimize-matrix-GA"
	@echo "	omga_input_matrices		generate input matrices for optimize-matrix-GA for 1 dataset"
	@echo "	omga_one_dataset		run optimize-matrix-GA on one dataset"
	@echo "	omga_all_datasets		run optimize-matrix-GA on all datasets of a given experiment"
	@echo "	omga_all_experiments		run optimize-matrix-GA on all datasets of all experiments"
	@echo
	@echo "Collection of all results and selection of the matrices"
	@echo "	omga_results_per_type		count the number of results per matrix type, TF and experiment"
	@echo "	omga_collect_tables		collect the performance stat tables for all experiment for a given TF"
	@echo "	omga_select_matrices		select 4 top-raking matrices per TF for each matrix type"
	@echo

param: param_00
	@echo
	@echo "Options for optimize-matrices-GA"
	@echo "	OMGA_DIR		${OMGA_DIR}"
	@echo "	OMGA_PATH		${OMGA_PATH}"
	@echo "	OMGA_PYTHON_PATH	${OMGA_PYTHON_PATH}"
	@echo "	THREADS			${THREADS}"
	@echo "	OMGA_GENERATIONS	${OMGA_GENERATIONS}"
	@echo "	CHILDREN		${CHILDREN}"
	@echo "	SELECT			${SELECT}"
	@echo "	OMGA_INPUT_MATRICES	${OMGA_INPUT_MATRICES}"
	@echo "	TRAIN_SEQ		${TRAIN_SEQ}"
	@echo "	POS_SEQ			${POS_SEQ}"
	@echo "	RAND_SEQ		${RAND_SEQ}"
	@echo "	TF_SEQ			${TF_SEQ}"
	@echo "	OTHERS_SEQ		${OTHERS_SEQ}"
	@echo "	NEG_SEQ			${NEG_SEQ}"
	@echo "	OMGA_OUT_DIR		${OMGA_OUT_DIR}"
	@echo "	OMGA_OUT_PREFIX		${OMGA_OUT_PREFIX}"
	@echo "	OMGA_CMD_PREFIX		${OMGA_CMD_PREFIX}"
	@echo "	OMGA_COMPA_CMD		${OMGA_COMPA_CMD}"
	@echo "	OMGA_CMD		${OMGA_CMD}"
	@echo "	PLOT_AUROC_CMD		${PLOT_AUROC_CMD}"
	@echo "	OMGA_SCRIPT		${OMGA_SCRIPT}"
	@echo "	OPTIMIZED_MATRICES_TF	${OPTIMIZED_MATRICES_TF}"
	@echo "	OPTIMIZED_MATRICES_CB	${OPTIMIZED_MATRICES_CB}"
	@echo "	OPTIMIZED_MATRICES_IBIS	${OPTIMIZED_MATRICES_IBIS}"
	@echo "	SCORE_TABLE		${SCORE_TABLE}"
	@echo "	AUROC_PLOT		${AUROC_PLOT}"
	@echo "	OMGA_COMPA_TAB		${OMGA_COMPA_TAB}"
	@echo "	OMGA_COMPA_HTML		${OMGA_COMPA_HTML}"
	@echo "	OMGA_COMPA_ALIGN	${OMGA_COMPA_ALIGN}"
	@echo
	@echo "Performance table collection"
	@echo "	MATRIX_TYPES		${MATRIX_TYPES}"
	@echo "	MATRIX_TYPE		${MATRIX_TYPE}"
	@echo "	RESULTS_PER_TYPE	${RESULTS_PER_TYPE}"
	@echo "	COLLECT_FILES		`wc -l ${COLLECT_FILES}`"
	@echo "	COLLECT_DIR		${COLLECT_DIR}"
	@echo "	COLLECT_TABLE		${COLLECT_TABLE}"
	@echo "	COLLECT_TABLE_COLUMNS	${COLLECT_TABLE_COLUMNS}"
	@echo "	COLLECT_TABLE_SORTED	${COLLECT_TABLE_SORTED}"
	@echo "	SELECT_TABLE_1TYPE	${SELECT_TABLE_1TYPE}"
	@echo "	SELECT_TABLE_INITIAL	${SELECT_TABLE_INITIAL}"
	@echo "	COLLECTED_PSSM_FINAL*	${COLLECTED_PSSM_FINAL}*"
	@echo

help:
	${OMGA_CMD} -h

## Choice of the matrices to optimize
OMGA_INPUT=peakmo

ifeq (${OMGA_INPUT},clusters)
	OMGA_INPUT_MATRICES=${TRIMMED_MATRICES}_c100000.tf
	OMGA_PRESUFFIX=clust-trimmed-matrices_tf-vs-others
else
	OMGA_INPUT_MATRICES=${PEAKMO_MATRICES}_noBS_c100000.tf
	OMGA_PRESUFFIX=peakmo-matrices_tf-vs-others
endif

#OMGA_PRESUFFIX=peakmo-matrices_train-vs-rand

OMGA_OUT_DIR=results/${BOARD}/${DATA_TYPE}/${EXPERIMENT}/${TF}/${DATASET}/optimized_matrices/${OMGA_PRESUFFIX}
OMGA_OUT_PREFIX=${OMGA_OUT_DIR}/${TF}_${EXPERIMENT}_${DATASET}_${OMGA_PRESUFFIX}
OMGA_SCRIPT=${OMGA_OUT_PREFIX}_cmd.sh
OMGA_CMD=${SCHEDULER} ${OMGA_CMD_PREFIX} -v ${V} \
		-t ${THREADS} \
		-g ${OMGA_GENERATIONS} \
		-c ${CHILDREN} \
		-s ${SELECT} \
		-m ${OMGA_INPUT_MATRICES} \
		-p ${POS_SEQ} \
		-n ${NEG_SEQ} \
		-b ${BG_EQUIPROBA} \
		-r '"${RSAT_CMD}"' \
		--output_prefix ${OMGA_OUT_PREFIX}

SCORE_TABLE=${OMGA_OUT_PREFIX}_gen0-${OMGA_GENERATIONS}_score_table.tsv
OPTIMIZED_MATRICES_TF=${OMGA_OUT_PREFIX}_gen${OMGA_GENERATIONS}_scored_AuROC_top5.tf
OPTIMIZED_MATRICES_CB=${OMGA_OUT_PREFIX}_gen${OMGA_GENERATIONS}_scored_AuROC_top5_freq.cb
OPTIMIZED_MATRICES_IBIS=${OMGA_OUT_PREFIX}_gen${OMGA_GENERATIONS}_scored_AuROC_top5_ibis.txt
AUROC_PLOT=${OMGA_OUT_PREFIX}_gen0-${OMGA_GENERATIONS}_auroc-profiles.pdf 
PLOT_AUROC_CMD=${OMGA_PYTHON_PATH} ${OMGA_DIR}/plot-auroc-profiles.py \
	-v 1 \
	-i ${SCORE_TABLE} \
	-t "${TF}_${EXPERIMENT}_${DATASET}_clust-trimmed-matrices" \
	-s "train-versus-rand" \
	--y_step1 0.05 --y_step2 0.01 \
	--min_y 0.0 --max_y 1.0 \
	--xsize 16 --ysize 8 \
	-f pdf \
	-o ${AUROC_PLOT}

OMGA_COMPA=${OMGA_OUT_PREFIX}_gen0-vs-gen20
OMGA_COMPA_TAB=${OMGA_COMPA}.tab
OMGA_COMPA_HTML=${OMGA_COMPA}.html
OMGA_COMPA_ALIGN=${OMGA_COMPA}_alignments_1ton.html
OMGA_COMPA_CMD=${RSAT_CMD} compare-matrices  -v ${V} \
	-file1 ${OPTIMIZED_MATRICES_TF} -format1 tf \
	-file2 ${OMGA_INPUT_MATRICES} \
	-format2 tf  -strand DR -lth cor 0.7 -lth Ncor 0.4 \
	-return cor,Ncor,logoDP,NsEucl,NSW,match_rank,matrix_id,matrix_name,width,strand,offset,consensus,alignments_1ton \
	-o ${OMGA_COMPA_TAB}
omga_compa:
	@echo "Comparing optimized matrices with initial matrices"
	@echo "	OMGA_COMMPA_CMD		${OMGA_COMPA_CMD}"
	${OMGA_COMPA_CMD}
	@echo "	OMGA_COMPA_TAB		${OMGA_COMPA_TAB}"
	@echo "	OMGA_COMPA_HTML		${OMGA_COMPA_HTML}"
	@echo "	OMGA_COMPA_ALIGN	${OMGA_COMPA_ALIGN}"

omga_input_matrices:
	@echo "Generating input matrices for opimize-matrix-GA"
	@${MAKE} ${OMGA_INPUT_MATRICES}
	@echo "	OMGA_INPUT_MATRICES	${OMGA_INPUT_MATRICES}"

omga_one_dataset: omga_input_matrices
	@echo "Optimizing matrices"
	@echo "	BOARD			${BOARD}"
	@echo "	EXPERIMENT		${EXPERIMENT}"
	@echo "	TF			${TF}"
	@echo "	DATASET			${DATASET}"
	@echo "	OMGA_INPUT_MATRICES	${OMGA_INPUT_MATRICES}"
	@echo "	POS_SEQ			${POS_SEQ}"
	@echo "	NEG_SEQ			${NEG_SEQ}"
	@echo "	OMGA_CMD		${OMGA_CMD}"
	@echo "	PLOT_AUROC_CMD		${PLOT_AUROC_CMD}"
	@echo "	Writing optimize-matrix-GA  script"
	@echo "	OMGA_SCRIPT		${OMGA_SCRIPT}"
	@${MAKE} ${OMGA_INPUT_MATRICES}
	@mkdir -p ${OMGA_OUT_DIR}
#	@echo -e ${RUNNER_HEADER} > ${OMGA_SCRIPT}
	@echo ${RUNNER_HEADER} > ${OMGA_SCRIPT}
	@echo "#SBATCH --cpus-per-task ${THREADS}\n" >> ${OMGA_SCRIPT}
	@echo >> ${OMGA_SCRIPT}
	@echo ${OMGA_CMD} >> ${OMGA_SCRIPT}
	@echo >> ${OMGA_SCRIPT}
	@echo ${PLOT_AUROC_CMD} >> ${OMGA_SCRIPT}
	@echo >> ${OMGA_SCRIPT}
	@echo ${OMGA_COMPA_CMD} >> ${OMGA_SCRIPT}
	@echo >> ${OMGA_SCRIPT}
	@echo ${MAKE} ${OPTIMIZED_MATRICES_TF} >> ${OMGA_SCRIPT}
	@echo ${MAKE} ${OPTIMIZED_MATRICES_CB} >> ${OMGA_SCRIPT}
	@echo ${MAKE} ${OPTIMIZED_MATRICES_IBIS} >> ${OMGA_SCRIPT}
	@${RUNNER} ${OMGA_SCRIPT}
	@echo "	OMGA_OUT_PREFIX		${OMGA_OUT_PREFIX}"
	@echo "	OPTIMIZED_MATRICES_TF	${OPTIMIZED_MATRICES_TF}"
	@echo "	OPTIMIZED_MATRICES_CB	${OPTIMIZED_MATRICES_CB}"
	@echo "	OPTIMIZED_MATRICES_IBIS	${OPTIMIZED_MATRICES_IBIS}"
	@echo "	SCORE_TABLE		${SCORE_TABLE}"
	@echo "	AUROC_PLOT		${AUROC_PLOT}"
	@echo "	OMGA_COMPA_TAB		${OMGA_COMPA_TAB}"
	@echo "	OMGA_COMPA_HTML		${OMGA_COMPA_HTML}"
	@echo "	OMGA_COMPA_ALIGN	${OMGA_COMPA_ALIGN}"
	@echo


omga_all_datasets:
	@${MAKE} iterate_datasets TASK=omga_one_dataset

omga_all_experiments:
	@${MAKE} iterate_experiments EXPERIMENT_TASK=omga_all_datasets



################################################################
## Count the number of final optimization tables per matrix type, TF
## and experiment
RESULTS_PER_TYPE=${COLLECT_DIR}/results_per_type_${BOARD}_all-TFs.tsv
RESULTS_PER_TYPE_XTAB=${COLLECT_DIR}/results_per_type_${BOARD}_all-TFs_cross-table.tsv
omga_results_per_type:
	@mkdir -p ${COLLECT_DIR}
	@echo "Counting the number of optimization results per matrix type, TF and experiment"
	@find results/${BOARD}/train \
		-name '*_gen0-20_score_table.tsv' | awk -F'/' 'BEGIN { OFS="\t" } { print $$8, $$5, $$4 }' \
		| sort | uniq -c | sort -k 2 -k 3 -k 4 \
		> ${RESULTS_PER_TYPE}
	@echo "	RESULTS_PER_TYPE	${RESULTS_PER_TYPE}"
	@gawk '{ matrix[$$3][$$4] = $$1; row[$$3] += $$1; col[$$4] += $$1; total[$$3] += $$1; grand_total += $$1; } END { printf "\t"; for (c in col) printf "%s\t", c; print "Row Total"; for (r in row) { printf "%s\t", r; sum = 0; for (c in col) { val = matrix[r][c] ? matrix[r][c] : 0; printf "%s\t", val; sum += val; } printf "%s\n", sum; } printf "Column Total\t"; for (c in col) printf "%s\t", col[c]; printf "%s\n", grand_total; }'  ${RESULTS_PER_TYPE} > ${RESULTS_PER_TYPE_XTAB}
	@echo "	RESULTS_PER_TYPE_XTAB	${RESULTS_PER_TYPE_XTAB}"

################################################################
## Collect all the performance tables, sort them and select matrices for submission
COLLECT_DIR=results/${BOARD}/train/cross-experiments
COLLECT_TABLE_PREFIX=${COLLECT_DIR}/optimize-matrix_scores_${BOARD}_all-TFs
COLLECT_FILES=${COLLECT_TABLE_PREFIX}_files.txt
COLLECT_TABLE=${COLLECT_TABLE_PREFIX}.tsv
COLLECT_TABLE_SORTED=${COLLECT_TABLE_PREFIX}_sorted.tsv
COLLECT_TABLE_COLUMNS=${COLLECT_TABLE_PREFIX}_columns.tsv
SELECT_TABLE_INITIAL=${COLLECT_TABLE_PREFIX}_gen0.tsv
SELECT_TABLE_FINAL=${COLLECT_TABLE_PREFIX}_gen${GENERATIONS}.tsv
ROC_TABLE_HEADER="`head -n 1 ${COLLECT_FILES} | xargs head -n 1`"
COLLECT_TABLE_HEADER=${ROC_TABLE_HEADER}"	score_table_path	matrix_file_path	result_dir	board	data_type	experiment	TF	dataset	optimization	input_matrix_type	matrix_file_name"
omga_collect_tables:
	@echo
	@echo "Collecting score tables from optimized matrice"
	@echo "	BOARD		${BOARD}"
	@echo "	TF		${TF}"
	@echo "	COLLECT_DIR	${COLLECT_DIR}"
	@mkdir -p ${COLLECT_DIR}
	@echo
	@${MAKE} _omga_collect_files

	@echo
	@echo "Merging score tables from optimize-matrix-GA"
	@echo ${COLLECT_TABLE_HEADER} > ${COLLECT_TABLE}
	@cat ${COLLECT_FILES} | while IFS= read -r f; do \
		${MAKE} _omga_add_one_table  ROC_TABLE=$${f} ; \
	done
	@echo "	COLLECT_TABLE		`wc -l ${COLLECT_TABLE}`"
	@head -n 1 ${COLLECT_TABLE} | perl -pe 's|\t|\n|g' | awk '{sum++; print sum"\t"$$0}' > ${COLLECT_TABLE_COLUMNS}
	@echo "	COLLECT_TABLE_COLUMNS	`wc -l ${COLLECT_TABLE_COLUMNS}`"

	@echo
	@echo "Sorting collected score table"
	@grep "^generation" ${COLLECT_TABLE} | sort -u > ${COLLECT_TABLE_SORTED}
	grep -v "^generation" ${COLLECT_TABLE} | awk -F'\t' '$$10==1' | sort -k 4 -r >> ${COLLECT_TABLE_SORTED}
	@echo "	COLLECT_TABLE_SORTED	`wc -l ${COLLECT_TABLE_SORTED}`"
	@echo
	@echo "	Selecting matrices before optimisation (generation=0) and after (generation=${OMGA_GENERATION})"
	@${MAKE} omga_select_matrices



_omga_collect_files:
	@echo "Getting the list of files to merge"
	@find results/${BOARD}/train -name '*_gen0-20*.tsv' > ${COLLECT_FILES}
	@echo "	COLLECT_FILES	`wc -l ${COLLECT_FILES}`"

#OPT_MATRICES=$(subst _score_table.tsv,_scored.tf,${ROC_TABLE})
OPT_MATRICES_PREFIX=$(subst _gen0-${OMGA_GENERATIONS}_score_table.tsv,,${ROC_TABLE})
_omga_add_one_table:
#	@echo "	adding table	${ROC_TABLE}"
#	@echo "	OPT_MATRICES	${OPT_MATRICES}"
	awk -F'\t' '$$10==1 {path="${ROC_TABLE}"; gsub("/", "\t", path); print $$0"\t${ROC_TABLE}\t${OPT_MATRICES_PREFIX}_gen"$$1"_scored.tf\t"path }' ${ROC_TABLE}  >> ${COLLECT_TABLE}

################################################################
## Select the top-ranking matrices per TF across all datasets
################################################################
MATRIX_TYPES=`grep -v "^generation" ${COLLECT_TABLE_SORTED} | cut -f 20 | sort -u | xargs`
omga_select_matrices:
	@for t in ${MATRIX_TYPES} ; do \
		${MAKE} omga_select_matrices_one_type MATRIX_TYPE=$${t} ; \
	done 

# Choice of the default matrix type
#MATRIX_TYPE=clust-trimmed-matrices_train-vs-rand
MATRIX_TYPE=clust-trimmed-matrices_tf-vs-others
#MATRIX_TYPE=peakmo-matrices_tf-vs-others

SELECT_TABLE_1TYPE=${COLLECT_TABLE_PREFIX}_${MATRIX_TYPE}.tsv
SELECT_TABLE_INITIAL=${COLLECT_TABLE_PREFIX}_${MATRIX_TYPE}_gen0.tsv
SELECT_TABLE_FINAL=${COLLECT_TABLE_PREFIX}_${MATRIX_TYPE}_gen${OMGA_GENERATIONS}.tsv
SELECTTED_INITIAL=${COLLECT_TABLE_PREFIX}_${MATRIX_TYPE}_gen0_topTFxEXO.tsv
SELECTTED_FINAL=${COLLECT_TABLE_PREFIX}_${MATRIX_TYPE}_gen${OMGA_GENERATIONS}_topTFxEXP.tsv
COLLECT_PSSM_FINAL_SCRIPT=${COLLECT_TABLE_PREFIX}_${MATRIX_TYPE}_gen${OMGA_GENERATIONS}_topTFxEXP_matrices_cmd.sh
COLLECTED_PSSM_FINAL=${COLLECT_TABLE_PREFIX}_${MATRIX_TYPE}_gen${OMGA_GENERATIONS}_topTFxEXP_matrices
omga_select_matrices_one_type:
	@echo
	@echo "Selecting matrices	${MATRIX_TYPE}"
	@head -n 1 ${COLLECT_TABLE_SORTED} > ${SELECT_TABLE_1TYPE}
	@awk '$$20=="${MATRIX_TYPE}"' ${COLLECT_TABLE_SORTED} >> ${SELECT_TABLE_1TYPE}
	@echo "	MATRIX_TYPE		${MATRIX_TYPE}"
	@echo "	SELECT_TABLE_1TYPE	`wc -l ${SELECT_TABLE_1TYPE}`"
	@awk -F'\t' 'BEGIN { OFS=FS } \
		NR == 1 { print $$0, "rank[TF_EXP]"; next } \
		$$1 == 0 { key =  $$17 "_" $$16 ; rank[key]++; print $$0, rank[key] }' ${SELECT_TABLE_1TYPE} > ${SELECT_TABLE_INITIAL}
	@echo "	SELECT_TABLE_INITIAL	`wc -l ${SELECT_TABLE_INITIAL}`"
	@awk -F'\t' 'BEGIN { OFS=FS } \
		NR == 1 { print $$0, "rank[TF_EXP]"; next } \
		$$1 == ${OMGA_GENERATIONS} { key =  $$17 "_" $$16 ; rank[key]++; print $$0, rank[key] }' ${SELECT_TABLE_1TYPE} > ${SELECT_TABLE_FINAL}
#	@awk -F'\t' 'BEGIN { OFS=FS } \
#		NR == 1 { print $$0, "rank[TF]"; next } \
#		$$1 == ${OMGA_GENERATIONS} { rank[$$17]++; print $$0, rank[$$17] }' ${SELECT_TABLE_1TYPE} > ${SELECT_TABLE_FINAL}
	@echo "	SELECT_TABLE_FINAL	`wc -l ${SELECT_TABLE_FINAL}`"
	@awk -F'\t' ' NR==1 {print $$0; next }; \
		$$NF <= 1 {print $$0}' ${SELECT_TABLE_INITIAL} > ${SELECTTED_INITIAL}
	@echo "	SELECTTED_INITIAL		`wc -l ${SELECTTED_INITIAL}`"
	@awk -F'\t' ' NR==1 {print $$0; next }; \
		$$NF <= 1 {print $$0}' ${SELECT_TABLE_FINAL} > ${SELECTTED_FINAL}
	@echo "	SELECTTED_FINAL		`wc -l ${SELECTTED_FINAL}`"
	@echo
	@echo "Gathering PSSMs"
	@echo "Collecting final matrices"
	awk -F'\t' 'NR==1 { next } { print "~/packages/rsat/bin/rsat retrieve-matrix -v 0 -i "$$12" -id "$$2" | perl -pe \"s/^AC  /AC  "$$17"_"substr($$16,1,1)"_/\"" }' ${SELECTTED_FINAL} > ${COLLECT_PSSM_FINAL_SCRIPT}
#	awk -F'\t' 'NR==1 { next } { print "~/packages/rsat/bin/rsat retrieve-matrix -v 0 -i "$$12" -id "$$2" | perl -pe \"s/^AC  /AC  "$$17"_"substr($$16,1,1)"_/; s/positions_/p/ ; s/dyads/d/; s/oligos_/o/; s/mkv/mv/\"" }' ${SELECTTED_FINAL} > ${COLLECT_PSSM_FINAL_SCRIPT}
	@echo "	COLLECT_PSSM_SCRIPT	${COLLECT_PSSM_FINAL_SCRIPT}"
	@echo "	COLLECTED_PSSM_FINAL	${COLLECTED_PSSM_FINAL}"
	@bash ${COLLECT_PSSM_FINAL_SCRIPT} > ${COLLECTED_PSSM_FINAL}.tf
	@echo "	COLLECTED_PSSM_FINAL .tf	${COLLECTED_PSSM_FINAL}.tf"
#	@echo "${SHELL} ${COLLECT_PSSM_FINAL_SCRIPT}"
	@${MAKE} ${COLLECTED_PSSM_FINAL}_freq.tf
	@echo "	COLLECTED_PSSM_FINAL ibis.txt	${COLLECTED_PSSM_FINAL}_freq.tf"
	@${MAKE} ${COLLECTED_PSSM_FINAL}_freq.cb
	@echo "	COLLECTED_PSSM_FINAL ibis.txt	${COLLECTED_PSSM_FINAL}_ibis.txt"
	@${MAKE} ${COLLECTED_PSSM_FINAL}_ibis.txt
	@echo "	COLLECTED_PSSM_FINAL ibis.txt	${COLLECTED_PSSM_FINAL}_ibis.txt"


%_ibis.txt : %_freq.cb
	@echo "Input\t$<"
	@echo "Output\t$@"
#	@awk '{	if ($$1 ~ /^>/) {sub("_", "\t", $$1);  sub("cluster_", "c", $$1); sub("node_", "n", $$1); sub("motifs", "m", $$1); sub("oligos_", "oli_", $$1); sub("positions_", "pos_", $$1); sub("dyads_", "dya_", $$1); sub(/\.Rep-MICHELLE/, "M", $$1); sub(/\.Rep-DIANA/, "D", $$1); sub(/ \/name.*/, "", $$1) } print }' "$<" > "$@"
	awk '{	if ($$1 ~ /^>/) { 			\
		sub("_", " ", $$1);  			\
		sub("cluster_", "c", $$1); 		\
		sub("node_", "n", $$1); 		\
		sub("motifs", "m", $$1); 		\
		sub("oligos_", "o", $$1); 		\
		sub("positions_", "p", $$1); 		\
		sub("nt", "", $$1);	 		\
		sub("mkv", "mv", $$1);			\
		sub("dyads_", "d_", $$1); 		\
		sub(/\.Rep-MICHELLE/, "M", $$1); 	\
		sub(/\.Rep-DIANA/, "D", $$1); 		\
		sub(/\/name.*/, "", $$0);		\
		} print }' $< > $@
