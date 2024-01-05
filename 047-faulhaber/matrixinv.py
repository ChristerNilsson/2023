from sympy import Matrix

facit = lambda n: Matrix([sum([item**(n-1) for item in range(1,n+1)][:i]) for i in range(1,1+n)])

def solve(n):
	ll = [[i**j for j in range(1,n+1)] for i in range(1,n+1)]
	return Matrix(ll).inv() @ facit(n)

for i in range(1,11):
	print(i,[cell for cell in solve(i+1)])

# Interpretation: (the polynomial starts as n, n^2, ...)
# 2 [1/6, 1/2, 1/3] (sum is always 1)
# Sum(n^2) = n/6 + n^2/2 + n^3/3
# The first number is the Bernouilli number (1/6)
# See https://maa.org/press/periodicals/convergence/sums-of-powers-of-positive-integers
