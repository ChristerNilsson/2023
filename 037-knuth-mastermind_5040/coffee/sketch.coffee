N = 10
ALFABET = 'ABCDEFGHIJ'

range = _.range
ass = (a,b) => if a!=b then console.log 'Assert failed',a,'!=',b

create5040 = ->
	res = []
	for i in range N
		for j in range N
			if i == j then continue
			for k in range N
				if k in [i,j] then continue
				for l in range N
					if l in [i,j,k] then continue
					res.push ALFABET[i] + ALFABET[j] + ALFABET[k] + ALFABET[l]
	res

evaluate = (guess,secret) =>
	res= []
	for i in range guess.length
		if guess[i] in secret
			res.push str abs i - secret.indexOf guess[i]
	res = res.sort().join ""
	if res=='' then '----' else res

ALL = create5040()

skala = 1
xoff = 0
data = null
solution = []
secret = ''
buffer = ''
showSolution = false

window.preload = -> data = loadJSON "./data_5040.json"

window.setup = ->
	createCanvas windowWidth, windowHeight
	skala = height/100
	textFont "Courier New"
	strokeWeight 0.5
	data = data.data.split '*'
	res = {}
	for index in range 5040
		res[ALL[index]] = "ABCD" + data[index] + ALL[index]
	data = res
	clickNew()
	xdraw() ####

showHelp = (x,y) ->
	textSize 4
	texts = []
	texts.push 'Mastermind 5040'
	texts.push '  (10*9*8*7)'
	texts.push 'Find the four'
	texts.push '  letter secret!'
	texts.push ''
	texts.push 'A clue gives up'
	texts.push '  to 4 distances'
	texts.push ''
	texts.push 'Max 5 guesses'
	texts.push '  necessary'
	texts.push ''
	texts.push 'Example:'
	texts.push '  DHIJ (secret)'
	texts.push '  guess => clue'
	texts.push '  ABCD  => 3'
	texts.push '  AEFG  => ----'
	texts.push '  HABI  => 11'
	texts.push '  DHIJ  => 0000'
	for i in range texts.length
		text texts[i],x-8,y+5*i

showTable = (table,x,y) -> # table = 'ABCDEFGH'
	textSize 6
	for i in range 0,table.length,4
		t = table.substring i,i+4
		item = t
		answer = evaluate secret,t
		if answer == '0000' then showSolution = true
		if t.length==4 then item = t + ' ' + answer
		text item, x-8,y+5*(i//4)

xdraw = -> ####
	push() ####
	background "lightgray"
	translate xoff,0
	scale skala
	textAlign CENTER,CENTER
	for button in buttons
		button.draw()
	textAlign LEFT,TOP
	if buffer.length == 0 then showHelp x1,y0 else showTable buffer,x1,y0
	if showSolution then showTable solution,x1,y1
	pop() ####

setActiveButtons = () =>
	n = buffer.length
	antal = n%4
	gray = buffer.substring n-antal,n
	for i in range N
		button = buttons[i]
		button.active = button.prompt not in gray
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
	if not showSolution and buffer.length < 40 # and button.active
		buffer += button.prompt
		setActiveButtons()

clickNew = ->
	buffer = ''
	secret = _.sample ALL
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
	button = new Button ALFABET[i], x0+i%2*10, y0+i//2*10,10,10,10 #, () => clickLetter button
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
	xdraw() ####
	false

window.mouseReleased = (event) ->
	event.preventDefault()
	released = true
	false

window.keyPressed = () ->
	s = '' + key
	s = s.toUpperCase()
	if s in ALFABET and buffer.length < 40
		buffer += s
		setActiveButtons()
	if keyCode == BACKSPACE
		clickUndo()
	xdraw()
