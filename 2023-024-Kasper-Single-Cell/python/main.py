import scanpy
import anndata
import time
directory = '../data'

start = time.time()

with open("../data/barcodes.tsv") as f:
	barcodes = [line.strip() for line in f.readlines()]

# Var tvungen att lägga in en header i features.tsv för att den skulle få med alla raderna.
features = anndata.read_csv("../data/features.tsv", first_column_names=['A','B','C'], delimiter="\t", dtype='U')
features = [feature[0] for feature in features.X]
#mtx = scanpy.read_10x_mtx(directory)
adata = scanpy.read_mtx("../data/matrix.mtx")
print(time.time() - start)
adata.obs_names = features
adata.var_names = barcodes

z=99

# # use anndata to read the .mtx file
#adata = anndata.read_mtx("../data/matrix.mtx",var_names=barcodes,obs_names=features)
#
print("Data shape:", adata.shape)
# Print the number of non-zero entries in the matrix
print("Non-zero entries:", adata.nnz)
# Print the names of the variables (if available)
print("Variable names:", adata.var_names)
# Print the names of the observations (if available)
print("Observation names:", adata.obs_names)