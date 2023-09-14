import _ from 'https://cdn.skypack.dev/lodash'
import {ass,log,range} from '../js/utils.js'
import {global} from '../js/globals.js'

# Kortet är implementerat med en hash:
# q: question. "e2e4.e7e5.g1f3"
# a: answers. ["b8c6,g8f6"] Sorterade i fallande popularitetsordning.
# p: popularity. 12345 (antal partier som spelat detta drag)

# Eventuellt kan denna hash ersättas med ett enda index.
# Övriga data kan enkelt utvinnas mha global.tree.arr

N = 3 # antal boxar
export class SpacedRepetition

	constructor : (@opening) ->
		@maximum = [4,16,64] #_.map range(N),(i) => N**i # cirka 1+3+9+27+81==121 kort i systemet
		#@reset()
		@load()

	reset : =>
		g = global
		@boxes = _.map @maximum, (item) -> []
		@bindex = -1
		@qindex = 0

		@start = g.tree.getStart @opening
		@stopp = g.tree.getStopp @opening,@start
		console.log 'start',@start, 'stopp',@stopp

		@questions = g.tree.getQuestions @start,@stopp # array med index till stora arrayen
		#console.log 'getQuestions',g.questions, new Date()-start
		console.log 'arr.length '+g.tree.arr.length
		console.log 'questions.length '+@questions.length

		@qindex = 0
		@path = g.tree.getPath @questions[@qindex]
		@answers = g.tree.getAnswers @questions[@qindex],@stopp
		#console.log 'getAnswers',g.answers
		for i in range 5
			@add {p:g.tree.arr[@questions[@qindex]][3], q:g.tree.getPath(@questions[@qindex]), a: g.tree.getAnswers(@questions[@qindex],@stopp)}
			@qindex++

	lengths : => _.map @boxes, (box) => box.length

	pick : => # Hämtar ett kort från den box som är relativt mest fylld.
		res = _.map @boxes, (box,i) => [box.length/@maximum[i], i]
		res.sort()
		@bindex = _.last(res)[1]
		g = global
		@answers = @current().a
		console.log ''
		console.log @current().q
		console.log 'popularity:', @current().p
		console.log 'answers:',@answers.join ' '
		console.log 'boxes:', @lengths(), 'bindex:',@bindex

	add : (card) => @boxes[0].push card

	current : => # returnerar nuvarande kort.
		if @bindex == -1 then null else @boxes[@bindex][0]

	correct : => # flyttar kortet till nästa box
		if @bindex == -1 then return
		card = @boxes[@bindex].shift()
		if @bindex+1 < @boxes.length then @boxes[@bindex+1].push card
		else console.log card,' is done.'
		@bindex = -1
		@save()

	wrong : => # flyttar kortet till box 0
		if @bindex == -1 then return
		card = @boxes[@bindex].shift()
		@boxes[0].push card
		@bindex = -1
		@save()

	load: => # from localStorage
		data = localStorage[@opening]
		if data
			data = JSON.parse data
			@boxes = data.boxes
			@bindex = data.bindex
			@qindex = data.qindex
			console.log 'load:',@opening, @lengths() #JSON.stringify {boxes:@boxes,bindex:@bindex,qindex:global.qindex}
		else
			@reset()
			console.log 'load: no data'
	save: => # to localStorage
		localStorage[@opening] = JSON.stringify {boxes:@boxes,bindex:@bindex,qindex:@qindex}
		console.log 'save:',@opening,@lengths() #JSON.stringify {boxes:@boxes,bindex:@bindex,qindex:@qindex}

#sr = new SpacedRepetition()
# lägg till fler kort och popularity
# card1 = {q:'e2e4', a:['e7e5']}
# card2 = {q:'e2e4.e7e5', a:['g1f3']}
# console.log card1,card2
# sr.add card1
# sr.add card2
# ass [2,0,0,0,0], sr.lengths()
#ass card1,sr.pick()
# ass [2,0,0,0,0], sr.lengths()
#ass 'e2e4 is pending',sr.pick()

# sr.correct()
# ass [1,1,0,0,0], sr.lengths()
# ass -1, sr.index
# sr.correct()
# ass -1, sr.index
# ass [1,1,0,0,0], sr.lengths()

# ass card2,sr.pick()
# sr.correct()
# ass [0,2,0,0,0], sr.lengths()

#ass card1,sr.pick()
# sr.correct()
# ass [0,1,1,0,0], sr.lengths()

#ass card2,sr.pick()
# sr.correct()
# ass [0,0,2,0,0], sr.lengths()

#ass card1,sr.pick()
# sr.correct()
# ass [0,0,1,1,0], sr.lengths()

#ass card2,sr.pick()
# sr.correct()
# ass [0,0,0,2,0], sr.lengths()

# ass card1,sr.pick()
# sr.correct()
# ass [0,0,0,1,1], sr.lengths()

# ass card2,sr.pick()
# sr.correct()
# ass [0,0,0,0,2], sr.lengths()

# ass card1,sr.pick()
# sr.correct()
# ass [0,0,0,0,1], sr.lengths()

# ass card2,sr.pick()
# sr.wrong()
# ass [1,0,0,0,0], sr.lengths()

# for i in range 4
# 	sr.pick()
# 	sr.correct()

# ass [0,0,0,0,1], sr.lengths()
# sr.pick()
# sr.correct()
# ass [0,0,0,0,0], sr.lengths()
# ass "",sr.pick()

#log sr

# breadthFirstSearch = (tree,level,result,path) =>
# 	for key,node of tree
# 		if key != "n"
# 			path1 = path + "." + key
# 			if level == 0 then result.push path1
# 			breadthFirstSearch node,level-1,result,path1

# result = []
# breadthFirstSearch tree,1,result,""
# log result

# traverseBreadthFirst = (tree,) =>
# 	result = []
# 	queue = []
# 	queue.push tree
# 	while queue.length > 0
# 		node = queue.shift()
# 		for key,value of node
# 			if key != "n"
# 				queue.push value
# 				result.push key
# 	return result

# this function returns the next node of the tree, given the current node, using breadthfirst search
#queue = []
#paths = []
# f = (tree,level) =>
# 	chars = 4*(level+1) + level
# 	queue = [tree]
# 	paths = [""]
# 	i = 0
# 	path = ''
# 	while i < queue.length
# 		node = queue[i]
# 		path = paths[i]
# 		for key of node
# 			if key != 'n'
# 				if path==""
# 					path1 = key
# 				else
# 					path1 = path + '.' + key
# 				if path1.length < chars
# 					queue.push node[key]
# 					paths.push path1
# 		i+=1
# 	paths

#log 'f',f tree,1
#log paths

# getNode = (tree,keys) =>
# 	node = tree
# 	for key in keys
# 		node = node[key]
# 	log 'getNode',keys, _.keys node
# 	node

# g = (tree,path) => gg tree,path.split '.'

# gg = (tree,keys) =>
# 	log 'A',keys
# 	path = keys.join '.'
# 	log 'B',path
# 	node = getNode tree,keys.slice 0,keys.length
# 	log node
# 	keys = f node,keys.length+1
# 	log 'C'
# 	index = keys.indexOf path
# 	log 'D',index
# 	if index == -1
# 		return gg tree, keys.slice 0,keys.length-2
# 	else
# 		return keys[index+1]

# ass "d2d4", g tree,""
# ok ass "e2e4", g tree,"d2d4"
# ok ass "g1f3", g tree,"e2e4"
# ok ass "d2d4.g8f6", g tree,"g2g3"
#ass "d2d4.b7b5.e2e4", g tree,"d2d4.g8f6.c2c4"
# ass "e2e4.c7c5.g1f3", g tree,"d2d4.b7b5.e2e4"
# ass "", g tree, "d2d4.g8f6.c2c4.c7c5.d4d5.e7e6.b1c3.e6d5.c4d5.g7g6.g1f3.d7d6.c1f4.f8g7.d1a4.c8d7.a4b3.d8c7.e2e4"
