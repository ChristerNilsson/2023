with open("../xal.pas", "r") as f:
    lines = f.read().split("\n")

starting = []
ending = []
indexes = []

for i in range(len(lines)):
    # print(line)
    line = lines[i]
    state = 2
    if line.startswith('(* <'): indexes.append(i+1)
    if line.endswith('*)'): indexes.append(-i-1)
    # if line.startswith('(*'): starting.append(i)
    # if line.endswith('*)'): ending.append(i)

print(indexes)

