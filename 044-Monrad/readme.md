# Swiss Tournament Handler

The URL is the database.

## Keys

Enter = Jump between Tables and Result
ArrowUp/ArrowDown = Select Table
0 space 1 q 2 w 3 e 4 r 5 t 6 y 7 u 8 = Enter result
ArrowLeft/ArrowRight = Change result
Home = Jump to first table
End = Jump to last table

## No Mouse or touch interface!

## Always print paper forms for entering results.

This is your ultimate backup!  

[Try it!](https://christernilsson.github.io/2023/044-Monrad)

14 players:  
```
http://127.0.0.1:5500?TOUR=Klass_1
&DATE=2024-05-28
&ROUNDS=6
&ROUND=0
&GAMES=1
&FIRST=black
&NAME=Lennart_B._Johansson|Göran_Björkdahl|Henrik_Strömbäck|Onni_Aikio|Tor_Liljeström|Lars-Åke_Pettersson|Leonid_Stolov|Peteris_Silins|Kjell_Persson|Jouko_Lehvonen|Lars_Owe_Andersson|Dan_Israel|Lars-Erik_Åberg|Görgen_Antonsson
&ELO=1825|1800|1775|1750|1725|1700|1675|1650|1625|1600|1575|1550|1525|1500
```

&OPP=1,5,2|0,6,3|3,11,0|2,8,1|5,13,12|4,0,6|7,1,5|6,10,9|9,3,11|8,12,7|11,7,13|10,2,8|13,9,4|12,4,10
&COL=WBB|BWB|WBW|BWW|WBB|BWB|WBW|BWB|WBW|BWW|WBW|BWB|WBW|BWB
&RES=221|020|221|022|201|002|000|220|001|222|200|001|201|022

64 players:  
```
http://127.0.0.1:5500?TOUR=Wasa_SK
&DATE=2023-11-28
&ROUNDS=6
&ROUND=0
&NAME=AA|AB|AC|AD|AE|AF|AG|AH|BA|BB|BC|BD|BE|BF|BG|BH|CA|CC|CC|CD|CE|CF|CG|CH|DA|DD|DC|DD|DE|DF|DG|DH|EA|EE|EC|ED|EE|EF|EG|EH|FA|FF|FC|FD|FE|FF|FG|FH|GA|GB|GC|GD|GE|GF|GG|GH|HA|HB|HC|HD|HE|HF|HG|HH
&ELO=1825|1800|1775|1750|1725|1700|1675|1650|1625|1600|1575|1550|1525|1500|1725|1700|1675|1650|1625|1600|1575|1550|1525|1500|1725|1700|1675|1650|1625|1600|1575|1550|1525|1500|1725|1700|1675|1650|1625|1600|1575|1550|1525|1500|1725|1700|1675|1650|1625|1600|1575|1550|1525|1500|1725|1700|1675|1650|1625|1600|1575|1550|1525|1500
```
### Monrad

	* Handles tournaments with 4 to 64 players.

### Quick Start

Enter the names in the URL.  
Show the names and let everybody be seated.  
The names are alphabetically ordered.  

<img align="center" src="1.GIF">

When the first game is played, click Next to see the Tables screen.  

<img align="center" src="2.GIF">

Click on the winner or between them for a draw.  
Clicking twice cancels the result.  
When all results are entered, click Next.  

<img align="center" src="3.GIF">

Click Next to start the next round.  

### Instructions
	Edit the URL above.  
	Add the names of the players.  

	* NAME contains then names, separated with |. Mandatory.
	* TOUR contains the header of the tournament. Optional
	* DATE contains the Date. Optional
	* ROUNDS contains the number of rounds. Optional
		* Default: minimum number of rounds if the tournament was a cup, plus 50%.
		* One round added to make the number of rounds even.
		* If you want a different number of rounds, just put it in the URL.
	* T contains the tiebreak order. Default: T=WD1
		* W = Number of Wins
		* D = Direct Encounter. Used only groups with exactly two players
		* 1 = Buchholz 1. The sum of all opponents
		* 2 = Buchholz 2. The sum of all opponents except the weakest.
		* B = Number of Black games
		* S = Sonneborn-Berger
		* F = Fide Tiebreak
	* Z states the team size. Default: Z=1. Maximum 8.

	The following parameters are internal and handled by the program:
	* OPP contains the opponents
	* COL contains the colours, B & W
	* RES contains the scores, 0, 1 or 2 for victory.

### Saving the tournament
	* The updated URL contains all information to display the result page.
	* The URL is available on the clipboard.
	* No data will be stored on the server. All data is in the URL.

### Sample URL
Eight players, four rounds  
Just copy and paste it into your browser. Oneliner not needed.  
```
https://christernilsson.github.io/2023/044-Monrad
?NAME=CARLSEN_Christer|BENGTSSON_Bertil|HARALDSSON_Helge|ERIKSSON_Erik|ANDERSSON_Anders|DANIELSSON_Daniel|GREIDER_Göran|FRANSSON_Ferdinand
&TOUR=Wasa SK KM blixt
&DATE=2023-11-25
&OPP=1,3,5,6|0,4,3,7|3,7,6,5|2,0,1,4|5,1,7,3|4,6,0,2|7,5,2,0|6,2,4,1
&COL=WBWB|BWWB|WBWB|BWBW|WBWB|BWBW|WBBW|BWBW
&RES=2111|0200|1222|1122|0020|2010|2201|0002
&TIE=WD1
```

# Table of number of rounds (R) given number of players (N).
General rule: 2*R <= N. Also R <= 20
```
N: 4 6 8 10 12 24 26 62 64
R: 2 3 4  4  6  6  8  8 10
```

### Teams

* State the team size in parameter Z
* Keys: 
	* 0
	* space ½
	* 1
	* q 1½
	* 2
	* w 2½ 
	* 3
	* e 3½
	* 4
	* r 4½
	* 5
	* t 5½
	* 6
	* y 6½
	* 7
	* u 7½
	* 8
	* Left  Arrow: Decrease White with ½. Wraps.
	* Right Arrow: Increase White with ½. Wraps.
* Use Up and Down to select game. Wraps
* Also: Home End PgUp PgDn

# Kontroller av URL.
* Antal spelare skall överensstämma i N, O, C och R
* Antal ronder skall överensstämma i O C och R
* Tillåtna tecken i N: I princip alla möjliga. De kodas/avkodas automatiskt. T ex åäöÅÄÖéæýþÿüïœßđèùúøàáçìíñμ-. Emojis?
* Tillåtna tecken i O: 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-/ (64 tecken)
* Tillåtna tecken i C: BW (två tecken)
* Tillåtna tecken i R individuellt spel: 012 (tre tecken)
* Tillåtna tecken i R med åtta spelare per lag: 0123456789abcdefg (16 tecken)

### Begränsningar
* 4 till 64 spelare

### Noterat
Begränsningar i antal ronder med maxweight-algoritmen:
N 8 16 32 64 128
R 4 10 25 50 113
64/50 tar 1204 ms (python) för alla ronderna.
För stora N och små R är min rekursiva pair mycket snabbare.

### Frågor
* Ska man se till att antaler ronder alltid är jämnt ? (Av färgrättviseskäl)
* Vad är lämpligt antal ronder, givet N spelare ?
* Visa placering som 12 (plats, Jämn=Vit, Udda=Svart) eller 6W (bord + färg) ?

### ToDo

* Slumpa namnen om ORC saknas!
* Blankett att fylla i resultatet (bordslista). En för varje rond.
* E= (ELO-rating) förberedelse för Swiss
* TB= (Tiebreaks) Prioritetsordning
* P= (partier per match) Lagturneringar
* R= Antal ronder
* Ändra Result till Score
* Score anges med ett tecken. T ex åtta spelare: 0 1q2w3e4r5t6y7u8  q=½-7½  u=7½-½

### Transpilering av .py till .coffee.
Tvingades transpilera fyra funktioner i ett eget pass, pga begränsningar i chatGPT.  
En felaktighet var att jag behövde byta `i,j = j,i` mot `[i,j] = [j,i]`
En annan att list comprehension använde [] istf ()
Negativa index fixades genom att [i] => [i %% length]

### Hur jag hittade alla buggar i övergången från Python till Coffeescript
* Låt python skapa en tracefil med utskrifter
* Låt Javascript skapa en tracefil med samma utskrifter
* Ställ dig på python.txt i PyCharm
* Kör PyCharm|View|Compare With och välj senaste tracefilen från javascript

