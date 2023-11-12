import time

INPUT_FUNCTIONS = 'afilename alt anything bits bitsdec decimal eof eofr eoln filename followedby format id integer lwsp notfollowedby opt to to_wholeword to_withinLine towholeword towithinLine towl word'.split(" ") # skip!

def fetchLines(filename):
	with open(filename) as f:
		return f.read().split("\n")

def group(start,end,lines):
	res = {}
	j = -1
	for i in range(len(lines)):
		line = lines[i]
		if j == -1 and line.startswith(start):
			j = i
		if j != -1 and line.endswith(end):
			res[lines[j]] = lines[j+1:i]
			j = -1
	return res

def clean(hash,patterns):
	res = {}
	for key in hash:
		key2 = key
		for [old,new] in patterns:
			key2 = key2.replace(old,new)
		res[key2] = hash[key]
	return res

def writeLines(filename,lines):
	with open(filename,'w') as g:
		g.write('\n'.join(lines))

##############################

# start = time.time_ns()
lines = fetchLines('../xal.pas')

bodies = group('(* <', '*)', lines)
bodies = clean(bodies, [['(* <', '<'],['>*:', '>'],['>:', '>']])

inputNames = []
normalNames = []
for key in bodies.keys():
	k = key.split(' ')[0]
	k = k.replace('<','').replace('>','')
	if k in INPUT_FUNCTIONS: inputNames.append(key)
	else: normalNames.append(key)

normalNames = sorted(normalNames)
inputNames = sorted(inputNames)
names = inputNames + normalNames

writeLines('xal_names.txt',['Normal functions:'] + normalNames + ['\nInput functions:'] + inputNames)
helpTexts = [name + '\n' + '\n'.join(bodies[name]) + '\n' for name in names]
writeLines('xal_help.txt',helpTexts)
# print(int((time.time_ns() - start)/10**6), 'ms')