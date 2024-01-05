# Läser in uttrycken från json-filen.
#   "1 3 2" <=> (n + 3n**2 + 2n**3)/6
# BigInt finns numera i Chrome.
# Fractions saknas dock.

range = _.range
print = console.log 

k = 1
index = 9
ns = []
for i in range 6
	for j in range 1,10
		ns.push j * 10**i
ns.push 1000000
n = ns[index]

buttons = []

class Button
	constructor : (@prompt,@x,@y,@click) ->
		@w=80
		@h=40
	draw : ->
		fill 'white'
		rect @x,@y,@w,@h
		fill 'black'
		text @prompt, @x, @y
	inside : -> @x-@w/2 < mouseX < @x+@w/2 and @y-@h/2 < mouseY < @y+@h/2


ass = (a,b) ->
	if a != b then log "assert failure: #{a} != #{b}"

data = null

window.preload = ->
	data = loadJSON "faulhaber.json"

window.setup = ->
	createCanvas 600,450
	for i in range data.a.length
		data.a[i] = data.a[i].split ' '
	ass BigInt(55),f(1,10)
	ass BigInt(5050),f(1,100)
	ass BigInt(385),f(2,10)
	ass BigInt(3025),f(3,10)
	ass BigInt(25502500),f(3,100)
	ass BigInt(10507499300049998500),f(9,100)
	textAlign CENTER,CENTER
	rectMode CENTER
	textFont 'Courier New'
	textSize 30
	buttons.push new Button "k--",40,20, -> if k > 0 then k--
	buttons.push new Button "k++",width-40,20, -> if k < data.a.length-1 then k++
	buttons.push new Button "n--",40,height-20, -> if index>0 then index--
	buttons.push new Button "n++",width-40,height-20, -> if index < ns.length-1 then index++

window.draw = ->
	background 'gray'
	textAlign CENTER,CENTER
	textSize 30
	for button in buttons
		button.draw()
	answer = f(k,ns[index]).toString()
	textAlign LEFT,BOTTOM
	for i in range 0,1+answer.length//32
		text answer.slice(32*i,32*(i+1)),12,100 + i*25

	textSize 60
	textAlign CENTER,CENTER
	text "Σ",width*0.5,height-100+30
	textSize 20
	text ns[index],width*0.50,height-130+30
	text "i",width*0.55,height-100+30
	if k>1 then text k,width*0.58,height-110+30
	text "i=1",width*0.50,height-70+30

f = (k,n) ->
	n = BigInt n
	r = data.a[k]
	value = BigInt 0
	summa = BigInt 0
	for i in range r.length
		value += BigInt(r[i]) * n ** BigInt i+1
		summa += BigInt(r[i])
	value / BigInt(summa)

window.mousePressed = ->
	for button in buttons
		if button.inside mouseX,mouseY
			button.click()
