ALFABET = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-/'
N = 0 # antal personer
R = 0 # antal ronder
DY = 30

# States:
# 2 Names
# 3 Tables
# 4 Result

seed = Math.random()
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

print = console.log
range = _.range
title = ''
datum = ''
persons = []
nameList = []
state = 0
rond = 0
ids = []
linesPerPage = 0

assert = (a,b) -> if a!=b then print "Assert failure: '#{a}' != '#{b}'"

buttons = [[],[],[],[],[]]
released = true
message = '' #This is a tutorial tournament. Use it or edit the URL'

fetchURL = (url = window.location.search) ->
	res = {}
	urlParams = new URLSearchParams url
	persons = []
	title = urlParams.get('T').replace "_",""
	datum = urlParams.get 'D'

	res.N = urlParams.get('N').replaceAll('_',' ').split '|'
	N = res.N.length

	if not (4 <= N <= 64)
		print "Error: Number of players must be between 4 and 64!"
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
		res.N = _.shuffle res.N
		persons = _.map range(N), (i) -> {id:i, n: res.N[i], c:'', r:'', s:0, opps:[], T:[]}
		print persons
			# persons.push {id:i, n: res.N[i], c:'', r:'', s:0, opps:[]}
		R = Math.round 1.5 * Math.log2 N # antal ronder
		#if N < 10 then R = 3

print "(#{window.location.search})"
if window.location.search == ''
	title = 'Wasa SK'
	datum = new Date()
	datum = datum.toISOString().split('T')[0]
	url = "?T=#{title.replace(" ","_")}&D=#{datum}&N=ANDERSSON_Anders|BENGTSSON_Bertil|CARLSEN_Christer|DANIELSSON_Daniel|ERIKSSON_Erik|FRANSSON_Ferdinand|GREIDER_Göran|HARALDSSON_Helge"
	location.replace url
else
	fetchURL()

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
	constructor : (@prompt,@x,@y,@w,@h,@click) ->
		@active = true
	draw : ->
		if not @active then return
		textAlign CENTER,CENTER
		rectMode CENTER
		if @prompt == 'next'
			fill 'black'
			rect @x,@y, @w,@h
			fill 'yellow'
		text @prompt,@x, @y + 0.5
	inside : (mx,my) -> @x-@w/2 <= mx <= @x+@w/2 and @y-@h/2 <= my <= @y+@h/2 and @active

createURL = ->
	res = "https://christernilsson.github.io/2023/044-Monrad"
	res += "?T=" + "Wasa SK KM blixt"
	res += "&D=" + "2023-11-25"
	res += "&N=" + (_.map persons, (person) -> person.n.replaceAll " ","_").join "|"
	if persons[0].opps.length> 0
		res += "&O=" + (_.map persons, (person) -> (_.map person.opps, (opp) -> ALFABET[opp]).join "").join "|"
		res += "&C=" + (_.map persons, (person) -> person.c).join "|"
		res += "&R=" + (_.map persons, (person) -> person.r).join "|"
	res


# fejkaData = ->
# 	förnamn = 'Anders Bertil Christer Daniel Erik Ferdinand Göran Helge'.split " "
# 	efternamn = 'ANDERSSON BENGTSSON CARLSEN DANIELSSON ERIKSSON FRANSSON GREIDER HARALDSSON'.split " "
# 	persons = []
# 	N = förnamn.length
# 	R = Math.round 1.5 * Math.log2 N
# 	for i in range N
# 		namn = efternamn[i%8] + ' ' + förnamn[i%8]
# 		persons.push {id:i, n: namn, c:'', r: '', s:0, opps:[], T:[0,0,0] }
# spara = (name) ->
# 	persons.push {s:0, id:persons.length, n:name, c:'', mandatory:0, colorComp:[], r:'', opps:[], T:[0,0,0]}

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
	colorize ids
	for i in range N//2
		a = ids[2*i]
		b = ids[2*i+1]
		persons[a].opps.push b
		persons[b].opps.push a
	print "#{new Date() - start} milliseconds"
	state = 2

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

transferResult = ->
	for i in range N//2
		a = ids[2*i]
		b = ids[2*i+1]
		#prompt = buttons[3][2+3*i].prompt
		#buttons[3][2+3*i].prompt = ''
		#res = {'1 - 0':'20', '½ - ½':'11', '0 - 1':'02'}[prompt]		
		persons[a].r += '2' #res[0]
		persons[b].r += '0' # res[1]

########### GUI ############

visaHeader = (header) ->
	y = DY/2
	textAlign CENTER,CENTER
	txt "#{title} #{datum}" ,5/700*width,y,LEFT,'black'
	txt header, 0.5*width,y,CENTER
	txt rond+1, 0.9*width,y,RIGHT

txt = (value, x, y, align=null, color=null) ->
	if align then textAlign align,CENTER
	if color then fill color
	text value,x,y

visaNamnlista = ->
	visaHeader 'Names'
	nameList = _.sortBy persons, ['n']
	textSize DY*0.5
	#txt "Namelist Round #{rond+1}",350,30,CENTER,'black'
	#txt 'Table Name',10,50,LEFT
	for i in ids
		person = nameList[i]
		x = width/2 * (i // 32)
		y = 80 + DY * (i % 32)
		bord = 1 + ids[i]//2
		fill if 'B' == _.last person.c then 'black' else 'white'
		txt bord,30+x,y,RIGHT
		txt person.n,40+x,y,LEFT

	buttons[3][0].active = true #false
	txt message, 350, height-20, CENTER

visaBordslista = ->
	visaHeader 'Tables'
	#txt "Table List Round #{rond+1}", 350, 40,CENTER,'lightgray'
	#txt "Click on a winner or in the middle. Twice cancels", width/2, 40 + 40*N,CENTER,'lightgray'
	y = 1.5 * DY
	txt '#',50/700*width,y,CENTER,'white'
	txt 'Score',100/700*width,y,CENTER,'white'
	txt 'Result',0.5*width,y,CENTER,'lightgray'
	txt 'Score',6/7*width,y,CENTER,'black'
	txt '#', 6.5/7 * width,y,CENTER,'black'
	txt 'White', 210/700*width,y,CENTER,'white'
	txt 'Black', 490/700*width,y,CENTER,'black'

	for i in range N//2
		y = DY * (i+2.5)
		a = persons[ids[2*i]]
		b = persons[ids[2*i+1]]

		pa = sum a.r
		pb = sum b.r
		nr = i+1
		txt nr,50/700*width,y,CENTER,'white'
		txt prRes(pa), 100/700*width,y
		txt '-',0.5*width,y,CENTER,'lightgray'
		txt prRes(pb), 600/700*width,y,CENTER,'black'
		txt nr, 650/700*width,y

lightbulb = (color, x, y, result, opponent) ->
	push()
	fill 'red yellow green'.split(' ')[result]
	circle x,y,0.9*DY
	fill {B:'black', W:'white'}[color]
	textSize DY * 0.6
	if result=='1' and color=='W'
		stroke 'black'
		strokeWeight = 1
	else 
		noStroke()
		strokeWeight = 0
	txt 1+opponent,x,y+2,CENTER
	pop()

visaResultat = ->
	visaHeader 'Result'
	if ids.length == 0
		txt "This round can't be paired! (Too many rounds)",width/2,height/2,CENTER
		return

	noStroke()
	calcT rond
	calcScore()

	temp = _.sortBy persons, ['s', 'T']
	ids = _.map temp, (person) -> person.id

	ids = ids.reverse()
	inv = invert ids # pga korstabell

	# textAlign CENTER,CENTER
	# arr = "0½1"
	# fill 'white'
	# textSize 16
	# for res in "012"
	# 	x = [50,90,130][res]
	# 	txt arr[res],x,15
	# 	lightbulb 'W',x,40,res,N-1
	# 	lightbulb 'B',x,80,res,N-1

	#textSize 16
	#txt "Result after round #{rond+1}",355,40

	y = 1.5 * DY
	textAlign CENTER
	for r in range R
		txt r+1,220/700*width+DY*r, y
	txt "Score",570/700*width,y
	#txt "Tiebreak",640,y-20
	txt "D",610/700*width,y
	txt "W",640/700*width,y
	txt "B",670/700*width,y

	fill 'white' 
	textSize DY * 0.5
	for i in range N
		p = persons[i]
		y = DY * (inv[i]+2.5)
		txt 1+inv[i],25/700*width,y,RIGHT
		txt p.n,35/700*width,y,LEFT
		for r in range rond+1
			x = 220/700*width+DY*r
			lightbulb p.c[r][0], x, y, p.r[r], inv[p.opps[r]]

		# textSize 16
		score = prRes sum p.r
		txt score, 570/700*width, y, CENTER,'white'

		txt prRes(p.T[0]),610/700*width,y
		txt p.T[1],640/700*width,y
		txt prRes(p.T[2]),670/700*width,y

setPrompt = (button,prompt) -> 
	button.prompt = if button.prompt == prompt then '' else prompt
	ok = true
	for button in buttons[3].slice 1
		if button.prompt == '' then ok = false
	buttons[3][0].active = ok

window.windowResized = -> 
	DY = 30*windowWidth/windowHeight
	linesPerPage = windowHeight / DY
	resizeCanvas windowWidth, windowHeight * [34,34,34,34,66][state] * linesPerPage

window.setup = ->
	createCanvas windowWidth,windowHeight
	DY = 50*width/1000
	# DY = 30 # windowHeight/(N/2+2)
	print N + ' players ' + R + ' rounds'
	textAlign CENTER,CENTER
	lotta()

	linesPerPage = windowHeight/DY
	resizeCanvas windowWidth, windowHeight * 34 / linesPerPage

	buttons[2].push new Button 'next', 670/700*width,20, 60,20, -> 
		linesPerPage = windowHeight/DY
		resizeCanvas windowWidth, windowHeight * 34 / linesPerPage
		state = 3

	buttons[3].push new Button 'next', 670/700*width,20, 60,20, ->
		linesPerPage = windowHeight/DY
		resizeCanvas windowWidth, windowHeight * 66 / linesPerPage
		transferResult()
		state = 4

	for i in range N//2
		y = DY * (i+2.5)
		a = persons[ids[2*i]]
		b = persons[ids[2*i+1]]
		n = buttons[3].length
		do (n) ->
			buttons[3].push new Button a.n,210/700*width,y, 180,30, -> setPrompt buttons[3][n+1], '1 - 0'
			buttons[3].push new Button '', 350/700*width,y,  90,30, -> setPrompt buttons[3][n+1], '½ - ½'
			buttons[3].push new Button b.n,490/700*width,y, 180,30, -> setPrompt buttons[3][n+1], '0 - 1'

	buttons[4].push new Button 'next', 670/700*width,20, 60,20, ->
		linesPerPage = windowHeight/DY
		resizeCanvas windowWidth, windowHeight * 34 / linesPerPage
		s = createURL()
		print s
		copyToClipboard s
		if rond < R-1
			rond += 1
			lotta()

window.draw = ->
	background 'gray'
	for button in buttons[state]
		button.draw()
	if state <= 1 then text "State #{state}",100,100
	else if state == 2 then visaNamnlista()
	else if state == 3 then visaBordslista()
	else if state == 4 then visaResultat()

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
