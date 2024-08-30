#!/bin/bash\n
#SBATCH -o ${SLURM_OUT}
#SBATCH --mem=16G

TMPDIR=/shared/projects/ibis_challenge/IBIS_2024/tmp/
TMP=${TMPDIR}
TEMP=${TMPDIR}
mkdir -p ${TMPDIR}
export TMPDIR TMP TEMP

