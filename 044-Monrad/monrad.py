import random
import time
import math

# Klarar upp till 1600 spelare på 1678 millisekunder för alla 15 ronderna.
# TB1 är inbördes möte. Används bara för att särskilja två spelare
# TB2 är antal vinster
# TB3 är Buchholz. Summan av motståndarnas poäng

start = time.time_ns()

random.seed(10)

persons = []

def save(name):
	persons.append({'id':len(persons), 'name':name, 'opps':[], 'color':[], 'mandatory':0, 'colorComp':[], 'result':[], 'TB1':0, 'TB2':0, 'TB3':0}) # color: 1=W -1=B

for name in 'A B C D E F G H'.split(" "):
#for name in '0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'.split(" "):
# for i in range(1600):
#for name in 'A B C D E F G H'.split(" "):
	save(name)

N = len(persons)
R = 3+int(round(math.log2(N))) # antal ronder
print(N,R)

score = lambda p: sum(persons[p]['result'])
getMet = lambda a,b: b in persons[a]['opps']

# Tag fram lista för varje spelare med personer man inte mött
def lotta(ids,pairing=[],colors = []):
	if len(pairing) == N: return [pairing,colors]
	for a in ids: # a är ett personindex
		for b in ids: # b är ett personindex
			if a == b: continue
			if getMet(a,b): continue # a och b får ej ha mötts tidigare

			# color handling
			mandatory = persons[a]["mandatory"] + persons[b]["mandatory"]
			if abs(mandatory) == 2: continue
			if persons[a]["colorComp"] < persons[b]["colorComp"]:
				color = [1,-1]
			else:
				color = [-1,1]
			newColors = colors + color

			newids = [id for id in ids if not id in [a,b]]
			newPairing = pairing + [a,b]
			result = lotta(newids,newPairing,newColors)
			if len(result[0]) == N: return result
	return [[],[]]

def visaLottning(ids):
	print('Lottning')
	for p in ids:
		person = persons[p]
		print(person)
		#print(person['id'],person['name'],person['opps'],person['result'])

def visaResultat(ids):
	print()
	print('Resultat')
	for p in ids:
		person = persons[p]
		print(person)
		#print(person['id'],person['name'],person['opps'],person['result'], sum(person['result']))

def setTB1(p,q):
	if q in persons[p]['opps']:
		rond = persons[p]['opps'].index(q)
		persons[p]["TB1"] = persons[p]["result"][rond]

def calcTB(rond):
	# TB ska beräknas först när allt är klart!
	# Beräkna TB1 bara för de poänggrupper som har exakt två personer och då enbart om de har mött varandra.
	# Oklart om detta används för grupper med t ex tre personer. Låg sannolikhet att alla mött varandra.
	scores = {}
	for p in range(len(persons)):
		person = persons[p]
		key = sum(person['result'])
		if key in scores:
			scores[key].append(p)
		else:
			scores[key] = [p]
	for key in scores:
		if len(scores[key]) == 2:
			[p,q] = scores[key]
			setTB1(p,q)
			setTB1(q,p)
	for p in persons:
		p['TB2'] = p['result'].count(2) # Antal vinster
		p['TB3']= sum([sum(persons[i]['result']) for i in p['opps']]) # Buchholz: summan av motståndarnas poäng

for rond in range(R):
	print("Rond",rond)
	for p in persons:
		colorSum = sum(p["color"])
		latest = sum(p["color"][-1:])

		p["mandatory"] = 0
		if colorSum <= -2: p["mandatory"] =  1
		if colorSum >=  2: p["mandatory"] = -1
		p["colorComp"] = [latest,colorSum] # fundera på ordningen här.
	ids = list(range(N))

	calcTB(rond)

	ids.sort(key=lambda p: score(p),reverse=True)
	visaResultat(ids)

	if rond == R-1: break

	[ids,colors] = lotta(ids,[])
	if len(ids)==0:
		print("Denna rond kan inte lottas! (Troligen för många ronder)")
		break

	print(ids)

	for i in range(N//2):
		a = ids[2*i]
		b = ids[2*i+1]
		persons[a]['opps'].append(b)
		persons[b]['opps'].append(a)
		persons[a]['color'].append(colors[2*i])
		persons[b]['color'].append(colors[2*i+1])
		x = random.random()
		if x < 0.1:   res = [1,1]
		elif x < 0.5: res = [0,2]
		else:         res = [2,0]
		persons[a]['result'].append(res[0])
		persons[b]['result'].append(res[1])
	visaLottning(ids)

print(N,R)
print((time.time_ns() - start)/10**6, "ms")
