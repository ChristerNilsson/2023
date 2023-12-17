# Pong
ball = null
print = console.log
range = _.range 
paddle=null

class Ball
	constructor : (@x,@y, @dx,@dy) -> @antal = 0 
	draw : ->
		strokeWeight 2
		@antal += 1
		fill  'white' 
		circle @x,@y,10
	updatePosition : ->
		@x += @dx
		@y += @dy
	updateSpeed : ->
		if @x-@r < 0 or width < @x+@r then @dx = -@dx
		if height < @y+@r then @dy = -@dy else @dy += 0.1
	krock : (other) ->
		dx = @x - other.x
		dy = @y - other.y
		@r > sqrt dx*dx + dy*dy
	# studs : (other) ->
	# 	[other.dx,@dx] = [@dx,other.dx]
	# 	[other.dy,@dy] = [@dy,other.dy]

class Paddle
	constructor : (@x,@y, @w,@h) ->
	draw : ->
		strokeWeight 2
		fill  'white'
		rect @x,@y,@w,@h
	updatePosition : ->
		@x += @dx
		@y += @dy
	updateSpeed : ->
		if @x-@r < 0 or width < @x+@r then @dx = -@dx
		if height < @y+@r then @dy = -@dy else @dy += 1
	studs : (other) ->
		other.dy = -other.dy

	inuti : (x,y) ->
		paddle.x < x < paddle.x + paddle.w and paddle.y < y < paddle.y + paddle.h

window.setup = ->
	createCanvas windowWidth-50,windowHeight-50
	stroke 'black'
	paddle = new Paddle width/2,height-50,100,20
	ball = new Ball width/2,height-300,0,0

window.draw = ->
	background 'gray'
	textSize 50
	# text antal,100,100
	ball.updatePosition()
	ball.updateSpeed()
	paddle.draw()
	ball.draw()
	if paddle.inuti ball then print 'smash!'
	if ball.krock paddle then paddle.studs()
	if paddle.x > 0 and keyIsDown LEFT_ARROW then paddle.x -= 5
	if paddle.x + paddle.w < width and keyIsDown RIGHT_ARROW then paddle.x += 5
