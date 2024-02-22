 ## Bakgrund

Jag heter Christer Nilsson och har bl a utvecklat Monradprogrammet som användes flitigt under 90-talet av t ex Jonas Sandbom.  
2023 tog jag även fram [Bildbanken 2](BB2?query=Seniorschack) i samarbete med Lars OA Hedlund.

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

This is a **markdown** file and is translated by *makeAll.py* to an **.html** file with the same name.

CONTENT

## .link

Files with this extension may contain a directory name, an html filename, a filename or an url.  
A **.link** file can be replaced by an **.md file**,  
but the user would see an extra menu level  
and thus have to use one extra *click*.  
You could say, the .link file acts as a shortcut.  

## From/To Matrix

From/To|Dir|.md|.link|url
-------|---|---|-----|---
Dir    |Yes|Yes|Yes  |Yes
.md    |Yes|Yes|     |Yes
.link  |Yes|Yes|     |Yes
url    |   |   |     |

**Yes**: a clickable link will be produced in the resulting html file.

* .md: ```[text](url)``` => ```<a href=url> text </a>```
* .link: Text file contains a url or file path
* url: Can also be any file except .md and .link
---
* .md can not refer to a .link.
* .link can not refer to another .link.
* In the produced .html file, .md and .link never occurs as targets.

## General advice

* Start with the folders
* Add files to your folders
* Add .link files to use urls
* Add an index.md file to show text, images and tables.
* Add an index.md file if you prefer another sort order
    * e.g. if your files start with a week day or a month name
        * fri mon sat sun thu tue wed
        * apr aug dec feb jan jun jul mar may nov oct sep
* Add html code to your .md files if necessary.
* Give all folders and files nice, short names, acceptable as menu names.
    * For the ```/files/news``` folder, start all file names with a date, using the format YYYY-MM-DD.
* style.css can be used to customize your pages.
    * font
    * font size
    * colours
    * link decoration
    * paddings and margins
    * style.css can be defined in every folder.
        * Sheets closer to the leaf overrides sheets closer to the root.
        * Try changing color of the links in this folder: ```a {color:green}```

## files

This folder contains files you don't want to be processed.

### Keywords

* **CON_TENT** is used as a placeholder that will be replaced by folder names, .md names, .link names and other file names stored in the *current* folder. Don't forget to remove the underscore.
* **PO_STS** is used as a placeholder that will be replaced by foldernames, markdown names, link names and other filenames stored in the **files/posts** folder.
    * Only the latest files will be displayed, as specified by the setting *latestPosts* = 5.

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


Common HTML codes:

* ```<a></a>```
* ```<b></b>```
* ```<body></body>```
* ```<br></br>```
* ```<div></div>```
* ```<font></font>```
* ```<h1></h1>```
* ```<h2></h2>```
* ```<h3></h3>```
* ```<head></head>```
* ```<hr>```
* ```<html></html>```
* ```<img></img>```
* ```<li></li>```
* ```<link></link>```
* ```<meta></meta>```
* ```<ol></ol>```
* ```<p></p>```
* ```<script></script>```
* ```<strong></strong>```
* ```<style></style>```
* ```<table></table>```
* ```<td></td>```
* ```<th></th>```
* ```<thead></thead>```
* ```<title></title>```
* ```<tr></tr>```
* ```<ul></ul>```


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


