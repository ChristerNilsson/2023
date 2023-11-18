import random
import time

start = time.time_ns()

random.seed(10)

persons = []

def save(name):
	persons.append({'id':len(persons), 'name':name, 'opps':[], 'color':[], 'result':[]})

for name in 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'.split(" "):
	save(name)

N= len(persons)

score = lambda p: sum(persons[p]['result'])
didMeet = lambda i,j: i in persons[j]['opps']

# Tag fram lista för varje spelare med personer man inte mött
def lotta(ids,pairing=[]):
	if len(pairing)==N: return pairing
	for i in range(len(ids)):
		for j in range(i+1,len(ids)):
			if didMeet(ids[i],ids[j]): continue
			newids = [id for id in ids if not id in [ids[i],ids[j]]]
			newPairing = pairing + [ids[i],ids[j]]
			result = lotta(newids,newPairing)
			if len(result)==N: return result
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

for rond in range(20):
	print("Rond",rond)
	ids = list(range(N))
	ids.sort(key=lambda p: score(p),reverse=True)
	visaResultat(ids)
	result = lotta(ids,[])
	print(result)
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
	visaLottning(ids)

print((time.time_ns() - start)/10**6, "ms")