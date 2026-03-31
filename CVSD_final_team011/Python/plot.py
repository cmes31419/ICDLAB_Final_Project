import matplotlib.pyplot as plt

# Data
labels = [
    "16-parallel\nchien search\nw/ full\nmultiplier",
    "64-parallel\nchien search\nw/ constant\nmultiplier",
    "32-parallel\nchien search\nw/ constant\nmultiplier",
    "16-parallel\nchien search\nw/ constant\nmultiplier"
]

values = [230000, 134000, 81000, 52000]

# Plot
plt.figure(figsize=(8, 5))
bars = plt.bar(range(len(values)), values)

# Value labels on top
for bar, val in zip(bars, values):
    plt.text(
        bar.get_x() + bar.get_width() / 2,
        val,
        f"{val}",
        ha="center",
        va="bottom"
    )

plt.xticks(range(len(labels)), labels)
plt.ylabel("Area (um^2)")
plt.title("Chien Search Architecture Comparison")

plt.tight_layout()
plt.show()



# import matplotlib.pyplot as plt

# # Data
# labels = [
#     "BM w/ 2t\niterations",
#     "BM w/ t\niterations"
# ]

# values = [66000, 48000]

# # Plot
# plt.figure(figsize=(5, 5))
# bars = plt.bar(range(len(values)), values, width=0.5)

# # Value labels
# for bar, val in zip(bars, values):
#     plt.text(
#         bar.get_x() + bar.get_width() / 2,
#         val + 1500,
#         f"{val}",
#         ha="center",
#         va="bottom",
#         fontsize=12
#     )

# plt.xticks(range(len(labels)), labels)
# plt.ylabel("Area (um^2)")
# plt.title("Berlekamp–Massey Architecture Comparison")

# # 🔴 固定 y 軸高度
# plt.ylim(0, 72000)

# plt.tight_layout()
# plt.show()
