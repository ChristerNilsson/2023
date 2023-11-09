import re

regex = re.compile(r"""
	\(\*   # (*
		(  # begin group
			.+?  # allow all characters. Question mark makes it non-greedy
		)  # end group
	\*\)   # *)
""",re.VERBOSE)

test_str = "(* Function * adam *) (* Function * bertil *)"

matches = re.findall(regex,test_str)

for match in matches:
	print("MATCH",match)
