FROM mcr.microsoft.com/azureml/openmpi4.1.0-ubuntu20.04:20240304.v1

WORKDIR /

# Define Envrionment name YAML FILE NAME
ARG ENV_NAME=PHMGearbox
ARG ENV_YAML=dev_environment.yaml

ENV CONDA_PREFIX=/azureml-envs/$ENV_NAME
ENV CONDA_DEFAULT_ENV=$CONDA_PREFIX
ENV PATH=$CONDA_PREFIX/bin:$PATH

# This is needed for mpi to locate libpython
ENV LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# added to allow local functions 
ENV PYTHONPATH=${PYTHONPATH}:/workspaces/$ENV_NAME

# # Create conda environment
# COPY ${ENV_YAML} .
# RUN conda env create -p $CONDA_PREFIX -f ${ENV_YAML} -q && \
#     rm ${ENV_YAML} && \
#     conda run -p $CONDA_PREFIX pip cache purge && \
#     conda clean -a -y

# # Copy environment.yml (if found) to a temp location so we update the environment. Also
# # copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
# COPY environment.yml* .devcontainer/noop.txt /tmp/conda-tmp/
# RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
#     && rm -rf /tmp/conda-tmp

# Copy environment YAML file
COPY ${ENV_YAML} .

# Check if the Conda environment exists at the specified path
RUN if conda info --envs | grep -q "^#.*${CONDA_PREFIX}$"; then \
        echo "Conda environment already exists. Updating..."; \
        conda env create -p $CONDA_PREFIX -f ${ENV_YAML} -q; \
    else \
        echo "Conda environment does not exist. Creating..."; \
        conda env create -p $CONDA_PREFIX -f ${ENV_YAML} -q; \
    fi && \
    # Clean up
    rm ${ENV_YAML} && \
    conda run -p $CONDA_PREFIX pip cache purge && \
    conda clean -a -y
# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>