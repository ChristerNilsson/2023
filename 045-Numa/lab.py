from decimal import *
import sys

# https://apod.nasa.gov/htmltest/gifcity/sqrt2.1mil
#facit = '1.414213562373095048801688724209698078569671875376948073176679737990732478462107038850387534327641572 Facit'
facit = '1.618033988749894848204586834365638117720309179805762862135448622705260462818902449707207204189391137 Facit'

getcontext().prec = 100

def f(x): return 1/x + 1


sys.set_int_max_str_digits(100000000)
res = 1
for i in range(1,3000000):
	res = res * i
print(i,res)





