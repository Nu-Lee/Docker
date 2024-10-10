# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

COPY ./piip /root/piip/
COPY ./mwa-reduce /app/mwa-reduce/

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    git vim wget curl sudo cmake g++ pkg-config \
    python3-pip xvfb casacore-dev libcfitsio-dev wcslib-dev \
    libboost-all-dev libgsl-dev libhdf5-dev libfftw3-dev \
    libblas-dev liblapack-dev libxml2-dev libgtkmm-3.0-dev \
    libpython3-dev python3-distutils doxygen python3-sphinx \
    libboost-date-time-dev libboost-filesystem-dev \
    libboost-program-options-dev libboost-system-dev \
    casacore-dev software-properties-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:cartavis-team/carta -y && \
    apt-get update && apt-get install -y carta

WORKDIR /app
# Install Python dependencies
RUN pip3 install --upgrade pip && \
    pip3 install sphinx_rtd_theme breathe myst-parser ephem AegeanTools numpy notebook

# Clone and build WSCLEAN
RUN git clone -b master https://gitlab.com/aroffringa/wsclean.git && \
    cd wsclean && mkdir build && cd build && cmake .. && make -j$(nproc) && make install

# Install EveryBeam
RUN git clone --recursive https://git.astron.nl/RD/EveryBeam.git && \
    cd EveryBeam && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr/local/EveryBeam/ .. && make install

# CASA installation
RUN wget https://casa.nrao.edu/download/distro/casa/release/rhel/casa-6.6.3-22-py3.8.el8.tar.xz && \
    tar -xvf casa-6.6.3-22-py3.8.el8.tar.xz && \
    rm -rf casa-6.6.3-22-py3.8.el8.tar.xz

# Set environment for CASA
ENV PATH="$PATH:/app/casa-6.6.3-22-py3.8.el8/bin"
ENV PATH="$PATH:/app/mwa-reduce/build"

# Install PIIP (MWA Telescope tools)
RUN git clone https://github.com/MWATelescope/mwa_pb.git && \
    cd mwa_pb/mwa_pb/data && wget http://ws.mwatelescope.org/static/mwa_full_embedded_element_pattern.h5 && \
    cd ../../ && python3 setup.py install

# Install SkyModel and related tools
RUN git clone https://github.com/Sunmish/skymodel.git && \
    cd skymodel && pip install . && cd .. && \
    git clone https://gitlab.com/Sunmish/flux_warp.git && cd flux_warp && pip3 install . && \
    cd .. && git clone https://github.com/nhurleywalker/fits_warp.git && cd fits_warp && pip3 install .

WORKDIR /app/mwa-reduce
# mwa-reduce Installation
RUN mkdir build
WORKDIR /app/mwa-reduce/build
RUN cmake .. && make

# Open necessary ports (Jupyter: 8888, CASA/CARTA: 3000, 4000)
EXPOSE 8888 3002 4000

# Set working directory for Jupyter Notebook
WORKDIR /root

# Set up Jupyter Notebook to run on container start
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root", "--no-browser"]

