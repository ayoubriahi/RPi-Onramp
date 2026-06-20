# ────────────────────────────────────────────────────────────────────────────
#  Anomaly Detection via FFT — FFT magnitude spectrum → threshold on magnitude
# ────────────────────────────────────────────────────────────────────────────

using FFTW
using Plots

# BUILD THE SIGNAL

fs = 1000.0  # sampling frequency (Hz)
N = 1024  # number of samples (power of 2 → fast FFT)
t = (0:N-1) ./ fs  # time vector

# NORMAL COMPONENTS
x_base = sin.(2π * 50.0 .* t) .+ 0.5 .* sin.(2π * 120.0 .* t)

# ANOMALOUS SIGNAL (spurious tone at 200 Hz)
x_anom = copy(x_base)
x_anom .+= 0.6 .* sin.(2π * 200.0 .* t)

# FFT

freqs = (0:N÷2-1) .* (fs / N)  # one-sided frequency axis
mag_base = abs.(fft(x_base)[1:N÷2]) ./ N
mag_anom = abs.(fft(x_anom)[1:N÷2]) ./ N

mag_base[2:end-1] .*= 2.0
mag_anom[2:end-1] .*= 2.0

# DETECT ANOMALIES
residual = mag_anom .- mag_base
threshold = 0.1
flagged_idx = findall(residual .> threshold)
flagged_freqs = freqs[flagged_idx]

println("Flagged frequencies: $(round.(flagged_freqs, digits=1)) Hz")

# PLOT

p1 = plot(freqs, mag_base;
    seriestype=:sticks,
    label="Baseline spectrum",
    color=RGB(0.01, 0.50, 0.56),
    linewidth=1.5,
    xlabel="Frequency (Hz)",
    ylabel="Magnitude",
    title="FFT (baseline vs anomalous signal)",
    legend=:topright,
)
plot!(p1, freqs, mag_anom;
    seriestype=:sticks,
    label="Anomalous spectrum",
    color=RGB(0.69, 0.18, 0.18),
    linewidth=1.5,
    alpha=0.75,
)

p2 = plot(freqs, residual;
    seriestype=:sticks,
    label="Residual  (anomaly − baseline)",
    color=RGB(0.40, 0.20, 0.60),
    linewidth=1.5,
    xlabel="Frequency (Hz)",
    ylabel="ΔMagnitude",
    title="Residual (anomaly flagged here)",
    legend=:topright,
)
hline!(p2, [threshold];
    label="Threshold (Δ > 0.1)",
    color=:orange,
    linestyle=:dash,
    linewidth=1.5,
)
scatter!(p2, flagged_freqs, residual[flagged_idx];
    label="Anomaly",
    color=:orange,
    markersize=7,
    markershape=:diamond,
)

plot(p1, p2; layout=(2, 1), size=(900, 580), dpi=150, margin=5Plots.mm)
savefig("../docs/images/anomaly-detection-fft.svg")
