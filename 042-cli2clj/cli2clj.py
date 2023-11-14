import json

def kass(a,b):
	if a!=b: print(a,'!=',b)

def parentesBalans(s): # ChatGPT
	stack = []
	a = "([{"
	b = ")]}"
	for tecken in s:
		if tecken in a:
			stack.append(tecken)
		elif tecken in b:
			if not stack or b.index(tecken) != a.index(stack.pop()): return False
	return not stack
kass(True, parentesBalans("()()(){}{}{}"))
kass(True, parentesBalans("({[]})"))
kass(True, parentesBalans("((()))"))
kass(False,parentesBalans("((())"))
kass(True, parentesBalans("((()){}[])"))
kass(False,parentesBalans(")("))
kass(True, parentesBalans("(def fib [x] (if (= x 1) x (+ (fib (- x 1)) (fib (- x 2)))))"))

def rightParen(ch):
	if ch=='(': return ')'
	if ch=='[': return ']'
	if ch=='{': return '}'
	return ch

def transform(s): # lägger till högerparenteser i slutet av raden vid behov

	pars = [] # = stack av hängande vänsterparenteser
	result = "" # input + tillkommande högerparenteser
	tabs = [line.count("\t") for line in s.split("\n")] # antal inledande tabbar per rad.

	i = 0 # radnummer
	for ch in s:
		if ch in '([':
			result += ' ' + ch
			pars.append(ch)
		elif ch in ')]':
			result += ch + ' '
			pars.pop()
		elif ch == '\t': pass
		elif ch == '\n':
			antal = len(pars) - tabs[i+1]
			if antal < 0: return 'Error: Too many tab stops in line ' + str(i+1)
			for j in range(antal):
				result += rightParen(pars.pop()) + ' '
			i += 1
		else:
			result += ch

	for j in range(len(pars)):
		result += rightParen(pars.pop())
	result = result.replace('  ',' ') # måste ev upprepas för att få bort extra blanktecken
	result = result.replace(') )','))') # måste ev upprepas för att få bort extra blanktecken
	return result.strip()

def short(s):
	if not s: return ""
	lines = s.strip("\n").split("\n")
	return "\n".join(lines)

def ass(a,b): # är, bör
	sa = short(a)
	sb = short(b)
	sfa = short(transform(a))
	if sb == sfa: return
	print('====== in =======')
	print(sa)
	print('====== är =======')
	print(sfa)
	print('====== bör ======')
	print(sb)
	print('=================')

tests = """
(def fib [x]
	(if (= x 1
		x
		(+ 
			(fib (- x 1
			(fib (- x 2
---
(def fib [x] (if (= x 1) x (+ (fib (- x 1)) (fib (- x 2)))))
===
(def fib [x]
		(if (= x 1
			x
			(+ 
				(fib (- x 1
				(fib (- x 2
---
Error: Too many tab stops in line 1
===
(* 1 2
(+ 3 4
---
(* 1 2) (+ 3 4)
===
(* 1 2
	(+ 3 4
---
(* 1 2 (+ 3 4))
===
(* 1 2
---
(* 1 2)
===
a
---
a
===
(a
---
(a)
===
(* 1 (* 2 (* 3 4
---
(* 1 (* 2 (* 3 4)))
===
(* 1
	(+ 2
		(- 7 3
---
(* 1 (+ 2 (- 7 3)))
"""

for item in tests.strip("\n").split("\n===\n"):
	a,b = item.strip("\n").split("\n---\n")
	ass(a,b)

# indent paren smart
with open("indent-mode.json") as f:
	data = list(json.load(f))

def test(t):
	a = t['text']
	b = t['result']['text']
	ass(a,b)

# test(data[0])


