import {button,div,log,r4r} from '../js/utils.js'

tree = null
stack = null # innehåller texter
nodes = null # innehåller objekt

filename = 'white_15_5_12.json'
board = null 

window.preload = =>
	tree = loadJSON '../data/' + filename

window.setup = =>
	stack = [] # innehåller texter
	nodes = [tree]
	board = Chessboard 'myBoard', {
		moveSpeed: 100,
		position: 'start'
	}
	render()

click = (key) =>
	if key == 'back'
		if stack.length > 0
			stack.pop()
			nodes.pop()
			board.start()
			for key in stack
				board.move key[0..1] + '-' + key[2..3]
	else if key == 'clear'
		stack = []
		nodes = [tree]
		board.start()
	else
		stack.push key
		nodes.push _.last(nodes)[key]
		# for key in stack
		board.move key[0..1] + '-' + key[2..3]

	render()

render = =>
	document.getElementById("app").innerHTML = ""
	node = _.last nodes
	keys = _.keys node
	keys.sort()
	r4r =>
		div {},
			for item in keys
				do (item) =>
					div {}, button {style:"width:50px", onclick:() => click item}, item
			div {}, filename
			div {}, stack.join(' • ')
			div {}, button {style:"width:50px", onclick:() => click 'clear'}, 'clear'
			div {}, button {style:"width:50px", onclick:() => click 'back'}, 'back'
