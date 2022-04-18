# count plot distributions for different apps
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from constraint import *
from loader import Loader
from config import get_filename, FileType

import matplotlib.pyplot as plt
import numpy as np

CONSTRAINT2NAME = {
    PresenceConstraint : 'Presence',
    InclusionConstraint : 'Inclusion',
    UniqueConstraint : 'Unique',
    FormatConstraint : 'Format',
    LengthConstraint : 'Length',
    NumericalConstraint : 'Numerical',
    ForeignKeyConstraint : 'FK'    
}

def group_by(constraints):
    c_map = {}
    for c in constraints:
        if type(c) not in c_map:
            c_map[type(c)] = 0
        c_map[type(c)] += 1
    return c_map

def plot_app(appname):
    filename = get_filename(FileType.CONSTRAINT, appname)
    constraints = Loader.load_constraints(filename)
    db_constraints = [c for c in constraints if c.db]
    model_constraints = [c for c in constraints if not c.db]
    db_group = group_by(db_constraints)
    model_group = group_by(model_constraints)
    keys = list(set(list(db_group.keys()) + list(model_group.keys())))
    
    fig, ax = plt.subplots()
    fig.set_size_inches(8, 4)
    
    x = np.arange(len(keys))
    db_values = []
    model_values = []
    for k in keys:
        if k in db_group:
            db_values.append(db_group[k])
        else:
            db_values.append(0)
        if k in model_group:
            model_values.append(model_group[k])
        else:
            model_values.append(0)
    
    width = 0.4
    ax.bar(x - width/2, model_values, width, edgecolor='black', color='#2596be', label = "Model")
    ax.bar(x + width/2, db_values, width, edgecolor='black', color='#e28743', label = "DB")
    ax.set_xticks(x)
    ax.set_xticklabels([CONSTRAINT2NAME[k] for k in keys], rotation = 10)
    
    ax.tick_params(axis='both', which='major', labelsize=17)
    ax.legend(prop={'size': 15})
    fig.subplots_adjust(bottom=0.2)
    plt.yscale("log")
    plt.savefig("/home/ubuntu/ConstrOpt/figures/7.2/%s.pdf" % appname)
    
    

if __name__ == "__main__":
    for appname in ["redmine", "forem", "openproject"]:
        plot_app(appname) 