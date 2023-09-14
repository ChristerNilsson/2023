import time
import chess.pgn
from os import scandir

DIR = "C:/github/2023-022-ChessOpenings-SpacedRepetition/original"

# Läser ett antal pgn-filer, som kan innehålla flera partier.

board = None
filename = ""
maximum = 0

def f(fen,pieces,count): return fen.count(pieces[0]) <= count and fen.count(pieces[1]) <= count

def analyzeGame(complete,node,board,i,header):
	global maximum
	for variation in node.variations:
		board.push(variation.move)
		n = len(list(board.legal_moves))
		if n >= 75:
			fen = board.fen()
			fen0 = fen.split(' ')[0] # as Q may occur in the castling field
			if f(fen0,'Qq',1) and f(fen0,'Rr',2) and f(fen0,'Bb',2) and f(fen0,'Nn',2):
				if n > maximum: maximum = n
				print(n,i,header)
				print("  ", fen)
				moves = [str(move) for move in list(board.legal_moves)]
				moves.sort()
				moves = ' '.join(moves)
				print("  ", moves)
				print("  ", complete)
				print()
		analyzeGame(complete,variation,board,i,header)

def readPGN(namn):
	global filename
	filename = namn
	start = time.time()
	pgn = open(DIR + "/lichess_elite_" + filename + ".pgn")
	print('readPGN:', filename)
	for i in range(1000000):
		board = chess.Board()
		game = chess.pgn.read_game(pgn)
		if game == None: break
		if 'abandoned' in game.headers['Termination']: continue
		header = game.headers['White'] + '-' + game.headers['Black']
		vs = list(game.variations)
		if len(vs) > 0:
			complete = str(vs[0])
			analyzeGame(complete,game,board,i,header)
	print('   maximum:',maximum,'av',i,'partier tog', round(time.time() - start,3),'s =>',round(i/(time.time() - start),3),'p/s')

res = []
for entry in scandir(DIR):
	res.append(entry.name[14:21])
res.sort()
print(res)
print()

res.reverse()

for name in res:
	readPGN(name)
