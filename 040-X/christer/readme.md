### Exekvering

* ./x.exe "`<load christer.x>`"

### Frågor till Bertil
* Hur få bort fönstret och visa resultat i terminalen?
* Hur visa assert på tre rader? (ny rad i wcons)
* Hur hanteras vanliga arrayer?


### Jämförelse mellan Coffeescript, Python och X

Coffeescript:
```coffee
fib = (n) -> if n < 2 then 1 else fib(n-1) + fib(n-2)
```

Python:
```python
def fib(n): return 1 if n < 2 else fib(n-1) + fib(n-2)
```

Clojure:
```clojure
(defn fib [n] (if (< n 2) 1 (+ (fib (- n 1)) (fib (- n 2)))))
```

X:
```
<preldef fib>
<def fib, <if $1 '< 2,1,<calc <fib <calc $1-1>> + <fib <calc $1-2>>>>>
```

* `preldef` måste användas eftersom funktionen är rekursiv.
* `$1` används för att nå första parametern
* `calc` nödvändig eftersom beräkning utförs
* `'<` nödvändig för att ange `<`. Krockar annars med vinkelparentesen.

```
Exekveringstider av fib(25) == 121393:
Coffeescript: 11 ms
Python:       37 ms
Clojure:      45 ms
X:         38000 ms
```