
Fördel: Utvärderingsfunktion behövs ej.

* Selection. [Video som beskriver hur urvalet går till](https://youtu.be/UXW2yZndl7U?si=0CVSD6abn7tXbdRQ)
	* Det handlar om avvägning mellan framgångsrika drag och oprövade grenar. [Länk](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search#Exploration_and_exploitation)
* Expansion.
* Simulation. Innebär att dragen väljs slumpvis till någon vunnit eller remi inträffat.
* Backpropagation. Uppdatering från lövet till roten av bråken.

Noderna innehåller vinstandelar.

Svart är vid draget.

Roten: Vit har vunnit 11 av 21

7/10 väljs här, pga C=sqrt(2). (0/3 väljs om C=2)

1/6 väljs

3/3 väljs

Simulering sker. Svart vann

3/3 uppdateras till 4/4

1/6 uppdateras till 1/7

7/10 uppdateras till 8/11

11/21 uppdateras till 11/22

Om tiden är ute, väljs 8/11 eftersom nämnaren 11 är störst.

Störst antal partier avgör alltså vilket drag som väljs.

![MCTS](MCTS-steps.svg)

[Wikipedia](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search)  
