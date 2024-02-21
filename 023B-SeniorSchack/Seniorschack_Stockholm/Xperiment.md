 
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
* Alfabetisk sortering av menyalternativen.
* Kronologisk sortering av Nyheter.
* Bakåt-knappen används alltid för att lämna en sida.
* Nya flikar skapas aldrig.
* [RSS](https://sv.wikipedia.org/wiki/RSS) på begäran.
* Open Source på [Github](https://github.com/ChristerNilsson/2023/blob/main/023B-SeniorSchack/makeAll.py)

## .md

This is a Markdown a file and is translated by makeAll.py to an .html file with the same name.

## .link

Files with this extension may contain a directory name, a markdown filename, a filename or an url.  
A .link file can be replaced by an .md file, but the user would have to use one extra click.  
You could say, the .link file acts as a shortcut.

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

## General advice

* Avoid .html
* Avoid .md
* Avoid .link
* Give all directories and files nice, short names, acceptable as menu names.
    * For ```/files/news```, start all file names with a date, using the format YYYY-MM-DD.
* style.css can be used to customize your pages.
    * font
    * font size
    * colours
    * link decoration
    * paddings and margins

Consider markdown to be used for:
* text
* links
* decoration
* tables
* specifying your own sort order of a menu.
* adding html when markdown is too limited.

### Code volume comparison

* Markdown size is normally 40 to 50 % of html size.
* The largest sample pages, Klubben.html and Arkivet.html takes 57 kb.
    * These can be replaced with zero code as the links are automatically created using folder and file names.
* The last 16 kb html, can be defined using 7 kb markdown code.
* Total code volume reduction is around 90%.

name|html|markdown|unit
---|---:|---:|---
index|10.3|3.0
program|5.5|1.8
klubben|22.4|0
arkivet|34.6|0
kontakt|0|1.4
ext länkar|0|0.9
totalt|72.9|7.1|kb

### Markdown vs html

purpose|markdown
-------|---
header |#
header |##
header |###
bold   |```**text**```
link   |```[text](url)```
image  |```![text](url)```

```
purpose|markdown
-------|---
header |#
header |##
header |###
bold   |```**text**```
link   |```[text](url)```
image  |```![text](url)```
```

Html codes:
```
<html> 
  <head> 
    <meta>
    <link>
    <script> </script>
    <title> </title>
    <style>
    </style>
  </head>
  <body> 
    <h1> </h1>
    <h2> </h2>
    <h3> </h3>
    <a href=url> text </a>
    <b> text </b>
    <img href=url>> text </img>
    <div> </div>
    <p> </p>
    <table> 
      <thead> 
        <th> 
        </th> 
      </thead>
      <tr> 
        <td> 
        </td>
      </tr>
    </table> 
    <font> </font>
    <br>
    <strong> </strong>
    <hr>
    <ol> </ol>
      <li> </li>
  </body>
</html>
```

### Veckans kombination

This folder is not included in this comparison, but might save 95%.  
We have 66 files with a size of 12 kb each, in total 800 kb.  
A number of identical javascript functions are included in every file.  

Differences:  
* positions
* players
* solution

### Dagens kombination 

Is constructed in a similar way, but is online.

### Large picture, 576 kb!

138 x 138 x 3 = 57 kb.  
Should be 6 kb compressed.  
This file is one hundred times too large.  

![](KM_SrS_24.jpg)

# Table examples
 
 År |    Segrare
----|--------------
2021|[Hans Rånby (Seniorseriemästare hösten 2021)](SENIOR/htmfiler/resultat_HT21.pdf)
2021|[Olle Ålgars (Stockholms Veteranmästare 2021)](SENIOR/htmfiler/resultat_veteran_HT21.pdf)


## News

Datum|Evenemang
-----------|------------------------------------------------------------------------------
2024-03-04 |[Stockholmsmästerskapet 2024](files/Inbjudan_Stockholmsmästerskapet_2024.pdf)
2024-03-01 |[Ny rating](files/Ny_rating.pdf)
2024-02-17 |[Robert Spångbergs Minnesturnering 2024](files/Inbjudan-Robert-Spångberg-memorial-2024.pdf)
2024-02-15 |[En liten lathund för att hitta information om Seniorschacks KM på Chess-Results](SENIOR/htmfiler/Chess-Results.pdf)
2024-02-08 |[Frirondsblixten](files/Frirondsblixten.pdf)

## Menu

||
|------------------------------------------------------------------------------|
|[Stockholmsmästerskapet 2024](files/Inbjudan_Stockholmsmästerskapet_2024.pdf)|
|[Ny rating](files/Ny_rating.pdf)|
|[Robert Spångbergs Minnesturnering 2024](files/Inbjudan-Robert-Spångberg-memorial-2024.pdf)|
|[En liten lathund för att hitta information om Seniorschacks KM på Chess-Results](SENIOR/htmfiler/Chess-Results.pdf)|
|[Frirondsblixten](files/Frirondsblixten.pdf)|
