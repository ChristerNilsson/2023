import re

ATOMIC_MASS = {"H": 1.008, "C": 12.011, "O": 15.999, "Na": 22.98976928, "S": 32.06, "Uue": 315}

def ass(a,b) :
	if a!=b: print('assert failure:',a,'!=',b)

def mul(x):
	return '*' + x.group(0)

def add(x):
	name = x.group(0)
	return '+(' if name == '(' else '+' + str(ATOMIC_MASS[name])

def molar_mass(s):
	orig=s
	s = re.sub(r"\d+", mul, s)
	s = re.sub(r"[A-Z][a-z]{0,2}|\(", add, s)
	print(orig,'=>',s)
	return round(eval(s), 3)

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
