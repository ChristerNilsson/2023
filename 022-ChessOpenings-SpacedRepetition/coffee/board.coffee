import _ from 'https://cdn.skypack.dev/lodash'
import {ass,lerp,param,range,hexToBase64} from '../js/utils.js'
import {Square} from '../js/square.js'
import {Button} from '../js/button.js'
import {coords,clickString,global,toObjectNotation,toUCI} from '../js/globals.js'
import {dumpState} from '../js/globals.js'

SIZE = global.SIZE

getNextQuestion = =>
	g = global
	sr = g.spacedRepetition
	if sr.boxes[0].length == 0
		for i in range 5
			if sr.qindex < sr.questions.length-1
				qi = sr.questions[sr.qindex]
				sr.add {p:g.tree.arr[qi][3], q:g.tree.getPath(qi), a: g.tree.getAnswers(qi,sr.stopp)}
				sr.qindex++
	sr.pick()
	g.chess.reset()
	moves = sr.current().q.split '.'
	for move in moves
		g.chess.move {from: move.slice(0,2), to:move.slice(2,4)}
	g.board.flipped = moves.length%2 == 1

export class Board
	constructor: ->
		@squares = []
		@clickedSquares = []
		@pieces = ""
		@flipped = false
		for i in range 64
			do (i) => @squares.push new Square i, => @click i

		@buttons = []
		#@buttons.push new Button x0*SIZE, 9.5*SIZE, 'correct', => clickString 'correct'

	click : (i) =>
		g = global
		sr = g.spacedRepetition
		if @flipped then i = 63-i
		col = i %% 8
		row = 7-i // 8
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
				if uci in sr.answers
					sr.correct()
					getNextQuestion()
					@clickedSquares = []
		else if csl == 2
			@clickedSquares.push i
		else if csl == 3
			@clickedSquares.push i
			uci = toUCI @clickedSquares.slice 2,4
			if uci in sr.answers
				sr.wrong()
				getNextQuestion()
				@clickedSquares = []
			else
				@clickedSquares = @clickedSquares.slice 0,2

	draw : =>

		for button in @buttons
			button.draw()

		fill 'white'
		textSize SIZE*0.3

		for i in range 8
			for j in range 8
				piece = global.chess.board()[7-i][j]
				sq = @squares[i*8+j]
				if @clickedSquares.length in [0,2]
					sq.draw piece, @flipped, false
				if @clickedSquares.length in [1]
					sq.draw piece, @flipped, i*8+j==@clickedSquares[0]
				else if @clickedSquares.length in [3,4]
					sq.draw piece, @flipped, i*8+j==@clickedSquares[2]

		stroke 'black'
		noFill()
		rect SIZE*4.5,SIZE*4.5,SIZE*8,SIZE*8

		@littera()

	littera : =>
		noStroke()
		fill 'black'
		textSize SIZE*0.3
		letters = if @flipped then "hgfedcba" else "abcdefgh"
		digits = if @flipped then  "12345678" else "87654321"

		for i in range 8
			text letters[i],SIZE*(i+1),SIZE*8.8
			text digits[i],SIZE*0.15,SIZE*(i+1)

	flip : => @flipped = not @flipped
