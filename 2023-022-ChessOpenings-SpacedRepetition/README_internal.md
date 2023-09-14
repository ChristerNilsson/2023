# TODO

https://github.com/lichess-org/chess-openings/tree/29d9ba8986d158d6c4307eb92249da86b0e73413

* Visa även ställningarnas namn t ex Ruy Lopez osv.
* prune, skär bort små grenar från trädet. T ex med mindre än 300 partier

## arr.json
Byggs upp med hjälp av ett antal master.pgn-filer och ett pythonprogram.  
```
Move Level Parent Games
e2e4   0     -1  191684
c7c5   1      0   75916
d2d4   2      1    3337
c5d4   3      2    3002
d2d4   0     -1  182333

e2e4
	c7c5
		d2d4
			c5d4
d2d4
```
Vi ser här några inledande drag.
* Move: t ex e2e4
* Level: 0 innebär första draget
* Parent: -1 innebär att parent saknas.
* Count: Antal spelade partier med denna öppning

Efter inläsning beskärs trädet för att få bort de små grenarna, under t ex fem partier.



I nedanstående utdrag från tree.arr ser man index i listan, antalet partier, samt den fortsatta öppningen.  
Det handlar varken om bredden först eller djupet först, utan om Count först.  
Gemensamt är att förälder alltid kommer före barn.  
Detta delträd består av 6503 halvdrag, varav vi ser de tio första.  
Både g8f6 och f8c5 accepteras som bästa drag eftersom 11210/11858 >= 0.8  
Databasen innehåller 24973 partier som inleds med dragen e2e4.e7e5.g1f3.b8c6.f1c4  

```
C50	Italian Game 1. e4 e5  2. Nf3 Nc6 3. Bc4
e2e4.e7e5.g1f3.b8c6.f1c4
 Index Count Path
303002 24973
303256 11858 g8f6
306307 11210 f8c5
303587  6564 g8f6.d2d3
306978  4764 f8c5.c2c3
306979  4235 f8c5.c2c3.g8f6
303588  3313 g8f6.d2d3.f8c5
305001  3083 g8f6.f3g5
305002  2735 g8f6.f3g5.d7d5
305003  2734 g8f6.f3g5.d7d5.e4d5
```

# Prestanda

Att välja nästa drag med utgångspunkt av nuvarande val,
kan troligen snabbas upp.
Just nu hämtas en nivå i trädet och detta kräver att hela subträdet traverseras.
Dessa pather bör eventuellt cachas. Antingen i nuvarande session eller sparas i localStorage.
Kan handla om tiotusentals 'e2e4.e7e5.g1f3...'-drag i en lista.

# Komprimering

Man kan lagra en rad med cirka sex tecken, i bästa fall fem tecken.
* e2e4 kodas med 64x64 (två tecken)
* level kodas med 64   (ett tecken)
* parent och n med lista av 32. (variabelt antal tecken)

Lista av 32 innebär att om versal eller 56789, kommer fler tecken.  
T ex lagras alla tal under 32 med ett tecken.  
	31 lagras som -  
	32 lagras som Ab  
1023 lagras som _-   dvs 31 + 32 x 31  
1024 lagras som AAb  dvs 0 + 0 x 32 + 1 x 32 x 32  

Hela arrayen lagras som en enda sträng.

Exempel:
```
["e2e4",0,1,123456], <=> m2 a b ABc <=> m2abABc
dvs 21 tecken blir 7, en besparing med 67%
["e2e4",0,1,12],     <=> m2 a b m <=> uAabm
dvs 17 tecken blir 5, en besparing med 70%
```
Alfabet:
```
0         1         2         3
01234567890123456789012345678901
abcdefghijklmnopqrstuvwxyz01234-  sista tecknet
ABCDEFGHIJKLMNOPQRSTUVWXYZ56789_  fler tecken kommer

Schackbrädet:
Y  Z  5  6  7  8  9  _  svart
Q  R  S  T  U  V  W  X
I  J  K  L  M  N  O  P
A  B  C  D  E  F  G  H
y  z  0  1  2  3  4  -
q  r  s  t  u  v  w  x
i  j  k  l  m  n  o  p
a  b  c  d  e  f  g  h  vit
```

# localstorage
Underhålls av javascript.
Används för att hålla reda på en användares status.  
root: e2e4.e7e5.g1f3.b8c6.f1b5 # Denna öppning vill man träna på  
latest: <path> # Senast hämtad öppning  
Boxes innehåller fem lådor med kort.  
Varje kort representeras av en path.  
Localstorage innehåller maximalt 5 + 10 + 20 + 40 + 80 = 155 kort, per öppning.  
Man kan välja nya öppningar med en knapptryckning och även byta.  
```
{
	root: "e2e4.e7e5.g1f3.b8c6.f1b5" # dvs Ruy Lopez
	latest: 123 (drag 123 av framsökta drag, sorterade enligt popularitet)
	boxes: # relativt root
		[
		"a7a6 a7a6.f1b5", # två kort
		"a7a6.f1b5.b5a4.g8f6", # ett kort
		"",
		"",
		""
	]
}
```
