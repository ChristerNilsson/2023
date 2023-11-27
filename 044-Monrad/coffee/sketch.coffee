# import random
# import time
# import math

# Klarar upp till 1950 spelare.
# 1600 spelar tar 1866 millisekunder för alla 16 ronderna. (Python)
# T1 är inbördes möte. Används bara för att särskilja två spelare
# T2 är antal vinster
# T3 är Buchholz. Summan av motståndarnas poäng

start = new Date()

seed = 12 # Math.random()
random = -> (((Math.sin(seed++)/2+0.5)*10000)%100)/100

print = console.log
range = _.range
pi = parseInt

sum = (arr) ->
	res = 0
	for item in arr
		res += item
	res

prod = (arr) ->
	res = 1
	for item in arr
		res *= item
	res

a = [11,3,31,1,2,23]
# print a
a.sort() # alfabetisk ordning
# print a
a.sort (a,b) -> a-b # numerisk ordning
# print a

a = [11,3,31,1,2,23]
# print a
a = _.sortBy a # numerisk ordning
# print a

b = []
b.push {name:'adam', age:1}
b.push {name:'cccc', age:32}
b.push {name:'bert', age:11}
b.push {name:'dddd', age:2}
b.push {name:'eeee', age:111}

b.sort (a,b) -> a.age-b.age # numerisk ordning
# print b

users = []
users.push {name:'cccc', age:32, kids:[3,1,5]}
users.push {name:'bert', age:11, kids:[6]}
users.push {name:'adam', age:1, kids:[14,1]}
users.push {name:'dddd', age:2, kids:[9,1,5]}
users.push {name:'eeee', age:111, kids:[11,1,5]}
#c = _.sortBy users,(user) -> [parseInt(sum(user.kids)), parseInt(prod(user.kids))] # numerisk ordning

c = users.toSorted (a,b) -> [parseInt(sum(a.kids)-sum(b.kids))] # ok
#c = users.toSorted (a,b) -> [pi(sum(a.kids))-pi(sum(b.kids)), pi(prod(a.kids))-pi(prod(b.kids))] 

print c

####################

people = [
	{ name: 'Anna', age: 54, barn: [5, 7, 9] },
	{ name: 'Anna', age: 35, barn: [3] },
	{ name: 'Anna', age: 42, barn: [4, 8] }
]

sortedPeople = _.sortBy people, [
	'barn',
	(person) => person.barn.length,
]

console.log(sortedPeople)
