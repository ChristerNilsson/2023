# TODO #######################################
# WB ska vara wb överallt, även i urlen
# Inför Dutch Manager
# Hantera frirond
# Tie Break - hantering
# Sortera på [score, rating, name]
# Splittra resultat på två kolumner?

# Ge perfekt felmeddelande för fel i URL-en.
#   Fel antal ronder i Color, Result
#   Fel antal ELO

# Parkera spelare. PARK=12,34

# Testa på Mac. (klippbordet)

# Publicera på chess-results? Skapa lämplig fil.

# DONE #########################################
# Alfabetisk Namnlista. Bord Färg Namn => 1w NILSSON Christer
# Print bordslista
# Skriv ut URL i samband med lottning till egen fil.
# Inför en variabel TPP som anger antal Tables per sida. t ex TPP=30
# Inför en variabel PPP som anger antal Players per sida. t ex PPP=60
# Inför ScorePoints. SP=0.1 ger de sex talen, SP=0.0 är default
# FIRST avgör om första spelaren ska ha vit eller svart i första ronden
# Hantera kontrollinmatning av resultat
# Markera Table med gul rektangel
# Delete ska nollställa nuvarande resultat

# LOW ########################################
# Hastighetsjämförelser (javafo, swiss-manager, min kod, monrad, swiss)
# Jämför lottningsresultat. Förklara skillnader.

# NOT TODO #####################################
# Välj Monrad eller Swiss i URL-en (LOW)
# localStorage (i princip urlen) Behövs localStorage?
# Repetition av piltangenter (NIX, går för fort)
# Två kolumner vid många spelare
# Backa en eller flera ronder? (Kan göras mha sparade URL:er)
# Ange färg för första bordet i URL-en (EASY) FIRST=WHITE, FIRST=BLACK (default)
# Hantera 1 till 8 partier per team/person GAMES=1 (default)

import { parseExpr } from './parser.js'

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
	Delete = Remove erroneous result
	P = Perform Pairing
	S = Make text smaller
	L = Make text larger
	? = Show this Help Page
	H = Show Help for constructing the URL
""".split '\n'

ASCII = '0123456789abcdefg'
N = 0 # number of players
DY = 75 # vertical line distance
DY = 40 # vertical line distance

print = console.log
range = _.range
datum = ''
currentTable = 0
tournament = null
errors = [] # id för motsägelsefulla resultat. Tas bort med Delete

state = 0 # 0=Tables 1=Result 2=Help
resultat = [] # 012 sorterad på id

showType = (a) -> if typeof a == 'string' then "'#{a}'" else a
assert = (a,b) -> if not _.isEqual a,b then print "Assert failure: #{showType a} != #{showType b}"

ok = (p0, p1) -> p0.id != p1.id and p0.id not in p1.opp and abs(p0.balans() + p1.balans()) <= 1 # eller 2
other = (col) -> if col == 'b' then 'w' else 'b'

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

class Tournament 
	constructor : () ->
		@name = ''
		@rounds = 0
		@round = 0
		@sp = 0.1
		@tpp = 30
		@ppp = 60

		# dessa tre listor pekar på samma objekt
		@players = []
		@persons = [] # stabil, sorterad på id och elo
		@pairings = [] # varierar med varje rond

		@fetchURL()

	write : () ->

	lotta : () ->
		print 'Lottning av rond ',@round
		document.title = 'Round ' + (@round+1)
		print @players
		for p in @players
			if p.res.length != p.col.length then return

		if @round == 0
			@pairings = @players
			print 'Apairings',@pairings
			@round = 1
		else
			@round += 1
			@pairings = _.sortBy @players, (player) -> player.score()
			@pairings = @pairings.reverse()
			start = new Date()

			@pairings = @pair @pairings
			print 'Bpairings',@pairings
			print @round, "#{new Date() - start} milliseconds"

		#colorize @pairings
		#assignColors @pairings

		print 'A',@pairings

		@adjustForColors()

		for i in range N//2
			a = @pairings[2*i]
			b = @pairings[2*i+1]
			a.opp.push b.id
			b.opp.push a.id
			@assignColors a,b

		print 'B',@pairings

		state = 0

		timestamp = new Date().toLocaleString 'se-SE'
		print "ROUND",@round
		downloadFile tournament.makeTableFile(" for " + @name + " in Round #{@round}    #{timestamp}"), @name + " Round #{@round}.txt"
		downloadFile @createURL(), "URL for " + @name + " Round #{@round}.txt"

		print {'pairings after pairing', @pairings}

		xdraw()

	fetchURL : (url = location.search) ->
		print url
		getParam = (name,def) ->
			res = urlParams.get name
			#if res then res else def
			res || def

		urlParams = new URLSearchParams url
		@players = []
		@name = urlParams.get('TOUR').replace '_',' '
		@datum = urlParams.get('DATE') or ""
		@rounds = parseInt urlParams.get 'ROUNDS'
		@round = parseInt urlParams.get 'ROUND'

		@first = getParam 'FIRST','bw' # Determines if first player has white or black in the first round
		print 'first',@first
		@sp = parseFloat getParam 'SP', 0.0 # ScorePoints
		@tpp = parseInt getParam 'TPP',30 # Tables Per Page
		@ppp = parseInt getParam 'PPP',60 # Players Per Page

		res = {}
		names = urlParams.get('NAME').replaceAll('_',' ').split '|'
		elos = urlParams.get('ELO').split '|'
		elos = _.map elos, (elo) -> parseInt elo
		N = names.length

		if N < 4
			print "Error: Number of players must be 4 or more!"
			return
		if N > 100
			print "Error: Number of players must be 100 or less!"
			return

		for i in range N
			@players.push new Player i, names[i], elos[i], [], "", "" # @id, @name, @elo, @opp, @col, @res
		
		@players = _.sortBy @players, (player) -> player.elo
		@players = @players.reverse()

		for i in range N
			@players[i].id = i+1

		print 'sorted players', @players

		if @ROUND > 0
			opps = urlParams.get('OPP').split '|'
			cols = urlParams.get('COL').split '|'
			ress = urlParams.get('RES').split '|'
			if names.length != opps.length != cols.length != ress.length != elos.length
				print "Error: Illegal number of players in OPP, COL, ELO or RES!"
				return

			opps = _.map opps, (r) -> _.map opp.split(','), (s) -> parseInt s
			ress = _.map ress, (res) -> _.map res, (ch) -> parseInt ch

			for i in range N
				if ress[i].length != opps[i].length != cols[i].length != ress[i].length
					print "Error: Illegal number of rounds for player #{names[i]}!"
					return
				@players[i].name = names[i]
				@players[i].col = cols[i]
				@players[i].res = ress[i]
				@players[i].opp = opps[i] 
				#@players[i].tie = [0,0,0]
			print(@players)
		else
			if N % 2 == 1
				@players.push new Player '-frirond-'
				N += 1
				# persons = _.map range(N), (i) -> {id:i, name: res.NAME[i], elo: res.ELO[i], col:'', res:[], bal:0, opp:[], T:[]}

	flip : (p0,p1) -> # p0 byter färg, p0 anpassar sig
		print 'flip',p0.col,p1.col
		col0 = _.last p0.col
		col1 = col0
		col0 = other col0
		p0.col += col0
		p1.col += col1

	assignColors : (p0,p1) ->
		if p0.col.length == 0
			col1 = @first[p0.id % 2]
			col0 = other col1
			p0.col += col0
			p1.col += col1
		else
			balans = p0.balans() + p1.balans()
			if balans == 0 then @flip p0,p1
			else if 2 == abs balans
				if 2 == abs p0.balans() then @flip p0,p1 else @flip p1,p0

	pair : (persons, pairing=[]) ->
		if pairing.length == N then return pairing
		a  = persons[0]
		for b in persons
			if not ok a,b then continue
			newPersons = (p for p in persons when p not in [a,b])
			newPairing = pairing.concat [a,b]
			result = @pair newPersons,newPairing
			if result.length == N then return result
		return []

	txtT : (value, w, align=window.CENTER) -> 
		if value.length > w then value = value.substring 0,w
		if align==window.LEFT then res = value + _.repeat ' ',w-value.length
		if align==window.RIGHT then res = _.repeat(' ',w-value.length) + value
		if align==window.CENTER 
			diff = w-value.length
			lt = _.repeat ' ',(1+diff)//2
			rt = _.repeat ' ',diff//2
			res = lt + value + rt
		res
	#assert "   Sven   ", txtT "Sven",10

	showHeader : (header) ->
		y = DY/2
		textAlign LEFT,CENTER
		s = ''
		s += @txtT "#{@name} #{@datum}" ,30, window.LEFT
		s += ' ' + @txtT header, 22, window.CENTER
		s += ' ' + @txtT 'Round ' + @round, 30, window.RIGHT
		fill 'black'
		text s,10,y

	txt : (value, x, y, align=null, color=null) ->
		if align then textAlign align,CENTER
		if color then fill color
		text value,x,y

	showTables : ->
		@showHeader 'Tables'
		y = 1.5 * DY
		s = ""
		s +=       @txtT '#', 2,window.RIGHT
		s += ' ' + @txtT 'Score', 5,window.RIGHT
		s += ' ' + @txtT 'Elo',   4,window.LEFT
		s += ' ' + @txtT 'White', 25,window.LEFT
		s += ' ' + @txtT 'Result',7,window.CENTER
		s += ' ' + @txtT 'Black', 25,window.LEFT
		s += ' ' + @txtT 'Elo',   4,window.LEFT
		s += ' ' + @txtT 'Score', 5,window.RIGHT
		fill 'black'
		textAlign window.LEFT
		text s,10,y

		for i in range N//2
			y += DY*0.5
			a = @pairings[2*i  ] # White
			b = @pairings[2*i+1] # Black
			pa = myRound a.score(), 1
			pb = myRound b.score(), 1
			both = if a.res.length == a.col.length then prBoth _.last(a.res) else "   -   "

			nr = i+1
			s = ""
			s += @txtT nr.toString(), 2, window.RIGHT
			s += ' ' + @txtT pa, 5
			s += ' ' + @txtT a.elo, 4
			s += ' ' + @txtT a.name, 25, window.LEFT

			s += ' ' + @txtT both,7, window.CENTER

			s += ' ' + @txtT b.name, 25, window.LEFT
			s += ' ' + @txtT b.elo, 4
			s += ' ' + @txtT pb, 5, window.CENTER

			if i == currentTable
				fill  'yellow'
				noStroke()
				rect 10,y-11,1000,20
				fill 'black'
			else
				if i in errors then fill 'red' else fill 'black'
			text s,10,y

	lightbulb : (color, x, y, result, opponent) ->
		# print 'lightbulb',color, x, y, result, opponent
		push()
		# print 'lightbulb',result
		fill 'red gray green'.split(' ')[result]
		rectMode CENTER
		rect x,y,0.8*DY,0.45*DY
		fill {b:'black', w:'white'}[color]
		noStroke()
		strokeWeight = 0
		@txt 1+opponent,x,y+1,CENTER
		pop()


	createURL : ->
		res = []
		#res.push "https://christernilsson.github.io/2023/044-Monrad"
		res.push "http://127.0.0.1:5500"
		res.push "?TOUR=" + @name.replace ' ','_'
		res.push "&DATE=" + "2023-11-25"
		res.push "&ROUNDS=" + @rounds
		res.push "&ROUND=" + @round
		res.push "&NAME=" + (_.map @players, (person) -> person.name.replaceAll " ","_").join "|"
		res.push "&ELO=" + (_.map @players, (person) -> person.elo).join "|"
		#if persons[0].opp.length> 0
		res.push "&OPP=" + (_.map @players, (person) -> (_.map person.opp, ints2strings)).join "|"
		res.push "&COL=" + (_.map @players, (person) -> person.col).join "|"
		res.push "&RES=" + (_.map @players, (person) -> res2string person.res).join "|"
		res.join '\n'

	adjustForColors : () ->
		print 'adjustForColors',N, @pairings.length
		res = []
		for i in range N//2
			if @pairings[2*i].col.length == 0 or 'w' == _.last @pairings[2*i].col
				res.push @pairings[2*i] # W
				res.push @pairings[2*i+1] # B
			else
				res.push @pairings[2*i+1] # W
				res.push @pairings[2*i] # B
		@pairings = res

	makeTableFile : (header) ->
		res = []

		players = ([@pairings[i],i] for i in range N)
		players = _.sortBy players, (p) -> p[0].name
		players = ("#{_.pad((1+i//2).toString() + 'wb'[i%2] ,5)} #{p.name}" for [p,i] in players)

		res.push "NAMES" + header
		res.push ""
		for p,i in players
			if i % @ppp == 0
				res.push "Table Name"
			res.push p
			if i % @ppp == @ppp-1 then res.push "\f"

		res.push "\f"

		res.push "TABLES" + header
		res.push ""
		for i in range N//2
			if i % @tpp == 0
				res.push "Table White".padEnd(6+25) + _.pad("",20) + 'Black'.padEnd(25)
			a = @pairings[2*i]
			b = @pairings[2*i+1]
			res.push ""
			res.push _.pad(i+1,6) + a.name.padEnd(25) + _.pad("|____| - |____|",20) +  b.name.padEnd(25)
			if i % @tpp == @tpp-1 then res.push "\f"
		res.join "\n"	

	showResult : ->
		@showHeader 'Result'
		if @pairings.length == 0
			txt "This ROUND can't be paired! (Too many rounds)",width/2,height/2,CENTER
			return

		noStroke()
		# calcT()

		temp = _.sortBy @players, (player) -> [player.score() ] #, 'tie']
		temp = temp.reverse()

		inv = (p.id for p in temp)
		inv = invert inv

		y = 1.5 * DY
		textAlign LEFT
		rheader = _.map range(1,@rounds+1), (i) -> "#{i%10} "
		rheader = rheader.join ' '

		s = ""
		s +=       @txtT "#",    2
		s += ' ' + @txtT "Elo",  4,window.LEFT
		s += ' ' + @txtT "Name", 25,window.LEFT
		s += ' ' + @txtT rheader,3*@rounds,window.LEFT 
		s += ' ' + @txtT "Score",5,window.RIGHT
		s += ' ' + @txtT "D",    2,window.CENTER
		s += ' ' + @txtT "W",    1,window.CENTER
		s += ' ' + @txtT "B",    2,window.CENTER
		text s,10,y

		fill 'white' 
		for person,i in temp
			y += DY * 0.5
			s = ""
			s +=       @txtT (1+i).toString(), 2, window.RIGHT
			s += ' ' + @txtT person.elo,       4, window.LEFT
			s += ' ' + @txtT person.name,     25, window.LEFT
			s += ' ' + @txtT '', 3*@rounds, window.CENTER
			print(person)
			score = person.score()
			score = myRound score, 1
			s += ' ' + @txtT score,             5, window.RIGHT
			# s += ' ' + @txtT prRes(person.tie[0]),2,window.CENTER
			# s += ' ' + @txtT       person.tie[1], 2,window.CENTER
			# s += ' ' + @txtT prRes(person.tie[2]),2,window.CENTER
			text s,10,y

			#print('round',round)
			for r in range @round-1
				x = DY * (10.5 + 0.9*r)
				print r,person.col[r][0], x, y, person.res[r], inv[person.opp[r]]
				@lightbulb person.col[r][0], x, y, person.res[r], inv[person.opp[r]]

class Player
	constructor : (@id, @name, @elo, @opp, @col, @res) ->

	balans : () -> # färgbalans
		result = 0
		for ch in @col
			if ch=='b' then result -= 1
			if ch=='w' then result += 1
		result

	score : () ->
		result = 0
		# print 'score',state,@res.length,@col.length
		n = tournament.round
		if state == 0 then n = n-1
		sp = tournament.sp
		for i in range n
			if i < @col.length and i < @res.length
				key = @col[i] + @res[i]
				result += {'w2': 1-sp, 'b2': 1, 'w1': 0.5-sp, 'b1': 0.5+sp, 'w0': 0, 'b0': sp}[key]
				
		result


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

sum = (s) ->
	res = 0
	for item in s
		res += parseInt item
	res
assert 6, sum '012012'

getMet = (a,b) -> b.id in persons[a.id].opp

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

prBoth = (score) ->
	a = ASCII.indexOf score
	b = 2 - a
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


setT0 = (p,q) ->
	if q in persons[p].opp
		r = persons[p].opp.indexOf q
		# persons[p].tie[0] = persons[p].res[r]

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
		# person.tie[0] = 0
	for key of scores
		if scores[key].length == 2
			[p,q] = scores[key]
			setT0 p,q
			setT0 q,p

	# for p in persons
	# 	p.tie[1] = p.res.split("").filter((x) => x == '2').length
	# 	p.tie[2] = 0
	# 	for i in p.opp
	# 		p.tie[2] += sum persons[i].res # Buchholz: the sum of opposition scores

mw = (x) -> x/1000 * width

########### GUI ############
# if location.search == ''
# 	title = 'Tutorial Tournament'
# 	datum = new Date()
# 	datum = datum.toISOString().split('T')[0]
# 	url = "?T=#{title.replace(" ","_")}&NAME=ANDERSSON_Anders|BENGTSSON_Bertil|CARLSEN_Christer|DANIELSSON_Daniel|ERIKSSON_Erik|FRANSSON_Ferdinand|GREIDER_Göran|HARALDSSON_Helge"
# 	location.href = url
# else
# 	fetchURL()
# 	pairings = persons

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
	tournament = new Tournament()
	tournament.fetchURL()
	tournament.lotta()
	state = 0
	xdraw()

xdraw = ->
	background 'gray'
	textSize DY * 0.5
	if state == 0 then tournament.showTables()
	if state == 1 then tournament.showResult()
	if state == 2 then tournament.showHelp()

window.keyPressed = ->
	#print key
	if key == 'Home' then currentTable = 0
	if key == 'ArrowUp' then currentTable = (currentTable - 1) %% (N//2)
	if key == 'ArrowDown' then currentTable = (currentTable + 1) %% (N//2)
	if key == 'End' then currentTable = (N//2) - 1
	index = 2 * currentTable
	a = tournament.pairings[index]
	b = tournament.pairings[index+1]

	if key in '0 1'
		index = '0 1'.indexOf key
		ch = "012"[index]
		if a.res.length == a.col.length 
			if ch != _.last a.res
				errors.push currentTable
				print 'errors',errors
		else
			if a.res.length < a.col.length then a.res += "012"[index]
			if b.res.length < b.col.length then b.res += "012"[2 - index]
		currentTable = (currentTable + 1) %% (N//2)

	if key == 'Enter'
		state = 1 - state
		# if state == 1
		# 	calcT()
	if key in 'pP' then tournament.lotta()
	if key in 'lL' then DY += 1
	if key in 'sS' then DY -= 1

	if key == 'x'
		for i in range tournament.pairings.length // 2
			a = tournament.pairings[2*i]
			b = tournament.pairings[2*i+1]
			index = i % 3
			if a.res.length < a.col.length then a.res += "012"[index]
			if b.res.length < b.col.length then b.res += "012"[2 - index]

	if key == 'Delete'
		i = currentTable
		errors = (e for e in errors when e != i)
		if a.res.length == b.res.length
			a = tournament.pairings[2*i]
			b = tournament.pairings[2*i+1]
			a.res = a.res.substring 0,a.res.length-1
			b.res = b.res.substring 0,b.res.length-1
		currentTable = (currentTable + 1) %% (N//2)

	xdraw()
