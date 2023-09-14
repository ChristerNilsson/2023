import {writable,get} from 'svelte/store'
export let stack = writable([])

const m = {}
m["/"] = ['a','b']
m.a = ['a1', 'a2']
m['a/a1'] = ['a11', 'a12']
m['a/a2'] = ['a21', 'a22']
m.b = 'b1 b2'
m['b/b1'] = ['b11', 'b12']
m['b/b2'] = ['b21', 'b22']
export let menu = writable(m)
