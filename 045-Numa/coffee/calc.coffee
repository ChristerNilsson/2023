# Övriga siffror
# Addition, Multiplikation, Division,Subtraktion, 1/x
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
stack = [1,2,3,4] # [x,y,z,t] [0,1,2,3]
inmatning = false
PI = 3.14159265359
print = console.log
range = _.range

class Knapp
	constructor : (@titel,@x,@y,@w,@h,@klick) ->
	rita : ->
		rect @x,@y,@w,@h
		text @titel,@x,@y+3
	inuti : -> @x-@w/2 < mouseX < @x+@w/2 and @y-@h/2 < mouseY < @y+@h/2
	
window.setup = ->
	createCanvas 360,450
	rectMode CENTER
	textFont 'Courier New'
	textSize 22
	textAlign CENTER,CENTER

	knappar.push new Knapp 'enter',75,170,130,40, ->
		stack.unshift stack[0]
		stack.pop()
		inmatning = false

	knappar.push new Knapp 'clx',180,170,60,40, -> stack[0] = 0

	knappar.push new Knapp '1', 40,220,60,40, -> klickapåKnapp 1
	knappar.push new Knapp '2',110,220,60,40, -> klickapåKnapp 2
	knappar.push new Knapp '3',180,220,60,40, -> klickapåKnapp 3
	knappar.push new Knapp '4', 40,270,60,40, -> klickapåKnapp 4
	knappar.push new Knapp '5',110,270,60,40, -> klickapåKnapp 5
	knappar.push new Knapp '6',180,270,60,40, -> klickapåKnapp 6
	knappar.push new Knapp '7', 40,320,60,40, -> klickapåKnapp 7
	knappar.push new Knapp '8',110,320,60,40, -> klickapåKnapp 8
	knappar.push new Knapp '9',180,320,60,40, -> klickapåKnapp 9
	knappar.push new Knapp '0',110,370,60,40, -> klickapåKnapp 0

	op2 = (f) ->
		stack.push stack[3]
		x = stack.shift()
		y = stack.shift()
		stack.unshift f x,y
		inmatning = false

	op1 = (f) ->
		stack.unshift f stack.shift()
		inmatning = false

	op0 = (f) ->
		stack.pop()
		stack.unshift f()
		inmatning = false

	knappar.push new Knapp '+',250,220,60,40, -> op2 (x,y) -> x + y

	knappar.push new Knapp '*',250,270,60,40, -> op2 (x,y) -> x * y
		
	knappar.push new Knapp '/',250,320,60,40, -> op2 (x,y) -> y / x
		
	knappar.push new Knapp '-',250,370,60,40, -> op2 (x,y) -> y - x
		
	knappar.push new Knapp '**',320,170,60,40, -> op2 (x,y) -> y ** x
		
	knappar.push new Knapp '1/x',250,170,60,40, -> op1 (x) -> 1/x
		
	knappar.push new Knapp 'x!',320,220,60,40, ->
		x = stack[0]
		res=1
		for i in range 1,x+1
			res *= i
		stack[0] = res
		inmatning = false

	knappar.push new Knapp 'fac',320,420,60,40, ->
		stack[0]*= stack[1]
		stack[1]++
		inmatning = false

	knappar.push new Knapp 'fib',250,420,60,40, ->
		x = stack[0]
		x += stack[1]
		stack[0] = x 
		inmatning = false

	knappar.push new Knapp 'sqr',180,420,60,40, ->
		stack[0] = (stack[0] + stack[1] / stack[0])/2
		inmatning = false

	knappar.push new Knapp 'PI',320,320,60,40, -> op0 () -> PI

	knappar.push new Knapp 'swp',320,370,60,40, ->
		[stack[0],stack[1]] = [stack [1],stack[0]]
		inmatning = false

	knappar.push new Knapp 'cla',320,270,60,40, ->
		stack=[0,0,0,0]
		inmatning = false

klickapåKnapp = (siffra) ->
	if inmatning
		stack[0] = 10 * stack[0] + siffra
	else
		stack[0] = siffra
		inmatning = true

window.draw = ->
	background 'gray'
	for knapp in knappar
		knapp.rita()
	textAlign LEFT
	for tal,i in stack
		text 'xyzt'[i]+':',10,25+(4-i)*25
		text tal, 50,25+(4-i)*25
	textAlign CENTER

window.mousePressed = ->
	for knapp in knappar
		if knapp.inuti() then knapp.klick()
