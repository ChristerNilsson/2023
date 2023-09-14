#    c  d  h  s
# 2  0  1  2  3
# 3  4  5  6  7
# 4  8  9 10 11
# 5 12 13 14 15
# 6 16 17 18 19
# 7 20 21 22 23
# 8 24 25 26 27
# 9 28 29 30 31
# T 32 33 34 35
# J 36 37 38 39
# Q 40 41 42 43
# K 44 45 46 47
# A 48 49 50 51

# Färger rangordnas ej.
# Är valörerna lika, splittas potten.

# https://www.pokerlistings.com/which-hand-wins-calculator

range = _.range
ass = (a,b) => if a!=b then console.log 'Assert failed',a,'!=',b

sort = (lst) => lst.sort (a,b) => b-a
spaceShip =(a,b) =>
	if a == b then 0 # lika
	else if a < b then 1 else -1 # 1=stigande, -1=fallande

compare = (na,nb) =>
	a = hands[na]
	b = hands[nb]
	res = spaceShip a.comp,b.comp
	console.log na,'<=>',nb,'Vinnare:',[na,'split',nb][res+1]
	res

log = (x) ->
	console.log x
	x

COLORS = 'cdhs'.split '' # clubs, diamonds, hearts, spades
VALUES = '23456789TJQKA'.split '' # ten, jack, queen, king, ace

toNumber = (card) ->
	c = COLORS.indexOf card[0]
	v = VALUES.indexOf card[1]
	c + v*COLORS.length
ass 0, toNumber 'c2'
ass 1, toNumber 'd2'
ass 51, toNumber 'sA'

toLitteral = (card) ->
	c = card %% COLORS.length
	v = card // COLORS.length
	COLORS[c] + VALUES[v]
ass 'c2', toLitteral 0
ass 'd2', toLitteral 1
ass 'hA', toLitteral 50
ass 'sA', toLitteral 51

value = (number) => number // 4
ass 12, value 51
ass 0, value 0

color = (number) => number %% 4
ass 3, color 51
ass 0, color 0

class Hand
	constructor : (@str,@facit) ->
		@lst = @str.split ' '
		@lst = _.map @lst, (card) => toNumber card
		@lst = sort @lst, (a,b) => b-a
		@evaluate()
		ass @comp, @facit

	draw : (j) =>
		textAlign RIGHT
		text j, 30, 20+20*j
		textAlign LEFT
		for card,i in @lst
			@show card,i,j
		fill 'black'
		text @comp, 240, 20+20*j

	show : (card,i,j) =>
		c = card %% COLORS.length
		v = card // COLORS.length
		fill "black red red black".split(" ")[c]
		text COLORS[c] + VALUES[v], 40+40*i, 20+20*j
	
	vc : =>
		mapper = {A:'E',K:'D',Q:'C',J:'B',T:'A'}
		res = _.map @valueCount[1], (item) => mapper[item] or item
		res.join ""

	evaluate : =>
		@valueCount = @groupValues()
		@colorCount = @groupColors()
		@comp = '0'
		if @valueCount[0] == '2111' then @comp = '1'
		if @valueCount[0] == '221' then @comp = '2'
		if @valueCount[0] == '311' then @comp = '3'
		if @valueCount[0] == '32' then @comp = '6'
		if @valueCount[0] == '41' then @comp = '7'
		if @valueCount[0] == '11111'
			if @färg() and @stege() then @comp = '8'
			else if @färg() then @comp = '5'
			else if @stege() then @comp = '4'
		@comp += ':' + @vc()

	stege : -> 
		if @valueCount[1] == 'A5432'
			@valueCount[1] = '5'
			return true
		if 4 == Math.abs value(@lst[0]) - value(@lst[4])
			@valueCount[1] = @valueCount[1][0]
			return true
		false
	färg : -> @colorCount

	groupValues : ->
		arr = []
		for card in @lst
			index = card // 4
			if not arr[index] then arr[index] = [0,card//4]
			arr[index][0]++
		arr = _.compact arr
		res = arr.sort (a,b) => b[0]-a[0] || b[1]-a[1]
		c0 = _.map res, (a) => a[0]
		c1 = _.map res, (a) => VALUES[a[1]]
		[c0.join(""), c1.join("")]

	groupColors : ->
		arr = [0,0,0,0]
		for card in @lst
			arr[card %% 4]++
		arr = _.compact arr # tar bort alla nollor
		arr.length == 1

hands = []
hands.push new Hand "h3 d4 sA c5 c6", '0:E6543' # 0
hands.push new Hand "h3 d4 sA c7 c6", '0:E7643' # 1
hands.push new Hand "s3 dJ h3 cQ cT", '1:3CBA' # 2
hands.push new Hand "s3 dJ h3 cQ cK", '1:3DCB' # 3
hands.push new Hand "s3 dJ c3 cQ cK", '1:3DCB' # 4
hands.push new Hand "cA hA cK hK c7", '2:ED7' # 5
hands.push new Hand "cA hA sA hK c7", '3:ED7' # 6
hands.push new Hand "h5 c4 c3 c2 cA", '4:5' # 7
hands.push new Hand "c7 h6 c5 h4 c3", '4:7' # 8
hands.push new Hand "hA cK cQ cJ cT", '4:E' # 9
hands.push new Hand "h5 h6 h7 h9 h3", '5:97653' # 10
hands.push new Hand "s5 s6 s7 s9 s3", '5:97653' # 11
hands.push new Hand "h5 h6 h8 h9 h3", '5:98653' # 12
hands.push new Hand "cQ hQ sQ hJ cJ", '6:CB' # 13
hands.push new Hand "s5 h5 c9 d5 c5", '7:59' # 14
hands.push new Hand "cA c2 c4 c3 c5", '8:5' # 15
hands.push new Hand "c2 c3 c4 c5 c6", '8:6' # 16
hands.push new Hand "cK cT cJ cQ c9", '8:D' # 17
hands.push new Hand "cT cJ cQ cK cA", '8:E' # 18

ass 0, compare  0, 0
ass 1, compare  0, 1
ass 1, compare  0, 2
ass 1, compare  2, 3
ass 0, compare  3, 3
ass 0, compare  3, 4
ass 1, compare  6, 7
ass 1, compare  5, 6
ass 1, compare  5, 7
ass 1, compare  8, 9
ass 0, compare 10,11
ass 1, compare 10,12
ass 1, compare 13,14
ass 1, compare 15,16
ass 1, compare 17,18

window.setup = ->
	createCanvas 500, 400
	background "lightgray"
	textSize 20
	textFont "Courier New"
	for hand,j in hands
		hand.draw j
