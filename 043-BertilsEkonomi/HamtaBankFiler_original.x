
<usage -
HamtaBankfiler.x
'---------------------
Hämta tre bankfiler från C:\Users\Bertil\Downloads:
   * Kontoutdrag
   * Utbetalningar
   * Inbetalningar.
Lägg dem i aktuell mapp (bokföring 20xx) under rätta namn.
Exempel:
   '<hamta Kontoutdrag',C:\Users\Bertil\Downloads',transaktioner*2023-11*.csv',2309'> 
      - Hämta fil med transaktioner från C:\Users\Bertil\Downloads vars namn
        matchar "transaktioner*2023-11*.csv" och döp om den till 
        "SHB Kontoutdrag 230901-230930.txt"
   '<hamta Kontoutdrag',',',2309'> 
      - Samma som föregående men 
        - Källmapp är C:\Users\Bertil\Downloads
        - För hämtning används aktuell månad
        - För nytt filnamn används 2309
   '<hamta Kontoutdrag'> 
      - Samma föregående men 
        - Källmapp är C:\Users\Bertil\Downloads
        - För hämtning används aktuell månad
        - För nytt filnamn används föregående månad
   '<hamta Utbetalningar',C:\Users\Bertil\Downloads',Sok_utbetalning 2023-11*.txt',2309'> 
      - Hämta fil med utbetalningar från C:\Users\Bertil\Downloads vars namn
        matchar "Sok_utbetalning 2023-11*.txt" och döp om den till 
        "SHB Utbetalningar 230901-230930.txt"
   '<hamta Utbetalningar',',',2309'> 
      - Samma föregående men 
        - Källmapp är C:\Users\Bertil\Downloads.
        - För hämtning används aktuell månad.
        - För nytt filnamn används 2309.
   '<hamta Utbetalningar'> 
      - Samma föregående men 
        - Källmapp är C:\Users\Bertil\Downloads.
        - för hämtning används aktuell månad.
        - för nytt filnamn används föregående månad.
   '<hamta Inbetalningar',C:\Users\Bertil\Downloads',
      Bg5139-8659_Insättningsuppgifter_202310*Belopp.xlsx',2310'> 
      - Hämta fil med inbetalningar från C:\Users\Bertil\Downloads vars namn
        matchar "Bg5139-8659_Insättningsuppgifter_202310*Belopp.xlsx'".
        Öppna den i Excel och spara den som .csv och döp om den till
        "SHB Inbetalningar 231001-231031.txt"
   '<hamta Inbetalningar',',',2309'> 
      - Samma föregående men 
        - Källmapp är C:\Users\Bertil\Downloads.
        - för hämtning och nytt filnamn används används "2309".
   '<hamta Inbetalningar'> 
      - Samma föregående men 
        - Källmapp är C:\Users\Bertil\Downloads.
        - för hämtning och nytt filnamn används används föregående månad.
   '<hamtaAlla'>* = Hämta alla filer för föregående månad.
   '<hamtaAlla 2309'>* = Hämta alla filer för månad 2309', nerladdade denna månad.
   <windowformat ,,700,700>
->

<load utils>(* sistadag *)

<var $year>
<var $month>
<var $day>
<var $shortyear>

<case <date>
-,<format dddd>-<format dd>-<format dd>,
-<set $year,<xp 1>>
-<set $month,<xp 2>>
-<set $day,<xp 3>>
-<set $shortyear,<case $year,<format dd><format dd>,<xp 2>>>
->

(* Examples: 2301 => 2212, 2310 => 2309. *)
<var $prevShortYearMonth,
-<case $month
--,01,<calc $shortyear-1>12
--,,$shortyear<if $month'<=10,0><calc $month-1>
-->
->

(* Interval = previous month. Exempel: 231001-231031 *)
<var $intvalYear,$year>
<var $intvalMonth,$month>
<update $intvalMonth,-1>
<if $intvalMonth=0,
-<update $intvalYear,-1>
-<set $intvalMonth,12>
->
<if <strlen $intvalMonth>=1,<set $intvalMonth,0$intvalMonth>>
<var $intvalShortYear,<case $intvalYear,<format dd><format dd>,<xp 2>>>
<var $intvalSistaDag,<utils.sistadag $intvalYear,$intvalMonth>>
<var $interval,$intvalShortYear$intvalMonth'01-$intvalShortYear$intvalMonth$intvalSistaDag>

(* MakeInterval. 
   Skapa datum intervall för en månad som kan användas i filnamn i bokföringen.
   Exempel:
   <makeinterval 2310> => "231001-231031"
   *)
<function makeinterval,
-<var $shortyearmonth,$1>
-<var $sistadag>
-<case $shortyearmonth
--,<format dd><format dd>,
--<set $sistadag,<utils.sistadag 20<xp 1>,<xp 2>>>
-->
-$shortyearmonth'01-$shortyearmonth$sistadag
-(* ($1'01-$1'$sistadag går ej att kompilera) *)
->


(* <hamta typ,[frånkatalog],[namnmönster],[månad]>
   Exempel: 
   <hamta kontoutdrag,C:\Users\Bertil\Downloads,transaktioner*2023-11*.csv',2310'>
   <hamta utbetalningar',C:\Users\Bertil\Downloads',Sok_utbetalning 2023-11*.txt',2310'> 
   <hamta inbetalningar,C:\Users\Bertil\Downloads,-
      Bg5139-8659_Insättningsuppgifter_202310*Belopp.xlsx,2310> 
   
   $1 = Typ av fil - kontoutdrag, utbetalningar eller inbetalningar
   $2 = sökväg till nerladdningskatalog.
   $3 = mönster för filnamn.
   $4 = år pch månad, t ex "2309".

   Hitta fil nerladdad från SHB, byt namn på filen och flytta den till aktuell
   mapp (bokföringskatalogen).
   För inbetalningar, öppna i Excel och omvandla från .xlsx till .csv.
*)   
<function hamta,
-<var $frånmapp,<ifis $2,$2,C:\Users\Bertil\Downloads>>
-<var $tillMapp,<cd>>
-<var $årmånadTransaktioner,<ifis $4,$4,$prevShortYearMonth>>(* Example: 2310 *)
-<var $årmånadNerladdning,(* Nuvarande månad, Exempel: 2311 *)
--<case <date>,<format dd><format dd>-<format dd>-<format dd>,<xp 2><xp 3>>
-->
-<var $pattern,<ifis $3,$3,
---<case $1
----
----,Kontoutdrag,
----(* Exempel: transaktioner*2023-11*.csv *)
----transaktioner*<case $årmånadNerladdning,<format dd><format dd>,20<xp 1>-<xp 2>>*.csv
----
----,Utbetalningar,
----(* Exempel: Sok_utbetalning 2023-11*.txt *)
----Sok_utbetalning <case $årmånadNerladdning,<format dd><format dd>,20<xp 1>-<xp 2>>*.txt
----
----,Inbetalningar,
----(* Exempel: Bg5139-8659_Insättningsuppgifter_202310*Belopp.xlsx *)
----Bg5139-8659_Insättningsuppgifter_20$årmånadTransaktioner*Belopp.xlsx
---->>>
-<var $nyttnamn,SHB $1 <makeinterval $årmånadTransaktioner>'.txt>
-
-<c hamtafil,$frånmapp,$pattern,$nyttnamn,$tillmapp>
-,1,4>

(* <hamtaAlla [månad]>
   $1 = transaktionsmånad, t ex "2309".
   Exempel:
   <hamtaalla > - Hämta kontoutdrag, utbetalningar och inbetalningar 
      för förra månaden', nerladdade denna månad', från C:\Users\Bertil\Downloads.
   <hamtaalla 2309> - Hämta kontoutdrag, utbetalningar och inbetalningar 
      för månad 2309', nerladdade denna månad', från C:\Users\Bertil\Downloads.

   Anropa hamta för varje fil (3 filer).   
*)   
<function hamtaAlla,
-<hamta Kontoutdrag,,,$1>
-<hamta Utbetalningar,,,$1>
-<hamta Inbetalningar,,,$1>
-,0,1>


hamtaFil.x
----------

(* <sp 1>: Från mapp - var filerna finns. Exempel: "C:\Users\Bertil\Downloads".
   <sp 2>: Söksträng, exempel (för oktober 2023):
      "transaktioner*2023-11*.csv"
      "Sok_utbetalning 2023-11*.txt"
      "Bg5139-8659_Insättningsuppgifter_202310*Belopp.xlsx"
   <sp 3>: Nytt namn, exempel:
      "SHB Kontoutdrag 231001-231031.txt"
      "SHB Utbetalningar 231001-231031.txt"
      "SHB Inbetalningar 231001-231031.txt"
   <sp 4>: Till mapp, exempel:
      "C:\Users\Bertil\Desktop\Samfälligheten\Bokföring 2023"
*)      


<var $saveCd>
<var $count>
<var $dir>

!"
-<wcons +++ hamtaFil(<sp 1>,<sp 2>,<sp 3>,<sp 4>).>
-<set $saveCD,<cd>>
-<cd <sp 1>>
-<set $dir,<command dir /B "<sp 2>">>
-<wcons dir result = "$dir".>
-<in <command dir /B "<sp 2>">
,string>
-<set $count,0>
-"!


(* Example: Transaktioner_213339668_2023-10-16_2137.csv *)
?"<towl .csv>.csv
"?
!"
-<wcons +++ hamtaFil: Hittade kontoutdrag <p 1>.csv.>
-<command rename "<p 1>.csv" "<sp 3>">
-<command move /Y "<sp 3>" "<sp 4>">
-<update $count,+1>
-"!

(* Example: Sok_utbetalning 2023-10-16 2148.txt *)
?"<towl .txt>.txt
"?
!"
-<wcons +++ hamtaFil: Hittade utbetalningar <p 1>.txt: "<p 0>".>
-<command rename "<p 1>.txt" "<sp 3>">
-<command move /Y "<sp 3>" "<sp 4>">
-<update $count,+1>
-"!

(* Example: "Bg5139-8659_Insättningsuppgifter_20230901-20230930Belopp.xlsx" *)
?"<towl .xlsx>.xlsx
"?
!"
-<wcons +++ hamtaFil: Hittade inbetalningar <p 1>.xlsx.>
-<excel open,C:\Users\Bertil\Downloads\<p 1>.xlsx,yes>
-<wcons +++ hamtaFil: '<sp 3'> (nytt namn) = <sp 3>.>
-<excel saveAs,<cd>\<sp 3>,.csv>
-<wcons +++ <command dir /B "SHB Inbetalningar *.txt">>
-<wcons +++ '<sp 3'> = <sp 3>', '<sp 4'> = <sp 4>.>
-<excel close>
-<command move /Y "<sp 3>" "<sp 4>">
-<update $count,+1>
-"!

?"2'>File Not Found
"?
!"<wcons Hittar inte "<sp 2>" (day1=$intvalYear$intvalMonth'01).>"!

?"<eof>"?
!"<r>"!

!"
-<if $count'>1,<wcons *** hamtaInbet: Förväntade 1 fil med 
--- men hittade $count st.>
-->
-<cd $saveCd>
-"!


