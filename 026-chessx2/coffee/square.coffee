import {global} from '../js/globals.js'
import {param} from '../js/utils.js'

pics = global.pics
width = global.width

export class Square
	constructor: (@nr,@i,@onclick) ->
		@ix = @i %% 8
		@iy = 7 - @i//8

		@w = global.size()
		@h = global.size()
		@col = 'white'

	draw : (piece,selected) =>
		if (@ix+@iy) % 2 == 1 then fill 'gray' else fill 'lightgray'
		if selected then fill 'green'
		[x,y] = [@ix+0.5, @iy+0.5]
		noStroke()
		rect global.size()*x, global.size()*y,global.size(),global.size()
		if not piece then return
		key = piece.type.toLowerCase()
		if piece.color == 'w' then key = key.toUpperCase()

		if @nr==0
			push()
			translate global.size()*x, global.size()*y
			scale -1,-1
			image pics[key], 0,0, global.size(),global.size()
			pop()
		else
			image pics[key], global.size()*x, global.size()*y,global.size(),global.size()

	inside : (mx,my) =>
		@x = global.mx() + global.size() * @ix
		@y = global.my() + global.size() * @iy + @nr * global.size() * 9
		@w = global.size()
		@h = global.size()
		res =   @x-@w/2 < mx-global.size()/2 < @x+@w/2
		res and @y-@h/2 < my-global.size()/2 < @y+@h/2
