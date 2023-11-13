import {r4r,div,a,button,input,br,table,tr,td,th,span} from '../js/utils.js'

title0 = "Wasa SK"
title1 = "Wordpress"
title2 = "Google"
URL0 = "https://www.wasask.se"
URL1 = "https://www.wasask.se/aaawasa/wordpress/?s="
URL2 = "https://www.google.com/search?q=site:wasask.se "

title3 = "Stockholms SF"
title4 = "Wordpress"
title5 = "Google"
URL3 = "https://stockholmsschack.se"
URL4 = "https://stockholmsschack.se/?s="
URL5 = "https://www.google.com/search?q=site:stockholmsschack.se "

title6 = "Sveriges SF"
title7 = "Wordpress"
title8 = "Google"
URL6 = "https://schack.se"
URL7 = "https://schack.se/?s="
URL8 = "https://www.google.com/search?q=site:schack.se "

title9  = "Alternativa kollektioner"
title10 = "Bildbanken 1"
title11 = "Bildbanken 2"
URL9  = "https://wasask.se/SSF.Bildkollektioner.version2.php"
URL10 = "https://bildbanken.schack.se/?query="
URL11 = "https://storage.googleapis.com/bildbank2/index.html?query="

#URL9 = "https://www.google.com/search?q=site:https://www.svenskalag.se/wasask-seniorer "
#URL10 = "https://www.google.com/search?q=site:https://www.svenskalag.se/wasask-juniorer "

N = ""
J = "Ja"

data = null
click  = (url) => window.location = url + data.value
click0 = (url) => window.location = url

makeButtons = (url0, url1, url2, title0, title1, title2) => [
	tr {},
		if url0 != '' and title0 != ''
			td {},
				button {style:"font-size:30px; text-align:center; width:270px", onclick: => click0 url0}, title0
		else
			td {}
		td {},
			button {style:"font-size:30px; text-align:center; width:270px", onclick: => click url1}, title1
		td {},
			button {style:"font-size:30px; text-align:center; width:270px", onclick: => click url2}, title2
]

tds = {style:"border:1px solid black; text-align:left"}
tdt = {style:"border:1px solid black"}

rubrik = (a,b,c) =>
	tr {},
		th tds, a
		th tds, b
		th tds, c

rad = (a,b,c,d="") =>
	tr {},
		td tds, a
		td tdt, b
		td tdt, c
		td tds, d

queryString = window.location.search
urlParams = new URLSearchParams queryString
if urlParams.size == 6
	title0 = urlParams.get 'title0'
	title1 = urlParams.get 'title1'
	title2 = urlParams.get 'title2'
	URL0 = urlParams.get 'URL0'
	URL1 = urlParams.get 'URL1'
	URL2 = urlParams.get 'URL2'

r4r =>
	div {style:"font-size:30px; text-align:center"},
		br {}
		data = input {style:"font-size:30px; width:540px", autofocus:true, placeholder:"ange noll eller flera sökord"}
		br {}
		br {}
		table {style:"border:1px solid black; margin:auto; border-collapse: collapse;"},
			makeButtons URL0, URL1, URL2, title0,title1,title2
			makeButtons URL3, URL4, URL5, title3,title4,title5
			makeButtons URL6, URL7, URL8, title6,title7,title8
			makeButtons URL9, URL10, URL11, title9,title10,title11
#			makeButtons URL9, URL10, "Svenska Lag Sr","Svenska Lag Jr"
		br {}
		table {style:"font-size:24px; border:1px solid black; margin:auto; border-collapse: collapse;"},
			rubrik "Feature", "BB1", "BB2"
			rad "Bildtext", N, J
			rad "Länk till Inbjudan", N, J
			rad "Länk till Resultat", N, J
			rad "Länk till Video", N, J
			rad "Zoom", N, J, "Klick + rullhjul"
			rad "Panorering", N, J,"Klick + mushasning"
			rad "Bildspel", N, J, "Add + Play"
			rad "Högupplösta bilder", N, J,"Klick"
			rad "Sökning med OCH", J, J, "anges ej"
			rad "Sökning med ELLER", N, J, "anges ej"
			rad "Sökning på hela ord", J, J, "All = [x]"
			rad "Sökning på orddelar", N, J,"All = [  ]"
			rad "Skiftlägesokänslig", J, J, "Case = [  ]"
			rad "Skiftlägeskänslig", N, J, "Case = [x]"
			rad "Sökning i filnamn", J, J
			rad "Sökning i katalognamn", N, J
			rad "Sökning i viss katalog", N, J
			rad "Korrekt kronologi", N, J,"Kamerans tid"
			rad "Sökning i text i bild", J, N
			rad "Kräver webbserver", J, N

