from statistics import median
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import json
from config import get_filename, FileType
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import pandas as pd

speedup = {}
s = []
a = []
apps = ["redmine", "forem", "openproject"]
for app in apps:
    print(app)
    filename = get_filename(FileType.ENUM_EVAL, app)
    with open(filename, "r") as f:
        lines = f.readlines()
    speedup[app] = []
    for line in lines:
        obj = json.loads(line)
        after_time = max(1e-5, obj["after_time"])
        sp = obj["before_time"] / after_time
        if sp == 1:
           continue
        speedup[app].append(sp)
        s.append(sp)
        a.append(app)

fig, axes = plt.subplots(1, 2)
storage = [1.49, 1.7, 1.57]
fig.set_size_inches(8, 4)
x = np.arange(len(speedup))  # the label locations
#sns.boxplot(data=pd.DataFrame.from_dict({"speedup":s, "app":a}), x="app", y="speedup")
#axes[0].set_ylim((0.5, 1.2))
axes[0].set_xticks([0, 1, 2])
axes[0].tick_params(axis='both', which='major', labelsize=12)
axes[0].set_xticklabels(apps)
means = []

# errors = []
for k in speedup:
    means.append(np.median(speedup[k]))
#     errors.append(np.std(speedup[k]))
print(means)
width = 0.3
axes[0].bar(x - width / 2, means, width=width, label="Speedup")
axes[0].bar(x + width / 2, storage, width=width, label="Storage Reduction")
axes[0].set_ylabel("Ratio", size = 16)
axes[0].set_xlabel("Application", size= 16)
axes[0].set_yticks([0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75])
axes[0].legend(loc=(-0.02,1.05), ncol=2)
axes[0].grid(axis='y', color='grey')

q1 = [1.03, 1.27, 1.77, 2.4, 4.77]
q2 = [0.97, 1.24, 1.66, 2.39, 5.03]
q3 = [1.02, 1.25, 1.64, 2.45, 5.02]
percentage = [0, 20, 40 ,60, 80]
x = np.arange(len(percentage))
width = 0.2
axes[1].bar(x - width, q1, width=width, label='Q1')
axes[1].bar(x, q2, width=width, label='Q2')
axes[1].bar(x + width, q3, width=width, label='Q3')
axes[1].tick_params(axis='both', which='major', labelsize=12)
axes[1].set_xticks([0, 1, 2, 3, 4])
axes[1].set_xticklabels([str(s) + "%" for s in percentage])
axes[1].set_xlabel("Invalid Percentage", size=16)
axes[1].set_ylabel("Speedup", size = 16)
axes[1].legend(loc=(0.04,1.05), ncol=3)
axes[1].grid(axis='y', color='grey')

plt.subplots_adjust(bottom=0.15)
plt.savefig("/home/ubuntu/ConstrOpt_str2int/figures/7.4/str2int.pdf")


