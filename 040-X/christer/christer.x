
<def assert,<if $1 != $2,<wcons Assert failure: $1 != $2>>>

//<var $arr[]>
//<set $arr[0],yxa>
//<set $arr[1],kniv>
//<set $arr[2],sax>
//<set $arr[adam],pistol>
//$arr
//$arr[adam]

//<def *,<calc $1*$2>>
//<def +,<calc $1+$2>>
//<def -,<calc $1-$2>>

<assert 5,<calc 2+3>>
<assert 12,<* 3,4>>
<assert 7,<+ 3,4>>
<assert 9,<- 13,4>>

<preldef fact>
<def fact, <if $1 '< 2,1,<* $1, <fact <calc $1-1>>>>>
<preldef fib>
<def fib, <if $1 '< 2,$1,<+ <fib <- $1,1>>, <fib <- $1,2>>>>>

<assert 120,<fact 5>>

<assert 5,<fib 5>>
<assert 8,<fib 6>>
<assert 55,<fib 10>>
//<assert 610,<fib 15>>
//<assert 6765,<fib 20>>
//<assert 10946,<fib 21>>
//<assert 17711,<fib 22>>

//<wcons <time>>
//<assert 75025,<fib 25>>
//<wcons <time>>

//<wcons <time>>
//<assert 75025,<fib 25>>
//<wcons <time>>
//<assert 66666,<fib 25>>
//<wcons <time>>
//<assert 77777,<fib 25>>
//<wcons <time>>

<var $weighttab[],H:1.008|He:4.002602|Li:6.94|Be:9.0121831|B:10.81|C:12.011|N:14.007|O:15.999|F:18.998403163>
<var $name,Li>
<set $weighttab[Li],7>
<assert 7,$weighttab[Li]>
<wcons Done!>

