# import _ from 'https://cdn.skypack.dev/lodash'
# import {log,range,r4r} from '../js/utils.js'
import {r4r,log,button,div,textarea} from '../js/utils.js'

a = null

click = =>
	a.hidden = false
	a.value = "1 b3"
	a.select()
	document.execCommand 'copy'
	a.hidden = true
	window.location.href = 'https://lichess.org/paste'

r4r => div {},
	a = textarea {hidden:true}
	button {onclick: click},
		'analyze'
