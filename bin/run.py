import faiss
import numpy as np
import csv
import sys

# parse CLI arguments

if len(sys.argv) == 3:
    out_dir = sys.argv[1]
    k = int(sys.argv[2])
else:
    out_dir = "../out"
    k = 2


# I/O functions

def csv_read(fname):
    reader = csv.reader(open(fname, "r"), delimiter="\t")
    x = list(reader)
    return np.array(x).astype("float32")


def csv_write(fname, data):
    writer = csv.writer(open(fname, "w"), delimiter="\t")
    writer.writerows(data)

# data processing

# extract
xb = csv_read("{}/xb.txt".format(out_dir))
d = xb.shape[1]

# transform

# build the index
index = faiss.IndexFlatL2(d)
print(index.is_trained)

# add vectors
index.add(xb)
print(index.ntotal)

# sanity check
D, I = index.search(xb[:5], k)
print(I)
print(D)

# actual search
D, I = index.search(xb, k) 
print(I[:5])    
print(I[-5:])        

# load
csv_write("{}/D.txt".format(out_dir), D)
csv_write("{}/I.txt".format(out_dir), I)
