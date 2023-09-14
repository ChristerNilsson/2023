import { batch } from "https://cdn.skypack.dev/solid-js@1.2.6"
import { r4r, signal, div, h3, input, button,log } from "/js/utils.js"

[title, setTitle] = signal ""
[todos, setTodos] = signal [{title: 'städa', done: false},{title: 'raka', done: true}]

r4r =>

	addTodo = (e) =>
		log "addTodo"
		# e.preventDefault()
		batch =>
			log "batch"
			#setTodos todos.length, {title: title(), done: false}
			# setTodos todos().concat [{title: title(), done: false}]
			setTodos => 
				# temp = todos()
				# temp.push {title: title(), done: false}
				# temp
				todos().concat [{title: 'städax', done: false},{title: 'rakax', done: true}]
			log todos()
			#setTodos [todos()..., {title: 'sven', done: false}]
			setTitle ""

	div {},
		h3 {}, "Simple Todos Example"
		input {
			placeholder : "enter todo and click +",
			required : true,
			value : => title(),
			onInput : (e) => setTitle e.currentTarget.value
		}
		button {onClick:addTodo},"+"

		for todo,i in todos()
			# do (i) =>
			div {},
				input {
					type:"checkbox",
					checked: => todo.done
					# onInput:(e) => setTodos i, "done", e.currentTarget.checked
				}
				input {
					type:"text",
					value: => todo.title
					# onInput:(e) => setTodos i, "title", e.currentTarget.value
				}
				# button {onClick:() => setTodos removeIndex todos, i}, "x"

# render App, document.getElementById "app"