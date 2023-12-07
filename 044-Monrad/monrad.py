import random
import time
import math
import mwmatching

# sys.setrecursionlimit(8000)

# Klarar upp till 1950 spelare.
# 1600 spelar tar 1866 millisekunder för alla 16 ronderna. (Python, pair)
# T1 är inbördes möte. Används bara för att särskilja två spelare
# T2 är antal vinster
# T3 är Buchholz. Summan av motståndarnas poäng

start = time.time_ns()

#random.seed(10)

persons = []
nameList = []

def save(name):
	persons.append({'id':len(persons), 'name':name, 'opps':[], 'color':[], 'mandatory':0, 'colorComp':[], 'result':[], 'T1':0, 'T2':0, 'T3':0}) # color: 1=W -1=B

#for name in 'Adam Bert Curt Dana Erik Falk Gran Hans IIII JJJJ KKKK LLLL MMMM NNNN OOOO PPPP QQQQ RRRR SSSS TTTT'.split(" "): save(name)
#for name in 'Adam Bert Curt Dana Erik Fina Gorm Hans'.split(" "): save(name)
for i in range(32): save(i)

N = len(persons)
R = int(round(1.5*math.log2(N))) # antal ronder
if N < 10: R=3
R = 20
print(N,'players,',R,'rounds')
print()

score = lambda p: sum(persons[p]['result'])
getMet = lambda a,b: b in persons[a]['opps']
färg = lambda i: 'W' if i==1 else "B"

# Tag fram lista för varje spelare med personer man inte mött

def colorize(ids):
	for i in range(len(ids)//2):
		pa = persons[ids[2*i]]
		pb = persons[ids[2*i+1]]
		if pa["mandatory"]: pac = pa["mandatory"]
		elif pb["mandatory"]: pac = -pb["mandatory"]
		elif pa["colorComp"] < pb["colorComp"]: pac = 1
		else: pac = -1
		pa["color"].append(pac)
		pb["color"].append(-pac)
	z=99

# def lotta(ids,pairing=[]):
# 	# print(ids,pairing)
# 	if len(pairing) == N: return pairing
# 	for a in ids: # a är ett personindex
# 		for b in ids: # b är ett personindex
# 			if a == b: continue # man kan inte möta sig själv
# 			if getMet(a,b): continue # a och b får ej ha mötts tidigare
# 			mandatory = persons[a]["mandatory"] + persons[b]["mandatory"]
# 			if abs(mandatory) == 2: continue # Spelarna kan inte ha samma färg.
# 			newids = [id for id in ids if not id in [a,b]]
# 			newPairing = pairing + [a,b]
# 			result = lotta(newids,newPairing)
# 			if len(result) == N: return result
# 	return []

def lotta(ids):
	arr = []
	for a in ids:
		for b in ids:
			if a>=b: continue
			if getMet(a, b): continue
			mandatory = persons[a]["mandatory"] + persons[b]["mandatory"]
			if abs(mandatory) == 2: continue # Spelarna kan inte ha samma färg.
			arr.append([a+1, b+1, 1000 - abs(score(a) - score(b))])
	#print(len(arr))
	z = mwmatching.maxWeightMatching(arr)
	z = z[1:N+1]
	res = []
	for i in range(N):
		if i < z[i]-1:
			res += [i,z[i]-1]
	return res

def visaNamnlista(rond,ids):
	print('=== Namelist Round',rond+1,'===')
	print('Table Colour Name')
	ids = invert(ids)
	for i in range(N):
		person = persons[nameList[i]]
		print(str(1+ids[i]//2) + färg(person["color"][-1]),person['name'])
	print()

def visaBordslista(rond,ids):
	print('=== Tables Round',rond+1,'===')
	print(' # Score White  Remis  Black Score')
	res = []
	for i in range(N//2):
		ia = ids[2*i]
		ib = ids[2*i+1]
		a = persons[ia]
		b = persons[ib]
		lst = [sum(a['result']),sum(b['result'])]
		lst.sort(reverse=True)
		res.append([lst,ia,ib])
	res.sort(reverse=True)
	for i in range(N//2):
		[_,ia,ib] = res[i]
		a = persons[ia]
		b = persons[ib]
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
		res[arr[i]] = i
	return res

def antal(p,color):
	return sum([1 for c in p["color"] if color==c])

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
		sRonder = ' '.join([str(1+inv[p['opps'][i]]) + färg(p['color'][i])[0] + prRes(p['result'][i]) for i in range(rond+1)])
		print(1+inv[p['id']],'  ',p['name'],sRonder, '',prRes(sum(p['result'])),' ',prRes(T1),T2,'',prRes(T3),antal(p,1),antal(p,-1))

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

	nameList = list(range(len(persons)))
	nameList.sort(key=lambda p: persons[p]['name'])

	for p in persons:
		colorSum = sum(p["color"])
		latest = sum(p["color"][-1:])
		latest2 = sum(p["color"][-2:])

		p["mandatory"] = 0
		if colorSum <= -1 or latest2 == -2: p["mandatory"] =  1
		if colorSum >=  1 or latest2 ==  2: p["mandatory"] = -1
		p["colorComp"] = [colorSum,latest] # fundera på ordningen här.

	ids = list(range(N))
	ids.sort(key=lambda p: score(p),reverse=True)

	ids = lotta(ids)
	if len(ids)==0:
		print("Denna rond kan inte lottas! (Troligen för många ronder)")
		break

	colorize(ids)

	print(ids)
	visaNamnlista(rond,ids)
	visaBordslista(rond,ids)

	for i in range(N//2):
		a = ids[2*i]
		b = ids[2*i+1]
		persons[a]['opps'].append(b)
		persons[b]['opps'].append(a)
		x = random.random()
		if x < 0.1:   res = [1,1]
		elif x < 0.5: res = [0,2]
		else:         res = [2,0]
		persons[a]['result'].append(res[0])
		persons[b]['result'].append(res[1])

	visaLottning(ids)
	if rond==R-1: visaResultat(rond,ids)

print()
print(round((time.time_ns() - start)/10**6,3), "ms")
