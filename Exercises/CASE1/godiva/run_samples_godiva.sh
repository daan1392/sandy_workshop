#!/usr/bin/env bash
set -euo pipefail

SMP=20
PWD=`pwd`
DATA_FOLDER=${PWD}/../../../openmc_data/jeff40_xs
NPROC=1   # number of parallel jobs

export DATA_FOLDER

run_sample() {
    local i=$1

    DIR="SMP${i}"
    mkdir -pv "$DIR"

    cp -v geometry.xml "$DIR/geometry.xml"
    cp -v materials.xml "$DIR/materials.xml"

    # CHANGE SEED
    SEED=$((RANDOM + $$ + i))
    echo "changing seed to ${SEED} in $DIR/settings.xml ..."
    sed "s|<seed>1</seed>|<seed>${SEED}</seed>|" settings.xml > "$DIR/settings.xml"

    echo "export OPENMC_CROSS_SECTIONS=${DATA_FOLDER}/cross_sections_${i}.xml ..."
    export OPENMC_CROSS_SECTIONS="${DATA_FOLDER}/cross_sections_${i}.xml"
    export OMP_NUM_THREADS=1

    cd "$DIR" || exit 1

    echo "running openmc for SMP=${i} ..."
    openmc

    # The name is 'statepoint.100.h5' because we use 100 cycles, otherwise change it
    mv -v statepoint.100.h5 "../statepoint.100_${i}.h5"

    cd ..

    rm -rv "$DIR"
}

export -f run_sample

seq 0 $((SMP - 1)) | xargs -P ${NPROC} -I {} bash -c 'run_sample "$@"' _ {}
