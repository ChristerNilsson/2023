Hej Christer

Här är en katalog med filer som (på min maskin) går att kompilera med följande version av Lazarus.
Lazarus är det verktyg som brukar användas för att editera, kompilera och testa program skrivna i Free Pascal.
Man trycker ctrl-F9 (= run/compile) för att kompilera programmet.

När man laddar ner Lazarus, brukar man samtidigt få Free Pascal.

Min version av Lazarus heter 1.8.ORC5 från 2017-10-11.
Free pascal compiler (FPC) har version 3.0.4 (SVN revision: 56026 i386-win32-win32/win64 om det nu säger dig något).

OBS att man måste installera för en 32-bitars maskin, eftersom assembler instruktionerna för DLL annars inte kommer att kompilera eller att köra (kommer inte ihåg vilket).

Om Du lyckas kompilera x, så kommer Du nog behöva ett exempelscript från mig för att testa om den fungerar.
För att bara få en uppfattning om tillgängliga funktioner, kan man skriva <help> för att få en lista av funktioner och <help (funktionsnamn)> för en beskrivning av en viss funktion.

De mest grundläggande functionerna är:
<var ...> - skapa variabel.
<set ...> - Tilldela ett värde (en sträng till en variabel)
<function ...> - Skapa en funktion

Du startar programmet genom att köra x.exe. 
Det finns chans att ditt antivirusprogram kommer att vilja stoppa exekveringen av x.exe, kanske för att den innehåller funktionen <command ...> som kan göra DOS-kommandon.
Men x.exe innehåller bara enkla funktioner som Du själv kan anropa.  

Jag har F-secure. För att kunna köra x.exe måste jag undanta den katalog där x.exe ligger, från något som heter DeepGuard.
Sedan är det bara att köra.

Hälsningar
Bertil
