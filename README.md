# DOB Control Explorer

An interactive MATLAB app for exploring **Disturbance Observer (DOB) control**, based on:

> Shim, H., Park, G., Joo, Y., Back, J., & Jo, N. H. (2016).  
> *Yet Another Tutorial of Disturbance Observer: Robust Stabilization and Recovery of Nominal Performance.*  
> [arXiv:1601.02075](https://arxiv.org/abs/1601.02075)

---

## Requirements

- MATLAB R2020b or later
- Control System Toolbox

---

## Usage

```matlab
DOBControlApp()
```

The window auto-sizes to your screen. All plots update live whenever a slider moves or a coefficient field changes.

---

## Layout

### Left panel — inputs

**Plant *P*(*s*)** — enter numerator and denominator as space-separated coefficient vectors, descending powers, monic denominator. *P*(*s*) must be strictly proper.

**Truncation order *n*** — how many dominant poles (those with the least-negative real parts) are retained to form the nominal model *P*ₙ(*s*). *P*ₙ is constructed as a poles-only transfer function with the same DC gain as *P*, so it has no zeros by construction.

**DOB *Q*-filter** — two parameters:
- *τ* (time constant): sets DOB bandwidth at 1/*τ* rad/s. Smaller *τ* = more aggressive disturbance rejection, but increases sensitivity to unmodelled dynamics.
- *μ* (filter order): order of *Q*(*s*) = 1/(*τs*+1)^*μ*. Auto-clamped to be at least *ν*, the relative degree of *P*ₙ, so that *Q*/*P*ₙ remains proper.

**Outer-loop bandwidth *ω*_c** — target bandwidth passed to `pidtune`, which designs a PI controller on *P*ₙ alone.

**Diagnostics** — updated on every recompute: plant order and relative degree, minimum-phase status, retained/discarded poles, nominal loop gain and phase margins, and explicit stable/unstable flags for both *T*_r (*r*→*y*) and *T*_d (*d*→*y*).

---

### Tab 1 — Responses

| Plot | Description |
|---|---|
| **Nyquist** | Frequency locus of *P*(*jω*) and *P*ₙ(*jω*). Solid line = positive frequencies; dotted = conjugate (negative frequencies). Critical point −1 marked. |
| **Step response** | Green dashed = nominal target (*P*ₙ + *C*, no DOB). Red solid = real plant under DOB. Convergence of red onto green as *τ* decreases is the performance-recovery property of the paper. |
| **Disturbance rejection** | Blue solid = output *y*(*t*) under a unit step disturbance *d* at the plant input. Returns to zero at steady state by construction (*T*_d(0) = 0). |

---

### Tab 2 — Bode

Closed-loop frequency response *T*_r(*jω*) = *r*→*y*, comparing **obtained** (real plant + DOB, red) against **target** (nominal *P*ₙ + *C* only, green dashed).

| Plot | Reference lines |
|---|---|
| **Magnitude (dB)** | Dotted −3 dB line; gold vertical marker at *ω*_c |
| **Phase (deg)** | Dotted −180° line; gold vertical marker at *ω*_c |

Frequency axis is auto-ranged from 5% of the slowest pole to 20× the fastest pole or DOB bandwidth, so the relevant dynamics are always in frame.

---

## How the closed loop is computed

The DOB block diagram (Fig. 1 of Shim et al.) is closed using MATLAB's `connect()` with named signal ports, producing a state-space realisation directly — no polynomial inversion, no `1/(1−Q)` singularity. The two closed-loop channels are:

$$T_r = \frac{P \cdot C \cdot P_n}{P_n(1-Q) + P_n P C + PQ}, \qquad T_d = \frac{P(1-Q)P_n}{P_n(1-Q) + P_n P C + PQ}$$

Both share the same pole set. Stability is checked via `isstable()` on the state-space realisations.

---

## Worked example — 8-pole arithmetic plant

$$P(s) = \frac{1}{\prod_{k=1}^{8}(s + 0.4k)}$$

| Field | Value |
|---|---|
| Numerator | `1` |
| Denominator | `1  14.4  87.36  290.304  574.6944  688.9882  483.8359  179.5424  26.4241` |

| Slider | Recommended value |
|---|---|
| *n* | 4 |
| *τ* | 0.20 |
| *μ* | 4 |
| *ω*_c | 0.50 |

With these settings the four slowest poles (−0.4, −0.8, −1.2, −1.6) are retained in *P*ₙ and the four fastest (−2.0, −2.4, −2.8, −3.2) are discarded. Drag *τ* down toward 0.05 and observe the disturbance rejection improving until the discarded-mode band destabilises the loop — this is the unmodelled-dynamics bandwidth limit described in Section 8 of the paper.
