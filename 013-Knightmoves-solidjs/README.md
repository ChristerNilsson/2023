# 2023-013-Knight Moves - SolidJS

Uppgiften består av
1. Placera en dam på en tillåten ruta.  
2. Placera en springare på högsta tillåten ruta.
3. Förflytta springaren till nästa tillåtna ruta.
4. Upprepa tills alla rutor besökts.

Damen kan inte placeras var som helst.  
T ex inte på a4, då kan springaren inte nå a1.  
Detta pga att springare och dam ej får ta varandra.  

Visning av möjliga drag
```
8  N - N - N - N -
7  B Q B Q B Q B Q
6  N - N - N - N -
5  B Q B Q B Q B Q
4  N - N - N - N -
3  B Q B Q B Q B Q
2  N - N - N - N -
1  B Q B Q B Q B Q
   a b c d e f g h

B: (Båda)   Visning av båda pjäsernas drag
N: (Knight) Visning av springarens drag
Q: (Queen)  Visning av damens drag
-:          Ingen visning av drag (svårast)
```

# Teknisk information

Numrering av schackbrädet
```
8 56 57 58 59 60 61 62 63
7 48 49 50 51 52 53 54 55
6 40 41 42 43 44 45 46 47
5 32 33 34 35 36 37 38 39
4 24 25 26 27 28 29 30 31
3 16 17 18 19 20 21 22 23
2 08 09 10 11 12 13 14 15
1 00 01 02 03 04 05 06 07
   a  b  c  d  e  f  g  h
```

# Datastrukturer
* state: 0,1 eller 2

* queens: en lista med möjliga rutor för damen
  * Visas med ett antal damer
* queen: ett index som anger var damen placerades
  * Visas med en dam
* illegals: en lista med rutor damen hotar
	* Visas med svarta cirklar
* targets: övriga rutor
	* blanka
* taken: antal targets som uppnåtts
* knight: ett index som visar var springaren befinner sig
	* Visas med en springare
* target: den ruta som springaren ska uppnå
	* Visas med en ring
* knightHops: de rutor springaren kan nå i ett drag. Max 8
	* Visas med vita cirklar
* count: antal drag för aktuell target. Oftast 0,1,2 eller 3.
* counts: lista med antal drag för alla tagna targets.
* mask: 0,1,2 eller 3. Används för att visa damens och springarens möjliga drag.
* info: Visar antal drag och totaltid.
* start: tiden då man började lösa uppgiften.

# SolidJS

Jag använder detta ramverk utan build.  
Detta genom att utnyttja 
* [SolidJS](https://www.solidjs.com) 
* [SolidJs-Hyperscript](https://www.solidjs.com/examples/simpletodoshyperscript)
* [Hyperscript](https://github.com/hyperhype/hyperscript)
* [Coffeescript](https://coffeescript.org)

Exempel:
```js
	svg
		viewBox : "0 0 #{10*S} #{12*S}"
		width : 8*S
		height : 8*S
		showRects()
		showLittera()
```

Detta innebär att man kan deploya överallt
* Google Cloud Storage
* Github Pages
* Lokalt kan man använda:
	* python -m http.server

# Frågor
* Varför behövs två loopar i r4r?
* Varför får jag inte igång reaktiviteten?
	* T ex måste jag lägga sättningarna i click-händelsen annars utförs de ej.

# Förvärvad kunskap
En signal innehåller oftast enstaka värden, t ex heltal eller strängar.
Men, en signal kan även innehålla godtyckliga JSON-strukturer.
Då man modifierar ett sådant träd måste man först klona originalet och sedan modiera en eller flera celler. Detta kan ske mha bl a _.set, föreslagit av CoPilot. _.set ingår i Lodash.
I [_.set](https://lodash.com/docs/4.17.15#set) anger man en path, t ex "a[2].b"

# Referenser
Möjligt att dessa kan förenklas.
Dessa fungerar både lokalt och med Github Pages.
* index.html: ./js/sketch.js (en punkt)
* sketch.coffee: ../js/utils.js (två punkter)

# Reaktivitet
Testade att ta bort alla signaler.  
Fungerade utmärkt, dock skapades ett bräde för varje klick.  
Tömning av body plus omritning av allt löste problemet.  
Se sketch8.coffee resp utils8.js  
Gick ej att se några prestandaskillnader, varken tid eller data.  
```js
click = (index) ->
	if state == 0 then state0 index
	else if state == 1 then state1 index
	else state2 index
	document.body.innerHTML = ''
	r4r => game
```
