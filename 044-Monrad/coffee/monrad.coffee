class Monrad

	lotta : () ->

		print 'Lottning av rond ',@round
		document.title = 'Round ' + (@round+1)
		print @players
		for p in @players
			if p.res.length != p.col.length
				print 'avbrutet!'
				return

		if @round == 0
			@pairings = @players
			print 'Apairings',@pairings
			@round = 1
		else

			timestamp = new Date().toLocaleString 'se-SE'
			print "lotta ROUND",@round
			print 'tournament',tournament
			downloadFile tournament.makeTableFile(" for " + @name + " in Round #{@round}    #{timestamp}"), @name + " Round #{@round}.txt"
			downloadFile @createURL(), "URL for " + @name + " Round #{@round}.txt"

			@round += 1

#			@pairings = _.sortBy @players, (player) -> [player.score(), -player.elo]
			@pairings = _.sortBy @players, (player) -> [-player.elo]

			if @round % 2 == 0 then @pairings = @pairings.reverse()
			start = new Date()

			@pairings = @pair @pairings
			print 'Bpairings',@pairings
			print @round, "#{new Date() - start} milliseconds"

		#colorize @pairings
		#assignColors @pairings

		@adjustForColors()

		for i in range N//2
			a = @pairings[2*i]
			b = @pairings[2*i+1]
			a.opp.push b.id
			b.opp.push a.id
			#a.res += ' '
			#b.res += ' '
			@assignColors a,b

		state = 0

		print {'pairings after pairing', @pairings}

		xdraw()

	flip : (p0,p1) -> # p0 byter färg, p0 anpassar sig
		print 'flip',p0.col,p1.col
		col0 = _.last p0.col
		col1 = col0
		col0 = other col0
		p0.col += col0
		p1.col += col1

	assignColors : (p0,p1) ->
		if p0.col.length == 0
			col1 = @first[p0.id % 2]
			col0 = other col1
			p0.col += col0
			p1.col += col1
		else
			balans = p0.balans() + p1.balans()
			if balans == 0 then @flip p0,p1
			else if 2 == abs balans
				if 2 == abs p0.balans() then @flip p0,p1 else @flip p1,p0

	pair : (persons, pairing=[]) ->
		if pairing.length == N then return pairing
		a  = persons[0]
		for b in persons
			if not ok a,b then continue
			newPersons = (p for p in persons when p not in [a,b])
			newPairing = pairing.concat [a,b]
			result = @pair newPersons,newPairing
			if result.length == N then return result
		return []

	adjustForColors : () ->
		print 'adjustForColors',N, @pairings.length
		res = []
		for i in range N//2

			if @pairings[2*i].col.length == 0
				if i % 2==0 
					res.push @pairings[2*i+1] # w
					res.push @pairings[2*i] # b
				else
					res.push @pairings[2*i] # w
					res.push @pairings[2*i+1] # b
			else if 'w' == _.last @pairings[2*i].col
				res.push @pairings[2*i] # w
				res.push @pairings[2*i+1] # b
			else
				res.push @pairings[2*i+1] # w
				res.push @pairings[2*i] # b

			# if @pairings[2*i].col.length == 0 or 'w' == _.last @pairings[2*i].col
			# 	res.push @pairings[2*i] # w
			# 	res.push @pairings[2*i+1] # b
			# else
			# 	res.push @pairings[2*i+1] # w
			# 	res.push @pairings[2*i] # b

		@pairings = res
