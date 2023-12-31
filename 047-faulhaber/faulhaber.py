from math import comb,lcm
from fractions import Fraction as F
import json

N = 101 # högsta gradtal
B = [1] # Bernoulli-tal: 1 -1/2 1/6 0 -1/30 0 1/42 0 -1/30 0 5/66 ...
summa = lambda k,n: sum([i**k for i in range(1,n+1)]) # enkel, men långsam
pascal = lambda n: [comb(n, k) for k in range(n)]
S = lambda m,n : F(sum([(-1)**k*comb(m+1,k)*B[k]*n**(m-k+1) for k in range(m+1)]),m+1)

for i in range(1,N+1):
	pas = pascal(i+1)
	B.append(F(sum(map(lambda k: -pas[k] * B[k], range(i))), pas[-1]))

def ass(a,b):
	if a != b:
		print(f'assert failure: {a} != {b}')

ass (35, comb(7,4)) # 7! / 3! 4!

ass(pascal(1),[1])
ass(pascal(2),[1,2])
ass(pascal(3),[1,3,3])

#          B0        B1       B2       B3         B4       B5
# ass(B, [1, F(-1, 2), F(1, 6), F(0, 1), F(-1, 30), F(0, 1), F(1, 42), F(0, 1), F(-1, 30), F(0, 1), F(5, 66)])

ass(summa(1,10),  55) # 1 + 2 + 3 + ... + 10
ass(summa(2,10), 385) # 1 + 4 + 9 + ... + 100
ass(summa(3,10),3025) # 1 + 8 + 27 + ... + 1000
ass(summa(9,100),10507499300049998500)

ass(S(1,10),  55)
ass(S(2,10), 385)
ass(S(3,10),3025)
ass(S(9,100),10507499300049998500)

def standardize(arr):
	denominators = [item.denominator for item in arr]
	a = lcm(*denominators)
	lst = [(item*a).numerator for item in arr] # + [a]
	return list(reversed(lst))

res = [standardize([F((-1) ** k * comb(m + 1, k),(m+1)) * B[k] for k in range(m + 1)]) for m in range(101)]

with open('faulhaber.json','w') as f:
	resultat = []
	for arr in res:
		resultat.append(' '.join([str(item) for item in arr]))
	resultat = {"a":resultat}
	s = json.dumps(resultat).replace('", "', '",\n"')
	f.write(s)

def f(k,n):
	r = res[k]
	value = F(0)
	for i in range(len(r)):
		value += r[i] * n ** (i+1)
	return value / sum(r)

ass(55,f(1,10))
ass(5050,f(1,100))
ass(385,f(2,10))
ass(3025,f(3,10))
ass(25502500,f(3,100))
ass(10507499300049998500,f(9,100))
ass(157211406637054876047170714793672086843814311171382380612596108831201947669658622317126645748904454905428999917816240712232510830329707275257029895123985909786290997404450073406292199564392363955731330,f(100,100))
