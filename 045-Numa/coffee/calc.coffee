# Övriga siffror
# Addition, Multiplikation, Division, 1/x
# Pi (x => 3.14)
# Swap (x och y byter plats)
# Clear All (xyzt -> 0000)
# Roll Down (xyzt -> yztx)
# Change Sign (x -> -x)
# Backspace (sista siffran tas bort eller x rensas)
# Upphöjt till (x -> y**x)
# Kvadratrot (x -> sqrt(x))
# Decimalpunkt
# Bithantering: and or xor
# Fakultet (5 ! -> 120)
# Logaritmer Trigonometri
# Exponent

# https://p5js.org/reference
#  createCanvas width height window.setup window.draw background
#  rectMode CENTER rect circle
#  fill stroke strokeWeight
#  text textFont textSize textAlign CENTER LEFT
#  mousePressed mouseMoved mouseX mouseY

# https://www.w3schools.com/js
#  windowWidth windowHeight
#  red green blue ...
#  push pop
#  unshift shift
#  console.log

# https://coffeescript.org
#  class constructor new
#  () ->
#  for in
#  if then else

# https://lodash.com
#  _.range _.sample _.sampleSize

# Christers namn:
#  knappar stack inmatning koordinater Knapp rita inuti @titel @x @y @w @h @klick

knappar = []
stack = [0,0,0,0] # [x,y,z,t] [0,1,2,3]
inmatning = false
koordinater = ''

class Knapp
	constructor : (@titel,@x,@y,@w,@h,@klick) ->

	rita : ->
		rect @x,@y,@w,@h
		text @titel,@x,@y+3

	inuti : ->
		@x-@w/2 < mouseX < @x+@w/2 and @y-@h/2 < mouseY < @y+@h/2
	
window.setup = ->
	createCanvas 400,400
	rectMode CENTER
	textFont 'Courier New'
	textSize 30
	textAlign CENTER,CENTER

	knappar.push new Knapp 'enter',60,170,100,40, ->
		stack.unshift stack[0]
		stack.pop()
		inmatning = false

	knappar.push new Knapp 'clx',200,170,60,40, ->
		stack[0] = 0

	knappar.push new Knapp '1',40,220,60,40, ->
		if inmatning
			stack[0] = 10 * stack[0] + 1
		else
			stack[0] = 1
			inmatning = true

	knappar.push new Knapp '+',200,220,60,40, ->
		stack.push stack[3]
		x = stack.shift()
		y = stack.shift()
		stack.unshift x + y
		inmatning = false

window.draw = ->
	background 'gray'
	for knapp in knappar
		knapp.rita()
	textAlign LEFT
	for tal,i in stack
		text 'xyzt'[i]+':',10,25+(4-i)*25
		text tal, 50,25+(4-i)*25
	textAlign CENTER
	text koordinater,width/2,height-20

window.mousePressed = ->
	for knapp in knappar
		if knapp.inuti() then knapp.klick()

window.mouseMoved = -> koordinater = "x=#{mouseX} y=#{mouseY}"
