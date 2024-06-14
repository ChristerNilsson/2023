# Swiss Tight Pairer

First I would like to show the different pairings of 

[Tyresö Open 2024 78]() 

[Swiss Dutch 78](swiss.txt)  
[Swiss Tight 78](tight.txt)  

[swiss_36.txt](swiss_36.txt)  
[tight_36.txt](tight_36.txt)  

Swiss Dutch has some slaughter rounds in the beginning of every tournament.
These are quite boring as the superiour player almost always win.
Tight Pairer tries to make similar strength players meet more often.
To calculate the ultimate winner, elo points are accumulated for every win or draw.

* Winner gets the Elo rating of the other player
* Drawer gets half the Elo of the other player
* Black eventually receives a bonus, depending on SP

* Scorepoints         SP=0.1 (default 0.0)
	* Drawing as White = 0.4 (default 0.5)
	* Drawing as Black = 0.6 (default 0.5)
	* Winning as White = 1.0 (default 1.0)
	* Winning as Black = 1.2 (default 1.0)

* Open Source
* The database == The URL
* Keyboard only - No Mouse
* Backup files downloaded automatically after every pairing
* Player with zero Elo is considered to have 1400.

## Advantages

* Players will meet similar strength players
* One person maximum needs a bye. Compare this with Berger.
* Available in the browser.
* Pages can be zoomed


## Example 1, SP=0.0
```
Player Elo   Result  Factor
White  2400  ½       0.5
Black  1600  ½       0.5

Black gets 2400 * 0.5 = 1200 points
White gets 1600 * 0.5 =  800 points
```

## Example 2, SP=0.1
```
Player Elo   Result  Factor
White  2400  ½       0.4
Black  1600  ½       0.6

Black gets 2400 * 0.6 = 1440 points
White gets 1600 * 0.4 =  640 points
```

## Example 3, SP=0.1

```
Player Elo   Result  Factor 
White  2400  0       0 
Black  1600  1       1.2

Black gets 2400 * 1.2 = 2880 points
If white wins, white will get 1600 * 1 = 1600 points
```

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
