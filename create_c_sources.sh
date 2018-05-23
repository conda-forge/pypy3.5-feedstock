#!/usr/bin/env bash

# Use the same miniconda prefix as used to generate the .travis file
export PYPY_USESSION_DIR=/tmp/pypy3.5-usession
export CONDA_FOLDER=/tmp/miniconda
export PYPY_C_BUILD_TAR_FILE=./pypy3-v6.0.0-c-sources.tgz

rm -rf $CONDA_FOLDER $PYPY_USESSION_DIR

export CONFIG=osx_

echo "Installing a fresh version of Miniconda."
MINICONDA_URL="https://repo.continuum.io/miniconda"
MINICONDA_FILE="Miniconda3-latest-MacOSX-x86_64.sh"
curl -L -O "${MINICONDA_URL}/${MINICONDA_FILE}"
bash $MINICONDA_FILE -b -p $CONDA_FOLDER -u

echo ""
echo "Configuring conda."
source $CONDA_FOLDER/bin/activate root
conda config --remove channels defaults
conda config --add channels defaults
conda config --add channels conda-forge
conda config --set show_channel_urls true
conda install --yes --quiet conda-forge-ci-setup=1

# If we won't use a separate bash, conda will force-exit because of MacOSX10.9.sdk.
bash -c "source run_conda_forge_build_setup"

echo "Staring build."
set -x
mkdir -p $PYPY_USESSION_DIR

# Only create C source files.
export PYPY_CUSTOM_GOAL=source

# Ignore the error (the build should fail because pypy3-c was not created.
conda build ./recipe -m ./.ci_support/${CONFIG}.yaml --no-build-id || true

(cd $PYPY_USESSION_DIR && tar -czf $CONDA_FOLDER/$PYPY_C_BUILD_TAR_FILE .)

mv $CONDA_FOLDER/$PYPY_C_BUILD_TAR_FILE ./$PYPY_C_BUILD_TAR_FILE