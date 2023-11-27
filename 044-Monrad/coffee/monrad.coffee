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
	res += "&N=" + (_.map persons, (person) -> person.n.replaceAll " ","_").join "|"
	if persons[0].opps.length> 0
		res += "&O=" + (_.map persons, (person) -> (_.map person.opps, (opp) -> ALFABET[opp]).join "").join "|"
		res += "&C=" + (_.map persons, (person) -> person.c).join "|"
		res += "&R=" + (_.map persons, (person) -> person.r).join "|"
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
			persons.push {id:i, n: res.N[i], c:res.C[i], r:res.R[i], s:0, opps:res.O[i], T:[0,0,0] }

	else
		for i in range N
			persons.push {id:i, n: res.N[i], c:'', r:'', s:0, opps:[]}
		R = Math.round 1.5 * Math.log2 N # antal ronder
		if N < 10 then R = 3

fejkaData = () ->
	förnamn = 'ABCDEFGH' #.split ""
	efternamn = 'ABCDEFGH' # _.map förnamn, (namn) -> namn + "sson"
	persons = []
	N = 64
	R = 9
	for i in range 64
		namn = förnamn[i//8] + efternamn[i%8]
		persons.push {id:i, n: namn, c:'', r: '', s:0, opps:[], T:[0,0,0] }
#fetchURL()
fejkaData()

start = new Date()

sum = (s) ->
	res = 0
	for item in s
		res += parseInt item
	res

spara = (name) ->
	persons.push {s:0, id:persons.length, n:name, c:'', mandatory:0, colorComp:[], r:'', opps:[], T:[0,0,0]}
#for i in range 16
#	spara(i)

print N + ' players ' + R + ' rounds'
print()

score =  (p) -> sum persons[p].r
getMet = (a,b) -> b in persons[a].opps

colorize = (ids) ->
	for i in range ids.length//2
		pa = persons[ids[2*i]]
		pb = persons[ids[2*i+1]]
		if pa.mandatory
			pac = if pa.mandatory==1 then 'W'  else 'B'
		else if pb.mandatory
			pac = if pa.mandatory==1 then 'B'  else 'W'
		else 
			if pa.colorComp < pb.colorComp then pac = 'W' else pac = 'B'
		pa.c += pac
		pb.c += if pac=='W' then 'B'  else 'W'

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
		print "#{bord}#{_.last(person.c)} #{person.n}"
	print()

visaBordslista = (rond,ids) ->
	print '=== Tables Round',rond+1,'==='
	print ' # Score W R B Score'
	for i in range N//2
		a = persons[ids[2*i]]
		b = persons[ids[2*i+1]]
		pa = sum a.r
		pb = sum b.r
		nr = (i+1).toString()
		if nr.length==1 then nr = ' ' + nr
		print nr,' ',prRes(pa).padEnd(2),a.n.padEnd(2),'-',b.n.padEnd(2),' ',prRes(pb)
	print()

visaLottning = (ids) ->
	print 'Lottning'
	for p in ids
		person = persons[p]

prRes = (score) ->
	if score % 2 == 1 then remis = '½' else remis = ''
	score = (score//2).toString()
	score = score + remis
	if score == '0½' then score = '½'
	score

invert = (arr) ->
	res = [0,0,0,0,0,0,0,0]
	for i in range arr.length
		res[arr[i]] = i
	return res

antal = (p,color) ->
	return sum [1 for c in p.c when color==c]

visaResultat = (rond,ids) ->
	calcT rond
	calcScore()
	sRonder = _.map range(rond+1), (i) -> "R#{i+1}".padStart 5
	sRonder = sRonder.join ''

	temp = _.sortBy persons, ['s', 'T']
	ids = _.map temp, (person) -> person.id

	ids = ids.reverse()
	inv = invert ids # pga korstabell
	print '=== Result after round',rond+1,'==='
	print ' # N',sRonder, 'Score Tie'
	for i in ids
		p = persons[i]
		T0 = prRes p.T[0]
		T1 = p.T[1]
		T2 = prRes p.T[2]
		sRonder = _.map range(rond+1), (r) -> "#{1+inv[p.opps[r]]}#{p.c[r][0]}#{prRes(p.r[r])}".padStart 5
		sRonder = sRonder.join ''

		nr = (1+inv[p.id]).toString()
		if nr.length==1 then nr = ' ' + nr
		pn = p.n.padEnd 2 #20
		score = prRes(sum(p.r)).padEnd 2
		print "#{nr} #{pn} #{sRonder}   #{score}   #{T0}  #{T1} #{T2}"  #, antal(p,1), antal(p,-1)"

calcScore = () ->
	for person in persons
		person.s = parseInt sum person.r

setT0 = (p,q) ->
	if q in persons[p].opps
		rond = persons[p].opps.indexOf q
		persons[p].T[0] = persons[p].r[rond]

calcT = (rond) ->
	# T ska beräknas först när allt är klart!
	# Beräkna T1 bara för de poänggrupper som har exakt två personer och då enbart om de har mött varandra.
	# Oklart om detta används för grupper med t ex tre personer. Låg sannolikhet att alla mött varandra.
	scores = {}
	for p in range persons.length
		person = persons[p]
		key = sum person.r
		if key of scores then scores[key].push p
		else scores[key] = [p]
		person.T[0] = 0
	for key of scores
		if scores[key].length == 2
			[p,q] = scores[key]
			setT0 p,q
			setT0 q,p

	for p in persons
		p.T[1] = p.r.split("").filter((x) => x == '2').length
		p.T[2] = 0
		for i in p.opps
			p.T[2] += sum persons[i].r # Buchholz: summan av motståndarnas poäng

print persons

for rond in range R
	nameList = range persons.length
	nameList.sort (p) -> persons[p].n

	for p in persons
		colorSum = sum p.c
		latest = if p.c.length== 0 then 0 else _.last p.c
		latest2 = if p.c.length < 2 then 0 else sum _.slice p.c, p.c.length - 2

		p.mandatory = 0
		if colorSum <= -1 or latest2 == -2 then p.mandatory =  1
		if colorSum >=  1 or latest2 ==  2 then p.mandatory = -1
		p.colorComp = [colorSum,latest] # fundera på ordningen här.

	calcScore()
	temp = _.sortBy persons, ['s']
	ids = _.map temp, (person) -> person.id
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
		if x < 0.1 then res = "11"
		else if x < 0.5 then res = "02"
		else res = "20"
		persons[a].r += res[0]
		persons[b].r += res[1]

	visaLottning ids
	if rond == R-1 then visaResultat rond,ids

print persons
print createURL()

print()
print(new Date() - start)
