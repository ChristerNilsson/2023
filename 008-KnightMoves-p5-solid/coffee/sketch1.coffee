import {log,range} from '../js/utils.js'

S = 50
N = 8
NOQUEENS = [3,4,10,13,17,18,19,20,21,22,24,26,29,31,32,34,37,39,41,42,43,44,45,46,50,53,59,60]
mx = S
my = S/2
os = if navigator.userAgent.includes 'Windows' then 'Windows' else 'Mac'
audio = new Audio 'shortclick.mp3'

r = (i) => i // N
c = (i) => i % N
sum = (arr)	=> arr.reduce ((a, b) => a + b), 0

class Board
	constructor : -> @values = _.map range(N*N), (i) => {ri:r(i), ci:c(i)}
	draw : =>
		for {ri,ci} in @values
			fill if (ri+ci) % 2 then 'darkgray' else 'lightgray'
			rect mx+S*ci, my+S*ri, S, S
			fill 'black'
			textSize 0.5*S
		for i in range N
			text "abcdefgh"[i], mx+S/2+S*i, my+8.4*S
			text "87654321"[i], mx-0.4*S, my+S/2+S*i
		if Z.state==0 then @info = "Click on a queen to start"
		txts = @info.split '|'
		for i in range txts.length
			text txts[i], mx+4*S, my + 9.25*S + 0.5*S*i

window.onresize = -> resize()

resize = ->
	H = min(innerHeight//11,innerWidth//10)
	W = H
	S = W
	mx = (innerWidth - 8*S)/2
	my = S/2
	resizeCanvas innerWidth, innerHeight
	rita()

drawText = (txt,ix) => 
	dy = if os=='Windows' then 0.1*S else 0.0*S
	text txt, mx+S/2+S*c(ix), my+S/2+S*r(ix)+dy

class Counts
	constructor : -> @values = []
	draw : =>
		fill 'black'
		textSize 0.5*S
		for i in range @values.length
			drawText @values[i], Z.targets.values[i]
	update : =>
		@values.push Z.count + 1
		Z.count = 0

class Knight
	constructor : (@value) ->
	draw : =>
		fill 'black'
		textSize S
		drawText '♘', @value

class KnightHops
	constructor :  ->
		k = Z.knight.value
		ts = Z.targets.values
		if k==-1 then return []
		@values = []
		col = c k
		row = r k
		for dc in [-2,-1,1,2]
			for dr in [-2,-1,1,2]
				if Math.abs(dc) == Math.abs(dr) then continue
				c2 = col + dc
				r2 = row + dr
				index = c2+N*r2
				if c2 in range(N) and r2 in range(N) and index in ts then @values.push index
		@values.sort (a,b) -> a-b
	draw : =>
		col = c Z.queen.value
		if col%2==1 then return
		fill 'white'
		for i in @values
			circle mx+S/2+S*c(i), my+S/2+S*r(i), S/4
	click : =>
		for index in @values
			if inside index
				audio.play()
				Z.knight = new Knight index
				Z.knightHops = new KnightHops
				if index == Z.target.value
					Z.counts.update()
					Z.target.update Z.targets.values[Z.counts.values.length+1]
					if Z.counts.values.length == Z.targets.values.length-1
						count = sum(Z.counts.values) + Z.count
						Z.board.info = count + " moves in #{(new Date - Z.start)/1000} seconds|Click on the Queen to restart"
						Z.state = 2
						return
				else
					Z.count++
				count = sum(Z.counts.values) + Z.count
				Z.board.info = count + " moves in #{(new Date - Z.start)/1000} seconds"

class Queen
	constructor : (@value) ->
	draw : =>
		fill 'black'
		textSize S
		drawText '♛', @value
	click : => if inside @value then Z.state = 0

class Queens
	constructor : -> @values = _.filter range(N*N), (i) -> i not in NOQUEENS
	draw : =>
		fill 'black'
		textSize S
		for i in @values
			drawText '♛', i
	click : =>
		for index in @values
			if inside index
				Z.count = 0
				Z.counts = new Counts
				Z.queen = new Queen index
				Z.queenHops = new QueenHops
				Z.targets  = new Targets
				Z.knight = new Knight Z.targets.values[Z.counts.values.length]
				Z.target = new Target Z.targets.values[Z.counts.values.length+1]
				Z.knightHops = new KnightHops
				Z.state = 1
				Z.start = new Date
				Z.board.info = "Move the knight to the golden ring"

class QueenHops
	constructor : ->
		@queen =  Z.queen.value
		f = (i) =>
			ci = c i
			ri = r i
			dc = Math.abs ci - @cq
			dr = Math.abs ri - @rq
			ci == @cq or ri == @rq or dc == dr
		@cq = c @queen
		@rq = r @queen
		@values = _.filter range(N*N), f
	draw: =>
		row = r Z.queen.value
		if row%2==0 then return
		fill 'black'
		for i in @values
			if i != @queen then circle mx+S/2+S*c(i), my+S/2+S*r(i), S/4

class Target
	constructor : (@value) ->
	draw : =>
		push()
		stroke 'yellow'
		strokeWeight 3
		noFill()
		circle mx+S/2+S*c(@value), my+S/2+S*r(@value), S/2
		pop()
	update : () => @value = Z.targets.values[Z.counts.values.length+1]

class Targets
	constructor : -> @values = range(N*N).filter (i) => i not in Z.queenHops.values

inside = (index) ->
	ci = c index
	ri = r index
	S*ci < mouseX-mx < S*ci+S and S*ri < mouseY-my < S*ri+S

Z = {} # object to hold global variables.
Z.state = 0
Z.count = 0
Z.counts = new Counts
Z.board = new Board
Z.queen = new Queen 0
Z.queens = new Queens
Z.queenHops = new QueenHops
Z.targets = new Targets
Z.knight = new Knight Z.targets.values[0]
Z.target = new Target Z.targets.values[1]
Z.knightHops = new KnightHops

rita = =>
	background 'gray'
	textSize S
	opss="board,queens|board,queen,queenHops,knight,target,counts,knightHops|board,queen,queenHops,knight,counts"
	ops = opss.split('|')[Z.state]
	Z[op].draw() for op in ops.split ','

window.mousePressed = =>
	Z["queens,knightHops,queen".split(',')[Z.state]].click()
	rita()

window.setup = =>
	createCanvas innerWidth, innerHeight
	#frameRate 1
	textAlign CENTER, CENTER
	resize()
