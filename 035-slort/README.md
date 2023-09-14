# 2023-035-slort

[Try it!](https://christernilsson.github.io/2023/035-slort)

Pusslet går ut på att använda rätt operationer för att omvandla godtycklig permutation till 123456

Det finns 6! = 6x5x4x3x2x1 = 720 permutationer.  
110 olika sekvenser används för att lösa alla 720 uppgifterna.  
I snitt krävs 4.5 operationer  
Största antalet operationer som behövs för sex siffror är sju.

Operationer på 123456:
```
Swap   214365  1:a och 2:a siffran byter plats, 3:e och 4:e samt 5:e och 6:e
Low    123456  Siffrorna 1, 2 och 3 flyttas till vänster
Odd    135246  Siffrorna 1, 3 och 5 flyttas till vänster
Rotate 234561  första siffran flyttas till slutet
Turn   654321  hela raden reverseras
```

Facit är lagrat i filen data.json.
216345 kan omvandlas till 123456 med SROSTRL
```
  216345 start
S 123654
R 236541
O 351264
S 532146
T 641235
R 412356
L 123456 target
```
