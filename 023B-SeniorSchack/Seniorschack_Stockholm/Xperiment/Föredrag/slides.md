Kalkylering (del 3)

# Ken Thompson

![Ken Thompson](Ken_Thompson.png)

* 1943: Föddes i New Orleans
* 1968: [Reguljära uttryck](https://www.oilshell.org/archive/Thompson-1968.pdf)
* 1969: [B](https://en.wikipedia.org/wiki/B_(programming_language)), föregångare till [C](https://en.wikipedia.org/wiki/C_(programming_language))
* 1970: [Unix](https://en.wikipedia.org/wiki/Unix) med Dennis Ritchie
* 1973: [grep](https://en.wikipedia.org/wiki/Grep)
* **1976**: [Belle](https://en.wikipedia.org/wiki/Belle_(chess_machine)) med Joe Condon
	* Första specifika schackhårdvaran.
	* Draggenerering
	* Ställningsutvärdering
	* Dragomkastningstabell
	* alpha-beta Pruning (uppsnabbning av minimax)
	* Generation 3 hanterade 100-200 tusen drag per sekund.
* **1978**: Vann [US Computer Chess Championship](https://en.wikipedia.org/wiki/North_American_Computer_Chess_Championship)
* **1977**: [Första slutspelsdatabasen](https://en.wikipedia.org/wiki/Endgame_tablebase)
* **1980**: Vann US Computer Chess Championship
* **1980**: Vann [World Computer Chess Championship](https://en.wikipedia.org/wiki/World_Computer_Chess_Championship)
* **1981**: Vann US Computer Chess Championship
* **1982**: Vann US Computer Chess Championship
* **1983**: Belle utsedd till US Chess Master med rating 2250
* **1986**: Vann US Computer Chess Championship
* 1992: [UTF-8](https://en.wikipedia.org/wiki/UTF-8) med Rob Pike
* 2009: [Go](https://en.wikipedia.org/wiki/Go_(programming_language)) med Robert Griesemer och Rob Pike
* [Intervju med Brian Kernighan](https://youtu.be/EY6q5dv_B-o?si=BZgbZfzNzxmCeTcM)
* [Wikipedia](https://en.wikipedia.org/wiki/Ken_Thompson)
* [Tiobe](https://www.tiobe.com/tiobe-index/)

# Utvärderingsfunktion
[Wikipedia](https://en.wikipedia.org/wiki/Evaluation_function)
* Material
* Rörlighet
* Säkerhet för kungen
* Centrum
* Bondestruktur
* [PST (piece-square tables)](https://github.com/Kyle-L/Simple-Chess-Engine/blob/main/board_pieces_tables.py)
* Dessa parametrar viktas och summeras med enheten *centipawn*
	* Positiv: vit leder
	* Negativ: svart leder 
* Alternativ: [NNUE](https://www.chessprogramming.org/Stockfish_NNUE)

# Minimax-algoritmen

1928: [John von Neumann](https://en.wikipedia.org/wiki/John_von_Neumann#Game_theory)  
1945: [Konrad Zuse](https://link.springer.com/chapter/10.1007/978-3-031-39876-6_12) (Oklart om minimax användes)  
1948: [Alan Turing](https://en.wikipedia.org/wiki/Turochamp)  
1949: [Claude Shannon](https://en.wikipedia.org/wiki/Claude_Shannon#Shannon's_computer_chess_program)  

[Wikipedia](https://en.wikipedia.org/wiki/Minimax)

# Kalaha
* Regler
* Utvärderingsfunktion
* Sökdjup

[Wikipedia](https://en.wikipedia.org/wiki/Kalah)
[Spel](https://christernilsson.github.io/Lab/2019/118-Kalaha/)
<iframe src="https://christernilsson.github.io/2024/118-Kalaha/?scale=0.5" title="Kalaha" style="border:0; width:460px; height:170px;"></iframe>
<iframe src="https://christernilsson.github.io/2024/118-Kalaha/?scale=0.5" title="Kalaha" style="border:0; width:460px; height:170px;"></iframe>

# Monte Carlo Tree Search

Fördel: Utvärderingsfunktion behövs ej.

* Selection. [Video som beskriver hur urvalet går till](https://youtu.be/UXW2yZndl7U?si=0CVSD6abn7tXbdRQ)
	* Det handlar om avvägning mellan framgångsrika drag och oprövade grenar. [Länk](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search#Exploration_and_exploitation)
* Expansion.
* Simulation. Innebär att dragen väljs slumpvis till någon vunnit eller remi inträffat.
* Backpropagation. Uppdatering från lövet till roten av bråken.

Noderna innehåller vinstandelar.

Svart är vid draget.

Roten: Vit har vunnit 11 av 21

7/10 väljs här, pga C=sqrt(2). (0/3 väljs om C=2)

1/6 väljs

3/3 väljs

Simulering sker. Svart vann

3/3 uppdateras till 4/4

1/6 uppdateras till 1/7

7/10 uppdateras till 8/11

11/21 uppdateras till 11/22

Om tiden är ute, väljs 8/11 eftersom nämnaren 11 är störst.

Störst antal partier avgör alltså vilket drag som väljs.

![MCTS](MCTS-steps.svg)

[Wikipedia](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search) 

# Schack

* [Utvärderingsfunktion](https://en.wikipedia.org/wiki/Computer_chess#Leaf_evaluation)
	* Vinst/förlust/remi
	* Material
	* Position
		* 2 * 6 * 64 = 768
		* Öppning/mittspel/slutspel + interpolation
	* Antal möjliga drag
	* [Machine Learning](https://en.wikipedia.org/wiki/Stockfish_(chess)#NNUE)
* [Öppningsdatabas](https://en.wikipedia.org/wiki/Computer_chess#Opening_book)
* [Simple Chess Engine](https://github.com/Kyle-L/Simple-Chess-Engine)

# Slutspelsdatabas

* [Slutspelsdatabas](https://en.wikipedia.org/wiki/Computer_chess#Endgame_tablebases)
	* [Syzygy](https://syzygy-tables.info)
* Komprimering
	* Spegling
	* Rotation
	* Övriga metoder
* [KRk](KRk.txt) Textformat: 247 kB
	* a1 a2 c1 7 innebär Ka1, Ra2, Kc1 sju drag till matt
	* [Matt i 16 drag](https://syzygy-tables.info/?fen=8/8/8/8/8/8/2Rk4/1K6_b_-_-_0_1)
	* Syzygy: 7.7 kB (kräver komplex mjukvara för att läsas)
	* Positioner: 28056
* KBNPvKRB 192 GB
	* [Matt i 35 drag](https://syzygy-tables.info/?fen=7k/P7/8/7K/B7/8/1N2r3/3b4_w_-_-_0_1)
* [Övriga slutspelsdatabaser](http://tablebase.sesse.net/)

<iframe src="https://syzygy-tables.info/?fen=8/8/8/8/8/8/2Rk4/1K6_b_-_-_0_1" title="Matt i 16 drag" style="border:0; width:500px; height:850px;"></iframe>
