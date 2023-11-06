<def ass,<ifeq $1,$2,<wcons $1 == $2>,<wcons $1 != $2>>>

<ass 1,1>
<ass 1,2>
<ass A,A>
<ass A,B>
<wcons Done!>

cc
---

!"<in <sp 1>,string><out ,string>"!

?"X"? !"yy"!
?"Y"? !"Z"!

?"<format l>"? !"L"!

?"1"? !"1"!
?"2"? !"2"!
?"3"? !"3"!

?"<eof>"? !"<r>"!

---

<ass LLL123yyyyZZ,<c cc,ABC123XXYY>>
