

Antag att vi har tio personer. Bilda en 10x10-matris med absoluta elodifferenser.  
Det räcker att ange 45 celler, eftersom matrisen är symmetrisk.
Första cellen: (1,2,3) pga 2416 - 2413 = 3
Andra cellen: (1,3,50) osv.


| |1|2|3|4|5|6|7|8|9|0|elo|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|1|*|1| | | | | | | | |2416
|2|1|*| | | | | | | | |2413
|3| | |*|1| | | | | | |2366
|4| | |1|*| | | | | | |2272
|5| | | | |*|1| | | | |2235
|6| | | | |1|*| | | | |2213
|7| | | | | | |*|1| | |2141
|8| | | | | | |1|*| | |2113
|9| | | | | | | | |*|1|2109
|0| | | | | | | | |1|*|2108

Blossom föreslår att rond 1 spelas enligt ovan, eftersom totalsumman av de fem cellerna då blir så låg som möjligt. (3 + 94 + 22 + 28 + 1 = 148)

Bordslista
|Bord||diff|
|:-:|-|-:|
|1|1 möter 2|3|
|2|3 möter 4|94|
|3|5 möter 6|22|
|4|7 möter 8|28|
|5|9 möter 0|1|

I nästa rond tar man bort de celler som spelats eller har förbjuden färgmatchning och får nya par.  

[Wikipedia](https://en.wikipedia.org/wiki/Blossom_algorithm) 