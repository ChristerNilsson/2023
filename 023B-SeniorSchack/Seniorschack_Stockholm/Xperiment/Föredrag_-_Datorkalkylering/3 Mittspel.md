*Mittspelet är komplexare än öppningen och slutspelet.  
Här måste alla drag genereras och ett träd genomsökas.  
Att utvärdera ställningen i schack är komplicerat.  
Därför använder jag barnspelet Kalaha (8+) här.  
Minimaxfunktionen är dock densamma som i schack.*

## Kalaha

![Kalaha](X_kalaha.jpg)

### Regler

0. Varje spelare har sex gropar, ABCDEF, plus en poänggrop
1. Fyra kulor placeras i var och en av de sex groparna
2. Spelarnas poäng ges av poänggropen till höger
3. Ett drag: Man tar alla kulorna i en av groparna. Dessa droppas moturs, en i taget. Man droppar i sin egen poänggrop, men inte i motståndarens 
4. Om sista kulan droppas i en *egen* *tom* grop, tar man den plus motståndarens kulor och lägger i sin egen poänggrop     
5. Om den sista kulan droppas i den egna *poänggropen*, får man ett bonusdrag. Man kan få flera bonusdrag
6. Kan en spelare inte göra något drag, avslutas spelet. Den andre spelaren får alla tolv groparnas innehåll. Spelaren med flest kulor vinner

### Draggenerering

Följande tio drag kan utföras i utgångsläget:
A B CA CB CD CE CF D E F  

Uppgift: Givet att vit börjar med CF, vilka drag kan svart göra?

### Evaluering

Uppgift: Evaluera dessa tio ställningar!

### Sökdjup (Level)

Sökdjupet anger hur många halvdrag som görs innan evaluering sker.
Datorns spelstyrka regleras så här:
* Sökdjupet ökar med ett om människan vinner
* Sökdjupet minskar med ett om människan förlorar
* Sökdjupet ändras ej vid remi

### Minimax 

![Minimax](X_minimax.png)

### Evaluering i schack

* Material (t ex 100,350,280,500,900)
* Pjäsrutor
	2 * 6 * 64 = 768 heltal
* Mobilitet
	* Hur många drag spelaren kan göra i den givna positionen
* Kungens säkerhet
* Bondestruktur
	* Dubbelbönder
	* Ensamma bönder
	* Avancemang  
* osv.

### Länkar

[Wikipedia](https://en.wikipedia.org/wiki/Kalah)
[Spel](https://christernilsson.github.io/Lab/2019/118-Kalaha/)
[Binärt Träd](X_tree.svg)
[Nokia 3310](https://youtube.com/clip/Ugkxax12m2ISro9LvHjkgzt_ZY9GwCM0f3Vh?si=J4J9fmi1io-Wgexb)
[Minimax - källkod](https://github.com/ChristerNilsson/Lab/blob/master/2019/118-Kalaha/coffee/minimax.coffee)
[Chess Programming](https://www.chessprogramming.org/Main_Page)
[Chess.stackexchange](https://chess.stackexchange.com)
[Python Chess](https://python-chess.readthedocs.io/en/latest)

<iframe src="https://christernilsson.github.io/2024/118-Kalaha/?scale=0.5" title="Kalaha" style="border:0; width:460px; height:170px;"></iframe>
