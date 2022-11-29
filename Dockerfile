FROM amazonlinux:2
RUN yum update -y

# Linux Packages
# ----------------------------------------
RUN yum install -y \
        shadow-utils.x86_64 \
        zip unzip \
        gcc-c++ \
        make \
        openssl-devel \
        zlib-devel \
        readline-devel \
        git \
        blas blas-devel \
        lapack lapack-devel \
        wget \
        zsh \
        which \
        tar

# Miniconda & Python
# ----------------------------------------
ENV CONDA_DIR=/opt
ENV ENV_NAME=myenv
ENV PYVERSION=3.9
RUN mkdir -p "${CONDA_DIR}"
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O \
        "$CONDA_DIR/miniconda.sh"
RUN bash "$CONDA_DIR/miniconda.sh" -b -u -p "$CONDA_DIR/miniconda"

# Conda environment
# ----------------------------------------
RUN source "$CONDA_DIR/miniconda/bin/activate" \
        && conda create -y -n $ENV_NAME python=$PYVERSION \
        && conda activate $ENV_NAME

# Python packages
# ----------------------------------------
COPY requirements.txt /opt
RUN ${CONDA_DIR}/miniconda/envs/${ENV_NAME}/bin/pip install -r /opt/requirements.txt


# AWS CLI 
# ---------------------
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install


# Entrypoint
# ---------------------
COPY run_simulation.sh /tmp/run_simulation.sh
COPY simulations.txt /tmp/simulations.txt
COPY myscript.py /tmp/myscript.py
RUN chmod +x /tmp/run_simulation.sh
ENTRYPOINT /tmp/run_simulation.sh
