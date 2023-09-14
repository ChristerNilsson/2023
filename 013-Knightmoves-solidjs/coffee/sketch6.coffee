import {r4r, signal, div, button} from '../js/utils.js'

[count,setCount] = signal 0

r4r => div {},
	"Count: ",count
	button {onClick: => setCount 0}, 'Reset'
	button {onClick: => setCount count() + 1}, '+'
	button {onClick: => setCount count() - 1}, '-'
