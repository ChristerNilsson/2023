# Swiss Tight Pairing


## Keys

```
Enter = Jump between Tables and Result
ArrowUp/ArrowDown = Select Table
0 = Enter White Loss
space = Enter Draw
1 = Enter White Win
Home = Jump to first table
End = Jump to last table
```

## No Mouse or touch interface!

## Always print paper forms for entering results.

This is your ultimate backup!  

[8 players](8.txt)

[14 players](14.txt)

[14 players - 2nd round](14_2.txt)

[28 players](28.txt)

[78 players](78.txt)

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

### Performance

78 players.  
Handled pairing up to 44 rounds.  
7 ms per round.  



## Bonus till svart

Eventuellt kan man tilldela svart en bonus.  
Orsaken till denna bonus är att kompensera för [vits fördel att få börja](https://chess-results.com/tnr816234.aspx?lan=6&art=13&turdet=YES&flag=30).  

* Bonuspoäng         = 0.1 (default 0.0)
	* Remi som vit   = 0.4 (default 0.5)
	* Remi som svart = 0.6 (default 0.5)
	* Vit vinst      = 1.0 (default 1.0)
	* Svart vinst    = 1.2 (default 1.0)

Denna parameter kan sättas till det värde man anser vara lämpligast.  
Vill man inte dela ut denna bonuspoäng sätts parametern till noll.  

## Några exempel på beräkningar

### Exampel 1 Svart vinner
```
Spelare Elo   Resultat  Faktor
Vit     2400  0         0      
Svart   1600  1         1   =>  2400 * 1.0 = 2400 elopoäng
```

### Exempel 2 Remi
```
Spleare Elo   Result  Faktor
Vit     2400  ½       0.5  =>  1600 * 0.5 =  800 elopoäng
Svart   1600  ½       0.5  =>  2400 * 0.5 = 1200 elopoäng
```

### Exempel 3 Svart vinner, Bonus = 0.1
```
Spelare Elo   Resultat  Faktor
Vit     2400  0         0 
Svart   1600  1         1.2  =>  2400 * 1.2 = 2880 elopoäng
```

### Exempel 4 Vit vinner, Bonus = 0.1
```
Spelare Elo   Resultat  Faktor
Vit     2400  1         1.0  =>  1600 * 1.0 = 1600 elopoäng
Svart   1600  0         0    
```

### Exempel 5 Remi, Bonus = 0.1
```
Spelare Elo   Result  Faktor 
Vit     2400  ½       0.4    1600 * 0.4 =  640 elopoäng
Svart   1600  ½       0.6    2400 * 0.6 = 1440 elopoäng
```

### Hypotetiskt exempel
```
Högsta gruppen
2400 Adam: Fyra remier ger 1195 + 1190 + 1185 + 1180 = 4750 elos
2390 Bert
2380 Carl
2370 Dina
2360 Erik

Lägsta gruppen
1440 Rolf 
1430 Sven
1420 Ture
1410 Ulla
1400 Omar: Fyra vinster ger 1440 + 1430 + 1420 + 1410 = 5700 elos
```
Omar, med elo 1400, lyckades alltså komma före Adam med 2400 i rating.
Kommentar: Eftersom spelarna har närliggande elotal är fyra vinster av fyra osannolikt.  
Dock *kan* det inträffa. Man måste leva på hoppet!

### Subtraktion med 400
```
Högsta gruppen
2000 Adam: Fyra remier ger 995 + 990 + 985 + 980 = 3950 elos
1990 Bert
1980 Carl
1970 Dina
1960 Erik

Lägsta gruppen
1040 Rolf 
1030 Sven
1020 Ture
1010 Ulla
1000 Omar: Fyra vinster ger 1040 + 1030 + 1020 + 1010 = 4100 elos
```
Ordningen återställd

