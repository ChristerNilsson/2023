# Dense Pairings - ett alternativ till Swiss ?

Föreläsning för Senior Stockholm 2024 av Christer Nilsson

## Bakgrund

* Civ Ing Data Linköping 1981
* Monradprogram för MS-DOS utv i Turbo Pascal ca 1990 (ref Jonas Sandbom)
* Bildbanken 2.0 2024 (Ref Lars OA Hedlund)

## Historik

* Swiss skapades 1895 av Dr. Julius Müller (1857-1917) i Zürich.
* Monrad 
* Dutch (FIDE 1998)
* Burstein

## Swiss

* Inga spelare får mötas två gånger
* Färgerna ska fördelas jämnt, max två eller tre i rad
* Spelare delas in i grupper efter antal poäng
* Spelarna inom en *grupp* kan paras på olika sätt
  * Monrad: *Närliggande* paras ihop
  * Dutch: *Mittemellan*. Gruppen delas i två. De starkaste i delgrupperna paras ihop.
  * Burstein: *Avlägsna* paras ihop
* Om paret i slutet inte kan mötas måste man [backtracka](https://en.wikipedia.org/wiki/Backtracking).

## Kritik av Swiss
* Ojämna spelstyrkor i varje parti, ffa inledande ronder, även kallade *slaktronder*.
* Komplex algoritm, se FIDE:s handbok
* [JaVaFo](http://www.rrweb.org/javafo/aum/JaVaFo2_AUM.htm) används av de flesta lottningsprogram, t ex [Swiss Manager](https://swiss-manager.at/)
* Källkoden till JavaFo ej publicerad

## Elo-rating

* Skapades av fysikprofessorn Arpad Elo (1903-1992)
* Introducerades 1960 i USA
* Bygger på normalfördelningen
* Givet en ratingskillnad räknas en ratingförändring ut.
* Vidarutvecklingen Glicko används av chess.com och lichess.

## Teaser

Här visar jag hur en turnering med 78 deltagare, [Tyresö Open 2024](https://member.schack.se/ShowTournamentServlet?id=13664&listingtype=2), hanteras med Swiss samt Dense Pairings.  
Utgången av inledande ronder är ofta given och innebär en mindre stimulerande transportsträcka för båda spelarna.  
I denna turnering snabbades denna resa upp genom att de fyra första ronderna spelades med kortare betänktetid, 15m + 5s.  
Därefter följde fyra långpartier, 90m + 30s.  

För att bestämma hur väl en lottning motsvarar målet, utvecklades ett mätetal, benämnt Sparseness (gleshet).  
Detta beräknas genom att ta fram medelvärdet av alla partiers absoluta elo-differens.  
Sparseness för Swiss blev 220.4 och för Dense Pairings 44.85 (simulerat).  
Swiss är i detta fall, alltså fem gånger glesare än Dense Pairings.

[Swiss Dutch](swiss.txt)  
[Dense Pairings](dense.txt)  
[Dense vs Swiss](https://docs.google.com/spreadsheets/d/1DHRnlp8Q6RnnG-gF-fg0liyS2zZINEF5typxI497JyE/edit?usp=sharing)

Dense Pairings har utgångspunkten att alla ska möta spelare med liknande spelstyrka.  
Idealet är att varje spelare har en egen grupp đär spelaren själv ligger i mitten.  
Detta är dock omöjligt för spelarna i början och slutet av listan.  
Den som har högst rating kan bara spela med lägre ratade och tvärtom.  

### Dense Pairings

I varje rond paras spelare med närliggande rating ihop.  
Detta under förutsättning att de ej mötts förut och att färgerna är tillåtna.  
Partiresultat användes enbart för att avgöra ställningen efter varje rond och påverkar EJ lottningen.  
Detta innebär att när turneringen är färdigspelad kan det finnas flera spelare som har maximal poäng.    

Detta hanteras genom att istället för partipoäng ackumuleras elo-poäng för varje vinst eller remi.

* En vinst ger vinnaren hela förlorarens elo-rating.
* En remi ger båda spelarna halva motståndarens elo-rating.

Metodiken påminner om [Sonneborn-Berger](https://en.wikipedia.org/wiki/Sonneborn%E2%80%93Berger_score).  
I Swiss är en vinst mot den starkaste värd exakt lika mycket som en vinst mot den svagaste, vilket Dense Pairings alltså ändrar på.

## Några exempel på beräkningar

Nedanstående elos används enbart för att räkna ut ställningen, inte för att lotta.  

```
1600 Anna    - 1650 Britta   1-0
1700 Cecilia - 1770 Greta    0-1
1800 Sven    - 1900 Ture     ½-½

Anna får 1650 elos 
Greta får 1700 elos
Sven får 950 elos (remi)
Ture får 900 elos (remi)
```

## Maximum Weight Matching
* Länkar skapas mellan alla spelare som *kan* paras (78 * 77 / 2 = 3003 stycken)
* Varje länk har en kostnad, i vårt fall den absoluta elo-skillnaden
* Algoritmen levererar en lista med de länkar som ger lägsta totala kostnad

## Dense Pairings vs Bergergrupper
* Berger ger större gleshet, pga fler hörn
* Berger ger fler frironder, eftersom spelare ej flyttas mellan grupperna
* Berger ger flera vinnare, som ej är jämförbara
* Berger ger samma poäng för ett vinstparti oavsett spelstyrka.

## Referenser

* [Swiss Tournament](https://en.wikipedia.org/wiki/Swiss-system_tournament)
* [Elo Rating](https://en.wikipedia.org/wiki/Elo_rating_system)
* [Maximum Weight Matching: Jack Edmonds 1965](https://en.wikipedia.org/wiki/Blossom_algorithm)
* [FIDE Handbook](https://handbook.fide.com)
* [Glicko Rating System](https://en.wikipedia.org/wiki/Glicko_rating_system)
* [Improving Ranking Quality and Fairness in Swiss-System Chess Tournaments](https://arxiv.org/html/2112.10522v2)
* [Designing Chess Pairing Mechanisms](https://real.mtak.hu/80729/7/jXaio4T11ygd57-77-86.pdf)





[swiss_36.txt](swiss_36.txt)  
[tight_36.txt](tight_36.txt)  

Till programmanualen


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



