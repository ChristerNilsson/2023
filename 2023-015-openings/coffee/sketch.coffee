# import _ from 'https://cdn.skypack.dev/lodash'
# import {log,range,r4r} from '../js/utils.js'
import {spaceShip} from '../js/utils.js'

logg = console.log

tree = null
curr = null
buttons = []

class Button
	constructor : (@x,@y,@width,@h,@title,@w,@r,@b) ->
		@all = @w + @r + @b
		#@w=Math.round 100*@w/@all
		#@r=Math.round 100*@r/@all
		#@b=Math.round 100*@b/@all

		@bw = @b - @w
	draw: =>
		fill 'white'
		rect @x,@y,@width,@h
		fill 'black'
		text @title + ' ' + @all + ' ' + @w + ' ' + @r + ' ' + @b, @x+10, @y+15
	click: =>
		logg 'click',@title,curr
		curr = curr[@title]
		makeButtons()

window.preload = => tree = loadJSON 'tree.json'

window.setup = =>
	logg tree
	curr = tree
	createCanvas 400,600
	makeButtons()

makeButtons = =>
	buttons = []
	for key in _.keys curr
		if key != 'wrb'
			x = 10
			y = 10+25*buttons.length
			[w,r,b] = curr[key].wrb
			logg w,r,b
			buttons.push new Button x,y,100,20,key,w,r,b
		logg key

	buttons.sort (a,b) => spaceShip b.all,a.all

	for b in buttons
		logg b.title,b.all

window.draw = =>
	background 'gray'
	# buttons = buttons.sort (a,b) => spaceShip a.title,b.title
	for b,i in buttons
		b.y = 10+25*i
		b.draw()

window.mousePressed = =>
	btn = null
	for b in buttons
		if mouseX > b.x and mouseX < b.x+b.w and mouseY > b.y and mouseY < b.y+b.h
			btn = b
	if btn then btn.click()
