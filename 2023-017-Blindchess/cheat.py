from stockfish import Stockfish # https://pypi.org/project/stockfish/
import sys
import time

start = time.time()

INITIAL = ' '.join(sys.argv[1:]) # INITIAL = "e2e4 e7e5 ..."
#DEPTH = 25
MOVES = 10

engine = Stockfish(path="stockfish15/stockfish-windows-2022-x86-64-modern")
engine.set_position(INITIAL.split(" "))

print()
for DEPTH in range(30,35):
	engine.set_depth(DEPTH)
	print(DEPTH,engine.get_evaluation())
print()

# moves = engine.get_top_moves(MOVES)
# for i in range(len(moves)):
# 	move = moves[i]
# 	print(i+1,move["Move"] + " " + str(move["Centipawn"]))
# print('DEPTH:',DEPTH, 'CPU:', round(time.time() - start,3), 's')
