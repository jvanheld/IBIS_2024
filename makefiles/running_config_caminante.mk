################################################################
## Computer-specific settings
##
## Local configuration for Jacques van Helden's laptop


################################################################
## Running configuration
################################################################
SCHEDULER=time
RUNNER=bash
RUNNER_HEADER="\#!/bin/bash"

################################################################
## RSAT confiiguration
################################################################

## Choose RSAT mode : local or docker
RSAT_MODE=docker

ifeq (${RSAT_MODE}, local)

## Use RSAT package installed on the laptop
RSAT_CMD=~/packages/rsat/bin/rsat
MOTIFDB_DIR=~/packages/motif_databases

else ifeq (${RSAT_MODE}, docker)
## Use docker container
DOCKER_RELEASE=eeadcsiccompbio/rsat:2024-08-28c
RSAT_CMD=docker run -v $$PWD:/home/rsat_user -v $$PWD/results:/home/rsat_user/out ${DOCKER_RELEASE} rsat
MOTIFDB_DIR=/packages/rsat/public_html/motif_databases

endif

################################################################
## Configuration for optimize-matrix-GA
################################################################
THREADS=10
OMGA_DIR=/Users/jvanheld/no_backup/rsat_github/optimize-matrix-GA
OMGA_PATH=${OMGA_DIR}/optimize-matrix-GA.py
OMGA_PYTHON_PATH=${OMGA_DIR}/venv/Downloads/bin/python
OMGA_CMD_PREFIX=${OMGA_PYTHON_PATH} ${OMGA_PATH}


