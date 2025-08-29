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

<img width="459" height="425" alt="SNR_lambda1" src="https://github.com/user-attachments/assets/40d6f789-2e4d-4d2d-a3bc-297908210856" />


**Adaptation Speed:**

<img width="457" height="451" alt="adaptationSpeed" src="https://github.com/user-attachments/assets/e23f48b1-e331-457c-92b8-ef541d8bb963" />


**Runtime (s) per run (MATLAB `tic/toc`):**

<img width="431" height="161" alt="computationalEfficiency" src="https://github.com/user-attachments/assets/c161f85c-5dee-421b-a448-d9d4388e50dd" />



### 6.2 Figures

* **Waveforms:**
* Graphically displayed the original denoised signal, noise reference signal, the noised signal, and the filtered outputs using both LMS and RLS algorithms, all together.

<img width="563" height="368" alt="outputs" src="https://github.com/user-attachments/assets/7f4b8685-f316-4a23-9618-56f39d859e22" />

* NI Denoised Signal - Noise Reference: White Noise - Noisy Signal
<img width="451" height="346" alt="NI" src="https://github.com/user-attachments/assets/69f15f9a-4c10-42e0-b0a0-e58f81d6d568" />

* Filtered signals (RLS & LMS)
<img width="331" height="304" alt="rls" src="https://github.com/user-attachments/assets/a372be44-49ec-4cd8-886d-4d297c20d7e0" />


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

