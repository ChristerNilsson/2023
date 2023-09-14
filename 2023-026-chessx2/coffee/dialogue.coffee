import {global} from '../js/globals.js'
import {menu0} from '../js/menus.js'
import _ from 'https://cdn.skypack.dev/lodash'

global.dialogues = []

calcr1r2 = (n,w,h) ->
	s = Math.min w,h
	r2 = s/7
	r1 = s/3
	if n > 6 then r2 *= 7/n
	[Math.round(r1),Math.round(r2)]
# assert [200,86], calcr1r2 4,600,800
# assert [200,75], calcr1r2 8,600,800

export class Dialogue

	constructor : (@x = width/2, @y = height/2) ->
		@col = '#ff06'
		@buttons = []
		global.dialogues.push @

	add : (prompt,event) -> @buttons.push new Button @,prompt,event

	clock : (title= ' ', @backPop=false, turn=0) ->
		n = @buttons.length
		[r1,r2] = calcr1r2 n,width,height
		for button,i in @buttons
			v = i*360/n + turn - 90
			button.x = r1*cos v
			button.y = r1*sin v
			button.r = r2
		button = new Button @, title, -> 
			if @dlg.backPop then global.dialogues.pop() else global.dialogues.clear()
		button.x = 0
		button.y = 0
		button.r = r2
		@buttons.push button
		chars = _.max (button.title.length for button in @buttons)
		@textSize = if chars == 1 then 0.75*r2 else 2.5*r2/chars

	update : (delta) -> # -1 eller +1
		if 0 <= @pageStart + delta * @pageSize < @lst.length
			@pageStart += delta * @pageSize
			for i in range @pageSize
				if @pageStart + i < @lst.length
					@buttons[i].arr = @lst[@pageStart + i] 
				else
					@buttons[i].arr = []

	show : ->
		push()
		translate @x,@y
		textSize @textSize
		for button in @buttons
			button.show @
		pop()

	execute : (mx,my) ->
		for button in @buttons
			if button.inside mx,my,@
				button.execute()
				return true
		false 

class Button 
	constructor : (@dlg, @title, @event = -> print @txt) -> @active = true 
	info : (@title,@event) -> @active = true
	show : ->
		if @active then fill @dlg.col else fill "#fff8"
		stroke 0
		ellipse @x,@y,2*@r,2*@r
		push()
		if @active then fill 0 else fill "#888"
		noStroke()
		textAlign CENTER,CENTER
		textSize @dlg.textSize
		arr = @title.split ' '
		if arr.length == 1 
			text arr[0], @x,@y
		else 
			text arr[0], @x,@y-0.3*@r
			text arr[1], @x,@y+0.3*@r
		pop()

	inside : (mx,my) ->  @r > dist mx, my, @dlg.x + @x, @dlg.y + @y 
	execute : -> 
		if @active then @event()

export class MenuButton
	constructor : (@x,@y,@onclick) ->
		@d = (height+width)/200
		@w = 4*@d
		@h = 4*@d
	draw : ->
		noStroke()
		fill "black"
		rect @x,@y-1.5*@d, @w, @d*0.8
		rect @x,@y+0*@d,   @w, @d*0.8
		rect @x,@y+1.5*@d, @w, @d*0.8
	inside : (mx,my) -> @x-@w/2 < mx < @x+@w/2 and @y-@h/2 < my < @y+@h/2
