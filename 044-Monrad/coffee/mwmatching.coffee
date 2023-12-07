print = console.log

maxWeightMatching = (edges, maxcardinality = false) ->

	integer_types = [Number]

	return [] unless edges.length

	nedge = edges.length
	print 'nedge',nedge
	nvertex = 0
	for [i, j, w] in edges
		nvertex = i + 1 if i >= nvertex
		nvertex = j + 1 if j >= nvertex

	print 'nvertex',nvertex

	maxweight = Math.max(0, Math.max.apply(null, (wt for [i, j, wt] in edges)))
	print 'maxweight',maxweight
	endpoint = edges[p // 2][p % 2] for p in [0...2 * nedge]
	print 'endpoint',endpoint
	neighbend = ([] for i in [0...nvertex])
	for k in [0...edges.length]
		[i, j, w] = edges[k]
		neighbend[i].push(2 * k + 1)
		neighbend[j].push(2 * k)
	print 'neighbend',neighbend
	mate = (-1 for i in [0...nvertex])
	print 'mate',mate
	label = (0 for i in [0...(2 * nvertex)])
	print 'label',label
	labelend = (-1 for i in [0...(2 * nvertex)])
	print 'labelend',labelend
	inblossom = (i for i in [0...nvertex])
	print 'inblossom',inblossom
	blossomparent = (-1 for i in [0...(2 * nvertex)])
	print 'blossomparent',blossomparent
	blossomchilds = (null for i in [0...(2 * nvertex)])
	print 'blossomchilds',blossomchilds
	blossombase = (i for i in [0...nvertex]).concat(-1 for i in [0...nvertex])
	print 'blossombase',blossombase
	blossomendps = (null for i in [0...(2 * nvertex)])
	print 'blossomendps',blossomendps
	bestedge = (-1 for i in [0...(2 * nvertex)])
	print 'bestedge',bestedge
	blossombestedges = (null for i in [0...(2 * nvertex)])
	print 'blossombestedges',blossombestedges
	unusedblossoms = (i for i in [nvertex...2 * nvertex])
	print 'unusedblossoms',unusedblossoms
	dualvar = (maxweight for i in [0...nvertex]).concat((0 for i in [0...nvertex]))
	print 'dualvar',dualvar
	allowedge = (false for i in [0...nedge])
	print 'allowedge',allowedge
	queue = []

	slack = (k) ->
		[i, j, wt] = edges[k]
		dualvar[i] + dualvar[j] - 2 * wt

	blossomLeaves = (b) ->
		if b < nvertex
			yield b
		else
			for t in blossomchilds[b]
				if t < nvertex
					yield t
				else
					yield v for v in blossomLeaves(t)

	assignLabel = (w, t, p) ->
		b = inblossom[w]
		label[w] = label[b] = t
		labelend[w] = labelend[b] = p
		bestedge[w] = bestedge[b] = -1
		if t == 1
			queue.push(v) for v in blossomLeaves(b)
		else if t == 2
			base = blossombase[b]
			assignLabel(endpoint[mate[base]], 1, mate[base] ^ 1)

	scanBlossom = (v, w) ->
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
		label[b] = 1 for b in path
		base

	addBlossom = (base, k) ->
		[v, w, wt] = edges[k]
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

		for v in blossomLeaves(b)
			queue.push(v) if label[inblossom[v]] == 2
			inblossom[v] = b

		bestedgeto = (-1 for i in [0...(2 * nvertex)])

		for bv in path
			nblists = if blossombestedges[bv] then [blossombestedges[bv]] else [[p / 2 | 0 for p in neighbend[v]] for v in blossomLeaves(bv)]

			for nblist in nblists
				for k in nblist
					[i, j, wt] = edges[k]
					[i, j] = [j, i] if inblossom[j] == b
					bj = inblossom[j]
					if bj != b and label[bj] == 1 and (bestedgeto[bj] == -1 or slack(k) < slack(bestedgeto[bj]))
						bestedgeto[bj] = k

			blossombestedges[bv] = null
			bestedge[bv] = -1

		blossombestedges[b] = (k for k in bestedgeto when k != -1)
		bestedge[b] = -1

		for k in blossombestedges[b]
			bestedge[b] = k if bestedge[b] == -1 or slack(k) < slack(bestedge[b])


	expandBlossom = (b, endstage) ->
		for s in blossomchilds[b]
			blossomparent[s] = -1
			if s < nvertex
				inblossom[s] = s
			else if endstage and dualvar[s] == 0
				expandBlossom(s, endstage)
			else
				for v in blossomLeaves(s)
					inblossom[v] = s

		if (not endstage) and label[b] == 2
			entrychild = inblossom[endpoint[labelend[b] ^ 1]]
			j = blossomchilds[b].indexOf(entrychild)
			if j & 1
				j -= len(blossomchilds[b])
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
				allowedge[blossomendps[b][j - endptrick] / 2 | 0] = true
				j += jstep
				p = blossomendps[b][j - endptrick] ^ endptrick
				allowedge[p / 2 | 0] = true
				j += jstep

			bv = blossomchilds[b][j]
			label[endpoint[p ^ 1]] = label[bv] = 2
			labelend[endpoint[p ^ 1]] = labelend[bv] = p
			bestedge[bv] = -1
			j += jstep

			while blossomchilds[b][j] != entrychild
				bv = blossomchilds[b][j]
				if label[bv] == 1
					j += jstep
					continue

				for v in blossomLeaves(bv)
					break if label[v] != 0

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
		t = v
		while blossomparent[t] != b
			t = blossomparent[t]
		if t >= nvertex
			augmentBlossom(t, v)
		i = j = blossomchilds[b].indexOf(t)
		if i & 1
			j -= len(blossomchilds[b])
			jstep = 1
			endptrick = 0
		else
			jstep = -1
			endptrick = 1
		while j != 0
			j += jstep
			t = blossomchilds[b][j]
			p = blossomendps[b][j - endptrick] ^ endptrick
			if t >= nvertex
				augmentBlossom(t, endpoint[p])
			j += jstep
			t = blossomchilds[b][j]
			if t >= nvertex
				augmentBlossom(t, endpoint[p ^ 1])
			mate[endpoint[p]] = p ^ 1
			mate[endpoint[p ^ 1]] = p
		blossomchilds[b] = blossomchilds[b].slice(i).concat(blossomchilds[b].slice(0, i))
		blossomendps[b] = blossomendps[b].slice(i).concat(blossomendps[b].slice(0, i))
		blossombase[b] = blossombase[blossomchilds[b][0]]

	augmentMatching = (k) ->
		[v, w, wt] = edges[k]
		for [s, p] in [[v, 2 * k + 1], [w, 2 * k]]
			while true
				bs = inblossom[s]
				if bs >= nvertex
					augmentBlossom(bs, s)
				mate[s] = p
				break if labelend[bs] == -1
				t = endpoint[labelend[bs]]
				bt = inblossom[t]
				s = endpoint[labelend[bt]]
				j = endpoint[labelend[bt] ^ 1]
				if bt >= nvertex
					augmentBlossom(bt, j)
				mate[j] = labelend[bt]
				p = labelend[bt] ^ 1

	# ... (rest of the functions)

	for t in [0...nvertex]

		label.fill(0)
		bestedge.fill(-1)
		blossombestedges.fill(null)
		allowedge.fill(false)
		queue = []

		for v in [0...nvertex]
			assignLabel(v, 1, -1) if mate[v] == -1 && label[inblossom[v]] == 0

		augmented = 0
		while true

			while queue.length && !augmented

				v = queue.pop()

				for p in neighbend[v]
					k = p / 2 | 0
					w = endpoint[p]
					next if inblossom[v] == inblossom[w]
					unless allowedge[k]
						kslack = slack(k)
						allowedge[k] = true if kslack <= 0
					if allowedge[k]
						if label[inblossom[w]] == 0
							assignLabel(w, 2, p ^ 1)
						else if label[inblossom[w]] == 1
							base = scanBlossom(v, w)
							if base >= 0
								addBlossom(base, k)
							else
								augmentMatching(k)
								augmented = 1
								break
						else if label[w] == 0
							label[w] = 2
							labelend[w] = p ^ 1
					else if label[inblossom[w]] == 1
						b = inblossom[v]
						bestedge[b] = k if bestedge[b] == -1 || slack(k) < slack(bestedge[b])
					else if label[w] == 0
						bestedge[w] = k if bestedge[w] == -1 || slack(k) < slack(bestedge[w])

			break if augmented

			deltatype = -1
			delta = deltaedge = deltablossom = null

			deltatype = 1
			delta = Math.min.apply(null, dualvar.slice(0, nvertex)) unless maxcardinality

			for v in [0...nvertex]
				if label[inblossom[v]] == 0 && bestedge[v] != -1
					d = slack(bestedge[v])
					if deltatype == -1 || d < delta
						delta = d
						deltatype = 2
						deltaedge = bestedge[v]

			for b in [0...(2 * nvertex)]
				if blossomparent[b] == -1 && label[b] == 1 && bestedge[b] != -1
					kslack = slack(bestedge[b])
					d = kslack / 2 if typeof kslack == "number"
					if deltatype == -1 || d < delta
						delta = d
						deltatype = 3
						deltaedge = bestedge[b]

			for b in [nvertex...(2 * nvertex)]
				if blossombase[b] >= 0 && blossomparent[b] == -1 && label[b] == 2 && (deltatype == -1 || dualvar[b] < delta)
					delta = dualvar[b]
					deltatype = 4
					deltablossom = b

			if deltatype == -1
				deltatype = 1
				delta = Math.max(0, Math.min.apply(null, dualvar.slice(0, nvertex)))

			for v in [0...nvertex]
				dualvar[v] -= delta if label[inblossom[v]] == 1
				dualvar[v] += delta if label[inblossom[v]] == 2
			for b in [nvertex...(2 * nvertex)]
				if blossombase[b] >= 0 && blossomparent[b] == -1
					dualvar[b] += delta if label[b] == 1
					dualvar[b] -= delta if label[b] == 2

			break if deltatype == 1
			allowedge[deltaedge] = true if deltatype == 2
			[i, j, wt] = edges[deltaedge]
			[i, j] = [j, i] if label[inblossom[i]] == 0
			queue.push(i) if label[inblossom[i]] == 0
			allowedge[deltaedge] = true if deltatype == 3
			[i, j, wt] = edges[deltaedge]
			queue.push(i) if deltatype == 3

			expandBlossom(deltablossom, false) if deltatype == 4

		break unless augmented

		expandBlossom(b, true) for b in [nvertex...(2 * nvertex)] when blossomparent[b] == -1 && blossombase[b] >= 0 && label[b] == 1 && dualvar[b] == 0

	mate[v] = endpoint[mate[v]] for v in [0...nvertex] if mate[v] >= 0

	mate
