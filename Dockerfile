# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

# Install essential packages
RUN apt-get update && apt-get install -y \
    git \
    vim \
    cmake \
    build-essential \
    pkg-config \
    casacore-data casacore-dev \
    libblas-dev liblapack-dev \
    python3 \
    libpython3-dev \
    libboost-date-time-dev libboost-test-dev \
    libboost-program-options-dev libboost-system-dev libboost-filesystem-dev \
    libcfitsio-dev \
    libfftw3-dev \
    libgsl-dev \
    libhdf5-dev \
    libopenmpi-dev \
    python3-dev python3-numpy \
    python3-sphinx \
    python3-pip \
    ppa-purge

# Set the working directory to /tmp
WORKDIR /tmp

# Clone the wsclean repository from GitLab
RUN git clone https://gitlab.com/aroffringa/wsclean.git

# Install Python packages
WORKDIR /tmp/wsclean/external
RUN pip3 install pytest matplotlib pandas

# Clone required Git repositories
RUN git clone https://gitlab.com/ska-telescope/sdp/ska-sdp-func-radler.git \
    && git clone https://github.com/pybind/pybind11.git \
    && git clone https://git.astron.nl/RD/schaapcommon.git \
    && git clone https://gitlab.com/aroffringa/aocommon.git

# Rename radler directory
RUN mv ska-sdp-func-radler/ radler/

# Install GCC 8
RUN apt-get update && apt-get install -y gcc-8 g++-8 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 40 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 40

# Apply code modifications
WORKDIR /tmp/wsclean/external/schaapcommon/src/h5parm
RUN sed -i -e '258s/^/\/\/ /' -e '259s/^/\/\/ /' -e '260s/^/\/\/ /' -e '428s/^/\/\/ /' soltab.cc

# Build and install wsclean
WORKDIR /tmp/wsclean
RUN mkdir build && cd build && cmake .. && make -j `nproc` && make install

# Set the working directory back to /root
WORKDIR /root/
