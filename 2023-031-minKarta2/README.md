# 2023-031-minKarta2

# Målsättning

Använda minkarta för att 
* Visa var man är
	* Omvandla WGS84 till SWEREF med proj4
* Hämta hem frimärken, 256 * 256, 512 * 512 osv. Lagras ej.
* Mha hårkors kunna sätta target
* Beräkna avstånd
* Beräkna bäring, troligen via WGS84 och latlon-spherical.js
* Fast zoomlägen
* Spara brödsmulor, komprimerat, via 4 kvadranter och 8x8. En meters noggrannhet. Ett tecken per position.
	* Dessa spår mailas om de ska sparas. Kan läggas in manuellt och göras tillgängliga.

# Teknikstack
* civet transpilerat till typescript/javascript
* p5.js
* fasta ljud (text -> speech fungerar inte så bra på iOS)

# Tidigare projekt
* 2021/013-gpsKarta2
* gpsKarta

# Frimärken
* Dessa har ett origo, troligen SWEREF 6553600, 655360.
* Utifrån detta origo, finns kartor som kan hämtas med angivande av rad och kolumn, i storlekar 256x256, 512x512 osv
	* TileCol: 0 och uppåt
	* TileRow: 0 och uppåt
	* TileMatrix: 0 på högsta nivån
