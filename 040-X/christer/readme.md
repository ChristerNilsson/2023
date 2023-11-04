### Exekvering

* ./x.exe "`<load christer.x>`"

### Frågor till Bertil
* Hur få bort fönstret och visa resultat i terminalen?
* Hur visa assert på tre rader? (ny rad i wcons)
* Hur hanteras vanliga arrayer? 
* Hur avläsa tecken 3 i "christer"?
* finns eval ? exec
* är a==A ? YES
* linenr, vad är det? enbart datafil
* <makebits 8,5> 00000101
* sort
* strlowercase, struppercase, kan ej jämföras
* <is > => No
* <is 12> => Yes
* Profiling behövs. -gv eller -pg

### Jämförelse mellan Pascal, Coffeescript, Python, Clojure och X

Pascal:
```python
function fib(n:int32):int32;
begin
	if n<2 then fib := 1 else fib := fib(n-1) + fib(n-2)
end;
```

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
Free Pascal:   1 ms
Coffeescript: 11 ms
Python:       37 ms
Clojure:      45 ms
X:         38000 ms
```