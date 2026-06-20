N = 1024
I = 0:N-1

w = exp(-2 * pi * im / N)
DFT = w .^ (I' .* I)

using Plots
p = heatmap(real(DFT), title="DFT Matrix", xlabel="Time Index (n)", ylabel="Frequency Index (k)")
savefig(p, "../docs/images/DFT_hm.svg")
