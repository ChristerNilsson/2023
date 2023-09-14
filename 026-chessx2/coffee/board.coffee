import _ from 'https://cdn.skypack.dev/lodash'
import {ass,lerp,param,range,hexToBase64,enterFullscreen} from '../js/utils.js'
import {Square} from '../js/square.js'
import {Button,ClockButton} from '../js/button.js'
import {coords,global,toObjectNotation,toUCI} from '../js/globals.js'
import {dumpState} from '../js/globals.js'

export class Board
	constructor: (@nr) ->
		@squares = []
		@clickedSquares = []
		@pieces = ""
		for i in range 64
			do (i) => @squares.push new Square @nr, i, => @click i

		@buttons = []

		x0 = round global.mx()/2
		x1 = width- x0
		y0 = round 0.20*height
		y1 = round 0.50*height
		y2 = round 0.80*height

		@buttons.push new ClockButton x0,y1,@nr,=> global.paused = not global.paused
		@buttons.push new ClockButton x1,y1,@nr,=> global.paused = not global.paused

	calcMaterial : () ->
		res = 0
		hash = {'.':0,'k':0,'r':-5,'q':-9,'b':-3,'n':-3,'p':-1,'K':0,'R':5,'Q':9,'B':3,'N':3,'P':1, '1':0,'2':0,'3':0,'4':0,'5':0,'6':0,'7':0,'8':0,'9':0,'/':0}		
		pieces = global.chess.fen().split(' ')[0]
		console.log pieces
		res += hash[piece] for piece in pieces
		console.log res
		return res

	click : (i) =>
		g = global
		if g.paused then return
		if @nr == g.chess.history().length %% 2 then return
		col = i %% 8
		row = 7 - i // 8
		sq = g.chess.board()[row][col]
		color = "wb"[g.chess.history().length %% 2] # förväntad färg på pjäsen
		csl = @clickedSquares.length
		if csl == 0
			if sq != null and sq.color == color then @clickedSquares.push i
		else if csl == 1
			if i == @clickedSquares[0] # ångra om samma ruta
				@clickedSquares = []
			else # kontrollera draget
				@clickedSquares.push i
				uci = toUCI @clickedSquares

				# är detta ett korrekt drag? I så fall, utför det
				if g.chess.move {from:uci.slice(0,2), to:uci.slice(2,4), promotion:'q'}
					@clickedSquares = []
					console.log g.chess
					global.audio.play()
					g.paused = false
					if g.chess.game_over() then g.paused = true
					g.clocks[g.chess.history().length %% 2] += g.increment
					global.material = @calcMaterial()
				else
					@clickedSquares.pop()

	draw : =>
		for button in @buttons
			button.draw()

		fill 'white'
		textSize global.size() * 0.3

		push()
		if @nr==0 then translate global.mx(), global.my()
		else translate global.mx(), global.my() + 9 * global.size()

		for i in range 8
			for j in range 8
				piece = global.chess.board()[7-i][j]
				sq = @squares[i*8+j]
				if @clickedSquares.length in [0,2]
					sq.draw piece, false
				if @clickedSquares.length in [1]
					sq.draw piece, i*8+j==@clickedSquares[0]
				else if @clickedSquares.length in [3,4]
					sq.draw piece, i*8+j==@clickedSquares[2]

		stroke 'black'
		if global.paused or @nr == global.chess.history().length%2 then fill 128,128,128,64 else noFill()
		SIZE = global.size()
		rect SIZE*4,SIZE*4,SIZE*8,SIZE*8
		pop()
		if global.clocks[0] <= 0 or global.clocks[1] <= 0 then global.paused = true

	littera : =>
		SIZE = global.size()
		noStroke()
		fill 'black'
		textSize SIZE*0.3
		letters = if false then "hgfedcba" else "abcdefgh"
		digits  = if false then "12345678" else "87654321"

		for i in range 8
			text letters[i],SIZE*(i+1),SIZE*8.8
			text digits[i],SIZE*0.15,SIZE*(i+1)

	resize: =>
		for button in @buttons
			button.resize()
