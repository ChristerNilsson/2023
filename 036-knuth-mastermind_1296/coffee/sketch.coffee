N = 6
ALFABET = 'ABCDEF'

range = _.range
ass = (a,b) => if a!=b then console.log 'Assert failed',a,'!=',b

create1296 = ->
	res = []
	for i in ALFABET
		for j in ALFABET
			for k in ALFABET
				for l in ALFABET
					res.push i+j+k+l
	res

evaluate = (guess,code) =>

	if guess.length != code.length then return ''
	n = guess.length

	correct_positions   = _.filter range(n), (i) => guess[i] == code[i]
	num_correct = correct_positions.length

	incorrect_positions = _.filter range(n), (i) => guess[i] != code[i]
	reduced_guess = _.map incorrect_positions, (i) => guess[i]
	reduced_set = _.uniq reduced_guess
	reduced_code = _.map incorrect_positions, (i) => code[i]

	num_transposed = 0
	for x in reduced_set
		num_transposed += Math.min(reduced_guess.filter((y) => y==x).length, reduced_code.filter((y) => y==x).length)

	return "#{num_correct}#{num_transposed}"

ass '11', evaluate 'AABB','ABCD'
ass '11', evaluate 'ABCD','AABB'
ass '01', evaluate '5522','1234'
ass '11', evaluate '4335','1234'
ass '11', evaluate '1415','1234'
ass '02', evaluate '3345','1234'
ass '13', evaluate '2314','1234'
ass '40', evaluate '1234','1234'

ALL = create1296()

skala = 1
xoff = 0
data = null
solution = []
secret = ''
buffer = ''
showSolution = false
orientation = 0

window.preload = -> data = loadJSON "./data_1296.json"

window.setup = ->
	createCanvas windowWidth, windowHeight
	skala = height/100
	textFont "Courier New"
	strokeWeight 0.5
	data = data.data.split '*'
	res = {}
	for index in range 1296
		res[ALL[index]] = "AABB" + data[index] + ALL[index]
	data = res
	clickNew()
	#xdraw() ####

showHelp = (x,y) ->
	textSize 4
	texts = []
	texts.push 'Mastermind 1296'
	texts.push '  (6*6*6*6)'
	texts.push 'Find the four'
	texts.push ' letter secret!'
	texts.push ''
	texts.push 'Max 5 guesses'
	texts.push ' necessary'
	texts.push ''
	texts.push 'Example:'
	texts.push ' CBCD (secret)'
	texts.push ' guess => clue'
	texts.push ' AABB  => 01'
	texts.push ' BCDD  => 12'
	texts.push ' CBDE  => 21'
	texts.push ' CBCD  => 40'
	for i in range texts.length
		text texts[i],x-8,y+5*i

showTable = (table,x,y) -> # table = 'ABCDEFGH'
	textSize 6
	for i in range 0,table.length,4
		t = table.substring i,i+4
		item = t
		answer = evaluate secret,t
		if answer == '40' then showSolution = true
		if t.length==4 then item = t + ' ' + answer
		text item, x,y+i//4*5

window.draw = -> ####
	push() ####
	background "white"
	translate xoff,0

	scale skala

	textAlign CENTER,CENTER
	for button in buttons
		button.draw()
	textAlign LEFT,TOP
	if buffer.length == 0 then showHelp x1,y0 else showTable buffer,x1,y0
	if showSolution then showTable solution,x1,y1
	pop() ####
	textSize 50

setActiveButtons = =>
	n = buffer.length
	antal = n%4
	gray = buffer.substring n-antal,n
	buttons[N+0].active = true #showSolution
	buttons[N+1].active = n > 0
	buttons[N+2].active = buffer.endsWith secret

class Button
	constructor : (@prompt,@x,@y,@w,@h,@ts,@click) -> @active = true
	draw : ->
		push()
		textSize @ts
		fill 'gray'
		rect @x,@y,@w,@h
		fill if @active then 'yellow' else 'lightgray'
		text @prompt,@x+@w/2, @y+@h*0.5+0.5
		pop()
	inside : (mx,my) -> @x <= mx <= @x+@w and @y <= my <= @y+@h and @active

clickLetter = (button) -> 
	if not showSolution and buffer.length < 40
		buffer += button.prompt
		setActiveButtons()

clickNew = ->
	buffer = ''
	secret = _.sample ALL
	console.log secret
	solution = data[secret]
	showSolution = false
	setActiveButtons()

clickUndo = ->
	if buffer.length == 0 then return
	if buffer.length == 1 then showSolution = false
	buffer = buffer.substring 0,buffer.length - 1
	setActiveButtons()

clickSolve = -> if buffer.length >= 20 then	showSolution = true

buttons = []
x0 = 1 # %
x1 = 30
y0 = 1
y1 = 60
for i in range N
	button = new Button ALFABET[i], x0+i%2*10, y0+i//2*10,10,10,10
	button.click = => clickLetter button
	buttons.push button

for i in range 3
	prompts = 'new undo solve'.split ' '
	clicks = [clickNew,clickUndo,clickSolve]
	button = new Button prompts[i], x0+i//5*10, y1+i%5*10,20,10,6, clicks[i]
	button.active = false
	buttons.push button

released = true

window.mousePressed = (event) ->
	event.preventDefault()
	if not released then return
	released = false
	for button in buttons
		if button.inside mouseX/skala,mouseY/skala then button.click()
	#xdraw() ####
	false

window.mouseReleased = (event) ->
	event.preventDefault()
	released = true
	false

window.keyPressed = ->
	s = '' + key
	s = s.toUpperCase()
	if s in ALFABET and buffer.length < 40
		buffer += s
		setActiveButtons()
	if keyCode == BACKSPACE
		clickUndo()
	#xdraw() ####
