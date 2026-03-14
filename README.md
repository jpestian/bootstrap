# Research Workstation Bootstrap

This repository bootstraps a reproducible research workstation environment.

It is designed to quickly configure a new machine with the same directory
structure, software stack, and development environment used for NLP and
machine learning research.

The bootstrap process is idempotent and safe to run multiple times.


## What the bootstrap script does

The `bootstrap.sh` script performs the following steps:

1. Creates the standard research directory structure
2. Installs core Linux utilities
3. Installs Miniconda if it is not already present
4. Restores the research Conda environment
5. Installs additional system packages
6. Configures Git
7. Creates an SSH key if needed
8. Clones required research repositories
9. Prints a system summary


## Standard directory layout

The bootstrap script creates the following structure in the user's home directory:

~/projects
~/research
~/research/datasets/raw
~/research/datasets/processed
~/research/embeddings
~/research/models/trained
~/research/models/checkpoints
~/artifacts
~/artifacts/manifolds
~/artifacts/clustering
~/artifacts/visualizations
~/containers
~/containers/defs
~/containers/images
~/containers/experiments
~/notebooks
~/papers
~/scripts
~/config
~/tmp


This layout separates:

projects   → Git repositories  
research   → datasets and models  
artifacts  → experiment outputs  
containers → container definitions  
scripts    → operational utilities  
config     → environment configuration  


## Usage

Clone the repository and run the bootstrap script:

git clone https://github.com/jpestian/bootstrap.git  
cd bootstrap  
bash bootstrap.sh


Optional machine profile:

bash bootstrap.sh workstation  
bash bootstrap.sh server  
bash bootstrap.sh nas  


## Configuration files

Configuration files are located in:

config/

Important files:

config/nlp_core_environment.yml  
config/installed_packages_apt.txt  


These files define the Python environment and additional system packages.


## Typical workflow

Bootstrap a new machine:

git clone https://github.com/jpestian/bootstrap.git  
cd bootstrap  
bash bootstrap.sh  


This restores the entire research environment.


## Notes

Large datasets, artifacts, and model checkpoints are intentionally excluded
from Git using `.gitignore`.

These should be stored in:

~/research  
~/artifacts  

or on a NAS or remote storage system.


## Author

John Pestian
