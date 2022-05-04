import numpy as np
import matplotlib.pyplot as plt

models = {
   'Presence' : 1482,
   'Inclusion' : 144,
   'Uniqueness': 370,
   'Format' : 116,
   'Length' : 430,
   'Numerical' : 144,
   'Foreign Key' : 1360
}

dbs = {
   'Presence' : 2469,
   'Inclusion' : 0,
   'Uniqueness': 368,
   'Format' : 0,
   'Length' : 2546,
   'Numerical' : 63,
   'Foreign Key' : 89
}

labels = list(models.keys())

fig, ax = plt.subplots()
fig.set_size_inches(20, 8)

x = np.arange(len(labels))  # the label locations
width = 0.4
#ax.bar(x - width/2, list(models.values()), width, edgecolor='black', color='#efccc9', label = "Model")
#ax.bar(x + width/2, list(dbs.values()), width, edgecolor='black', color='#713b28', label = "DB")
ax.bar(x - width/2, list(models.values()), width, label = "Model")
ax.bar(x + width/2, list(dbs.values()), width, label = "DB")
for i, v in enumerate(models.values()):
   ax.text(i - width/2 - 0.17, v * 1.05, str(v), color='black', fontsize=24)
for i, v in enumerate(dbs.values()):
   if v == 0:
      v = 1
      t = '0'
   else:
      t = str(v)
   ax.text(i + width/2 - 0.15, v * 1.05, t, color='black', fontsize=24)
   
ax.set_xticks(x)
ax.set_xticklabels(labels, rotation = 20)

step = 500
maxv = int(max(list(models.values()) + list(dbs.values())) / step) * step
ax.set_xlim(-3.0/2*width, len(labels) - width)
ax.set_yscale("log", nonpositive='clip')
ax.set_ylim(bottom=1, top=10**(3.7))
# ax.set_yticks(list(range(0, maxv + 50, step)))
ax.set_ylabel("Number of constraints", size = 40)

ax.tick_params(axis='both', which='major', labelsize=40)
ax.legend(prop={'size': 30}, loc=(0.65, 1.05), ncol = 2)
fig.subplots_adjust(bottom=0.2)
plt.savefig("/home/ubuntu/ConstrOpt_str2int/figures/7.2/constraint_dis.pdf")