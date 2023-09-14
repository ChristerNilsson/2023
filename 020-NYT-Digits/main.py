import time

antal=0

def ass(a,b):
	if a==b: return
	print('assert failed')
	print('  ',a)
	print('  ',b)

def update (lst,i,j,c): return [c] + lst[:i] + lst[i+1:j] + lst[j+1:]
ass(update([1,2,3,4,5],0,1,3), [3,3,4,5])

def operation (a,op,b):
	global antal
	antal+=1
	if op == '+': return a + b
	if op == '-': return a - b
	if op == '*' and b != 1: return a * b
	if op == '/' and b != 1 and a % b == 0 : return a // b
	return 0

def solve (target, numbers):
	global solution
	global antal
	antal=0
	def solve1 (target, lst, level, lines):
		global solution
		n = len(lst)
		for i in range(n-1):
			for j in range(i+1,n):
				for op in "*+-/":
					a = lst[i]
					b = lst[j]
					if a < b: [a,b] = [b,a]
					c = operation(a,op,b)
					if c > 0:
						lines1 = lines + [[c,a,op,b]]
						lst1 = update(lst,i,j,c)
						if c == target:
							solution = lines1
						else:
							if level > 1 and len(solution) == 0: solve1(target,lst1,level-1,lines1)

	def traverse(key,level=0):
		if key not in hash: return
		c,a,op,b = hash[key]
		print('  '*level,c,'=',a,op,b)
		traverse(a,level+1)
		traverse(b,level+1)

	solution = []
	start = time.time()
	for level in range(1,6):
		solve1(target,numbers,level,[])
		if len(solution) != 0: break
	print(numbers,'=>',target,'  (',round(time.time() - start,3),'sek ) ',antal)

	hash = {}
	for sol in solution: hash[sol[0]] = sol
	traverse(target)

solve(497,[24,20,15,10,8,5])
solve(11,[1,2,3,4,5])
solve(133,[4,5,8,11,15,20])
solve(218,[4,5,7,9,11,20])
solve(388,[3,5,9,20,23,25])
solve(462,[3,5,9,10,20,25])
solve(1562,[3,5,9,10,20,25])
