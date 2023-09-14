import {ass,log,range,split,param,hexToBase64,spaceShip} from '../js/utils.js'
import {Button} from '../js/button.js'
import _ from 'https://cdn.skypack.dev/lodash'

export global = {

	dialogues: [], # dialogstack till menyhanteringen
	board0 : null,
	board1 : null,
	chess : null, # hanterar dragen samt deras legalitet

	minutes : 15,
	increment : 10, # seconds
	clocks: [15*60+10,15*60+10], # white and black in seconds. float.

	paused : true,
	version:'ver: B',
	pics : {}, # 12 pjäser
	buttons : [],

	size:null, # en rutas storlek
	setSize:null, 
	mx:null, # x-marginal
	setMx:null,
	my:null, # y-marginal
	setMy:null,

}

export coords = (uci) =>
	param.String uci
	c0 = "abcdefgh".indexOf uci[0]
	r0 = "12345678".indexOf uci[1]
	c1 = "abcdefgh".indexOf uci[2]
	r1 = "12345678".indexOf uci[3]
	param.Array [c0+8*r0, c1+8*r1]
ass [8,24], coords "a2a4"

export toUCI = ([from,to]) =>
	param.Integer from
	param.Integer to
	c0 = "abcdefgh"[from%8]
	r0 = "12345678"[from//8]
	c1 = "abcdefgh"[to%8]
	r1 = "12345678"[to//8]
	param.String c0+r0+c1+r1
ass "e2e4", toUCI [12,28]

export toObjectNotation = ([from,to]) =>
	param.Integer from
	param.Integer to
	uci = toUCI [from,to]
	from = uci.slice 0,2
	to = uci.slice 2,4
	param.Object {from, to}
ass {from:'e2', to:'e4'}, toObjectNotation [12,28]

export empty = (n) =>
	param.Integer n
	param.String (1+n//8).toString()

export dumpState = =>
	console.log 'STATE ########'
	# console.log '  stack',global.stack
	console.log '  currNode',global.currNode
	console.log '  history',global.chess.history()

link = => 'https://lichess.org/analysis/' + global.chess.fen()
