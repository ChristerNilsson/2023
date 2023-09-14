add = lambda a,b: a+b
sub = lambda a,b: a-b
mul = lambda a,b: a*b
div = lambda a,b: a/b if a % b == 0 else 0/0

operations = [ (add, '+'),(sub, '-'),(mul, '*'),(div, '/')]

def Evaluate(stack):
	try:
		total = 0
		lastOper = add
		for item in stack:
			if type(item) is int:
				total = lastOper(total, item)
			else:
				lastOper = item[0]
		return total
	except:
		return 0

def ReprStack(stack):
	reps = [ str(item) if type(item) is int else item[1] for item in stack ]
	return ' '.join(reps)

def Solve(target, numbers):

	def Recurse(stack, nums):
		for n in range(len(nums)):
			stack.append( nums[n] )

			remaining = nums[:n] + nums[n+1:]

			if Evaluate(stack) == target:
				print(ReprStack(stack))

			if len(remaining) > 0:
				for op in operations:
					stack.append(op)
					stack = Recurse(stack, remaining)
					stack = stack[:-1]

			stack = stack[:-1]

		return stack

	Recurse([], numbers)

target = 421
numbers = [5,6,10,11,12,18]

print("Target: {0} using {1}".format(target, numbers))
Solve(target, numbers)

# Många dubletter
# 3M operationer
# Visar alla på sex sekunder

5 + 6 + 12 + 18 * 10 + 11
5 + 6 + 18 + 12 * 10 + 11
5 + 12 + 6 + 18 * 10 + 11
5 + 12 + 18 + 6 * 10 + 11
5 + 18 + 6 + 12 * 10 + 11
5 + 18 + 12 + 6 * 10 + 11

6 + 5 + 12 + 18 * 10 + 11
6 + 5 + 18 + 12 * 10 + 11
6 + 12 + 5 + 18 * 10 + 11
6 + 12 + 18 + 5 * 10 + 11
6 + 18 + 5 + 12 * 10 + 11
6 + 18 + 12 + 5 * 10 + 11

12 + 5 + 6 + 18 * 10 + 11
12 + 5 + 18 + 6 * 10 + 11
12 + 6 + 5 + 18 * 10 + 11
12 + 6 + 18 + 5 * 10 + 11
12 + 18 + 5 + 6 * 10 + 11
12 + 18 + 6 + 5 * 10 + 11

18 + 5 + 6 + 12 * 10 + 11
18 + 5 + 12 + 6 * 10 + 11
18 + 6 + 5 + 12 * 10 + 11
18 + 6 + 12 + 5 * 10 + 11
18 + 12 + 5 + 6 * 10 + 11
18 + 12 + 6 + 5 * 10 + 11

6 * 12 + 10 * 5 + 11

11 + 12 + 18 * 10 + 5 + 6
11 + 12 + 18 * 10 + 6 + 5
11 + 18 + 12 * 10 + 5 + 6
11 + 18 + 12 * 10 + 6 + 5
11 * 12 + 5 * 18 / 6 + 10
11 * 12 + 10 * 18 / 6 - 5
11 * 18 + 10 * 12 / 6 + 5
12 + 11 + 18 * 10 + 5 + 6
12 + 11 + 18 * 10 + 6 + 5
12 + 18 + 11 * 10 + 5 + 6
12 + 18 + 11 * 10 + 6 + 5
12 * 6 + 10 * 5 + 11
12 * 11 + 5 * 18 / 6 + 10
12 * 11 + 10 * 18 / 6 - 5
12 * 18 * 10 / 5 - 11
12 * 18 / 6 + 5 * 10 + 11
18 + 11 + 12 * 10 + 5 + 6
18 + 11 + 12 * 10 + 6 + 5
12 / 6 * 18 + 5 * 10 + 11
18 + 12 + 11 * 10 + 5 + 6
18 + 12 + 11 * 10 + 6 + 5
18 - 12 * 6 + 5 * 10 + 11
18 - 12 * 10 + 11 * 6 - 5

10 * 12 * 18 / 5 - 11
10 * 12 / 5 * 18 - 11
10 * 18 * 12 / 5 - 11
10 * 18 / 5 * 12 - 11
10 / 5 * 12 * 18 - 11
10 / 5 * 18 * 12 - 11
12 * 10 * 18 / 5 - 11
12 * 10 / 5 * 18 - 11
18 * 10 * 12 / 5 - 11
18 * 10 / 5 * 12 - 11
18 * 12 * 10 / 5 - 11

6 * 10 / 5 + 12 * 18 - 11
10 * 6 / 5 + 12 * 18 - 11
10 / 5 * 6 + 12 * 18 - 11

18 * 11 + 10 * 12 / 6 + 5
18 * 12 / 6 + 5 * 10 + 11
18 / 6 * 12 + 5 * 10 + 11