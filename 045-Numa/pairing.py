import random
import time
N = 16

antal = 0
persons = []
for i in range(N):
	persons.append({'id': i, 'opps':[], 'score':0})

def getMet(a,b): return a['id'] in b['opps']

def pair (persons,pairing=[]):
	if len(pairing) == N: return pairing
	global antal
	antal += 1
	for a in persons:
		for b in persons:
			if a == b: continue # man kan inte möta sig själv
			if getMet(a,b): continue # a och b får ej ha mötts tidigare
			newPersons = [p for p in persons if not p in [a,b]]
			newPairing = pairing + [a,b]
			result = pair(newPersons,newPairing)
			if len(result) == N: return result
	return []

start = time.time_ns()

for rond in range(15):
	print(rond,antal)
	persons.sort(reverse=True,key=lambda p: p['score'])
	pairings = pair(persons)
	for i in range(N//2):
		a = pairings[2*i+0]
		b = pairings[2*i+1]
		a['opps'].append(b['id'])
		b['opps'].append(a['id'])
		result = random.randint(0,2)
		a['score'] += result
		b['score'] += 2 - result

persons.sort(reverse=True,key=lambda p: p['score'])
print()
for p in persons:
	print(p['id'],p['score'],p['opps'])

print(antal,(time.time_ns() - start)/10**6)