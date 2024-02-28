from lxml.html import fromstring
import requests
import time

URL = "https://member.schack.se/ShowTournamentServlet?id=13633&listingtype=2"
pageResp = requests.get(URL)
tree = fromstring(pageResp.text)

def ass(a,b):
    if a != b: print(a,'!=',b)

def fetch(s):
    s = '//' + s
    arr = s.split('.')
    res = tree
    for i in range(0,len(arr),2):
        index = int(arr[i + 1])
        items = res.xpath(arr[i])
        if index >= len(items): return None
        res = items[index]
    return res

def getText(s):
    res = fetch(s)
    return "" if res is None else res.text

def getClass(s):
    res = fetch(s)
    return "" if res is None else res.attrib['class']

start = time.time_ns()

ass('NAMN', getText('table.2.tr.0.td.3.span.0')) # Namn
ass('4',    getText('table.2.tr.0.td.13.span.0')) # Rond

ass('Anders Nystrand', getText('table.2.tr.1.td.3.span.0')) # Namn
ass('7',       getText('table.2.tr.1.td.13.div.0')) # Motståndare
ass('CP_White',getClass('table.2.tr.1.td.13.div.0')) # Color
ass('½',getText('table.2.tr.1.td.13.div.1')) # Resultat

ass('Carl Rollenhagen', getText('table.2.tr.2.td.3.span.0'))
ass('5',getText('table.2.tr.2.td.13.div.0'))
ass('½',getText('table.2.tr.2.td.13.div.1'))

ass('Christer Nilsson', getText('table.2.tr.3.td.3.span.0'))
ass('8',getText('table.2.tr.3.td.13.div.0'))
ass('1',getText('table.2.tr.3.td.13.div.1'))

names = [getText(f'table.2.tr.{i+1}.td.3.span.0') for i in range(11)]
print(names)

print()
results = [[getText(f'table.2.tr.{i+1}.td.{10+j}.div.0') for j in range(11)] for i in range(11)]
for result in results:
    print(result)

print()
results = [[getClass(f'table.2.tr.{i+1}.td.{10+j}.div.0') for j in range(11)] for i in range(11)]
for result in results:
    print(result)

print()
results = [[getText(f'table.2.tr.{i+1}.td.{10+j}.div.1') for j in range(11)] for i in range(11)]
for result in results:
    print(result)

print((time.time_ns() - start)/10**6,'ms')