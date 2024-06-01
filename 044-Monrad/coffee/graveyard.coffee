#############################

# start = new Date()
# #for round in range 0 # N//2
# lotta()
# print 'persons',persons
# print "#{new Date() - start} milliseconds"

# calcT()
# temp = _.sortBy persons, ['score', 'T']
# temp = temp.reverse()
# print temp

#######################################

# selectRounds = (n) -> # antal ronder ska vara cirka 150% av antalet matcher i en cup. Samt jämnt.
# 	res = Math.floor 1.50 * Math.log2 n
# 	res += res % 2
# 	if 2*res > n then res -= 1
# 	if n==4 then res = 2
# 	res
# assert 2, selectRounds 4
# assert 3, selectRounds 6
# assert 4, selectRounds 10
# assert 6, selectRounds 12
# assert 6, selectRounds 24
# assert 8, selectRounds 26
# assert 8, selectRounds 60
# assert 10, selectRounds 64

	# for i in range N//2
		# a = pairings[2*i+0]
		# b = pairings[2*i+1]
		# z = random()
		# if z < 0.1 then res = 1
		# else if z < 0.5 then res =  0
		# else res = 2
		# a.res += res.toString()
		# b.res += (2-res).toString()

# N = 16
# for i in range N
# 	persons.push { id:i, name:i, col:"", res:"", score:0, opp:[], T:[0,0,0] }

# showNames = ->
# 	showHeader 'Names'
# 	textSize 0.5 * DY
# 	txt 'Table Name',mw(  5),DY*1.5,LEFT
# 	txt 'Table Name',mw(505),DY*1.5,LEFT
# 	for person,i in pairings
# 		x = mw(500) * (person.id // (N//2))
# 		y = DY * (2.5 + person.id % (N//2))
# 		bord = 1 + i//2
# 		fill if 'B' == _.last person.col then 'black' else 'white'
# 		txt bord,0.75*DY+x,y,RIGHT
# 		txt person.name,DY+x,y,LEFT

# 	buttons[3][0].active = false

# seed = 14 # Math.random()
# random = ->
# 	seed++
# 	(((Math.sin(seed)/2+0.5)*10000)%100)/100

# lotta_inner = (pairings) -> # personer sorterade
# 	# denna funktion anpassar till maxWeightMatching
# 	arr = []
# 	#print 'aaa',pairings
# 	for a in pairings
# 		for b in pairings
# 			if a.id >= b.id then continue
# 			if getMet a, b then continue
# 			mandatory = a.mandatory + b.mandatory
# 			if Math.abs(mandatory) == 2 then continue # Spelarna kan inte ha samma färg.
# 			arr.push([a.id+1, b.id+1, 1000 - Math.abs(scorex(a) - scorex(b))])
# 	print('arr',arr)
# 	z = maxWeightMatching arr
# 	print 'z',z
# 	z = z.slice 1 #[1:N+1]
# 	res = []
# 	for i in range N
# 		if i < z[i]-1 then res.concat [i,z[i]-1]
# 	# res är ej sorterad i bordsordning ännu

# 	#print 'adam',res

# 	result = []
# 	for i in range(N//2)
# 		ia = res[2*i]
# 		ib = res[2*i+1]
# 		a = persons[ia]
# 		b = persons[ib]
# 		lst = [scorex(a),scorex(b)]
# 		lst.sort(reverse=True)
# 		result.append([lst,ia,ib])
# 	result.sort(reverse=True)

# 	resultat = []
# 	for i in range(N//2)
# 		[_,ia,ib] = result[i]
# 		resultat.concat [ia,ib]
# 		# a = persons[ia]
# 		# b = persons[ib]
# 		# pa = scorex(a) # sum(a['result'])/2
# 		# pb = scorex(b) # sum(b['result'])/2
# 		# print('',i+1,' ',pa,a["name"],'         ',b["name"],' ',pb)
# 	resultat

# moveAllButtons = ->
# 	buttons[2][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY
# 	buttons[3][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY
# 	buttons[4][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY

# 	for i in range N//2
# 		y = DY * (i+2.5)
# 		buttons[3][3*i+1].setExtent mw(200),y, mw(200),30
# 		buttons[3][3*i+2].setExtent mw(500),y, mw(200),30
# 		buttons[3][3*i+3].setExtent mw(600),y, mw(200),30

# updateAllButtons = ->
# 	for i in range N//2
# 		white = pairings[2*i+0]
# 		black = pairings[2*i+1]
# 		buttons[3][3*i+1].prompt = white.name
# 		buttons[3][3*i+1].align = LEFT
# 		buttons[3][3*i+2].prompt = '-'
# 		buttons[3][3*i+3].prompt = black.name
# 		buttons[3][3*i+3].align = LEFT

# createAllButtons = ->

# 	buttons = [[],[],[],[],[]]

# 	buttons[2].push new Button 'next', 'yellow', ->
# 		state = 3
# 		print('state',state)

# 		updateAllButtons()

# 	buttons[3] = []
# 	buttons[3].push new Button 'next', 'yellow', ->
# 		state = 4
# 		print('state',state)

# 		transferResult()
# 		windowResized()
# 	for i in range N//2
# 		n = buttons[3].length
# 		do (n) ->
# 			buttons[3].push new Button 'white','white',     -> setPrompt buttons[3][n+1], '1 - 0'
# 			buttons[3].push new Button '-',    'lightgray', -> setPrompt buttons[3][n+1], '½ - ½'
# 			buttons[3].push new Button 'black', 'black',    -> setPrompt buttons[3][n+1], '0 - 1'

# 	buttons[4].push new Button 'next', 'yellow', ->
# 		resizeCanvas windowWidth, DY * (N//2+2)
# 		s = createURL()
# 		print s
# 		copyToClipboard s
# 		if rond < ROUNDS-1
# 			rond += 1
# 			for person in persons
# 				person.score = scorex person
# 			print persons
# 			lotta()
# 			print {pairings}
# 	print "#{buttons[3].length + 2} buttons created"

# window.mousePressed = (event) ->
# 	event.preventDefault()
# 	if not released then return
# 	released = false
# 	for button in buttons[state]
# 		if button.inside mouseX,mouseY then button.click()
# 	false

# window.mouseReleased = (event) ->
# 	event.preventDefault()
# 	released = true
# 	false

# setPrompt = (button,prompt) -> 
# 	button.prompt = if button.prompt == prompt then '-' else prompt
# 	for button in buttons[3].slice 1
# 		if button.prompt == '-'
# 			buttons[3][0].active = false
# 			return
# 	buttons[3][0].active = true

# transferResult = ->
# 	for i in range N//2
# 		button = buttons[3][2+3*i]
# 		white = {'1 - 0': 2,'½ - ½': 1,'0 - 1': 0}[button.prompt]
# 		pairings[2*i+0].res += "012"[white]
# 		pairings[2*i+1].res += "012"[2-white]
# 		button.prompt = '-'

# class Button
# 	constructor : (@prompt,@fill,@click) ->
# 		@active = true
# 		@align = CENTER
# 	setExtent : (@x,@y,@w,@h) ->
# 	draw : ->
# 		if not @active then return
# 		textAlign @align,CENTER
# 		if @prompt == 'next'
# 			fill 'black'
# 			rectMode CENTER
# 			rect @x,@y, @w,@h
# 		fill @fill
# 		text @prompt,@x, @y + 0.5
# 	inside : (mx,my) -> @x-@w/2 <= mx <= @x+@w/2 and @y-@h/2 <= my <= @y+@h/2 and @active

# colorize = (persons) ->
# 	for i in range persons.length//2
# 		pa = persons[2*i]
# 		pb = persons[2*i+1]
# 		pac = 'B W'[pa.mandatory+1]
# 		pbc = 'B W'[pb.mandatory+1]
# 		if pac == pbc
# 			if pa.colorComp <= pb.colorComp then pac = 'W' else pac = 'B'
# 		pa.col += pac
# 		pb.col += if pac=='W' then 'B'  else 'W'

		# for p in @players
			# colorSum = sumBW p.col
			# latest = if p.col.length== 0 then '' else _.last p.col
			# latest2 = if p.col.length < 2 then '' else sumBW _.slice p.col, p.col.length - 2

			# p.mandatory = 0
			# if colorSum <= -1 or latest2 == -2 then p.mandatory =  1
			# if colorSum >=  1 or latest2 ==  2 then p.mandatory = -1
			# p.colorComp = [colorSum,latest] # fundera på ordningen här.

		#calcScore()

# sumBW = (s) ->
# 	res = 0
# 	for item in s
# 		res += if item=='B' then -1 else 1
# 	res
# assert 0, sumBW ''
# assert 0, sumBW 'BWBWWB'
# assert -6, sumBW 'BBBBBB'
# assert 6, sumBW 'WWWWWW'

#assert 0, scorex [],0
#assert 2.5, scorex [0,1,2,2],4

