import random
import time
import math

# Klarar upp till 1500 spelare på 2.5 sekunder för alla ronderna.

start = time.time_ns()

random.seed(10)

persons = []

def save(name):
	persons.append({'id':len(persons), 'name':name, 'opps':[], 'color':[], 'result':[]})

#for name in 'A B C D E F G H I J'.split(" "):
#for name in 'A B C D E F G H I J K L M N O P'.split(" "):
#for name in '0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'.split(" "):
for i in range(1500):
	save(i)

N = len(persons)
R = int(math.floor(1.5*math.log2(N))) # antal ronder
print(N,R)

hash = {}
possible = [] # matris som användes för att direkt se om spelarna mötts tidigare.

score = lambda p: sum(persons[p]['result'])

didMeet = lambda i,j: possible[i][j]==0

# Tag fram lista för varje spelare med personer man inte mött
def lotta(ids,pairing=[]):
	if len(pairing) == N: return pairing
	for a in ids: # a är ett personindex
		for b in ids: # b är ett personindex
			if a <= b: continue
			if didMeet(a,b): continue # a och b får ej ha mötts tidigare
			newids = [id for id in ids if not id in [a,b]]
			newPairing = pairing + [a,b]
			possible[a][b] = 0
			possible[b][a] = 0
			result = lotta(newids,newPairing)
			possible[a][b] = 1
			possible[b][a] = 1
			if len(result) == N: return result
	return []

def visaLottning(ids):
	print('Lottning')
	for p in ids:
		person = persons[p]
		print(person['id'],person['name'],person['opps'],person['result'])

def visaResultat(ids):
	print()
	print('Resultat')
	for p in ids:
		person = persons[p]
		print(person['id'],person['name'],person['opps'],person['result'], sum(person['result']))

for person in persons:
	possible.append([1] * N)

def makePossible():
	global possible
	possible = []
	for person in persons:
		possible.append([1] * N)
	for i in range(N):
		person = persons[i]
		possible[i][i]=0
		for j in person['opps']:
			possible[i][j] = 0
			possible[j][i] = 0

for rond in range(R):
	print("Rond",rond)
	ids = list(range(N))
	ids.sort(key=lambda p: score(p),reverse=True)
	#visaResultat(ids)
	result = lotta(ids,[])
	#print(result)
	for i in range(N//2):
		a = result[2*i]
		b = result[2*i+1]
		persons[a]['opps'].append(b)
		persons[b]['opps'].append(a)
		x = random.random()
		res = [1.0,0.0]
		if x < 0.5: res = [0.0,1.0]
		if x < 0.1: res = [0.5,0.5]
		persons[a]['result'].append(res[0])
		persons[b]['result'].append(res[1])
	#visaLottning(ids)

	makePossible()
	#print()
	#for i in range(N):
	#	print(possible[i])

print(N,hash)
print((time.time_ns() - start)/10**6, "ms")