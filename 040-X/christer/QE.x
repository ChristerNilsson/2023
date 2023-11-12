<def ass,<ifeq $1,$2,<wcons == $1>,<wcons $1 != $2>>>

<ass 1,1>
<ass 1,2>
<ass A,A>
<ass A,B>
<wcons Done!>

cc // Byte av tecken, genomsläpp av tecken utan transformation
---
!"<in <sp 1>,string><out ,string>"!
?"X"? !"yy"!
?"Y"? !"Z"!
?"<format l>"? !"L"!
?"<format d>"? !"<p 1>"!
?"<eof>"? !"<r>"!
---
<ass LLL123yyyyZZ,<c cc,ABC123XXYY>>

dd // udda tal => -udda-, letters släpps igenom
---
!"<in <sp 1>,string><out ,string>"!
?"<format l>"? !"<p 1>"!
?"<alt 1,3>"? !"-udda-"!
?"<format d>"? !"<p 1>"!
?"<eof>"? !"<r>"!
---
<ass ABC-udda-2-udda-XXYY,<c dd,ABC123XXYY>>

ee // integer
---
!"<in <sp 1>,string><out ,string>"!
?"<integer>"? !"i"!
?"<format l>"? !"L"!
?"<eof>"? !"<r>"!
---
<ass LLLiLLLL,<c ee,ABC123XXYY>>

ff // decimal
---
!"<in <sp 1>,string><out ,string>"!
?"<decimal>"? !"d"!
?"<format l>"? !"L"!
?"<eof>"? !"<r>"!
---
<ass LLLdLLLL,<c ff,ABC3.14XXYY>>

gg // format h
---
!"<in <sp 1>,string><out ,string>"!
?"<format h>"? !"h"!
?"<format l>"? !"L"!
?"<eof>"? !"<r>"!
---
<ass hhhhhhhhhhhLLLL,<c gg,ABCcafebabeXXYY>>

hh // bits
---
!"<in <sp 1>,string><out ,string>"!
?"<bits 8>"? !"8"!
?"<format l>"? !"L"!
?"<eof>"? !"<r>"!
---
<ass LL8888LLLL,<c hh,ZZcafebabeXXYY>>

ii // bits, bitscount
---
!"<in <sp 1>,string><out ,string>"!
?"<bits 32>"? !"<bitscount>"!
?"<format l>"? !"L"!
?"<eof>"? !"<r>"!
---
<ass LL32LLLL,<c ii,ZZcafebabeXXYY>>

jj // bitsdec
---
!"<in <sp 1>,string><out ,string>"!
?"<bitsdec 32>"? !"<p 1>"!
?"<format l>"? !"L"!
?"<eof>"? !"<r>"!
---
<ass LL3405691582LLLL,<c jj,ZZcafebabeXXYY>>

kk // to
---
!"<in <sp 1>,string><out ,string>"!
?"<to ab,b,c>"? !"(<p 1>)"!
?"<format l>"? !"<p 1>"!
?"<eof>"? !"<r>"!
---
<ass (ZZ)()c(afe)()b()a()beXXYY,<c kk,ZZcafebabeXXYY>>

ll // id
---
!"<in <sp 1>,string><out ,string>"!
?"<id>"? !"(<p 1>)"!
?" "? !"*"!
?"<format l>"? !"l"!
?"<format d>"? !"<p 1>"!
?"<eof>"? !"<r>"!
---
<ass (a)*6(b)*(c)*7*(Da_8),<c ll,a 6b c 7 Da_8>>

mm // towholeword ??? vad är eofs?
---
!"<in <sp 1>,string><out ,string>"!
?"<towholeword bertil>"? !"(<p 1>)"!
?"<format l>"? !"l"!
?"<format d>"? !"<p 1>"!
?" "? !"*"!
//?"<eoln>"? !"crlf"!
?"<eof>"? !"<r>"!
---
//<ass (a)*6(b)*(c)*7*(Da_8),<c mm,adam bertil cesar david>>

nn // eoln ??? Hur få in eoln i strängen?
---
!"<in <sp 1>,string><out ,string>"!
?"<to '<eoln>"? !"(<p 1>)"!
?"<format l>"? !"l"!
?"<format d>"? !"<p 1>"!
?" "? !"*"!
?"<eof>"? !"<r>"!
---
//<ass (a)*6(b)*(c)*7*(Da_8),<c nn,adam bertil \n cesar david>>


