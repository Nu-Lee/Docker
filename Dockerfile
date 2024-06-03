# Base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget bzip2 git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Anaconda3
RUN wget https://repo.anaconda.com/archive/Anaconda3-2023.03-Linux-x86_64.sh -O anaconda.sh && \
    bash anaconda.sh -b -p /opt/anaconda3 && \
    rm anaconda.sh

# Set PATH for Anaconda
ENV PATH=/opt/anaconda3/bin:$PATH

# Create a Python 3.6 environment and activate it
RUN conda create -y -n py36 python=3.6 && \
    echo "source activate py36" > ~/.bashrc

# Install required Python packages in the py36 environment
RUN /opt/anaconda3/bin/conda run -n py36 pip install sphinx_rtd_theme breathe myst-parser ephem AegeanTools numpy mwa_hyperbeam && \
    /opt/anaconda3/bin/conda run -n py36 pip install git+https://github.com/MWATelescope/mwa_pb.git && \
    /opt/anaconda3/bin/conda run -n py36 pip install git+https://github.com/Sunmish/skymodel.git && \
    /opt/anaconda3/bin/conda run -n py36 pip install git+https://gitlab.com/Sunmish/flux_warp.git && \
    /opt/anaconda3/bin/conda run -n py36 pip install git+https://github.com/nhurleywalker/fits_warp.git

# Install other dependencies
RUN apt-get update && \
    apt-get install -y \
    casacore-dev libgsl-dev libhdf5-dev \
    libfftw3-dev libboost-dev \
    libboost-date-time-dev libboost-filesystem-dev \
    libboost-program-options-dev libboost-system-dev \
    libcfitsio-dev cmake g++ pkg-config \
    doxygen libboost-all-dev libblas-dev \
    liblapack-dev libxm12-dev libgtkmm-3.0-dev \
    wcslib-dev xvfb aoflagger && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install EveryBeam
RUN git clone --recursive -j4 https://git.astron.nl/RD/EveryBeam.git && \
    cd EveryBeam && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/EveryBeam/ .. && \
    make -j $(nproc) && make install

# Install WSCLEAN
RUN git clone -b master https://gitlab.com/aroffringa/wsclean.git && \
    cd wsclean && \
    mkdir build && cd build && \
    cmake .. && \
    make -j $(nproc) && make install

# Install CASA
RUN wget https://casa.nrao.edu/download/distro/casa/release/rhel/casa-6.6.3-22-py3.8.el8.tar.xz && \
    mkdir -p /usr/local/bin/CASA && \
    tar -xvf casa-6.6.3-22-py3.8.el8.tar.xz -C /usr/local/bin/CASA && \
    cp -r /usr/local/bin/CASA/casa-6.6.3-22-py3.8.el8/data/* /var/lib/casacore/data/ && \
    echo 'export PATH=$PATH:/usr/local/bin/CASA/casa-6.6.3-22-py3.8.el8/bin' >> /etc/profile

# Install CARTA
RUN add-apt-repository ppa:cartavis-team/carta -y && \
    apt-get update && \
    apt-get install -y carta

# Set default command
CMD ["/bin/bash"]
