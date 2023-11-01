(* XFS.PAS *)


(* FS - Flexible string package *)
(************************************)

UNIT xfs;

{$MODE Delphi}

(* $norangecheck*) (* OREGON: F(tm)R ATT -32768-1 SKA KUNNA BLI 32767 *)

(***) INTERFACE (***)

CONST
fseofs= 255; (* ASCII-KOD - (CTRL-TECKEN KAN EJ ANVŽNDAS OM KOMPILERADE
                MMP-STRŽNGAR SKA KUNNA REPRESENTERAS). *)
fseoa= 254; (* From xx.pas) *)

fsmaxblocks100= 4000; (* Maximum number of 100 block chunks. (4000*100*250
                         = 100 M bytes). *)

TYPE
fsptr= ^CHAR;
fsint16= smallint;
fsint32= longint;

var
fscasemask: fsint16; (* (from xx.pas) Determines if fsEqualFilename comparison
   shall be case sensitive or not. $FF = case sensitive. $DF = not case sensitive. *)

var
fslcTab: array[char(0)..char(255)] of char; // Lower case table
fsUcTab: array[char(0)..char(255)] of char; // Upper case table
fslcWsTab: array[char(0)..char(255)] of char; // Lower case and white space table
fsBinaryWsTab: array[char(0)..char(255)] of char; // Binary white space table
fsHtodTab: array[char(0)..char(255)] of char; // Hex to dec tab. Example: 'a' => char(10)
fsDtoHTab: array[0..15] of char;

procedure fsinit
(* INITIALIZE FS PACKAGE *);

procedure fsdispose( var pp: fsptr )
(* DISPOSE FS-STRING. *);

procedure fsrewrite( var pp: fsptr )
(* DELETE ENTIRE STRING AND GO TO THE FIRST POSITION. *);

procedure fsdelrest( var pp: fsptr )
(* DELETE REST STRING SO THAT PP POINTS AT EOFS. *);

procedure fsnew( var p: fsptr )
(* CREATE FS-STRING *);

function fstostr( pp: fsptr ): string;
(* Convert pp^ to a string. *)

procedure fspshend( var pp: fsptr; pch: CHAR )
(* PUT CHAR AT THE END OF STRING. *);

procedure fsback( var pp: fsptr )
(* MOVE POINTER TO PREVIOUS CHARACTER *);

procedure fsforward( var pp: fsptr)
(* MOVE POINTER TO NEXT CHAR *);

procedure fsforwend( var pp: fsptr )
(* GO TO END OF STRING *);

procedure fsbackend( var pp: fsptr )
(* Go to beginning of string *);

procedure fsforwendch( var pp: fsptr; pendch: CHAR )
(* GO TO ENDCH  *);

procedure fsfindch( var pp: fsptr; pendch: CHAR )
(* Copied from fsforwendch.
   Go to pendch, but do not print error message if not found. *);

procedure fsmultiforw(var pp: fsptr; pn: fsint16)
(* MOVE FORWARD PN STEPS. NOTE THAT IT IS THE CALLERS RESPONSIBILITY
   THAT EOFS NOT IS GONE BEYOND. *);

function fsdistance( pp1,pp2: fsptr ): fsint32;

procedure fscopy(p1,p2: fsptr; pendch: CHAR)
(* COPY P1 STRING TO (END OF) P2. *);

function fsequalFilename(p1,p2: fsptr; pendch1,pendch2: CHAR): BOOLEAN
(* Compare two filenames until pendch. All blanks are considered
   in this version. *);

function fsequal(p1,p2: fsptr; pendch1,pendch2: CHAR): BOOLEAN;
(* Compare strings without considering character case, or type of
   whitespace, until pendch.
   Extra blanks (more than one blank or tab) are ignored.
   Used by alCase.
*)

function fsposint( pp: fsptr ): fsint32;
(* Decode fsint32 from string. *)
(* Skip lead blanks then read until not digit.
   Return -1 if no digit found. *)

procedure fsbitills( pi: fsint32; ps: fsptr )
(* fsint32 -> FS *);

function fsusecount: fsint32;
(* Return number of used blocks. *)

procedure fspushandforward(var pfrom: fsptr; var pto: fsptr);
(* Time efficient procedure to replace for example
   fspshend(ut,ins^);
   fsforward(ins);
   by
   fspushandforward(ins,ut);
   in alMacro. *)

procedure fsAllowNewlineInBinaryInput(pallowed: boolean);
(* To control wether newline characters are allowed or not in binary input
   (<bits ...>). Used by alSettings when the setting allowNewlineInBinaryInput
   is changed. *)

procedure fstest;

(* END of fs.EXT *)


(***) IMPLEMENTATION (***)

USES

xio (* ioerrormess, ioreadln *)
,SysUtils (* inttostr *)
,xioform  (* iofWriteToWbuf, iofWritelnToWbuf *)
,xx (* xProgramError *)
;


TYPE
fsblockp= ^fsblock;
fsblock=  RECORD
           txt: PACKED ARRAY[0..247] OF CHAR;  (* 248 BYTES *)
           prev,next: fsblockp;                (* 8  BYTES *)
          end;                               (* 256 BYTES TOTAL *)

fpt=     RECORD CASE integer OF
           1: (b4,b3,b2,b1: BYTE);
           (* Jag tror att adresser lagras med den minst signifikanta
              byten först (b4) och den mest signifikanta sist (b1). *)
           2: (fp: fsblockp);
           3: (ch: ^CHAR);
           4: (w2,w1: WORD);
          end;

var
freelist: fsblockp;
eofs: CHAR;
NULL: CHAR;
ctrlM: CHAR;
blockCount: integer = 0;
blockRecord: array[1..fsmaxblocks100] of fpt;
usecount: integer = 0;

procedure makeLcUcWsTabs; forward;
procedure makeBinaryWsTab; forward;
procedure makeHtodTab; forward;

procedure fsinit
(* Iinitialize fs package *);
var i: integer;

begin (*fsinit*)

fpt(freelist).fp:= nil;
eofs:= CHR(fseofs);
null:= CHR(0);
ctrlM:= CHR(13);

(* (from xx.pas) Case insensitive comparisons is default. *)
fscasemask:= $DF;

makeLcUcWsTabs;
makeBinaryWsTab;
makeHtodTab;
// dtohtab:
for i:= 0 to 9 do fsDtoHTab[i]:= char(integer('0')+i);
for i:= 10 to 15 do fsDtoHTab[i]:= char(integer('A')+i-10);


end; (*fsinit*)

procedure fsget100blocks;  (* Add 100 new blocks to freelist. *)

var
p0: POINTER;
p: fpt;
i: fsint16;

begin

getmem(p0,25856); (* 101 * 256 *)
p:= fpt(p0);

blockCount:= blockcount+1;
if blockCount>fsmaxblocks100 then
  xScriptError('X(fsnewblock): Error, fs has a limit of '+
  inttostr(fsmaxblocks100*100)+' blocks ('+inttostr(fsmaxblocks100*40)+'MByte).')
else blockrecord[blockcount]:= p;

(* All blocks must start on an even XXXXXX00 boundary. *)
if p.b3=255 then begin
    p.w1:= p.w1+1;
    p.b3:= 0;
    end
else p.b3:= p.b3+1;
p.b4:= 0;

FOR i:= 1 TO 100 do begin

    if freelist<>nil then begin
        freelist^.prev:= fsblockp(p);
        fsblockp(p)^.next:= freelist;
        end
    else fsblockp(p)^.next:= nil;
    freelist:= fsblockp(p);
    freelist^.prev:= nil;
    if p.b3=255 then begin
        p.w1:= p.w1+1;
        p.b3:= 0;
        end
    else p.b3:= p.b3+1;
    end;

end; (* fsget100blocks *)


procedure fsnewblock( var pp: fsblockp );
(*******************)

(* Create a new 256 byte block *)

begin (*fsnewblock*)

if freelist=nil then fsget100blocks;

pp:= freelist;

if freelist^.next<>nil then begin
    freelist:= freelist^.next;
    freelist^.prev:= nil;
    end

else freelist:= nil;

WITH pp^ do begin
    prev:= nil; next:= nil;
    end;

usecount:= usecount+1;
end; (*fsnewblock*)


procedure fsdisposeblock( pp: fsblockp );
(***********************)

begin (*fsdisposeblock*)

if fpt(pp).b4<>0 then xProgramError('X(fsdispose): Error - b4<>0.');

if freelist <> nil then begin
    freelist^.prev:= pp;
    pp^.next:= freelist;
    end
else pp^.next:= nil;

freelist:= pp;
freelist^.prev:= nil;

usecount:= usecount-1;

end; (*fsdisposeblock*)

(*X*)
procedure fsdispose( var pp: fsptr )
(* DISPOSE FS-STRING. *);

var p: fsblockp; nx,pv,pv1: fsblockp;
begin (*fsdispose*)

if pp<>nil then begin

    fpt(pp).b4:= 0;
    nx:= fpt(pp).fp^.next;
    pv:= fpt(pp).fp^.prev;
    pv1:= pv;
    fsdisposeblock(fsblockp(pp));

    while not (nx=nil) do begin

        p:= nx;
        nx:= p^.next;
        fsdisposeblock(p);
        end;
    while not (pv=nil) do begin
        p:= pv;
        pv:= p^.prev;
        fsdisposeblock(p);
        if pv=pv1 then begin
            xProgramError(
              'X(fsdispose): Error, dispose of already free block.');
            pv:= nil;
            end;

        end;
    end;

pp:= nil;

end; (*fsdispose*)

(*X*)
procedure fsrewrite( var pp: fsptr )
(* DELETE ENTIRE STRING AND GO TO THE FIRST POSITION. *);

var p,nx,pv: fsblockp;
begin (*fsrewrite*)

fpt(pp).b4:= 0;
nx:= fpt(pp).fp^.next; fpt(pp).fp^.next:= nil;
pv:= fpt(pp).fp^.prev; fpt(pp).fp^.prev:= nil;

while not (nx=nil) do begin
    p:= nx;
    nx:= nx^.next;
    fsdisposeblock(p);
    end;
while not (pv=nil) do begin
    p:= pv;
    pv:= pv^.prev;
    fsdisposeblock(p);
    end;
pp^:= eofs;

end; (*fsrewrite*)

(*X*)
procedure fsdelrest( var pp: fsptr )
(* DELETE REST STRING SO THAT PP POINTS AT EOFS. *);

var p: fsblockp; nx: fsblockp;
begin (*fsdelrest*)

p:= fsblockp(pp); fpt(p).b4:= 0;

nx:= p^.next;
p^.next:= nil;

while not (nx=nil) do begin
    p:= nx;
    nx:= nx^.next;
    fsdisposeblock(p);
    end;

pp^:= eofs;

end; (*fsdelrest*)


(*X*)
procedure fsnew( var p: fsptr )
(* CREATE FS-STRING *); 

begin (*fsnew*)

fsnewblock(fsblockp(p));
p^:= eofs;

end; (*fsnew*)


(*X*)
procedure fspshend( var pp: fsptr; pch: CHAR )
(* PUT CHAR AT THE end OF STRING. *);

var p0,p1,p: fsblockp;

begin (*fspshend*)

(* Go to end of string. *)
if not (pp^=eofs) then begin
    p:= fsblockp(pp); fpt(p).b4:= 0;
    if p^.next<>nil then begin
        while not (p^.next=nil) do
            p:= p^.next;
        pp:= fsptr(p);
        end;
    while not ((pp^=eofs) OR (fpt(pp).b4=247)) do
        fpt(pp).b4:= fpt(pp).b4+1;

    if not (pp^=eofs) then xProgramError(
      'X(fspshend): Error - pp^<>eofs.');
    end;

pp^:= pch;

if fpt(pp).b4<=246 then fpt(pp).b4:= fpt(pp).b4+1
else begin
    p0:= fsblockp(pp); fpt(p0).b4:= 0;
    fsnewblock(p1);
    p0^.next:= p1;
    p1^.prev:= p0;
    pp:= fsptr(p1);
    end;
pp^:= eofs;

end; (*fspshend*)


(*X*)
procedure fsback( var pp: fsptr )
(* MOVE POINTER TO PREVIOUS CHARACTER *);

LABEL 99;

begin (*fsback*)

if fpt(pp).b4>0 then fpt(pp).b4:= fpt(pp).b4-1

else begin

    if fpt(pp).fp^.prev=nil then begin
        xProgramError('X(fsback): Error - prev=nil.');
        GOTO 99;
        end;
    fpt(pp).fp:= fpt(pp).fp^.prev; fpt(pp).b4:= 247;
    end;
99:
end; (*fsback*)


var emess: shortstring; s: string;

(*X*)
procedure fsforward( var pp: fsptr)
(* MOVE POINTER TO NEXT CHAR *);

var p: fsptr; i: fsint16; (* (old:) emess: shortstring; s: string; *)
(*(old:)l: integer;*)

begin (*fsforward*)

if pp^=eofs then begin
    emess:= 'X(fsforward): Error - end of fs,';
    p:= pp;
    for i:= 1 to 200 do begin
        if not ((fpt(p).b4=0) AND (fpt(p).fp^.prev=nil))
        then fsback(p);
        end;
    emess:= emess+'last characters: "'+fstostr(p)+'".';
    xProgramError(emess);
    end

else begin

    fpt(pp).b4:= fpt(pp).b4+1;
    if fpt(pp).b4=248 then begin

        fpt(pp).b4:= 0;
        if fpt(pp).fp^.next=nil then begin
            //s:= fstostr(pp); (removed because it called itself recursively)
            s:= '';
            while (pp^<>eofs) and (fpt(pp).b4<248) do begin
               s:= s + pp^;
               fpt(pp).b4:= fpt(pp).b4+1;
               end;

            xProgramError('X(fsforward): Error - next=nil ('
              +s+').');
            fpt(pp).b4:= 248;
            pp^:= eofs;
        end
        else fpt(pp).fp:= fpt(pp).fp^.next;
        end;
    end;

end; (*fsforward*)


procedure fsforwend( var pp: fsptr)
(* GO TO END OF STRING *);

var
p: fsblockp;

begin (*fsforwend*)

p:= fsblockp(pp); fpt(p).b4:= 0;

(* Make sure that pp points at the last block. *)
if p^.next <> nil then begin
    while not (p^.next=nil) do
        p:= p^.next;
    pp:= fsptr(p);
    end;

while not ((pp^=eofs) OR (fpt(pp).b4=247)) do
    fpt(pp).b4:= fpt(pp).b4 + 1;

if not (pp^=eofs) then
    xProgramError('X(fsforwend): Error - pp^.ch<>eofs.');

end; (* fsforwend*)


procedure fsbackend( var pp: fsptr )
(* Go to beginning of string *);

var
p: fsblockp;

begin (*fsbackend*)

p:= fsblockp(pp); fpt(p).b4:= 0;

(* Make sure that pp points at the first block. *)
if p^.prev <> nil then begin
    while not (p^.prev=nil) do
        p:= p^.prev;
    end;
pp:= fsptr(p);

end; (* fsbackend*)

procedure fsforwendch( var pp: fsptr; pendch: CHAR )
(* GO TO ENDCH  *);

var
p: fsblockp;
aborted: boolean;

begin (*fsforwendch*)

p:= fsblockp(pp); fpt(p).b4:= 0;
aborted:= false;

while not ( (pp^=pendch) or aborted ) do begin

  (* At end of string? *)
  if pp^=eofs then aborted:= true

  (* At end of block? *)
  else if fpt(pp).b4=247 then begin
    if p^.next=nil then aborted:= true
    else begin
      p:= p^.next;
      pp:= fsptr(p);
      end;
    end

  (* No - step forward. *)
  else fpt(pp).b4:= fpt(pp).b4 + 1;
  end; (* while *)

if not (pp^=pendch) then begin
    xProgramError('fsforwendch: Error - end character('
      +inttostr(ORD(pendch))+') not found.');
    if not (pp^=eofs) then begin
      xProgramError('fsforwendch: Error - end of string (eofs) not found.');
      pp^:= eofs;
      end;
    end;

end; (* fsforwendch*)

procedure fsfindch( var pp: fsptr; pendch: CHAR )
(* Copied from fsforwendch.
   Go to pendch, but do not print error message if not found. *);

var
p: fsblockp;
aborted: boolean;

begin (*fsfindch*)

p:= fsblockp(pp); fpt(p).b4:= 0;
aborted:= false;

while not ( (pp^=pendch) or aborted ) do begin

  (* At end of string? *)
  if pp^=eofs then aborted:= true

  (* At end of block? *)
  else if fpt(pp).b4=247 then begin
    if p^.next=nil then aborted:= true
    else begin
      p:= p^.next;
      pp:= fsptr(p);
      end;
    end

  (* No - step forward. *)
  else fpt(pp).b4:= fpt(pp).b4 + 1;
  end; (* while *)

end; (* fsfindch*)

(*X*)
procedure fsmultiforw(var pp: fsptr; pn: fsint16)
(* MOVE FORWARD PN STEPS. NOTE THAT IT IS THE CALLERS RESPONSIBILITY
   THAT EOFS not IS GONE BEYOND. *);

begin (*fsmultiforw*)

(* PN=ADDITIONAL NEEDED STEPS AHEAD NEEDED. *)
pn:=pn + fpt(pp).b4;
fpt(pp).b4:= 0;

while not (pn<=247) do if fpt(pp).fp^.next=nil then begin
    xProgramError(
    'X(fsmultiforw): Error - attempt to jump beyond bound (pn='+inttostr(pn)+').');
    pn:= 0;
    end
    else begin
    fpt(pp).fp:= fpt(pp).fp^.next; pn:= pn-248;
    end;

fpt(pp).b4:= pn;

end; (*fsmultiforw*)


(*X*)
function fsdistance( pp1,pp2: fsptr ): fsint32;
(* DISTANCE BETWEEN TWO POINTERS IN A STRING. *)

var p1,p2: fsblockp; d: fsint32;
begin (*fsdistance*)

p1:= fsblockp(pp1); fpt(p1).b4:= 0;
p2:= fsblockp(pp2); fpt(p2).b4:= 0;
d:= 0;
while not (p1=p2) do begin
    p1:= p1^.next;
    d:= d + 248;
    end;

fsdistance:= d + fpt(pp2).b4 - fpt(pp1).b4;

end; (*fsdistance*)


procedure fscopy(p1,p2: fsptr; pendch: CHAR)
(* Copy p1 string to (end of) p2. Callers p1 and p2 remain unchanged
   (since  they are not var-declared). *);

var newp: fsblockp; i: fsint16; ch: CHAR;

begin (*fscopy*)

fsforwend(p2);

i:= fpt(p2).b4; (* Put next character in P2^.TXT[i] *)
fpt(p2).b4:= 0;

while not ( (p1^=eofs) OR (p1^=pendch) ) do begin

    (* TECKEN FR P1 *)
    ch:= p1^;
    (* TECKEN TILL P2 *)
    fpt(p2).fp^.txt[i]:= ch;

    (* FLYTTA FRAM I *)
    i:= i+1;
    if i=248 then begin
        fsnewblock(newp);
        fpt(p2).fp^.next:= newp;
        newp^.prev:= fpt(p2).fp;
        p2:= fsptr(newp);
        i:= 0;
        end;

    (* FLYTTA FRAM P1 *)
    fpt(p1).b4:= fpt(p1).b4+1;
    if fpt(p1).b4=248 then begin

        fpt(p1).b4:= 0;
        if fpt(p1).fp^.next=nil then
          xProgramError('X(fscopy): Error - next=0.')
        else fpt(p1).fp:= fpt(p1).fp^.next;
        end;
    end; (*while*)

(* AVSLUTA MED EOFS *)
fpt(p2).fp^.txt[i]:= eofs;

end; (*fscopy*)


function fstostr( pp: fsptr ): string;
(* Convert pp^ to a string. *)
var
ss: shortstring;
s: string;

begin (*fstostr*)

ss:= '';
s:= '';

while not (pp^=eofs) do begin
    if pp^=ctrlM then ss:= ss + CHR(13) (*(used to be writeln)*)
    else if pp^=CHR(0) then ss:= ss + 'nul'
    else if pp^=CHR(7) then ss:= ss + '^G'
    else if pp^=CHR(8) then ss:= ss + '^H'
    else if pp^=CHR(10) then ss:= ss + '^J'
    else if integer(pp^)<32 then ss:= ss + '^'+ inttostr(integer(pp^))
    else ss:= ss + pp^;
    if length(ss)>250 then begin
        s:= s + ss;
        ss:= '';
        end;
    fsforward(pp);
    end;
fstostr:= s+ss;

end; (*fstostr*)


function fsequalFilename(p1,p2: fsptr; pendch1,pendch2: CHAR): BOOLEAN
(* Compare two filenames until pendch. All blanks are considered
   in this version. *);

begin (*fsequalFilename*)

(* (from xx.pas) About case insensitive comparisons: if all bits are
   equal except bit 5, and bit 6 is set, then the two char's
   shall be treated as equal. The following comparison will
   thus be case insensitive if fscasemask=$DF (11011111) and
   case-sensitive if fscasemask=$FF. *)

(* Known error: "@" is found equal to "`", because @ is >= 0x40.
   Plausible solution: Use tables to convert P1^ and p2^
   to lower case if they are not completely equal. *)

(* Invariant: everything before p1,p2 is equal and not eofs. *)
while not (
   (p1^<>p2^) and (
      ((((ord(p1^) xor ord(p2^)) and fscasemask) or (not ord(p1^) and $40)) <> 0)
      or ((ord(p1^) and $5F)>90)
         )

   OR (p1^=pendch1) or (p1^=eofs)
   or (p2^=pendch2) or (p2^=eofs)
   )
    do begin
    fpt(p1).b4:= fpt(p1).b4+1;
    if fpt(p1).b4=248 then begin
        fpt(p1).b4:= 0; fpt(p1).fp:= fpt(p1).fp^.next;
        end;
    fpt(p2).b4:= fpt(p2).b4+1;
    if fpt(p2).b4=248 then begin
        fpt(p2).b4:= 0; fpt(p2).fp:= fpt(p2).fp^.next;
        end;
    end;
fsequalFileName:= (p1^=pendch1) and (p2^=pendch2);

end; (*fsequalFilename*)


procedure makeLcUcWsTabs;
var
i: char;
j: integer;
s1,s2:  AnsiString;
begin

s1:= '';
for i:=chr(0) to chr(255) do s1:= s1+i;

s2:= AnsiLowerCase(s1);
for j:=1 to 256 do begin
   fsLcWsTab[chr(j-1)]:= s2[j];
   end;

(* BFn 2021-09-07: "Ö" was correctly changed to "ö" when compiled in home computer, but
   not when compiled at the office computer (which has english language settings).
   Apparently, AnsiLowerCase is not consistent with ISO 8859-1 (Latin-1)
   So, we have to make sure that char Cx and Dx are converted to Ex and Fx. *)
for j:=$C0 to $DF do begin
      fsLcWsTab[char(j)]:= char(j+32);
      end;

// Tab = space, NBSP (Non braking space) = space
fsLcWsTab[char(9)]:= ' ';
fsLcWsTab[char($A0)]:= ' '; // NBSP (Non braking space)

(* Create conversion table for lowercase (used by <strLowerCase ...>). *)
s2:= AnsiLowerCase(s1);
for j:=1 to 256 do begin
   fsLcTab[chr(j-1)]:= s2[j];
   end;

(* Ansi cannot be trusted to follow latin-1.
   So, we have to make sure that char Cx and Dx are converted to Ex and Fx. *)
for j:=$C0 to $DF do begin
   fsLcTab[char(j)]:= char(j+32);
   end;

(* Create conversion table for uppercase (used by <strUpperCase ...>). *)
s2:= AnsiUpperCase(s1);
for j:=1 to 256 do begin
   fsUcTab[chr(j-1)]:= s2[j];
   end;

(* Ansi cannot be trusted to follow latin-1.
   So, we have to make sure that char Ex and Fx are converted to Cx and Dx. *)
for j:=$E0 to $FF do begin
      fsUcTab[char(j)]:= char(j-32);
      end;

end; (*makeLcWsTab*)

(* This table is used for <bits ...>. All characters are the same except
   that and tab, nbsp are coded as space. CR and LF are also coded as space
   <settings allowNewlineInBinaryInput>. fsAllowNewlineInBinaryInput need
   to be called when this setting is initialised or changed. *)
procedure makeBinaryWsTab;
var
i: char;
j: integer;
s1:  AnsiString;
begin

s1:= '';

for i:=chr(0) to chr(255) do s1:= s1+i;
for j:=1 to 256 do begin
   fsBinaryWsTab[chr(j-1)]:= s1[j];
   end;

// Tab = space, NBSP (Non braking space) = space
fsBinaryWsTab[char(9)]:= ' ';
fsBinaryWsTab[char($A0)]:= ' '; // NBSP (Non braking space)
fsBinaryWsTab[char(10)]:= ' '; // LF
fsBinaryWsTab[char(13)]:= ' '; // CR

end; (*makeBinaryWsTab*)

(* This table is used for <bits ...>. All characters are char(16)
   that '0'..'9' = char(0)..char(9), 'A' .. 'F' = char(10)..char(15) and
   'a'..'f' = char(10)..char(15). *)
procedure makeHtodTab;
var
i: char;
begin

for i:=char(0) to char(255) do fsHtodTab[i]:= char(16);
for i:= '0' to '9' do fsHtodTab[i]:= char(integer(i) - integer('0'));
for i:= 'A' to 'F' do fsHtodTab[i]:= char(10 + integer(i) - integer('A'));
for i:= 'a' to 'f' do fsHtodTab[i]:= char(10 + integer(i) - integer('a'));

end; (*makeHtodTab*)


procedure fsAllowNewlineInBinaryInput(pallowed: boolean);
(* To control wether newline characters are allowed or not in binary input
   (<bits ...>). Used by alSettings when the setting allowNewlineInBinaryInput
   is changed. *)
begin
if pallowed then begin
   fsBinaryWsTab[char(10)]:= ' '; // LF
   fsBinaryWsTab[char(13)]:= ' '; // CR
   end
else begin
   fsBinaryWsTab[char(10)]:= char(10);
   fsBinaryWsTab[char(13)]:= char(13);
   end;

end; (*fsAllowNewlineInBinaryInput*)


(* (new:) *)
function fsequal(p1,p2: fsptr; pendch1,pendch2: CHAR): BOOLEAN
(* Compare strings without considering character case, or type of
   whitespace, until pendch.
   Extra blanks (more than one blank or tab) are ignored.
   Used by alCase.
*);

var
ch1, ch2: char;
whiteSpace: boolean;

begin

   ch1:= fsLcWsTab[p1^];
   ch2:= fsLcWsTab[p2^];

   while not ((ch1 = pendch1) or (ch1 = eofs) or (ch2 = pendch2) or (ch2 = eofs) or
      (ch1 <> ch2) ) do begin

      whiteSpace:= ch1 = ' ';
      (* If not whiteSpace, then the following loop will only advance the pointer
         one step and update ch1. But if whitespace, then it will advance the
         pointer until something else than ' ' is found. *)
      repeat
         fpt(p1).b4:= fpt(p1).b4+1;
         if fpt(p1).b4=248 then begin
            fpt(p1).b4:= 0; fpt(p1).fp:= fpt(p1).fp^.next;
            end;
         ch1:= fsLcWsTab[p1^]
         until not whiteSpace or (ch1 <> ' ');

      whiteSpace:= ch2 = ' ';
      repeat
         fpt(p2).b4:= fpt(p2).b4+1;
         if fpt(p2).b4=248 then begin
            fpt(p2).b4:= 0; fpt(p2).fp:= fpt(p2).fp^.next;
            end;
         ch2:= fsLcWsTab[p2^];
         until not whiteSpace or (ch2 <> ' ');
      end;

   if (ch1=eofs) and (ch1<>pendch1) or (ch2=eofs) and (ch2<>pendch2) then begin
      xProgramError('fsEqual: end character '+pendch1+' or '+pendch2+' was not found.');
      fsequal:= false;
      end
   else fsequal:= (ch1 = pendch1) and (ch2 = pendch2);

end; (*fsEqual*)



(* (old:) *)
function fsequal0(p1,p2: fsptr; pendch1,pendch2: CHAR): BOOLEAN
(* Compare strings until pendch. Extra blanks (more than one) are ignored
   in this version *);

begin (*fsequal0*)

(* Copied from fsEqualFilename, then added ignoring of extra blanks. *)

(* Invariant: everything before p1,p2 is equal and not eofs. *)
while not (
   (p1^<>p2^) and (
      ((((ord(p1^) xor ord(p2^)) and fscasemask) or (not ord(p1^) and $40)) <> 0)
      or ((ord(p1^) and $5F)>90)
         )

   OR (p1^=pendch1) or (p1^=eofs)
   or (p2^=pendch2) or (p2^=eofs)
   )
    do begin
    fpt(p1).b4:= fpt(p1).b4+1;
    if fpt(p1).b4=248 then begin
        fpt(p1).b4:= 0; fpt(p1).fp:= fpt(p1).fp^.next;
        end;
    fpt(p2).b4:= fpt(p2).b4+1;
    if fpt(p2).b4=248 then begin
        fpt(p2).b4:= 0; fpt(p2).fp:= fpt(p2).fp^.next;
        end;
    end;
fsequal0:= (p1^=pendch1) and (p2^=pendch2);

end; (*fsequal0*)

function fsposint( pp: fsptr ): fsint32;
(* Decode fsint32 from string. *)
(* Skip lead blanks then read until not digit.
   Return -1 if no digit found. *)

var state: (s1,s2,s3,s4); n: fsint32; ch: CHAR;
ppstart: fsptr; pperr,errstr,errstr0: fsptr;
error: boolean;

begin (*fsposint*)

state:= s1; n:= 0;
ppstart:= pp;
error:= False;

while not ( (pp^=eofs) OR (state>=s3) ) do begin

    ch:= pp^;
    if fpt(pp).b4<247 then fpt(pp).b4:= fpt(pp).b4+1
    else begin
        fpt(pp).b4:= 0; fpt(pp).fp:= fpt(pp).fp^.next;
        end;

    CASE state OF
        s1: if ch=' ' then (*NOTHING*)
        else if ch IN ['0'..'9'] then begin
            n:= ORD(ch) - ORD('0');
            state:= s2;
            end
        else begin
            fsnew(errstr);
            errstr0:= errstr;
            pperr:= ppstart;
            while ord(pperr^)<ord('z') do begin
              fspshend(errstr,pperr^);
              fsforward(pperr);
              end;
            (* xScriptError('X(fsposint): Error - Unexpected non-digit character "'+ch
              +'" found in beginning of string "'+fstostr(errstr0)+'"');*)
            (* (Failures now handled outside fsposint by returning -1) *)
            state:= s4;
            fsdispose(errstr);
            end;
        s2: if ch IN ['0'..'9'] then
            n:= n*10 + ORD(ch) - ORD('0')
            else begin
               //BFn 2010-03-28: Anything after integer is an error
               if ch=char(fseoa) then state:= s3
               else state:= s4;
               end;
        s3: ;
        s4: ;
        end;(*CASE*)
    end; (*while*)

if state=s4 then fsposint:= -1
else fsposint:= n;

end; (*fsposint*)


procedure fsbitills( pi: fsint32; ps: fsptr )
(* fsint32 -> FS *);

var reversed,revstart: fsptr; digit: fsint16;

begin (*fsbitills*)

if pi=0 then fspshend(ps,'0')
else begin
   fsnew(reversed);
   revstart:= reversed;
   while not (pi=0) do begin
       digit:= pi MOD 10;
       pi:= pi DIV 10;
       fspshend(reversed,CHR( ORD('0') + digit ));
       end;
   while not (reversed=revstart) do begin
       fsback(reversed);
       fspshend(ps,reversed^);
       end;
   fsdispose(reversed);
   end;

end; (*fsbitills*)

procedure fspushandforward(var pfrom: fsptr; var pto: fsptr);
(* Time efficient procedure to replace for example
   fspshend(ut,ins^);
   fsforward(ins);
   by
   fspushandforward(ins,ut);
   in alMacro. *)

var p0,p1: fsblockp;// from fspshend
var p: fsptr; i: fsint16;  // from fsforward

begin

(* freely copied from fspshend: *)

(* Go to end of string. *)
if not (pto^=eofs) then fsforwend(pto);

pto^:= pfrom^;

if fpt(pto).b4<=246 then fpt(pto).b4:= fpt(pto).b4+1
else begin
   p0:= fsblockp(pto); fpt(p0).b4:= 0;
   fsnewblock(p1);
   p0^.next:= p1;
   p1^.prev:= p0;
   pto:= fsptr(p1);
   end;
pto^:= eofs;

(* freely copied from fsforward: *)

if pfrom^=eofs then begin
   emess:= 'X(fspushandforward): Error - end of fs,';
   p:= pfrom;
   for i:= 1 to 200 do begin
      if not ((fpt(p).b4=0) AND (fpt(p).fp^.prev=nil))
      then fsback(p);
      end;
   emess:= emess+'last characters: "'+fstostr(p)+'".';
   xProgramError(emess);
   end

else begin

   fpt(pfrom).b4:= fpt(pfrom).b4+1;
   if fpt(pfrom).b4=248 then begin

      fpt(pfrom).b4:= 0;
      if fpt(pfrom).fp^.next=nil then begin
         s:= '';
         while (pfrom^<>eofs) and (fpt(pfrom).b4<248) do begin
            s:= s + pfrom^;
            fpt(pfrom).b4:= fpt(pfrom).b4+1;
            end;

         xProgramError('X(fsforward): Error - next=nil ('
            +s+').');
         fpt(pfrom).b4:= 248;
         pfrom^:= eofs;
      end
      else fpt(pfrom).fp:= fpt(pfrom).fp^.next;
      end;
   end;

end; (*fspushandforward*)


procedure fstestfs(pp:fsptr);

var
s,p,P1,OLDP1,cs: fsptr;
ch,nch: CHAR;
ins: fsptr;

begin (*fstestfs*)

s:= pp;
p:= s;
fsnew(cs);
fsnew(ins);

iofWritelnToWbuf('F/B/A/E/D/N/Mch/C/Q/I:');

REPEAT

  (*  ch:= crt.readkey;*) (* crt finns inte i Delphi. *)
  ioreadln(ins); ch:= ins^;

    CASE ch of

        '?': iofWritelnToWbuf('F/B/A/E/D/N/Mch/C/Q/I:');

        'F': fsforward(p);

        'B': fsback(p);

        'A': iofWritelnToWbuf('p^='+p^);

        'E': ;

        'D': fsdelrest(p);

        'N': fsforwend(p);

        'M': begin
            READLN(nch);
            fsmultiforw(p,ORD(nch) - ORD('0'));
            end;

        'C': begin
            fscopy(p,cs,eofs);
            iofWriteToWbuf(fstostr(cs));
            end;

        'Q': if fsequal(p,cs,eofs,eofs) then iofWritelnToWbuf('TRUE')
             else iofWritelnToWbuf('FALSE');

        'I': iofWritelnToWbuf(inttostr(fsposint(p)));

        else fspshend(p,ch);
        end;

    P1:= S;
    while not (P1^=EOFS) do begin
    if p1^=CHR(13) then iofWritelnToWbuf('') else iofWriteToWbuf(P1^);
    oldp1:= p1; FSFORWARD(P1);
    if fpt(p1).b3<>fpt(oldp1).b3 then iofWriteToWbuf('-');  end;
    iofWritelnToWbuf('');

    P1:= S;
    while not (P1^=EOFS) do begin
    if P1^=CHR(13) then iofWriteToWbuf(char(13)) else
    if fpt(p1).fp=fpt(p).fp then iofWriteToWbuf('^') else iofWriteToWbuf(' ');
    oldp1:= p1; FSFORWARD(P1);
    if fpt(p1).b3<>fpt(oldp1).b3 then iofWriteToWbuf(' ');
    end;
    if fpt(p1).fp=fpt(p).fp then iofWriteToWbuf('^') else iofWriteToWbuf(' ');
    iofWritelnToWbuf('');

    UNTIL ch='E';

fsdispose(cs);
fsdispose(ins);

end; (*fstestfs*)

function fsusecount: fsint32;
begin
fsusecount:= usecount;
end;

(*X*)
procedure fstest;

var s: fsptr;
begin
fsinit;
fsnew(s);
fstestfs(s);
fsdispose(s);
end;

end.


