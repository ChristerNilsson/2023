labels = 'S V C MP SD L KD M Man Kvinna'.split ' '
buttons = []

timings = {}
active = ''

range = _.range
released = true

window.setup = ->
	createCanvas windowWidth, windowHeight
	for label in labels
		buttons.push new Button label

window.draw = ->
	background 'white'
	if active != '' then timings[active] += 1/frameRate()

	for button in buttons
		textAlign CENTER,CENTER
		button.draw()
		fill 'black'
		textAlign RIGHT
		push()
		textSize 20
		text timings[button.prompt].toFixed(1),200,12.5+button.y
		pop()

class Button
	constructor : (@prompt) ->
		@x = 10
		@y = 25 + 25 * buttons.length
		@w = 100
		@h = 20
		timings[@prompt] = 0
	draw : ->
		fill if @prompt==active then 'black' else 'gray'
		rect @x,@y,@w,@h
		fill 'yellow'
		text @prompt,@x+@w/2, @y+@h*0.5+0.5
	inside : (mx,my) -> @x <= mx <= @x+@w and @y <= my <= @y+@h
	click : -> active = if active == @prompt then '' else @prompt

window.mousePressed = (event) ->
	event.preventDefault()
	if not released then return
	released = false
	for button in buttons
		if button.inside mouseX,mouseY then button.click()
	false

window.mouseReleased = (event) ->
	event.preventDefault()
	released = true
	false
