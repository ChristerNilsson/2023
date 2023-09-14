import _ from 'https://cdn.skypack.dev/lodash'
import {abs,circle,col,color,logg,N,row,sum,svg,makeIllegals,makeQueens,Position,range,rect,text,signal,effect,r4r} from '/js/utils.js'

W = 0
H = 0
R = W//10

QUEEN = '♛'
KNIGHT = '♘'

[state,    setState]    = signal 0
[QUEENS,   setQUEENS]   = signal []
[queen,    setQueen]    = signal 42
[knight,   setKnight]   = signal 10
[illegals, setIllegals] = signal makeIllegals queen() # indexes of squares taken by queen
[rects,    setRects]    = signal [] # Rect objects
[targets,  setTargets]  = signal [] # indexes of squares that knight must visit

makeState = (nextState) =>
	logg 'makeState'
	if nextState==0
		state0()
	# else if nextState==1 then makeGame()
	# else if nextState==2 then makeResults()
	# else if nextState==3 then makeEnd()
	# else logg 'makeState error'
	setState nextState

	# setQueen 42
	# setKnight 10
	# setIllegals makeIllegals queen()
	# setRects []
	# setTargets []
	# setState 1

intro = """
Click on a square to place the queen.
Avoid the dots and the queen.
The ring will move when taken.
Repeat for all squares.
Qa8 is an easy starter, 118 moves.
Qd5 is a good challenge, 158 moves.
""".split('\n')

setState 0

clicks = 0
arrClicks = []	# number of clicks for each target
taken = 0
results = ['Move the knight to the ring']
start = 0

class Rect
	constructor : (@index, @x,@y, @w,@h, @col) ->
	# draw : ->
	# 	fill @col
	# 	rect @x, @y, @w, @h
	# inside : (x, y) -> abs(x-@x) <= W/2 and abs(y-@y) <= H/2
	click : -> if state()==0 then placeQueen @index else moveKnight @index
#	drawDot : -> if @index != queen() and (row(queen())+col(queen())) % 2 == 0 then circle {cx:@x, cy:@y, r:2*R}
	drawDot : -> circle {cx:@x+@w/2, cy:@y+@h/2, r:2*R}

	# drawPiece : (name) ->
	# 	textSize 1.1 * W
	# 	fill "black"
	# 	text name,@x,@y
	# text : (txt) ->
	# 	textAlign CENTER, CENTER
	# 	textSize 0.5*W
	# 	fill 'black'
	# 	text txt, @x, @y
	# coin : =>
	# 	noFill()
	# 	push()
	# 	strokeWeight 3
	# 	ellipse @x, @y, 5*R
	# 	pop()


placeQueen = (index) =>
	logg 'Q' + Position index
	if not QUEENS().includes index
		logg 'No queen here'
		return

	setQUEENS []
	setQueen index
	setIllegals makeIllegals queen()
	setTargets range(N*N).filter (i) => not illegals().includes i
	setKnight => targets()[0]
	logg 'illegals', illegals()
	logg 'targets', targets()
	logg 'knight', knight()
	# setRects rects
	arrClicks.push 0
	taken++
	setState 1
	logg 'state',state()

state0 = ->
	logg 'state',state()
	setQUEENS => makeQueens()
	logg 'QUEENS',QUEENS()
	reSize()
	# setQueen 0
	# setIllegals []
	# setTargets []
	# setState 0
	# setKnight 0
	clicks = 0
	arrClicks = []
	taken = 0
	start = new Date()

moveKnight = (index) =>
	if illegals().includes index then return
	c = col index
	r = row index
	dx = abs c - col knight()
	dy = abs r - row knight()
	if dx*dx + dy*dy == 5
		logg 'knight moves to', Position index
		setKnight index
		clicks++
		if targets()[taken] == knight()
			taken++
			arrClicks.push clicks
			clicks = 0
	if taken == targets().length
		results.push "Q#{Position queen()}: #{sum(arrClicks)} moves took #{(new Date()-start)/1000} seconds"
		setState  2

reSize = ->
	H = 40 # Math.min innerHeight//13,innerWidth//9
	W = H
	H = W
	R = W//10
	setRects []
	margin = 0 # (innerWidth-8*W)//2
	res = []
	for index in range N*N
		ri = row index
		ci = col index
		clr = if (ri + ci) % 2 then 'brown' else 'yellow'
		x = W/2 + W * col index
		y = H/2 + H * row index
		res.push new Rect index, margin+x, y, W,H, clr
	setRects res
	# logg 'rects',rects()

# reSize()
# logg rects()
#newGame()

makeState 0

r4r =>
	effect => logg 'r4r',QUEENS.length

	svg {viewBox:"0 0 400 400", width:320, height:320},
		for sq in rects()
			do (sq) =>
				r = row sq.index
				c = col sq.index
				x = sq.x #40*r
				y = sq.y # 40*c
				width = sq.w #40
				height = sq.h #40
				fill = color r,c
				onClick = => sq.click()
				rect {x, y, width, height, fill, onClick}
				# if sq.index == queen()
				# 	text {x, y}, QUEEN
				# if sq.index == knight()
				# 	text {x, y}, KNIGHT
				#logg sq

		if state() == 0
			for sq in rects()
				do (sq) =>
					if sq.index in QUEENS()
						x = sq.x + W/2
						y = sq.y + W/2+5
						onClick = => sq.click()
						text {x, y, onClick}, QUEEN


		# sq = rects()[queen()]
		# x = ()=> 20+sq.x #40*row queen()
		# y = ()=> 25+sq.y #40*col queen()
		# text {x,y},QUEEN

		# sq = rects()[knight()]
		# x = ()=> 20+sq.x #*row knight()
		# y = ()=> 25+sq.y #40*col knight()
		# text {x,y},KNIGHT

		# rects()[13].drawDot()
		# rects()[14].drawDot()
		# rects()[15].drawDot()
		# rects()[16].drawDot()

		# for index in illegals()
		# 	logg 'illegals',index
		# 	# rects()[index].drawDot()
		# 	sq = rects()[index]
		# 	circle {cx:sq.x+sq.w/2, cy:sq.y+sq.h/2, r:2*R}
		# 	# logg 'illegals',index
		# 	# # rects()[index].drawDot()
		# 	# sq = rects()[index]
		# 	# circle {cx:sq.x+sq.w/2, cy:sq.y+sq.h/2, r:2*R}

# render Board, document.body
window.onresize = -> reSize()

################################


# setup = =>
# 	reSize()
# 	newGame()
# 	rectMode CENTER
# 	textAlign CENTER, CENTER
# 	createCanvas innerWidth, innerHeight

# info = ->
# 	fill 'black'
# 	textAlign CENTER, CENTER
# 	textSize 0.5*W
# 	temp = if state==0 then intro else results
# 	for result,i in temp
# 		text result,innerWidth//2, 9*H + i*H/2

# drawBoard = =>
# 	for rect in rects
# 		rect.draw()

# draw = =>
# 	background 128
# 	drawBoard()
# 	info()

# 	textAlign CENTER, CENTER
# 	if state > 0
# 		rects[queen].drawPiece Queen
# 		rects[knight].drawPiece Knight

# 	for i in illegal
# 		rects[i].drawDot()

# 	textSize 0.55*W
# 	for i in range taken
# 		if targets[i] != knight
# 			rects[targets[i]].text arrClicks[i]

# 	if state == 1
# 		rects[targets[taken]].coin()

# mousePressed = ->
# 	if state==2
# 		newGame()
# 		return
# 	for rect in rects
# 		if rect.inside mouseX, mouseY then rect.click()


