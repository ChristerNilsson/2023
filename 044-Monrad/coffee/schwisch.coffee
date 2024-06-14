# TODO ½ #######################################
# Bläddra mellan ronder med LEFT och RIGHT
# Skippa canvas, använda html istället?
# Testa att läsa skapade url:er
# Spara Zoom i urlen
# Visa hjälprad som anger möjliga tangenter
#   TABLES: up down 1 space 0 delete enter Pair Small Large
#   RESULT: up down enter pause
# createURL ska skicka runt bl a SP ZOOM TPP PPP
# Visa namnlistan på skärmen?
# Hantera frirond
# Tie Break - hantering
# Sortera på [score, elo, name]
# Kunna scrolla canvas, med pilar eller mushjulet.

# Ge perfekt felmeddelande för fel i URL-en.
#   Fel antal ronder i Color, Result
#   Fel antal ELO

# Parkera spelare. PARK=(12|34). Resultatskärmen, Pause-knappen 

# Testa på Mac. (klippbordet)

# Publicera på chess-results? Skapa lämplig fil.

# DONE #########################################
# Initialer i showResult.
# Den markerade radens höjd och bredd ska också zoomas
# Lispinspirerad URL med () och |
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
# Res Externt=0½1, internt=012
# WB ska vara wb överallt, även i urlen

# LOW ########################################
# Införa Dutch Manager? Vet ej hur det ska hanteras. Just nu möts 1-2 i tredje ronden. Finns ingen publik kod, FIDE:s lagtext svår att tolka.

# NOT TODO #####################################
# Välj Dutch eller Swiss i URL-en (LOW)
# localStorage (i princip urlen) Behövs localStorage?
# Repetition av piltangenter (NIX, går för fort)
# Två kolumner vid många spelare
# Backa en eller flera ronder? (Kan göras mha sparade URL:er)
# Ange färg för första bordet i URL-en (EASY) FIRST=WHITE, FIRST=BLACK (default)
# Hantera 1 till 8 partier per team/person GAMES=1 (default)
# Hastighetsjämförelser (javafo, swiss-manager, min kod, monrad, swiss)
# Jämför lottningsresultat. Förklara skillnader.

import { parseExpr } from './parser.js'

HELP = """
How to use Schwisch Manager:
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
ZOOM = [40,40,40] # vertical line distance for three states

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

myRound = (x,decs) -> x.toFixed decs
assert "2.0", myRound 1.99,1
assert "0.6", myRound 0.61,1

ints2strings = (ints) -> "#{ints}"
assert "1,2,3", ints2strings [1,2,3]
assert "1", ints2strings [1]
assert "", ints2strings []

res2string = (ints) -> (i.toString() for i in ints).join ''
assert "123", res2string [1,2,3]
assert "1", res2string [1]
assert "", res2string []

xxx = [[2,1],[12,2],[12,1],[3,4]]
xxx.sort (a,b) -> 
	diff = a[0] - b[0] 
	if diff == 0 then a[1] - b[1] else diff
assert [[2,1], [3,4], [12,1], [12,2]], xxx	
assert true, [2] > [12]
assert true, "2" > "12"
assert false, 2 > 12

# xxx = [[2,1],[12,2],[12,1],[3,4]]
# assert [[2,1],[3,4],[12,2]], _.sortBy(xxx, (x) -> [x[0],x[1]])
# assert [[3,4],[2,1],[1,2]], _.sortBy(xxx, (x) -> -x[0])
# assert [[2,1],[1,2],[3,4]], _.sortBy(xxx, (x) -> x[1])
# assert [[3,4],[1,2],[2,1]], _.sortBy(xxx, (x) -> -x[1])

initials = (name) ->
	res = ""
	arr = name.replace('-',' ').split ' '
	for s in arr
		res += s[0]
	res
assert 'cn', initials 'christer nilsson'
assert 'JLB', initials 'JOHANSSON Lennart B.'

cdf = (x) -> # https://www.geeksforgeeks.org/javascript-program-for-normal-cdf-calculator/
    T = 1 / (1 + 0.2316419 * Math.abs x)
    D = 0.3989423 * Math.exp -x * x / 2
    cd = D * T * (0.3193815 + T * (-0.3565638 + T * (1.781478 + T * (-1.821256 + T * 1.330274))))
    if x > 0 then 1 - cd else cd

calc = (winner, loser, result, K) ->
    diff = winner - loser
    u = diff/400 * sqrt(2)
    (result - cdf(u)) * K

# elodiff = (games,K=20) -> [calc(a,b,res,K) for a,b,res in games]

class Player
	constructor : (@id, @elo="", @name="", @opp=[], @col="", @res="") ->

	eloDiff : -> 
		result = 0
		for i in range @res.length
			result += calc @elo, tournament.persons[@opp[i]].elo, 0.5 * parseInt(@res[i]), 20
		result

	balans : -> # färgbalans
		result = 0
		for ch in @col
			if ch=='b' then result -= 1
			if ch=='w' then result += 1
		result

	score : ->
		result = 0
		n = tournament.round
		if state == 0 then n = n-1
		sp = tournament.sp
		for i in range n
			if i < @col.length and i < @res.length
				key = @col[i] + @res[i]
				result += {'w2': 1-sp, 'b2': 1, 'w1': 0.5-sp, 'b1': 0.5+sp, 'w0': 0, 'b0': sp}[key]
		result

	read : (player) -> 
		# (1234|Christer|(12w0|23b½|14w)) 
		# (1234|Christer) 
		# print 'read',player
		@elo = parseInt player[0]
		@name = player[1]
		# print @elo 
		@opp = []
		@col = ""
		@res = ""
		if player.length < 3 then return
		ocrs = player[2]
		#print 'ocrs',ocrs
		for ocr in ocrs
			#print 'ocr',ocr
			if 'w' in ocr then col='w' else col='b'
			arr = ocr.split col
			@opp.push parseInt arr[0]
			@col += col
			if arr.length == 2 and arr[1].length == 1
				#print 'arr',arr[1]
				@res += {'0':'0', '½':'1', '1':'2'}[arr[1]]  
				#print @res
		print @

	write : -> # (1234|Christer|(12w0|23b½|14w)) Elo:1234 Name:Christer opponent:23 color:b result:½
		res = []
		res.push @elo
		res.push @name.replaceAll ' ','_'
		nn = @opp.length
		# ocr = ("#{@opp[i]}#{@col[i]}#{if i < nn-1 then "0½1"[@res[i]] else ''}" for i in range(nn)) 
		ocr = ("#{@opp[i]}#{@col[i]}#{if i < nn then "0½1"[@res[i]] else ''}" for i in range(nn)) 
		res.push '(' + ocr.join('|') + ')'
		res.join '|'

class Tournament 
	constructor : () ->
		@name = ''
		@rounds = 0
		@round = 0
		@sp = 0.1 # 0.01
		@tpp = 30
		@ppp = 60

		# dessa tre listor pekar på samma objekt
		@players = []
		@persons = [] # stabil, sorterad på id och elo
		@pairings = [] # varierar med varje rond

		@fetchURL()
		# @round -= 1
		#@lotta()

	write : () ->

	lotta : () ->

		print 'Lottning av rond ',@round
		document.title = 'Round ' + (@round+1)
		print @players
		for p in @players
			if p.res.length != p.col.length
				print 'avbrutet!'
				return

		if @round == 0
			@pairings = @players
			print 'Apairings',@pairings
			@round = 1
		else

			timestamp = new Date().toLocaleString 'se-SE'
			print "lotta ROUND",@round
			print 'tournament',tournament
			downloadFile tournament.makeTableFile(" for " + @name + " in Round #{@round}    #{timestamp}"), @name + " Round #{@round}.txt"
			downloadFile @createURL(), "URL for " + @name + " Round #{@round}.txt"

			@round += 1

#			@pairings = _.sortBy @players, (player) -> [player.score(), -player.elo]
			@pairings = _.sortBy @players, (player) -> [-player.elo]

			if @round % 2 == 0 then @pairings = @pairings.reverse()
			start = new Date()

			@pairings = @pair @pairings
			print 'Bpairings',@pairings
			print @round, "#{new Date() - start} milliseconds"

		#colorize @pairings
		#assignColors @pairings

		@adjustForColors()

		for i in range N//2
			a = @pairings[2*i]
			b = @pairings[2*i+1]
			a.opp.push b.id
			b.opp.push a.id
			#a.res += ' '
			#b.res += ' '
			@assignColors a,b

		state = 0

		print {'pairings after pairing', @pairings}

		xdraw()

	fetchURL : (url = location.search) ->
		print 'fetchURL'
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
		@sp = parseFloat getParam 'SP', 0.0 # ScorePoints
		@tpp = parseInt getParam 'TPP',30 # Tables Per Page
		@ppp = parseInt getParam 'PPP',60 # Players Per Page

		players = urlParams.get 'PLAYERS'
		print players
		players = players.replaceAll ')(', ')|('
		players = players.replaceAll '_',' '
		players = '(' + players + ')'
		players = parseExpr players
		print 'xxx',players

		N = players.length

		if N < 4
			print "Error: Number of players must be 4 or more!"
			return
		if N > 100
			print "Error: Number of players must be 100 or less!"
			return

		for i in range N
			player = new Player i
			player.read players[i]
			@players.push player

		print @players
		
		@players = _.sortBy @players, (player) -> player.elo
		@players = @players.reverse()
		@persons = _.cloneDeep @players

		for i in range N
			@players[i].id = i

		@persons = _.clone @players

		print 'sorted players', @players

		if @ROUND > 0
			#opps = urlParams.get('OPP').split '|'
			#cols = urlParams.get('COL').split '|'
			#ress = urlParams.get('RES').split '|'
			#if names.length != opps.length != cols.length != ress.length != elos.length
			#	print "Error: Illegal number of players in OPP, COL, ELO or RES!"
			#	return

			#opps = _.map opps, (r) -> _.map opp.split(','), (s) -> parseInt s
			#ress = _.map ress, (res) -> _.map res, (ch) -> parseInt ch

			# for i in range N
			# 	if ress[i].length != opps[i].length != cols[i].length != ress[i].length
			# 		print "Error: Illegal number of rounds for player #{names[i]}!"
			# 		return
			# 	@players[i].name = names[i]
			# 	@players[i].col = cols[i]
			# 	@players[i].res = ress[i]
			# 	@players[i].opp = opps[i] 
			# 	#@players[i].tie = [0,0,0]
			# print(@players)
		else
			if N % 2 == 1
				@players.push new Player N, 0, '-frirond-'
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
		if value.length < w and align==window.RIGHT then value = value.padStart w
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
		y = ZOOM[state]/2
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
		y = 1.5 * ZOOM[state]
		s = ""
		s +=       @txtT '#', 2,window.RIGHT
		s += ' ' + @txtT 'Score', 5,window.RIGHT
		s += ' ' + @txtT 'Elo',   4,window.RIGHT
		s += ' ' + @txtT 'White', 25,window.LEFT
		s += ' ' + @txtT 'Result',7,window.CENTER
		s += ' ' + @txtT 'Black', 25,window.LEFT
		s += ' ' + @txtT 'Elo',   4,window.LEFT
		s += ' ' + @txtT 'Score', 5,window.RIGHT
		fill 'black'
		textAlign window.LEFT
		text s,10,y

		print 'pairings.length',@pairings.length
		for i in range N//2
			y += ZOOM[state] * 0.5
			a = @pairings[2*i  ] # White
			b = @pairings[2*i+1] # Black
			pa = myRound a.score(), 1
			pb = myRound b.score(), 1
			both = if a.res.length == a.col.length then prBoth _.last(a.res) else "   -   "

			nr = i+1
			s = ""
			s += @txtT nr.toString(), 2, window.RIGHT
			s += ' ' + @txtT pa, 5
			s += ' ' + @txtT a.elo.toString(), 4, window.RIGHT
			s += ' ' + @txtT a.name, 25, window.LEFT

			s += ' ' + @txtT both,7, window.CENTER

			s += ' ' + @txtT b.name, 25, window.LEFT
			s += ' ' + @txtT b.elo.toString(), 4, window.RIGHT
			s += ' ' + @txtT pb, 5, window.CENTER

			if i == currentTable
				fill  'yellow'
				noStroke()
				rect 0,y-0.25*ZOOM[state],width, 0.5 * ZOOM[state]
				fill 'black'
			else
				if i in errors then fill 'red' else fill 'black'
			text s,10,y

	lightbulb : (color, x, y, result, opponent) ->
		# print 'lightbulb',color, x, y, result, opponent
		push()
		#print 'lightbulb',result
		# result = 2 * '0½1'.indexOf result
		result = '012'.indexOf result
		#print 'lightbulb',result
		fill 'red gray green'.split(' ')[result]
		rectMode CENTER
		rect x,y,0.84 * ZOOM[state],0.45 * ZOOM[state]
		fill {b:'black', w:'white'}[color]
		noStroke()
		strokeWeight = 0
#		@txt 1+opponent,x,y+1,CENTER
		@txt opponent,x,y+1,CENTER
		pop()

	createURL : ->
		res = []
		#res.push "https://christernilsson.github.io/2023/044-Monrad"
		res.push "http://127.0.0.1:5500"
		res.push "?TOUR=" + @name.replace ' ','_'
		res.push "&DATE=" + "2023-11-25"
		res.push "&ROUNDS=" + @rounds
		res.push "&ROUND=" + @round
		res.push "&PLAYERS=" 
		
		players = []
		for player in @players
			s = player.write()
			players.push '(' + s + ')'
		players = players.join("\n")
		res = res.concat players

		# res.push "&NAME=" + (_.map @players, (person) -> person.name.replaceAll " ","_").join "|"
		# res.push "&ELO=" + (_.map @players, (person) -> person.elo).join "|"
		# #if persons[0].opp.length> 0
		# res.push "&OPP=" + (_.map @players, (person) -> (_.map person.opp, ints2strings)).join "|"
		# res.push "&COL=" + (_.map @players, (person) -> person.col).join "|"
		# res.push "&RES=" + (_.map @players, (person) -> res2string person.res).join "|"
		res.join '\n'

	adjustForColors : () ->
		print 'adjustForColors',N, @pairings.length
		res = []
		for i in range N//2

			if @pairings[2*i].col.length == 0
				if i % 2==0 
					res.push @pairings[2*i+1] # w
					res.push @pairings[2*i] # b
				else
					res.push @pairings[2*i] # w
					res.push @pairings[2*i+1] # b
			else if 'w' == _.last @pairings[2*i].col
				res.push @pairings[2*i] # w
				res.push @pairings[2*i+1] # b
			else
				res.push @pairings[2*i+1] # w
				res.push @pairings[2*i] # b

			# if @pairings[2*i].col.length == 0 or 'w' == _.last @pairings[2*i].col
			# 	res.push @pairings[2*i] # w
			# 	res.push @pairings[2*i+1] # b
			# else
			# 	res.push @pairings[2*i+1] # w
			# 	res.push @pairings[2*i] # b

		@pairings = res

	makeTableFile : (header) ->
		res = []

		print header
		print 'makeTableFile',@pairings
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
		print 'showResult'
		if @pairings.length == 0
			txt "This ROUND can't be paired! (Too many rounds)",width/2,height/2,CENTER
			return

		noStroke()
		# calcT()

		# _.sortBy på [score, elo] verkar inte fungera pga array jämförs som sträng?

		temp = _.clone @players
		temp.sort (a,b) -> 
			diff = b.score() - a.score()
			if diff != 0 then return diff
			return b.elo - a.elo

		print 'tempA',temp
		#temp.reverse()

		inv = (p.id for p in temp)
		inv = invert inv

		y = 1.5 * ZOOM[state]
		textAlign LEFT
		rheader = _.map range(1,@rounds+1), (i) -> "#{i%10} "
		rheader = rheader.join ' '

		s = ""
		s +=       @txtT "#",    2
		s += ' ' + @txtT "Elo",  4,window.RIGHT
		s += ' ' + @txtT "Name", 25,window.LEFT
		s += ' ' + @txtT rheader,3*@rounds,window.LEFT 
		s += ' ' + @txtT "Score",5,window.RIGHT
		s += ' ' + @txtT "±Elo", 6,window.RIGHT
		s += ' ' + @txtT "D",    2,window.CENTER
		s += ' ' + @txtT "W",    1,window.CENTER
		s += ' ' + @txtT "B",    2,window.CENTER
		
		text s,10,y

		fill 'white' 
		for person,i in temp
			y += ZOOM[state] * 0.5
			s = ""
			s +=       @txtT (1+i).toString(),      2, window.RIGHT
			s += ' ' + @txtT person.elo.toString(), 4, window.RIGHT
			s += ' ' + @txtT person.name,          25, window.LEFT
			s += ' ' + @txtT '', 3*@rounds, window.CENTER
			print(person)
			score = person.score()
			score = myRound score, 1
			s += ' ' + @txtT score,             5, window.RIGHT
			s += ' ' + @txtT myRound(person.eloDiff(),1).toString(),  6, window.RIGHT

			# s += ' ' + @txtT prRes(person.tie[0]),2,window.CENTER
			# s += ' ' + @txtT       person.tie[1], 2,window.CENTER
			# s += ' ' + @txtT prRes(person.tie[2]),2,window.CENTER
			text s,10,y

			#print('round',round)
			for r in range @round-1
				x = ZOOM[state] * (10.5 + 0.9*r)
				# print r,person.col[r][0], x, y, person.res[r], inv[person.opp[r]]
				# @lightbulb person.col[r][0], x, y, person.res[r], initials @players[inv[person.opp[r]]].name
				@lightbulb person.col[r][0], x, y, person.res[r], initials @persons[person.opp[r]].name

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

# getMet = (a,b) -> b.id in persons[a.id].opp

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
	#tournament.fetchURL()
	tournament.lotta()
	state = 0
	xdraw()

xdraw = ->
	background 'gray'
	textSize ZOOM[state] * 0.5
	if state == 0 then tournament.showTables()
	if state == 1 then tournament.showResult()
	if state == 2 then tournament.showHelp()

window.keyPressed = ->
	# print key
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
			if b.res.length < b.col.length then b.res += "210"[index]
		currentTable = (currentTable + 1) %% (N//2)

	if key == 'Enter'
		state = 1 - state
		# if state == 1
		# 	calcT()
	if key in 'pP' then tournament.lotta()
	if key in 'l' then ZOOM[state] += 1
	if key in 's' then ZOOM[state] -= 1
	if key in 'L' then ZOOM[state] += 4
	if key in 'S' then ZOOM[state] -= 4

	if key == 'x'
		for i in range tournament.pairings.length // 2
			a = tournament.pairings[2*i]
			b = tournament.pairings[2*i+1]
			index = i % 3
			if a.res.length < a.col.length then a.res += "012"[index]
			if b.res.length < b.col.length then b.res += "012"[2 - index]

			matrix = []
			for r in range tournament.round
				res = []
				for player in tournament.players
					res.push [player.id,player.opp[r]]				
				matrix.push res
			print 'dump', JSON.stringify matrix


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
