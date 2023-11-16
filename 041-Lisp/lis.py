import math
import operator as op
import time

import sys
#resource.setrlimit(resource.RLIMIT_STACK, (2**29,-1))
sys.setrecursionlimit(10**6)

# (define fact (lambda (n) (if (<= n 1) 1 (+ n (fact (- n 1))))))
# (define fib (lambda (n) (if (< n 2) n (+ (fib (- n 1)) (fib (- n 2))))))
# (set! adam 'xyz')

Symbol = str		  # A Lisp Symbol is implemented as a Python str
List   = list		  # A Lisp List is implemented as a Python list
Number = (int, float) # A Lisp Number is implemented as a Python int or float

antal = 0

def parse(program):
	return read_from_tokens(tokenize(program))

def tokenize(s):
	return s.replace('(',' ( ').replace(')',' ) ').split()

def read_from_tokens(tokens):
	if len(tokens) == 0:
		raise SyntaxError('unexpected EOF while reading')
	token = tokens.pop(0)
	if '(' == token:
		L = []
		while tokens[0] != ')':
			L.append(read_from_tokens(tokens))
		tokens.pop(0) # pop off ')'
		return L
	elif ')' == token:
		raise SyntaxError('unexpected )')
	else:
		return atom(token)

def atom(token):
	try: return int(token)
	except ValueError:
		try: return float(token)
		except ValueError:
			return Symbol(token)

def standard_env():
	env = Env()
	env.update(vars(math)) # sin, cos, sqrt, pi, ...
	env.update({
		'+':op.add, '-':op.sub, '*':op.mul, '/':op.truediv,
		'>':op.gt, '<':op.lt, '>=':op.ge, '<=':op.le, '=':op.eq,
		'abs':	 abs,
		'append':  op.add,
		# 'apply':   apply,
		'begin':   lambda *x: x[-1],
		'car':	 lambda x: x[0],
		'cdr':	 lambda x: x[1:],
		'cons':	lambda x,y: [x] + y,
		'eq?':	 op.is_,
		'equal?':  op.eq,
		'length':  len,
		'list':	lambda *x: list(x),
		'list?':   lambda x: isinstance(x,list),
		'map':	 map,
		'max':	 max,
		'min':	 min,
		'not':	 op.not_,
		'null?':   lambda x: x == [],
		'number?': lambda x: isinstance(x, Number),
		'procedure?': callable,
		'round':   round,
		'symbol?': lambda x: isinstance(x, Symbol),
	})
	return env

class Env(dict):
	def __init__(self, parms=(), args=(), outer=None):
		self.update(zip(parms, args))
		self.outer = outer
	def find(self, var):
		global antal
		antal += 1
		#env = self
#		while env!=None and var not in env:
#			env = self.outer
#		return env
		#print(var)
		return self if (var in self) else self.outer.find(var)

global_env = standard_env()

def repl(prompt='lis.py> '):
	while True:
		s = input(prompt)
		start = time.time_ns()
		parsed = print(parse(s))
		val = eval(parsed)
		print((time.time_ns() - start) / 10 ** 9)
		if val is not None:
			print(lispstr(val))
			print(antal)
def lispstr(exp):
	if isinstance(exp, List):
		return '(' + ' '.join(map(lispstr, exp)) + ')'
	else:
		return str(exp)

class Procedure(object):
	def __init__(self, parms, body, env):
		self.parms, self.body, self.env = parms, body, env
	def __call__(self, *args):
		return eval(self.body, Env(self.parms, args, self.env))

def eval(x, env=global_env):
	if isinstance(x, Symbol):	  # variable reference
		return env.find(x)[x]
	elif not isinstance(x, List):  # constant literal
		return x
	elif x[0] == 'quote':		  # (quote exp)
		(_, exp) = x
		return exp
	elif x[0] == 'if':			 # (if test conseq alt)
		(_, test, conseq, alt) = x
		exp = (conseq if eval(test, env) else alt)
		return eval(exp, env)
	elif x[0] == 'define':		 # (define var exp)
		(_, var, exp) = x
		env[var] = eval(exp, env)
	elif x[0] == 'set!':		   # (set! var exp)
		(_, var, exp) = x
		env[var] = eval(exp, env)
	elif x[0] == 'lambda':		 # (lambda (var...) body)
		(_, parms, body) = x
		return Procedure(parms, body, env)
	else:						  # (proc arg...)
		proc = eval(x[0], env)
		args = [eval(exp, env) for exp in x[1:]]
		return proc(*args)

repl()