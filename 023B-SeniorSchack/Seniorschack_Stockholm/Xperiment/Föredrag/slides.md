Kalkylering (del 3)

# Ken Thompson
* Född: 1943
* 1969: [B](https://en.wikipedia.org/wiki/B_(programming_language)), föregångare till [C](https://en.wikipedia.org/wiki/C_(programming_language))
* 1970: [Unix](https://en.wikipedia.org/wiki/Unix)
* 1976: [Belle](https://en.wikipedia.org/wiki/Belle_(chess_machine))
* 1977: [Första slutspelsdatabasen](https://en.wikipedia.org/wiki/Endgame_tablebase)
* 2009: [Go](https://en.wikipedia.org/wiki/Go_(programming_language))
* [Intervju med Brian Kernighan](https://youtu.be/EY6q5dv_B-o?si=BZgbZfzNzxmCeTcM)
* [Wikipedia](https://en.wikipedia.org/wiki/Ken_Thompson)
* [Tiobe](https://www.tiobe.com/tiobe-index/)

# Utvärderingsfunktion
[Wikipedia](https://en.wikipedia.org/wiki/Evaluation_function)
* Positiv: vit leder
* Negativ: svart leder 

# Minimax-algoritmen
[Wikipedia](https://en.wikipedia.org/wiki/Minimax)

[John von Neumann 1928](https://en.wikipedia.org/wiki/John_von_Neumann#Game_theory)
[Alan Turing 1948](https://en.wikipedia.org/wiki/Turochamp)
[Claude Shannon](https://en.wikipedia.org/wiki/Claude_Shannon#Shannon's_computer_chess_program)

# Kalaha
* Regler
* Utvärderingsfunktion
* Sökdjup

[Wikipedia](https://en.wikipedia.org/wiki/Kalah)
[Spel](https://christernilsson.github.io/Lab/2019/118-Kalaha/)
<iframe src="https://christernilsson.github.io/2024/118-Kalaha/?scale=0.5" title="Kalaha" style="border:0; width:460px; height:170px;"></iframe>
<iframe src="https://christernilsson.github.io/2024/118-Kalaha/?scale=0.5" title="Kalaha" style="border:0; width:460px; height:170px;"></iframe>

# Monte Carlo Tree Search
[Wikipedia](https://en.wikipedia.org/wiki/Monte_Carlo_Tree_Search) 

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
