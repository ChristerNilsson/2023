# import _ from 'https://cdn.skypack.dev/lodash'
import {log,range,r4r} from '../js/utils.js'
# import {spaceShip} from '../js/utils.js'

# import {Stockfish} from '../node_modules/stockfish/src/stockfish.js'

uint8 = new Uint8Array 8
uint8[0] = 0
uint8[1] = 6*16+1
uint8[2] = 7*16+3
uint8[3] = 6*16+13
uint8[4] = 1
uint8[5] = 0
uint8[6] = 0
uint8[7] = 0


# wasmSupported = typeof WebAssembly == 'object' && WebAssembly.validate(Uint8Array.of(0x0, 0x61, 0x73, 0x6d, 0x01, 0, 0, 0));
wasmSupported = typeof WebAssembly == 'object' && WebAssembly.validate(uint8);
log wasmSupported

stockfish = new Worker(wasmSupported ? 'stockfish.wasm.js' : 'stockfish.js');
 
stockfish.addEventListener('message', (e) =>
  console.log('listener',e);
);
 
stockfish.postMessage('uci');


# stockfish = Stockfish()

log 'stockfish',stockfish

# import { Chess } from '../js/chess.js'

# while !chess.isGameOver()
# 	moves = chess.moves()
# 	move = moves[Math.floor(Math.random() * moves.length)]
# 	chess.move move
# 	logg chess.ascii()
# 	# r4r =>
# 	# 	chess.ascii()

# chess = null
# buffer = ''
# app = document.getElementById "app"

# show = =>
# 	s = chess.ascii()
# 	s = s.replaceAll "\n", '<br>'
# 	s= s.replaceAll " ", '&nbsp;'
# 	app.innerHTML = s

# putPiece = (piece, color) ->
# 	if piece.length == 3
# 		chess.put { type: piece[0].toLowerCase(), color }, piece[1..2]
# 	else
# 		chess.put { type: 'p', color }, piece[0..1]

# put = (w,b) ->
# 	chess.clear()
# 	for piece in w.split ' '
# 		putPiece piece, 'w'
# 	for piece in b.split ' '
# 		putPiece piece, 'b'

# window.setup = =>
# 	chess = new Chess()
# 	put "Kc3 Rd4","Ke5"
# 	app.style.fontFamily = "monospace"
# 	show()

# window.keyPressed = (e) ->
# 	buffer += e.key
# 	if buffer.length == 4
# 		try
# 			chess.move buffer
# 			show()
# 			logg buffer, 'ok'
# 		catch
# 			logg buffer,'invalid'
# 		buffer = ''
