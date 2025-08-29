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
* **Cons:** Higher complexity, sensitive to numerical settings.

> **Filter order (M):** Choose based on expected impulse response length of the noise path / correlation structure. Larger **M** captures more correlation but increases cost and risk of overfitting/instability.

---

## 4) Evaluation

### 4.1 Metrics

* **Noise Reduction (ΔSNR in dB):** ΔSNR = SNR(out) - SNR(in).
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

### 6) Output Signals

**Waveforms:**
- Graphically displayed the original denoised signal, noise reference signal, the noised signal, and the filtered outputs using both LMS and RLS algorithms, all together:

<img width="563" height="368" alt="outputs" src="https://github.com/user-attachments/assets/7f4b8685-f316-4a23-9618-56f39d859e22" />

**NI Denoised Signal - Noise Reference: White Noise - Noisy Signal:**
<img width="451" height="346" alt="NI" src="https://github.com/user-attachments/assets/69f15f9a-4c10-42e0-b0a0-e58f81d6d568" />

**Filtered signals (RLS & LMS):**
<img width="331" height="304" alt="rls" src="https://github.com/user-attachments/assets/a372be44-49ec-4cd8-886d-4d297c20d7e0" />

## 7) Adaptive Filter Performance Analysis


**ΔSNR (dB) — LMS vs RLS:**

<img width="459" height="425" alt="SNR_lambda1" src="https://github.com/user-attachments/assets/40d6f789-2e4d-4d2d-a3bc-297908210856" />

- The experiment commenced by adding white noise to the denoised signal from National Instruments (NI) with the forgetting factor λ set to 1. Under these conditions, the RLS algorithm achieved a significant Signal-to-Noise Ratio (SNR) improvement of 23.67 dB, outperforming the LMS algorithm, which recorded an SNR enhancement of 18.53 dB. This outcome highlights the superior effectiveness of the RLS algorithm in reducing white noise. 

- Subsequently, pink noise was introduced to the denoised signal. The RLS algorithm continued to demonstrate its advantage by attaining an SNR improvement of 18.54 dB, compared to 8.70 dB achieved by LMS. When brown noise was added, RLS still outperformed LMS, achieving an SNR improvement of 15.22 dB versus 4.82 dB for LMS. 

- Across all three types of noise -white, pink, and brown- the RLS algorithm consistently provided greater SNR improvements compared to the LMS algorithm. However, the magnitude of SNR enhancement decreased progressively from white noise to pink noise to brown noise. This trend can be attributed to the inherent spectral characteristics of each noise type.

**Adaptation Speed:**

<img width="457" height="451" alt="adaptationSpeed" src="https://github.com/user-attachments/assets/e23f48b1-e331-457c-92b8-ef541d8bb963" />

- After adding different types of noise to each half of the signal to simulate environment changing, it was observed that with the forgetting factor λ=1, the RLS algorithm required a longer time to stabilize compared to the LMS algorithm. Additionally, the number of instances where the RLS squared error exceeded the LMS squared error was higher than the reverse, as depicted in the "Comparison of Error Occurrences" chart. The Average Squared Error Post-Change for Custom RLS was also greater than that for Custom LMS, further indicating the superior performance of LMS under these conditions. 

**Runtime (s) per run (MATLAB `tic/toc`):**

<img width="431" height="161" alt="computationalEfficiency" src="https://github.com/user-attachments/assets/c161f85c-5dee-421b-a448-d9d4388e50dd" />

- The LMS algorithm demonstrates markedly higher computational efficiency compared to the RLS algorithm, both in built-in and custom implementations. This efficiency is primarily due to the LMS's simpler computational structure, which involves fewer and less complex operations. On the other hand, the RLS algorithm, despite its potential advantages in adaptation speed and noise reduction under optimal parameter settings, incurs a higher computational burden that results in longer execution times.


---


## 8) Choosing the Right Algorithm

The selection between RLS and LMS can be guided by the specific needs of the application: 

* RLS is advantageous when: 
- High SNR Improvement is essential, particularly in environments with complex or highly correlated noise.
- Rapid Adaptation to changing signal conditions is required.
- Computational Resources are sufficient to handle the increased processing demands.
- Precision in error minimization and coefficient adjustment is a priority.

* LMS is advantageous when:
- Computational Efficiency and low processing overhead are critical, such as in embedded systems or real-time applications with limited hardware capabilities.
- The signal environment is relatively stable, or changes occur gradually, reducing the need for rapid adaptation.
- Simplicity and ease of implementation are desired, especially for initial prototyping or educational purposes.

---

## 9) Acknowledgments

* NI-provided denoised speech material used as the base for corruption and testing.
* MATLAB custom implementations compared against MATLAB built-ins for verification.

---

