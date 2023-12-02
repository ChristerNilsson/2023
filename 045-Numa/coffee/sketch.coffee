# Bouncing Ball
balls = []
print = console.log
antal=0

class Ball
	constructor : (@x,@y, @r, @dx,@dy, @colors) -> @antal=0
	draw : ->
		strokeWeight 2
		@antal +=1
		fill  @colors[@antal % @colors.length]
		circle @x,@y,@r
	updatePosition :  ->
		@x += @dx
		@y += @dy
	updateSpeed :  ->
		if @x-@r < 0 or width < @x+@r then @dx = -@dx
		if height < @y+@r then @dy = -@dy else @dy += 1

window.setup = ->
	createCanvas windowWidth-50,windowHeight-50
	stroke 'black'

window.draw = ->
	background 'gray'
	textSize 50
	text antal,100,100
	for ball in balls
		ball.draw()
		ball.updatePosition()
		ball.updateSpeed()

window.mousePressed=->
	antal += 1
	# print antal
	for i in _.range 1
		x = mouseX #_.sample [0.1*width,0.2*width]
		y = mouseY #_.sample [0,92,95,96,97,99,100]
		dy = _.sample [4,5,7,8,9,10]
		col = ['red','blue','green','yellow','white','orange','Chartreuse']
		balls.push new Ball x,y, 42, 5,dy, _.sampleSize col,_.sample [2,3]
