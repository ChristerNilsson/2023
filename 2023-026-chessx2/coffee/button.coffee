import {global} from '../js/globals.js'
import {param,range} from '../js/utils.js'

export class Button
	constructor: (@x,@y,@text,@onclick) ->
		@w = 3 * global.size()
		@h = 4 * global.size()
		@bg = 'lightgray'
		@fg = 'black'
		@align = CENTER

	draw : =>
		noStroke()
		if @align==LEFT then x=@x-0.45*@w else x=@x
		push()
		textSize 2*global.size() # 0.4
		textAlign @align
		noStroke()
		text @text, x,@y+0.05*global.size()
		pop()

	inside : (x,y) => @x-@w/2 < x < @x+@w/2 and @y-@h/2 < y < @y+@h/2

export class ClockButton extends Button
	constructor: (x,y,@nr,onclick) ->
		super x,y,'',onclick
		@W = 2.7
		@H = 2.7 # Hela höjden
		@resize()

	draw : =>
		noStroke()
		push()
		textSize 2*global.size()
		textAlign @align
		noStroke()
		@drawClock 0
		@drawClock 1
		pop()

	drawClock : (player) =>
		p = global.chess.history().length %% 2
		if global.clocks[player] < 60 then fill "red"
		noStroke()
		textSize global.size()
		t = global.clocks[player]
		if not global.paused and p!=player
			t -= 1/240
		global.clocks[player] = t
		if t < 60
			res = t.toFixed 1
		else
			t = round t
			sekunder = t %% 60
			t = t // 60
			if sekunder < 10 then sekunder = "0" + sekunder
			minuter = t
			if minuter < 10 then minuter = "0" + minuter
			res = minuter + ":" + sekunder

		@bg = ['black','white'][player]
		@bg = 'gray' if p == player or global.paused

		push()
		x = if @nr == 0 then global.mx()/2 else width-global.mx()/2
		y = global.size() * [8,10][player]
		translate x, y
		if @nr==1 then scale -1,-1
		fill @bg
		rect 0, 0, @W*global.size(), @H/3*global.size()
		if global.clocks[player] < 60 then fill "red"
		else fill ['white','black'][player]

		faktor = if global.windows then 0.1 else 0.0
		text res, 0, faktor * global.size()
		pop()

		push()
		y = global.size() * 9
		translate x,y
		if @nr==1 then scale -1,-1
		fill 'white'
		noStroke()
		textSize global.size()*0.5
		text global.material, 0,0
		pop()

	resize : =>
		@w = @W * global.size()
		@h = @H * global.size()


