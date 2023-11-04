<clear>
<def assert,<if $1=$2,,<wcons Assert failure: $1 != $2>>>
<def asseq,<ifeq $1,$2,,<wcons Asseq failure: $1 != $2>>>

<assert 5,<calc 2+3>>

<assert 8,<abs -8>>
<assert 8,<strlen christer>>

<var $s,abc>
<append $s,d>
<assert abcd,$s>

<assert 14,<calc 2+3*4>>
<assert A,<char 65>>
<assert a,<char 65>>
<assert A,<char 97>>

<assert 11001010111111101011101010111110,<htob cafebabe>>
<assert cafebabe,<btoh 11001010111111101011101010111110>>

<assert 4719,<htod 126F>>
//<assert '126F,<dtoh 4719>>

//<assert 4719,<htos 126F>>
//<assert 0,<htos cafebabe>>

//<assert 0, <makebits 8,ff>>

<var $arr,<range 0,9>>
//<assert 1,$arr[1]>
<assert 0|1|2|3|4|5|6|7|8|9,$arr>

<assert 3,<sqrt 9>>

<assert christer,<strlowercase Christer>>
<assert christer,<struppercase Christer>>

<var $count,1>
<update $count,+1>
<assert 2,$count>

<var $abc>
<var $arr1,0:1|1:b|2:3|3:4>
<var $res[]>
<foreach $abc,$arr1,<append $res,$abc,|>>
//<asseq 0:1|1:b|2:3|3:4,$res>
//<asseq 3,$res[2]>


//<ifeq Christer,<format ll><format l><anything>,<xp 2>> 

//<var $bertil,"<calc 4+7>" >
//<asseq "<calc 4+7>",$bertil>
//<assert 11,<exec $bertil>>

(*
<var $a1,a>
<var $a2,b>
<var $a3,c>
<var $a4,d>
<var $xyz> //,0|1|2|3|4|5|6>
<pack $xyz,|,$a1,$a2,$a3,$a4>
<wcons $xyz>
//<assert z,$xyz>
*)

// NIX! bitscount




<wcons ok.>

