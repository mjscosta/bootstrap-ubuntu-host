#!/bin/bash


if [ -z "$1" ]; then
    _CONDA_VER="4.5.4"
else
    _CONDA_VER=$1
fi

# Get Miniconda3 and make it the main Python interpreter
if [ ! -d /opt/conda ]; then
    curl -s -L https://repo.continuum.io/miniconda/Miniconda3-${_CONDA_VER}-Linux-x86_64.sh > miniconda.sh && \
    openssl md5 miniconda.sh | grep a946ea1d0c4a642ddf0c3a26a18bb16d && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    touch /opt/conda/conda-meta/pinned && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    export PATH=/opt/conda/bin:$PATH && \
    conda config --set show_channel_urls True && \
    conda config --append channels conda-forge && \
    conda config --append channels defaults && \
    conda update --all --yes && \
    conda clean -tipy
fi

