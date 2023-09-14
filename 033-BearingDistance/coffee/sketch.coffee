Version = 110

# Alternativa koordinater:
# 67 52 4.9 N 18 37 11.2 E (WGS84 grader, minuter, sekunder)    implementerat
# 67.123456 18.123456    (WGS grader, decimaler)                implementerat
# N 6574412, E 679424    (SWEREF meter)                      ej implementerat

points = {}
pLat = 0
pLon = 0

convert1 = (deg,min,sek) =>
	deg = parseFloat deg
	min = parseFloat min
	sek = parseFloat sek
	(deg + min/60 + sek/3600).toFixed 6

convert = (point) ->
	[deg1, min1, sek1, z1, deg2, min2, sek2, z2] = point.split ' '
	[convert1(deg1,min1,sek1), convert1(deg2,min2,sek2)]
save = (s,name) => points[name] = if "N" in s and 'E' in s then convert s else s.split ' '

# Dessa punkter bör ligga i en .jsonfil!
# De bör sparas i localStorage
# Man ska kunna lägga till via URL

save "67 52 4.9 N 18 37 11.2 E", "Kebnekajse Turiststation"
save "67 54 2.8 N 18 31 2.6 E",  "Sydtoppen"
save "67 54 17.2 N 18 31 41.1 E","Nordtoppen"
save "67 54 41.8 N 18 36 35.4 E","Tarfalastugan"
save "67 51 1.4 N 18 18 55.2 E", "Singistugorna"
save "67 53 55.6 N 18 30 47.4 E","Kebnekajse Toppstuga"
save "67 51 2.7 N 19 0 47.4 E",  "Nikkaluokta"
save "59 15 54.6 N 18 7 58.1 E", "Varmfrontsgatan 1"
save "59 16 13.8 N 18 8 54.5 E", "Brotorpsstugan"
save "59 16 38.7 N 18 9 48.7 E", "Ulvsjön"
save "59 16 36.7 N 18 11 17.8 E","Sandakällan"
save "59 19 8.9 N 17 58 7.8 E",  "Bergviksvägen 24"
save "21 25 21.0 N 39 49 34.2 E","Kaban"
save "68 17 10.3 N 18 35 26.3 E","Abiskojaure"
save "68 21 31 N 18 47 0.7 E",   "Abisko Fjällstation"
save "68 20 59.2 N 18 50 1.8 E", "Abisko Guesthouse"
save "67 52 3.7 N 20 13 37.8 E", "Kiruna STF Malmfälten Campingv 3"
save "67.856408 20.225450",      "Lars Janssonsgatan 17 Kiruna"
save "67 52 6.1 N 20 11 58 E",   "Kiruna Järnvägsstation"

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then message = 'Check location permissions'
locationUpdate = (p) ->
	pLat = p.coords.latitude.toFixed 6
	pLon = p.coords.longitude.toFixed 6

setup = ->
	createCanvas innerWidth, innerHeight
	textSize 50
	noLoop()
	# frameRate 0
	# xdraw()

draw = ->
	console.log 'draw'
	background 'gray'
	if pLat==0
		text Version, 100,100
		text 'Click!',100,150
		return
	lst = []
	for name, [lat,lon] of points
		a = LatLon pLat, pLon
		c = LatLon lat, lon
		bearing = a.bearingTo c
		distance = a.distanceTo c # meters
		lst.push [distance, bearing, name]
	lst.sort (a,b) -> a[0]-b[0]
	for [distance, bearing, name],i in lst
		d = new Date()
		d = d.toLocaleTimeString('se-SV',{ hour12: false })
		text d, 100, 60
		y = 60+80*(i+1)
		textAlign RIGHT
		fill 'yellow'
		text bearing.toFixed(0)+"°", 120, y
		fill 'black'
		if distance < 1000
			text distance.toFixed(0)+' m', 350, y
		else if distance < 10000
			text (distance/1000).toFixed(2)+' km', 350, y
		else if distance < 100000
			text (distance/1000).toFixed(1)+' km', 350, y
		else
			text (distance/1000).toFixed(0)+' km', 350, y
		textAlign LEFT
		text name, 400, y

touchStarted = (event) ->
	if navigator.geolocation
		navigator.geolocation.getCurrentPosition locationUpdate, locationUpdateFail,
			enableHighAccuracy: true
			maximumAge: 30000
			timeout: 27000
	else
		console.log 'No location support'
	redraw()
