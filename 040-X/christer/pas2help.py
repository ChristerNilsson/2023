import re
import time

def fetchText(filename):
	with open(filename) as f:
		return f.read()

def writeLines(filename,lines):
	with open(filename,'w') as g:
		g.write('\n'.join(lines))

def doit():

	text = fetchText('../xal.pas')

	regex = re.compile(r"""
		\(\*[ ]
			(<[.]+?>[*]*:)
			([.]+?)
		\n\*\)
	""", re.VERBOSE)

	# regex = re.compile(r"""
	# \n\(\*[ ]
	# 	(<([^:]+)>*?:) # name, asterix kan förekomma
	# 	([^*]*)          # body, får innehålla alla tecken utom asterix
	# \n\*\)
	# """,re.VERBOSE)

	lista = re.findall(regex,text)

	inputNames = []
	normalNames = []
	names = {}
	for name,_,body in lista:
		print(name)
		if '*' in name:
			name = name.replace('*','')
			inputNames.append(name)
		else:
			normalNames.append(name)
		names[name] = body

	normalNames = sorted(normalNames)
	inputNames = sorted(inputNames)
	both = normalNames + inputNames

	writeLines('xal_names.txt',['Normal functions:'] + normalNames + ['\nInput functions:'] + inputNames)
	helpTexts = [name + names[name] for name in both]
	writeLines('xal_help.txt',helpTexts)
	print(len(lista),'funktioner hittades.')

start = time.time_ns()
doit()
print(int((time.time_ns() - start)/10**6), 'ms')