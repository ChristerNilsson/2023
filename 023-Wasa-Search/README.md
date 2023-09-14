* Syftet med detta projekt är att kunna visa webbsidorna på mobiler.

* .lean transpileras till .html av lean2html.py

* Indentering sker med noll eller flera tab-steg
* Första ordet kan vara ett kommando
	* BOLD  | text - fetstil
	* HEADER | text - rubrik
	* LINK  | text | länk - Godtyckling länk
	* ANMÄL | text | länk - Länk till member.schack.se, anmälan
	* TOUR  | text | länk - Länk till member.schack.se, resultat
	* WASA  | text | länk - Länk till wasask.se
	* BB2   | text | länk - Länk till Bildbanken 2
	* DOT                 - •
	* A     | text | länk - Naken länk: ```<a href=länk>text</a>```
	* Blanka rader är signifikanta

HTML kan användas. T ex ```<b></b>```  
Vokabulären har utökats med ```<red></red>``` och ```<green></green>```  

## Exempel

### 2023-04.lean (indata)
```
HEADER|Inbjudningar April 2023
WASA|Påskturneringen - GP|Inbjudan_Påskturneringen_2023.pdf
	Norrköping
	2023-04-07 • 2023-04-10
	TOUR|Resultat|10380
```
### 2023-04.html (utdata)
```
<div class="I0"><h2>Inbjudningar April 2023</h2></div>
<div class="I0"><a href='https://www.wasask.se/Inbjudan_Påskturneringen_2023.pdf'>Påskturneringen - GP</a></div>
  <div class="I1">Norrköping</div>
  <div class="I1">2023-04-07 • 2023-04-10</div>
  <div class="I1"><a href='https://member.schack.se/ShowTournamentServlet?id=10380'>Resultat</a></div>
```

## Style
Indenteringen styrs med "margin-left"
```
<style>
  .I0 {margin-left: 0px}
  .I1 {margin-left: 20px}
  .I2 {margin-left: 40px}
  .I3 {margin-left: 60px}
  .I4 {margin-left: 80px}
</style>
```

## Sökning

### Metod
Se till att Google kravlar sig genom filerna.  
[Google Search Console](https://search.google.com/search-console?resource_id=https://christernilsson.github.io/2023-023-Wasa-Search/)

### Plan B
Samla sajtens innehåll (.lean) i en json som söks linjärt efter förekomster.  
Denna .json laddas bara när man vill söka. Länkarna presenteras.  
.json-filen byggs av lean2html.py  

## Run On Save
Kör alla filer just nu.
```
	"match": "\\.lean$",
	"cmd": "cd ${workspaceRoot} && python lean2html.py"
```

## Kalender
* Detta är startskärmens utseende.
* Dagens datum är markerat, 2023-04-29
* Dagens enda aktivitet, Wasa JGP, har attributen Junior samt Distrikt
* Klicka på annan dag för att byta dag
* Klicka på Förra eller Nästa för att byta månad.
* De färgglada knapparna har state. Totalt 4x4=16 möjliga.
```
  S J T -
K x x x x
D x x x x
N x x x x
- x x x x
```
* Reset återställer datum och visar alla events.
* Inre ringen visar Senior/Junior/Tjej
* Yttre ringen visar Klubb/Distrikt/Nation

![Kalender](images/screenDump.JPG)