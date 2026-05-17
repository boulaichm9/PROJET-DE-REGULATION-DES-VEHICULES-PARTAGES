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

### 1. Clone this repository

```bash
git clone https://github.com/boulaichm9/PROJET-DE-REGULATION-DES-VEHICULES-PARTAGES.git
cd PROJET-DE-REGULATION-DES-VEHICULES-PARTAGES
```

### 2. Instantiate the Julia environment

Open the Julia REPL in the project root directory and run:

```bash
julia --project=.
```

Then, inside the Julia REPL:

```julia
using Pkg
Pkg.instantiate()
```
## 📊 Running the Experiments

### Option A: Using the Interactive Jupyter Notebook (Recommended)

The easiest way to view plots and explore the networks interactively is through the notebook.

Launch Jupyter from your terminal:

```bash
jupyter notebook
```

Then:

1. Navigate to the `notebooks/` folder.
2. Open `demo_simulation.ipynb`.
3. Run the cells.

The notebook is pre-configured to go up one directory level (`Pkg.activate("..")`) to find and use your project environment seamlessly.

---

### Option B: Running via a Julia Script

You can also run experiments directly from a standalone script or terminal session at the root of your project directory:

```julia
using Pkg
Pkg.activate(".") # Activates the local project environment

# Include your source files
include("src/instances.jl")
include("src/simulation.jl")

using Plots

# 1. Load the Manhattan instance parameters
# Note: manhattan() unpacks 9 variables (ignoring 'pos' for the simulation function)
S, N, K, x, pos, lambda, sigma, t_velo, t_camion = manhattan()

# 2. Run the discrete-event simulation for 50,000 time units
sim_time = 50000.0
metrics = run_simulation(
    S, N, K, x,
    lambda, sigma,
    t_velo, t_camion,
    sim_time
)

# 3. Print summary metrics
println("--- Simulation Complete ---")
println("Total successful user trips: ", metrics[:k])
println("Total failed bike lookups:   ", metrics[:echecs])

# 4. Generate and save the performance plot
p = plot(
    metrics[:liste_t],
    metrics[:liste_k],
    title = "Bike-Sharing Rebalancing Performance (Manhattan)",
    xlabel = "Simulation Time",
    ylabel = "Satisfied Users (k)",
    label = "k(t)",
    linewidth = 2,
    color = :blue
)

savefig(p, "manhattan_performance.png")

println("Performance plot saved as 'manhattan_performance.png'")
```

---

## ✒️ Citation

If you utilize this framework or the asymmetric simulation topologies in your academic work, please cite our paper:

```bibtex
@article{sharedvehicles2026,
  title   = {Projet de régulation des véhicules partagés},
  author  = {Adam Boulaich, Geoffroy Garibal, Adam Haissane, Sylvie Han},
  year    = {2026},
}
```
