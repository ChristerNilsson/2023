ALFABET = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-/'
N = 0 # antal personer
R = 0 # antal ronder

DY = 40

seed = 12 # Math.random()
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

print = console.log
range = _.range
persons = []
nameList = []
state = 0
rond = 0
ids = []

assert = (a,b) ->
	if a!=b then print "Assert failure: '#{a}' != '#{b}'"

createURL = ->
	res = ""
	res += "?T=" + "Wasa SK KM blixt"
	res += "&D=" + "2023-11-25"
	res += "&N=" + (_.map persons, (person) -> person.n.replaceAll " ","_").join "|"
	if persons[0].opps.length> 0
		res += "&O=" + (_.map persons, (person) -> (_.map person.opps, (opp) -> ALFABET[opp]).join "").join "|"
		res += "&C=" + (_.map persons, (person) -> person.c).join "|"
		res += "&R=" + (_.map persons, (person) -> person.r).join "|"
	res

fetchURL = ->
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

fejkaData = ->
	förnamn = 'Anders Bertil Christer Daniel Erik Ferdinand Göran Helge'.split " "
	efternamn = 'ANDERSSON BENGTSSON CARLSEN DANIELSSON ERIKSSON FRANSSON GREIDER HARALDSSON'.split " "
	persons = []
	N = 8
	R = 4
	for i in range 8
		namn = efternamn[i%8] + ' ' + förnamn[i%8]
		persons.push {id:i, n: namn, c:'', r: '', s:0, opps:[], T:[0,0,0] }

sum = (s) ->
	res = 0
	for item in s
		res += parseInt item
	res

sumBW = (s) ->
	res = 0
	for item in s
		res += if item=='B' then -1 else 1
	res

spara = (name) ->
	persons.push {s:0, id:persons.length, n:name, c:'', mandatory:0, colorComp:[], r:'', opps:[], T:[0,0,0]}
#for i in range 16
#	spara(i)

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

pair = (ids,pairing=[]) ->
	if pairing.length == N then return pairing
	for a in ids # a är ett personindex
		for b in ids # b är ett personindex
			if a == b then continue # man kan inte möta sig själv
			if getMet a,b then continue # a och b får ej ha mötts tidigare
			mandatory = persons[a].mandatory + persons[b].mandatory
			if 2 == Math.abs mandatory then continue # Spelarna kan inte ha samma färg.
			newids = (id for id in ids when id not in [a,b])
			newPairing = pairing.concat [a,b]
			result = pair newids,newPairing
			if result.length == N then return result
	return []

lotta = ->

	start = new Date()

	# prepare pairing
	for p in persons
		colorSum = sumBW p.c
		latest = if p.c.length== 0 then 0 else _.last p.c
		latest2 = if p.c.length < 2 then 0 else sumBW _.slice p.c, p.c.length - 2

		p.mandatory = 0
		if colorSum <= -1 or latest2 == -2 then p.mandatory =  1
		if colorSum >=  1 or latest2 ==  2 then p.mandatory = -1
		p.colorComp = [colorSum,latest] # fundera på ordningen här.

	calcScore()
	temp = _.sortBy persons, ['s']
	ids = _.map temp, (person) -> person.id
	ids = ids.reverse()

	ids = pair ids

	# update persons
	colorize ids

	for i in range N//2
		a = ids[2*i]
		b = ids[2*i+1]
		persons[a].opps.push b
		persons[b].opps.push a

	print "#{new Date() - start} milliseconds"

	state = 2

visaLottning = (ids) ->
	print 'Lottning'
	for p in ids
		person = persons[p]

prRes = (score) ->
	score = parseInt score
	if score == 1 then return '½'
	a = (score // 2).toString()
	if score % 2 == 1 then b='½' else b=''
	a + b
assert '0', prRes '0'
assert '½', prRes '1'
assert '1', prRes '2'
assert '1½', prRes 3
assert '10', prRes 20
assert '10½', prRes 21

invert = (arr) ->
	res = []
	for i in range arr.length
		res[arr[i]] = i
	return res

antal = (p,color) ->
	return sum [1 for c in p.c when color==c]

calcScore = ->
	for person in persons
		person.s = parseInt sum person.r

setT0 = (p,q) ->
	if q in persons[p].opps
		r = persons[p].opps.indexOf q
		persons[p].T[0] = persons[p].r[r]

calcT = ->
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

fejkaResultat = ->
	for i in range N//2
		a = ids[2*i]
		b = ids[2*i+1]
		x = random()
		if x < 0.1 then res = "11"
		else if x < 0.5 then res = "02"
		else res = "20"
		persons[a].r += res[0]
		persons[b].r += res[1]

########### GUI ############

window.setup = ->
	#fetchURL()
	fejkaData()
	createCanvas 710,100 + N*40
	print N + ' players ' + R + ' rounds'
	textAlign CENTER,CENTER
	lotta()

window.draw = ->

	visaNamnlista = ->
		nameList = range N
		nameList.sort (p) -> persons[p].n

		nameList = _.sortBy persons, ['n']
		#print nameList
		textSize 16
		textAlign CENTER,CENTER
		fill 'black'
		text "Namelist Round #{rond+1}",350,30
		textAlign LEFT,CENTER
		text 'Table Name',10,60
		#ids = invert ids
		for i in ids
			person = nameList[i]
			x = 350 * (i // 32)
			y = 90+30*(i % 32)
			bord = 1 + ids[i]//2
			fill if 'B' == _.last person.c then 'black' else 'white'
			textAlign RIGHT,CENTER
			text bord,30+x,y
			textAlign LEFT,CENTER
			text person.n,40+x,y

	visaBordslista = ->
		text "Tables Round #{rond+1}", 100, 40
		text '# Score W R B Score',100,80
		for i in range N//2
			a = persons[ids[2*i]]
			b = persons[ids[2*i+1]]
			pa = sum a.r
			pb = sum b.r
			nr = (i+1).toString()
			if nr.length==1 then nr = ' ' + nr
			text "#{nr} #{prRes(pa).padEnd(2)} #{a.n.padEnd(2)} - #{b.n.padEnd(2)} #{prRes(pb)}", 100, 100 + i*30

	lightbulb = (color, x, y, result, opponent) ->
		fill 'red yellow green'.split(' ')[result]
		circle x,y,30
		fill {B:'black', W:'white'}[color]
		textSize 20
		push()
		if result=='1' and color=='W'
			stroke 'black'
			strokeWeight = 1
		else 
			noStroke()
			strokeWeight = 0
		text 1+opponent,x,y+2
		pop()

	visaResultat = ->
		if ids.length == 0
			text "Denna rond kan inte lottas! (Troligen för många ronder)",100,100
			return

		noStroke()
		calcT rond
		calcScore()

		temp = _.sortBy persons, ['s', 'T']
		ids = _.map temp, (person) -> person.id

		ids = ids.reverse()
		inv = invert ids # pga korstabell

		textAlign CENTER,CENTER
		arr = "0½1"
		for res in "012"
			x = [50,90,130][res]
			fill 'white'
			textSize 16
			text arr[res],x,15
			lightbulb 'W',x,40,res,N-1
			lightbulb 'B',x,80,res,N-1

		textSize 16
		textAlign CENTER,CENTER
		fill 'white'
		text "Result after round #{rond+1}",355,40

		textAlign LEFT,CENTER
		
		y = 80
		textAlign CENTER,CENTER
		for r in range R
			text r+1,220+40*r, y
		text "Score",580,y
		textAlign LEFT,CENTER
		text "Tiebreak",610,y-20
		text "D",610,y
		text "W",640,y
		text "B",670,y

		for i in range N

			p = persons[i]

			y = DY*(inv[i]+3)
			fill 'white'
			textSize 16
			textAlign RIGHT,CENTER
			text 1+inv[i],25,y
			textAlign LEFT,CENTER
			text p.n,35,y
			textAlign CENTER,CENTER
			for r in range rond+1
				x = 220+40*r
				lightbulb p.c[r][0], x, y, p.r[r], inv[p.opps[r]]

			textSize 16
			textAlign CENTER,CENTER
			fill 'white'
			score = sum(p.r)
			text score, 570, y

			text prRes(p.T[0]),610,y
			text p.T[1],640,y
			text prRes(p.T[2]),670,y

	background 'gray'
	
	if state <= 1 then text "State #{state}",100,100
	else if state == 2 then visaNamnlista()
	else if state == 3 then visaBordslista()
	else if state == 4 then visaResultat()

window.mousePressed = ->
	if state==2
		state=3
	else if state==3
		fejkaResultat()
		print persons
		state=4
	else if state==4
		print createURL()
		if rond < R-1
			rond += 1
			lotta()
