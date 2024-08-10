################################################################
## Computer-specific settings
##
## Local configuration for Jacques van Helden's laptop

## Use RSAT package installed on the laptop
RSAT_CMD=rsat
MOTIFDB_DIR=~/packages/rsat/motif_databases ## Local RSAT installation

## Use docker container
DOCKER_RELEASE=eeadcsiccompbio/rsat:20240808
#RSAT_CMD=docker run -v $$PWD:/home/rsat_user -v $$PWD/results:/home/rsat_user/out ${DOCKER_RELEASE} rsat
#MOTIFDB_DIR=/packages/rsat/public_html/motif_databases # in the Docker container

SCHEDULER=time
RUNNER=bash
RUNNER_HEADER="\#!/bin/bash"
SLURM_OUT=


