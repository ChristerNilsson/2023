# Exempel från https://www.solidjs.com/tutorial

# import { r4r, div} from "/js/utils.js"
# r4r => div {}, "Hello World"

# import { r4r, signal, button } from "/js/utils.js"
# r4r =>
# 	[count, setCount] = signal 1
# 	button {onClick: => setCount count() + 1}, => count()

# import { r4r, div, svg, defs, linearGradient, stop, ellipse } from '/js/utils.js'
# r4r =>
# 	name = "Solid"
# 	s = 
# 	svg {height:300, width:400},
# 		defs {},
# 			linearGradient {id:"gr1", x1:0, y1:0.6, x2:1, y2:0},
# 				stop {offset:0.05, style:"stop-color:yellow;stop-opacity:1"}
# 				stop {offset:1,    style:"stop-color:red;   stop-opacity:1"}
# 		ellipse {cx:125, cy:150, rx:100, ry:60, fill:"url(#gr1)"}
# 	div {},
# 		div {}, "Hello #{name}!", s

# import { r4r, p, div, h1 } from '/js/utils.js'
# Nested = => p {}, "This is a Paragraph"
# r4r =>
# 	div {},
# 		h1 {}, "This is a Header"
# 		Nested

# import { render } from "solid-js/web";
# import { createSignal } from "solid-js";

# import { r4r, signal, div } from '/js/utils.js'
# r4r =>
# 	[count, setCount] = signal 0
# 	f = => setCount count() + 1
# 	setInterval f, 1000
# 	div {}, "Count:", => count()

# import { r4r, signal, div, h1 } from '/js/utils.js'
# r4r =>
# 	[fruits,setFruits] = signal "Apple 🍎|Banana 🍌|Orange 🍊|Mango 🥭|Melon 🍈".split "|"
# 	div {},
# 		h1 {},"Fruits"
# 		for fruit,index in fruits()
# 			div {},"#{index+1} #{fruit}"

# import { r4r, signal, effect, log, button } from '/js/utils.js'
# r4r =>
# 	[count, setCount] = signal 0
# 	effect => log "The count is now", count()
# 	button {onClick: => setCount count() + 1},"Click Me"

# import { r4r, signal, effect, log, button, div } from '/js/utils.js'
# r4r =>
# 	[count, setCount] = signal 0
# 	doubleCount = => count() * 2
# 	f = => setCount count() + 1
# 	setInterval f, 1000
# 	div {}, "Count: ", => doubleCount()

# solidjs.memo seems to only cache the previous value
# import { r4r, div, range,log } from '/js/utils.js'
# memo = {0:1, 1:1}
# fib = (num) => memo[num] ?= fib(num - 1) + fib(num - 2)
# r4r =>
# 	for i in range 100,0
# 		div {}, => "#{i} #{fib i}"

# import { r4r, signal, button, effect,log,div } from '/js/utils.js'
# r4r =>
# 	[loggedIn, setLoggedIn] = signal false
# 	button {onClick: => setLoggedIn not loggedIn()}, => if loggedIn() then "Log in" else "Log out"

# for
# import { r4r, signal, ul,li,a } from '/js/utils.js'
# r4r =>
# 	[cats, setCats] = signal [
# 		{ id: 'J---aiyznGQ', name: 'Keyboard Cat' },
# 		{ id: 'z_AbfPXTKms', name: 'Maru' },
# 		{ id: 'OUtn3pvWmpg', name: 'Henri The Existential Cat' }
# 	]
# 	ul {},
# 		for cat,i in cats()
# 			li {},
# 				a {target:"_blank", href:"https://www.youtube.com/watch?v=#{cat.id}"}, "#{i + 1}: #{cat.name}"

# switch
# import { r4r, signal, p } from '/js/utils.js'
# r4r =>
# 	[x] = signal 7
# 	message = switch
# 		when x() > 10 then " is greater than 10"
# 		when 5 > x() then " is less than 5"
# 		else " is between 5 and 10"
# 	p {}, x(), message

# Dynamic
# import { r4r, signal, strong,select,option,div } from '/js/utils.js'
# options =
# 	red:   strong {style:"color:red"},  "Red Thing"
# 	green: strong {style:"color:green"},"Green Thing"
# 	blue:  strong {style:"color:blue"}, "Blue Thing"
# r4r =>
# 	[selected, setSelected] = signal "red"
# 	div {},
# 		select {value: selected(), onInput: (e) => setSelected e.currentTarget.value},
# 			for color of options
# 				option {value:color},color
# 		=> options[selected()]

# onMount. Fick ej asynkron laddning att fungera
# import { onMount } from "https://cdn.skypack.dev/solid-js@1.2.6"
# # import "./styles.css"
# import { r4r, signal,effect,div,h1,img,figure,figCaption,log } from '/js/utils.js'

# data = [
# 	{albumId: 1, id: 1, title: 'accusamus beatae ad facilis cum similique qui sunt', url: 'https://via.placeholder.com/600/92c952', thumbnailUrl: 'https://via.placeholder.com/150/92c952'}
# 	{albumId: 1, id: 2, title: 'reprehenderit est deserunt velit ipsam', url: 'https://via.placeholder.com/600/771796', thumbnailUrl: 'https://via.placeholder.com/150/771796'}
# 	{albumId: 1, id: 3, title: 'officia porro iure quia iusto qui ipsa ut modi', url: 'https://via.placeholder.com/600/24f355', thumbnailUrl: 'https://via.placeholder.com/150/24f355'}
# 	{albumId: 1, id: 4, title: 'culpa odio esse rerum omnis laboriosam voluptate repudiandae', url: 'https://via.placeholder.com/600/d32776', thumbnailUrl: 'https://via.placeholder.com/150/d32776'}
# 	{albumId: 1, id: 5, title: 'natus nisi omnis corporis facere molestiae rerum in', url: 'https://via.placeholder.com/600/f66b97', thumbnailUrl: 'https://via.placeholder.com/150/f66b97'}
# 	{albumId: 1, id: 6, title: 'accusamus ea aliquid et amet sequi nemo', url: 'https://via.placeholder.com/600/56a8c2', thumbnailUrl: 'https://via.placeholder.com/150/56a8c2'}
# 	{albumId: 1, id: 7, title: 'officia delectus consequatur vero aut veniam explicabo molestias', url: 'https://via.placeholder.com/600/b0f7cc', thumbnailUrl: 'https://via.placeholder.com/150/b0f7cc'}
# 	{albumId: 1, id: 8, title: 'aut porro officiis laborum odit ea laudantium corporis', url: 'https://via.placeholder.com/600/54176f', thumbnailUrl: 'https://via.placeholder.com/150/54176f'}
# 	{albumId: 1, id: 9, title: 'qui eius qui autem sed', url: 'https://via.placeholder.com/600/51aa97', thumbnailUrl: 'https://via.placeholder.com/150/51aa97'}
# 	{albumId: 1, id: 10, title: 'beatae et provident et ut vel', url: 'https://via.placeholder.com/600/810b14', thumbnailUrl: 'https://via.placeholder.com/150/810b14'}
# 	{albumId: 1, id: 11, title: 'nihil at amet non hic quia qui', url: 'https://via.placeholder.com/600/1ee8a4', thumbnailUrl: 'https://via.placeholder.com/150/1ee8a4'}
# 	{albumId: 1, id: 12, title: 'mollitia soluta ut rerum eos aliquam consequatur perspiciatis maiores', url: 'https://via.placeholder.com/600/66b7d2', thumbnailUrl: 'https://via.placeholder.com/150/66b7d2'}
# 	{albumId: 1, id: 13, title: 'repudiandae iusto deleniti rerum', url: 'https://via.placeholder.com/600/197d29', thumbnailUrl: 'https://via.placeholder.com/150/197d29'}
# 	{albumId: 1, id: 14, title: 'est necessitatibus architecto ut laborum', url: 'https://via.placeholder.com/600/61a65', thumbnailUrl: 'https://via.placeholder.com/150/61a65'}
# 	{albumId: 1, id: 15, title: 'harum dicta similique quis dolore earum ex qui', url: 'https://via.placeholder.com/600/f9cee5', thumbnailUrl: 'https://via.placeholder.com/150/f9cee5'}
# 	{albumId: 1, id: 16, title: 'iusto sunt nobis quasi veritatis quas expedita voluptatum deserunt', url: 'https://via.placeholder.com/600/fdf73e', thumbnailUrl: 'https://via.placeholder.com/150/fdf73e'}
# 	{albumId: 1, id: 17, title: 'natus doloribus necessitatibus ipsa', url: 'https://via.placeholder.com/600/9c184f', thumbnailUrl: 'https://via.placeholder.com/150/9c184f'}
# 	{albumId: 1, id: 18, title: 'laboriosam odit nam necessitatibus et illum dolores reiciendis', url: 'https://via.placeholder.com/600/1fe46f', thumbnailUrl: 'https://via.placeholder.com/150/1fe46f'}
# 	{albumId: 1, id: 19, title: 'perferendis nesciunt eveniet et optio a', url: 'https://via.placeholder.com/600/56acb2', thumbnailUrl: 'https://via.placeholder.com/150/56acb2'}
# 	{albumId: 1, id: 20, title: 'assumenda voluptatem laboriosam enim consequatur veniam placeat reiciendis error', url: 'https://via.placeholder.com/600/8985dc', thumbnailUrl: 'https://via.placeholder.com/150/8985dc'}
# ]
# r4r =>
# 	[photos, setPhotos] = signal []
# 	# onMount =>
# 	# 	res = await fetch "https://jsonplaceholder.typicode.com/photos?_limit=20"
# 	# 	setPhotos await res.json()
# 	setPhotos data
# 	effect =>
# 		log photos()
# 	div {},
# 		h1 {}, "Photo album"
# 		for photo in photos()
# 			figure {},
# 				img {src:photo.thumbnailUrl, alt:photo.title}
# 				figCaption {}, photo.title

# onCleanup
# import { onCleanup } from "https://cdn.skypack.dev/solid-js@1.2.6"
# import { r4r, signal,effect,div,h1,img,figure,figCaption,log } from '/js/utils.js'
# r4r =>
# 	[count, setCount] = signal 0
# 	f = => setCount count() + 1
# 	timer = setInterval f, 1000
# 	onCleanup => clearInterval timer
# 	div {}, "Count:", => count()

# Bindings/events
# import { r4r, signal,div } from '/js/utils.js'
# r4r =>
# 	[pos, setPos] = signal {x: 0, y: 0}
# 	onMouseMove = (e) => setPos {x: e.clientX, y: e.clientY}
# 	div {onMouseMove}, => "The mouse position is #{pos().x} x #{pos().y}"

# Style 
# import { r4r, signal,div } from '/js/utils.js'
# r4r =>
# 	[num, setNum] = signal 0
# 	f = => setNum (num() + 1) % 255
# 	setInterval f, 30
# 	s = => " 
# 		color : rgb(#{num()}, 180, #{num()});
# 		font-weight : 800;
# 		font-size : #{num()}px" # n.b.: Arrow function is needed to avoid the style to be evaluated only once
# 	=> div {style: s}, num()

# ClassList

import { r4r, signal,div,button } from '/js/utils.js'
r4r => 
	g = (x) => "display:block;" + if current() == x then 'background-color: #ff3e00;color:white' else ''
	[current, setCurrent] = signal "foo"
	=> div {style:s},
		button {style:g('foo'), onClick: => setCurrent 'foo'}, "foo"
		button {style:g('bar'), onClick: => setCurrent 'bar'}, "bar"
		button {style:g('baz'), onClick: => setCurrent 'baz'}, "baz"
