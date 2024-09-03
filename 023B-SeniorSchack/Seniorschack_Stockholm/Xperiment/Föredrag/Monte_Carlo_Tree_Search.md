
Fördel: Utvärderingsfunktion behövs ej.

* Selection. [Video som beskriver hur urvalet går till](https://youtu.be/UXW2yZndl7U?si=0CVSD6abn7tXbdRQ)
	* Det handlar om avvägning mellan framgångsrika drag och oprövade grenar.
* Expansion.
* Simulation. Innebär att dragen väljs slumpvis till någon vunnit eller remi inträffat.
* Backpropagation. Uppdatering från lövet till roten av bråken.

Noderna innehåller vinstandelar.

Svart är vid draget.

Roten: Vit har vunnit 11 av 21

7/10 väljs eftersom den noden är större än 3/8.

1/6 väljs eftersom den är mindre än 2/4

3/3 väljs eftersom den är större än 2/3

Simulering sker. Svart vann

3/3 uppdateras till 4/4

1/6 uppdateras till 1/7

7/10 uppdateras till 8/11

11/21 uppdateras till 11/22

Om tiden är ute, väljs 8/11 eftersom 11 är störst.

Störst antal partier avgör vilket drag som väljs.

![MCTS](MCTS-steps.svg)

[Wikipedia](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search) 
