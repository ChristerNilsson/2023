import json
import re

def ass(a,b):
	if a!=b: print(a,'!=',b)

def parse_expression(expression):
	stack = []
	tree = []
	for token in re.findall(r'\(|\)|[^\s()]+', expression):
		if token == '(':
			stack.append(tree)
			new_tree = []
			tree.append(new_tree)
			tree = new_tree
		elif token == ')':
			tree = stack.pop()
		else:
			tree.append(token)
	return tree[0]
ass(['add', ['multiply', '2', '3'], '4'], parse_expression("(add (multiply 2 3) 4)"))


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
ass(True, parentesBalans("()()(){}{}{}"))
ass(True, parentesBalans("({[]})"))
ass(True, parentesBalans("((()))"))
ass(False,parentesBalans("((())"))
ass(True, parentesBalans("((()){}[])"))
ass(False,parentesBalans(")("))
ass(True, parentesBalans("(def fib [x] (if (= x 1) x (+ (fib (- x 1)) (fib (- x 2)))))"))

def rightParen(ch):
	if ch=='(': return ')'
	if ch=='[': return ']'
	if ch=='{': return '}'
	return ch

def transform(s): # lägger till högerparenteser i slutet av raden vid behov

	pars = [] # = stack av hängande vänsterparenteser
	result = "" # input + tillkommande högerparenteser
	tabs = [line.count("\t") for line in s.split("\n")] # antal inledande tabbar per rad.
	stringMode = False

	i = 0 # radnummer
	for ch in s:
		if stringMode:
			if ch=='"': stringMode = False
			result += ch
		else:
			if ch in '([{':
				result += ch
				pars.append(ch)
			elif ch in ')]}':
				result += ch
				if len(pars) == 0:
					return 'Error: Parenthesis unbalanced in line ' + str(i)
				else:
					temp = rightParen(pars.pop())
					if temp != ch:
						return f"Error: Expected '{temp}', but found '{ch}' in line {i}"
			elif ch == '\t':
				result += ch
			elif ch == '\n':
				antal = len(pars) - tabs[i+1]
				if antal < 0: return 'Error: Too many tab stops in line ' + str(i+1)
				for j in range(antal):
					result += rightParen(pars.pop())
				i += 1
				result += ch
			elif ch=='"':
				stringMode = True
				result += ch
			else:
				result += ch

	for j in range(len(pars)):
		result += rightParen(pars.pop())

	# a = 0
	# while len(result) != a:
	# 	a = len(result)
	# 	result = result.replace('  ',' ')
	# Nu ska strängen vara fri från dubbla mellanslag
	#result = result.replace(') )','))') # måste ev upprepas för att få bort extra blanktecken

	return result.strip()

def short(s):
	if not s: return ""
	lines = s.strip("\n").split("\n")
	return "\n".join(lines)

def tass(a,b): # är, bör
	sa = short(a)
	sb = short(b)
	sfa = short(transform(a))
	#if not parentesBalans(sfa): print("Obalanserat!",sa)
	if sb == sfa: return
	print('====== in =======')
	print(sa)
	print('====== är =======')
	print(sfa)
	print('====== bör ======')
	print(sb)
	print('=================')

tests = """
(defn leap-year? [year
	(and (zero? (mod year 4
		(or (not (zero? (mod year 100
			(zero? (mod year 400
---
(defn leap-year? [year]
	(and (zero? (mod year 4))
		(or (not (zero? (mod year 100)))
			(zero? (mod year 400)))))
===
(require '[clojure.data.csv :as csv
(require '[clojure.java.io :as io
(require '[dk.ative.docjure :as docjure

(defn csv-data->maps [csv-data
	(map zipmap
		(->> (first csv-data
			(map keyword
			repeat
		(rest csv-data

(defn read-csv [filename
	(with-open [reader (io/reader filename
		(doall
			(csv-data->maps (csv/read-csv reader {:separator \;

(read-csv "data/Transaktioner_213339668_2023-11-12_1659.csv"
---
(require '[clojure.data.csv :as csv])
(require '[clojure.java.io :as io])
(require '[dk.ative.docjure :as docjure])

(defn csv-data->maps [csv-data]
	(map zipmap
		(->> (first csv-data)
			(map keyword)
			repeat)
		(rest csv-data)))

(defn read-csv [filename]
	(with-open [reader (io/reader filename)]
		(doall
			(csv-data->maps (csv/read-csv reader {:separator \;})))))

(read-csv "data/Transaktioner_213339668_2023-11-12_1659.csv")
===
(import java.time.LocalDate

(defn ass [a b] (if (= a b) "ok" (str "Assert failure: " a " != " b

(defn makeInterval [date
	[
		(.withDayOfMonth date 1
		(-> date
			(.plusMonths 1
			(.withDayOfMonth 1
			(.minusDays 1

(defn makeInterval_ [date] [ (.withDayOfMonth date 1) (.minusDays (.withDayOfMonth (.plusMonths date 1) 1) 1

(ass [(LocalDate/of 2023 10 01) (LocalDate/of 2023 10 31)] (makeInterval (LocalDate/of 2023 10 19
(ass [(LocalDate/of 2023 11 01) (LocalDate/of 2023 11 30)] (makeInterval (LocalDate/of 2023 11 15
---
(import java.time.LocalDate)

(defn ass [a b] (if (= a b) "ok" (str "Assert failure: " a " != " b)))

(defn makeInterval [date]
	[
		(.withDayOfMonth date 1)
		(-> date
			(.plusMonths 1)
			(.withDayOfMonth 1)
			(.minusDays 1))])

(defn makeInterval_ [date] [ (.withDayOfMonth date 1) (.minusDays (.withDayOfMonth (.plusMonths date 1) 1) 1)])

(ass [(LocalDate/of 2023 10 01) (LocalDate/of 2023 10 31)] (makeInterval (LocalDate/of 2023 10 19)))
(ass [(LocalDate/of 2023 11 01) (LocalDate/of 2023 11 30)] (makeInterval (LocalDate/of 2023 11 15)))
===
(ns user (:require [clojure.string :as str

(def book (slurp "C:/github/2023/040-X/christer/mobydick.txt"

(count book

(def words (str/split book #"[^a-zA-Z]+"

; (def words (re-seq #"[\w|’]+" book))

(count words

(take 10 words

(def common-words #{"for" "all" "by" "not" "from" "on" "this" "at" "his" "s" "is" "was" "the" "of" "and" "a" "to" "in" "that" "his " "it" "with" "i" "as" "he" "but"

common-words
(count common-words

(->> words
	(map str/lower-case
	(remove common-words
	(frequencies
	(sort-by val
	(reverse
	(take 20

(->> words
	(map str/lower-case
	(distinct
	(sort-by count
	(take-last 20
	(reverse
	(group-by count

(defn palindrome? [s
	(= (seq s) (reverse s

(palindrome? "sirap i paris"
(palindrome? "slisk"

(->> words
	(distinct
	(filter palindrome?
	(sort-by count
	(last
---
(ns user (:require [clojure.string :as str]))

(def book (slurp "C:/github/2023/040-X/christer/mobydick.txt"))

(count book)

(def words (str/split book #"[^a-zA-Z]+"))

; (def words (re-seq #"[\w|’]+" book))

(count words)

(take 10 words)

(def common-words #{"for" "all" "by" "not" "from" "on" "this" "at" "his" "s" "is" "was" "the" "of" "and" "a" "to" "in" "that" "his " "it" "with" "i" "as" "he" "but"})

common-words
(count common-words)

(->> words
	(map str/lower-case)
	(remove common-words)
	(frequencies)
	(sort-by val)
	(reverse)
	(take 20))

(->> words
	(map str/lower-case)
	(distinct)
	(sort-by count)
	(take-last 20)
	(reverse)
	(group-by count))

(defn palindrome? [s]
	(= (seq s) (reverse s)))

(palindrome? "sirap i paris")
(palindrome? "slisk")

(->> words
	(distinct)
	(filter palindrome?)
	(sort-by count)
	(last))
===
(def b [[c d] ])
---
(def b [[c d] ])
===
(let [a "])"
		b 2
---
(let [a "])"
		b 2])
===
(let [a "Hello World"
		b 2
	ret
---
(let [a "Hello World"
		b 2]
	ret)
===
(defn foo
	"This is docstring.
	Line 2 here."
	ret
---
(defn foo
	"This is docstring.
	Line 2 here."
	ret)
===
"adam"
---
"adam"
===
(foo [a (b] c)
---
Error: Expected ')', but found ']' in line 0
===
(let [x {:foo 1 :bar 2]
	x)
---
Error: Expected '}', but found ']' in line 0
===
(def foo [a b]]
---
Error: Expected ')', but found ']' in line 0
===
bar)
---
Error: Parenthesis unbalanced in line 0
===
(defn foa
	[arg
	ret

(defn fob
	[arg
	ret
---
(defn foa
	[arg]
	ret)

(defn fob
	[arg]
	ret)
===
(defn foc
[arg
ret
---
(defn foc)
[arg]
ret
===
(defn fod
[arg ret
---
(defn fod)
[arg ret]
===
(defn foe
	[arg
	ret
---
(defn foe
	[arg]
	ret)
===
(def fib [x]
	(if (= x 1
		x
		(+
			(fib (- x 1
			(fib (- x 2
---
(def fib [x]
	(if (= x 1)
		x
		(+
			(fib (- x 1))
			(fib (- x 2)))))
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
(* 1 2)
(+ 3 4)
===
(* 1 2
	(+ 3 4
---
(* 1 2
	(+ 3 4))
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
(* 1
	(+ 2
		(- 7 3)))
"""

for item in tests.strip("\n").split("\n===\n"):
	a,b = item.strip("\n").split("\n---\n")
	tass(a,b)

# indent paren smart
# with open("indent-mode.json") as f:
# 	data = list(json.load(f))
#
# def test(t):
# 	a = t['text']
# 	b = t['result']['text']
# 	ass(a,b)
#
# test(data[0])
#
#
