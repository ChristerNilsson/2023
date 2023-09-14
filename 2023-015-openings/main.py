LINE = '1. e4 e5 2. Nf3 Nc6 3. Bc4'
# LINE = '1. b4'

GAMES = 90000

N = 8

import os
files = os.listdir("data")

games = []
hash = {'wrb':[0,0,0]}
#hash = {}
header=""
leafs = 0
nodes = 0

def addLine(lst,tree=hash):
	global nodes
	if len(lst) == 0: return
	if lst[0] not in tree: 
		tree[lst[0]] = {'wrb':[0,0,0]}
		nodes += 1
	addLine(lst[1:],tree[lst[0]])

def updateLeaf(tree,path,result):
	global leafs
	leafs+=1
	t = tree
	for key in path:
		if key not in t: return
		t = t[key]
	t = t['wrb']
	if result == "1-0": t[0] += 1
	elif result == "0-1": t[2] += 1
	else: t[1] += 1
	return

def loadGames():
	global header
	games = []
	for file in files:
		with open("data/" + file) as f:
			lines = f.read().split("\n\n")
			for i in range(len(lines)):
				lines[i] = lines[i].replace("\n", " ")
				if i%2==1 and lines[i].startswith(LINE):
					games.append(lines[i])
					if len(games) == GAMES: return games
	return games

def buildTree(games):
	for game in games:
		res = []
		lst = game.split(" ")
		for i in range(len(lst)-1):
			if i%3 in [1,2] and len(res)<2*N: #lst[i] not in ['1-0','0-1','1/2-1/2']:
				res.append(lst[i])
		addLine(res)

def decorateTree(games):
	for game in games:
		path = []
		lst = game.split(" ")
		for i in range(len(lst)):
			if i%3 in [1,2] and len(path)<2*N:
				path.append(lst[i])
		updateLeaf(hash,path,lst[-1])

def propagate(tree):
	for key in tree:
		if key == 'wrb': continue
		propagate(tree[key])
		tree['wrb'][0] += tree[key]['wrb'][0]
		tree['wrb'][1] += tree[key]['wrb'][1]
		tree['wrb'][2] += tree[key]['wrb'][2]

import json

games = loadGames()
buildTree(games)
decorateTree(games)
propagate(hash)

with open("tree.json", "w") as outfile:
	json.dump(hash, outfile)

print('games',len(games))
print('leafs',leafs)
print('nodes',nodes)

# with open("tree.json", "r") as f:
# 	hash = json.load(f)

# print(hash)