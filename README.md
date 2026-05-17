# Simulation Framework for Bike-Sharing Rebalancing Systems

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Made with Julia](https://img.shields.io/badge/Made_with-Julia-1f425f.svg)](https://julialang.org/)

This repository contains the official simulation source code and data instances accompanying the research paper: 
**"PROJET DE RÉGULATION DES VÉHICULES PARTAGÉS"** by Adam Boulaich, Geoffroy Garibal, Adam Haissane, Sylvie Han.

## Abstract
This repository provides a discrete-event simulation framework built in Julia to evaluate vehicle rebalancing policies within bike-sharing networks. Unlike traditional models, our simulation focuses on highly asymmetric travel times and tests regulatory policies targeting specific node capacities.

## Repository Structure

* `src/`
  * `instances.jl`: Defines the 4 benchmark network topologies (Manhattan, Star, Concentric Urban, and Asymmetric Trio) including distance matrices and Poisson demand parameters.
  * `simulation.jl`: Contains the core discrete-event simulation engine built with `ConcurrentSim.jl` and `ResumableFunctions.jl`.
* `notebooks/`
  * `demo_simulation.ipynb`: A Jupyter notebook demonstrating how to run the simulations and reproduce the main figures from the paper.
* `Project.toml` & `Manifest.toml`: Julia environment files guaranteeing exact dependency versions for full reproducibility.

## Installation & Reproducibility

To replicate our findings, you need to install [Julia](https://julialang.org/downloads/) (v1.10 or higher). We highly recommend using the locked environment provided in this repository.

1. Clone this repository:
   ```bash
   git clone https://github.com/boulaichm9/PROJET-DE-REGULATION-DES-VEHICULES-PARTAGES
   cd PROJET-DE-REGULATION-DES-VEHICULES-PARTAGES
