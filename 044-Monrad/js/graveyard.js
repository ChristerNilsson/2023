// Generated by CoffeeScript 2.7.0
//############################

// start = new Date()
// #for round in range 0 # N//2
// lotta()
// print 'persons',persons
// print "#{new Date() - start} milliseconds"

// calcT()
// temp = _.sortBy persons, ['score', 'T']
// temp = temp.reverse()
// print temp

//######################################

// selectRounds = (n) -> # antal ronder ska vara cirka 150% av antalet matcher i en cup. Samt jämnt.
// 	res = Math.floor 1.50 * Math.log2 n
// 	res += res % 2
// 	if 2*res > n then res -= 1
// 	if n==4 then res = 2
// 	res
// assert 2, selectRounds 4
// assert 3, selectRounds 6
// assert 4, selectRounds 10
// assert 6, selectRounds 12
// assert 6, selectRounds 24
// assert 8, selectRounds 26
// assert 8, selectRounds 60
// assert 10, selectRounds 64

// for i in range N//2
// a = pairings[2*i+0]
// b = pairings[2*i+1]
// z = random()
// if z < 0.1 then res = 1
// else if z < 0.5 then res =  0
// else res = 2
// a.res += res.toString()
// b.res += (2-res).toString()

// N = 16
// for i in range N
// 	persons.push { id:i, name:i, col:"", res:"", score:0, opp:[], T:[0,0,0] }

// showNames = ->
// 	showHeader 'Names'
// 	textSize 0.5 * DY
// 	txt 'Table Name',mw(  5),DY*1.5,LEFT
// 	txt 'Table Name',mw(505),DY*1.5,LEFT
// 	for person,i in pairings
// 		x = mw(500) * (person.id // (N//2))
// 		y = DY * (2.5 + person.id % (N//2))
// 		bord = 1 + i//2
// 		fill if 'B' == _.last person.col then 'black' else 'white'
// 		txt bord,0.75*DY+x,y,RIGHT
// 		txt person.name,DY+x,y,LEFT

// 	buttons[3][0].active = false

// seed = 14 # Math.random()
// random = ->
// 	seed++
// 	(((Math.sin(seed)/2+0.5)*10000)%100)/100

// lotta_inner = (pairings) -> # personer sorterade
// 	# denna funktion anpassar till maxWeightMatching
// 	arr = []
// 	#print 'aaa',pairings
// 	for a in pairings
// 		for b in pairings
// 			if a.id >= b.id then continue
// 			if getMet a, b then continue
// 			mandatory = a.mandatory + b.mandatory
// 			if Math.abs(mandatory) == 2 then continue # Spelarna kan inte ha samma färg.
// 			arr.push([a.id+1, b.id+1, 1000 - Math.abs(scorex(a) - scorex(b))])
// 	print('arr',arr)
// 	z = maxWeightMatching arr
// 	print 'z',z
// 	z = z.slice 1 #[1:N+1]
// 	res = []
// 	for i in range N
// 		if i < z[i]-1 then res.concat [i,z[i]-1]
// 	# res är ej sorterad i bordsordning ännu

// 	#print 'adam',res

// 	result = []
// 	for i in range(N//2)
// 		ia = res[2*i]
// 		ib = res[2*i+1]
// 		a = persons[ia]
// 		b = persons[ib]
// 		lst = [scorex(a),scorex(b)]
// 		lst.sort(reverse=True)
// 		result.append([lst,ia,ib])
// 	result.sort(reverse=True)

// 	resultat = []
// 	for i in range(N//2)
// 		[_,ia,ib] = result[i]
// 		resultat.concat [ia,ib]
// 		# a = persons[ia]
// 		# b = persons[ib]
// 		# pa = scorex(a) # sum(a['result'])/2
// 		# pb = scorex(b) # sum(b['result'])/2
// 		# print('',i+1,' ',pa,a["name"],'         ',b["name"],' ',pb)
// 	resultat

// moveAllButtons = ->
// 	buttons[2][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY
// 	buttons[3][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY
// 	buttons[4][0].setExtent mw(950),0.45*DY, mw(60),0.55*DY

// 	for i in range N//2
// 		y = DY * (i+2.5)
// 		buttons[3][3*i+1].setExtent mw(200),y, mw(200),30
// 		buttons[3][3*i+2].setExtent mw(500),y, mw(200),30
// 		buttons[3][3*i+3].setExtent mw(600),y, mw(200),30

// updateAllButtons = ->
// 	for i in range N//2
// 		white = pairings[2*i+0]
// 		black = pairings[2*i+1]
// 		buttons[3][3*i+1].prompt = white.name
// 		buttons[3][3*i+1].align = LEFT
// 		buttons[3][3*i+2].prompt = '-'
// 		buttons[3][3*i+3].prompt = black.name
// 		buttons[3][3*i+3].align = LEFT

// createAllButtons = ->

// 	buttons = [[],[],[],[],[]]

// 	buttons[2].push new Button 'next', 'yellow', ->
// 		state = 3
// 		print('state',state)

// 		updateAllButtons()

// 	buttons[3] = []
// 	buttons[3].push new Button 'next', 'yellow', ->
// 		state = 4
// 		print('state',state)

// 		transferResult()
// 		windowResized()
// 	for i in range N//2
// 		n = buttons[3].length
// 		do (n) ->
// 			buttons[3].push new Button 'white','white',     -> setPrompt buttons[3][n+1], '1 - 0'
// 			buttons[3].push new Button '-',    'lightgray', -> setPrompt buttons[3][n+1], '½ - ½'
// 			buttons[3].push new Button 'black', 'black',    -> setPrompt buttons[3][n+1], '0 - 1'

// 	buttons[4].push new Button 'next', 'yellow', ->
// 		resizeCanvas windowWidth, DY * (N//2+2)
// 		s = createURL()
// 		print s
// 		copyToClipboard s
// 		if rond < ROUNDS-1
// 			rond += 1
// 			for person in persons
// 				person.score = scorex person
// 			print persons
// 			lotta()
// 			print {pairings}
// 	print "#{buttons[3].length + 2} buttons created"

// window.mousePressed = (event) ->
// 	event.preventDefault()
// 	if not released then return
// 	released = false
// 	for button in buttons[state]
// 		if button.inside mouseX,mouseY then button.click()
// 	false

// window.mouseReleased = (event) ->
// 	event.preventDefault()
// 	released = true
// 	false

// setPrompt = (button,prompt) -> 
// 	button.prompt = if button.prompt == prompt then '-' else prompt
// 	for button in buttons[3].slice 1
// 		if button.prompt == '-'
// 			buttons[3][0].active = false
// 			return
// 	buttons[3][0].active = true

// transferResult = ->
// 	for i in range N//2
// 		button = buttons[3][2+3*i]
// 		white = {'1 - 0': 2,'½ - ½': 1,'0 - 1': 0}[button.prompt]
// 		pairings[2*i+0].res += "012"[white]
// 		pairings[2*i+1].res += "012"[2-white]
// 		button.prompt = '-'

// class Button
// 	constructor : (@prompt,@fill,@click) ->
// 		@active = true
// 		@align = CENTER
// 	setExtent : (@x,@y,@w,@h) ->
// 	draw : ->
// 		if not @active then return
// 		textAlign @align,CENTER
// 		if @prompt == 'next'
// 			fill 'black'
// 			rectMode CENTER
// 			rect @x,@y, @w,@h
// 		fill @fill
// 		text @prompt,@x, @y + 0.5
// 	inside : (mx,my) -> @x-@w/2 <= mx <= @x+@w/2 and @y-@h/2 <= my <= @y+@h/2 and @active


//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZ3JhdmV5YXJkLmpzIiwic291cmNlUm9vdCI6Ii4uXFwiLCJzb3VyY2VzIjpbImNvZmZlZVxcZ3JhdmV5YXJkLmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiO0FBa053RiIsInNvdXJjZXNDb250ZW50IjpbIiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXHJcblxyXG4jIHN0YXJ0ID0gbmV3IERhdGUoKVxyXG4jICNmb3Igcm91bmQgaW4gcmFuZ2UgMCAjIE4vLzJcclxuIyBsb3R0YSgpXHJcbiMgcHJpbnQgJ3BlcnNvbnMnLHBlcnNvbnNcclxuIyBwcmludCBcIiN7bmV3IERhdGUoKSAtIHN0YXJ0fSBtaWxsaXNlY29uZHNcIlxyXG5cclxuIyBjYWxjVCgpXHJcbiMgdGVtcCA9IF8uc29ydEJ5IHBlcnNvbnMsIFsnc2NvcmUnLCAnVCddXHJcbiMgdGVtcCA9IHRlbXAucmV2ZXJzZSgpXHJcbiMgcHJpbnQgdGVtcFxyXG5cclxuIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXHJcblxyXG4jIHNlbGVjdFJvdW5kcyA9IChuKSAtPiAjIGFudGFsIHJvbmRlciBza2EgdmFyYSBjaXJrYSAxNTAlIGF2IGFudGFsZXQgbWF0Y2hlciBpIGVuIGN1cC4gU2FtdCBqw6RtbnQuXHJcbiMgXHRyZXMgPSBNYXRoLmZsb29yIDEuNTAgKiBNYXRoLmxvZzIgblxyXG4jIFx0cmVzICs9IHJlcyAlIDJcclxuIyBcdGlmIDIqcmVzID4gbiB0aGVuIHJlcyAtPSAxXHJcbiMgXHRpZiBuPT00IHRoZW4gcmVzID0gMlxyXG4jIFx0cmVzXHJcbiMgYXNzZXJ0IDIsIHNlbGVjdFJvdW5kcyA0XHJcbiMgYXNzZXJ0IDMsIHNlbGVjdFJvdW5kcyA2XHJcbiMgYXNzZXJ0IDQsIHNlbGVjdFJvdW5kcyAxMFxyXG4jIGFzc2VydCA2LCBzZWxlY3RSb3VuZHMgMTJcclxuIyBhc3NlcnQgNiwgc2VsZWN0Um91bmRzIDI0XHJcbiMgYXNzZXJ0IDgsIHNlbGVjdFJvdW5kcyAyNlxyXG4jIGFzc2VydCA4LCBzZWxlY3RSb3VuZHMgNjBcclxuIyBhc3NlcnQgMTAsIHNlbGVjdFJvdW5kcyA2NFxyXG5cclxuXHQjIGZvciBpIGluIHJhbmdlIE4vLzJcclxuXHRcdCMgYSA9IHBhaXJpbmdzWzIqaSswXVxyXG5cdFx0IyBiID0gcGFpcmluZ3NbMippKzFdXHJcblx0XHQjIHogPSByYW5kb20oKVxyXG5cdFx0IyBpZiB6IDwgMC4xIHRoZW4gcmVzID0gMVxyXG5cdFx0IyBlbHNlIGlmIHogPCAwLjUgdGhlbiByZXMgPSAgMFxyXG5cdFx0IyBlbHNlIHJlcyA9IDJcclxuXHRcdCMgYS5yZXMgKz0gcmVzLnRvU3RyaW5nKClcclxuXHRcdCMgYi5yZXMgKz0gKDItcmVzKS50b1N0cmluZygpXHJcblxyXG4jIE4gPSAxNlxyXG4jIGZvciBpIGluIHJhbmdlIE5cclxuIyBcdHBlcnNvbnMucHVzaCB7IGlkOmksIG5hbWU6aSwgY29sOlwiXCIsIHJlczpcIlwiLCBzY29yZTowLCBvcHA6W10sIFQ6WzAsMCwwXSB9XHJcblxyXG4jIHNob3dOYW1lcyA9IC0+XHJcbiMgXHRzaG93SGVhZGVyICdOYW1lcydcclxuIyBcdHRleHRTaXplIDAuNSAqIERZXHJcbiMgXHR0eHQgJ1RhYmxlIE5hbWUnLG13KCAgNSksRFkqMS41LExFRlRcclxuIyBcdHR4dCAnVGFibGUgTmFtZScsbXcoNTA1KSxEWSoxLjUsTEVGVFxyXG4jIFx0Zm9yIHBlcnNvbixpIGluIHBhaXJpbmdzXHJcbiMgXHRcdHggPSBtdyg1MDApICogKHBlcnNvbi5pZCAvLyAoTi8vMikpXHJcbiMgXHRcdHkgPSBEWSAqICgyLjUgKyBwZXJzb24uaWQgJSAoTi8vMikpXHJcbiMgXHRcdGJvcmQgPSAxICsgaS8vMlxyXG4jIFx0XHRmaWxsIGlmICdCJyA9PSBfLmxhc3QgcGVyc29uLmNvbCB0aGVuICdibGFjaycgZWxzZSAnd2hpdGUnXHJcbiMgXHRcdHR4dCBib3JkLDAuNzUqRFkreCx5LFJJR0hUXHJcbiMgXHRcdHR4dCBwZXJzb24ubmFtZSxEWSt4LHksTEVGVFxyXG5cclxuIyBcdGJ1dHRvbnNbM11bMF0uYWN0aXZlID0gZmFsc2VcclxuXHJcbiMgc2VlZCA9IDE0ICMgTWF0aC5yYW5kb20oKVxyXG4jIHJhbmRvbSA9IC0+XHJcbiMgXHRzZWVkKytcclxuIyBcdCgoKE1hdGguc2luKHNlZWQpLzIrMC41KSoxMDAwMCklMTAwKS8xMDBcclxuXHJcbiMgbG90dGFfaW5uZXIgPSAocGFpcmluZ3MpIC0+ICMgcGVyc29uZXIgc29ydGVyYWRlXHJcbiMgXHQjIGRlbm5hIGZ1bmt0aW9uIGFucGFzc2FyIHRpbGwgbWF4V2VpZ2h0TWF0Y2hpbmdcclxuIyBcdGFyciA9IFtdXHJcbiMgXHQjcHJpbnQgJ2FhYScscGFpcmluZ3NcclxuIyBcdGZvciBhIGluIHBhaXJpbmdzXHJcbiMgXHRcdGZvciBiIGluIHBhaXJpbmdzXHJcbiMgXHRcdFx0aWYgYS5pZCA+PSBiLmlkIHRoZW4gY29udGludWVcclxuIyBcdFx0XHRpZiBnZXRNZXQgYSwgYiB0aGVuIGNvbnRpbnVlXHJcbiMgXHRcdFx0bWFuZGF0b3J5ID0gYS5tYW5kYXRvcnkgKyBiLm1hbmRhdG9yeVxyXG4jIFx0XHRcdGlmIE1hdGguYWJzKG1hbmRhdG9yeSkgPT0gMiB0aGVuIGNvbnRpbnVlICMgU3BlbGFybmEga2FuIGludGUgaGEgc2FtbWEgZsOkcmcuXHJcbiMgXHRcdFx0YXJyLnB1c2goW2EuaWQrMSwgYi5pZCsxLCAxMDAwIC0gTWF0aC5hYnMoc2NvcmV4KGEpIC0gc2NvcmV4KGIpKV0pXHJcbiMgXHRwcmludCgnYXJyJyxhcnIpXHJcbiMgXHR6ID0gbWF4V2VpZ2h0TWF0Y2hpbmcgYXJyXHJcbiMgXHRwcmludCAneicselxyXG4jIFx0eiA9IHouc2xpY2UgMSAjWzE6TisxXVxyXG4jIFx0cmVzID0gW11cclxuIyBcdGZvciBpIGluIHJhbmdlIE5cclxuIyBcdFx0aWYgaSA8IHpbaV0tMSB0aGVuIHJlcy5jb25jYXQgW2kseltpXS0xXVxyXG4jIFx0IyByZXMgw6RyIGVqIHNvcnRlcmFkIGkgYm9yZHNvcmRuaW5nIMOkbm51XHJcblxyXG4jIFx0I3ByaW50ICdhZGFtJyxyZXNcclxuXHJcbiMgXHRyZXN1bHQgPSBbXVxyXG4jIFx0Zm9yIGkgaW4gcmFuZ2UoTi8vMilcclxuIyBcdFx0aWEgPSByZXNbMippXVxyXG4jIFx0XHRpYiA9IHJlc1syKmkrMV1cclxuIyBcdFx0YSA9IHBlcnNvbnNbaWFdXHJcbiMgXHRcdGIgPSBwZXJzb25zW2liXVxyXG4jIFx0XHRsc3QgPSBbc2NvcmV4KGEpLHNjb3JleChiKV1cclxuIyBcdFx0bHN0LnNvcnQocmV2ZXJzZT1UcnVlKVxyXG4jIFx0XHRyZXN1bHQuYXBwZW5kKFtsc3QsaWEsaWJdKVxyXG4jIFx0cmVzdWx0LnNvcnQocmV2ZXJzZT1UcnVlKVxyXG5cclxuIyBcdHJlc3VsdGF0ID0gW11cclxuIyBcdGZvciBpIGluIHJhbmdlKE4vLzIpXHJcbiMgXHRcdFtfLGlhLGliXSA9IHJlc3VsdFtpXVxyXG4jIFx0XHRyZXN1bHRhdC5jb25jYXQgW2lhLGliXVxyXG4jIFx0XHQjIGEgPSBwZXJzb25zW2lhXVxyXG4jIFx0XHQjIGIgPSBwZXJzb25zW2liXVxyXG4jIFx0XHQjIHBhID0gc2NvcmV4KGEpICMgc3VtKGFbJ3Jlc3VsdCddKS8yXHJcbiMgXHRcdCMgcGIgPSBzY29yZXgoYikgIyBzdW0oYlsncmVzdWx0J10pLzJcclxuIyBcdFx0IyBwcmludCgnJyxpKzEsJyAnLHBhLGFbXCJuYW1lXCJdLCcgICAgICAgICAnLGJbXCJuYW1lXCJdLCcgJyxwYilcclxuIyBcdHJlc3VsdGF0XHJcblxyXG4jIG1vdmVBbGxCdXR0b25zID0gLT5cclxuIyBcdGJ1dHRvbnNbMl1bMF0uc2V0RXh0ZW50IG13KDk1MCksMC40NSpEWSwgbXcoNjApLDAuNTUqRFlcclxuIyBcdGJ1dHRvbnNbM11bMF0uc2V0RXh0ZW50IG13KDk1MCksMC40NSpEWSwgbXcoNjApLDAuNTUqRFlcclxuIyBcdGJ1dHRvbnNbNF1bMF0uc2V0RXh0ZW50IG13KDk1MCksMC40NSpEWSwgbXcoNjApLDAuNTUqRFlcclxuXHJcbiMgXHRmb3IgaSBpbiByYW5nZSBOLy8yXHJcbiMgXHRcdHkgPSBEWSAqIChpKzIuNSlcclxuIyBcdFx0YnV0dG9uc1szXVszKmkrMV0uc2V0RXh0ZW50IG13KDIwMCkseSwgbXcoMjAwKSwzMFxyXG4jIFx0XHRidXR0b25zWzNdWzMqaSsyXS5zZXRFeHRlbnQgbXcoNTAwKSx5LCBtdygyMDApLDMwXHJcbiMgXHRcdGJ1dHRvbnNbM11bMyppKzNdLnNldEV4dGVudCBtdyg2MDApLHksIG13KDIwMCksMzBcclxuXHJcbiMgdXBkYXRlQWxsQnV0dG9ucyA9IC0+XHJcbiMgXHRmb3IgaSBpbiByYW5nZSBOLy8yXHJcbiMgXHRcdHdoaXRlID0gcGFpcmluZ3NbMippKzBdXHJcbiMgXHRcdGJsYWNrID0gcGFpcmluZ3NbMippKzFdXHJcbiMgXHRcdGJ1dHRvbnNbM11bMyppKzFdLnByb21wdCA9IHdoaXRlLm5hbWVcclxuIyBcdFx0YnV0dG9uc1szXVszKmkrMV0uYWxpZ24gPSBMRUZUXHJcbiMgXHRcdGJ1dHRvbnNbM11bMyppKzJdLnByb21wdCA9ICctJ1xyXG4jIFx0XHRidXR0b25zWzNdWzMqaSszXS5wcm9tcHQgPSBibGFjay5uYW1lXHJcbiMgXHRcdGJ1dHRvbnNbM11bMyppKzNdLmFsaWduID0gTEVGVFxyXG5cclxuIyBjcmVhdGVBbGxCdXR0b25zID0gLT5cclxuXHJcbiMgXHRidXR0b25zID0gW1tdLFtdLFtdLFtdLFtdXVxyXG5cclxuIyBcdGJ1dHRvbnNbMl0ucHVzaCBuZXcgQnV0dG9uICduZXh0JywgJ3llbGxvdycsIC0+XHJcbiMgXHRcdHN0YXRlID0gM1xyXG4jIFx0XHRwcmludCgnc3RhdGUnLHN0YXRlKVxyXG5cclxuIyBcdFx0dXBkYXRlQWxsQnV0dG9ucygpXHJcblxyXG4jIFx0YnV0dG9uc1szXSA9IFtdXHJcbiMgXHRidXR0b25zWzNdLnB1c2ggbmV3IEJ1dHRvbiAnbmV4dCcsICd5ZWxsb3cnLCAtPlxyXG4jIFx0XHRzdGF0ZSA9IDRcclxuIyBcdFx0cHJpbnQoJ3N0YXRlJyxzdGF0ZSlcclxuXHJcbiMgXHRcdHRyYW5zZmVyUmVzdWx0KClcclxuIyBcdFx0d2luZG93UmVzaXplZCgpXHJcbiMgXHRmb3IgaSBpbiByYW5nZSBOLy8yXHJcbiMgXHRcdG4gPSBidXR0b25zWzNdLmxlbmd0aFxyXG4jIFx0XHRkbyAobikgLT5cclxuIyBcdFx0XHRidXR0b25zWzNdLnB1c2ggbmV3IEJ1dHRvbiAnd2hpdGUnLCd3aGl0ZScsICAgICAtPiBzZXRQcm9tcHQgYnV0dG9uc1szXVtuKzFdLCAnMSAtIDAnXHJcbiMgXHRcdFx0YnV0dG9uc1szXS5wdXNoIG5ldyBCdXR0b24gJy0nLCAgICAnbGlnaHRncmF5JywgLT4gc2V0UHJvbXB0IGJ1dHRvbnNbM11bbisxXSwgJ8K9IC0gwr0nXHJcbiMgXHRcdFx0YnV0dG9uc1szXS5wdXNoIG5ldyBCdXR0b24gJ2JsYWNrJywgJ2JsYWNrJywgICAgLT4gc2V0UHJvbXB0IGJ1dHRvbnNbM11bbisxXSwgJzAgLSAxJ1xyXG5cclxuIyBcdGJ1dHRvbnNbNF0ucHVzaCBuZXcgQnV0dG9uICduZXh0JywgJ3llbGxvdycsIC0+XHJcbiMgXHRcdHJlc2l6ZUNhbnZhcyB3aW5kb3dXaWR0aCwgRFkgKiAoTi8vMisyKVxyXG4jIFx0XHRzID0gY3JlYXRlVVJMKClcclxuIyBcdFx0cHJpbnQgc1xyXG4jIFx0XHRjb3B5VG9DbGlwYm9hcmQgc1xyXG4jIFx0XHRpZiByb25kIDwgUk9VTkRTLTFcclxuIyBcdFx0XHRyb25kICs9IDFcclxuIyBcdFx0XHRmb3IgcGVyc29uIGluIHBlcnNvbnNcclxuIyBcdFx0XHRcdHBlcnNvbi5zY29yZSA9IHNjb3JleCBwZXJzb25cclxuIyBcdFx0XHRwcmludCBwZXJzb25zXHJcbiMgXHRcdFx0bG90dGEoKVxyXG4jIFx0XHRcdHByaW50IHtwYWlyaW5nc31cclxuIyBcdHByaW50IFwiI3tidXR0b25zWzNdLmxlbmd0aCArIDJ9IGJ1dHRvbnMgY3JlYXRlZFwiXHJcblxyXG4jIHdpbmRvdy5tb3VzZVByZXNzZWQgPSAoZXZlbnQpIC0+XHJcbiMgXHRldmVudC5wcmV2ZW50RGVmYXVsdCgpXHJcbiMgXHRpZiBub3QgcmVsZWFzZWQgdGhlbiByZXR1cm5cclxuIyBcdHJlbGVhc2VkID0gZmFsc2VcclxuIyBcdGZvciBidXR0b24gaW4gYnV0dG9uc1tzdGF0ZV1cclxuIyBcdFx0aWYgYnV0dG9uLmluc2lkZSBtb3VzZVgsbW91c2VZIHRoZW4gYnV0dG9uLmNsaWNrKClcclxuIyBcdGZhbHNlXHJcblxyXG4jIHdpbmRvdy5tb3VzZVJlbGVhc2VkID0gKGV2ZW50KSAtPlxyXG4jIFx0ZXZlbnQucHJldmVudERlZmF1bHQoKVxyXG4jIFx0cmVsZWFzZWQgPSB0cnVlXHJcbiMgXHRmYWxzZVxyXG5cclxuIyBzZXRQcm9tcHQgPSAoYnV0dG9uLHByb21wdCkgLT4gXHJcbiMgXHRidXR0b24ucHJvbXB0ID0gaWYgYnV0dG9uLnByb21wdCA9PSBwcm9tcHQgdGhlbiAnLScgZWxzZSBwcm9tcHRcclxuIyBcdGZvciBidXR0b24gaW4gYnV0dG9uc1szXS5zbGljZSAxXHJcbiMgXHRcdGlmIGJ1dHRvbi5wcm9tcHQgPT0gJy0nXHJcbiMgXHRcdFx0YnV0dG9uc1szXVswXS5hY3RpdmUgPSBmYWxzZVxyXG4jIFx0XHRcdHJldHVyblxyXG4jIFx0YnV0dG9uc1szXVswXS5hY3RpdmUgPSB0cnVlXHJcblxyXG4jIHRyYW5zZmVyUmVzdWx0ID0gLT5cclxuIyBcdGZvciBpIGluIHJhbmdlIE4vLzJcclxuIyBcdFx0YnV0dG9uID0gYnV0dG9uc1szXVsyKzMqaV1cclxuIyBcdFx0d2hpdGUgPSB7JzEgLSAwJzogMiwnwr0gLSDCvSc6IDEsJzAgLSAxJzogMH1bYnV0dG9uLnByb21wdF1cclxuIyBcdFx0cGFpcmluZ3NbMippKzBdLnJlcyArPSBcIjAxMlwiW3doaXRlXVxyXG4jIFx0XHRwYWlyaW5nc1syKmkrMV0ucmVzICs9IFwiMDEyXCJbMi13aGl0ZV1cclxuIyBcdFx0YnV0dG9uLnByb21wdCA9ICctJ1xyXG5cclxuIyBjbGFzcyBCdXR0b25cclxuIyBcdGNvbnN0cnVjdG9yIDogKEBwcm9tcHQsQGZpbGwsQGNsaWNrKSAtPlxyXG4jIFx0XHRAYWN0aXZlID0gdHJ1ZVxyXG4jIFx0XHRAYWxpZ24gPSBDRU5URVJcclxuIyBcdHNldEV4dGVudCA6IChAeCxAeSxAdyxAaCkgLT5cclxuIyBcdGRyYXcgOiAtPlxyXG4jIFx0XHRpZiBub3QgQGFjdGl2ZSB0aGVuIHJldHVyblxyXG4jIFx0XHR0ZXh0QWxpZ24gQGFsaWduLENFTlRFUlxyXG4jIFx0XHRpZiBAcHJvbXB0ID09ICduZXh0J1xyXG4jIFx0XHRcdGZpbGwgJ2JsYWNrJ1xyXG4jIFx0XHRcdHJlY3RNb2RlIENFTlRFUlxyXG4jIFx0XHRcdHJlY3QgQHgsQHksIEB3LEBoXHJcbiMgXHRcdGZpbGwgQGZpbGxcclxuIyBcdFx0dGV4dCBAcHJvbXB0LEB4LCBAeSArIDAuNVxyXG4jIFx0aW5zaWRlIDogKG14LG15KSAtPiBAeC1Ady8yIDw9IG14IDw9IEB4K0B3LzIgYW5kIEB5LUBoLzIgPD0gbXkgPD0gQHkrQGgvMiBhbmQgQGFjdGl2ZVxyXG5cclxuIl19
//# sourceURL=c:\github\2023\044-Monrad\coffee\graveyard.coffee