<def ass,<ifeq $1,$2,<wcons $1 == $2>,<wcons $1 != $2>>>

cc
---

!"<in <sp 1>,string>"!

?"X"? !"yy"!
?"Y"? !"Z"!

?"<format l>"? !"L"!

?"0"? !"0"!
?"1"? !"1"!
?"2"? !"2"!
?"3"? !"3"!
?"4"? !"4"!
?"5"? !"5"!
?"6"? !"6"!
?"7"? !"7"!
?"8"? !"8"!
?"9"? !"9"!

?"<eof>"? !"<r>"!

---

<ass 1,1>
<ass 1,2>
<ass A,A>
<ass A,B>

<wcons <c cc,ABC123XXYY>>

<ass LLL123yyyyZZ,<c cc,ABC123XXYY>>
