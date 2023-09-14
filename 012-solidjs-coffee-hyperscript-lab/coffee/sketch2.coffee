# https://codesandbox.io/s/0vmjlmq94v?file=/index.js:0-2096 Ryan Carniato (h)

# Har ej fått denna att fungera än. Den fyller inte på todos med nya värden.
# Man måste refresha sidan för att se att det fungerar.

import { createSignal, createEffect } from "https://cdn.skypack.dev/solid-js@1.2.6"
# import { render }        from "https://cdn.skypack.dev/solid-js@1.2.6/web"
# import h                 from "https://cdn.skypack.dev/solid-js@1.2.6/h"
import { createStore }   from "https://cdn.skypack.dev/solid-js@1.2.6/store"
import { h3,input,button,div,r4r,log } from "/js/utils.js"

createLocalStore = (initState) =>
	[state, setState] = createStore initState
	if localStorage.todos then setState JSON.parse localStorage.todos
	createEffect => localStorage.todos = JSON.stringify state
	[state, setState]

r4r => 
	log 'r4r'
	[state, setState] = createLocalStore {todos:[], title:"", idCounter:0}
	div {},
		h3 {}, "Simple Todos Example"
		input {
			type: "text",
			placeholder: "enter todo and click +",
			value: => state.title,
			onInput: (e) => setState "title", e.target.value
		}
		button {
			onClick: =>
				setState ((s) => {
					idCounter: s.idCounter + 1,
					todos: [...s.todos, {id: state.idCounter,title: state.title,done: false}],
					title: ""
				})
			},
			"+"
		for todo in state.todos
			div {},
				input {
					type: "checkbox",
					checked: => todo.done,
					onChange: (e) => setState("todos",state.todos.findIndex((t) => t.id == todo.id),{done: e.target.checked})
				}
				input {
					type: "text",
					value: => todo.title,
					onChange: (e) => setState("todos",state.todos.findIndex((t) => t.id == todo.id),{title: e.target.value})
				}
				button {onClick: () => setState("todos", (t) => t.filter((t) => t.id != todo.id))},"x"
