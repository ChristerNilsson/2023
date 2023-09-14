import _ from 'https://cdn.skypack.dev/lodash'
import {ass,r4r,signal,range,br,div,input,button,bold,abs} from '../js/utils.js'

ass [], [7,8].slice 0,0
ass [7], [7,8].slice 0,1
ass [8], [7,8].slice 1,2
ass [7,8], [7,8].slice 0,2

update = (lst,i,j,c) =>
	lst1 = lst.slice 0,i
	lst2 = lst1.concat(lst.slice i+1,j)
	lst3 = lst2.concat(lst.slice j+1)
	lst3 = lst3.concat([c])
	ass lst3.length,lst.length-1
	lst3
ass [23], update [11,12],0,1,23
ass [13,23], update [11,12,13],0,1,23
ass [11,25], update [11,12,13],1,2,25
ass [12,24], update [11,12,13],0,2,24
ass [13,14,23], update [11,12,13,14],0,1,23

operation = (a,op,b) =>
	c = 0
	if op == '+' then c = a + b
	if op == '-' then c = a - b
	if b != 1
		if op == '*' then c = a * b
		if op == '/' and a %% b == 0 then c = a // b
	c

Digits = (target,numbers) =>
	[solutions,setSolutions] = signal []

	fix = (a) =>
		if a > 0 then return a
		bold {}, -a

	traverse = (solution,hash,key,level='') =>
		if key not of hash then return
		[c,a,op,b] = hash[key]
		solution.push "#{level} #{c} = #{abs a} #{op} #{abs b}"
		traverse solution,hash,a,level + '•'
		traverse solution,hash,b,level + '•'

	indented = (sol,target) =>
		hash = {}
		for line in sol
			[c,a,op,b] = line
			hash[c] = line
		solution = []
		traverse solution,hash,target
		solution
	ass [4712], indented [[7, -9, '-', -2], [17, -10, '+', -7],[850, -50, '*', 17],[843, 850, '-', 7]],84

	click = (t,n) =>
		solve parseInt(t.value), n.value.split(' ').map (x) => -parseInt x
	solve = (target, numbers) =>
		solution = "0123456789"
		solve1 = (target, lst, level, lines) =>
			n = lst.length
			for i in range n-1
				for j in range i+1,n
					a = lst[i]
					b = lst[j]
					if abs(a) < abs(b) then [a,b] = [b,a]
					for op in "*+-/"
						c = operation abs(a),op,abs(b)
						if c > 0
							lines1 = lines.concat [[c,a,op,b]]
							lst1 = update lst,i,j,c
							if c == target
								if solution.length > lines1.length
									solution = lines1
							else
								if level > 1 then solve1 target,lst1,level-1,lines1

		start = new Date()
		if numbers.length > 6
			solution = ["Maximum six numbers"]
		else
			for level in range 2,6
				solve1 target,numbers,level,[]
				if solution.length != 10 then break

			solution = indented solution,target

			if solution.length==10 then solution = ["No solution"]
		setSolutions solution
		console.log new Date() - start

	div {},
		div {},
			n = input {size:13, value:numbers}
			t = input {size:3, value:target}
			button {onclick: => click t,n},"solve"
		=> for sol in solutions()
			div {}, sol
		br {}

r4r =>
	div {style:'text-align:left;font-size:2em;font-family: "Courier New", Courier, monospace;'},
		Digits 101,'2 7 9 10 25 50'
		Digits 571,'2 7 9 10 25 50'
		Digits 133,'4 5 8 11 15 20'
		Digits 218,'4 5 7 9 11 20'
		Digits 388,'3 5 9 20 23 25'
		Digits 462,'3 5 9 10 20 25'
