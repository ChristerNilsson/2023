SIZE = 30 * 90/89
range = _.range

setup = ->
	c= createCanvas 1200,1200
	angleMode DEGREES
	textAlign CENTER,CENTER
	xdraw()
	saveCanvas c, 'myCanvas', 'jpg'

drawEdge = (n) ->
	push()
	translate 0,-3*SIZE
	textSize 2*SIZE
	text n,0,0
	pop()
	translate -300,-300
	for i in range n+2
		rect SIZE*(i),0,SIZE,SIZE
		rect SIZE*(n+i),0,SIZE,SIZE
	fill 'black'
	circle (n+1.5)*SIZE,SIZE/2,SIZE/4
	fill 'white'
	circle (1.5)*SIZE,SIZE/2,SIZE/4
	circle (2*n+1.5)*SIZE,SIZE/2,SIZE/4

xdraw = ->
	background 'white'
	rect 0,0,600,600
	translate 300,300
	for i in range 1,5
	#for i in range 5,9
		rotate 90
		push()
		drawEdge i
		pop()
