import {global} from '../js/globals.js'
import {param,range} from '../js/utils.js'

export class Button
	constructor: (@x,@y,@text,@onclick) ->
		param.Compact "NNSF",arguments
		@w = 1.7 * global.SIZE
		@h = 0.7 * global.SIZE
		@bg = 'lightgray'
		@fg = 'black'
		@align = CENTER

	draw : =>
		noStroke()
		fill @bg
		rect @x,@y,@w,@h*0.65

		if @align==LEFT then x=@x-0.45*@w else x=@x
		fill @fg
		push()
		textSize 0.4*global.SIZE
		textAlign @align
		noStroke()
		text @text, x,@y+0.05*global.SIZE
		pop()

	inside : (x,y) =>
		param.Number x
		param.Number y
		param.Boolean @x-@w/2 < x < @x+@w/2 and @y-@h/2 < y < @y+@h/2
