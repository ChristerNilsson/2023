import random
import time
N = 64

antal = 0
persons = []
for i in range(N):
	persons.append({'id': i, 'opps':[], 'score':0})

def getMet(a,b): return a['id'] in b['opps']

# def pair (persons,pairing=[]):
# 	if len(pairing) == N: return pairing
# 	global antal
# 	antal += 1
# 	for a in persons:
# 		for b in persons:
# 			if a == b: continue # man kan inte möta sig själv
# 			if getMet(a,b): continue # a och b får ej ha mötts tidigare
# 			newPersons = [p for p in persons if not p in [a,b]]
# 			newPairing = pairing + [a,b]
# 			result = pair(newPersons,newPairing)
# 			if len(result) == N: return result
# 	return []

def value(a,b):
	res = 0
	if getMet(a,b): res += 10000
	diff = a['score'] - b['score']
	res += diff * diff
	return res

def swapper(pairings):
	for i in range(len(pairings)//2):
		for j in range(i+1,len(pairings)//2):
			a = persons[pairings[2*i+0]]
			b = persons[pairings[2*i+1]]
			c = persons[pairings[2*j+0]]
			d = persons[pairings[2*j+1]]
			r = value(a,b) + value(c,d)
			q = value(a,c) + value(b,d)
			s = value(a,d) + value(c,b)
			# print(r,q,s)
			if q < r and q < 10000:
				print('q < r')
				pairings[2 * i + 1], pairings[2 * j + 0] = pairings[2 * j + 0], pairings[2 * i + 1]
				#return r-q
			if s < r and s < 10000:
				print('s < r')
				persons[2 * i + 1], persons[2 * j + 1] = persons[2 * j + 1], persons[2 * i + 1]
				#return r-s
	return 0

start = time.time_ns()

def makeMatrix(persons):
	arr = []
	for i in range(N):
		a = persons[i]
		for j in range(N):
			if i==j : continue
			b = persons[j]
			if getMet(a,b): continue
			cost = abs(a['score'] - b['score'])
			arr.append([cost,i,j])
	arr.sort()
	z=99
	return arr

for rond in range(32):
	print(rond,antal)

	matrix = makeMatrix(persons)
	#persons.sort(reverse=True,key=lambda p: p['score'])
	#pairings = [person['id'] for person in persons]
	#persons.sort(key=lambda p: p['id'])

	used = [False] * N
	pairs = []
	for [cost,i,j] in matrix:
		if used[i] or used[j]: continue
		used[i] = True
		used[j] = True
		pairs.append([i,j])
	z=99

	for [i,j] in pairs:
		a = persons[i]
		b = persons[j]
		a['opps'].append(b['id'])
		b['opps'].append(a['id'])
		result = random.randint(0,2)
		a['score'] += result
		b['score'] += 2 - result
	z=99

persons.sort(reverse=True,key=lambda p: p['score'])
print()
for p in persons:
	print(p['id'],p['score'],p['opps'])

print(antal,(time.time_ns() - start)/10**6)