# T1 är inbördes möte. Används bara för att särskilja två spelare
# T2 är antal vinster
# T3 är Buchholz. Summan av motståndarnas poäng

ALFABET = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-/'
N = 0 # antal personer
R = 0 # antal ronder

seed = 12 # Math.random()
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

print = console.log
range = _.range
persons = []
nameList = []

createURL = () ->
	res = ""
	res += "?T=" + "Wasa SK KM blixt"
	res += "&D=" + "2023-11-25"
	res += "&N=" + (_.map persons, (person) -> person.name.replaceAll " ","_").join "|"
	if persons[0].opps.length> 0
		res += "&O=" + (_.map persons, (person) -> (_.map person.opps, (opp) -> ALFABET[opp]).join "").join "|"
		res += "&C=" + (_.map persons, (person) -> (_.map person.color, (c) -> "B W"[c+1]).join "").join "|"
		res += "&R=" + (_.map persons, (person) -> person.result.join "").join "|"
	res

fetchURL = () ->
	res = {}
	urlParams = new URLSearchParams window.location.search
	persons = []
	res.T = urlParams.get 'T'
	res.D = urlParams.get 'D'

	res.N = urlParams.get('N').replaceAll('_',' ').split '|'
	N = res.N.length

	if not (4 <= N <= 64)
		print "Error: Number players must be between 4 and 64!"
		return

	if res.O and res.C and res.R

		res.O = urlParams.get('O').split '|'
		res.C = urlParams.get('C').split '|'
		res.R = urlParams.get('R').split '|'
		if res.N.length != res.O.length != res.C.length != res.R.length
			print "Error: Illegal number of players in O, C or R!"
			return
		R = res.R[0].length

		res.O = _.map res.O, (r) -> _.map r, (ch) -> ALFABET.indexOf ch
		res.C = _.map res.C, (r) -> _.map r, (ch) -> {B:-1,W:1}[ch]
		res.R = _.map res.R, (r) -> _.map r, (ch) -> parseInt ch

		for i in range N
			if R != res.O[i].length != res.C[i].length != res.R[i].length
				print "Error: Illegal number of rounds for player #{res.N[i]}!"
				return
			persons.push {id:i, score:0, name: res.N[i], opps:res.O[i], color:res.C[i], result:res.R[i], T1:0, T2:0, T3:0 }

	else
		for i in range N
			persons.push {id:i, score:0, name: res.N[i], opps:[], color:[], result:[] }
		R = Math.round 1.5 * Math.log2 N # antal ronder
		if N < 10 then R = 3

fejkaData = () ->
	förnamn = 'Adam Bert Curt Dana Erik Fina Gorm Hans'.split " "
	efternamn = _.map förnamn, (namn) -> namn + "sson"
	persons = []
	for i in range 64
		namn = förnamn[i//8] + ' ' + efternamn[i%8]
		persons.push {id:i, score:0, name: namn, opps:[], color:[], result: [], T1:0, T2:0, T3:0 }
fetchURL()
#fejkaData()

start = new Date()

sum = (arr) ->
	res = 0
	for item in arr
		res += item
	res

spara = (name) ->
	persons.push {score:0, id:persons.length, name:name, opps:[], color:[], mandatory:0, colorComp:[], result:[], T1:0, T2:0, T3:0}
#for i in range 16
#	spara(i)

# for name in 'Adam Bert Curt Dana Erik Fina Gorm Hans'.split " "
# 	spara name
#spara(name) for name in 'Adam Bert Curt Dana Erik Falk Gran Hans IIII JJJJ KKKK LLLL MMMM NNNN OOOO PPPP QQQQ RRRR SSSS TTTT'.split(" ")
#for person in persons
#	print person

print N + ' players ' + R + ' rounds'
print()

score =  (p) -> sum persons[p].result
getMet = (a,b) -> b in persons[a].opps
färg = (i) -> if i==1 then 'W' else "B"

# Tag fram lista för varje spelare med personer man inte mött

colorize = (ids) ->
	for i in range ids.length//2
		pa = persons[ids[2*i]]
		pb = persons[ids[2*i+1]]
		if pa.mandatory then pac = pa.mandatory
		else if pb.mandatory then pac = -pb.mandatory
		else if pa.colorComp < pb.colorComp then pac = 1
		else pac = -1
		pa.color.push pac
		pb.color.push -pac

lotta = (ids,pairing=[]) ->
	if pairing.length == N then return pairing
	for a in ids # a är ett personindex
		for b in ids # b är ett personindex
			if a == b then continue # man kan inte möta sig själv
			if getMet a,b then continue # a och b får ej ha mötts tidigare
			mandatory = persons[a].mandatory + persons[b].mandatory
			if 2 == Math.abs mandatory then continue # Spelarna kan inte ha samma färg.
			newids = (id for id in ids when id not in [a,b])
			newPairing = pairing.concat [a,b]
			result = lotta newids,newPairing
			if result.length == N then return result
	return []

visaNamnlista = (rond,ids) ->
	print '=== Namelist Round',rond+1,'==='
	print 'Table Colour Name'
	ids = invert ids
	for i in range N
		person = persons[nameList[i]]
		bord = (1+ids[i]//2).toString().padStart 2
		print "#{bord}#{färg(_.last(person.color))} #{person.name}"
	print()

visaBordslista = (rond,ids) ->
	print '=== Tables Round',rond+1,'==='
	print ' # Score White  Remis  Black Score'
	for i in range N//2
		a = persons[ids[2*i]]
		b = persons[ids[2*i+1]]
		pa = sum a.result
		pb = sum b.result
		nr = (i+1).toString()
		if nr.length==1 then nr = ' ' + nr
		print nr,' ',prRes(pa).padEnd(2),a.name.padEnd(20),'-',b.name.padEnd(20),' ',prRes(pb)
	print()

visaLottning = (ids) ->
	print 'Lottning'
	for p in ids
		person = persons[p]

prRes = (score) ->
	if score % 2 == 1 then remis = '½' else remis = ''
	score = (score//2).toString()
	#if score == "0" then score =''
	score = score + remis
	if score == '0½' then score = '½'
	score
	# score.replace('.5','½').replace('.0',' ')

invert = (arr) ->
	res = [0,0,0,0,0,0,0,0]
	for i in range arr.length
		res[arr[i]] = i
	return res

antal = (p,color) ->
	return sum [1 for c in p.color when color==c]

visaResultat = (rond,ids) ->
	calcTB rond
	calcScore()
	sRonder = _.map range(rond+1), (i) -> "R#{i+1}".padStart 5
	sRonder = sRonder.join ''

	temp = _.sortBy persons, ['score', 'T1', 'T2', 'T3']
	ids = _.map temp, (person) -> person.id

	ids = ids.reverse()
	inv = invert ids # pga korstabell

	print '=== Result after round',rond+1,'==='
	print ' # Name               ',sRonder, 'Score T1 T2 T3'
	for i in ids
		p = persons[i]
		T1 = prRes p.T1
		T2 = p.T2
		T3 = prRes p.T3
		sRonder = _.map range(rond+1), (r) -> "#{1+inv[p.opps[r]]}#{färg(p.color[r])[0]}#{prRes(p.result[r])}".padStart 5
		sRonder = sRonder.join ''

		nr = (1+inv[p.id]).toString()
		if nr.length==1 then nr = ' ' + nr
		pn = p.name.padEnd 20
		score = prRes(sum(p.result)).padEnd 2
		print "#{nr} #{pn} #{sRonder}   #{score}   #{T1}  #{T2} #{T3}"  #, antal(p,1), antal(p,-1)"

calcScore = () ->
	for person in persons
		person.score = parseInt sum person.result

setT1 = (p,q) ->
	if q in persons[p].opps
		rond = persons[p].opps.indexOf q
		persons[p].T1 = persons[p].result[rond]

calcTB = (rond) ->
	# T ska beräknas först när allt är klart!
	# Beräkna T1 bara för de poänggrupper som har exakt två personer och då enbart om de har mött varandra.
	# Oklart om detta används för grupper med t ex tre personer. Låg sannolikhet att alla mött varandra.
	scores = {}
	for p in range persons.length
		person = persons[p]
		key = sum person.result
		if key of scores then scores[key].push p
		else scores[key] = [p]
		person.T1 = 0
	for key of scores
		if scores[key].length == 2
			[p,q] = scores[key]
			setT1 p,q
			setT1 q,p

	for p in persons
		p.T2 = p.result.filter((x) => x == 2).length
		p.T3 = 0
		for i in p.opps
			p.T3 += sum persons[i].result # Buchholz: summan av motståndarnas poäng

print persons

for rond in range R
	nameList = range persons.length
	nameList.sort (p) -> persons[p].name

	for p in persons
		colorSum = sum p.color
		latest = if p.color.length== 0 then 0 else _.last p.color
		latest2 = if p.color.length < 2 then 0 else sum _.slice p.color, p.color.length - 2

		p.mandatory = 0
		if colorSum <= -1 or latest2 == -2 then p.mandatory =  1
		if colorSum >=  1 or latest2 ==  2 then p.mandatory = -1
		p.colorComp = [colorSum,latest] # fundera på ordningen här.

	calcScore()
	temp = _.sortBy persons, ['score']
	ids = _.map temp, (person) -> person.id

	# ids = range N
	# ids = _.sortBy ids, (p) => ['score'] #['score', 'T1', 'T2', 'T3']
	ids = ids.reverse()

	print({ids})

	ids = lotta ids,[]
	if ids.length == 0
		print "Denna rond kan inte lottas! (Troligen för många ronder)"
		break

	colorize ids

	visaNamnlista rond,ids
	print temp.reverse()
	visaBordslista rond,ids

	for i in range N//2
		a = ids[2*i]
		b = ids[2*i+1]
		persons[a].opps.push b
		persons[b].opps.push a
		x = random()
		if x < 0.1 then res = [1,1]
		else if x < 0.5 then res = [0,2]
		else res = [2,0]
		persons[a].result.push res[0]
		persons[b].result.push res[1]

	visaLottning ids
	if rond == R-1 then visaResultat rond,ids

print createURL()

print()
print(new Date() - start)
