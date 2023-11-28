[Try it!](https://christernilsson.github.io/2023/044-Monrad)

### ToDo

* Slumpa namnen om ORC saknas!
* Blankett att fylla i resultatet (bordslista). En för varje rond.
* E= (ELO-rating) förberedelse för Swiss
* TB= (Tiebreaks) Prioritetsordning
* P= (partier per match) Lagturneringar
* R= Antal ronder ska kunna anges. Default används annars, cirka 1.5*log2(N)
* Ändra Result till Score
* Scores anges med ett tecken. T ex åtta spelare: 0123456789abcdefg 0:0-8 1:½-7½ .. f:7½-½ g:8-0

### Prestanda, utan utskrifter, millisekunder
N = antal spelare
R = antal ronder
```
   N  R   JS Python 3.10
   8  3    3
  16  6    6
  32  8    7
  64  9    8

ej tillgängligt:
 128 11   14 
 256 12   33
 512 14   75
1024 15  129 1476
2048 17  521 6086
4096 18 1821 28 sek
8192 20 7457 81 sek
```

### URL
```
N=8 R=4

http://127.0.0.1:5500/index.html?
T=KM_Blixt_Wasa_SK&
D=2023-11-25&
N=Adam_Adamsson|Bertil_Bertilsson|Cesar_Cesarsson|David_Davidsson|Erik_Eriksson|Filip_Filipsson|Gustav_Gustavsson|Helge_Helgesson&
O=0123|1234|1234|1234|1234|1234|1234|1234|1234&
C=BWBW|BWBW|BWBW|BWBW|BWBW|BWBW|BWBW|BWBW|BWBW&
R=1021|1021|1021|1021|1021|1021|1021|1021|1021&
TB=SBC

N=Adam_Adamsson|Bertil_Bertilsson|Cesar_Cesarsson|David_Davidsson|Erik_Eriksson|Filip_Filipsson|Gustav_Gustavsson|Helge_Helgesson
O=0123|1234|1234|1234|1234|1234|1234|1234|1234 (Opponents: 64-kodning, dvs 0-9 a-z A-Z - / )
C=BWBW|BWBW|BWBW|BWBW|BWBW|BWBW|BWBW|BWBW|BWBW (Color:     B=Black W=White)
R=1021|1021|1021|1021|1021|1021|1021|1021|1021 (Result:    0=Loss 1=Remis 2=Win)

This will be stored internally as:
[{id:0, name:"Adam Adamsson, opps:[0,1,2,3], color:[-1,1,-1,1], result:[1,0,2,1]}, ...]

20 * N + 3 * N * R = 160 + 96 = 256 tecken

N=64 R=10
20 * N + 3 * N * R = 1280 + 1920 = 3200 tecken

Minimal URL, bara namn. N:
http://127.0.0.1:5500/index.html?N=Adam_Adamsson|Bertil_Bertilsson|Cesar_Cesarsson|David_Davidsson|Erik_Eriksson|Filip_Filipsson|Gustav_Gustavsson|Helge_Helgesson

Möjliga kombinationer: Names [Opponents Color Result] [Date] [Title]. Bara Names är obligatoriskt.

```

# Tie Breaks
* Sonneborn-Berger
* Direct Encounter
* Black
* Win
* 1 = Buchholz 1
* 2 = Buchholz 2
* Fide Tiebreak

T ex TB=SDBW12F (valfritt antal tecken, default=???)

# Laghantering
* Ange antal partier i egen variabel
* Tillåt inmatning av dessa resultat. T ex genom upprepade klick
	* Klick på vit ökar med 1, Klick på svart minskar med 1, klick på remi ökar/minskar med 1/2
	* Fyra spelare => nil 0-4 1-3 2-2 3-1 4-0 cykliskt
	* Åtta spelare => nil 0-8 1-7 2-6 3-5 4-4 5-3 6-2 7-1 8-0 cykliskt
* Parameter P=4 eller P=8. Default=1

# Kontroller av URL.
* Antal spelare skall överensstämma i N, O, C och R
* Antal ronder skall överensstämma i O C och R
* Tillåtna tecken I N: I princip alla möjliga. De kodas/avkodas automatiskt. T ex åäöÅÄÖéæýþÿüïœßđèùúøàáçìíñμ-. Emojis?
* Tillåtna tecken i O: 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-/ (64 tecken)
* Tillåtna tecken i C: BW (två tecken)
* Tillåtna tecken i R: 012 (tre tecken)

### Begränsningar
* 4 till 64 spelare
* Kan ganska enkelt utvidgas till 4096 spelare (två tecken per spelare, 64-kodat. 64*64=4096)

### Frågor
* Ska man se till att antaler ronder alltid är jämnt ? (Av färgrättviseskäl)
* Vad är lämpligt antal ronder, givet N spelare ?
* Visa placering som 12 (plats, Jämn=Vit, Udda=Svart) eller 6W (bord + färg) ?
