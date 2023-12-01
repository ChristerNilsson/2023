# Bouncing Ball
cirkel = null 
ball1 = null
ball2 = null

class Ball
	constructor : (@x,@y,@r,@dx,@dy,@fill='yellow') ->
	draw : ->
		strokeWeight 2
		fill @fill
		cirkel @x,@y,@r
	move :  ->
		@dy=@dy+1
		@x=@x+@dx
		@y=@y+@dy
		if @x-@r < 0 then @dx=-@dx
		if @x+@r > 400 then @dx=-@dx
		if @y-@r < 0 then @dy=-@dy
		if @y+@r > 400 then @dy=-@dy



window.setup = ->
	createCanvas 400,400
	cirkel = circle 
	ball1 = new Ball 250,200,50,5,7,'green'
	ball2 = new Ball 200,100,40,5,8,'red'

window.draw = ->
	# background 'green'
	# stroke 'YeLloW'
	ball1.draw()
	ball1.move()
	ball2.draw()
	ball2.move()
