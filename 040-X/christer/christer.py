# import time 

# def fib(n): return 1 if n<2 else fib(n-1) + fib(n-2)

# start = time.time()
# print(fib(25))
# print(time.time()-start)

def ass(a,b): 
	if a!=b: print('Assert failed',a,b)

arr = [3,4]
hash = {'a':1, 'b':2}

ass(arr,[3,4])
ass(arr[1],4)
ass(hash,{'a':1, 'b':2})
ass(hash['a'],1)

arr1 = []
hash1 = {}

for value in arr:
	arr1.append(value)

for key in hash:
	hash1[key] = hash[key]

ass(arr,arr1)
ass(hash,hash1)

print('ok')

