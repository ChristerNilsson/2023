import json
import datetime

def checkDates(dates):
	for date in dates.split(' '):
		try:
			datetime.datetime.strptime(date, '%Y-%m-%d')
		except ValueError:
			print("Incorrect date format, should be YYYY-MM-DD",date)

def transpile (filename) :
	with open(filename,encoding='utf8') as f:
		s = f.read()
	res = []
	for line in s.split("\n"):
		arr = line.split("|")
		hash = {}
		for i in range(len(arr)):
			if arr[i][1]==':':
				key = arr[i][0]
				hash[key] = arr[i][2:]
				if key=='d': checkDates(hash[key])
				if key=='q' and len(hash[key]) <= 5: hash[key] = "https://member.schack.se/turnering/" + hash[key] + "/anmalan"
				if key=='r' and len(hash[key]) <= 5: hash[key] = "https://member.schack.se/ShowTournamentServlet?id=" + hash[key]
			else:
				print('error in line',i,arr[i])
		res.append(hash)

	with open(filename.replace('.txt','.json'), 'w', encoding='utf8') as g:
		g.write(json.dumps({'events':res},ensure_ascii=False).replace('"}, ','"},\n'))

transpile('kalender.txt')

# keys:
# t = title
# d = dates
# i = inbjudan
# q = anmälan
# r = result
# a = attributes
	# attribute:
	# J=Junior S=Senior F=Flicka
	# K=Klubb D=Distrikt N=Nation
	# L=Lag-DM A=Allsvenskan C=Stockholmsserien (T=Träning)

# Givet månad filtreras denna json på valda attribut.
# Resultatet visas under kalendern i porträtt mode.
# T ex:

# Visa en dag!

#    to 13 maj
# Wasa föredrag
# Wasa Juniorträning
# Wasa JGP [i] [q] [r]