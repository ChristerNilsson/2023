import _ from 'https://cdn.skypack.dev/lodash'
import { createSignal, createEffect, createMemo } from "https://cdn.skypack.dev/solid-js@1.2.6"
import { createStore }  from "https://cdn.skypack.dev/solid-js@1.2.6/store"
import h from "https://cdn.skypack.dev/solid-js@1.2.6/h"
import { render } from "https://cdn.skypack.dev/solid-js@1.2.6/web"

export signal = createSignal
export effect = createEffect
export memo = createMemo

export param = {}
param.String = (v) => if not _.isString v then console.log (new Error v + " is not a String").stack else v
param.Number = (v) => if not _.isNumber v then console.log (new Error v + " is not a Number").stack else v
param.Integer = (v) => if not _.isInteger v then console.log (new Error v + " is not an Integer").stack else v
param.Boolean = (v) => if not _.isBoolean v then console.log (new Error v + " is not a Boolean").stack else v
param.Object = (v) => if not _.isObject v then console.log (new Error v + " is not an Object").stack else v
param.Array = (v) => if not _.isArray v then console.log (new Error v + " is not an Array").stack else v
param.Function = (v) => if not _.isFunction v then console.log (new Error v + " is not a Function").stack else v
param.Test = (test,msg='') => if not test then console.log (new Error "param.Test failed:" + msg).stack
param.Compact = (types,args) =>
	for i in [0..args.length-1]
		if types[i] == 'S' then param.String args[i]
		if types[i] == 'N' then param.Number args[i]
		if types[i] == 'I' then param.Integer args[i]
		if types[i] == 'B' then param.Boolean args[i]
		if types[i] == 'O' then param.Object args[i]
		if types[i] == 'A' then param.Array args[i]
		if types[i] == 'F' then param.Function args[i]

export N = 8

export hexToBase64 = (str) =>
	btoa String.fromCharCode.apply(null,
		str.replace(/\r|\n/g, "").replace(/([\da-fA-F]{2}) ?/g, "0x$1 ").replace(/ +$/, "").split(" "))

export ass = (a,b) =>
	if not _.isEqual a,b
		log 'assert failure:'
		log a
		log b

export lerp = (a,b,ratio) => 
	param.Number a
	param.Number b
	param.Number ratio
	param.Number a + (b-a)*ratio

export split = (s) ->
	param.String s
	param.Array if s=="" then [] else s.split " " # there is a bug in split

export col = (n) => n %% N
export row = (n) => n // N
export sum = (arr) => arr.reduce(((a, b) => a + b), 0)
export r4r = (a) => render a, document.getElementById "app"
export spaceShip = (a,b) => if a < b then -1 else if a > b then 1 else 0

export map = _.map
export range = _.range
export log = console.log
export abs = Math.abs

export a = (a...) => h "a", a
export button = (a...) => h "button", a
export circle = (a...) => h "circle", a
export defs = (a...) => h "defs", a
export div = (a...) => h "div", a
export ellipse = (a...) => h "ellipse", a
export figure = (a...) => h "figure", a
export figCaption = (a...) => h "figCaption", a
export form = (a...) => h "form", a
export g = (a...) => h "g", a
export h1 = (a...) => h "h1", a
export h3 = (a...) => h "h3", a
export header = (a...) => h "header",a
export img = (a...) => h "img", a
export input = (a...) => h "input", a
export li = (a...) => h "li", a
export linearGradient = (a...) => h "linearGradient", a
export option = (a...) => h "option", a
export p = (a...) => h "p", a
export table = (a...) => h "table", a
export tr = (a...) => h "tr", a
export td = (a...) => h "td", a
export rect   = (a...) => h "rect",a
export select = (a...) => h "select", a
export stop = (a...) => h "stop", a
export strong = (a...) => h "strong", a
export svg = (a...) => h "svg", a
export text   = (a...) => h "text",a
export ul = (a...) => h "ul", a

export Position = (index) -> "#{"abcdefgh"[col index]}#{"87654321"[row index]}"

export createLocalStore = (name,init) =>
	localState = localStorage.getItem name
	[state, setState] = createStore if localState then JSON.parse localState else init
	createEffect () => localStorage.setItem name, JSON.stringify state
	[state, setState]

export removeIndex = (array, index) =>
	# [...array.slice 0, index, ...array.slice index + 1]
	a = array.slice 0, index 
	b = array.slice index + 1
	console.log a.concat b
	a.concat b
