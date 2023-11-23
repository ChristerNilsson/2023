import random
import time
import math

# Klarar upp till 1600 spelare på 1678 millisekunder för alla 15 ronderna. (Python)
# T1 är inbördes möte. Används bara för att särskilja två spelare
# T2 är antal vinster
# T3 är Buchholz. Summan av motståndarnas poäng

start = time.time_ns()

random.seed(10)

persons = []

def save(name):
	persons.append({'id':len(persons), 'name':name, 'opps':[], 'color':[], 'mandatory':0, 'colorComp':[], 'result':[], 'T1':0, 'T2':0, 'T3':0}) # color: 1=W -1=B

for name in 'Adam Bert Curt Dana Erik Falk Gran Hans'.split(" "):
#for name in '0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'.split(" "):
#for i in range(1600):
#for name in 'A B C D E F G H'.split(" "):
	save(name)

N = len(persons)
R = 3+int(round(math.log2(N))) # antal ronder
print(N,'players,',R,'rounds')
print()

score = lambda p: sum(persons[p]['result'])
getMet = lambda a,b: b in persons[a]['opps']
färg = lambda i: 'White' if i==1 else "Black"

# Tag fram lista för varje spelare med personer man inte mött
def lotta(ids,pairing=[],colors = []):
	print(ids,pairing,colors)
	if len(pairing) == N: return [pairing,colors]
	for a in ids: # a är ett personindex
		for b in ids: # b är ett personindex
			if a == b: continue # man kan inte möta sig själv
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

def visaNamnlista(rond,ids,colors):
	print('=== Namelist Round',rond+1,'===')
	print('Name Table Colour')
	for i in range(len(ids)):
		person = persons[ids[i]]
		print(person['name'],' ',1+ids[i]//2,' ',färg(colors[i]))
	print()

def visaBordslista(rond,ids):
	print('=== Tables Round',rond+1,'===')
	print(' # Score White  Remis  Black Score')
	for i in range(N//2):
		a = persons[ids[2*i]]
		b = persons[ids[2*i+1]]
		pa = sum(a['result'])/2
		pb = sum(b['result'])/2
		print('',i+1,' ',pa,a["name"],'         ',b["name"],' ',pb)
	print()

def visaLottning(ids):
	print('Lottning')
	for p in ids:
		person = persons[p]
		print(person)
		#print(person['id'],person['name'],person['opps'],person['result'])

def prRes(score):
	score = str(score/2)
	if score=='0.5':
		return '½ '
	else:
		return score.replace('.5','½').replace('.0',' ')

def invert(arr):
	res = [0] * len(arr)
	for i in range(len(arr)):
		res[arr[i]] = i+1
	return res

def visaResultat(rond,ids):

	calcTB(rond)

	sRonder = '   '.join(['R'+str(i+1) for i in range(rond+1)])

	ids.sort(key=lambda p: [score(p),persons[p]['T1'], persons[p]['T2'], persons[p]['T3']],reverse=True)

	inv = invert(ids) # pga korstabell

	print('=== Result after round',rond+1,'===')
	print('Rank Name',sRonder, ' Score  T1 T2 T3')
	for i in ids:
		p = persons[i]
		T1 = p["T1"]
		T2 = str(p["T2"])
		T3 = p["T3"]
		sRonder = ' '.join([str(inv[p['opps'][i]]) + färg(p['color'][i])[0] + prRes(p['result'][i]) for i in range(rond+1)])
		print(inv[p['id']],'  ',p['name'],sRonder, '',prRes(sum(p['result'])),' ',prRes(T1),T2,'',prRes(T3))

def setT1(p,q):
	if q in persons[p]['opps']:
		rond = persons[p]['opps'].index(q)
		persons[p]["T1"] = persons[p]["result"][rond]

def calcTB(rond):
	# T ska beräknas först när allt är klart!
	# Beräkna T1 bara för de poänggrupper som har exakt två personer och då enbart om de har mött varandra.
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
			setT1(p,q)
			setT1(q,p)
	for p in persons:
		p['T2'] = p['result'].count(2) # Antal vinster
		p['T3']= sum([sum(persons[i]['result']) for i in p['opps']]) # Buchholz: summan av motståndarnas poäng

for rond in range(R):
	for p in persons:
		colorSum = sum(p["color"])
		latest = sum(p["color"][-1:])

		p["mandatory"] = 0
		if colorSum <= -2: p["mandatory"] =  1
		if colorSum >=  2: p["mandatory"] = -1
		p["colorComp"] = [latest,colorSum] # fundera på ordningen här.
	ids = list(range(N))

	ids.sort(key=lambda p: score(p),reverse=True)

	[ids,colors] = lotta(ids,[])
	if len(ids)==0:
		print("Denna rond kan inte lottas! (Troligen för många ronder)")
		break

	#print(ids)
	visaNamnlista(rond,ids,colors)
	visaBordslista(rond,ids)

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
	#visaLottning(ids)

	if rond==R-1: visaResultat(rond,ids)

print()
print(round((time.time_ns() - start)/10**6), "ms")
