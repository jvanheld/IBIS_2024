################################################################
## Motif discovery for the IBIS challenge 2024
##
## Participants: Jacques van Helden and Bruno Contreiras Moreira

list_targets:
	@echo
	@echo "Targets"
	@echo "	targets	list targets"
	@echo "	param	list parameters"
	@echo

param:
	@echo
	@echo "Parameters"
#	@echo "	DISCIPLINE	${DISCIPLINE}"
	@echo "	BOARD		${BOARD}"
	@echo "	DATA_TYPE	${DATA_TYPE}"
	@echo "	TF		${TF}"
	@echo

DISCIPLINE=WET
BOARD=leaderboard
DATA_TYPE=CHS
TF=GABPA

