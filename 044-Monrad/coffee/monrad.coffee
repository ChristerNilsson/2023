# import {maxWeightMatching} from './mwmatching.js'

# ALFABET = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-/' # ½
N = 0 # antal personer
ROUNDS = 0 # antal ronder
#ROUND = 0
DY = 30 # radavstånd i pixlar

# States:
# 2 Names
# 3 Tables
# 4 Result

# seed = 14 # Math.random()
# random = ->
# 	seed++
# 	(((Math.sin(seed)/2+0.5)*10000)%100)/100

print = console.log
range = _.range
title = ''
datum = ''

persons = [] # stabil, sorterad på id
#nameList = [] # stabil, sorterad på namn
pairings = [] # varierar med varje rond

state = 3
print('state',state)
rond = 0 
resultat = [] # 012 sorterad på id
antal = 0 

showType = (a) -> if typeof a == 'string' then "'#{a}'" else a

assert = (a,b) -> if not _.isEqual a,b then print "Assert failure: #{showType a} != #{showType b}"

# selectRounds = (n) -> # antal ronder ska vara cirka 150% av antalet matcher i en cup. Samt jämnt.
# 	res = Math.floor 1.50 * Math.log2 n
# 	res += res % 2
# 	if 2*res > n then res -= 1
# 	if n==4 then res = 2
# 	res
# assert 2, selectRounds 4
# assert 3, selectRounds 6
# assert 4, selectRounds 10
# assert 6, selectRounds 12
# assert 6, selectRounds 24
# assert 8, selectRounds 26
# assert 8, selectRounds 60
# assert 10, selectRounds 64

buttons = [[],[],[],[],[]]
released = true
message = '' #This is a tutorial tournament. Use it or edit the URL'

fetchURL = (url = location.search) ->
	res = {}
	urlParams = new URLSearchParams url
	persons = []
	title = urlParams.get('TOUR').replace '_',' '
	datum = urlParams.get('DATE') or ""
	ROUNDS = parseInt urlParams.get('ROUNDS')
	rond = parseInt urlParams.get('ROUND')

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

	if res.OPP and res.COL and res.RES

		res.OPP = urlParams.get('OPP').split '|'
		res.COL = urlParams.get('COL').split '|'
		res.RES = urlParams.get('RES').split '|'
		if res.NAME.length != res.OPP.length != res.COL.length != res.RES.length != res.ELO.length
			print "Error: Illegal number of players in OPP, COL, ELO or RES!"
			return
		R = res.RES[0].length

		res.OPP = _.map res.OPP, (r) -> _.map r.split(',') #, (ch) -> ALFABET.indexOf ch
		res.COL = _.map res.COL, (r) -> _.map r, (ch) -> {B:-1,W:1}[ch]
		res.RES = _.map res.RES, (r) -> _.map r, (ch) -> parseInt ch

		for i in range N
			if R != res.OPP[i].length != res.COL[i].length != res.RES[i].length
				print "Error: Illegal number of rounds for player #{res.NAME[i]}!"
				return
			persons.push {id:i, name: res.NAME[i], col:res.COL[i], res:res.RES[i], bal:0, opp:res.OPP[i], T:[0,0,0], elo:res.ELO[i] }

	else
		if N % 2 == 1
			res.NAME.push '-frirond-'
			N += 1

		# res.NAME = _.shuffle res.NAME
		persons = _.map range(N), (i) -> {id:i, name: res.NAME[i], elo: res.ELO[i], col:'', res:'', bal:0, opp:[], T:[]}
		#R = selectRounds N
	#nameList = _.sortBy persons, ['name']
	print(persons)

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

class Button
	constructor : (@prompt,@fill,@click) ->
		@active = true
		@align = CENTER
	setExtent : (@x,@y,@w,@h) ->
	draw : ->
		if not @active then return
		textAlign @align,CENTER
		if @prompt == 'next'
			fill 'black'
			rectMode CENTER
			rect @x,@y, @w,@h
		fill @fill
		text @prompt,@x, @y + 0.5
	inside : (mx,my) -> @x-@w/2 <= mx <= @x+@w/2 and @y-@h/2 <= my <= @y+@h/2 and @active

createURL = ->
	res = "https://christernilsson.github.io/2023/044-Monrad"
	res += "?TOUR=" + "Wasa SK KM blixt"
	res += "&DATE=" + "2023-11-25"
	res += "&NAME=" + (_.map persons, (person) -> person.name.replaceAll " ","_").join "|"
	if persons[0].opp.length> 0
		res += "&OPP=" + (_.map persons, (person) -> (_.map person.opp, (opp) -> str(opp)).join ",").join "|"
		res += "&COL=" + (_.map persons, (person) -> person.col).join "|"
		res += "&RES=" + (_.map persons, (person) -> person.res).join "|"
	res

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

scorex =  (person) ->
	print 'scorex',person
	sum person.res
getMet = (a,b) -> b.id in persons[a.id].opp

colorize = (persons) ->
	for i in range persons.length//2
		pa = persons[2*i]
		pb = persons[2*i+1]
		pac = 'B W'[pa.mandatory+1]
		pbc = 'B W'[pb.mandatory+1]
		if pac == pbc
			if pa.colorComp <= pb.colorComp then pac = 'W' else pac = 'B'
		pa.col += pac
		pb.col += if pac=='W' then 'B'  else 'W'

pair = (persons,pairing=[]) ->
	#print 'persons',persons
	#print 'pairing',pairing
	if pairing.length == N then return pairing
	antal += 1
	a  = persons[0]
	for b in persons
		if a == b then continue # man kan inte möta sig själv
		if getMet a,b then continue # a och b får ej ha mötts tidigare
		mandatory = a.mandatory + b.mandatory
		if 2 == Math.abs mandatory then continue # Spelarna kan inte ha samma färg.
		# print "pair: #{pairing.length//2} #{a.id} - #{b.id}"
		newPersons = (p for p in persons when p not in [a,b])
		newPairing = pairing.concat [a,b]
		result = pair newPersons,newPairing
		if result.length == N then return result
	return []

adjustForColors = (pairings) ->
	res = []
	#print 'adjustForColors',pairings
	for i in range N//2
		if pairings[2*i].col.length == 0 or 'W' == _.last(pairings[2*i].col)
			res.push pairings[2*i] # W
			res.push pairings[2*i+1] # B
		else
			res.push pairings[2*i+1] # W
			res.push pairings[2*i] # B
	#print 'adjustForColors',res
	res

# lotta_inner = (pairings) -> # personer sorterade
# 	# denna funktion anpassar till maxWeightMatching
# 	arr = []
# 	#print 'aaa',pairings
# 	for a in pairings
# 		for b in pairings
# 			if a.id >= b.id then continue
# 			if getMet a, b then continue
# 			mandatory = a.mandatory + b.mandatory
# 			if Math.abs(mandatory) == 2 then continue # Spelarna kan inte ha samma färg.
# 			arr.push([a.id+1, b.id+1, 1000 - Math.abs(scorex(a) - scorex(b))])
# 	print('arr',arr)
# 	z = maxWeightMatching arr
# 	print 'z',z
# 	z = z.slice 1 #[1:N+1]
# 	res = []
# 	for i in range N
# 		if i < z[i]-1 then res.concat [i,z[i]-1]
# 	# res är ej sorterad i bordsordning ännu

# 	#print 'adam',res

# 	result = []
# 	for i in range(N//2)
# 		ia = res[2*i]
# 		ib = res[2*i+1]
# 		a = persons[ia]
# 		b = persons[ib]
# 		lst = [scorex(a),scorex(b)]
# 		lst.sort(reverse=True)
# 		result.append([lst,ia,ib])
# 	result.sort(reverse=True)

# 	resultat = []
# 	for i in range(N//2)
# 		[_,ia,ib] = result[i]
# 		resultat.concat [ia,ib]
# 		# a = persons[ia]
# 		# b = persons[ib]
# 		# pa = scorex(a) # sum(a['result'])/2
# 		# pb = scorex(b) # sum(b['result'])/2
# 		# print('',i+1,' ',pa,a["name"],'         ',b["name"],' ',pb)
# 	resultat

lotta = ->
	print 'lotta'
	# prepare pairing
	for p in persons
		colorSum = sumBW p.col
		latest = if p.col.length== 0 then '' else _.last p.col
		latest2 = if p.col.length < 2 then '' else sumBW _.slice p.col, p.col.length - 2

		p.mandatory = 0
		if colorSum <= -1 or latest2 == -2 then p.mandatory =  1
		if colorSum >=  1 or latest2 ==  2 then p.mandatory = -1
		p.colorComp = [colorSum,latest] # fundera på ordningen här.

	calcScore()
	if rond == 0
		pairings = persons
		print 'pairings',pairings
		#pairings = lotta_inner pairings
	else
		pairings = _.sortBy persons, ['score']
		pairings = pairings.reverse()
		start = new Date()
		antal = 0

		pairings = pair pairings
		print 'pairings',pairings
		#pairings = lotta_inner pairings

		print rond, "#{antal} #{new Date() - start} milliseconds"

	colorize pairings
	pairings = adjustForColors pairings
	for i in range N//2
		a = pairings[2*i]
		b = pairings[2*i+1]
		a.opp.push b.id
		b.opp.push a.id

	state = 3
	updateAllButtons()
	print('state',state)

	print {'pairings efter lottning',pairings}

prRes = (score) ->
	score = parseInt score
	if score == 1 then return '½'
	a = "#{score // 2}"
	b = if score % 2 == 1 then '½' else ''
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
assert [0,1,2,3], invert [0,1,2,3]
assert [3,2,0,1], invert [2,3,1,0]

calcScore = ->
	for person in persons
		person.score = parseInt sum person.res

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
			p.T[2] += sum persons[i].res # Buchholz: summan av motståndarnas poäng

mw = (x) -> x/1000 * width # (milliWidth)

########### GUI ############

showHeader = (header) ->
	y = DY/2
	textAlign CENTER,CENTER
	txt "#{title} #{datum}" ,mw(7),y,LEFT,'black'
	txt header, mw(500),y,CENTER
	txt rond+1, mw(900),y,RIGHT

txt = (value, x, y, align=null, color=null) ->
	if align then textAlign align,CENTER
	if color then fill color
	text value,x,y

# showNames = ->
# 	showHeader 'Names'
# 	textSize 0.5 * DY
# 	txt 'Table Name',mw(  5),DY*1.5,LEFT
# 	txt 'Table Name',mw(505),DY*1.5,LEFT
# 	for person,i in pairings
# 		x = mw(500) * (person.id // (N//2))
# 		y = DY * (2.5 + person.id % (N//2))
# 		bord = 1 + i//2
# 		fill if 'B' == _.last person.col then 'black' else 'white'
# 		txt bord,0.75*DY+x,y,RIGHT
# 		txt person.name,DY+x,y,LEFT

# 	buttons[3][0].active = false

showTables = ->
	showHeader 'Tables'
	y = 1.5 * DY
	txt '#',     mw( 75),y,CENTER,'white'
	txt 'Score', mw(150),y
	txt 'White', mw(200),y,LEFT
	txt 'Result',mw(500),y,CENTER,'lightgray'
	txt 'Black', mw(600),y,LEFT,'black'
	txt 'Score', mw(850),y
	txt '#',     mw(925),y

	for i in range N//2
		y = DY * (i+2.5)
		a = pairings[2*i  ] # White
		b = pairings[2*i+1] # Black

		pa = sum a.res
		pb = sum b.res
		nr = i+1
		txt nr,        mw( 75),y,CENTER,'white'
		txt prRes(pa), mw(150),y
		txt '-',       mw(500),y,CENTER,'lightgray'
		txt prRes(pb), mw(850),y,CENTER,'black'
		txt nr,        mw(925),y

lightbulb = (color, x, y, result, opponent) ->
	push()
	fill 'red gray green'.split(' ')[result]
	circle x,y,0.9*DY
	fill {B:'black', W:'white'}[color]
	textSize DY * 0.5
	if result=='1' and color=='W'
		#stroke 'black'
		strokeWeight = 1
	else 
		noStroke()
		strokeWeight = 0
	txt 1+opponent,x,y+2,CENTER
	pop()

showResult = ->
	showHeader 'Result'
	if pairings.length == 0
		txt "This round can't be paired! (Too many rounds)",width/2,height/2,CENTER
		return

	noStroke()
	calcT()
	calcScore()

	temp = _.sortBy persons, ['score', 'T']

	temp = temp.reverse()
	inv = (p.id for p in temp)
	inv = invert inv

	y = 1.5 * DY
	textAlign CENTER
	for r in range rond
		txt r+1,mw(330) + DY*r, y
	txt "Score",mw(850),y
	txt "D",    mw(900),y
	txt "W",    mw(930),y
	txt "B",    mw(960),y

	fill 'white' 
	textSize DY * 0.5
	for person,i in temp
		y = DY * (i+2.5)
		txt 1+i,mw(40),y,RIGHT
		txt person.name,mw(50),y,LEFT
		for r in range rond+1
			x = mw(330) + DY*r
			lightbulb person.col[r][0], x, y, person.res[r], inv[person.opp[r]]

		score = prRes sum person.res
		txt score, mw(850), y, CENTER,'white'

		txt prRes(person.T[0]),mw(900),y
		txt       person.T[1], mw(930),y
		txt prRes(person.T[2]),mw(960),y

setPrompt = (button,prompt) -> 
	button.prompt = if button.prompt == prompt then '-' else prompt
	for button in buttons[3].slice 1
		if button.prompt == '-'
			buttons[3][0].active = false
			return
	buttons[3][0].active = true

window.windowResized = ->
	DY = 30 # mw 50
	if state < 4
		resizeCanvas windowWidth, DY * (N//2+2)
	else
		resizeCanvas windowWidth, DY * (N+2)
	moveAllButtons()

transferResult = ->
	for i in range N//2
		button = buttons[3][2+3*i]
		white = {'1 - 0': 2,'½ - ½': 1,'0 - 1': 0}[button.prompt]
		pairings[2*i+0].res += "012"[white]
		pairings[2*i+1].res += "012"[2-white]
		button.prompt = '-'

moveAllButtons = ->
	buttons[2][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY
	buttons[3][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY
	buttons[4][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY

	for i in range N//2
		y = DY * (i+2.5)
		buttons[3][3*i+1].setExtent mw(200),y, mw(200),30
		buttons[3][3*i+2].setExtent mw(500),y, mw(200),30
		buttons[3][3*i+3].setExtent mw(600),y, mw(200),30

updateAllButtons = ->
	for i in range N//2
		white = pairings[2*i+0]
		black = pairings[2*i+1]
		buttons[3][3*i+1].prompt = white.name
		buttons[3][3*i+1].align = LEFT
		buttons[3][3*i+2].prompt = '-'
		buttons[3][3*i+3].prompt = black.name
		buttons[3][3*i+3].align = LEFT

createAllButtons = ->

	buttons = [[],[],[],[],[]]

	buttons[2].push new Button 'next', 'yellow', ->
		state = 3
		print('state',state)

		updateAllButtons()

	buttons[3] = []
	buttons[3].push new Button 'next', 'yellow', ->
		state = 4
		print('state',state)

		transferResult()
		windowResized()
	for i in range N//2
		n = buttons[3].length
		do (n) ->
			buttons[3].push new Button 'white','white',     -> setPrompt buttons[3][n+1], '1 - 0'
			buttons[3].push new Button '-',    'lightgray', -> setPrompt buttons[3][n+1], '½ - ½'
			buttons[3].push new Button 'black', 'black',    -> setPrompt buttons[3][n+1], '0 - 1'

	buttons[4].push new Button 'next', 'yellow', ->
		resizeCanvas windowWidth, DY * (N//2+2)
		s = createURL()
		print s
		copyToClipboard s
		if rond < ROUNDS-1
			rond += 1
			lotta()
			print {pairings}
	print "#{buttons[3].length + 2} buttons created"

if location.search == ''
	title = 'Tutorial Tournament'
	datum = new Date()
	datum = datum.toISOString().split('T')[0]
	url = "?T=#{title.replace(" ","_")}&NAME=ANDERSSON_Anders|BENGTSSON_Bertil|CARLSEN_Christer|DANIELSSON_Daniel|ERIKSSON_Erik|FRANSSON_Ferdinand|GREIDER_Göran|HARALDSSON_Helge"
	location.href = url
else
	fetchURL()
	pairings = persons

window.setup = ->
	createCanvas windowWidth,windowHeight
	createAllButtons()
	moveAllButtons()

	# print N + ' players ' + R + ' rounds'
	textAlign CENTER,CENTER
	lotta()
	updateAllButtons()

window.draw = ->
	background 'gray'
	for button in buttons[state]
		button.draw()
	# if state <= 1 then text "State #{state}",100,100
	# else if state == 2 then showNames()
	if state == 3 then showTables()
	else if state == 4 then showResult()

window.mousePressed = (event) ->
	event.preventDefault()
	if not released then return
	released = false
	for button in buttons[state]
		if button.inside mouseX,mouseY then button.click()
	false

window.mouseReleased = (event) ->
	event.preventDefault()
	released = true
	false

#############################

# N = 16
# for i in range N
# 	persons.push { id:i, name:i, col:"", res:"", score:0, opp:[], T:[0,0,0] }

start = new Date()
for rond in range 0 # N//2
	lotta()
	# for i in range N//2
		# a = pairings[2*i+0]
		# b = pairings[2*i+1]
		# z = random()
		# if z < 0.1 then res = 1
		# else if z < 0.5 then res =  0
		# else res = 2
		# a.res += res.toString()
		# b.res += (2-res).toString()
	print 'persons',persons
print "#{new Date() - start} milliseconds"

calcT()
temp = _.sortBy persons, ['score', 'T']
temp = temp.reverse()
print temp
