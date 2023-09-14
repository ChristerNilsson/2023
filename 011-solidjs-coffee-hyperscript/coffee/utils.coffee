import h                from "https://cdn.skypack.dev/solid-js@1.2.6/h"
import _                from 'https://cdn.skypack.dev/lodash'
import { createSignal, createEffect } from "https://cdn.skypack.dev/solid-js@1.2.6"
import { render }       from "https://cdn.skypack.dev/solid-js@1.2.6/web"

export signal = createSignal
export effect = createEffect
export r4r = (a) => render a, document.getElementById "app"

export N = 8

export col = (n) => 7 - n %% N
export row = (n) => n // N
export sum = (arr)	=> arr.reduce(((a, b) => a + b), 0)

export range = _.range
export logg = console.log
export abs = Math.abs

export color = (row,col) => if (row+col) % 2 == 1 then "yellow" else "lightgray"

export circle = (a...) => h "circle", a
export div    = (a...) => h "div",a
export header = (a...) => h "header",a
export svg    = (a...) => h "svg",a
export rect   = (a...) => h "rect",a
export text   = (a...) => h "text",a
export button = (a...) => h "button",a

export Position = (index) -> "#{"abcdefgh"[col index]}#{"87654321"[row index]}"

assert = (a,b)	-> 
	if _.isEqual a,b then return
	logg 'assert failure'
	logg a
	logg b

export makeQueens = =>
	cx = 7 # board center x
	cy = 7 # board center y
	res = []
	for r in range N
		for c in range N
			dx = Math.abs 2*c - cx
			dy = Math.abs 2*r - cy
			if dx*dy not in [3,7,9,15] then res.push c+8*r
	res.sort (a,b) -> a-b
	res
assert makeQueens(),[0,1,2,5,6,7,8,9,11,12,14,15,16,23,25,27,28,30,33,35,36,38,40,47,48,49,51,52,54,55,56,57,58,61,62,63]

export makeIllegals = (queen) =>
	_.filter range(N*N), (i) =>
		ci = col i
		ri = row i
		cq = col queen
		rq = row queen
		dc = Math.abs ci - cq
		dr = Math.abs ri - rq
		ci == cq or ri == rq or dc == dr
assert makeIllegals(42), [2, 7, 10, 14, 18, 21, 24, 26, 28, 33, 34, 35, 40, 41, 42, 43, 44, 45, 46, 47, 49, 50, 51, 56, 58, 60]

logg 'Ready!'