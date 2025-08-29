# Adaptive Noise Canceller (ANC) — MATLAB (LMS & RLS)

---

## 1) Overview

This project implements and compares **Least Mean Squares (LMS)** and **Recursive Least Squares (RLS)** adaptive filters for speech denoising under **white**, **pink**, and **brown** noise scenarios. Step size (**μ**), forgetting factor (**λ**), and **filter order** are tuned for stable convergence.

* **Scenario:** Synthetic colored noise is added to a clean/denoised base signal (from NI-provided material). The algorithms are evaluated for **noise reduction (ΔSNR)**, **adaptation speed**, and **computational efficiency** (execution time).

* **Artifacts:** Convergence/MSE analyses and stability notes across μ/λ sweeps.

---

## 2) Quick Start


1. **Requirements:** MATLAB. Signal Processing Toolbox helpful.
2. **Data:** Place base speech/denoised audio and noise reference WAVs under `./`.
3. **Run.**

---

## 3) Methodology

### 3.1 ANC Setup

* Start from a **clean/denoised** speech signal (from NI material).
* Add **white**, **pink**, or **brown** noise.
* Feed the adaptive filter with the **noisy signal** (primary) and a **reference** that is correlated with the added noise (e.g., generated noise stream or a filtered copy). The filter output is subtracted from the primary to form the **error** (the denoised estimate).

### 3.2 LMS (stochastic gradient)

* **Pros:** Simple, $\mathcal{O}(M)$ per sample, robust.
* **Cons:** Convergence depends on $\mu$ and input statistics; slower than RLS.

### 3.3 RLS (least-squares recursion)

* **Pros:** Very fast convergence.
* **Cons:** Higher complexity (≈$\mathcal{O}(M^2)$), sensitive to numerical settings.

> **Filter order (M):** Choose based on expected impulse response length of the noise path / correlation structure. Larger **M** captures more correlation but increases cost and risk of overfitting/instability.

---

## 4) Evaluation

### 4.1 Metrics

* **Noise Reduction (ΔSNR in dB):** $\Delta\mathrm{SNR} = \mathrm{SNR}_{\text{out}} - \mathrm{SNR}_{\text{in}}$.
* **Adaptation Speed:** iterations/samples to reach a target fraction of final MSE.
* **Computational Efficiency:** elapsed time (s) per run.

### 4.2 Noise Types

* **White:** flat spectrum.
* **Pink:** $1/f$ spectrum; more low-frequency power.
* **Brown (Brownian):** $1/f^2$ spectrum; even stronger low-frequency content.

---

## 5) Parameter Tuning & Stability Notes

* **LMS step size (μ):** typically $0 < \mu < 1 / (\alpha \cdot P_x)$, where $P_x$ is input power and $\alpha$ depends on **M**. Start small; increase until near-divergence, then back off.
* **RLS forgetting (λ):** $0.95 \le \lambda \le 1$. Closer to **1** emphasizes long-term data (smoother but slower to track nonstationarity).
* **Filter order (M):** sweep **e.g., 16–256**; monitor ΔSNR/MSE vs. runtime.


---

## 6) Results (Placeholders to fill)


### 6.1 ΔSNR (dB) — LMS vs RLS
<img width="459" height="425" alt="SNR_lambda1" src="https://github.com/user-attachments/assets/3d1b5bb0-c646-4ea1-9483-b2dd83f3d5d0" />


**Adaptation Speed:**

<img width="457" height="451" alt="adaptationSpeed" src="https://github.com/user-attachments/assets/9084050c-7b54-443f-9b64-58d0ac9bc4cc" />


**Runtime (s) per run (MATLAB `tic/toc`):**

<img width="431" height="161" alt="computationalEfficiency" src="https://github.com/user-attachments/assets/55667ee9-68a0-49d2-b89a-e4b782f83db7" />



### 6.2 Figures

* **Waveforms:** noisy input vs. ANC outputs
* 
<img width="563" height="368" alt="outputs" src="https://github.com/user-attachments/assets/4d1ddee3-b78a-464f-90ad-173fd96f008b" />

<img width="451" height="346" alt="NI" src="https://github.com/user-attachments/assets/eff64a49-d038-4cf9-a1cd-9db1f7333835" />

<img width="331" height="304" alt="rls" src="https://github.com/user-attachments/assets/64dfc7c1-e8a9-4133-b8a3-3a0f7f5b84e4" />


---


## 7) Limitations & Future Work

* **RLS**: higher computational cost and numerical sensitivity.
* **LMS**: slower convergence under colored noise; may require normalization (NLMS) for robustness.
* **Future:** NLMS/APA variants, time-varying λ (RLS), multi-mic/reference experiments, and real-world recordings.

---

## 8) Acknowledgments

* NI-provided denoised speech material used as the base for corruption and testing.
* MATLAB custom implementations compared against MATLAB built-ins for verification.

---

