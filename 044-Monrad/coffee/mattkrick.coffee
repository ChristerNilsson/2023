range = _.range

export class Edmonds
	constructor : (@edges, @maxCardinality=true) ->
		@nEdge = @edges.length
		@nVertexInit()
		@maxWeightInit()
		@endpointInit()
		@neighbendInit()
		@mate = filledArray(@nVertex, -1)
		@label = filledArray(2 * @nVertex, 0) #remove?
		@labelEnd = filledArray(2 * @nVertex, -1)
		@inBlossomInit()
		@blossomParent = filledArray(2 * @nVertex, -1)
		@blossomChilds = initArrArr(2 * @nVertex)
		@blossomBaseInit()
		@blossomEndPs = initArrArr(2 * @nVertex)
		@bestEdge = filledArray(2 * @nVertex, -1) #remove?
		@blossomBestEdges = initArrArr(2 * @nVertex) #remove?
		@unusedBlossomsInit()
		@dualVarInit()
		@allowEdge = filledArray(@nEdge, false) #remove?
		@queue = [] #remove?
	
	maxWeightMatching : ->
		for t in range @nVertex
			@label = filledArray(2 * @nVertex, 0)
			@bestEdge = filledArray(2 * @nVertex, -1)
			@blossomBestEdges = initArrArr(2 * @nVertex)
			@allowEdge = filledArray(@nEdge, false)
			@queue = []
			for v in range @nVertex 
				if @mate[v] == -1 and @label[@inBlossom[v]] == 0 then @assignLabel v, 1, -1
			augmented = false
			while true
				while @queue.length > 0 and !augmented
					v = @queue.pop()
					for ii in range @neighbend[v].length
						p = @neighbend[v][ii]
						k = ~~(p / 2)
						w = @endpoint[p]
						if @inBlossom[v] == @inBlossom[w] then continue
						if !@allowEdge[k]
							kSlack = @slack(k)
							if kSlack <= 0 then @allowEdge[k] = true
						
						if @allowEdge[k]
							if @label[@inBlossom[w]] == 0 then @assignLabel(w, 2, p ^ 1)
							else if @label[@inBlossom[w]] == 1
								base = @scanBlossom(v, w)
								if base >= 0 then @addBlossom(base, k)
								else 
									@augmentMatching(k)
									augmented = true
									break
								
							else if @label[w] == 0
								@label[w] = 2
								@labelEnd[w] = p ^ 1
							
						else if @label[@inBlossom[w]] == 1
							b = @inBlossom[v]
							if @bestEdge[b] == -1 or kSlack < @slack(@bestEdge[b]) then @bestEdge[b] = k
							
						else if @label[w] == 0
							if @bestEdge[w] == -1 or kSlack < @slack(@bestEdge[w]) then @bestEdge[w] = k
				if augmented then break
				deltaType = -1
				delta = []
				deltaEdge = []
				deltaBlossom = []
				if !@maxCardinality
					deltaType = 1
					delta = getMin(@dualVar, 0, @nVertex - 1)
				
				for v in range @nVertex
					if @label[@inBlossom[v]] == 0  and  @bestEdge[v] != -1
						d = @slack(@bestEdge[v])
						if deltaType == -1 or d < delta
							delta = d
							deltaType = 2
							deltaEdge = @bestEdge[v]

				for b in range 2 * @nVertex
					if @blossomParent[b] == -1  and  @label[b] == 1  and  @bestEdge[b] != -1
						kSlack = @slack(@bestEdge[b])
						d = kSlack / 2
						if deltaType == -1 or d < delta
							delta = d
							deltaType = 3
							deltaEdge = @bestEdge[b]

				for b in range @nVertex, @nVertex * 2
					if @blossomBase[b] >= 0  and  @blossomParent[b] == -1  and  @label[b] == 2  and  (deltaType == -1 or @dualVar[b] < delta)
						delta = @dualVar[b]
						deltaType = 4
						deltaBlossom = b

				if deltaType == -1
					deltaType = 1
					delta = Math.max(0, getMin(@dualVar, 0, @nVertex - 1))

				for v in range @nVertex
					curLabel = @label[@inBlossom[v]]
					if curLabel == 1 then @dualVar[v] -= delta
					else if curLabel == 2 then @dualVar[v] += delta
					
				for b in range @nVertex,@nVertex * 2
					if @blossomBase[b] >= 0  and  @blossomParent[b] == -1
						if @label[b] == 1 then @dualVar[b] += delta
						else if @label[b] == 2 then @dualVar[b] -= delta

				if deltaType == 1 then break
				else if deltaType == 2
					@allowEdge[deltaEdge] = true
					i = @edges[deltaEdge][0]
					j = @edges[deltaEdge][1]
					wt = @edges[deltaEdge][2]
					if @label[@inBlossom[i]] == 0
						i = i ^ j
						j = j ^ i
						i = i ^ j

					@queue.push(i)
				else if deltaType == 3
					@allowEdge[deltaEdge] = true
					i = @edges[deltaEdge][0]
					j = @edges[deltaEdge][1]
					wt = @edges[deltaEdge][2]
					@queue.push(i)
				else if deltaType == 4
					@expandBlossom(deltaBlossom, false)

			if !augmented then break
			for b in range @nVertex, @nVertex * 2
				if @blossomParent[b] == -1 and @blossomBase[b] >= 0 and @label[b] == 1 and @dualVar[b] == 0
					@expandBlossom(b, true)

		for v in range @nVertex
			if @mate[v] >= 0 then @mate[v] = @endpoint[@mate[v]]

		return @mate
	
	slack : (k) ->
		i = @edges[k][0]
		j = @edges[k][1]
		wt = @edges[k][2]
		return @dualVar[i] + @dualVar[j] - 2 * wt
	
	blossomLeaves : (b) ->
		if b < @nVertex then return [b]
		
		leaves = []
		childList = @blossomChilds[b]
		for t in range childList.length
			if childList[t] <= @nVertex
				leaves.push(childList[t])
			else
				leafList = @blossomLeaves(childList[t])
				for v in range leafList.length
					leaves.push(leafList[v])

		return leaves
	
	assignLabel : (w, t, p) ->
		b = @inBlossom[w]
		@label[w] = @label[b] = t
		@labelEnd[w] = @labelEnd[b] = p
		@bestEdge[w] = @bestEdge[b] = -1
		if t == 1
			@queue.push.apply(@queue, @blossomLeaves(b))
		else if t == 2
			base = @blossomBase[b]
			@assignLabel(@endpoint[@mate[base]], 1, @mate[base] ^ 1)
	
	scanBlossom : (v, w) ->
		path = []
		base = -1
		while v != -1 or w != -1
			b = @inBlossom[v]
			if @label[b] & 4
				base = @blossomBase[b]
				break
			path.push(b)
			@label[b] = 5
			if @labelEnd[b] == -1 then v = -1
			else
				v = @endpoint[@labelEnd[b]]
				b = @inBlossom[v]
				v = @endpoint[@labelEnd[b]]
			if w != -1
				v = v ^ w
				w = w ^ v
				v = v ^ w

		for ii in range path.length
			b = path[ii]
			@label[b] = 1
		return base
	
	addBlossom : (base, k) ->
		v = @edges[k][0]
		w = @edges[k][1]
		wt = @edges[k][2]
		bb = @inBlossom[base]
		bv = @inBlossom[v]
		bw = @inBlossom[w]
		b = @unusedBlossoms.pop()
		@blossomBase[b] = base
		@blossomParent[b] = -1
		@blossomParent[bb] = b
		path = @blossomChilds[b] = []
		endPs = @blossomEndPs[b] = []
		while bv != bb
			@blossomParent[bv] = b
			path.push(bv)
			endPs.push(@labelEnd[bv])
			v = @endpoint[@labelEnd[bv]]
			bv = @inBlossom[v]
		
		path.push(bb)
		path.reverse()
		endPs.reverse()
		endPs.push((2 * k))
		while bw != bb
			@blossomParent[bw] = b
			path.push(bw)
			endPs.push(@labelEnd[bw] ^ 1)
			w = @endpoint[@labelEnd[bw]]
			bw = @inBlossom[w]
		
		@label[b] = 1
		@labelEnd[b] = @labelEnd[bb]
		@dualVar[b] = 0
		leaves = @blossomLeaves(b)
		for ii in range leaves.length
			v = leaves[ii]
			if @label[@inBlossom[v]] == 2 then @queue.push(v)
			@inBlossom[v] = b
		bestEdgeTo = filledArray(2 * @nVertex, -1)
		for ii in range path.length
			bv = path[ii]
			if @blossomBestEdges[bv].length == 0
				nbLists = []
				leaves = @blossomLeaves(bv)
				for x in range leaves.length
					v = leaves[x]
					nbLists[x] = []
					for y in range @neighbend[v].length
						p = @neighbend[v][y]
						nbLists[x].push(~~(p / 2))
			else
				nbLists = [@blossomBestEdges[bv]]
			for x in range nbLists.length
				nbList = nbLists[x]
				for y in range nbList.length
					k = nbList[y]
					i = @edges[k][0]
					j = @edges[k][1]
					wt = @edges[k][2]
					if @inBlossom[j] == b
						i = i ^ j
						j = j ^ i
						i = i ^ j
					bj = @inBlossom[j]
					if bj != b and @label[bj] == 1 and (bestEdgeTo[bj] == -1 or @slack(k) < @slack(bestEdgeTo[bj]))
						bestEdgeTo[bj] = k

			@blossomBestEdges[bv] = []
			@bestEdge[bv] = -1

		be = []
		for ii in range bestEdgeTo.length
			k = bestEdgeTo[ii]
			if k != -1 then be.push(k)

		@blossomBestEdges[b] = be
		@bestEdge[b] = -1
		for ii in @blossomBestEdges[b].length
			k = @blossomBestEdges[b][ii]
			if @bestEdge[b] == -1 or @slack(k) < @slack(@bestEdge[b]) then @bestEdge[b] = k
	
	expandBlossom : (b, endStage) ->
		for ii in range @blossomChilds[b].length
			s = @blossomChilds[b][ii]
			@blossomParent[s] = -1
			if s < @nVertex
				@inBlossom[s] = s
			else if endStage  and  @dualVar[s] == 0
				@expandBlossom(s, endStage)
			else
				leaves = @blossomLeaves(s)
				for jj in range leaves.length
					v = leaves[jj]
					@inBlossom[v] = s

		if !endStage  and  @label[b] == 2
			entryChild = @inBlossom[@endpoint[@labelEnd[b] ^ 1]]
			j = @blossomChilds[b].indexOf(entryChild)
			if j & 1
				j -= @blossomChilds[b].length
				jStep = 1
				endpTrick = 0
			else
				jStep = -1
				endpTrick = 1

			p = @labelEnd[b]
			while j != 0
				@label[@endpoint[p ^ 1]] = 0
				@label[@endpoint[pIndex(@blossomEndPs[b], j - endpTrick) ^ endpTrick ^ 1]] = 0
				@assignLabel(@endpoint[p ^ 1], 2, p)
				@allowEdge[~~(pIndex(@blossomEndPs[b], j - endpTrick) / 2)] = true
				j += jStep
				p = pIndex(@blossomEndPs[b], j - endpTrick) ^ endpTrick
				@allowEdge[~~(p / 2)] = true
				j += jStep
			
			bv = pIndex(@blossomChilds[b], j)
			@label[@endpoint[p ^ 1]] = @label[bv] = 2
	
			@labelEnd[@endpoint[p ^ 1]] = @labelEnd[bv] = p
			@bestEdge[bv] = -1
			j += jStep
			while pIndex(@blossomChilds[b], j) != entryChild
				bv = pIndex(@blossomChilds[b], j)
				if @label[bv] == 1
					j += jStep
					continue

				leaves = @blossomLeaves(bv)
				for ii in range leaves.length
					v = leaves[ii]
					if @label[v] != 0 then break

				if @label[v] != 0
					@label[v] = 0
					@label[@endpoint[@mate[@blossomBase[bv]]]] = 0
					@assignLabel(v, 2, @labelEnd[v])
				j += jStep

		@label[b] = @labelEnd[b] = -1
		@blossomEndPs[b] = @blossomChilds[b] = []
		@blossomBase[b] = -1
		@blossomBestEdges[b] = []
		@bestEdge[b] = -1
		@unusedBlossoms.push(b)
	
	augmentBlossom : (b, v) ->
		t = v
		while @blossomParent[t] != b
			t = @blossomParent[t]

		if t > @nVertex then @augmentBlossom(t, v)

		i = j = @blossomChilds[b].indexOf(t)
		if i & 1
			j -= @blossomChilds[b].length
			jStep = 1
			endpTrick = 0
		else
			jStep = -1
			endpTrick = 1
		while j != 0
			j += jStep
			t = pIndex(@blossomChilds[b], j)
			p = pIndex(@blossomEndPs[b], j - endpTrick) ^ endpTrick
			if t >= @nVertex then @augmentBlossom(t, @endpoint[p])
			
			j += jStep
			t = pIndex(@blossomChilds[b], j)
			if t >= @nVertex then @augmentBlossom(t, @endpoint[p ^ 1])
			
			@mate[@endpoint[p]] = p ^ 1
			@mate[@endpoint[p ^ 1]] = p

		@blossomChilds[b] = @blossomChilds[b].slice(i).concat(@blossomChilds[b].slice(0, i))
		@blossomEndPs[b] = @blossomEndPs[b].slice(i).concat(@blossomEndPs[b].slice(0, i))
		@blossomBase[b] = @blossomBase[@blossomChilds[b][0]]
	
	augmentMatching : (k) ->
		v = @edges[k][0]
		w = @edges[k][1]
		for ii in range 2
			if ii == 0
				s = v
				p = 2 * k + 1
			else
				s = w
				p = 2 * k
			while true
				bs = @inBlossom[s]
				if bs >= @nVertex then @augmentBlossom(bs, s)
				@mate[s] = p
				if @labelEnd[bs] == -1 then break
				t = @endpoint[@labelEnd[bs]]
				bt = @inBlossom[t]
				s = @endpoint[@labelEnd[bt]]
				j = @endpoint[@labelEnd[bt] ^ 1]
				if bt >= @nVertex then @augmentBlossom(bt, j)
				@mate[j] = @labelEnd[bt]
				p = @labelEnd[bt] ^ 1
		
	blossomBaseInit : () ->
		base = []
		for i in range @nVertex
			base[i] = i
		negs = filledArray(@nVertex, -1)
		@blossomBase = base.concat(negs)

	dualVarInit : () ->
		mw = filledArray(@nVertex, @maxWeight)
		zeros = filledArray(@nVertex, 0)
		@dualVar = mw.concat(zeros)

	unusedBlossomsInit : () ->
		unusedBlossoms = []
		for i in range @nVertex,2 * @nVertex
			unusedBlossoms.push(i)

		@unusedBlossoms = unusedBlossoms

	inBlossomInit : () ->
		inBlossom = []
		for i in range @nVertex
			inBlossom[i] = i
		@inBlossom = inBlossom

	neighbendInit : () ->
		neighbend = initArrArr(@nVertex)
		for k in range @nEdge
			i = @edges[k][0]
			j = @edges[k][1]
			neighbend[i].push(2 * k + 1)
			neighbend[j].push(2 * k)

		@neighbend = neighbend

	endpointInit :() ->
		endpoint = []
		for p in range 2 * @nEdge
			endpoint[p] = @edges[~~(p / 2)][p % 2]

		@endpoint = endpoint

	nVertexInit : () ->
		nVertex = 0
		for k in range @nEdge
			i = @edges[k][0]
			j = @edges[k][1]
			if i >= nVertex then nVertex = i + 1
			if j >= nVertex then nVertex = j + 1

		@nVertex = nVertex

	maxWeightInit : () ->
		maxWeight = 0
		for k in range @nEdge
			weight = @edges[k][2]
			if weight > maxWeight then maxWeight = weight

		@maxWeight = maxWeight
	
	# HELPERS #
	filledArray = (len, fill) ->
		newArray = []
		for i in range len
			newArray[i] = fill
		return newArray
	
	initArrArr = (len) ->
		arr = []
		for i in range len 
			arr[i] = []
		return arr
	
	getMin = (arr, start, end) ->
		min = Infinity
		for i in range start,end+1
			if arr[i] < min then min = arr[i]
		return min
	
	pIndex = (arr, idx) ->
		if idx < 0 then arr[arr.length + idx] else arr[idx]
