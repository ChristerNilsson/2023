 
## Bakgrund

Jag heter Christer Nilsson och har bl a utvecklat Monradprogrammet som användes flitigt under 90-talet av t ex Jonas Sandbom.  
2023 tog jag även fram [Bildbanken 2](https://storage.googleapis.com/bildbank2/index.html?query=Seniorschack) i samarbete med Lars OA Hedlund.

Bildbanken 2 består enbart av statiska filer, dvs det finns inget program som körs på någon server.  
I Bildbanken 2 är det katalogstrukturen som styr allt.

Med detta i bakhuvudet gör jag här ett försök att bygga upp en statisk hemsida utgående från katalogstrukturen.

Några high lights:

* Baserad på [markdown](https://www.markdownguide.org/cheat-sheet/).
* Anpassad för mobiler och äldre.
* De senaste Nyheterna visas direkt på startsidan.
* Markdown kan ses för en sida genom att klicka på rubriken.
* Alfabetisk eller kronologisk sortering.
* Bakåt-knappen fungerar som på iPhone och Androider och är obligatorisk.
    * Nya flikar skapas aldrig.
* [RSS](https://sv.wikipedia.org/wiki/RSS) på begäran.
* Open Source [Github](https://github.com/ChristerNilsson/2023/blob/main/023B-SeniorSchack/makeAll.py)

## Link

Files with extension .link contains a directory name, a markdown file name or an url.  
The reason behind it's existence is to display a proper menu name and sort correctly.

## Matrix

From       |Dir|.md|.link|other files
-----------|---|---|---|---
Dir        |Yes|Yes|Yes|Yes
.md        |Yes|Yes|   |Yes
.link      |Yes|Yes|   |Yes
other files|   |   |   |

* .md: ```[text](url)``` => ```<a href=url> text </a>```
* .link: Text file that contains a file path or an URL
* Other files: Can be .pdf, .txt and other files except .md and .link, or an URL
---
* .md can not refer to a .link file.  
* A .link file can not refer to another .link file.  
* Other files can not refer to anything.  
* In the produced .html files, .md and .link never occurs.

### Jämförelse av kodvolym

* Markdown utgör 40-50% av html:s storlek.
* De största befintliga sidorna, Klubben.html och Arkivet.html tar sammanlagt 57 kb.
    * Dessa kräver noll bytes iom att länkarna kan skapas automatiskt utifrån mappnamn och filnamn.
* Resterande 16 kb html, kan skapas med 7 kb markdownkod.
* Total reducering av kodvolym är alltså cirka 90%.

namn|html|markdown|enhet
---|---:|---:|---
index|10.3|3.0
program|5.5|1.8
klubben|22.4|0
arkivet|34.6|0
kontakt|0|1.4
ext länkar|0|0.9
totalt|72.9|7.1|kbyte

### Veckans kombination

Denna katalog ingår inte i jämförelsen, men här kan man spara 95%.
Vi har cirka 66 filer om 12K, dvs 800kB. Ett antal identiska javascriptfunktioner ingår i varje fil.
Pjäser och bräde är gemensamt.
Det som skiljer är 

* utplacering av pjäser.
* namn på spelarna
* lösningen

Antar att dessa har några år på nacken iom att chess.com och lichess har liknande saker.

### Dagens kombination 

Är uppbyggd på liknande sätt, men ligger online.

### Stor bild, 576 kilobyte!

138 x 138 x 3 = 57 kB.  
Borde vara 6 kb mtp komprimering.  
Filen är ett hundra gånger för stor.  

![](KM_SrS_24.jpg)

## Exempel på tabellhantering
 
 År |    Segrare
----|--------------
2021|[Hans Rånby (Seniorseriemästare hösten 2021)](SENIOR/htmfiler/resultat_HT21.pdf)
2021|[Olle Ålgars (Stockholms Veteranmästare 2021)](SENIOR/htmfiler/resultat_veteran_HT21.pdf)


# Nyheter

Datum|Evenemang
-----------|------------------------------------------------------------------------------
2024-03-04 |[Stockholmsmästerskapet 2024](files/Inbjudan_Stockholmsmästerskapet_2024.pdf)
2024-03-01 |[Ny rating](files/Ny_rating.pdf)
2024-02-17 |[Robert Spångbergs Minnesturnering 2024](files/Inbjudan-Robert-Spångberg-memorial-2024.pdf)
2024-02-15 |[En liten lathund för att hitta information om Seniorschacks KM på Chess-Results](SENIOR/htmfiler/Chess-Results.pdf)
2024-02-08 |[Frirondsblixten](files/Frirondsblixten.pdf)

# Meny

||
|------------------------------------------------------------------------------|
|[Stockholmsmästerskapet 2024](files/Inbjudan_Stockholmsmästerskapet_2024.pdf)|
|[Ny rating](files/Ny_rating.pdf)|
|[Robert Spångbergs Minnesturnering 2024](files/Inbjudan-Robert-Spångberg-memorial-2024.pdf)|
|[En liten lathund för att hitta information om Seniorschacks KM på Chess-Results](SENIOR/htmfiler/Chess-Results.pdf)|
|[Frirondsblixten](files/Frirondsblixten.pdf)|
