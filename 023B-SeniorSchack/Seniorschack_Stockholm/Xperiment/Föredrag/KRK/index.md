* KRK - [Torres 1912](https://en.wikipedia.org/wiki/El_Ajedrecista)
	* Maskin
	* Begränsningar
		* Tornet måste vara [mellan](https://syzygy-tables.info/?fen=8/8/8/8/8/3k4/2R5/1K6_w_-_-_0_1) kungarna, och mattkanten uppåt.
		* Vit kung kan ej röra sig diagonalt. 
		* Tornet kan bara röra sig ett steg i taget vertikalt.
	* Klarar de flesta problem inom 50-dragsregeln, dock ej alla.
* [Barbara Liskov 1968](https://www.chessprogramming.org/Barbara_Liskov)
	* Avhandling: [A Program to play chess end games](https://apps.dtic.mil/sti/tr/pdf/AD0673971.pdf)
		* KRK 16 sidor
		* KBBK 33 sidor
		* KBNK 53 sidor
		* Predikatkalkyl, baserad på Capablancas [bok](https://www.sources.com/SSR/Docs/Capablanca-ChessFundamentals.pdf).
		* Lispprogram
		* Programmet hanterar även KQK och KNNNK
* KRK - Nilsson 1972
	* Lunds Tekniska Högskola
		* Univac 1108
		* Fortran
		* 10 cm hålkort
		* Ett skott om dagen!
		* Blev aldrig klart.
	* Min version av Torres i [Python](https://raw.githubusercontent.com/ChristerNilsson/2024/main/035-KRK-robot/krk-robot.py)

# Exempel Kc6 Rd2 Ke3

* Torres  1912 [29 drag](https://lichess.org/study/ZXSfQnuS/UD4DMl5W)
* Liskov  1968 [17 drag](https://lichess.org/study/ZXSfQnuS/YeR4k4Tq)
* Thomson 1975 [13 drag](https://syzygy-tables.info/?fen=8/8/2K5/8/8/4k3/3R4/8_w_-_-_0_1)

# Slutsats

Ansatsen i Torres och Liskovs projekt var att skapa en maskin eller ett program som tänker som en människa.  
Dessa program kan sägas bestå av ett antal if-satser.  
Skalbarhet saknas.   


