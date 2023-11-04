def fetchLines(start,end,lines):
	names = {}
	i_start = -1
	for i in range(len(lines)):
		line = lines[i]
		if i_start == -1 and line.startswith(start):
			i_start = i
		if i_start != -1 and line.endswith(end):
			names[lines[i_start].replace(start, "<").replace("*", "")] = lines[i_start+1:i]
			i_start = -1
	return names


with open("../xal.pas") as f:
	lines = f.read().split("\n")

res = fetchLines('(* <', '*)',lines)
keys = sorted(res.keys())

with open('christer1.txt','w') as g:
	for key in keys:
		g.write(key + '\n')

with open('christer2.txt', 'w') as h:
	for key in keys:
		h.write(key + '\n' + '\n'.join(res[key]) + '\n')

