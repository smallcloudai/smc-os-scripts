#FROM nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04
FROM nvidia/cuda:11.5.0-cudnn8-devel-ubuntu20.04
#FROM nvidia/cuda:11.4.2-devel-ubuntu20.04
# works 11.4 11.5
# bus error 11.6 (with driver 515.43.04) -- but check again
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y software-properties-common wget
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-11 main"
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    git-lfs \
    bzip2 \
    openssh-server \
    rsyslog \
    mc \
    htop \
    tmux \
    vim \
    rsync \
    inetutils-ping net-tools psmisc telnet \
    p7zip \
    python3 python3-pip \
    mpich libmpich-dev \
    autotools-dev automake build-essential cmake \
    clang-11 lldb-11 lld-11 clangd-11 \
    strace \
    m4 flex bison \
    swig \
    pkg-config \
    libaio-dev \
    libnuma1 \
    libltdl-dev \
    pciutils libpci3 \
    libnl-3-dev \
    libusb-1.0-0 \
    libfuse2 \
    lsof \
    chrpath \
    ethtool \
    kmod \
    tcl tk \
    udev \
    libnl-route-3-dev libmnl0 \
    debhelper \
    dpatch \
    graphviz \
    libncurses5-dev libncursesw5-dev \
    && rm -rf /var/lib/{apt,dpkg,cache,log}


RUN adduser --disabled-password --gecos '' --ingroup adm --shell /bin/bash --uid 1337 user && chown -R user:adm /home/user
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
# for MPI_HOME
RUN mkdir /usr/mpi_home && ln -s /usr/include/x86_64-linux-gnu/mpich /usr/mpi_home/include && ln -s /usr/lib/x86_64-linux-gnu/ /usr/mpi_home/lib
ENV HOME=/home/user
WORKDIR /home/user

RUN chmod 700 /home/user && mkdir /home/user/.ssh && chown user:adm /home/user/.ssh && chmod 700 /home/user/.ssh
RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config
RUN echo "GlobalKnownHostsFile /etc/ssh/known_hosts" >> /etc/ssh/ssh_config
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/no_password.conf
RUN mkdir /run/sshd
RUN touch /home/user/.ssh/authorized_keys && chmod 600 /home/user/.ssh/authorized_keys && chown -R user:adm /home/user
RUN echo "export PATH=~/.local/bin:/usr/local/cuda/bin:\$PATH" > /etc/profile.d/50-smc.sh
ENV PATH=/home/user/.local/bin:$PATH

RUN wget --quiet https://content.mellanox.com/ofed/MLNX_OFED-5.6-1.0.3.3/MLNX_OFED_LINUX-5.6-1.0.3.3-ubuntu20.04-x86_64.tgz && \
    tar -xvf MLNX_OFED_LINUX-5.6-1.0.3.3-ubuntu20.04-x86_64.tgz && \
    MLNX_OFED_LINUX-5.6-1.0.3.3-ubuntu20.04-x86_64/mlnxofedinstall --user-space-only --without-fw-update -q && \
    rm -rf MLNX_OFED_LINUX-5.6*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

USER user
RUN pip install --no-cache-dir mpi4py wandb matplotlib IPython blobfile cloudpickle filelock numpy redis boostedblob tokenizers py-spy pytest pandas && \
    pip install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113

RUN mkdir from-source
RUN cd from-source && git clone https://github.com/NVIDIA/nccl-tests && make MPI=1 MPI_HOME=/usr/mpi_home/ -j8 -C nccl-tests
RUN cd from-source && git clone https://github.com/openai/triton && pip install -e triton/python
RUN cd from-source && git clone https://github.com/Syllo/nvtop && cd nvtop && cmake . --install-prefix=/usr && make && sudo make install

COPY sleep_script /home/user/sleep_script
USER root
CMD ["/bin/bash", "/home/user/sleep_script"]
