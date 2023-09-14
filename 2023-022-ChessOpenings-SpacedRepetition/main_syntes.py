import time
import json
import chess.pgn
from os import scandir

# Läser ett antal pgn-filer, som kan innehålla flera partier.
# Skapar tree.json med antal partier
# Skapar arr.json med antal level, partier samt parent

CUTOFF = 5 # min antal partier för att spara ett drag
MAX_MOVES = 32

board = None
filename = ""

def propagate(tree):
	for key in tree:
		if key == 'n': continue
		propagate(tree[key])
		if len(tree[key]) == 1: # dvs bara n, inga drag
			tree['n'] += 1
		else:
			tree['n'] += tree[key]['n']

def prune(tree,n):
	for key in list(tree.keys()):
		if key == 'n': continue
		prune(tree[key], n)
		if tree[key]['n'] < n:
			del tree[key]

def maxDepth(tree):
	res = 0
	for key in tree:
		if key != 'n': res = max(res, maxDepth(tree[key]))
	return res + 1

def countNodes(tree):
	res = 1
	for key in tree:
		if key != 'n':
			res += countNodes(tree[key])
	return res

def traversePGN(node,t,level=0):
	if len(node.variations) > 1: print("node.variations > 1")
	if level == MAX_MOVES: return
	for variation in node.variations:
		key = variation.move.uci()
		board.push(variation.move)
		if key not in t:
			t[key] = {'n':0}
		traversePGN(variation,t[key],level+1)
		board.pop()

def readPGN(namn):
	global filename
	filename = namn
	start = time.time()
	pgn = open('original/lichess_elite_' + filename + '.pgn')
	for i in range(1000000):
		game = chess.pgn.read_game(pgn)
		if game == None: break
		if 'abandoned' in game.headers['Termination']: continue
		#print(i,game.headers['White'],'-',game.headers['Black'])
		traversePGN(game,tree)
	#print()
	print('readPGN:',filename,i,'partier', round(time.time() - start,3),'s')

def cpu (prompt,f) :
	start = time.time()
	print(prompt, f(),round(time.time() - start, 3), 's')

# Kolla sorteringsordning innan detta produktionssättes
ALFABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ01234_abcdefghijklmnopqrstuvwxyz56789-'
#       01234567890123456789012345678901
HIGH = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ01234_'
LOW  = 'abcdefghijklmnopqrstuvwxyz56789-'

def code6464(square):
	row = 'abcdefgh'.index(square[0])
	col = '12345678'.index(square[1])
	return ALFABET[row+8*col]
# def code64(level): return ALFABET[level]
# def triple(arr):
# 	res = ""
# 	for uci,level in arr:
# 		res += code6464(uci[0:2]) + code6464(uci[2:4]) + code64(level)
# 	return res

def linearize(tree,arr=[],level=0):
	for key in tree:
		if key == 'n': continue
		arr.append([key,level,tree[key]['n']])
		linearize(tree[key],arr,level+1)
	return arr

def add_p(linear):
	res = []
	index = [0] * 64
	for i in range(len(linear)):
		uci,level,n = linear[i]
		index[level] = i
		if level == 0: res.append([uci, level, 0, n])
		else: res.append([uci, level, i-index[level - 1], n])
	return res

def utf(n) :
	res = ""
	while True:
		a = n % 32
		n //= 32
		if n == 0: return res + LOW[a]
		else: res += HIGH[a]

def compressed(arr):
	res = []
	for [uci,level,parent,popularity] in arr:
		res.append(code6464(uci[0:2]) + code6464(uci[2:4]) + utf(level) + utf(parent) + utf(popularity))
	return "".join(res)

# ["d5a5",5,1,14072] =>

def save(tree):
	linear = linearize(tree)
	parent = add_p(linear)
	# with open("data/tree-" + filename + ".json", "w") as f: f.write(json.dumps(tree).replace(" ", ""))
	# with open("data/arr-"  + filename + ".json", "w") as f: f.write(json.dumps({'arr':parent}).replace('], ["', '],\n["').replace(' ',''))
	with open("data/tree.json", "w") as f: f.write(json.dumps(tree).replace(" ", ""))
	with open("data/arr.json", "w") as f: f.write(json.dumps({'arr':parent}).replace('], ["', '],\n["').replace(' ',''))
	with open("data/carr.json", "w") as f: f.write(json.dumps({'arr':compressed(parent)}))


# with open("data/tree.json", "r") as f: tree = json.load(f)
tree = {'n':0}

print()
board = chess.Board()
#                                     === sekunder ===   kB    nodes  nodes  depth depth         nodes
#                      pgnSize  games read  prop prune tree   before  after before after nodes/s /game
#readPGN('2014-08') #   0.1 MB    137    1   0.0   0.0    1    10737     62    298    20         0.45
readPGN('2016-02') #  10.0 MB  13149  107   1.1   1.4   60   914356   3918    256    28     36  0.30
#readPGN('2019-06') #  65.0 MB  76808  767  10.4  16.0  341           22536                  29
#readPGN('2019-11') # 137.0 MB 163429 1580  14.4  18.7  694           45868                  29
#readPGN('2020-01') # 206.0 MB 248213 1965  16.7  95.5 1037           68756                  35  0.28 # prune(5) killed 99.6% of the nodes
#readPGN('2020-05') # 313.0 MB 369771 3033  23.8  78.3 1591 26270541 105197                  35       # zippat 255kB
#readPGN('2020-04') # 356.0 MB 423017 3281  28.1 105.9 1795 29772962 118744    434    43     36  0.28 # prune(5) killed 99.6%

res = []
for entry in scandir('original'):
	res.append(entry.name[14:21])
res.sort()
print(res)

#for name in res[:10]:
#	readPGN(name)

# totalt 3.05 GB cirka 18MB 10h

cpu('propagate',lambda : propagate(tree))
cpu('countNodes before', lambda : countNodes(tree))
cpu('maxDepth before', lambda : maxDepth(tree))
cpu('prune',lambda : prune(tree,CUTOFF))
cpu('maxDepth after', lambda : maxDepth(tree))
cpu('countNodes after', lambda : countNodes(tree))
cpu('save',lambda : save(tree))
