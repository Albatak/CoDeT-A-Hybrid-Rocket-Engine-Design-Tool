# CoDeT — Computational Design Tool for Hybrid Rocket Engines

> **CoDeT** is an advanced, modular MATLAB-based computational framework developed for the preliminary design, performance prediction, and internal ballistics simulation of hybrid rocket engines (HREs)[cite: 2, 6]. 

---

## Overview

HREs offer significant safety, cost, and operational advantages over traditional solid and liquid rockets[cite: 6]. However, predicting their performance is challenging due to the interdependent nature of oxidizer and fuel mass flow rates and the temporal evolution of the fuel port geometry (O/F shift). 

**CoDeT** automates the end-to-end design workflow—from theoretical propellant performance evaluations and grain sizing to injector fluid modeling and time-resolved combustion analysis.

---

## Software Architecture & Core Modules

CoDeT is structured into three primary computational phases:

### 1. Precombustion Analysis
* **NASA CEA Integration:** Automatically interfaces with NASA's Chemical Equilibrium with Applications (CEA) software via a MATLAB wrapper (`CEAwin`) to calculate theoretical performance parameters ($I_{sp}$, $c^*$, $C_F$, and flame temperature) across wide O/F ratio ranges.
* **Grain & Geometry Sizing:** Computes initial port diameters and grain lengths for single-port cylindrical paraffin ($C_{32}H_{66}$) fuel grains to meet target thrust and oxidizer flux specifications.
* **Injector Design:** Implements specialized flow models depending on the oxidizer choice:
  * **Single-Phase Incompressible (SPI):** For liquid oxygen (LOX).
  * **Single-Phase Compressible (SPC):** For gaseous oxygen (GOX), including choked flow checks.
  * **Homogeneous Equilibrium Model (HEM):** For self-pressurizing, two-phase fluids like nitrous oxide ($N_2O$).

### 2. Combustion Modeling
* **Time-Resolved Iteration:** Simulates engine operation over burn time at configured time steps (e.g., 100 Hz).
* **Regression Rate Law:** Models fuel consumption using empirical mass flux dependencies ($\dot{r} = a \cdot G_o^n$) tailored for high-regression liquefying fuels like paraffin wax.
* **O/F Shift Tracking:** Dynamically tracks port diameter expansion ($D_p^n = D_p^{n-1} + 2 \cdot \dot{r}^{n-1} \cdot dt$) and evaluates temporal changes in mass flow rates, thrust, and specific impulse.

### 3. Postcombustion & Validation
* Automatically logs combustion arrays into structured data tables and generates temporal performance plots.

---

## Validation & Case Studies

The tool has been rigorously benchmarked against industry standards and experimental findings:
* **RPA Validation:** Theoretical precombustion parameters were validated against commercial *Rocket Propulsion Analysis (RPA)* software across multiple expansion area ratios ($AR = 2 \text{ to } 5$).
* **Regression Rate Data:** Validated against experimental hybrid combustion literature (e.g., Chiaverini et al.).
* **Flight Hardware Correlation:** Cross-verified against design parameters and test data from the **ZEpHyR** sounding rocket (ZARM Experimental Hybrid Rocket, University of Bremen / DLR STERN project).

---

## Tech Stack
* **Language:** MATLAB
* **External Tools:** NASA CEA (Chemical Equilibrium with Applications)[cite: 21, 22]

---

## 📄 Author & Academic Context
* **Developer:** Ali Batuhan Akbey
* **Institution/Companies:** DeltaV Space Technologies, University of Bremen, Department of Production Engineering
* **Supervisors:** Prof. Dr. Marc Avila, Dr.-Ing. Peter Rickmers, Mehmet Resat Ufuk, Tim Schwenteck, Maximilian Ruhe
* **Target Application:** Developed as a Bachelor's Thesis (July 2023) later as a scientific paper draft (August 2024) to support university research groups and student rocket teams in streamlining hybrid propulsion development.
