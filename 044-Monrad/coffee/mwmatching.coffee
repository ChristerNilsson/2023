# print = console.log

range = _.range

lines = []

print = (_a,_b='',_c='',_d='',_e='',_f='') ->
	_s = _a + ' :'
	if _b!='' then _s += ' ' + JSON.stringify(_b)
	if _c!='' then _s += ' ' + JSON.stringify(_c)
	if _d!='' then _s += ' ' + JSON.stringify(_d)
	if _e!='' then _s += ' ' + JSON.stringify(_e)
	if _f!='' then _s += ' ' + JSON.stringify(_f)
	console.log _s
	lines.push _s + "\n"

ass = (a,b) ->
	if _.isEqual(a,b)
		console.log ''
		console.log a
		console.log b,'ok'
	else
		console.log ''
		console.log a
		console.log b,'assert failure'

export maxWeightMatching = (edges, maxcardinality = false) ->

	return [] unless edges.length

	nedge = edges.length
	nvertex = 0
	for [_i, _j, _w] in edges
		nvertex = _i + 1 if _i >= nvertex
		nvertex = _j + 1 if _j >= nvertex

	maxweight = Math.max 0, _.max (wt for [_i, _j, wt] in edges)
	endpoint = (edges[_i // 2][_i % 2] for _i in range 2 * nedge)
	neighbend = ([] for _i in range nvertex)
	for _k in range edges.length
		[_i, _j, _w] = edges[_k]
		neighbend[_i].push 2 * _k + 1
		neighbend[_j].push 2 * _k
	mate = (-1 for _i in range nvertex)
	label = (0 for _i in range 2 * nvertex)
	labelend = (-1 for _i in range 2 * nvertex)
	inblossom = (_i for _i in range nvertex)
	blossomparent = (-1 for _i in range 2 * nvertex)
	blossomchilds = (null for _i in range 2 * nvertex)
	blossombase = (_i for _i in range nvertex).concat(-1 for _j in range nvertex)
	blossomendps = (null for _i in range 2 * nvertex)
	bestedge = (-1 for _i in range 2 * nvertex)
	blossombestedges = (null for _i in range 2 * nvertex)
	unusedblossoms = (_i for _i in range nvertex, 2 * nvertex)
	dualvar = (maxweight for _i in range nvertex).concat(0 for _j in range nvertex)
	allowedge = (false for _i in range nedge)
	queue = []

	dump = () ->
		print 'nedge',nedge
		print 'edges',edges
		print 'nvertex',nvertex
		print 'maxweight',maxweight
		print 'endpoint',endpoint
		print 'neighbend',neighbend
		print 'mate',mate
		print 'label',label
		print 'labelend',labelend
		print 'inblossom',inblossom
		print 'blossomparent',blossomparent
		print 'blossomchilds',blossomchilds
		print 'blossombase',blossombase
		print 'blossomendps',blossomendps
		print 'bestedge',bestedge
		print 'blossombestedges',blossombestedges
		print 'unusedblossoms',unusedblossoms
		print 'dualvar',dualvar
		print 'allowedge',allowedge
		print 'queue',queue

	dump()
	
	slack = (k) ->
		[i, j, wt] = edges[k]
		res = dualvar[i] + dualvar[j] - 2 * wt
		print('slack k i j wt res',k,i,j,wt,res)
		res

	blossomLeaves = (b) ->
		print 'blossomLeaves b',b
		if b < nvertex
			yield b
		else
			# print('blossomLeaves length b',blossomchilds.length,b)
			for t in blossomchilds[b]
				# print('blossomLeaves t',t)
				if t < nvertex
					yield t
				else
					for v from blossomLeaves(t)
						yield v

	assignLabel = (w, t, p) ->
		print 'assignLabel w t p',w,t,p
		b = inblossom[w]
		label[w] = label[b] = t
		labelend[w] = labelend[b] = p
		bestedge[w] = bestedge[b] = -1
		if t == 1
			#print 'assignLabel b',b
			for v from blossomLeaves(b)  # OBS: "from" behövs pga generator!
				queue.push(v)
		else if t == 2
			base = blossombase[b]
			assignLabel(endpoint[mate[base]], 1, mate[base] ^ 1)

	scanBlossom = (v, w) ->
		print 'scanBlossom v w',v,w
		path = []
		base = -1
		while v != -1 or w != -1
			b = inblossom[v]
			if label[b] & 4
				base = blossombase[b]
				break
			path.push(b)
			label[b] = 5
			if labelend[b] == -1
				v = -1
			else
				v = endpoint[labelend[b]]
				b = inblossom[v]
				v = endpoint[labelend[b]]
			if w != -1
				[v, w] = [w, v]
		for b in path
			label[b] = 1
		base

	addBlossom = (base, k) ->
		[v, w, wt] = edges[k]
		print 'addBlossom base k v w wt',base,k,v,w,wt
		bb = inblossom[base]
		bv = inblossom[v]
		bw = inblossom[w]
		b = unusedblossoms.pop()
		blossombase[b] = base
		blossomparent[b] = -1
		blossomparent[bb] = b
		blossomchilds[b] = path = []
		blossomendps[b] = endps = []

		while bv != bb
			blossomparent[bv] = b
			path.push(bv)
			endps.push(labelend[bv])
			v = endpoint[labelend[bv]]
			bv = inblossom[v]

		path.push(bb)
		path.reverse()
		endps.reverse()
		endps.push(2 * k)

		while bw != bb
			blossomparent[bw] = b
			path.push(bw)
			endps.push(labelend[bw] ^ 1)
			w = endpoint[labelend[bw]]
			bw = inblossom[w]

		label[b] = 1
		labelend[b] = labelend[bb]
		dualvar[b] = 0

		#print 'addBlossom b',b
		for v from blossomLeaves(b)
			if label[inblossom[v]] == 2
				queue.push(v) 
			inblossom[v] = b

		bestedgeto = (-1 for i in range 2 * nvertex)

		for bv in path
			if blossombestedges[bv] == null
				#print 'addBlossom bv',bv
				nblists = ((p // 2 for p in neighbend[v]) for v from blossomLeaves(bv))
			else
				nblists = [blossombestedges[bv]]

			for nblist in nblists
				for k in nblist
					[i, j, wt] = edges[k]
					if inblossom[j] == b
						[i, j] = [j, i] 
					bj = inblossom[j]
					if bj != b and label[bj] == 1 and (bestedgeto[bj] == -1 or slack(k) < slack(bestedgeto[bj]))
						bestedgeto[bj] = k

			blossombestedges[bv] = null
			bestedge[bv] = -1

		blossombestedges[b] = (k for k in bestedgeto when k != -1)
		bestedge[b] = -1

		for k in blossombestedges[b]
			if bestedge[b] == -1 or slack(k) < slack(bestedge[b])
				bestedge[b] = k

	expandBlossom = (b, endstage) ->
		print 'expandBlossom b endstage',b,endstage
		for s in blossomchilds[b]
			blossomparent[s] = -1
			if s < nvertex
				inblossom[s] = s
			else if endstage and dualvar[s] == 0
				expandBlossom(s, endstage)
			else
				#print 'expandBlossom s',s
				for v from blossomLeaves(s)
					inblossom[v] = s

		if (not endstage) and label[b] == 2
			entrychild = inblossom[endpoint[labelend[b] ^ 1]]
			j = blossomchilds[b].indexOf(entrychild)
			if j & 1
				j -= blossomchilds[b].length
				jstep = 1
				endptrick = 0
			else
				jstep = -1
				endptrick = 1

			p = labelend[b]
			while j != 0
				label[endpoint[p ^ 1]] = 0
				label[endpoint[blossomendps[b][j - endptrick] ^ endptrick ^ 1]] = 0
				assignLabel(endpoint[p ^ 1], 2, p)
				allowedge[blossomendps[b][j - endptrick] // 2] = true
				j += jstep
				p = blossomendps[b][j - endptrick] ^ endptrick
				allowedge[p // 2] = true
				j += jstep

			bv = blossomchilds[b][j]
			label[endpoint[p ^ 1]] = label[bv] = 2
			labelend[endpoint[p ^ 1]] = labelend[bv] = p
			bestedge[bv] = -1
			j += jstep

			n = blossomchilds[b].length
			#print('expandBlossom j',j)
			while blossomchilds[b][j %% n] != entrychild
				bv = blossomchilds[b][j %% n]
				if label[bv] == 1
					j += jstep
					continue
				#print 'expandBlossom bv',bv
				for v from blossomLeaves(bv)
					if label[v] != 0
						break

				if label[v] != 0
					label[v] = 0
					label[endpoint[mate[blossombase[bv]]]] = 0
					assignLabel(v, 2, labelend[v])

				j += jstep

		label[b] = labelend[b] = -1
		blossomchilds[b] = blossomendps[b] = null
		blossombase[b] = -1
		blossombestedges[b] = null
		bestedge[b] = -1
		unusedblossoms.push(b)

	augmentBlossom = (b, v) ->
		print 'augmentBlossom b v',b,v 
		print('endpoint',endpoint)
		print('blossomendps',blossomendps)  
		print('blossomchilds',blossomchilds)
		t = v
		while blossomparent[t] != b
			t = blossomparent[t]
		if t >= nvertex
			augmentBlossom(t, v)
		i = j = blossomchilds[b].indexOf(t)
		if i & 1
			j -= blossomchilds[b].length
			jstep = 1
			endptrick = 0
		else
			jstep = -1
			endptrick = 1
		print('i j jstep endptrick',i,j,jstep,endptrick)
		while j != 0
			j += jstep
			n = blossomchilds[b].length
			t = blossomchilds[b][(n+j) %% n]
			_p = blossomendps[b][(n+j - endptrick) %% n] ^ endptrick
			print('p',_p)
			if t >= nvertex
				augmentBlossom(t, endpoint[_p])
			j += jstep
			t = blossomchilds[b][(n+j) %% n]
			if t >= nvertex
				augmentBlossom(t, endpoint[_p ^ 1])
			print('mate p p^1',mate,_p,_p^1)
			print('endpoint p',endpoint[_p],_p)
			mate[endpoint[_p]] = _p ^ 1
			mate[endpoint[_p ^ 1]] = _p
			print('mate', mate) #mate[endpoint[p]],   endpoint[p],   p)
			#print('mate endpoint p^1', mate[endpoint[p^1]], endpoint[p^1], p^1)

		blossomchilds[b] = blossomchilds[b].slice(i).concat(blossomchilds[b].slice(0, i))
		blossomendps[b] = blossomendps[b].slice(i).concat(blossomendps[b].slice(0, i))
		blossombase[b] = blossombase[blossomchilds[b][0]]

		print('blossomchilds',blossomchilds)
		print('blossomendps',blossomendps)
		print('blossombase',blossombase)

	augmentMatching = (k) ->
		[v, w, wt] = edges[k]
		print 'augmentMatching k v w wt',k,v,w,wt
		print('labelend',labelend)
		print('inblossom',inblossom)
		for [s, p] in [[v, 2 * k + 1], [w, 2 * k]]
			print('s p',s,p)
			while true
				bs = inblossom[s]
				print('bs',bs)
				if bs >= nvertex
					augmentBlossom(bs, s)
				mate[s] = p
				print('s mate[s]',s,mate[s])
				if labelend[bs] == -1
					print('break')
					break
				t = endpoint[labelend[bs]]
				bt = inblossom[t]
				s = endpoint[labelend[bt]]
				j = endpoint[labelend[bt] ^ 1]
				if bt >= nvertex
					augmentBlossom(bt, j)
				mate[j] = labelend[bt]
				print('j mate[j]',j,mate[j])
				p = labelend[bt] ^ 1
				print('p2',p)
		print('mate',mate)

	for t in range nvertex

		label = (0 for item in range 2*nvertex)
		bestedge = (-1 for item in range 2*nvertex)
		blossombestedges[nvertex..] = (null for item in range nvertex)
		allowedge= (false for item in range nedge)
		queue = []

		for v in range nvertex
			if mate[v] == -1 and label[inblossom[v]] == 0
				assignLabel(v, 1, -1)

		augmented = false
		while true

			while queue.length > 0 and not augmented
				v = queue.pop()

				for p in neighbend[v]
					k = p // 2
					w = endpoint[p]
					if inblossom[v] == inblossom[w]
						continue
					if not allowedge[k]
						kslack = slack(k)
						if kslack <= 0
							allowedge[k] = true
					if allowedge[k]
						if label[inblossom[w]] == 0
							assignLabel(w, 2, p ^ 1)
						else if label[inblossom[w]] == 1
							base = scanBlossom(v, w)
							if base >= 0
								addBlossom(base, k)
							else
								augmentMatching(k)
								augmented = true
								break
						else if label[w] == 0
							label[w] = 2
							labelend[w] = p ^ 1
					else if label[inblossom[w]] == 1
						b = inblossom[v]
						if bestedge[b] == -1 or kslack < slack(bestedge[b])
							bestedge[b] = k
					else if label[w] == 0
						if bestedge[w] == -1 or kslack < slack(bestedge[w])
							bestedge[w] = k 

			if augmented then break

			deltatype = -1
			delta = deltaedge = deltablossom = null

			if not maxcardinality
				deltatype = 1
				delta = _.min dualvar.slice 0, nvertex

			for v in range nvertex
				if label[inblossom[v]] == 0 and bestedge[v] != -1
					d = slack(bestedge[v])
					if deltatype == -1 or d < delta
						delta = d
						deltatype = 2
						deltaedge = bestedge[v]

			for b in range 2 * nvertex
				if blossomparent[b] == -1 and label[b] == 1 and bestedge[b] != -1
					kslack = slack(bestedge[b])
					d = kslack // 2
					if deltatype == -1 or d < delta
						delta = d
						deltatype = 3
						deltaedge = bestedge[b]

			for b in range nvertex, 2 * nvertex
				if blossombase[b] >= 0 and blossomparent[b] == -1 and label[b] == 2 and (deltatype == -1 or dualvar[b] < delta)
					delta = dualvar[b]
					deltatype = 4
					deltablossom = b

			if deltatype == -1
				deltatype = 1
				delta = Math.max 0, _.min dualvar.slice 0, nvertex

			for v in range nvertex
				if label[inblossom[v]] == 1
					dualvar[v] -= delta
				if label[inblossom[v]] == 2
					dualvar[v] += delta 

			for b in range nvertex, 2 * nvertex
				if blossombase[b] >= 0 and blossomparent[b] == -1
					if label[b] == 1
						dualvar[b] += delta
					if label[b] == 2
						dualvar[b] -= delta

			if deltatype == 1
				break
			else if deltatype == 2
				allowedge[deltaedge] = true
				[i, j, wt] = edges[deltaedge]
				if label[inblossom[i]] == 0
					[i, j] = [j, i]
				queue.push(i)
			else if deltatype == 3 
				allowedge[deltaedge] = true
				[i, j, wt] = edges[deltaedge]
				queue.push(i) 
			else if deltatype == 4
				expandBlossom(deltablossom, false)

		if not augmented
			break

		for b in range nvertex, 2 * nvertex
			if blossomparent[b] == -1 and blossombase[b] >= 0 and label[b] == 1 and dualvar[b] == 0
				expandBlossom b, true

	print 'mate',mate
	print 'endpoint',endpoint
	for v in range nvertex
		if mate[v] >= 0
			mate[v] = endpoint[mate[v]]

	#ass mate,[-1,2,1,4,3]

	saveAs new File lines, "javascript.txt", {type: "text/plain;charset=utf-8"}

	mate

