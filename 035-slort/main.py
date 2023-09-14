import json
ALFABET = '123456'


def ass(a, b):
	if a == b: return
	print("assertion failure:")
	print('  ', a)
	print('  ', b)


def op(s, selection):
	a = [digit for digit in s if digit in selection]
	b = [digit for digit in s if digit not in selection]
	return "".join(a + b)


def swap(s): return s[1] + s[0] + s[3] + s[2] + s[5] + s[4]
def rotate(s): return s[1] + s[2] + s[3] + s[4] + s[5] + s[0]
def turn(s): return s[5] + s[4] + s[3] + s[2] + s[1] + s[0]
def low(s): return op(s,'123')
def odd(s): return op(s,'135')


ass(swap('123456'), '214365')
ass(rotate('123456'), '234561')
ass(turn('123456'), '654321')
ass(low('135246'), '132546')
ass(odd('123456'), '135246')

chest = {"S": swap, "R": rotate, "L": low, "O": odd, "T": turn}

all = []
for a0 in ALFABET:
	for a1 in ALFABET:
		if a1 in [a0]:continue
		for a2 in ALFABET:
			if a2 in [a0,a1]: continue
			for a3 in ALFABET:
				if a3 in [a0,a1,a2]: continue
				for a4 in ALFABET:
					if a4 in [a0,a1,a2,a3]: continue
					for a5 in ALFABET:
						if a5 in [a0,a1,a2,a3,a4]: continue
						all.append(a0+a1+a2+a3+a4+a5)

def operations(parent,start,target):
	t = target
	res = ""
	while t != start:
		z = parent[t]
		t = z[0:6]
		res = z[-1] + res
	return res

def findPath(start,target):
	front = [start]
	parent = {start:'X'}
	while True:
		front2 = []
		for item in front:
			for key in chest:
				new = chest[key](item)
				if new in parent: continue
				front2.append(new)
				parent[new] = item + key
				if len(parent) == 720:
					keys = list(parent.keys())
					keys.sort()
					return operations(parent, start, target)
			front = front2

total = {}
for code in all: total[code] = findPath(code, '123456')

data = json.dumps(total)
with open('data.json','w') as f: f.write(data)
