Slutspel kan hanteras utan trädsökning med upp till sju pjäser.  
Dragen är perfekta. 
De räknas ut inom någon millisekund.  

Vi kommer här att se närmare på KRK, dvs Kung och torn mot ensam Kung.

* Filerna [krk_black](http://tablebase.sesse.net/3-4-5/krk.nbb.emd) och [krk_white](http://tablebase.sesse.net/3-4-5/krk.nbw.emd) innehåller cirka 28.000 positioner.

* För varje position anges antal halvdrag till matt 
* För att hitta det bästa draget måste man
    * Skapa alla positioner nåbara med ett halvdrag.
    * Söka upp dessa positioner i filen och få fram antal halvdrag till matt.
    * Välja det bästa draget. 

Exempel   

[Ke5 Re6 Kh8](https://syzygy-tables.info/?fen=7k/8/4R3/4K3/8/8/8/8_w_-_-_0_1)

## Exempel på innehåll i filerna KRK

Filerna innehåller ej dragen och är binärfiler.  
Man måste använda ett speciellt program där man går in med var och en av positionerna man vill slå upp. T ex returnerar Kf6, dvs "f6e6h8", värdet 6.  

Fil implementerad som en tredimensionell kub:  
64 * 64 * 64 * 1 = 262 kb  

Filen är hårt komprimerad, bl a med hjälp av rotationer och speglingar.  
Totalt 14 kb. Cirka 4 bitar per unik position.  

```
...
Kf6 6
Re7 8
Rg6 8
Kd6 10
Kf5 10
Kf4 12
Rf6 12
Kd5 14
...
```

# Databasstorlekar

```
Antal
pjäser      Storlek  Klar
3             27 kB  1975 (2 filer: KRK + KQK)
4          30 MB     1985 ca
5        1 GB        1995 ca
6      150 GB        2005
7    17 TB           2012
8  2000 TB           pågår
```

Åtta pjäser påbörjades 2012 och beräknas ta 2000 TB i anspråk.

Här kan man ladda ner [databaserna](http://tablebase.sesse.net/3-4-5/) för 3, 4 och 5 pjäser

Dessa databaser vill man inte lagra på sin laptop.  
Chess.com och Lichess har egna kopior av dessa databaser.  
Man kan nå dessa via ett [API](https://tablebase.lichess.ovh/standard?fen=7k/8/4R3/4K3/8/8/8/8%20w%20-%20-%200%201)  
Man anger sin position mha FEN och får tillbaks de möjliga dragen, sorterade bäst först.

[Wikipedia](https://en.wikipedia.org/wiki/Endgame_tablebase)  
[Ken Thompson](https://en.wikipedia.org/wiki/Ken_Thompson)  
[End Papers](https://web.archive.org/web/20090325093618/http://www.gadycosteff.com/eg/eg52.pdf)  