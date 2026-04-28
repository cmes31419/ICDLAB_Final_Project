import numpy as np
import matplotlib.pyplot as plt

t_max = np.array([2, 6, 10, 20, 30])

data = {
    8: {
        "conventional": np.array([172, 670, 1217, 2602, 3957]),
        "baseline": np.array([138, 583, 1071, 2405, 3749]),
        "ours":     np.array([138, 566, 1023, 2281, 3478]),
    },
    16: {
        "conventional": np.array([445, 1547, 2687, 5597, 8369]),
        "baseline": np.array([240, 1137, 2056, 4642, 7412]),
        "ours":     np.array([240, 1016, 1701, 3721, 5644]),
    },
    32: {
        "conventional": np.array([1077, 3340, 5665, 11509, 17214]),
        "baseline": np.array([558, 2239, 4011, 9103, 14471]),
        "ours":     np.array([558, 1880, 3003, 6541, 10000]),
    },
    63: {
        "conventional": np.array([2304, 6912, 11566, 23132, 34554]),
        "baseline": np.array([1230, 4556, 8031, 18209, 29106]),
        "ours":     np.array([1230, 3728, 5655, 12175, 18598]),
    },
}

# =========================
# Figure 1: 2x2 grouped bar chart
# =========================

fig, axes = plt.subplots(2, 2, figsize=(11, 7), sharey=False)
axes = axes.flatten()

x = np.arange(len(t_max))
width = 0.25

for ax, P in zip(axes, data.keys()):
    ax.bar(x - width, data[P]["conventional"], width, label="conventional")
    ax.bar(x, data[P]["baseline"], width, label="baseline")
    ax.bar(x + width, data[P]["ours"], width, label="ours")

    ax.set_title(f"q = 6, P = {P}", fontsize=12)
    ax.set_xlabel(r"$t_{max}$", fontsize=11)
    ax.set_ylabel("XOR Gate Count", fontsize=11)
    ax.set_xticks(x)
    ax.set_xticklabels(t_max, fontsize=10)
    ax.tick_params(axis='y', labelsize=10)
    ax.grid(True, axis="y", linestyle="--", alpha=0.5)
    ax.legend(fontsize=10)

fig.suptitle("XOR Gate Count Comparison: Conventional vs Baseline vs Ours", fontsize=16)
fig.tight_layout()
fig.savefig("report/complexity_grouped_bar.png", dpi=300, bbox_inches="tight")
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
ax.set_title("XOR Gate Count Reduction of Ours Compared with Baseline (%)")

cbar = plt.colorbar(im, ax=ax)
cbar.set_label("Reduction (%)")

for i in range(len(P_values)):
    for j in range(len(t_max)):
        ax.text(
            j, i, f"{reduction[i, j]:.1f}%",
            ha="center", va="center", color="white"
        )

fig.tight_layout()
fig.savefig("report/reduction_heatmap.png", dpi=300, bbox_inches="tight")
plt.close(fig)

print("Saved figures:")
print("1. complexity_grouped_bar.png")
print("2. reduction_heatmap.png")