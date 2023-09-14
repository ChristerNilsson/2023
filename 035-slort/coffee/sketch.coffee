ALFABET = "SLORT"
range = _.range
ass = (a,b) => if a!=b then console.log 'Assert failed',a,'!=',b

op = (s, selection)  =>
	a = _.filter s , (x) -> x in selection
	b = _.filter s , (x) -> x not in selection
	a.concat(b).join ""

evaluate = (a,cmd) =>
	res = a
	if cmd=='S' then res=a[1]+a[0]+a[3]+a[2]+a[5]+a[4]
	if cmd=='L' then res=op a,'123'
	if cmd=='O' then res=op a,'135'
	if cmd=='R' then res=a[1]+a[2]+a[3]+a[4]+a[5]+a[0]
	if cmd=='T' then res=a[5]+a[4]+a[3]+a[2]+a[1]+a[0]
	res

start = 0
state = 0 # 0=Help 1=Normal 2=Solution
skala = 1
xoff = 0
data = null
solution = []
buffer = '' # SLORTSLORT
levels = []
level = 1
increment = -1

window.preload = -> data = loadJSON "./data.json"

window.setup = ->
	createCanvas windowWidth, windowHeight
	keys = _.keys data
	levels = _.groupBy keys,(key) -> data[key].length
	console.log levels
	skala = height/100
	textFont "Courier New"
	strokeWeight 0.5

showHelp = (x,y) ->
	textSize 4
	texts = []
	texts.push 'SLORT'
	texts.push ''
	texts.push 'Find the steps!'
	texts.push ''
	texts.push 'Target: 123456'
	texts.push ''
	texts.push 'Max 7 steps'
	texts.push '  necessary'
	texts.push ''
	texts.push 'Example:'
	texts.push '    123654'
	texts.push '  R 236541'
	texts.push '  O 351264'
	texts.push '  S 532146'
	texts.push '  T 641235'
	texts.push '  R 412356'
	texts.push '  L 123456 ok'

	for i in range texts.length
		text texts[i],x-8,y+5*i

showTable = (table,x,y,showStart) -> # table = 'SLORT'
	textSize 6
	current = start
	if showStart then text '  ' + start + ' ' + level, 24, y
	for i in range table.length
		cmd = table[i]
		current = evaluate current,cmd
		if current == '123456' and buffer == table
			text cmd + ' ' + current + ' ok', 24,y+5*(i+1)
			increment = 1
			buttons[5].active = true
			buttons[6].active = false
			buttons[7].active = true
		text cmd + ' ' + current, 24,y+5*(i+1)

window.draw = ->
	background "lightgray"
	translate xoff,0
	scale skala
	textAlign CENTER,CENTER
	for button in buttons
		button.draw()
	textAlign LEFT,TOP
	if state==0 then showHelp x1,y0
	if state in [1,2] then showTable buffer,x1,y0,true
	if state in [2] then showTable solution,x1,y1,false

setActiveButtons = () =>

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

click = (ltr) -> 
	if buffer.length < 10
		buffer += ltr
		buttons[6].active = true

clickSwap = -> click 'S'
clickLow = -> click 'L'
clickOdd = -> click 'O'
clickRotate = -> click 'R'
clickTurn = -> click 'T'

clickNew = ->
	state = 1
	buffer = ''
	level += increment
	if level < 1 then level = 1
	if level > 7 then level = 7
	increment = -1
	start = _.sample levels[level]
	solution = data[start]
	for i in range 8
		buttons[i].active = true
	buttons[6].active=false

clickUndo = ->
	if buffer.length == 0 then return
	buffer = buffer.substring 0,buffer.length - 1
	buttons[6].active = buffer.length > 0

clickSolve = -> state = 2

buttons = []
x0 = 1 # %
x1 = 30
y0 = 0
y1 = 55

for i in range 8
	prompts = 'Swap Low Odd Rotate Turn new undo solve'.split ' '
	clicks = [clickSwap,clickLow,clickOdd,clickRotate,clickTurn,clickNew,clickUndo,clickSolve]
	button = new Button prompts[i], x0, y0+i*10,20,10,6, clicks[i]
	button.ts = 5
	if i>=5 then button.y+= 5
	button.active = i == 5
	buttons.push button

released = true

window.mousePressed = (event) ->
	event.preventDefault()
	if not released then return
	released = false
	for button in buttons
		if button.inside mouseX/skala,mouseY/skala then button.click()
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
