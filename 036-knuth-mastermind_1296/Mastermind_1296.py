import time
import json

ALFABET = 'ABCDEF'
ALL = None

def ass(a,b):
	if a == b: return
	print('assert failure')
	print('  ',a)
	print('  ',b)

def evaluate(guess,code):

	assert(len(guess) == len(code))
	n = len(guess)

	# Determine the correct and incorrect positions.
	correct_positions = [i for i in range(n) if guess[i] == code[i]]
	incorrect_positions = [i for i in range(n) if guess[i] != code[i]]
	num_correct = len(correct_positions)

	# Reduce the guess and the code by removing the correct positions.
	# Create the set values that are common between the two reduced lists.
	reduced_guess = [guess[i] for i in incorrect_positions]
	reduced_code = [code[i] for i in incorrect_positions]
	reduced_set = set(reduced_guess) & set(reduced_guess)

	# Determine the number of transposed values.
	num_transposed = 0
	for x in reduced_set:
		num_transposed += min(reduced_guess.count(x), reduced_code.count(x))

	return str(num_correct) + str(num_transposed)

ass(evaluate('AABB','ABCD'),'11')
ass(evaluate('ABCD','AABB'),'11')
ass(evaluate('5522','1234'),'01')
ass(evaluate('4335','1234'),'11')
ass(evaluate('1415','1234'),'11')
ass(evaluate('3345','1234'),'02')
ass(evaluate('2314','1234'),'13')
ass(evaluate('1234','1234'),'40')

allScore = [str(i) + str(j) for i in range(5) for j in range(4 - i + 1)]

def KnuthFive():
	allP = ALL
	S = ALL

	guess = 'AABB'
	guessList = [guess]
	answer = evaluate(guess,code)

	# while the guess is not the code, keep guessing
	while answer != '40':
		temp = [] # temp is the list after removing all the conflicting guesses in S
		cScore = [] # cScore is a list of scores for each guess in allP

		# remove guesses from S that will not give the same peg score if it is the answer
		for item in S:
			if evaluate(guess, item) == answer:
				temp.append(item)
		S = temp #[:]

		# minimax step of the algorithm
		# for all unused guesses in allP, create a list (hitCount) that will be used
		# to calculate the score for the guess
		for item in allP:
			if item not in guessList:
				hitCount = [0]*len(allScore)
				# for all guesses in S, calculate its peg score if the unused guess in allP
				# is the answer. Increase the corresponding position in hitCount by 1
				for s in S:
					hitCount[allScore.index(evaluate(s, item))] += 1
				# calculate the score for the current unused guess
				cScore.append(len(S) - max(hitCount))
			else:
				cScore.append(0)
		# find all indices with the max score
		maxScore = max(cScore)
		indices = [i for i, x in enumerate(cScore) if x == maxScore]
		# if any guesses corresponds to the indices is a member of S, use that as the next guess
		change = False

		for index in indices:
			if allP[index] in S:
				guess = allP[index]
				change = True
				break

		if change == False:
			guess = allP[indices[0]]
		guessList.append(guess)

		answer = evaluate(guess,code)

	return guessList

def create1296(): return [i+j+k+l for i in ALFABET for j in ALFABET for k in ALFABET for l in ALFABET]

ALL = create1296()
data = []

# Initialize statistics.
totalSolved   = 0 # number of the 1296 codes that you solved
totalUnsolved = 0 # number of the 1296 codes that you didn't solve
worstCase     = 0 # largest number of guesses used to solve a code
totalGuesses  = 0 # total number of guesses used to solve all solved codes

start = time.time()
for i in range(1296):
	code = ALL[i]
	guesses = KnuthFive()
	print(i,time.time()-start,code,guesses)
	if guesses[-1] == code:
		totalSolved += 1

		s = "".join(guesses[1:-1])
		#print(i, s)
		i += 1
		data.append(s)

		numGuesses = len(guesses)
		worstCase = numGuesses if numGuesses > worstCase else worstCase
		totalGuesses += numGuesses
	else:
		totalUnsolved += 1

with open("data_1296.json",'w') as f:
	hash = {"data":"*".join(data)}
	f.write(json.dumps(hash))

print("total solved: %d" % totalSolved)
print("worst case: %d" % worstCase)
print("average: %f" % (totalGuesses/totalSolved))
print("total unsolved: %d" % totalUnsolved)
