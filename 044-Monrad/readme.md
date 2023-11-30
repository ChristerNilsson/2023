WORK IN PROGRESS!

[Try it!](https://christernilsson.github.io/2023/044-Monrad)

64 players:
https://christernilsson.github.io/2023/044-Monrad?T=Wasa_SK&D=2023-11-28&N=AA|AB|AC|AD|AE|AF|AG|AH|BA|BB|BC|BD|BE|BF|BG|BH|CA|CC|CC|CD|CE|CF|CG|CH|DA|DD|DC|DD|DE|DF|DG|DH|EA|EE|EC|ED|EE|EF|EG|EH|FA|FF|FC|FD|FE|FF|FG|FH|GA|GB|GC|GD|GE|GF|GG|GH|HA|HB|HC|HD|HE|HF|HG|HH

### Monrad
	* Handles tournaments with 4 to 64 players.

### Instructions
	Edit the URL above.  
	Add the names of the players.  

	* N contains then names, separated with |. Mandatory!
	* H contains the header of the tournament
	* R contains the number of rounds. 
		* Default: minimum number of rounds if the tournament was a cup, plus 50%.
		* One round added to make the number of rounds even.
		* If you want a different number of rounds, just state it.
	* T contains the tiebreak order. Default: T=WD1
		* W = Number of Wins
		* D = Direct Encounter. Used only groups with exactly two players
		* 1 = Buchholz 1. The sum of all opponents
		* 2 = Buchholz 2. The sum of all opponents except the weakest.
		* B = Number of Black games
		* S = Sonneborn-Berger
		* F = Fide Tiebreak
	* Z states the team size. Default: Z=1

	The following parameters are internal and handled by the program:
	* D contains the date
	* O contains the opponents
	* C contains the colours, B & W
	* S contains the scores, 0, 1 or 2 for victory.

### Handling the GUI
Look at the names and let everybody be seated.
![Names](1.JPG)
When the first game is played, click Next to see the Tables screen.
![Tables](2.JPG)
Click on the winner or between them.  
When all results are entered, click Next.  
![Results](3.JPG)
Click Next to start the next round.

### Saving the tournament
	* The updated URL contains all information to display the result page.
	* The URL is available on the clipboard. Windows:ok, Apple:no (thanks to EU and GDPR)
	* No tournament will be stored on the server.

### Sample URL
Eight players, four rounds  
Just copy and paste it into your browser. Oneliner not needed.  
```
https://christernilsson.github.io/2023/044-Monrad
?H=Wasa SK KM blixt
&D=2023-11-25
&N=CARLSEN_Christer|BENGTSSON_Bertil|HARALDSSON_Helge|ERIKSSON_Erik|ANDERSSON_Anders|DANIELSSON_Daniel|GREIDER_Göran|FRANSSON_Ferdinand
&O=1356|0437|3765|2014|5173|4602|7520|6241
&C=WBWB|BWWB|WBWB|BWBW|WBWB|BWBW|WBBW|BWBW
&S=2111|0200|1222|1122|0020|2010|2201|0002
&T=WD1
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
	* Left  Arrow: Decrease White with ½. Modulo.
	* Right Arrow: Increase White with ½. Modulo.
* Use Up and Down to select game

# Kontroller av URL.
* Antal spelare skall överensstämma i N, O, C och R
* Antal ronder skall överensstämma i O C och R
* Tillåtna tecken I N: I princip alla möjliga. De kodas/avkodas automatiskt. T ex åäöÅÄÖéæýþÿüïœßđèùúøàáçìíñμ-. Emojis?
* Tillåtna tecken i O: 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-/ (64 tecken)
* Tillåtna tecken i C: BW (två tecken)
* Tillåtna tecken i R: 012 (tre tecken)

### Begränsningar
* 4 till 64 spelare

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
* R= Antal ronder ska kunna anges. Default används annars, cirka 1.5*log2(N)
* Ändra Result till Score
* Scores anges med ett tecken. T ex åtta spelare: 0123456789abcdefg 0:0-8 1:½-7½ .. f:7½-½ g:8-0

