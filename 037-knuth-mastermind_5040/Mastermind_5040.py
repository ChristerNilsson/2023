from __future__ import print_function
from __future__ import division  # this ensures the / operation give floats by default
import itertools
import time

N = 10
ALFABET = "ABCDEFGHIJ"
maxTime = 0
data = []

def create5040():
	res = []
	for i in range(N):
		for j in range(N):
			if i == j: continue
			for k in range(N):
				if k in [i,j]: continue
				for l in range(N):
					if l in [i,j,k]: continue
					res.append(ALFABET[i] + ALFABET[j] + ALFABET[k] + ALFABET[l])
	return res

ALL = create5040()

def evaluate(guess,secret):
	res = [str(abs(i - secret.index(guess[i]))) for i in range(len(guess)) if guess[i] in secret]
	return "".join(sorted(res))

assert evaluate("EFGH","IJAB") == ""
assert evaluate("EFGH","IFAB") == "0"
assert evaluate("EFGH","IEAB") == "1"
assert evaluate("EFGH","IJEB") == "2"
assert evaluate("EFGH","IJAE") == "3"
assert evaluate("EFGH","EFGH") == "0000"
assert evaluate("EFGH","FEHG") == "1111"
assert evaluate("EFGH","GHEF") == "2222"
assert evaluate("EFGH","HFEG") == "0123"

def KnuthFive(secret):
	S = ALL
	allScore = set()
	for c in ALL: allScore.add("".join(evaluate(c,secret)))
	allScore = sorted(allScore)

	guess = "ABCD"
	guesses = [guess]
	answer = evaluate(guess,secret)

	while answer != "0000":
		S = [item for item in S if evaluate(guess, item) == answer]

		cScore = [] # cScore is a list of scores for each guess in ALL
		for item in ALL:
			if item not in guesses:
				hitCount = [0] * len(allScore)
				for s in S:
					ans = evaluate(s, item)
					hitCount[allScore.index(ans)] += 1
				cScore.append(len(S) - max(hitCount))
			else:
				cScore.append(0)

		maxScore = max(cScore)
		indices = [i for i, x in enumerate(cScore) if x == maxScore]
		guess = None
		for index in indices:
			if ALL[index] in S:
				guess = ALL[index]
				break

		if not guess:
			guess = ALL[indices[0]]

		guesses.append(guess)
		answer = evaluate(guess,secret)
	return guesses

worstCase = 0     # largest number of guesses used to solve a secret
totalGuesses = 0  # total number of guesses used to solve all solved secrets
start = time.time()
n = len(ALL)
i=0
for secret in ALL:
	guesses = KnuthFive(secret)
	s = "".join(guesses[1:-1])
	print(i,s)
	i+=1
	data.append(s)
	if guesses[-1] == secret:
		worstCase = max(len(guesses), worstCase)
		totalGuesses += len(guesses)

with open("data_5040.json",'w') as f:
	f.write("\n".join(data))

print()
print("total solved: %d" % n)
print("worst case: %d" % worstCase)
print("average: %f" % (totalGuesses/n))
print(time.time()-start)
