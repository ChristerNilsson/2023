import _ from 'https://cdn.skypack.dev/lodash'
import {ass} from '../js/utils.js'

SIZE = 50

numbers = [5,6,9,11,15,20]
target = 318
stack = [] # index till NumberButtons

operators = "+-*/"
numberButtons = []
operatorButtons = []
undoButton = null
buttons = []
history = [] # texter och stack
# ["5 6 9 11 15 20",'']

start = new Date()

getTop2 = () =>
	n = stack.length
	a = stack[n-1]
	b = stack[n-2]
	a = buttons[a].text
	b = buttons[b].text
	if a < b then [b,a] else [a,b]

setActive = =>
	if stack.length >= 2
		operatorButtons[0].active = true
		operatorButtons[1].active = true
		operatorButtons[2].active = true
		[a,b] = getTop2()
		operatorButtons[3].active = a%%b==0
	else
		for button in operatorButtons
			button.active = false
	undoButton.active = history.length > 0

class Button
	constructor : (@index,@text,@x,@y,@active) ->
	draw : =>
		n = stack.length
		if @text == 0 then return
		push()
		fill 'white'
		if @ in numberButtons
			if @index in stack then fill 'yellow' 
			if @index in stack.slice n-2,n then fill 'green' 
		circle @x,@y,SIZE
		fill if @active then 'black' else 'lightgray'
		textSize [40,30,30,25,20,15,12,10,8,6,5,4,3,2][str(@text).length]
		text @text,@x,@y+3
		pop()
	inside : (mx,my) =>
		dx = mx-@x
		dy = my-@y
		dx*dx + dy*dy < SIZE/2 * SIZE/2

class UndoButton extends Button
	click : =>
		if history.length == 1 then return
		history.pop()
		[texter,stack] = _.last history
		stack = stack.slice()
		for text,i in texter
			numberButtons[i].text = text
		setActive()

class NumberButton extends Button
	click : =>
		stack.push @index
		setActive()

class OperatorButton extends Button
	click : =>
		n = stack.length
		if n >= 2
			[a,b] = getTop2()
			c = 0
			if @text == '+' then c =a+b
			if @text == '-' then c =a-b
			if @text == '*' then c =a*b
			if @text == '/' and a%%b==0 then c =a//b
			if c > 0
				numberButtons[stack[n-1]].text = c
				numberButtons[stack[n-2]].text = 0
				texter = _.map numberButtons, (b) => b.text
				history.push [texter.slice(),stack.slice()]
				x = stack.pop()
				y = stack.pop()
				stack.push x
				setActive()

window.setup = =>
	createCanvas 800,300
	noLoop()
	textAlign CENTER,CENTER
	textSize 30

	for number,i in numbers
		x = 100+10 + i%3 * (SIZE+10)
		y = 100 + i//3 * (SIZE+10)
		numberButtons.push new NumberButton i,number,x,y,true

	y = 225
	for operator,i in operators
		x = 50 + i%4 * (SIZE+10)
		operatorButtons.push new OperatorButton i,operator,x,y,false

	x = 95 + 4 * SIZE
	undoButton = new UndoButton 0,'undo',x,y,false

	buttons = [numberButtons..., operatorButtons..., undoButton]

	textf = _.map numberButtons, (b) => b.text
	textf = textf.slice()
	stackf = stack.slice()
	history = [[textf,stackf]]

	asserts()

window.mousePressed = =>
	for button in buttons
		if button.inside mouseX,mouseY
			button.click()
			draw()

window.draw = =>
	background 'gray'
	for button in buttons
		button.draw()
	push()
	textSize 50
	text target,175,45
	pop()
	drawHistory()
	drawStack()

drawStack = () =>
	push()
	textSize 30
	for item,i in stack
		text numberButtons[item].text, 650, 40 + i*40
	pop()

drawHistory = =>
	push()
	textSize 30
	for item,i in history
		[textf,stackf] = item
		text textf.join(' ') + ' | ' + stackf.join(' '), 450, 40 + i*40
		#text "#{c} = #{a} #{op} #{b}", 450, 40 + i*40
	pop()
	# if history.length == 0 then return
	# if _.last(history)[0] == target
	# 	push()
	# 	textSize 30
	# 	text "Well done!", 450, 40 + history.length*40
	# 	textSize 20
	# 	text "#{(new Date() - start)} ms", 450, 80 + history.length*40
	# 	pop()

### TESTING ###

finger = (commands) =>
	for number,i in numbers
		numberButtons[i].text = number
	stack = []
	for command in commands
		if command=='0' then numberButtons[0].click()
		if command=='1' then numberButtons[1].click()
		if command=='2' then numberButtons[2].click()
		if command=='3' then numberButtons[3].click()
		if command=='4' then numberButtons[4].click()
		if command=='5' then numberButtons[5].click()
		if command=='+' then operatorButtons[0].click()
		if command=='-' then operatorButtons[1].click()
		if command=='*' then operatorButtons[2].click()
		if command=='/' then operatorButtons[3].click()
		if command=='Z' then undoButton.click()
	textf = _.map numberButtons, (button) => button.text
	textf = textf.join ' '
	stackf = _.map stack, (index) => numberButtons[index].text
	stackf = stackf.join ' '
	[textf,stackf]

asserts = =>
	return
	ass ['5 6 9 11 15 20',''], finger ''
	ass ['5 6 9 11 15 20','5'], finger '0'
	ass ['5 6 9 11 15 20','5 6'], finger '01'
	ass ['5 6 9 11 15 20','5 6 9'], finger '012'
	ass ['5 0 15 11 15 20','5 15'], finger '012+'
	ass ['5 6 9 11 15 20','5 6 9'], finger '012+Z'
	ass ['0 0 20 11 15 20','20'], finger '012++'
	ass ['5 0 15 11 15 20','5 15'], finger '012++Z'
