import {ass,log,range,spaceShip} from '../js/utils.js'
import {global} from '../js/globals.js'
import _ from 'https://cdn.skypack.dev/lodash'

SIZE = 2

export class Tree
	constructor : (@arr) ->

	getPath : (i) =>
		res = []
		while true
			res.push @arr[i][0]
			if @arr[i][2] == 0 then break
			i = i - @arr[i][2]
		_.reverse(res).join '.'

	getStart : (path) =>
		keys = path.split '.'
		j = 0
		for i in range keys.length
			key = keys[i]
			while @arr[j][0] != key or @arr[j][1] != i
				j += 1
				if j>=@arr.length then return -1
		j

	getStopp : (path,index) =>
		keys = path.split '.'
		j = index + 1
		while @arr[j][1] >= keys.length
			j += 1
		j

	getQuestions : (start,stopp) =>
		res = _.map range(start,stopp), (i) => [@arr[i][3], @getPath(i), i]
		res.sort (a,b) => spaceShip(b[0],a[0]) or spaceShip(a[1],b[1])
		_.map res, (item) => item[2]

	# sök igenom hela arr[start:stopp] efter alla rader med rätt level och sortera
	# Avbryt om vi hamnar utanför det aktuella trädet.
	getAnswers : (i,stopp) =>
		level = @arr[i][1]
		res = []
		for item in @arr.slice i+1,stopp
			if item[1] <= level then break
			if item[1] == level+1 then res.push item
		res.sort (a,b) => spaceShip b[3], a[3]
		result = [res[0][0]]
		for item,i in res
			# console.log item,i
			if i==0 then continue
			if res[i][3] / res[i-1][3] >= 0.8
				result.push item[0]
			else break
		# console.log 'result',result
		result

	test : =>

		if SIZE == 0
			ass "d2d4", @getPath 0
			ass "d2d4.g8f6", @getPath 1
			ass "g2g3.d7d5.f1g2", @getPath 60

			ass 22, @getStart "e2e4"
			ass 32, @getStart "e2e4.e7e5"
			ass -1, @getStart "e2e4.e7e5.g1f3.b8c6.f1c4"

			ass 42, @getStopp "e2e4",22
			ass 34, @getStopp "e2e4.e7e5",32

			# questions = getQuestions 32,34

			# ass [9, 'e2e4.e7e5'], questions[0]
			# ass [6, 'e2e4.e7e5.g1f3'], questions[1]

			# ass getAnswers(22,42), [['c7c5', 1, 1, 14], ['g7g6', 1, 15, 13], ['d7d5', 1, 3, 9], ['e7e5', 1, 10, 9], ['c7c6', 1, 12, 6]]
			# ass getAnswers(32,34), [['g1f3', 2, 1, 6]]

		if SIZE == 1
			ass "d2d4", @getPath 0
			ass "d2d4.d7d5", @getPath 1
			ass "e2e4.e7e5.g1f3.b8c6.f1c4", @getPath 2557
			ass "e2e4.e7e5.g1f3.b8c6.f1c4.f8c5.b2b4.c5b4.c2c3.b4e7.d2d4.c6a5", @getPath 2611
			ass "e2e4.e7e5.g1f3.b8c6.d2d4", @getPath 2612
			ass "c2c3", @getPath global.arr.length-1
			ass 2557, @getStart "e2e4.e7e5.g1f3.b8c6.f1c4"
			ass 2612, @getStopp "e2e4.e7e5.g1f3.b8c6.f1c4",2557
			# questions = getQuestions 2557,2612
			# ass [134, 'e2e4.e7e5.g1f3.b8c6.f1c4'], questions[0] 
			# ass [5, 'e2e4.e7e5.g1f3.b8c6.f1c4.g8f6.e1g1.f8e7'], _.last questions
			# ass getAnswers(2557,2612), [['g8f6', 5, 1, 60], ['f8c5', 5, 29, 60]]

		if SIZE == 2
			ass "e2e4.c7c5.g1f3.e7e6.d2d4.c5d4.f3d4.a7a6.f1d3.d8c7.e1g1.b8c6.d4c6.d7c6.b1d2", @getPath 100
			ass "e2e4.d7d5.e4d5.g8f6.g1f3.f6d5", @getPath 10000
			ass 4585, @getStart "e2e4.e7e5.g1f3.b8c6.f1c4"
			ass 4900, @getStopp "e2e4.e7e5.g1f3.b8c6.f1c4",4585
			questions = @getQuestions 4585,4900
			ass 4840, questions[15]
			ass 4841, questions[16]
			ass @getAnswers(4585,4900), [['g8f6', 5, 146, 529], ['f8c5', 5, 1, 454], ['f8e7', 5, 305, 19], ['g7g6', 5, 312, 12], ['f7f5', 5, 311, 8], ['d7d6', 5, 313, 8], ['a7a6', 5, 310, 5]]
			ass @getAnswers(4731,4900), [['d2d3',6,1,358],['f3g5',6,108,95],['d2d4', 6, 85, 33],['e1g1', 6, 154, 22],['b1c3', 6, 145, 11],['c2c3', 6, 158, 8]]

		console.log 'testTree done.'
