# 008-Kalkyl

[Try it!](https://christernilsson.github.io/2023/008-Kalkyl)

* Here you can test your one-liners!
* Also suitable as a calculator
* Give name to your expressions
* Create your own functions
* Syntax: Coffeescript or Javascript
* Results are displayed with engineering notation:
	* E-3 milli, E-6 mikro, E-9 nano, E-12 pico ...
	* E3  kilo,  E6  mega,  E9  giga, E12  tera ...

## operations
```js
+  add
*  mul
-  sub
/  div
** power
[3,7]      lists
{a:1, b:3} objects
(x) => x*x functions (oneliners only)
```

## functions
```
solve_bin
solve_nr
```

## Clear
Clears the calculator

## Samples
Show the following example.

## Help
Link to this page

## Hide
Hides the keyboard on smartphones

## URL

Makes a copy of this tab. The link can be copied and sent to a friend.
Please note: Some environments corrupts the link. E.g. MarkDown links. 
In these cases, using a url shortener helps.

## Coffeescript/Javascript

Selects Language

## Degrees/Radians

Selects AngleMode

## Fixed/Engineering

Selects Display mode

## Less

Shows less digits

## More

Shows more digits

## Examples

For example, write

```javascript
distance = 12
time = 5
speed = distance / time
```

Change distance to 20

Also handles strings, lists, objects, functions

## solve_bin (binary search)

solve_bin f,a,b,n=50
* f = function
* a = lower x
* b = upper x
* n = number of iterations

## solve_nr (Newton-Raphson)
solve_nr f,a,n=10,h=0.001
* f = function
* a = initial x
* n = number of iterations
* h = step used in differentiation

## More examples

```javascript
2+3

distance = 150
time = 6
time
distance/time
25 == distance/time
30 == distance/time

# String
a = "Volvo" 
5 == a.length
'l' == a[2]

# Math
5 == sqrt 25 

# Date
c = new Date() 
2018 == c.getFullYear()
c.getHours()

# Array
numbers = [1,2,3] 
2 == numbers[1]
numbers.push 47
4 == numbers.length
numbers 
47 == numbers.pop()
3 == numbers.length
numbers

# Object
person = {fnamn:'David', enamn:'Larsson'}
'David' == person['fnamn']
'Larsson' == person.enamn

# functions (only one liners allowed!)
square = (x) -> x*x
25 == square 5

serial = (a,b) -> a+b
2 == serial 1,1
5 == serial 2,3

parallel = (a,b) -> a*b/(a+b)
0.5 == parallel 1,1
1.2 == parallel 2,3

factorial = (x) -> if x==0 then 1 else x * factorial(x-1)
3628800 == factorial 10

fib = (x) -> if x<=0 then 1 else fib(x-1) + fib(x-2) 
1 == fib 0
2 == fib 1
5 == fib 3
8 == fib 4
13 == fib 5
21 == fib 6

f = 9**x - 6**x -4**x
solve_bin f,1,2,5
solve_bin f,1,2,50
```
