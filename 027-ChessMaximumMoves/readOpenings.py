import json
import chess

# Läser öppningar från fem tsv-filer från Github/Lichess

lines = []
board = chess.Board()
tree = {}

for letter in 'abcde':
	with open('openings/' + letter + '.tsv', "r", encoding="utf-8") as f:
		z = f.readline() # titles of tsv
		lines += f.readlines()

arr = [line.split('\t') for line in lines]

for item in arr:
	board = chess.Board()
	moves = item[2].strip().split(' ')
	moves = [move for move in moves if '.' not in move]
	for move in moves: board.push_san(move)
	moves = [board.uci(move) for move in board.move_stack]
	node = tree
	for move in moves:
		if move not in node: node[move] = {}
		node = node[move]
	node['name'] = item[0] + ' ' + item[1]

with open('openings/openings.json', "w", encoding="utf-8") as g:
	g.write(json.dumps(tree))
