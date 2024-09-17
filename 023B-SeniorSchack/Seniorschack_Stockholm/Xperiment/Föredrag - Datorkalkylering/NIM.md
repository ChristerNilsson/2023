* 1940: [Nimatron](https://en.wikipedia.org/wiki/Nimatron) visades upp i USA
* 1951: En annan NIM-maskin visades upp i England

Dessa maskiner hade fyra högar med upp till sju stickor i varje.  
Spelarna turades om att ta bort en eller flera stickor ur EN hög.  
Den som tar sista stickan vinner.  


```
A 1 |
B 3 | | |
C 5 | | | | |
D 7 | | | | | | |
```

[Wikipedia](https://en.wikipedia.org/wiki/Nim)

## Strategi

Vi använder [xor](https://en.wikipedia.org/wiki/Exclusive_or)

Vinnande ställningar uppfyller följande villkor:

A xor B xor C = 0

## Sanningstabell för xor

|xor|0|1|
|-|-|-|
|**0**|0|1|
|**1**|1|0|

## Större sanningstabell för xor

|xor|0|1|2|3|4|5|6|7|
|-|-|-|-|-|-|-|-|-|
|**0**|0|1|2|3|4|5|6|7|
|**1**|1|0|3|2|5|4|7|6|
|**2**|2|3|0|1|6|7|4|5|
|**3**|3|2|1|0|7|6|5|4|
|**4**|4|5|6|7|0|1|2|3|
|**5**|5|4|7|6|1|0|3|2|
|**6**|6|7|4|5|2|3|0|1|
|**7**|7|6|5|4|3|2|1|0|

### Exempel 1

```
Hög dec 421
 A   1  001
 B   3  011
 C   4  100
xor  6  110

1 3 4 är en förlorande ställning eftersom 1 xor 3 xor 4 = 6
```

## Draggenerering

```
A B C xor
0 3 4  7
1 2 4  7
1 1 4  4
1 0 4  5
1 3 3  1
1 3 2  0 Vinnare!
1 3 1  3
1 3 0  2
```

## Manuell strategi

* Skriv talen som summor av 1, 2, 4, 8..
* Välj största högen med ett ensamt tal
* Lägg tillbaks stickor i samma hög så att nya par bildas

### Exempel 2
Vi kallar högarna A, B och C
```
 A 3 = 1 2
 B 4 =     4
 C 5 = 1   4

 Tvåan är ensam och tas därför bort
 Resultat: 1 4 5
```

### Exempel 3
```
A 4 =     4
B 5 = 1   4
C 6 =   2 4

Antalet ettor, tvåor och fyror är udda.
Välj en hög innehållande en fyra

A 3 = 1 2
B 5 = 1   4
C 6 =   2 4

A väljs. Droppa en tvåa och en etta

eller

A 4 =     4
B 2 =   2
C 6 =   2 4

B väljs. Droppa en tvåa

eller

A 4 =     4
B 5 = 1   4
C 1 = 1

C väljs. Droppa en etta

```

### Exempel 4
```
A 2 =   2
B 3 = 1 2
C 6 =   2 4

Fyran måste bort. Den är ensam och störst.

A 2 =   2
B 3 = 1 2
C 1 = 1

C väljs. Droppa en etta.

```
