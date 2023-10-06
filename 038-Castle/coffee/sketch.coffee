# Vectorized Playing Cards 2.0 - http://sourceforge.net/projects/vector-cards/
# Copyright 2015 - Chris Aguilar - conjurenation@gmail.com
# Licensed under LGPL 3 - www.gnu.org/copyleft/lesser.html

#  4  5  6  7  8  9 10 11  0 
#  4  5  6  7  8  9 10 11  1
#  4  5  6  7  8  9 10 11  2 
#  4  5  6  7  8  9 10 11  3
#  4  5  6  7  8  9 10 11
#  4  5  6  7  8  9 10 11

###
Korten benämnes :
  abcdefghijklm hjärter
  nopqrstuvwxyz spader
  ABCDEFGHIJKLM ruter
  NOPQRSTUVWXYZ klöver
  A23456789TJQK

Startposition:
  a n A N (fyra äss. Observera att man bara behöver lagra högsta kortet)
  egUSBy (en hög med korten h5 h7 c8 c6 d2 sQ. Åtta högar behövs)
  Totalt 52 + 11 = 63 tecken

Slutposition:
  m z M Z + några blanka separatorer
  Totalt 4 + 11 = 15 tecken.

Med hjälp av dessa strängar kan man förhindra att man besöker redan besökta noder.

###

N = 9

ACES  = [0,1,2,3]
HEAPS = [4,5,6,7,8,9,10,11]
#comeFrom = {}

Suit = 'chsd'
Rank = "A23456789TJQK"
SUIT = "club heart spade diamond".split ' '
RANK = "A23456789TJQK" 
LONG = " Ace Two Three Four Five Six Seven Eight Nine Ten Jack Queen King".split ' '

# Konstanter för cards.png
OFFSETX = 468
W = 263.25
H = 352

w = null
h = null
LIMIT = 1000 # Maximum steps considered before giving up. 1000 is too low, hint fails sometimes.

faces = null
backs = null

board = null
cards = null
cands = null
hash = null
aceCards = 4
originalBoard = null

startCompetition = null
srcs = null
dsts = null
vip = []

alternativeDsts = []

infoLines = []
general = null

released = true

prnt = console.log

range = _.range
Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') ->
	if not _.isEqual a,b
		prnt msg
		prnt "  ",a
		prnt "  ",b

getParameters = (h = window.location.href) -> 
	h = decodeURI h
	arr = h.split '?'
	if arr.length != 2 then return {}
	s = arr[1]
	if s=='' then return {}
	_.fromPairs (f.split '=' for f in s.split('&'))

myRandom = (a,b) -> 
	x = 10000 * Math.sin general.fastSeed++
	r = x - Math.floor x
	a + Math.floor (b-a) * r

myShuffle = (array) ->
	n = array.length 
	for i in range n
		#j = myRandom i, n
		j = _.random i, n-1, false
		#prnt j
		value = array[i]
		array[i] = array[j]
		array[j] = value

copyToClipboard = (txt) ->
	copyText = document.getElementById "myClipboard"
	copyText.value = txt 
	copyText.select()
	document.execCommand "copy"

makeLink = -> 
	url = window.location.href + '?'
	index = url.indexOf '?'
	url = url.substring 0,index
	url + '?cards=' + general.slowSeed

class BlackBox # Avgör om man lyckats eller ej. Man får tillgodogöra sig tidigare drag.
	constructor : -> @clr()
	clr : ->
		@total = [0,0,0] # [time,computer,human]
		@count = 0
		#@success = false 
	show : -> # prnt 'BlackBox',@count,@total

class General
	constructor : ->
		@slowSeed = 1 # stored externally
		@fastSeed = 1 # used internally
		@start = null
		@maxMoves = null
		@hist = null
		@hintsUsed = 0
		@blackBox = new BlackBox()
		@clr()
		@getLocalStorage()

	success : -> @blackBox.total[2] + @hist.length <= @blackBox.total[1] + @maxMoves 

	probe : (time) ->
		if not @success() then return false 
		total = @blackBox.total
		total[0] += time
		total[1] += @maxMoves
		total[2] += @hist.length
		true

	getLocalStorage : ->
		#prnt 'direct',localStorage.Generalen
		if localStorage.Generalen? then hash = JSON.parse localStorage.Generalen else hash = {}
		if 5 != _.size hash then hash = {slowSeed:1, fastSeed:1, total:[0,0,0], hintsUsed:0} 
		#prnt 'hash',JSON.stringify hash
		@slowSeed = hash.slowSeed
		@fastSeed = hash.fastSeed
		@blackBox.total = hash.total
		@hintsUsed = hash.hintsUsed
		#prnt 'get', JSON.stringify hash

	putLocalStorage : ->
		s = JSON.stringify {slowSeed:@slowSeed, fastSeed:@fastSeed, total:@blackBox.total, hintsUsed:@hintsUsed} 
		localStorage.Generalen = s 
		prnt 'put',s

	clr : ->
		@blackBox.clr()
		@timeUsed = 0
		#@putLocalStorage()

	totalRestart : ->
		@slowSeed = int random 65536
		@clr()

	handle : (mx,my) ->
		marked = [(mx + if my >= 3 then 12 else 4),my]
		heap = oneClick marked,board,true

		if @timeUsed == 0 and 4*N == countAceCards board
			timeUsed = (millis() - @start) // 1000
			if @probe timeUsed
				@timeUsed = timeUsed
				@blackBox.show()
			@putLocalStorage()
			prntManualprnt()

preload = -> 
	faces = loadImage 'cards/Color_52_Faces_v.2.0.png'
	backs = loadImage 'cards/Playing_Card_Backs.png'

pack = (suit,rank) -> Suit[suit] + RANK[rank] # + if under==over then '' else RANK[over]
assert 'cA', pack 0,0
assert 'dA', pack 3,0
assert 'd2', pack 3,1
assert 'hQ', pack 1,11
assert 'hJ', pack 1,10
#prnt 'pack ok'

packAll = (cards) -> _.map cards, (card) -> pack card[0],card[1]

unpack = (n) -> 
	suit = Suit.indexOf n[0]
	rank = RANK.indexOf n[1]
	[suit,rank]
assert [0,0], unpack 'cA'
assert [3,0], unpack 'dA'
assert [1,11], unpack 'hQ'
assert [1,10], unpack 'hJ'
#prnt 'unpack ok'

unpackAll = (cards) -> _.map cards.split(' '), (card) -> unpack card
assert [[0,0],[3,1]], unpackAll 'cA d2'

compress = (board) ->
	for heap in HEAPS
		board[heap] = compressOne board[heap]

compressOne = (cards) -> cards

countAceCards = (b) ->
	res = 0
	for heap in ACES
		res += b[heap].length
	res

countEmptyPiles = (b) ->
	res = 0
	for heap in HEAPS
		if b[heap].length == 0 then res++
	res

dumpBoard = (board) -> (heap.join ' ' for heap in board).join '|'

makeBoard = ->
	#N = 13

	cards = []
	for suit in range 4
		for rank in range 1,N # 2..K
			cards.push pack suit,rank
	#prnt cards

	#general.fastSeed++ # nödvändig?
	myShuffle cards

	board = []
	for i in range 4+8
		board.push []

	for suit,heap in range 4 
		board[heap].push pack suit,0 # Ess

	for card,i in cards
		heap = 4+i%8
		board[heap].push card

	#prnt board
	board

readBoard = (b) -> (if heap=='' then [] else heap.split ' ') for heap in b.split '|'

fakeBoard = ->
	board = readBoard   "cA|hA|sA|dA|hT c3 s4 c4 h2 s2|c5 s9 hJ cT sQ d2|dQ h4 cK s8 c2 sJ|h6 cQ s3 d8 h5 s7|c6 d3 s5 h7 h3 d5|h9 d7 dK hQ d6 sK|h8 d9 c8 c9 c7 d4|cJ hK s6 dJ sT dT" # 111418466
	
	#N = 13
	#board =  readBoard "cA|hA|sA|dA|c4 dJ c6 h2 h3 sJ|hQ c8 s5 sT h8 h4|c7 s7 h6 s9 s2 dK|d8 sK cT h7 cK d3|cQ d2 c5 d5 cJ s4|d6 hK h5 dQ c2 hT|c3 c9 hJ d7 sQ d4|h9 d9 s3 dT s6 s8" # 452200020
	#vip = '4 c6 4 h3 5 sT 6 s9 7 cK 8 d5 8 cJ 9 dQ 9 hT 10 c9 11 dT 11 s6 11 s8'
	
	#board =  readBoard "cA|hA|sA|dA|c2 c3|c4 c5|d2 d3|d4 d5|s2 s3|s4 s5|h2 h3|h4 h5" # ingen lösning
	#board =  readBoard "cA|hA|sA|dA|c3 c2|c5 c4|d3 d2|d5 d4|s3 s2|s5 s4|h3 h2|h5 h4" # lösning direkt

	# N = 5
	# board =  readBoard "cA|hA|sA|dA|s4 c4|s3 d5|h5 c3|s5 c5|d4 d3|h4 d2|h2 h3|s2 c2" # ett VIP card
	# vip = '10 h3'

	# N = 9
	# board =  readBoard "cA|hA|sA|dA|h8 c8 s2 c4|d4 d8 s6 c2|c3 d9 h6 s5|s8 c6 c7 s7|h7 s4 d3 c5|s3 d6 h2 s9|d2 h3 h4 d5|d7 h5 h9 c9"
	# vip = []

	N = 7
	board =  readBoard "cA|hA|sA|dA|s5 d2 d7|h7 c6 c4|h6 s2 c2|c7 d3 d5|d4 s6 s7|c3 s3 h3|c5 s4 h4|d6 h5 h2"
	vip = []

	# N = 5 # 104 drag. Dock manuellt 20 drag
	# board =  readBoard "cA|hA|sA|dA|c3 c5|h5 h2|d5 d4|s4 d2|c4 c2|s2 s5|d3 s3|h3 h4"
	# vip = []

	prnt board

done = []

recurse = (b,level=0,done=[]) ->
	#if level > 3000 then return false
	key = dumpBoard b

	# if key in done then return false
	#done = done.concat key

	#prnt 'recurse',level,done.length,  _.map b, (pile) -> pile.length
	prnt key
	if b[0].length + b[1].length + b[2].length + b[3].length == N*4
		solution = _.cloneDeep done
		console.log 'Solved!', level, done.length
		return true
	moves = findAllMoves b,level
	for [src,dst] in moves
		prnt src,dst
		b[dst].push b[src].pop()
		done.push key
		if not done.includes dumpBoard b
			res = recurse b, level+1, done
		done.pop()
		b[src].push b[dst].pop()
		if res then return true
	false

newGame = ->
	general.start = millis()
	general.hist = []

	for i in range 1
		done = []
		makeBoard()
		prnt dumpBoard board
		start = new Date()
		recurse board
		console.log new Date() - start, 'ms'

	return


	for i in range 1

		makeBoard()

		general.hintsUsed = 0
		originalBoard = _.cloneDeep board

		aceCards = countAceCards board

		cands = []
		cands.push [aceCards,0,board,[]] # antal kort på ässen, antal drag, boa
		hash = {}
		nr = 0
		cand = null
		prnt 'newGame',nr,LIMIT,cands.length,aceCards,N

		level = 0
		while aceCards != N*4 and cands.length > 0 and level < 200
			level++
			cands2 = []
			for cand in cands
				aceCards = cand[0]
				emptyPiles = cand[1]
				if aceCards == N*4 then break
				increment = expand cand
				cands2 = cands2.concat increment
			cands = cands2
			cands.sort (a,b) -> b[0]-a[0] # if b[0]==a[0] then b[1]-a[1] else b[0]-a[0]
			cands = cands.slice 0,2000 # större ger längre körning och kortare lösning.

			if cands.length > 0
				prnt 'candsx', level, cands.length,cands[0][0]

			#for cand in cands
			#	prnt JSON.stringify cand

		if aceCards == N*4
			prnt JSON.stringify dumpBoard originalBoard
			board = cand[2]
			prnt makeLink()
			prntAutomaticprnt hash,board
			board = _.cloneDeep originalBoard
			prnt "#{int millis()-general.start} ms"
			general.start = millis()
			general.maxMoves = int cand[1]
			return

setup = ->
	canvas = createCanvas innerWidth-0.5, innerHeight-0.5
	canvas.position 0,0 # hides text field used for clipboard copy.

	general = new General()

	w = width/9
	h = height/4
	angleMode DEGREES

	params = getParameters()
	if 'cards' of params
		general.slowSeed = parseInt params.cards

	startCompetition = millis()
	infoLines.push 'Moves Bonus Cards   Time Hints'.split ' '
	infoLines.push '0 0 0   0 0'.split ' '

	newGame()
	display board

keyPressed = ->
	if key == 'X'
		N = 7
		board = "cA7|hA4|sA3|dA2||h6|s5 d6||h5 d5||s4 s6|d34||d7|s7|h7||||"
		general.hist = [[12,0,1],[5,1,1],[8,3,1],[9,1,1],[11,1,1],[16,2,1],[17,0,1],[10,0,1],[9,0,1],[18,2,1],[19,0,1],[7,0,1]]		
		board = readBoard board
		prnt board
	display board

# returnerar övre, vänstra koordinaten för översta kortet i högen som [x,y]
getCenter = (heap) ->
	if heap in ACES then return [int(8*w), int(heap*h)]
#	if heap in PANEL then return [int((heap-12)*w), int(3*h)]
	if heap in HEAPS
		n = board[heap].length
		dy = if n == 0 then 0 else min h/4,2*h/(n-1)
		return [int((heap-4)*w), int((n-1)*dy)]

menu0 = (src,dst,col) ->
	dialogue = new Dialogue 0,int(w/2),int(h/2),int(0.10*h),col
	r = int 0.05 * height
	[x,y] = getCenter src
	dialogue.add new Button 'From', x,y,r, -> dialogues.pop()
	[x,y] = getCenter dst
	dialogue.add new Button 'To',   x,y,r, -> dialogues.pop()

menu1 = ->
	dialogue = new Dialogue 1,int(4*w),int(1.5*h),int(0.15*h) 

	r1 = 0.25 * height
	r2 = 0.085 * height
	dialogue.clock ' ',6,r1,r2,90+360/12

	dialogue.buttons[0].info 'Undo', general.hist.length > 0, ->
		if general.hist.length > 0 
			[src,dst,antal] = _.last general.hist
			dialogues.pop()
			undoMove general.hist.pop()
			menu0 src,dst,'#ff0'
		else
			dialogues.pop()

	dialogue.buttons[1].info 'Hint', true, ->
		dialogues.pop()
		hint() # Lägger till menu0

	dialogue.buttons[2].info 'Cycle Move', alternativeDsts.length > 1, ->
		alternativeDsts.push alternativeDsts.shift()
		[src,dst,antal] = general.hist.pop()
		undoMove [src,dst,antal]
		heap = alternativeDsts[0]
		makeMove board,src,heap,true
		# dialogues.pop() # do not pop!

	dialogue.buttons[3].info 'Next', general.success(), ->
		newGame()
		general.timeUsed = 0
		general.putLocalStorage()
		dialogues.pop()

	dialogue.buttons[4].info 'Help', true, ->
		window.open "https://github.com/ChristerNilsson/Lab/tree/master/2018/056-GeneralensTidsf%C3%B6rdriv#generalens-tidsf%C3%B6rdriv"

	dialogue.buttons[5].info 'More...', true, ->
		menu2()

menu2 = ->
	dialogue = new Dialogue 2,int(4*w),int(1.5*h),int(0.15*h)

	r1 = 0.25 * height
	r2 = 0.11 * height
	dialogue.clock ' ',3,r1,r2,90+360/6

	dialogue.buttons[0].info 'Restart', true, ->
		restart()
		dialogues.clear()

	dialogue.buttons[1].info 'Total Restart', true, ->
		general.totalRestart()
		newGame() # 0
		dialogues.clear()

	dialogue.buttons[2].info 'Link', true, ->
		link = makeLink()
		copyToClipboard link
		#msg = 'Link copied to clipboard'
		dialogues.clear()

showHeap = (board,heap,x,y,dy) -> # dy kan vara både pos och neg
	n = board[heap].length
	x = x * w
	if n > 0
		y = y * h + y * dy
		for card,k in board[heap]
			[suit,rank] = unpack card
			#dr = if under < over then 1 else -1
			#for rank in range under,over+dr,dr
			noFill()
			stroke 0
			image faces, x, y, w,h*1.1, OFFSETX+W*rank,1092+H*suit,225,H-1
			y += dy

		# visa eventuellt baksidan
		card = _.last board[heap]
		[suit,rank] = unpack card
		if heap in ACES and rank == N-1
			image backs, x, y, w,h*1.1, OFFSETX+860,1092+622,225,H-1

display = (board) ->
	prnt 'display',board
	background 0,128,0

	generalen()

	textAlign CENTER,TOP
	for heap,y in ACES
		showHeap board, heap, 8, y, 0
	for heap,x in HEAPS
		n = board[heap].length
		dy = if n == 0 then 0 else min h/4,2*h/(n-1)
		showHeap board, heap, x, 0, dy
	#for heap,x in PANEL
	#	showHeap board, heap, x, 3, 0

	showInfo()

	noStroke()
	showDialogue()

text3 = (a,b,c,y) ->

showInfo = ->
	fill 64
	prnt 'textSize'
	textSize 0.1*(w+h)

	total = general.blackBox.total

	infoLines[1][1-1] = general.maxMoves - general.hist.length
	infoLines[1][2-1] = total[1] - total[2] # bonus
	infoLines[1][3-1] = 4*N - countAceCards(board) # cards
	infoLines[1][6-1] = total[0] # time 
	infoLines[1][7-1] = general.hintsUsed # hints

	fill 255,255,0,128
	stroke 0,128,0

	textAlign CENTER,BOTTOM
	for i in range 7
		x = w*(i+0.5)
		for j in range 2
			y = h*(2.8 + 0.2*j)
			text infoLines[j][i], x,y

generalen = ->
	textAlign CENTER,CENTER
	textSize 0.5*(w+h)
	stroke 0,64,0
	noFill()
	text 'Generalens',  4*w,0.5*h
	text 'Tidsfördriv', 4*w,1.5*h

showDialogue = -> if dialogues.length > 0 then (_.last dialogues).show()

legalMove = (board,src,dst) ->
	if src in ACES then return false
	if board[src].length==0 then return false
	if board[dst].length==0 then return true
	[suit1,rank1] = unpack _.last board[src]
	[suit2,rank2] = unpack _.last board[dst]
	if dst in [0,1,2,3]
		rank2 + 1 == rank1 and suit1 == suit2
	else
		rank2 == 1 + rank1

makeMove = (board,src,dst,record) ->
	[suit,rank] = unpack board[src].pop()
	if record then general.hist.push [src, dst, 1 + rank]
	board[dst].push pack suit,rank

# returns text move
undoMove = ([src,dst,antal]) ->
	res = prettyUndoMove src,dst,board,antal
	[board[src],board[dst]] = undoMoveOne board[src],board[dst],antal
	res

undoMoveOne = (a,b,antal) ->
	[suit, rank] = b.pop()
	a.push [suit,rank]
	[a,b]
#assert [['d9T'],['dJ']], undoMoveOne [],['dJ9'],2
#assert [['d9'],['dJT']], undoMoveOne [],['dJ9'],1

prettyUndoMove = (src,dst,b,antal) ->
	c2 = _.last b[dst]
	if b[src].length > 0
		c1 = _.last b[src]
		"#{prettyCard2 c2,antal} to #{prettyCard c1}"
	else
		if src in HEAPS then "#{prettyCard2 c2,antal} to hole"

# returns destination
oneClick = (marked,board,sharp=false) ->

	holes = []
	found = false

	alternativeDsts = [] # för att kunna välja mellan flera via Cycle Moves
	for heap in ACES
		if legalMove board,marked[0],heap
			if sharp then makeMove board,marked[0],heap,true
			found = true
			return heap

	if not found # Går ej att flytta till något ess.
		for heap in HEAPS
			if board[heap].length == 0
				if board[marked[0]].length > 1 # marked[0] in PANEL or
					holes.push heap
			else 
				if legalMove board,marked[0],heap
					alternativeDsts.push heap
		if holes.length > 0 then alternativeDsts.push holes[0]

		if alternativeDsts.length > 0
			heap = alternativeDsts[0]
			if sharp then makeMove board,marked[0],heap,true
			return heap

	return marked[0] # no Move can happen

hitGreen = (mx,my,mouseX,mouseY) ->
	if my==3 then return false
	seqs = board[mx+4]
	n = seqs.length
	if n==0 then return true
	mouseY > h*(1+1/4*(n-1))

mouseReleased = ->
	released = true
	false

mousePressed = ->

	if not released then return false
	released = false

	if not (0 < mouseX < width) then return false
	if not (0 < mouseY < height) then return false

	mx = mouseX//w
	my = mouseY//h

	if dialogues.length == 1 and dialogues[0].number == 0 then dialogues.pop() # dölj indikatorer

	dialogue = _.last dialogues
	if dialogues.length == 0 or not dialogue.execute mouseX,mouseY

		if mx == 8 or hitGreen mx,my,mouseX,mouseY
			if dialogues.length == 0 then menu1() else dialogues.pop()
			display board
			return false

		dialogues.clear()
		general.handle mx,my

	display board
	false

####### AI-section ########

calcVip = (cards) ->
	highest = [0,0,0,0]
	for [suit,rank] in cards
		if highest[suit] != 0 and rank > highest[suit]
			#prnt 'calcVip',packAll(cards),true
			return true
		highest[suit] = rank
	#prnt 'calcVip',packAll(cards),false
	false
assert true,calcVip unpackAll 's5 d2 d7'
assert false,calcVip unpackAll 's5 d6 s4'

# Börja med längsta kön
# Prioritera viphögar. Ex d7 blockar d2
# beräkna vip on the fly
# jämför med ässhögens översta kort

findAllMoves = (b,level) ->
	#prnt 'findAllMoves',{b}
	srcs = HEAPS.concat []
	dsts = ACES.concat HEAPS
	#res = []

	prio = []

	for src in srcs
		if b[src].length == 0 then continue
		vip = calcVip b[src]
		# prioCard = false # vip.includes src + ' ' + _.last(b[src])
		#prnt prioCard, src + ' ' + _.last(b[src]), vip
		for dst in dsts
			if src == dst then continue
			if not legalMove b,src,dst then continue
			if b[src].length==1 and b[dst].length==0 then continue
			if dst in [0,1,2,3]
				prio.push [src,dst,999]
			else 
				if vip
					prio.push [src,dst,b[src].length * 10]
				else
					prio.push [src,dst,b[src].length]

	prio = prio.sort (a,b) -> b[2] - a[2]
	prnt JSON.stringify prio
	prio = _.map prio, (item) -> item.slice 0,2
	prnt JSON.stringify prio
	prio

# findAllMoves = (b,level) ->
# 	# undertrycker inte flytt till ointressanta hål just nu.
# 	# endast ett hål är intressant
# 	#prnt 'findAllMoves',{b}
# 	srcs = HEAPS.concat []
# 	dsts = ACES.concat HEAPS
# 	#res = []

# 	prio = []

# 	for src in srcs
# 		if b[src].length == 0 then continue
# 		prioCard = false # vip.includes src + ' ' + _.last(b[src])
# 		#prnt prioCard, src + ' ' + _.last(b[src]), vip
# 		for dst in dsts
# 			if src == dst then continue
# 			if not legalMove b,src,dst then continue
# 			if dst in [0,1,2,3]
# 				prio.push [src,dst,0]
# 			else if b[dst].length > 0
# 				if prioCard then prio.push [src,dst,1] else prio.push [src,dst,2]
# 			else 
# 				if prioCard then prio.push [src,dst,3] else prio.push [src,dst,4]

# 	prio = prio.sort (a,b) -> a[2] - b[2]
# 	#prnt JSON.stringify prio
# 	prio = _.map prio, (item) -> item.slice 0,2
# 	#prnt JSON.stringify prio
# 	prio
# 	#prnt 'res',level, JSON.stringify res

expand = ([aceCards,emptyPiles,b,path]) ->
	#prnt 'expand',{aceCards,b,path}
	res = []
	moves = findAllMoves b
	#comeFrom = {}
	for move in moves
		[src,dst] = move
		b1 = _.cloneDeep b
		makeMove b1,src,dst
		key = dumpBoard b1
		# console.log key
		if key not of hash
			newPath = path.concat [move]
			hash[key] = [newPath, b]
			res.push [countAceCards(b1), countEmptyPiles(b1), b1, path.concat([move])]
			#prnt {src,dst,position}
	res

hint = ->
	if 4*N == countAceCards board then return
	general.hintsUsed++

	#dialogues.pop()

	res = hintOne()
	if res or general.hist.length==0 then return

	# Gick ej att gå framåt, gå bakåt
	[src,dst,antal] = _.last general.hist
	menu0 src,dst,'#f00'
	prnt 'red',dialogues.length

hintOne = -> 
	hintTime = millis()
	aceCards = countAceCards board
	if aceCards == N*4 then return true
	cands = []
	cands.push [aceCards,general.hist.length,board,[]] # antal kort på ässen, antal drag, board

	hash = {}
	key = dumpBoard board
	path = []
	hash[key] = [path, board]

	nr = 0
	cand = null
	origBoard = _.cloneDeep board

	while nr < 10000 and cands.length > 0 and aceCards < N*4
		nr++ 
		cand = cands.pop()
		aceCards = cand[0]
		if aceCards < N*4
			increment = expand cand
			cands = cands.concat increment
#			cands.sort (a,b) -> if a[0] == b[0] then b[1]-a[1] else a[0]-b[0]
			#cands.sort (a,b) -> a[0]-b[0]
		#prnt cands
	#prnt N,nr,cands.length,aceCards

	if aceCards == N*4
		board = cand[2]
		#prntAutomaticprnt hash, board
		path = cand[3]
		board = origBoard
		[src,dst] = path[0]
		#makeMove board,src,dst,true
		#dialogues.pop()
		menu0 src,dst,'#0f0'
		#prnt "hint: #{int millis()-hintTime} ms"
		return true
	else
		prnt 'hint failed. Should never happen!'
		#prnt N,nr,cands.length,aceCards,_.size hash
		board = origBoard
		return false

restart = ->
	general.hist = []
	board = _.cloneDeep originalBoard

prettyCard2 = (card,antal) ->
	[suit,under,over] = unpack card
	if antal==1 
		"#{SUIT[suit]} #{RANK[over]}"
	else
		if under < over
			"#{SUIT[suit]} #{RANK[over]}..#{RANK[over-antal+1]}"
		else
			"#{SUIT[suit]} #{RANK[over]}..#{RANK[over+antal-1]}"

prettyCard = (card,antal=2) ->
	[suit,rank] = unpack card
	if antal==1 then "#{RANK[rank]}"
	else "#{SUIT[suit]} #{RANK[rank]}"
assert "club A", prettyCard pack 0,0
assert "club T", prettyCard pack 0,9
assert "heart J", prettyCard pack 1,10
assert "spade Q", prettyCard pack 2,11
assert "diamond K", prettyCard pack 3,12
assert "3", prettyCard pack(3,2),1
#prnt 'prettyCard ok'

prettyMove = (src,dst,b) ->
	prnt 'prettyMove',src,dst,b
	c1 = _.last b[src]
	if b[dst].length > 0
		c2 = _.last b[dst]
		"#{prettyCard c1} to #{prettyCard c2,1}"
	else
		if dst in HEAPS then "#{prettyCard c1} to hole"
		else "#{prettyCard c1} to panel"

prntAutomaticprnt = (hash, b) ->
	key = dumpBoard b
	prnt = []
	while key of hash
		[path,b] = hash[key]
		prnt.push hash[key]
		key = dumpBoard b
	prnt.reverse()
	s = 'Automatic prnt:'
	for [path,b],index in prnt
		[src,dst] = _.last path
		s += "\n#{index}: #{prettyMove src,dst,b} (#{src} to #{dst})"
	prnt s

prntManualprnt = ->
	b = _.cloneDeep originalBoard
	s = 'Manual prnt:'
	for [src,dst,antal],index in general.hist
		s += "\n#{index}: #{prettyMove src,dst,b}"
		makeMove b,src,dst,false
	prnt s
