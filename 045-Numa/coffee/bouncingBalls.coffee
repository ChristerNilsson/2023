# Bouncing Ball
balls = []
print = console.log
range = _.range
antal = 0

class Ball
	constructor : (@x,@y, @r, @dx,@dy, @color) -> @antal = 0 
	draw : ->
		strokeWeight 2
		@antal += 1
		fill  @color #s[@antal % @colors.length]
		circle @x,@y,2*@r
	updatePosition : ->
		@x += @dx
		@y += @dy
	updateSpeed : ->
		if @x-@r < 0 or width < @x+@r then @dx = -@dx
		if height < @y+@r then @dy = -@dy else @dy += 1
	krock : (other) ->
		dx = @x - other.x
		dy = @y - other.y
		@r > sqrt dx*dx + dy*dy
	studs : (other) ->
		[other.dx,@dx] = [@dx,other.dx]
		[other.dy,@dy] = [@dy,other.dy]

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
	for i in range balls.length
		for j in range i+1, balls.length
			if balls[i].krock balls[j]
				balls[i].studs balls[j]

window.mousePressed = ->
	antal += 1
	x = mouseX
	y = mouseY
	dy = _.sample [4,5,7,8,9,10]
	col = ['red','blue','green','yellow','white','orange','Chartreuse']
	balls.push new Ball x,y, 40, 5,dy, _.sample col
