import { parseExpr } from './parser.js'
import {Edmonds} from './mattkrick.js'

# parameters that somewhat affects matching
COST = 'QUADRATIC' # QUADRATIC=1.01 or LINEAR=1
DIFF = 'ID' # ID or ELO
COLORS = 1 # 1 or 2

RINGS = {'b':'•', 'w':'o'}

HELP = """
How to use Dense Pairings:
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

print = console.log
range = _.range

# up down  enter  1 space=draw 0  delete  Pair  Small Large  Matrix

ASCII = '0123456789abcdefg'
ALFABET = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' # 62 ronder maximalt
N = 0 # number of players
ZOOM = [40,40,40] # vertical line distance for three states

datum = ''
currentTable = 0
currentResult = 0 
tournament = null
errors = [] # id för motsägelsefulla resultat. Tas bort med Delete

state = 0 # 0=Tables 1=Result 2=Help
resultat = [] # 012 sorterad på id
message = '' #This is a tutorial tournament. Use it or edit the URL'

showType = (a) -> if typeof a == 'string' then "'#{a}'" else a
assert = (a,b) -> if not _.isEqual a,b then print "Assert failure: #{showType a} != #{showType b}"

ok = (p0, p1) -> p0.id != p1.id and p0.id not in p1.opp and abs(p0.balans() + p1.balans()) <= COLORS
other = (col) -> if col == 'b' then 'w' else 'b'

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

xxx = [[2,1],[12,2],[12,1],[3,4]]
assert [[2,1],[3,4],[12,2]], _.sortBy(xxx, (x) -> [x[0],x[1]])
assert [[3,4],[2,1],[1,2]], _.sortBy(xxx, (x) -> -x[0])
assert [[2,1],[1,2],[3,4]], _.sortBy(xxx, (x) -> x[1])
assert [[3,4],[1,2],[2,1]], _.sortBy(xxx, (x) -> -x[1])

normera = (x) -> x # 1000/1010 * x - 392

class Player
	constructor : (@id, @elo="",  @opp=[], @col="", @res="",@name="") ->

	toString : -> "#{@id} #{@name} elo:#{@elo} #{@col} res:#{@res} opp:[#{@opp}] score:#{@score().toFixed(1)} eloSum:#{@eloSum().toFixed(0)}"

	eloSum : -> 
		sp = tournament.sp
		hash = {'w2': 1, 'b2': 1+2*sp, 'w1': 0.5-sp, 'b1': 0.5+sp, 'w0': 0, 'b0': 0}
		sum(normera(tournament.persons[@opp[i]].elo) * hash[@col[i] + @res[i]] for i in range @res.length)

	avgEloDiff : ->
		res = []
		for id in @opp.slice 0, @opp.length - 1
			res.push abs normera(@elo) - normera(tournament.persons[id].elo)
		sum(res) / res.length

	balans : -> # färgbalans
		result = 0
		for ch in @col
			if ch=='b' then result -= 1
			if ch=='w' then result += 1
		result

	score : ->
		result = 0
		n = tournament.round
		sp = tournament.sp
		for i in range n
			if i < @col.length and i < @res.length
				key = @col[i] + @res[i]
				#result += {'w2': 1-sp, 'b2': 1, 'w1': 0.5-sp, 'b1': 0.5+sp, 'w0': 0, 'b0': sp}[key]
				res = {'w2': 1, 'b2': 1+2*sp, 'w1': 0.5-sp, 'b1': 0.5+sp, 'w0': 0, 'b0': 0}[key]
		#print 'id,score',@id, @res, result,n
		result

	read : (player) -> 
		# (1234|Christer|(12w0|23b½|14w)) 
		# (1234|Christer) 
		# print 'read',player
		@elo = parseInt player[0]
		@name = player[1]
		@opp = []
		@col = ""
		@res = ""
		if player.length < 3 then return
		ocrs = player[2]
		for ocr in ocrs
			if 'w' in ocr then col='w' else col='b'
			arr = ocr.split col
			@opp.push parseInt arr[0]
			@col += col
			if arr.length == 2 and arr[1].length == 1
				@res += {'0':'0', '½':'1', '1':'2'}[arr[1]]  
		print @

	write : -> # (1234|Christer|(12w0|23b½|14w)) Elo:1234 Name:Christer opponent:23 color:b result:½
		res = []
		res.push @elo
		res.push @name.replaceAll ' ','_'
		nn = @opp.length - 1
		ocr = ("#{@opp[i]}#{@col[i]}#{if i < nn then "0½1"[@res[i]] else ''}" for i in range(nn)) 
		res.push '(' + ocr.join('|') + ')'
		res.join '|'

class Tournament 
	constructor : () ->
		@title = ''
		@rounds = 0
		@round = 0
		@sp = 0.0 # 0.01
		@tpp = 30
		@ppp = 60

		# dessa tre listor pekar på samma objekt
		@players = []
		@persons = [] # stabil, sorterad på id och elo
		@pairs = [] # varierar med varje rond

		@robin = range N
		@fetchURL()
		@mat = []

	write : () ->

	makeEdges : ->
		edges = []
		for a in range N
			pa = @persons[a]
			for b in range a+1,N
				pb = @persons[b]

				if DIFF == 'ELO' then diff = abs pa.elo - pb.elo
				if DIFF == 'ID'  then diff = abs pa.id - pb.id
				if COST == 'LINEAR'    then cost = 2000 - diff
				if COST == 'QUADRATIC' then cost = 2000 - diff ** 1.01

				if ok pa,pb then edges.push [pa.id,pb.id,cost]
		edges
	
	findSolution : (edges) -> 
		edmonds = new Edmonds edges
		edmonds.maxWeightMatching edges

	flip : (p0,p1) -> # p0 byter färg, p0 anpassar sig
		col0 = _.last p0.col
		col1 = col0
		col0 = other col0
		p0.col += col0
		p1.col += col1

	assignColors : (p0,p1) ->
		b0 = p0.balans()
		b1 = p1.balans()
		if b0 < b1 then x = 0
		else if b0 > b1 then x = 1
		else if p0.id < p1.id then x = 0 else x = 1
		p0.col += 'wb'[x]
		p1.col += 'bw'[x]

	unscramble : (solution) -> # [5,3,4,1,2,0] => [[0,5],[1,3],[2,4]]
		solution = _.clone solution
		result = []
		for i in range solution.length
			if solution[i] != -1
				j = solution[i]
				result.push [i,j] #[@players[i].id,@players[j].id]
				solution[j] = -1
				solution[i] = -1
		result

	lotta : () ->

		#print @players
		for p in @persons
			if p.res.length != p.col.length
				print 'avbrutet!'
				return

		print 'Lottning av rond ',@round
		document.title = 'Round ' + (@round+1)

		start = new Date()
		net = @makeEdges @persons
		print 'net',net
		solution = @findSolution net
		print 'solution',solution
		if -1 in solution
			print 'Solution failed!'
			return 
		@pairs = @unscramble solution
		print 'pairs',@pairs
		print 'cpu:',new Date() - start

		for [a,b] in @pairs
			pa = @persons[a]
			pb = @persons[b]
			pa.opp.push pb.id
			pb.opp.push pa.id

		print @persons

		if @round == 0
			for i in range @pairs.length
				[a,b] = @pairs[i]
				pa = @persons[a]
				pb = @persons[b]
				col1 = "bw"[i%2]
				col0 = other col1
				pa.col += col0
				pb.col += col1
				if i%2==1 then @pairs[i].reverse()
		else
			for i in range @pairs.length
				[a,b] = @pairs[i]
				pa = @persons[a]
				pb = @persons[b]
				@assignColors pa,pb
				if pa.col[@round]=='b' then @pairs[i].reverse()

		downloadFile tournament.makeStandardFile(), "R#{@round} #{@title}.txt"
		downloadFile @createURL(), "R#{@round} URL.txt"
		start = new Date()
		if @round > 0 then downloadFile @createMatrix(), "R#{@round} Matrix.txt"
		# downloadFile @makeEdges(), "R#{@round} Net.txt"
		# downloadFile @makeStandings(), "R#{@round} Standings.txt"

		@round += 1
		state = 0
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
		@title = urlParams.get('TOUR').replace '_',' '
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
		print 'players',players

		# players.sort (a,b) -> b.elo - a.elo

		N = players.length

		if N < 4
			print "Error: Number of players must be 4 or more!"
			return
		if N > 200
			print "Error: Number of players must be 200 or less!"
			return

		for i in range N
			player = new Player i
			player.read players[i]
			@players.push player

		print @players
		
		@players = _.sortBy @players, (player) -> player.elo
		@players = @players.reverse()
		for i in range N
			@players[i].id = i

		@persons = _.clone @players

		print (p.elo for p in @persons)
		print 'sorted players', @players

		if @ROUND == 0
			if N % 2 == 1
				@players.push new Player N, 0, '-frirond-'
				N += 1
				# persons = _.map range(N), (i) -> {id:i, name: res.NAME[i], elo: res.ELO[i], col:'', res:[], bal:0, opp:[], T:[]}

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
		s += @txtT "#{@title} #{@datum}" ,30, window.LEFT
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
		# s += ' ' + @txtT 'Score', 5,window.RIGHT
		s += ' ' + @txtT 'Elo',   4,window.RIGHT
		s += ' ' + @txtT 'White', 25,window.LEFT
		s += ' ' + @txtT 'Result',7,window.CENTER
		s += ' ' + @txtT 'Black', 25,window.LEFT
		s += ' ' + @txtT 'Elo',   4,window.LEFT
		# s += ' ' + @txtT 'Score', 5,window.RIGHT
		fill 'black'
		textAlign window.LEFT
		text s,10,y

		for i in range @pairs.length
			[a,b] = @pairs[i]
			a = @persons[a]
			b = @persons[b]
			y += ZOOM[state] * 0.5
			pa = myRound a.score(), 1
			pb = myRound b.score(), 1
			both = if a.res.length == a.col.length then prBoth _.last(a.res) else "   -   "

			nr = i+1
			s = ""
			s += @txtT nr.toString(), 2, window.RIGHT
			# s += ' ' + @txtT pa, 5
			s += ' ' + @txtT a.elo.toString(), 4, window.RIGHT
			s += ' ' + @txtT a.name, 25, window.LEFT

			s += ' ' + @txtT both,7, window.CENTER

			s += ' ' + @txtT b.name, 25, window.LEFT
			s += ' ' + @txtT b.elo.toString(), 4, window.RIGHT
			# s += ' ' + @txtT pb, 5, window.CENTER

			if i == currentTable
				fill  'yellow'
				noStroke()
				rect 0,y-0.25*ZOOM[state],width, 0.5 * ZOOM[state]
				fill 'black'
			else
				if i in errors then fill 'red' else fill 'black'
			text s,10,y

	lightbulb : (color, x, y, result, opponent) ->
		push()
		result = '012'.indexOf result
		fill 'red gray green'.split(' ')[result]
		rectMode CENTER
		rect x,y,0.84 * ZOOM[state],0.45 * ZOOM[state]
		fill {b:'black', w:'white'}[color]
		noStroke()
		strokeWeight = 0
		@txt opponent,x,y+1,CENTER
		pop()

	createURL : ->
		res = []
		#res.push "https://christernilsson.github.io/Dense"
		res.push "http://127.0.0.1:5500"
		res.push "?TOUR=" + @title.replace ' ','_'
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

		res.join '\n'

	makeStandings : (header,res) ->
		if @pairs.length == 0 then res.push "This ROUND can't be paired! (Too many rounds)"

		temp = _.clone @players
		temp.sort (a,b) -> 
			diff = b.eloSum() - a.eloSum()
			if diff != 0 then return diff
			return b.elo - a.elo

		inv = invert (p.id for p in temp)

		res.push "STANDINGS" + header
		res.push ""

		header = ""
		header +=       @txtT "#",     2
		# header += ' ' + @txtT "Id",    4,window.RIGHT
		header += ' ' + @txtT "Elo",   4,window.RIGHT
		header += ' ' + @txtT "Name", 25,window.LEFT
		for r in range @round
			header += @txtT "#{r+1}",6,window.RIGHT
		header += '  ' + @txtT "EloSum", 8,window.RIGHT
		
		for person,i in temp
			if i % @ppp == 0 then res.push header
			s = ""
			s +=       @txtT (1+i).toString(),          2, window.RIGHT
			# s += ' ' + @txtT (person.id+1).toString(),  4, window.RIGHT
			s += ' ' + @txtT person.elo.toString(),     4, window.RIGHT
			s += ' ' + @txtT person.name,              25, window.LEFT
			s += ' '
			for r in range @round
				s += @txtT "#{1+inv[person.opp[r]]}#{RINGS[person.col[r][0]]}#{"0½1"[person.res[r]]}", 6, window.RIGHT			
			s += ' ' + @txtT person.eloSum().toFixed(1),  8, window.RIGHT
			res.push s
			if i % @ppp == @ppp-1 then res.push "\f"
		res.push "\f"

	makeNames : (header,players,res) ->
		res.push "NAMES" + header
		res.push ""
		r = tournament.round
		for p,i in players
			if i % @ppp == 0 then res.push "Table Name"
			res.push "#{str(1 + p[1]//2).padStart(3)} #{RINGS[p[0].col[r][0]]} #{p[0].name}" #  (#{initial p[0].name})"
			if i % @ppp == @ppp-1 then res.push "\f"
		res.push "\f"

	makeTables : (header,res) ->
		res.push "TABLES" + header
		res.push ""
		for i in range @pairs.length
			[a,b] = @pairs[i]
			if i % @tpp == 0 then res.push "Table #{RINGS.w}".padEnd(5+25) + _.pad("",28) + "#{RINGS.b}".padEnd(25)
			pa = @persons[a]
			pb = @persons[b]
			res.push ""
			res.push _.pad(i+1,6) + pa.elo + ' ' + @txtT(pa.name, 25, window.LEFT) + ' ' + _.pad("|____| - |____|",20) + ' ' + pb.elo + ' ' + @txtT(pb.name, 25, window.LEFT)
			if i % @tpp == @tpp-1 then res.push "\f"

	makeStandardFile : () ->
		res = []
		players = []
		for i in range @pairs.length
			[a,b] = @pairs[i]
			pa = @persons[a]
			pb = @persons[b]
			players.push [pa,2*i]
			players.push [pb,2*i+1]
		players = _.sortBy players, (p) -> p[0].name

		timestamp = new Date().toLocaleString('se-SE').slice 0,16
		header0 = " for " + @title + " after Round #{@round}    #{timestamp}"
		header1 = " for " + @title + " in Round #{@round+1}    #{timestamp}"

		@makeStandings header0,res
		if @round < @rounds 
			@makeNames header1,players,res
			@makeTables header1,res

		res.join "\n"	

	distans : (rounds) ->
		result = []
		for i in range(rounds.length) 
			for [a,b] in rounds[i]
				pa = tournament.persons[a]
				pb = tournament.persons[b]
				result.push abs(pa.elo-pb.elo) 
		(sum(result)/result.length).toFixed 2

	makeCanvas : ->
		result = []
		for i in range N
			line = new Array N
			_.fill line, '·'
			line[i] = '*'
			result.push line
		result

	dumpCanvas : (title,average,canvas) ->
		output = ["", title]
		output.push "Sparseness: #{average}  (Average Elo Difference) DIFF:#{DIFF} COST:#{COST} COLORS:#{COLORS} SP:#{@sp}"
		output.push ""
		header = (str((i + 1) % 10) for i in range(N)).join(' ')
		output.push '     ' + header + '   Elo    AED'
		ordning = (p.elo for p in @persons)
		for i in range canvas.length
			row = canvas[i]
			nr = str(i + 1).padStart(3)
			output.push "#{nr}  #{(str(item) for item in row).join(" ")}  #{ordning[i]} #{@persons[i].avgEloDiff().toFixed(1).padStart(6)}"
		output.push '     ' + header
		output.join '\n'

	drawMatrix : (title,rounds) ->
		canvas = @makeCanvas()
		for i in range rounds.length
			for [a,b] in rounds[i]
				canvas[a][b] = ALFABET[i]
				canvas[b][a] = ALFABET[i]
		@dumpCanvas title,@distans(rounds),canvas

	createMatrix : ->
		matrix = []
		for r in range @round
			res = []
			for player in @players
				res.push [player.id,player.opp[r]]				
			matrix.push res
		@drawMatrix @title, matrix

	showStandings : ->
		@showHeader 'Standings'
		if @pairs.length == 0
			txt "This ROUND can't be paired! (Too many rounds)",width/2,height/2,CENTER
			return

		noStroke()

		temp = _.clone @players
		temp.sort (a,b) -> 
			# return a.id - b.id 
			diff = b.eloSum() - a.eloSum()
			if diff != 0 then return diff
			return b.elo - a.elo

		inv = invert (p.id for p in temp)

		y = 1.5 * ZOOM[state] + currentResult
		textAlign LEFT
		rheader = _.map range(1,@rounds+1), (i) -> "#{i%10} "
		rheader = rheader.join ' '
		s = ""
		s +=       @txtT "#",    2
		# s += ' ' + @txtT "Id",   4,window.RIGHT
		s += ' ' + @txtT "Elo",  4,window.RIGHT
		s += ' ' + @txtT "Name", 25,window.LEFT
		s += ' ' + @txtT rheader,3*@rounds,window.LEFT 
		s += ' ' + @txtT "EloSum", 7,window.RIGHT
		text s,10,y

		fill 'white' 
		for person,i in temp
			y += ZOOM[state] * 0.5
			s = ""
			s +=       @txtT (1+i).toString(),         2, window.RIGHT
			# s += ' ' + @txtT (inv[person.id]).toString(), 4, window.RIGHT
			s += ' ' + @txtT person.elo.toString(),    4, window.RIGHT
			s += ' ' + @txtT person.name,             25, window.LEFT
			s += ' ' + @txtT '',               3*@rounds, window.CENTER
			s += ' ' + @txtT person.eloSum().toFixed(1),  7, window.RIGHT

			text s,10,y

			for r in range @round-1
				x = ZOOM[state] * (10.6 + 0.9*r)
				# print r,person.col[r][0], x, y, person.res[r], inv[person.opp[r]]
				# @lightbulb person.col[r][0], x, y, person.res[r], initial @players[inv[person.opp[r]]].name
				@lightbulb person.col[r][0], x, y, person.res[r], 1+inv[person.opp[r]]

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
		res += parseFloat item
	res
assert 6, sum '012012'

downloadFile = (txt,filename) ->
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
assert [2,3,1,0], invert invert [2,3,1,0]

showHelp = ->
	textAlign LEFT
	for i in range HELP.length
		text HELP[i],100,50+50*i

window.windowResized = -> 
	resizeCanvas windowWidth-4,1650 #windowHeight-4
	xdraw()

window.setup = ->
	createCanvas windowWidth-4,1650 # windowHeight-4
	textFont 'Courier New'
	textAlign CENTER,CENTER
	tournament = new Tournament()
	tournament.lotta()
	state = 0
	xdraw()

xdraw = ->
	background 'gray'
	textSize ZOOM[state] * 0.5
	if state == 0 then tournament.showTables()
	if state == 1 then tournament.showStandings()
	if state == 2 then tournament.showHelp()

elo_probabilities = (R_W, R_B, draw=0.2) ->
	E_W = 1 / (1 + 10 ** ((R_B - R_W) / 400))
	win = E_W - draw / 2
	loss = (1 - E_W) - draw / 2
	x = _.random 0,1,true
	index = 2
	if x < loss + draw then index = 1
	if x < loss then index = 0
	index

handleResult = (a,b,pa,pb,key) ->
	index = '0 1'.indexOf key
	ch = "012"[index]
	if pa.res.length == pa.col.length 
		if ch != _.last pa.res
			errors.push currentTable
			print 'errors',errors
	else
		if pa.res.length < pa.col.length then pa.res += "012"[index]
		if pb.res.length < pb.col.length then pb.res += "210"[index]
	currentTable = (currentTable + 1) %% (N//2)

fakeInput = ->
	for i in range tournament.pairs.length
		[a,b] = tournament.pairs[i]
		pa = tournament.persons[a]
		pb = tournament.persons[b]

		x = 1
		if x==0	# Utan slump
			if abs(pa.elo - pb.elo) <= 5 then res = 1
			else if pa.elo > pb.elo then res = 2
			else res = 0
		else if x==1 # elo_prob
			res = elo_probabilities pa.elo, pb.elo
		else if x==2 # ren slump [0.4,0.2,0.4]
			r = _.random 1, true
			res = 2
			if r < 0.6 then res=1
			if r < 0.4 then res=0

		if pa.res.length < pa.col.length then pa.res += "012"[res] 
		if pb.res.length < pb.col.length then pb.res += "012"[2 - res]

handleDelete = (pa,pb) ->
	i = currentTable
	errors = (e for e in errors when e != i)
	if pa.res.length == pb.res.length
		[a,b] = tournament.pairs[i]
		pa = tournament.persons[a]
		pb = tournament.persons[b]
		# b = tournament.pairings[2*i+1]

		pa.res = pa.res.substring 0,pa.res.length-1
		pb.res = pb.res.substring 0,pb.res.length-1
	currentTable = (currentTable + 1) %% (N//2)

window.keyPressed = (event) ->
	# print key
	if key == 'Home' then currentTable = 0
	if key == 'End' then currentTable = (N//2) - 1

	if key == 'ArrowUp'
		currentTable = (currentTable - 1) %% (N//2)
		event.preventDefault()
	if key == 'ArrowDown'
		currentTable = (currentTable + 1) %% (N//2)
		event.preventDefault()

	# if key == 'PageUp' then currentResult -= 800
	# if key == 'PageDown' then currentResult += 800

	# index = 2 * currentTable
	[a,b] = tournament.pairs[currentTable]
	pa = tournament.persons[a]
	pb = tournament.persons[b]

	if key in '0 1' then handleResult a,b,pa,pb,key
	if key == 'Enter' then state = 1 - state
	if key in 'pP' then tournament.lotta()

	if key in 'l' then ZOOM[state] += 1
	if key in 's' then ZOOM[state] -= 1
	if key in 'L' then ZOOM[state] += 4
	if key in 'S' then ZOOM[state] -= 4

	if key == 'x' then fakeInput()
	if key == 'Delete' then handleDelete pa,pb

	xdraw()
