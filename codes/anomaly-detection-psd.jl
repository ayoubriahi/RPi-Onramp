# ────────────────────────────────────────────────────────────────────
#  Anomaly Detection via PSD (Welch's method) — PSD → threshold on PSD
# ────────────────────────────────────────────────────────────────────

using FFTW
using Statistics
using Plots

# PARAMETERS

fs = 1000.0  # sampling frequency (Hz)
N = 1024  # samples per frame
t = (0:N-1) ./ fs  # time vector  (~1 s)

# SIGNALS

noise = 0.05 .* randn(N)  # Gaussian noise
baseline = sin.(2π * 50.0 .* t) .+ 0.5 .* sin.(2π * 120.0 .* t) .+ noise

anomaly = copy(baseline)
anomaly .+= 0.6 .* sin.(2π * 200.0 .* t)  # spurious tone at 200 Hz

# PSD VIA WELCH'S METHOD (Split signal into overlapping segments, window each one, compute periodogram per segment, average them.)

function welch_psd(x, fs; seg_len=256, overlap=128)
    step = seg_len - overlap
    n_seg = (length(x) - overlap) ÷ step
    win = 0.5 .* (1 .- cos.(2π .* (0:seg_len-1) ./ (seg_len - 1)))  # Hann
    win_pow = sum(win .^ 2)

    psd = zeros(seg_len ÷ 2)

    for i in 1:n_seg
        start = (i - 1) * step + 1
        seg = x[start:start+seg_len-1] .* win
        X = fft(seg)
        psd .+= abs.(X[1:seg_len÷2]) .^ 2 ./ (fs * win_pow)
    end

    psd ./= n_seg  # average over segments
    freqs = (0:seg_len÷2-1) .* (fs / seg_len)
    return freqs, psd
end

freqs, psd_base = welch_psd(baseline, fs)
_, psd_anom = welch_psd(anomaly, fs)

# DETECT ANOMALY (Flag bins where anomalous PSD exceeds baseline by > 3σ of the baseline PSD distribution)

residual = psd_anom .- psd_base
threshold = mean(residual) + 3.0 * std(residual)

flagged_idx = findall(residual .> threshold)
flagged_freqs = freqs[flagged_idx]

println("Threshold            : $(round(threshold, sigdigits=3))")
println("Flagged frequencies  : $(round.(flagged_freqs, digits=1)) Hz")
# → expected peaks at 50, 120 Hz (normal) + 200 Hz (anomaly)

# PLOT

p1 = plot(freqs, psd_base;
    label="Baseline PSD",
    color=RGB(0.01, 0.50, 0.56),
    linewidth=1.8,
    xlabel="Frequency (Hz)",
    ylabel="PSD (V²/Hz)",
    title="PSD comparison",
    yscale=:log10,
    legend=:topright,
)
plot!(p1, freqs, psd_anom;
    label="Anomalous PSD",
    color=RGB(0.69, 0.18, 0.18),
    linewidth=1.4,
    alpha=0.85,
)

p2 = plot(freqs, residual;
    label="Residual  (anomaly − baseline)",
    color=RGB(0.40, 0.20, 0.60),
    linewidth=1.5,
    xlabel="Frequency (Hz)",
    ylabel="ΔPSD (V²/Hz)",
    title="Residual (anomaly flagged here)",
    legend=:topright,
    fillrange=0,
    fillalpha=0.12,
    fillcolor=RGB(0.40, 0.20, 0.60),
)
hline!(p2, [threshold];
    label="Threshold  (μ + 3σ)",
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
savefig("../docs/images/anomaly-detection-psd.svg")
