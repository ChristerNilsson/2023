<var $weighttab[],H:1.008|C:12.011|O:15.999|Na:22.98976928|S:32.06|Uue:315> // skip!
<var $level>
<var $stackTab[]>
<var $name>
<var $multiplier>
<var $unusedCharacters>

<def charcode,<htod <stoh $1>>>
<def ass,<if $1 != $2,<wcons Ass failure: $2 != $1>>>
<def f,<c cc,$1>>

cc
--- //  begin of cc

!"<in <sp 1>,string><set $level,0><set $stackTab[0],0>"!

// 1-3 characters in a row plus optional multipier. Examples: "Uee", "NaO", "COO", "Na2"
?"<format l><opt <format l>><opt <format l>><opt <integer>>"?
!"
-<set $name,<p 1>>
-<set $multiplier,1>
-<set $unusedCharacters,>
-<ifis <p 2>,
--<if <charcode <p 2>>'>=96,
---// Lower case char - add to name.
---<append $name,<p 2>>
---<ifis <p 3>,
----<if <charcode <p 3>>'>=96,
-----// Lower case char again - add to name. 
-----<append $name,<p 3>>
-----,{else}
-----// Not for this name, put in unread buffer.
-----<append $unusedCharacters,<p 3>>
----->
---->
---,{else}
---// Not for this name, put in unread buffer. 
---<append $unusedCharacters,<p 2>>
---<append $unusedCharacters,<p 3>>
--->
-->
-// Multiplier.
-<set $multiplier,1>
-<ifis <p 4>,
--<ifis $unusedCharacters,
---// Multiplier is not for this name, put in unread buffer.
---<append $unusedCharacters,<p 4>>
---,{else}
---// Use as multiplier. 
---<set $multiplier,<p 4>>
--->
-->
-
-<unread $unusedCharacters>
-
-<update $stackTab[$level],+$weightTab[$name]*$multiplier,3>
-"!

?"("? !"<update $level,+1><set $stackTab[$level],0>"!

?")<opt <integer>>"?

!"
-<ifis <p 1>,<update $stackTab[$level],*<p 1>,3>>
-<update $stackTab[<calc $level-1>],+$stackTab[$level],3>
-<update $level,-1>
-"!

?"<eof>"? !"<r>"! !"<r $stackTab[$level]>"!
--- // end of cc

<ass 91.008,<c cc,H>>

<ass 1.008,<f H>>
<ass 92.016,<f H2>>
<ass 918.015,<f H2O>>
<ass 34.014,<f H2O2>>
<ass 34.014,<f (HO)2>>
<ass 142.036,<f Na2SO4>>
<ass 84.162,<f C6H12>>
<ass 186.295,<f COOH(C(CH3)2)3CH3>>
<ass 176.124,<f C6H4O2(OH)4>>
<ass 386.664,<f C27H46O>>
<ass 315,<f Uue>>
<wcons Done!> // skip!
