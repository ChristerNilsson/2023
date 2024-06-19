import { parseExpr } from './parser.js'
# import {maxWeightMatching} from './mwmatching.js'
import {Edmonds} from './mattkrick.js' # seems to be better than mwmatching.js

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

# up down  enter  1 space=draw 0  delete  Pair  Small Large  Matrix

ASCII = '0123456789abcdefg'
ALFABET = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' # 62 ronder maximalt
N = 0 # number of players
ZOOM = [40,40,40] # vertical line distance for three states

print = console.log
range = _.range
datum = ''
currentTable = 0
currentResult = 0 
tournament = null
errors = [] # id för motsägelsefulla resultat. Tas bort med Delete

state = 0 # 0=Tables 1=Result 2=Help
resultat = [] # 012 sorterad på id

showType = (a) -> if typeof a == 'string' then "'#{a}'" else a
assert = (a,b) -> if not _.isEqual a,b then print "Assert failure: #{showType a} != #{showType b}"

ok = (p0, p1) -> p0.id != p1.id and p0.id not in p1.opp and abs(p0.balans() + p1.balans()) <= COLORS
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

# cdf = (x) -> # https://www.geeksforgeeks.org/javascript-program-for-normal-cdf-calculator/
#     T = 1 / (1 + 0.2316419 * Math.abs x)
#     D = 0.3989423 * Math.exp -x * x / 2
#     cd = D * T * (0.3193815 + T * (-0.3565638 + T * (1.781478 + T * (-1.821256 + T * 1.330274))))
#     if x > 0 then 1 - cd else cd

# calc = (winner, loser, result, K) ->
#     diff = winner - loser
#     u = diff/400 * sqrt(2)
#     (result - cdf(u)) * K

# elodiff = (games,K=20) -> [calc(a,b,res,K) for a,b,res in games]

normera = (x) -> x # 1000/1010 * x - 392

class Player
	constructor : (@id, @elo="",  @opp=[], @col="", @res="",@name="") ->

	toString : -> "#{@id} #{@name} elo:#{@elo} #{@col} res:#{@res} opp:[#{@opp}] score:#{@score().toFixed(1)} eloSum:#{@eloSum().toFixed(0)}" # balans:#{@balans()}"

	eloSum : -> 
		sp = tournament.sp
		hash = {'w2': 1, 'b2': 1+2*sp, 'w1': 0.5-sp, 'b1': 0.5+sp, 'w0': 0, 'b0': 0}
		sum(normera(tournament.persons[@opp[i]].elo) * hash[@col[i] + @res[i]] for i in range @res.length)

	avgEloDiff : ->
		res = []
		for id in @opp.slice 0, @opp.length - 1
			res.push abs normera(@elo) - normera(tournament.persons[id].elo)
		# print 'avgEloDiff', @opp, res,sum(res) / res.length
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
		nn = @opp.length - 1
		# ocr = ("#{@opp[i]}#{@col[i]}#{if i < nn-1 then "0½1"[@res[i]] else ''}" for i in range(nn)) 
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
		# @round -= 1
		#@lotta()

	write : () ->

	# pair : (persons, pairing=[]) ->
	# 	if pairing.length == N then return pairing
	# 	a = persons[0]
	# 	for b in persons
	# 		if not ok a,b then continue
	# 		newPersons = (p for p in persons when p not in [a,b])
	# 		newPairing = pairing.concat [a,b]
	# 		result = @pair newPersons,newPairing
	# 		if result.length == N then return result
	# 	return []

	generateNet : ->
		edges = []
		for a in range N
			pa = @persons[a]
			for b in range a+1,N
				pb = @persons[b]

				if DIFF == 'ELO' then diff = abs pa.elo - pb.elo
				if DIFF == 'ID'  then diff = abs pa.id - pb.id
				if COST == 'LINEAR'    then cost = 2000000 - diff 
				if COST == 'QUADRATIC' then cost = 2000000 - diff ** 1.01

				if ok pa,pb then edges.push [pa.id,pb.id,cost]
		edges
	
	findSolution : (edges) -> 
		edmonds = new Edmonds edges
		edmonds.maxWeightMatching edges

	# pair : (persons, index=0, pairing=[], antal=0) ->
	# 	# denna version tar 43 sek för rond 16 med 78 spelare.
	# 	if antal == N then return pairing
	# 	a = persons[index]
	# 	for b in persons
	# 		if pairing[b.id] >= 0 then continue
	# 		if not ok a,b then continue
	# 		pairing[a.id] = b.id # sätt paret
	# 		pairing[b.id] = a.id
	# 		if antal+2==N then return pairing
	# 		for ix in range index+1,N # sök upp nästa lediga index
	# 			if pairing[persons[ix].id] == -1 then break
	# 		if antal + 2 < N
	# 			result = @pair persons, ix, pairing, antal+2
	# 			if result.length > 0 then return result
	# 		else
	# 			pairing[a.id] = -1 # återställ paret
	# 			pairing[b.id] = -1
	# 			return pairing
	# 		pairing[a.id] = -1 # återställ paret
	# 		pairing[b.id] = -1
	# 		if index == N then return result
	# 	return []

	flip : (p0,p1) -> # p0 byter färg, p0 anpassar sig
		#print 'flip',p0.col,p1.col
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
		return 

		if p0.col.length == 0
			col1 = @first[p0.id % 2]
			col0 = other col1
			print 'assignColors',col0,col1
			p0.col += col0
			p1.col += col1
		else
			balans = p0.balans() + p1.balans()
			if balans == 0 then @flip p0,p1
			else if 2 == abs balans
				if 2 == abs p0.balans() then @flip p0,p1 else @flip p1,p0
			else print 'unexpected',balans

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

		# @players = _.clone @players
		# @players.sort (a,b) -> a.id - b.id

		# print ""
		# print 'sorterat på elo'
		# for p in @players
		# 	print(p.toString())
		
		#if @round % 2 == 1 then @players = @players.reverse() # reverse verkar inte spela någon roll

		# print 'sorterat på id'
		# for p in @persons
		# 	print(p.toString())

		# if @round == @rounds
		# 	temp = _.clone @players
		# 	temp.sort (a,b) -> 
		# 		diff = b.eloSum() - a.eloSum()
		# 		if diff != 0 then return diff
		# 		return b.score() - a.score()
		# 	print 'sorterat på [eloSum,score]'
		# 	for p in temp
		# 		print(p.toString())

		start = new Date()
		# lista = (-1 for i in range N)
		# print 'lista',lista
		# @pairings = @pair @players, 0, lista
		net = @generateNet @persons
		print 'net',net
		solution = @findSolution net
		print 'solution',solution
		if -1 in solution
			print 'Solution failed!'
			return 
		@pairs = @unscramble solution
		print 'pairs',@pairs
		# @pairings = (@persons[index] for index in solution)
		print 'cpu:',new Date() - start
		# print 'pairings',@pairings

		for [a,b] in @pairs
			pa = @persons[a]
			pb = @persons[b]
			pa.opp.push pb.id
			pb.opp.push pa.id

		print @persons

		# for i in range N//2
		# 	a = @pairings[2*i]
		# 	b = @pairings[2*i+1]
		# 	print "#{a.id}-#{b.id} elo #{a.elo} vs #{b.elo}"

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

		timestamp = new Date().toLocaleString 'se-SE'
		downloadFile tournament.makeStandardFile(" for " + @title + " in Round #{@round}    #{timestamp}"), "R#{@round} #{@title}.txt"
		downloadFile @createURL(), "R#{@round} URL.txt"
		start = new Date()
		if @round > 0 then downloadFile @createMatrix(), "R#{@round} Matrix.txt"
		# downloadFile @generateNet(), "R#{@round} Net.txt"
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
		print 'xxx',players

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

		# @persons = _.cloneDeep @players
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

		#print 'pairings.length',@pairings.length
		for i in range @pairs.length
			[a,b] = @pairs[i]
			a = @persons[a]
			b = @persons[b]
			y += ZOOM[state] * 0.5
			# a = @pairs[2*i  ] # White
			# b = @pairs[2*i+1] # Black
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

	makeStandings : (res) ->
		if @pairs.length == 0 then "This ROUND can't be paired! (Too many rounds)"

		temp = _.clone @players
		temp.sort (a,b) -> 
			diff = b.eloSum() - a.eloSum()
			if diff != 0 then return diff
			return b.elo - a.elo

		#result = []
		res.push "STANDINGS"
		res.push ""

		# Header
		s = ""
		s +=       @txtT "#",     2
		s += ' ' + @txtT "Id",    4,window.RIGHT
		s += ' ' + @txtT "Elo",   4,window.RIGHT
		s += ' ' + @txtT "Name", 25,window.LEFT
		for r in range @round
			s += @txtT "#{r+1}",6,window.RIGHT
		s += '  ' + @txtT "EloSum", 6,window.RIGHT
		header = s
		
		for person,i in temp
			if i % @ppp == 0 then res.push header
			s = ""
			s +=       @txtT (1+i).toString(),          2, window.RIGHT
			s += ' ' + @txtT (person.id+1).toString(),  4, window.RIGHT
			s += ' ' + @txtT person.elo.toString(),     4, window.RIGHT
			s += ' ' + @txtT person.name,              25, window.LEFT
			s += ' '
			for r in range @round
				s += @txtT "#{person.opp[r]+1}#{RINGS[person.col[r][0]]}#{"0½1"[person.res[r]]}", 6, window.RIGHT			
			s += ' ' + @txtT person.eloSum().toFixed(0),  6, window.RIGHT
			res.push s
			if i % @ppp == @ppp-1 then res.push "\f"
		res.push "\f"

	makeNames : (header,players,res) ->
		res.push "NAMES" + header
		res.push ""
		r = tournament.round
		for p,i in players
			if i % @ppp == 0 then res.push "Table Name"
			res.push "#{str(1 + p[1]//2).padStart(3)} #{RINGS[p[0].col[r][0]]} #{p[0].name}"
			if i % @ppp == @ppp-1 then res.push "\f"
		res.push "\f"

	makeTables : (header,res) ->
		res.push "TABLES" + header
		res.push ""
		for i in range @pairs.length
			[a,b] = @pairs[i]
			if i % @tpp == 0 then res.push "Table White".padEnd(5+25) + _.pad("",28) + 'Black'.padEnd(25)
			pa = @persons[a]
			pb = @persons[b]
			res.push ""
			res.push _.pad(i+1,6) + pa.elo + ' ' + @txtT(pa.name, 25, window.LEFT) + ' ' + _.pad("|____| - |____|",20) + ' ' + pb.elo + ' ' + @txtT(pb.name, 25, window.LEFT)
			if i % @tpp == @tpp-1 then res.push "\f"

	makeStandardFile : (header) ->
		res = []
		players = []
		for i in range @pairs.length
			[a,b] = @pairs[i]
			pa = @persons[a]
			pb = @persons[b]
			players.push [pa,2*i]
			players.push [pb,2*i+1]

		# players = ([@persons[@pairs[i]],i] for i in range N//2)
		players = _.sortBy players, (p) -> p[0].name
		print 'players',players

		# players = ("#{_.pad((1+i//2).toString() + 'wb'[i%2] ,5)} #{p.name}" for [p,i] in players)

		@makeStandings res
		@makeNames header,players,res
		@makeTables header,res

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
		print 'showStandings'
		if @pairs.length == 0
			txt "This ROUND can't be paired! (Too many rounds)",width/2,height/2,CENTER
			return

		noStroke()

		# _.sortBy på [score, elo] verkar inte fungera pga array jämförs som sträng?

		temp = _.clone @players
		temp.sort (a,b) -> 
			# return a.id - b.id 
			diff = b.eloSum() - a.eloSum()
			if diff != 0 then return diff
			return b.elo - a.elo

		# print 'tempA',temp
		#temp.reverse()

		# inv = (p.id for p in temp)
		# inv = invert inv

		y = 1.5 * ZOOM[state] + currentResult
		textAlign LEFT
		rheader = _.map range(1,@rounds+1), (i) -> "#{i%10} "
		rheader = rheader.join ' '

		s = ""
		s +=       @txtT "#",    2
		s += ' ' + @txtT "Id",   4,window.RIGHT
		s += ' ' + @txtT "Elo",  4,window.RIGHT
		s += ' ' + @txtT "Name", 25,window.LEFT
		s += ' ' + @txtT rheader,3*@rounds,window.LEFT 
		s += ' ' + @txtT "EloSum", 7,window.RIGHT
		
		text s,10,y

		fill 'white' 
		for person,i in temp
			y += ZOOM[state] * 0.5
			s = ""
			s +=       @txtT (1+i).toString(),      2, window.RIGHT
			s += ' ' + @txtT (person.id+1).toString(),  4, window.RIGHT
			s += ' ' + @txtT person.elo.toString(), 4, window.RIGHT
			s += ' ' + @txtT person.name,          25, window.LEFT
			s += ' ' + @txtT '', 3*@rounds, window.CENTER
			print(person)
			score = person.score()
			score = myRound score, 1
			s += ' ' + @txtT person.eloSum().toFixed(1),  7, window.RIGHT

			text s,10,y

			#print('round',round)
			for r in range @round-1
				x = ZOOM[state] * (12.1 + 0.9*r)
				# print r,person.col[r][0], x, y, person.res[r], inv[person.opp[r]]
				# @lightbulb person.col[r][0], x, y, person.res[r], initials @players[inv[person.opp[r]]].name
				@lightbulb person.col[r][0], x, y, person.res[r], person.opp[r]+1 # initials @persons[person.opp[r]].name

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
