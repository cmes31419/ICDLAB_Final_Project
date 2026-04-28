import numpy as np
import matplotlib.pyplot as plt

t_max = np.array([2, 6, 10, 20, 30, 50])

data = {
    8: {
        "conventional": np.array([172, 670, 1217, 2602, 3957, 6630]),
        "baseline": np.array([118, 563, 1051, 2385, 3729, 6365]),
        "ours":     np.array([88, 381, 728, 1631, 2503, 4215]),
    },
    16: {
        "conventional": np.array([445, 1547, 2687, 5597, 8369, 13985]),
        "baseline": np.array([135, 1032, 1951, 4537, 7307, 12758]),
        "ours":     np.array([105, 456, 841, 1871, 2864, 4819]),
    },
    32: {
        "conventional": np.array([1077, 3340, 5665, 11509, 17214, 28754]),
        "baseline": np.array([188, 1869, 3641, 8733, 14101, 24873]),
        "ours":     np.array([158, 600, 1058, 2341, 3590, 5994]),
    },
    63: {
        "conventional": np.array([2304, 6912, 11566, 23132, 34554, 57542]),
        "baseline": np.array([300, 3626, 7101, 17279, 28176, 49481]),
        "ours":     np.array([270, 908, 1500, 3280, 5023, 8275]),
    },
}

# =========================
# Figure 1: 2x2 grouped bar chart
# =========================

fig, axes = plt.subplots(2, 2, figsize=(11, 7), sharey=False)
axes = axes.flatten()

x = np.arange(len(t_max))
width = 0.35

for ax, P in zip(axes, data.keys()):
    ax.bar(x - width / 2, data[P]["baseline"], width, label="baseline")
    ax.bar(x + width / 2, data[P]["ours"], width, label="ours")

    ax.set_title(f"q = 6, P = {P}")
    ax.set_xlabel(r"$t_{max}$")
    ax.set_ylabel("XOR Gate Count")
    ax.set_xticks(x)
    ax.set_xticklabels(t_max)
    ax.grid(True, axis="y", linestyle="--", alpha=0.5)
    ax.legend()

fig.suptitle("XOR Gate Count Comparison: Baseline vs Ours", fontsize=14)
fig.tight_layout()
fig.savefig("complexity_grouped_bar.png", dpi=300, bbox_inches="tight")
plt.close(fig)


# =========================
# Figure 2: reduction heatmap
# =========================

P_values = list(data.keys())
reduction = []

for P in P_values:
    baseline = data[P]["baseline"]
    ours = data[P]["ours"]
    red = (baseline - ours) / baseline * 100
    reduction.append(red)

reduction = np.array(reduction)

fig, ax = plt.subplots(figsize=(8, 4.5))

im = ax.imshow(reduction, aspect="auto")

ax.set_xticks(np.arange(len(t_max)))
ax.set_xticklabels(t_max)
ax.set_yticks(np.arange(len(P_values)))
ax.set_yticklabels(P_values)

ax.set_xlabel(r"$t_{max}$")
ax.set_ylabel("P")
ax.set_title("Reduction Ratio of XOR Gate Count (%)")

cbar = plt.colorbar(im, ax=ax)
cbar.set_label("Reduction (%)")

for i in range(len(P_values)):
    for j in range(len(t_max)):
        ax.text(
            j, i, f"{reduction[i, j]:.1f}%",
            ha="center", va="center", color="white"
        )

fig.tight_layout()
fig.savefig("reduction_heatmap.png", dpi=300, bbox_inches="tight")
plt.close(fig)

print("Saved figures:")
print("1. complexity_grouped_bar.png")
print("2. reduction_heatmap.png")