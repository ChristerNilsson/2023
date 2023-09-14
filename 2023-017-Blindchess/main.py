from stockfish import Stockfish # https://pypi.org/project/stockfish/
import time
import json

DEPTH = 15
FANOUT = 5
MOVES = 12

count = 0
start = time.time()
black = {}
white = {}

engine = Stockfish(path="stockfish15/stockfish-windows-2022-x86-64-modern")
engine.set_depth(DEPTH)

def dump(objs):
	print()
	for obj in objs: print(obj)

def store(hash,moves):
	h = hash
	for move in moves:
		if move not in h: h[move] = {}
		h = h[move]

def expand (hash,n,moves=[]):
	global count
	if len(moves) == MOVES:
		print(count,time.time()-start)
		count += 1
		store(hash,moves)
		return
	engine.set_position(moves)
	children = engine.get_top_moves([FANOUT,1][(n+len(moves))%2])
	children = [move["Move"] for move in children]
	for move in children: expand (hash,n,moves + [move])

filename = "_" + str(DEPTH) + "_" + str(FANOUT) + "_" + str(MOVES) +".json"

with open("data/black" + filename,"w") as f:
	expand(black,0)
	f.write(json.dumps(black))

# with open("data/white" + filename,"w") as f:
# 	expand(white,1)
# 	f.write(json.dumps(white))
