import time
import re

# Chemical Calculator med reguljära uttryck VERBOSE

ATOMIC_MASS = {"H": 1.008, "C": 12.011, "O": 15.999, "Na": 22.98976928, "S": 32.06, "Uue": 315}

def ass (a,b):
	if a != b: print('Assert failure:',a,'!=',b)

def mul(x):
	return '*' + x.group(0)

def add(x):
	name = x.group(0)
	return '+' + str(ATOMIC_MASS[name])

start = time.time_ns()

r1 = re.compile(r"""
	\d+                # noll eller flera siffror
""",re.VERBOSE)

r2 = re.compile(r"""
	[A-Z]              # Exakt en stor bokstav, t ex H
	[a-z]{0,2}         # noll till två små bokstäver, t ex H Na Uue
	""",re.VERBOSE)

def molar_mass(s):
	s = re.sub(r1, mul, s) # heltal => *heltal
	s = re.sub(r2, add, s) # namn => +vikt
	s = s.replace('(', '+(') # ( => +(
	return round(eval(s), 3)

N = 1000
for i in range(N):
	# molar_mass('H')                                 # 31 mikrosekunder
	molar_mass('COOH(C(CH3)2)3CH3')                   # 94 mikrosekunder
	# molar_mass('COOH(C(CH3)2)3CH3COOH(C(CH3)2)3CH3')# 156 mikrosekunder

print((time.time_ns()-start)/10**6/N,'ms/styck')

ass( 1.008 , molar_mass('H'))
ass( 315 , molar_mass('Uue'))
ass( 2.016 , molar_mass('H2'))
ass( 18.015 , molar_mass('H2O'))
ass( 34.014 , molar_mass('H2O2'))
ass( 34.014 , molar_mass('(HO)2'))
ass( 142.036 , molar_mass('Na2SO4'))
ass( 84.162 , molar_mass('C6H12'))
ass( 186.295 , molar_mass('COOH(C(CH3)2)3CH3'))
ass( 176.124 , molar_mass('C6H4O2(OH)4')) # Vitamin C
ass( 386.664 , molar_mass('C27H46O')) # Cholesterol
