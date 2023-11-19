import random
import time
import math

# Klarar upp till 1600 spelare på 1899 millisekunder för alla 15 ronderna.

start = time.time_ns()

random.seed(10)

persons = []

def save(name):
	persons.append({'id':len(persons), 'name':name, 'opps':[], 'color':[], 'result':[]})

#for name in 'A B C D E F G H I J'.split(" "):
#for name in 'A B C D E F G H I J K L M N O P'.split(" "):
#for name in '0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'.split(" "):
for i in range(1600):
	save(i)

N = len(persons)
R = int(math.floor(1.5*math.log2(N))) # antal ronder
print(N,R)

met = {} # användes för att se om spelarna mötts tidigare. "F"=ej mötts  "T"=mötts

score = lambda p: sum(persons[p]['result'])

def getMet(a,b):
	key = f"{a}-{b}" if a < b else f"{b}-{a}"
	return (key in met) and met[key] == "T"

def setMet(a,b):
	key = f"{a}-{b}" if a < b else f"{b}-{a}"
	met[key] = 'T'

def clrMet(a,b):
	key = f"{a}-{b}" if a < b else f"{b}-{a}"
	met[key] = 'F'

# Tag fram lista för varje spelare med personer man inte mött
def lotta(ids,pairing=[]):
	if len(pairing) == N: return pairing
	for a in ids: # a är ett personindex
		for b in ids: # b är ett personindex
			if a >= b: continue
			if getMet(a,b): continue # a och b får ej ha mötts tidigare
			newids = [id for id in ids if not id in [a,b]]
			newPairing = pairing + [a,b]
			setMet(a,b)
			result = lotta(newids,newPairing)
			clrMet(a,b)
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

def makeMet():
	global met
	met = {}
	for i in range(N):
		setMet(i, i)
		person = persons[i]
		for j in person['opps']: setMet(i,j)

for rond in range(R):
	print("Rond",rond)
	ids = list(range(N))
	ids.sort(key=lambda p: score(p),reverse=True)
	#visaResultat(ids)
	result = lotta(ids,[])
	# print(result)
	for i in range(N//2):
		a = result[2*i]
		b = result[2*i+1]
		persons[a]['opps'].append(b)
		persons[b]['opps'].append(a)
		x = random.random()
		if x < 0.1:   res = [1,1]
		elif x < 0.5: res = [0,2]
		else:         res = [2,0]
		persons[a]['result'].append(res[0])
		persons[b]['result'].append(res[1])
	#visaLottning(ids)
	makeMet()
	# for key in sorted(met.keys()):
	# 	print(key,met[key])

print(N,len(met))
print((time.time_ns() - start)/10**6, "ms")