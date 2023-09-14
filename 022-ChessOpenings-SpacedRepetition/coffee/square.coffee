import {global} from '../js/globals.js'
import {param} from '../js/utils.js'

SIZE = global.SIZE
pics = global.pics
width = global.width

export class Square
	constructor: (@i,@onclick) ->
		param.Integer @i
		@x = @i%8
		@y = 7 - @i//8
		@w = SIZE
		@h = SIZE
		@col = 'white'

	draw : (piece,flipped,selected) =>
		param.Test piece==null or piece.type in 'rnbqkp' and piece.color in 'bw'
		param.Boolean flipped
		if (@x+@y) % 2 == 1 then fill 'gray' else fill 'lightgray'
		if selected then fill 'green'
		[x,y] = if flipped then [7-@x,7-@y] else [@x,@y]
		noStroke()
		rect SIZE*(x+1),SIZE*(y+1),SIZE,SIZE
		if not piece then return 
		key = piece.type.toLowerCase()
		if piece.color == 'w' then key = key.toUpperCase()
		image pics[key],SIZE*(x+0.5),SIZE*(y+0.5),SIZE,SIZE

	inside : (mx,my) =>
		param.Number mx
		param.Number my
		x = (@x+1)*SIZE
		y = (@y+1)*SIZE
		res = x-@w/2 < mx < x+@w/2 and y-@h/2 < my < y+@h/2
		param.Boolean res
