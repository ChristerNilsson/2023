import {global} from '../js/globals.js'
import {Dialogue} from '../js/dialogue.js'
import {enterFullscreen} from '../js/utils.js'
import {Button} from '../js/button.js'

analyze = (url) =>

	# [Event "Exempelturnering"]
	# [Site "Lichess"]
	# [Date "2023.05.27"]
	# [Round "1"]
	# [White "Spelare1"]
	# [Black "Spelare2"]
	# [Result "1-0"]

	date = new Date().toISOString().slice(0,10).replace(/-/g,'.')
	console.log date
	pgnString = '[Date "'+ date + '"]\n' + global.chess.pgn()
	encodedPGN = encodeURIComponent pgnString

	fetch 'https://lichess.org/api/import', {method: 'POST',headers: {'Content-Type': 'application/x-www-form-urlencoded'},body: "pgn=" + encodedPGN}
		.then (response) ->
			console.log "Statuskod: #{response.status}"
			response.json()
		.then (data) ->
			console.log data
			window.open data.url, "_blank"
		.catch (error) ->
			console.error error

newGame = =>
	global.chess.reset()
	seconds = global.minutes*60 + global.increment
	global.clocks = [seconds,seconds]
	global.board0.clickedSquares = []
	global.board1.clickedSquares = []
	global.material = 0

setMinutes= (minutes) ->
	global.minutes = minutes
	seconds = minutes*60 + global.increment
	global.clocks = [seconds,seconds]
	global.dialogues.pop()

setIncrement = (increment) ->
	global.increment = increment
	seconds = global.minutes*60 + global.increment
	global.clocks = [seconds,seconds]
	global.dialogues.pop()

export menu0 = -> # Main Menu
	global.dialogue = new Dialogue()
	global.dialogue.add 'Full Screen', ->
		enterFullscreen()
		global.dialogues.clear()
	global.dialogue.add 'Analyze', ->
		analyze "https://lichess.org/paste"
		global.dialogues.clear()
	global.dialogue.add 'New Game', ->
		newGame()
		seconds = global.minutes*60 + global.increment
		global.clocks = [seconds, seconds]
		console.log 'newGame',global.minutes,global.increment
		global.dialogues.clear()
	global.dialogue.add 'Undo', ->
		global.chess.undo()
		global.dialogues.clear()
	global.dialogue.add 'Clock', -> menu1()
	global.dialogue.add 'Help', ->
		window.open "https://github.com/ChristerNilsson/2023-026-chessx2#chess-2x", "_blank"
		global.dialogues.clear()

	global.dialogue.clock ' ',true
	global.dialogue.textSize *= 1.5

export menu1 = -> # Minutes
	global.dialogue = new Dialogue()
	for n in [1,2,3,5,10,15,20,30,45,60,90]
		do (n) -> global.dialogue.add n.toString(), ->
			setMinutes n
			menu2()
	global.dialogue.clock 'Min'
	global.dialogue.textSize *= 0.5

export menu2 = -> # Seconds
	global.dialogue = new Dialogue()
	for n in [0,1,2,3,5,10,15,20,30,40,50]
		do (n) -> global.dialogue.add n.toString(), ->
			setIncrement n
			global.dialogues.pop()
	global.dialogue.clock 'Sec'
	global.dialogue.textSize *= 0.5
