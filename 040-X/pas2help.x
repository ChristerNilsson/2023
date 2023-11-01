
<Usage
pas2help
'---------

Create help files in html format from all functions defined in xal.pas.
Usages example:
   '<html yes'>            Activate html generation. 
   '<pas2help xal.pas'>*   Generate help file helptab.txt
   '<showhelp select'>        Show help for '<select ...'>
,html|pas2help|showhelp>   

<var $createHtml,no>
<var $helptab[]>
<var $normalFunctionsTab[],, ,
>
<var $inputFunctionsTab[],, ,
>

<function pas2help,
-(* Create helpTab and write the file helpFunctions.txt. *)
-<c pas2Help,$1>
-(* Write helptab to helptab.tmp. *)
-<localio <out helptab.tmp><write $helptab><close <out>>>
-(* Convert CRLF to CR, because the x-window does not like LF. *)
-<c Crlf2Cr,helptab.tmp,helptab.txt>
->

<function html,<set $CreateHtml,$1>>
<function showhelp,$helptab[$1]>

pas2help.x
----------

(* Example:
"'('* <flag ch>:
   (return "1" if set, else "0")
'*')"
=>
"|flag:<flag ch> 
   (return "1" if set, else "0")
" *)

<var $cnt>

!"
-<if <is <sp 1>>,<in <sp 1>>>
-<set $helptab,>
-<c implementation>
-<set $cnt,0>
-"!

(* Example normal function: 
('* <flag ch>:
   (return "1" if set, else "0")
*') 

   Example input function:
('* <anything>*:
   Matches anything, to the end of the string or file.
*')

*)
?"'('* '<<id><to_withinline '><opt *>:>'><opt *>:<to
>
<to '*')>'*')<to
>
"?
!"
-<update $cnt,+1>
-<set $helptab[<p 1>],'<<p 1><p 2>'>:<p 4>
<p 5>>
-(* Write to helpFunctions.txt. *)
-<ifis <p 3>,
--<set $inputFunctionsTab['<<p 1><p 2>'>], <p 4>>
--,{else}
--<set $normalFunctionsTab['<<p 1><p 2>'>], <p 4>>
-->
-"!

?"'('* '<<id><to_withinline '>><to
>
<to '*')>'*')<to
>
"?
!"<wcons +++ pas2help: otherline = <p 0>.>"!

?"<to
>
"?
!""!

?"<eof>"?
!"<r>"!

!"<if <is <sp 1>>,
--<if <fileisopen <sp 1>>,<close <sp 1>>>
-->
-<wcons $cnt function help texts found.>
-(* Create file for function <helpfunctions>. *)
-<sort $normalFunctionsTab> 
-<sort $inputFunctionsTab> 
-<out helpFunctions.txt>
Normal functions:
$normalFunctionsTab

Input functions:
$inputFunctionsTab

-<close <out>>
-"!


implementation.x
----------------

(* Find implementation. *)

?" "?
!""!

?"IMPLEMENTATION"?
!"<r>"!

?"<to implementation>"?
!""!


unicode2Latin1.x
----------------

!"<in <sp 1>,string><out ,string>"!

?"Ã¥"?
!"å"!

?"Ã¤"?
!"ä"!

?"Ã¶"?
!"ö"!

?"Ã…"?
!"Å"!

?"Ã„"?
!"Ä"!

?"Ã–"?
!"Ö"!

?"Ã<format x>"?
!"<wcons *** Unidentified unicode character: <p 0>.>
-<p 0>"!

?"<char 10>"?
!""!

?"<to Ã,<char 10>,<eof>>"?
!"<p 1>"!

?"<eof>"?
!"<r>"!

Crlf2Cr.x
---------

<var $count>

!"<set $count,0><in <sp 1>,binary><out <sp 2>,binary>"!

?"0D0A"?
!"0D<update $count,+1>"!

?"<to 0D0A,<eof>>"?
!"<p 0>"!

?"<eof>"?
!"<r>"!

!"<wcons +++ Crlf2cr: $count replacements done.>
-<close <sp 1>><close <sp 2>>
-"!

----------------


<if <loadlevel>=1,<clear><wcons
pas2help
'---------

Create help files in html format from all functions defined in xal.pas.
Usages example:
   '<html yes'>            Activate html generation. 
   '<pas2help xal.pas'>   Generate help file helptab.txt
   '<showhelp select'>        Show help for '<select ...'>
>>   