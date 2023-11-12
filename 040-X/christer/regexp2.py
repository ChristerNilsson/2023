import re
import time

def ass(a,b):
	if a != b:
		print("assert failure:")
		print(a)
		print("!=")
		print(b)

def fetchText(filename):
	with open(filename) as f:
		return f.read()

start = time.time_ns()

################# general

any = '.+?' # zero or one character, lazy

brackets = lambda s : f'<{s}>'
ass(r'<x>', brackets('x'))

opt = lambda s : f'{s}?'
ass(r'x?', opt('x'))

group = lambda s : f'({s})'
ass(r'(x)', group('x'))

q = lambda s: ''.join(["\\" + ch for ch in s])
ass(r'\(\*', q('(*'))

nl = q('n')
ass(r'\n', q('n'))

################## application specific

pascalComment = lambda s : q('(*') + s + q('*)')
ass(r'\(\*x\*\)', pascalComment('x'))

group1 = group(' ' + brackets(any) + opt('*') + ':')
ass(r'( <.+?>*?:)', group1)

group2 = group(any)
ass(r'(.+?)', group2)

rex = nl + pascalComment(group1 + opt(nl) + group2 + nl)
ass(r'\n\(\*( <.+?>*?:)\n?(.+?)\n\*\)', rex)

regex = re.compile(rex, re.DOTALL)
text = fetchText('../xal.pas')

matches = re.findall(regex,text)
for (name,body) in matches:
	print(name)
	print(body)

print(len(matches), 'matches')
print((time.time_ns()-start)/10**6,'ms')

'''
Borde gå att få se detta i utvecklingsmiljön:
Man redigerar trädet på vänster sida
Högra sidan skapas automatiskt
	(Är den öht intressant utom för debug?)

(rex                  # \n\(\*( <.+?>*?:)\n?(.+?)\n\*\)
	nl                # \n
	(pascalComment    #   \(\*( <.+?>*?:)\n?(.+?)\n\*\)
		(q            #   \(\*
			'(*'      #   '(*'  
    	(group        #       ( <.+?>*?:)
			' '       #        .
			(brackets #         <.+?>
				any   #          .+?
			(opt      #              *?
				'*'   #              *
			':'       #                :
		(opt          #                  \n?
			nl        #                  \n            
		(group        #                     (.+?)
			any       #                      .+?
		nl            #                          \n
		(q            #                            \*\)
			'*)'      #                            '*)'
'''