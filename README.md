# CoDeT — Computational Design Tool for Hybrid Rocket Engines

> **CoDeT** is an advanced, modular MATLAB-based computational framework developed for the preliminary design, performance prediction, and internal ballistics simulation of hybrid rocket engines (HREs)[cite: 2, 6]. 

---

## 🚀 Overview

Hybrid rocket engines offer significant safety, cost, and operational advantages over traditional solid and liquid rockets[cite: 6]. However, predicting their performance is challenging due to the interdependent nature of oxidizer and fuel mass flow rates and the temporal evolution of the fuel port geometry (O/F shift)[cite: 12, 13, 44]. 

**CoDeT** automates the end-to-end design workflow—from theoretical propellant performance evaluations and grain sizing to injector fluid modeling and time-resolved combustion analysis[cite: 2, 24, 25].

---

## 🛠 Software Architecture & Core Modules

CoDeT is structured into three primary computational phases[cite: 25]:

### 1. Precombustion Analysis
* **NASA CEA Integration:** Automatically interfaces with NASA's Chemical Equilibrium with Applications (CEA) software via a MATLAB wrapper (`CEAwin`) to calculate theoretical performance parameters ($I_{sp}$, $c^*$, $C_F$, and flame temperature) across wide O/F ratio ranges[cite: 22, 23, 24, 26, 27].
* **Grain & Geometry Sizing:** Computes initial port diameters and grain lengths for single-port cylindrical paraffin ($C_{32}H_{66}$) fuel grains to meet target thrust and oxidizer flux specifications[cite: 27, 28].
* **Injector Design:** Implements specialized flow models depending on the oxidizer choice[cite: 15, 16]:
  * **Single-Phase Incompressible (SPI):** For liquid oxygen (LOX)[cite: 18].
  * **Single-Phase Compressible (SPC):** For gaseous oxygen (GOX), including choked flow checks[cite: 18, 19].
  * **Homogeneous Equilibrium Model (HEM):** For self-pressurizing, two-phase fluids like nitrous oxide ($N_2O$)[cite: 19].

### 2. Combustion Modeling
* **Time-Resolved Iteration:** Simulates engine operation over burn time at configured time steps (e.g., 100 Hz)[cite: 25, 42].
* **Regression Rate Law:** Models fuel consumption using empirical mass flux dependencies ($\dot{r} = a \cdot G_o^n$) tailored for high-regression liquefying fuels like paraffin wax[cite: 13, 14].
* **O/F Shift Tracking:** Dynamically tracks port diameter expansion ($D_p^n = D_p^{n-1} + 2 \cdot \dot{r}^{n-1} \cdot dt$) and evaluates temporal changes in mass flow rates, thrust, and specific impulse[cite: 27, 29, 30, 43].

### 3. Postcombustion & Validation
* Automatically logs combustion arrays into structured data tables and generates temporal performance plots[cite: 30].

---

## 📊 Validation & Case Studies

The tool has been rigorously benchmarked against industry standards and experimental findings[cite: 2]:
* **RPA Validation:** Theoretical precombustion parameters were validated against commercial *Rocket Propulsion Analysis (RPA)* software across multiple expansion area ratios ($AR = 2 \text{ to } 5$)[cite: 47].
* **Regression Rate Data:** Validated against experimental hybrid combustion literature (e.g., Chiaverini et al.)[cite: 53].
* **Flight Hardware Correlation:** Cross-verified against design parameters and test data from the **ZEpHyR** sounding rocket (ZARM Experimental Hybrid Rocket, University of Bremen / DLR STERN project)[cite: 53, 54].

---

## 💻 Tech Stack
* **Language:** MATLAB[cite: 6]
* **External Tools:** NASA CEA (Chemical Equilibrium with Applications)[cite: 21, 22]

---

## 📄 Author & Academic Context
* **Developer:** Ali Batuhan Akbey
* **Institution:** University of Bremen, Department of Production Engineering[cite: 1]
* **Supervisors:** Prof. Dr. Marc Avila, Dr.-Ing. Peter Rickmers, Tim Schwenteck, Maximilian Ruhe[cite: 1]
* **Target Application:** Developed as a Bachelor's Thesis (July 2023)[cite: 1] to support university research groups and student rocket teams in streamlining hybrid propulsion development[cite: 2].
