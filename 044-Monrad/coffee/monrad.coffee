# LOW ########################################
# Återinför scorepoints vid GAMES == 1

# TODO #######################################
# Inför Swiss
# Hantera kontrollinmatning av resultat
# Hantera frirond
# Skriv ut URL i samband med lottning till egen fil.

# Ge perfekt felmeddelande för fel i URL-en. (EASY)
#   Fel antal ronder i Color, Result
#   Fel antal ELO

# Välj Monrad eller Swiss i URL-en (LOW)
# Parkera spelare

# localStorage (i princip urlen)
# Hastighetsjämförelser (javafo, swiss-manager, min kod, monrad, swiss)

# Testa på Mac. (klippbordet)

# DONE #########################################
# Alfabetisk Namnlista? Namn Bord Färg
# Print bordslista
# Hantera 1 till 8 partier per team/person GAMES=1 (default)

# NOT TODO #####################################
# Repetition av piltangenter (NIX, går för fort)
# Två kolumner vid många spelare
# Backa en eller flera ronder? (Kan göras mha sparade URL:er)
# Ange färg för första bordet i URL-en (EASY) FIRST=WHITE, FIRST=BLACK (default)

HELP = """
How to use the Schwisch Chess Tournament Program:
	Enter = Switch between Tables and Result
	Home = Select First Table
	Up   = Select Previous Table
	Down = Select Next Table
	End  = Select Last Table
	0 = Enter a Loss for White Player
	space = Enter a Draw
	1 = Enter a Win for White Player
	P = Perform Pairing
	S = Make text smaller
	L = Make text larger
	? = Show this Help Page
	H = Show Help for constructing the URL
""".split '\n'

ASCII = '0123456789abcdefg'

N = 0 # number of players
ROUNDS = 0 # number of rounds
DY = 75 # vertical line distance
DY = 40 # vertical line distance

TOUR = ''
GAMES = 1
FIRST = 'black'

print = console.log
range = _.range
title = ''
datum = ''
currentTable = 0

persons = [] # stabil, sorterad på id
pairings = [] # varierar med varje rond

state = 0 # 0=Tables 1=Result 2=Help
ROUND = 0
resultat = [] # 012 sorterad på id

showType = (a) -> if typeof a == 'string' then "'#{a}'" else a
assert = (a,b) -> if not _.isEqual a,b then print "Assert failure: #{showType a} != #{showType b}"

ok = (p0, p1) -> p0 != p1 and p0.id not in p1.opp and abs(p0.bal + p1.bal) <= 1 # eller 2
other = (col) -> if col == 'b' then 'w' else 'b'
balans = (col) -> if col == 'w' then 1 else -1

flip = (p0,p1) -> # p0 byter färg, p0 anpassar sig
	col0 = _.last p0.col
	col1 = col0
	col0 = other col0
	p0.col += col0
	p1.col += col1
	p0.bal += balans col0
	p1.bal += balans col1

assignColors = (p0,p1) ->
	if p0.col.length == 0
		col1 = "bw"[p0.id % 2]
		col0 = other col1 # "bw"[1 - p0.id % 2]
		p0.col += col0
		p1.col += col1
		# bal = 1 if col0 == 'w' else -1
		p0.bal += balans col0
		p1.bal += balans col1
	else
		bal = p0.bal + p1.bal
		if bal == 0
			flip p0,p1
		else if 2 == abs bal
			if 2 == abs p0.bal
				flip p0,p1
			else
				flip p1,p0

message = '' #This is a tutorial tournament. Use it or edit the URL'

myRound = (x,decs) -> 
	s = (_.round x,decs).toString()
	if '.' not in s then s += '.0'
	s
assert "2.0", myRound 1.99,1
assert "0.6", myRound 0.6,1

ints2strings = (ints) -> "#{ints}"
assert "1,2,3", ints2strings [1,2,3]
assert "1", ints2strings [1]
assert "", ints2strings []

res2string = (ints) -> (i.toString() for i in ints).join ''
assert "123", res2string [1,2,3]
assert "1", res2string [1]
assert "", res2string []

# string2ints = (s) -> 
# 	print s
# 	print s.split(",")
# 	res = _.map s.split(","), (item) -> parseInt item
# 	print res
# 	res
#assert [], string2ints ""
#assert [1], string2ints "1"
#assert [1,2], string2ints "1,2"
# assert [1,2,3], string2ints "1,2,3"

fetchURL = (url = location.search) ->
	res = {}
	urlParams = new URLSearchParams url
	persons = []
	TOUR = urlParams.get('TOUR').replace '_',' '
	datum = urlParams.get('DATE') or ""
	ROUNDS = parseInt urlParams.get('ROUNDS')
	ROUND = parseInt urlParams.get('ROUND')

	res.NAME = urlParams.get('NAME').replaceAll('_',' ').split '|'
	res.ELO = urlParams.get('ELO').split '|'
	res.ELO = _.map res.ELO, (r) -> parseInt r
	N = res.NAME.length

	if N < 4
		print "Error: Number of players must be 4 or more!"
		return
	if N > 64
		print "Error: Number of players must be 64 or less!"
		return

	GAMES = if urlParams.get 'GAMES' then parseInt urlParams.get 'GAMES' else 1
	FIRST = if urlParams.get 'FIRST' then urlParams.get 'FIRST' else 'black'

	print {GAMES,FIRST}

	if ROUND > 0

		res.OPP = urlParams.get('OPP').split '|'
		res.COL = urlParams.get('COL').split '|'
		res.RES = urlParams.get('RES').split '|'
		if res.NAME.length != res.OPP.length != res.COL.length != res.RES.length != res.ELO.length
			print "Error: Illegal number of players in OPP, COL, ELO or RES!"
			return
		R = res.RES[0].length

		print('a',res)
		res.OPP = _.map res.OPP, (r) -> _.map r.split(','), (s) -> parseInt s
		#res.COL = _.map res.COL, (r) -> _.map r, (ch) -> {B:-1,W:1}[ch]
		res.RES = _.map res.RES, (r) -> _.map r, (ch) -> parseInt ch
		#res.RES = _.map res.RES, string2ints 
		print('b',res)

		for i in range N
			if R != res.OPP[i].length != res.COL[i].length != res.RES[i].length
				print "Error: Illegal number of rounds for player #{res.NAME[i]}!"
				return
			persons.push {id:i, name: res.NAME[i], col:res.COL[i], res:res.RES[i], bal:0, opp:res.OPP[i], T:[0,0,0], elo:res.ELO[i] }
		print(persons)
		calcScore()
		print(persons)

	else
		if N % 2 == 1
			res.NAME.push '-frirond-'
			N += 1
		persons = _.map range(N), (i) -> {id:i, name: res.NAME[i], elo: res.ELO[i], col:'', res:[], bal:0, opp:[], T:[]}
	print persons

copyToClipboard = (text) ->
	if !navigator.clipboard
		textarea = document.createElement 'textarea'
		textarea.value = text
		document.boF.appendChild textarea
		textarea.select()
		document.execCommand 'copy'
		document.boF.removeChild textarea
		message = 'Urlen har kopierats till klippbordet 1'
	else
		navigator.clipboard.writeText text
		.then => message = 'Urlen har kopierats till klippbordet 2'
		.catch (err) => message 'Kopiering till klippbordet misslyckades'

createURL = ->
	res = []
	#res.push "https://christernilsson.github.io/2023/044-Monrad"
	res.push "http://127.0.0.1:5500"
	res.push "?TOUR=" + TOUR.replace ' ','_'
	res.push "&DATE=" + "2023-11-25"
	res.push "&ROUNDS=" + ROUNDS
	res.push "&ROUND=" + ROUND
	res.push "&NAME=" + (_.map persons, (person) -> person.name.replaceAll " ","_").join "|"
	res.push "&ELO=" + (_.map persons, (person) -> person.elo).join "|"
	#if persons[0].opp.length> 0
	res.push "&OPP=" + (_.map persons, (person) -> (_.map person.opp, ints2strings)).join "|"
	res.push "&COL=" + (_.map persons, (person) -> person.col).join "|"
	res.push "&RES=" + (_.map persons, (person) -> res2string person.res).join "|"
	res.join '\n'

sum = (s) ->
	res = 0
	for item in s
		res += parseInt item
	res
assert 6, sum '012012'

sumBW = (s) ->
	res = 0
	for item in s
		res += if item=='B' then -1 else 1
	res
assert 0, sumBW ''
assert 0, sumBW 'BWBWWB'
assert -6, sumBW 'BBBBBB'
assert 6, sumBW 'WWWWWW'

scorex = (res,r=ROUND-1) ->
	print 'scorex',res,r
	result = 0
	for i in range r
		result += res[i]
	result / 2
assert 0, scorex [],0
assert 2.5, scorex [0,1,2,2],4

getMet = (a,b) -> b.id in persons[a.id].opp

pair = (persons,pairing=[]) ->
	if pairing.length == N then return pairing
	a  = persons[0]
	for b in persons
		if not ok a,b then continue
		newPersons = (p for p in persons when p not in [a,b])
		newPairing = pairing.concat [a,b]
		result = pair newPersons,newPairing
		if result.length == N then return result
	return []

adjustForColors = (pairings) ->
	res = []
	for i in range N//2
		if pairings[2*i].col.length == 0 or 'W' == _.last(pairings[2*i].col)
			res.push pairings[2*i] # W
			res.push pairings[2*i+1] # B
		else
			res.push pairings[2*i+1] # W
			res.push pairings[2*i] # B
	res

downloadFile = (txt,filename) ->
	print 'filename',filename
	blob = new Blob [txt], { type: 'text/plain' }
	url = URL.createObjectURL blob
	a = document.createElement 'a'
	a.href = url
	a.download = filename
	document.body.appendChild a
	a.click()
	document.body.removeChild a
	URL.revokeObjectURL url

makeTableFile = (header) ->
	res = []

	players = ([pairings[i],i] for i in range N)
	players = _.sortBy players, (p) -> p[0].name
	players = ("#{_.pad((1+i//2).toString()+'WB'[i%2] ,5)} #{p.name}" for [p,i] in players)

	res.push "NAMES" + header
	res.push ""
	res.push "Table Name"
	for p in players
		res.push p
	res.push "\f"

	res.push "TABLES" + header
	res.push ""
	res.push "Table White".padEnd(6+25) + _.pad("",20) + 'Black'.padEnd(25)
	for i in range N//2
		a = pairings[2*i]
		b = pairings[2*i+1]
		res.push ""
		res.push _.pad(i+1,6) + a.name.padEnd(25) + _.pad("|____| - |____|",20) +  b.name.padEnd(25)
	res.join "\n"	

lotta = ->
	print 'Lottning av rond ',ROUND
	document.title = 'Round ' + (ROUND+1)
	print persons
	for p in persons
		if p.res.length != p.col.length then return
	print 'genomförs!'
	for p in persons
		colorSum = sumBW p.col
		latest = if p.col.length== 0 then '' else _.last p.col
		latest2 = if p.col.length < 2 then '' else sumBW _.slice p.col, p.col.length - 2

		# p.mandatory = 0
		# if colorSum <= -1 or latest2 == -2 then p.mandatory =  1
		# if colorSum >=  1 or latest2 ==  2 then p.mandatory = -1
		# p.colorComp = [colorSum,latest] # fundera på ordningen här.

	calcScore()
	if ROUND == 0
		pairings = persons
		print 'pairings',pairings
		ROUND = 1
	else
		ROUND += 1
		pairings = _.sortBy persons, ['score']
		pairings = pairings.reverse()
		start = new Date()

		pairings = pair pairings
		# print 'pairings',pairings
		print ROUND, "#{new Date() - start} milliseconds"

	# colorize pairings
	# assignColors pairings

	pairings = adjustForColors pairings
	for i in range N//2
		a = pairings[2*i]
		b = pairings[2*i+1]
		a.opp.push b.id
		b.opp.push a.id
		assignColors a,b

	state = 0

	timestamp = new Date().toLocaleString 'se-SE'
	print "ROUND",ROUND
	downloadFile makeTableFile(" for " + TOUR + " in Round #{ROUND}    #{timestamp}"), TOUR + " Round #{ROUND}.txt"
	downloadFile createURL(), "URL for " + TOUR + " Round #{ROUND}.txt"

	print {'pairings after pairing',pairings}

# Beror på GAMES som varierar mellan 1 och 8
prBoth = (score) ->
	a = ASCII.indexOf score
	b = 2 * GAMES - a
	ax = prRes score
	bx = prRes ASCII[b]
	if ax.length == 1 then ax = ' ' + ax
	if bx.length == 1 then bx = bx + ' '
	ax + ' - ' + bx

prRes = (score) ->
	score = ASCII.indexOf score
	a = "#{score // 2}"
	if a == "0" then a=""
	b = if score % 2 == 1 then '½' else ''
	if a+b == "" then return '0'
	a+b
assert '0',  prRes '0'
assert '½',  prRes '1'
assert '1',  prRes '2'
assert '1½', prRes '3'
assert '4',  prRes '8'
assert '5',  prRes 'a'
assert '5½', prRes 'b'

invert = (arr) ->
	res = []
	for i in range arr.length
		res[arr[i]] = i
	return res
assert [0,1,2,3], invert [0,1,2,3]
assert [3,2,0,1], invert [2,3,1,0]

calcScore = ->
	for person in persons
		person.score = scorex person.res
	print('calcScore',persons)

setT0 = (p,q) ->
	if q in persons[p].opp
		r = persons[p].opp.indexOf q
		persons[p].T[0] = persons[p].res[r]

calcT = ->
	# T ska beräknas först när allt är klart!
	# Beräkna T1 bara för de poänggrupper som har exakt två personer och då enbart om de har mött varandra.
	# Oklart om detta används för grupper med t ex tre personer. Låg sannolikhet att alla mött varandra.
	scores = {}
	for p in range persons.length
		person = persons[p]
		key = sum person.res
		if key of scores then scores[key].push p
		else scores[key] = [p]
		person.T[0] = 0
	for key of scores
		if scores[key].length == 2
			[p,q] = scores[key]
			setT0 p,q
			setT0 q,p

	for p in persons
		p.T[1] = p.res.split("").filter((x) => x == '2').length
		p.T[2] = 0
		for i in p.opp
			p.T[2] += sum persons[i].res # Buchholz: the sum of opposition scores

mw = (x) -> x/1000 * width

########### GUI ############

txtT = (value, w, align=window.CENTER) -> 
	if value.length > w then value = value.substring 0,w
	if align==window.LEFT then res = value + _.repeat ' ',w-value.length
	if align==window.RIGHT then res = _.repeat(' ',w-value.length) + value
	if align==window.CENTER 
		diff = w-value.length
		lt = _.repeat ' ',(1+diff)//2
		rt = _.repeat ' ',diff//2
		res = lt + value + rt
	res
assert "   Sven   ", txtT "Sven",10

showHeader = (header) ->
	y = DY/2
	textAlign LEFT,CENTER
	s = ''
	s += txtT "#{title} #{datum}" ,30, window.LEFT
	s += ' ' + txtT header, 22, window.CENTER
	s += ' ' + txtT 'Round ' + ROUND, 30, window.RIGHT
	fill 'black'
	text s,10,y

txt = (value, x, y, align=null, color=null) ->
	if align then textAlign align,CENTER
	if color then fill color
	text value,x,y

showTables = ->
	showHeader 'Tables'
	y = 1.5 * DY
	s = ""
	s +=       txtT '#', 2,window.RIGHT
	s += ' ' + txtT 'Score', 5,window.RIGHT
	s += ' ' + txtT 'Elo',   4,window.LEFT
	s += ' ' + txtT 'White', 25,window.LEFT
	s += ' ' + txtT 'Result',7,window.CENTER
	s += ' ' + txtT 'Black', 25,window.LEFT
	s += ' ' + txtT 'Elo',   4,window.LEFT
	s += ' ' + txtT 'Score', 5,window.RIGHT
	fill 'black'
	textAlign window.LEFT
	text s,10,y

	for i in range N//2
		y += DY*0.5
		a = pairings[2*i  ] # White
		b = pairings[2*i+1] # Black
		# pa = myRound scorex(a.res), 1
		# pb = myRound scorex(b.res), 1
		pa = myRound a.score, 1
		pb = myRound b.score, 1
		both = if a.res.length == a.col.length then prBoth _.last(a.res) else "   -   "

		nr = i+1
		s = ""
		s += txtT nr.toString(), 2, window.RIGHT
		s += ' ' + txtT pa, 5
		s += ' ' + txtT a.elo, 4
		s += ' ' + txtT a.name, 25, window.LEFT

		s += ' ' + txtT both,7, window.CENTER

		s += ' ' + txtT b.name, 25, window.LEFT
		s += ' ' + txtT b.elo, 4
		s += ' ' + txtT pb, 5, window.CENTER
		fill if currentTable==i then 'yellow' else 'black'
		text s,10,y

lightbulb = (color, x, y, result, opponent) ->
	# print 'lightbulb',color, x, y, result, opponent
	push()
	# print 'lightbulb',result
	fill 'red gray green'.split(' ')[result]
	rectMode CENTER
	rect x,y,0.8*DY,0.45*DY
	fill {b:'black', w:'white'}[color]
	noStroke()
	strokeWeight = 0
	txt 1+opponent,x,y+1,CENTER
	pop()

showResult = ->
	showHeader 'Result'
	if pairings.length == 0
		txt "This ROUND can't be paired! (Too many rounds)",width/2,height/2,CENTER
		return

	noStroke()
	calcT()
	# calcScore()

	temp = _.sortBy persons, ['score', 'T']
	temp = temp.reverse()

	inv = (p.id for p in temp)
	inv = invert inv

	y = 1.5 * DY
	textAlign LEFT
	rheader = _.map range(1,ROUNDS+1), (i) -> "#{i%10} "
	rheader = rheader.join ' '

	s = ""
	s +=       txtT "#",    2
	s += ' ' + txtT "Elo",  4,window.LEFT
	s += ' ' + txtT "Name", 25,window.LEFT
	s += ' ' + txtT rheader,3*ROUNDS,window.LEFT 
	s += ' ' + txtT "Score",5,window.RIGHT
	s += ' ' + txtT "D",    2,window.CENTER
	s += ' ' + txtT "W",    1,window.CENTER
	s += ' ' + txtT "B",    2,window.CENTER
	text s,10,y

	fill 'white' 
	#textSize DY * 0.5
	for person,i in temp
		y += DY * 0.5
		s = ""
		s +=       txtT (1+i).toString(), 2, window.RIGHT
		s += ' ' + txtT person.elo,       4, window.LEFT
		s += ' ' + txtT person.name,     25, window.LEFT
		s += ' ' + txtT '', 3*ROUNDS, window.CENTER
		score = person.score # scorex person.res
		score = myRound score,1
		s += ' ' + txtT score,             5, window.RIGHT
		s += ' ' + txtT prRes(person.T[0]),2,window.CENTER
		s += ' ' + txtT       person.T[1], 2,window.CENTER
		s += ' ' + txtT prRes(person.T[2]),2,window.CENTER
		text s,10,y

		#print('round',round)
		for r in range ROUND-1
			x = DY * (10.5 + 0.9*r)
			print r,person.col[r][0], x, y, person.res[r], inv[person.opp[r]]
			lightbulb person.col[r][0], x, y, person.res[r], inv[person.opp[r]]

if location.search == ''
	title = 'Tutorial Tournament'
	datum = new Date()
	datum = datum.toISOString().split('T')[0]
	url = "?T=#{title.replace(" ","_")}&NAME=ANDERSSON_Anders|BENGTSSON_Bertil|CARLSEN_Christer|DANIELSSON_Daniel|ERIKSSON_Erik|FRANSSON_Ferdinand|GREIDER_Göran|HARALDSSON_Helge"
	location.href = url
else
	fetchURL()
	pairings = persons

showHelp = ->
	textAlign LEFT
	for i in range HELP.length
		text HELP[i],100,50+50*i

window.windowResized = -> 
	resizeCanvas windowWidth-4,windowHeight-4
	xdraw()

window.setup = ->
	createCanvas windowWidth-4,windowHeight-4
	textFont 'Courier New'
	textAlign CENTER,CENTER
	lotta()
	state = 0
	xdraw()

xdraw = ->
	background 'gray'
	textSize DY * 0.5
	if state == 0 then showTables()
	if state == 1 then showResult()
	if state == 2 then showHelp()

window.keyPressed = ->
	if key == 'Home' then currentTable = 0
	if key == 'ArrowUp' then currentTable = (currentTable - 1) %% (N//2)
	if key == 'ArrowDown' then currentTable = (currentTable + 1) %% (N//2)
	if key == 'End' then currentTable = (N//2) - 1
	index = 2*currentTable
	a = pairings[index]
	b = pairings[index+1]
	if key in '0 1q2w3e4r5t6y7u8'
		index = '0 1q2w3e4r5t6y7u8'.indexOf key
		if index <= 2 * GAMES
			if a.res.length < a.col.length then a.res.push index
			if b.res.length < b.col.length then b.res.push 2*GAMES - index
			currentTable = (currentTable + 1) %% (N//2)
	if key == 'Enter'
		state = 1 - state
		if state == 1
			calcT()
	if key in 'pP' then lotta()
	if key in 'lL' then DY += 1
	if key in 'sS' then DY -= 1
	xdraw()
