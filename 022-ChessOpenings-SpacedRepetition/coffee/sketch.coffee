import _ from 'https://cdn.skypack.dev/lodash'
import {ass,log,range} from '../js/utils.js'
import {Board} from '../js/board.js'
import {Button} from '../js/button.js'
import {clickString,global} from '../js/globals.js'
import {SpacedRepetition} from '../js/spaced_repetition.js'
import {Tree} from '../js/tree.js'

SIZE = global.SIZE
released = true # prevention of touch bounce
arr = null
help = 'Make the most common master move.'

window.preload = =>
	#arr = loadJSON './data/arr-2014-08.json' # SIZE = 0
	#arr = loadJSON './data/arr-2016-02.json' # SIZE = 1
	#arr = loadJSON './data/arr-2019-06.json' # SIZE = 2
	arr = loadJSON './data/arr32.json'

	for letter in "rnbqkp"
		global.pics[letter] = loadImage './images/b' + letter + '.png'
	for letter in "RNBQKP"
		global.pics[letter] = loadImage './images/w' + letter.toLowerCase() + '.png'

window.setup = =>
	createCanvas SIZE*10.5, SIZE*10
	textAlign CENTER,CENTER
	rectMode CENTER

	g = global

	g.tree = new Tree arr.arr
	g.board = new Board()
	g.chess = new Chess()
	# g.tree.test()

	g.spacedRepetition = new SpacedRepetition 'e2e4.e7e5.g1f3.b8c6.f1c4'
	sr = g.spacedRepetition

	sr.pick()

	g.chess.reset()
	moves = sr.current().q.split '.'
	for move in moves
		g.chess.move {from: move.slice(0,2), to:move.slice(2,4)}
	g.board.flipped = moves.length%2 == 1

	xdraw()

drawSpacedRepetition = =>
	g = global
	sr = g.spacedRepetition
	textAlign LEFT,CENTER
	current = sr.current()
	if current
		for move,i in g.chess.history()
			x = 450+i%2 * 35
			y = 35 + floor(i/2) * 20
			fill 'black'
			if i%2==0 then text i/2+1, x-20, y
			fill if i < sr.path.split('.').length then 'lightgray' else ['white','black'][i%2]
			text move, x,y

		if global.board.clickedSquares.length == 2 # hint
			textAlign CENTER,CENTER
			fill ['white','black'][g.chess.history().length % 2]
			text current.a.join(' • '), SIZE*4.5, SIZE*9.5

xdraw = =>
	background 'gray'
	textSize SIZE
	global.board.draw()
	for button in global.buttons
		button.draw()
	drawSpacedRepetition()
	fill "black"
	textAlign CENTER,CENTER
	text help, SIZE*4.5, SIZE*9.5

	# for sq,i in global.board.clickedSquares # debug
	# 	text sq,150+40*i,540

# window.keyPressed = =>
# 	if key == 'ArrowLeft' then clickString 'left'
# 	if key == 'ArrowRight'  then clickString 'right'
# 	if key == 'ArrowUp'  then clickString 'up'
# 	if key == 'ArrowDown' then clickString 'down'
# 	if key == ' ' then clickString 'flip'
# 	if key == 'Home' then clickString 'first'
# 	xdraw()
# 	return false

window.mousePressed = =>
	help = ''
	if not released then return
	released =false
	for button in global.buttons.concat global.board.buttons
		if button.inside mouseX,mouseY
			button.onclick()
			xdraw()
			return false
	for square in global.board.squares
		if square.inside mouseX,mouseY
			square.onclick()
			xdraw()
			return false
	false

window.mouseReleased = =>
	released = true
	false