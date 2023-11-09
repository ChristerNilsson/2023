import re

# Workaround: Byte av *) mot ååå sker för att kunna tillåta * i texten. Bokstaven å får icke förekomma i texten!

regex = r"\n\(\*[ ](<([^:]+)>:)([^å]*)\nååå"


test_str = """
(* Function descriptions for functions which does not have its own procedure: *)
(* <windowclear>:
	Clear the X window
*)
(* <clear>: 
   Clear the X window.
   Renamed to <windowClear>.
   Temporarily supported for backwards compatibility.
*)
(* <loadlevel>:
   Returns the current level of loading X-files.
   The first X-file loaded from the X window has level 1. If this file
   loads another file, then in that file, <loadlevel> will return 2, and
   so on.
   <loadlevel> used to show an introduction only if an X-script is loaded
   directly from the X window (<if <loadlevel>=1, ...>) but this is not needed
   anymore, since the <usage ...> was implemented, which does this automatically.
   Therefore, the function <loadlevel> is seldom or never used.
*)
(* <openfiles>:
   Returns a list of currently open files in X.
   Can for example used from X-window to see if there is are open files after a
   script error. Then one can close these output files to write them to disk.
*)
"""

test_str = test_str.replace('*)','ååå')

matches = re.finditer(regex, test_str)

for m, match in enumerate(matches, start=1):
	#fs = "Match {m} was found at {start}-{end}: {match}"
	#print(fs.format(m=m, start=match.start(),end=match.end(), match=match.group()))
	print("MATCH")
	print(match.group(1))
	print(match.group(3))

	# for g in range(1, 1+len(match.groups())):
	# 	fs = "Group {g} found at {start}-{end}: {group}"
	# 	print(fs.format(g=g, start=match.start(g),end=match.end(g),group=match.group(g)))
