import { button,div,r4r,signal,log,map } from "/js/utils.js"

Game = =>

	START = 12

	[a, setA] = signal START
	[hist,setHist] = signal [START]

	update = (value) =>
		setA => value
		setHist => [value].concat hist()

	undo = =>
		if hist().length <= 1 then return
		setA => hist()[1]
		setHist => hist().slice 1

	str = => hist().join " "

	div {},
		button {onClick: => update a()+2}, "add"
		button {onClick: => update a()*2}, "mul"
		button {onClick: => update a()/2}, "div"
		button {onClick: => undo()}, "undo"
		=> str()
		=> map hist(), (item) => div {}, item

r4r =>
	div {},
		Game
		Game
