Hej Christer

H�r �r en katalog med filer som (p� min maskin) g�r att kompilera med f�ljande version av Lazarus.
Lazarus �r det verktyg som brukar anv�ndas f�r att editera, kompilera och testa program skrivna i Free Pascal.
Man trycker ctrl-F9 (= run/compile) f�r att kompilera programmet.

N�r man laddar ner Lazarus, brukar man samtidigt f� Free Pascal.

Min version av Lazarus heter 1.8.ORC5 fr�n 2017-10-11.
Free pascal compiler (FPC) har version 3.0.4 (SVN revision: 56026 i386-win32-win32/win64 om det nu s�ger dig n�got).

OBS att man m�ste installera f�r en 32-bitars maskin, eftersom assembler instruktionerna f�r DLL annars inte kommer att kompilera eller att k�ra (kommer inte ih�g vilket).

Om Du lyckas kompilera x, s� kommer Du nog beh�va ett exempelscript fr�n mig f�r att testa om den fungerar.
F�r att bara f� en uppfattning om tillg�ngliga funktioner, kan man skriva <help> f�r att f� en lista av funktioner och <help (funktionsnamn)> f�r en beskrivning av en viss funktion.

De mest grundl�ggande functionerna �r:
<var ...> - skapa variabel.
<set ...> - Tilldela ett v�rde (en str�ng till en variabel)
<function ...> - Skapa en funktion

Du startar programmet genom att k�ra x.exe. 
Det finns chans att ditt antivirusprogram kommer att vilja stoppa exekveringen av x.exe, kanske f�r att den inneh�ller funktionen <command ...> som kan g�ra DOS-kommandon.
Men x.exe inneh�ller bara enkla funktioner som Du sj�lv kan anropa.  

Jag har F-secure. F�r att kunna k�ra x.exe m�ste jag undanta den katalog d�r x.exe ligger, fr�n n�got som heter DeepGuard.
Sedan �r det bara att k�ra.

H�lsningar
Bertil
