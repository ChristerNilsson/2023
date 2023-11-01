{$A8,B-,C-,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q+,R+,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE ON}
{$WARN UNSAFE_CODE ON}
{$WARN UNSAFE_CAST ON}
(* XAL.PAS *)
(* TODO: Move shiftbits to filerec. Shiftbits is not valid anymore if
   the input file is changed. Example: <in <sp 1>,string,local> ... ?"<bits 8"?
   !"..."! will use shiftbits if shiftbits was <> 0 when input file was
   changed. *)

UNIT xal;

{$MODE Delphi}

(* X application library. *)

(* 99-09-17: Version 1.03 started. alc, algoto, <unread>
             <read n/LN/*>, almacro corrected, *)
(* 99-01-16: Version 1.01 finished. 1.02 started. *)
(* 98-06-07: Major changes to make it look more like old X.
             Every routine does argument evaluation by itself. *)
(* 98-04-27: NEW X IN DELPHI 2.0 *)
(* 93-03-12: X IN TURBO PASCAL VERSION 4 *)

(****) INTERFACE (****)

USES
   xfs          (* fsptr, fspopfront, ... , fstest *)
   ,xt           (* ioinptr *)
   ,xx           (* xargblock, xname, xcompare, xtest, xSetUsage *)
   ,xio          (* ioin, ioinreadln, iounread, iooutrewrite, iotest. *)
   ,SysUtils     (* now, decodetime, decodedate. *)
   ,DateUtils    (* millisecondsbetween *)
   ,xioform      (* iofwritenow, iofclear, iofupdatecaption, debugform *)
   ,dialogs      (* TMsgDlgButtons *)
   ,interfaces // FPC
   ,forms        (* Application.terminate *)
   ,xunr         (* UnrBottomPtrAtEntryToCurrentState *)
//   ,LCLIntf, LCLType, LMessages      (* winExec *)
   ,windows
   ,shellapi
   ,controls     (* mrYes, mrNo, ... *)
   ,classes      (* TstringList *)
   ,sqlapi
   ,strutils (* AnsiContainsString *)
   ,winsock (* gethostbyname, inet_ntoa, Tsocket, send, recv, ... *)
   ;       (* sqlconnect, ... *)
//xdebug;       (* debugform *)

TYPE
alint16= INTEGER; (* (smallint is enough, but INTEGER is
                     recommended for efficiency.) *)
alint32= longint;

threadvar alThreadNr: alint16;

var
althreadcount: alint16 = 0; (* Running thread counter. Used by iocleanup
   while waiting for all threads to end. And by updateformcaption to show number
   of extra threads in caption. Also used in enterstring to avoid deleting
   local parameters if there are other threads running. *)

altoploadnr: integer = 0; (* Nr of top load file (if successful)
   (used by resolveStateRef). *)

alcasewarning: boolean = True; (* See <settings casewarning,yes/no> *)

alWin32WindowProc: integer = 0;

alcompileAlts: boolean = True; (* See <settings compilealts,yes/no> *)

alPrelDefWithNarg: boolean = False; (* Require arg 3 (min args) in <preldef ...> *)

alAllowFunctionCallsAfterPreact: boolean = false; (* To allow function calls
   before and after alternatives in the alternative list. Needed for
   <settings compileAlts,yes/no> (conditional compilation of alternatives). *)

alAllowBlanksBeforeCommentToEoln: boolean = true; (* If true: Allow
  blanks before comments which continue to end of line (or more). Example:
  ?"Si <integer>/ ( * p1:Ceiling speed * )
  -<integer> ( * p2:Target speed * )
  -<eof>"?
  (Blanks will not be inserted if this flag is true).
  Used by ioxRead. *)

alCheckUnreadPosAtExit: boolean; (* When true: If unread was used in the
   preactionCheck of a called state, check at return from the state that the
   position has been restored to the same position as when state was entered.
   Purpose is to find errors when for exampe <unread <sp 1>> is used in preaction
   and then the unread string shall be decoced in some way in the state.
   This use is however outdated, since now <in ...,string is instead used for this
   purpose. This variable is used by alsettings to control whether this test
   shall be done or not. *)

allowNewlineInBinaryInput: boolean = true; (* When true: Ignore newline
   characters (CR or LF) in binary input stream when reading bits.
   This can be useful if input is read from a text file where a hexadecimal
   string stretches over more than one line. Blanks are always ignored
   when reading binary data in hex form, using the <bits ...> function. *)

alHelpFunctionsStr:string = '';

procedure alCheckScriptError;
(* General subroutine to pick up a script error if there is one stored. *)

(*
const
alUseHexForMakeBitsDefault: boolean = false;
*)

var
alPfuncnr,alPdecfuncnr: ioint16; (* Number of <p n> (or <pdec n>)-function.
   Used by xcompilestring and almacro. *)
alSetFuncNr: ioint16;
alAppendFuncNr: ioint16;
alPackFuncNr: ioint16;
alPopFuncnr: ioint16;
alForeachFuncnr: ioint16;
alVarFuncnr: ioint16;
alFunctionFuncNr: ioint16;
alDefFuncNr: ioint16;
alPreldefFuncNr: ioint16;
alIfeqFuncNr: ioint16;
alCaseFuncNr: ioint16;
alXpFuncNr: ioint16;
alInFuncNr: ioint16;
alOutFuncNr: ioint16;
alCFuncNr: ioint16;
alJFuncNr: ioint16;
alC_LateEvaluationFuncNr: ioint16;
alUpdateFuncNr: ioint16;
alIndexesFuncNr: ioint16;
alBitsFuncNr: ioint16;
alRangeFuncNr: ioint16;
alDoFuncNr: ioint16;

alInSettingPrelDefWithNarg: boolean = false; // Used to allow <settings prelDefWithNarg,yes/no>

alCdIsInternetAddress: boolean = false; (* True = Current directory is
   an internet address (\\...). This is used to print an error message if, later,
   <command ...> is called because cmd.exe (windows command interpeter) does not
   support internet ("UNC") paths as current directories.
   Try doing cd \\mu2.global.sys\Projekt,from the
   windows command interpreter:
      '\\mu2.global.sys\Projekt'
      CMD does not support UNC paths as current directories.
   Initialised at startup and updated at alCd.
   Used by alCommand.
   *)

alPlayRunning: boolean;

alDllVersion: boolean = false; (* This shall be initialised to true in main
   program of DLL version (see xdll.lpr, at the end). *)

procedure alinit;

procedure alcall( pnr: alint16; var pargs: xargblock;
                  pevalkind: xevalkind;
                  var pstateenv: xstateenv;
                  pfuncret: fsptr);

FUNCTION alflagga( pch: CHAR ): BOOLEAN;
(* RETURNERA FLAGGAS VÄRDE *)

procedure alinttofs(pi: longint; var ps: fsptr );
(* Append string(pi) to ps. *)

procedure alstrtofs(ps1: string; ps2: fsptr );
(* Append string ps1 to ps2. *)

FUNCTION alfstostr100( ps: fsptr; pendch: char ): string;
(* Convert ps^ to a string, max 100 char's. *)

FUNCTION alfstostr( ps: fsptr; pendch: char ): string;
(* Convert ps^ to a string. *)

FUNCTION alfstostrlc( ps: fsptr; pendch: char ): string;
(* Convert ps^ to a lower case string. *)

procedure alBitsClear; (* Reset from bitsmode *)

(* By using alreset error and alerror, xload can check if any errors were
   discovered during evaluation of <...>-callsa. *)
procedure alreseterror;
function alerror: boolean;

(* Name of x file loaded from x window (used in title) . *)
function altoploadtitle: string;

(* Running threads. *)
function alrunningtitle: string;

(* Working directory. Used by ioxreset to take x files from the
   working directory if available there. *)
function alworkingdir: string;

function alseerrmess(perrcode: integer): string;
(* Decodes error code from shellexecute.
From newsgoups:Borland:borland public ... *)

function alshowcmd(ps:fsptr; pendch: char): integer;
(* Decode showcmd string (used in shellexecute). Example:
   alshowcmd('SW_SHOWNORMAL') = SH_SHOWNORMAL. *)

function alinmac(pxpos: fsptr): integer;
(* Return number of macro that pxpos points at, or 0 if none found. *)

procedure alInitLocVarParameters;
(* This procedure is available in case exception handling would disturb
   the state of these variables. *)

function alSystemErrorMessage: string;
(* = win32 getlasterror. *)

function alErrCode2Message(perrcode: integer): string;
(* Usage example:
   e:= getlasterror;
   if e<>0 then ioErrmessWithDebugInfo(alErrCode2Mess(e));. *)

function alShowCall(pnr: integer; var pargs: xargblock): string;
(* Show decoded call. Used in error messages.
   Freely copied from alVisaAnrop)
   Usage example: alShowCall(pargs);
*)

function alShowArg(parg: fsptr; pRecursive: boolean): string;
(* Show an argument, decompile if recursive. Used for error
   messages.
   Example (from alDef):
   parmin:= fsposint(arg[3]);
   if parmin<0 then
      xScriptError('X: Number expected as arg 3, found "'+
      alShowArg(arg[3],rekursiv[3])+'".');
*)

procedure aldebuglog(pwhere,pname,pvalue: string);

function alfstoint(ps: fsptr; var presult: integer): boolean;
(* Convert fs to integer, return false if failed. *)

(* Pointer where to save old In and out when in or out is changed:
   (used to restore io after <c ...> or <macro ...>). *)
threadvar
saveIo: xSavedIODataRecord;
alSaveIoPtr: xSavedIODataPtrType;

alLastIOWasPersistent: boolean;



(* alSaveIo
   --------
   Save current input and output file numbers.
   Called when in or out is changed the first time after calling a macro
   (<name ...>) or a state (<c ...> or <c_lateevaluation ...>).
   Used to restore io before returning from macro or state.
   Since current in and out only need to be saved once, alSaveIo deletes
   the pointer to the saved record after having saved. (But the
   records itself is addressable in alcall).
*)
procedure alSaveIo;

procedure alThreadInit;

function alTopLoaded: boolean; // true = <load... was entered and alLoadLevel = 1
var alLoadLevel: integer = 0; (* How many times alLoad has been called recursively.
   Used to detect when an x file is loaded directly (1) and not recursively (>1). *)

procedure alCloseCallTraceLog;
(* (See call trace framework close before alCall.) *)

function alPlayGetInput: string;

procedure alPlayLog(pStr: string);


procedure alOpenForRead(var pfile: file; pname: string; var pior: integer);
(* Open a file  with FileMode:= fmOpenRead + fmShareDenyNone.
   This allows opening a file that is already locked by another program.
*)
procedure alReadLine(var pfile: file; pStr: fsptr);
(* Read a line, from a (binary)file . *)


(****) IMPLEMENTATION (****)

uses
   ComObj // Used by alexcel
   ,variants // varisempty
   ,xdebug //debugdecompile
  ;

const
alMaxLocVar = 100;
// (new:)
alIndexMaxnr = 100;
// (old:)alIndexMaxnr = 20;

var
initialized: Boolean = False; (* True when alinit has been called. Alinit
                                  can then be called later to reset data
                                  without loosing fs-buffers. *)

flagTab: ARRAY['A'..'Z'] OF BOOLEAN;
eoa,eofs,eofr,ctrlM: CHAR;

mactab: ARRAY[0..xmaxfuncnr+alMaxLocVar] OF fsptr; (* Strings defined by <def ...> or
                                   <set ...>. These strings all end
                                   with eoa (otherwise fylli(...)
                                   would not work). *)
recursivemac: ARRAY[0..xmaxfuncnr] OF BOOLEAN; (* mactab[..] contains <...>-
                                          calls. *)
parmac: ARRAY[0..xmaxfuncnr] OF BOOLEAN; (* mactab[..] contains $- parameter
                                          insertions. *)

preldef: ARRAY[0..xmaxfuncnr] OF BOOLEAN; (* Preliminary defined macros.
                                      Defined with <preldef ...> -
                                      may be redefined. *)
containscleanup: array[0..xmaxfuncnr] of boolean; (* mactab[n] contains call to
                                      <cleanup>. Must be copied before evalu-
                                      ation. *)
cleanupfuncnr,
loadfuncnr: alint16;    (* Used to check if a macro contains calls to
                               <cleanup>. *)
prelDefFuncNr: alint16; (* Used to redefine min nr of args to preldef, from
                           <settings prelDefWithNarn,yes/no>. *)
xpfuncnr: alint16;    (* Used by alMacro to evaluate calls to xp directly when
                         replacing an argument reference ($n) with its argument
                         because the xp offset may otherwise change if the reference
                         is located in <ifeq ...> or <case ...>.  *)

atcleanup: fsptr; (* For <atcleanup ...> - Code to be executed at cleanup, including
                     form close. *)

(* Used by albits (<bits n>) and alp (<p n>): *)
bitsmode: Boolean; (* True = shiftbits is valid. *)
shiftbits: alint16; (* 0..3 number of bits to be shifted away from
                       1st (hexadecimal) char of input. *)
errorsfound: alint16 = 0; (* Error counter. Used by xload to check if any
                          errors were discovered during evaluation (e.g by
                          aldef). *)

restoreioaftermacro: boolean = False; (* If activated: input and output files
                                         are automatically restored at the end
                                         of a macro. This removes the need to
                                         save current input in saparate variables
                                         like "oldin", "saveout", etcetera. *)

// mainThreadId: dword:= 0; // FPC+ (from compare between delphi and fpc in home computer)

procedure alToUppercase( var pch: char );
(* Convert lowercase char to char to upper case. *)

(* Note. Implementation dependent (character encoding). *)

begin (*alToUppercase*)

if pch IN ['a'..'z',char($E5),char($E4),char($F6)(*'å','ä','ö'*)] then
   pch:= char( ORD(pch) - 32 );

end; (*alToUppercase*)


FUNCTION alfstostr100( ps: fsptr; pendch: char ): string;
(* Convert ps^ to a string, max 100 char's. *)
var
s: string; cnt: integer;

begin (*alfstostr100*)

s:= ''; cnt:= 0;

while not ((ps^=pendch) or (cnt>=100)) do begin
    if ps^=char(13) then s:= s + char(13) (*(used to be writeln)*)
    else if (ORD(ps^)<ORD(' ')) or (ORD(ps^)>=253) then
       s:= s+'('+inttostr(ORD(ps^))+')'
    else s:= s+ps^;
    fsforward(ps);
    cnt:= cnt+1;
    end;
if ps^<>pendch then s:= s + '...';

alfstostr100:= s;

end; (*alfstostr100*)

FUNCTION alfstostrlim( ps: fsptr; pendch: char; plim: integer ): string;
(* Convert ps^ to a string, max plim char's. *)
var
s: string; cnt: integer;

begin (*alfstostrLim*)

s:= ''; cnt:= 0;

while not ((ps^=pendch) or (cnt>=plim)) do begin
    if ps^=char(13) then s:= s + char(13) (*(used to be writeln)*)
    else if (ORD(ps^)<ORD(' ')) or (ORD(ps^)>=253) then
       s:= s+'('+inttostr(ORD(ps^))+')'
    else s:= s+ps^;
    fsforward(ps);
    cnt:= cnt+1;
    end;
if ps^<>pendch then s:= s + '...';

alfstostrLim:= s;

end; (*alfstostrLim*)

FUNCTION alfstostr( ps: fsptr; pendch: char ): string;
(* Convert ps^ to a string. *)
var
s: string;

begin (*alfstostr*)

s:= '';

while not ((ps^=pendch) or (ps^=eofs)) do begin
    s:= s+ps^;
    fsforward(ps);
    end;

alfstostr:= s;

end; (*alfstostr*)

function alfstostrConvCrToCrLf( ps: fsptr; pendch: char ): string;
(* Convert ps^ to a string. Conv CR without following LF to CRLF.
   Used by alDllCall because lone CR is not accepted as line delimeter in
   multiline Edit control. *)
var
s: string;
ch: char;

begin (*alfstostrConvCrToCrLf*)

s:= '';

while not ((ps^=pendch) or (ps^=eofs)) do begin
   ch:= ps^;
   s:= s+ch;
   fsforward(ps);
   if ch=char(13) then begin
      if ps^<>char(10) then s:= s+char(10);
      end;
   end;

alfstostrConvCrToCrLf:= s;

end; (*alfstostrConvCrToCrLf*)


(* Fs to c string, copied from alfstostrconvcrtocrlg and modified. *)
procedure alfstoCstrConvCrToCrLf(ps: fsptr; pendch: char; pBufSize: integer; pBuffer: ioinptr );
(* Convert ps^ to a c string. Conv CR without following LF to CRLF.
   Used by alDllCall because lone CR is not accepted as line delimeter in
   multiline Edit control. *)
var
ptr, nullPtr: ioinptr;
overflow: boolean;
ch: char;

begin (*alfstoCstrConvCrToCrLf*)

ptr:= pBuffer;
nullPtr:= ioinptr(integer(ptr)+pBufsize-1);
overFlow:= false;

while not ((ps^=pendch) or (ps^=eofs) or overFlow) do begin
   if integer(ptr)>=integer(nullPtr) then overFlow:= true
   else begin
      ch:= ps^;
      ptr^:= ch;
      ptr:= ioinptr(integer(ptr)+1);
      fsforward(ps);
      if ch=char(13) then begin
         if integer(ptr)>=integer(nullPtr) then overflow:= true
         else if ps^<>char(10) then begin
            ptr^:= char(10);
            ptr:= ioinptr(integer(ptr)+1);
            end;
         end;
      end;
   end;

if integer(ptr)>integer(nullPtr) then overflow:= true
else begin
   ptr^:= char(0);
   ptr:= ioinptr(integer(ptr)+1);
   end;

if overflow then xScriptError('alFsToCstrConvCrToCrLf: Buffer size was limited to '+
   inttostr(pbufsize)+ ' but string was longer.');

end; (*alfstoCstrConvCrToCrLf*)


function alfstoint(ps: fsptr; var presult: integer): boolean;
(* Convert fs to integer, return false if failed. *)
var
p0: fsptr;
sign:integer;
begin
p0:= ps;
if ps^='-' then begin
   sign:= -1;
   fsforward(ps);
   end
else if ps^='+' then begin
   sign:= 1;
   fsforward(ps);
   end
else sign:= 1;

presult:= fsposint(ps);
if presult<0 then begin
   presult:= 0;
   alfstoint:= false;
   end

else begin
   presult:= presult*sign;
   alfstoint:= true;
   end;

end; (*alfstoint*)


function alfscontains( ps: fsptr; pendch: char; pSearchCh: char): boolean;
(* Find pSearchCh in ps. *)
var
res: boolean;

begin (*alfscontains*)

res:= false;

while not ((ps^=pendch) or res) do begin
    if ps^=pSearchCh then res:= true;
    fsforward(ps);
    end;
alfscontains:= res;

end; (*alfscontains*)


FUNCTION alfstostrlc( ps: fsptr; pendch: char ): string;
(* Convert ps^ to a lower case string. *)
var
s: string;
ch: char;

begin (*alfstostrlc*)

s:= '';

while not ((ps^=pendch) or (ps^=eofs)) do begin
    ch:= ps^;
    if ch=char(13) then s:= s + char(13) (*(used to be writeln)*)
    else if (ORD(ch)<ORD(' ')) or (ORD(ch)>=253) then
       s:= s+'('+inttostr(ORD(ch))+')'
    else begin
      if ch IN ['A'..'Z',char($C5),char($C4),char($D6)(*'Å','Ä','Ö'*)] then
        ch:= char( ORD(ch) + 32 );
      s:= s+ch;
      end;
    fsforward(ps);
    end;
alfstostrlc:= s;

end; (*alfstostrlc*)

FUNCTION alfslen( ps: fsptr; pendch: char): alint32;
var s: fsptr;
begin
s:= ps;
while not (s^=pendch) do fsforward(s);
fsforwendch(s,pendch);
alfslen:= fsdistance(ps,s);
end;

(* Used by almakebits: *)

function alhextoint(pch: char): alint16;
var res: alint16;
(* (0 returned for non-hexadecimal characters). *)
begin
if (pch<'0') then res:= -1
else if (pch<='9') then res:= alint16(pch) - alint16('0')
else if pch<'A' then res:=0
else if pch<='F' then res:= alint16(pch) + 10 - alint16('A')
else if (pch>='a') and (pch<='f') then res:= alint16(pch) + 10 - alint16('a')
else res:= -1;
if res = -1 then begin
    xScriptError('X(alhextoint): Expected "0".."F", found "'+pch+'" (returns 0).');
    res:= 0;
    end;
alhextoint:= res;
end;

function alinttohex(pi: alint16): char;
begin
pi:= pi and $f;
if pi<=9 then alinttohex:= char(alint16('0')+pi)
else alinttohex:= char(alint16('A')+ pi - 10);
end;

procedure alfsshl(ps: fsptr; pn: alint16);
(* Shift an fs string pn bits to the left
   pn is 0..3. *)

var
ch1,ch2: char;
i: alint16;
ps0: fsptr;

begin

if (pn<0) or (pn>3) then begin
  iodebugmess('X(alfsshl): Prog error - pn outside range ('
  +inttostr(pn)+').');
  pn:= 0;
  end;

while (ps^<>eofs) do begin
    ch1:= ps^; ps0:= ps;
    fsforward(ps);
    if ps^=eofs then ch2:= '0'
    else ch2:= ps^;
    i:= (alhextoint(ch1) shl 4) + alhextoint(ch2);
    i:= (i shl pn) and $0ff;
    i:= i shr 4;
    ps0^:= alinttohex(i);
    end;

end; (*alfsshl*)



TYPE
alevalset = SET OF 1..xmaxnarg; (* Arguments to be evaluated.
                                  Example: [1,3]. *)
alevalmem = ARRAY[1..xmaxnarg]  (* Original contents of arg[n] *)
            OF fsptr;          (* before it was evaluated. *)

procedure alevaluate( var pargs: xargblock;
                      var pstateenv:xstateenv;
                      var pmem: alevalmem;
                      pmask: alevalset
                      );
(* Example: alevaluate(pargs,pstateenv,mem,[1,3])
            means evaluate arg[1] and arg[3] if they are
            <= narg and recursive. Use mem to store original
            pointers. *)
var i: xint16; s: fsptr;

begin

with pargs do begin

    for i:= 1 TO narg do if (i IN pmask) and rekursiv[i] then begin
        pmem[i]:= arg[i];
        fsnew(arg[i]);
        xevaluate(pmem[i],eoa,xevalnormal,pstateenv,arg[i]);
        s:= arg[i];
        fspshend(s,eoa);
        rekursiv[i]:= FALSE;
        end
    else pmem[i]:= nil;
    end;

end; (*alevaluate*)

procedure aldispose( var pargs: xargblock;
                     var pmem: alevalmem
                    );
(* Restore pargs.arg to what it was before
   alevaluate was called, using pmem. *)
var i: xint16;

begin

with pargs do for i:= 1 TO narg do begin

    if pmem[i]<>NIL then begin

        fsdispose(arg[i]);
        arg[i]:= pmem[i];
        pmem[i]:= NIL;
        rekursiv[i]:= TRUE;
        end;
    end;

end; (*aldispose*)

(* Function descriptions for functions which does not have its own procedure: *)
(* <windowclear>:
   Clear the X window
*)
(* <clear>: Clear the X window.
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

procedure algetbits( pinp:ioinptr; pnch: alint16; pshift1,pshift2: alint16;
                     ps: fsptr; var phexerror: char );
(* Get bits from a string of hexadecimal characters. Pshift1 tells where
   to start in first character. pshift2 tells where to stop in last character.
   pnch tells number of characters to scan. phex is set to false if failure
   because of non 0-9, A-F characters.
   Blanks are ignored.
   Usage: algetbits( "5A 6B", 3,3,2,str,hexerror) appends "69A" to str.
          algetbits( "5A 6B", 3,2,3,str,hexerror) appends "0D35" to str.
          if hexerror<>'0' then xProgramError('Unexpected char '+hexerror+'was read.');
   *)
var
inp: ioinptr;
cnt: alint16;
ch1,ch2: char;
chi: alint16;
hexerror: char;

function hextoint(pch: char): alint16;
var res: alint16;
(* This is same as alhextoint, except that an error flag is raised
   instead of printing an error message when non hexadecimal character
   is discovered. *)
begin
if (pch<'0') then res:= -1
else if (pch<='9') then res:= alint16(pch) - alint16('0')
else if pch<'A' then res:=0
else if pch<='F' then res:= alint16(pch) + 10 - alint16('A')
else if pch<'a' then res:=0
else if pch<='f' then res:= alint16(pch) + 10 - alint16('a')
else res:= -1;
if res = -1 then begin
    if hexerror='0' then hexerror:= pch;
    res:= 0;
    end;
hextoint:= res;
end;

begin

hexerror:= '0';

(* 1. Get first nonblank character. *)
inp:= pinp;
if inp^=eofr then ioingetinput(inp,true);

while fsBinaryWsTab[inp^]=' ' do begin
   ioinforward(inp);
   if inp^=char(eofr) then ioingetinput(inp,true);
   end;

(* 2. Init character counter. *)
cnt:= 0;

(* 3. Get first nibble if it is other than 4 bits long. *)
if inp^=eofs then (* Nothing - end of file. *)
else if pshift1=pshift2 then (* Nothing - 1st nibble (if any) is 4 bits. *)
else if pshift2>pshift1 then begin
   (* 1st nibble is contained within 1st char. *)
   ch1:= inp^;
   chi:= (hextoint(ch1) shl pshift1) and $f;
   chi:= chi shr (pshift1 + 4 - pshift2);
   fspshend(ps,alinttohex(chi));
   end
else if pshift2=0 then begin
   (* 1st nibble consumes 1st char to last bit). *)
   ch1:= inp^;
   cnt:= cnt+1;

   (* Go to 2nd char only if necessary, because otherwise
      x may wait for a character not yet received. *)
   if cnt<pnch then repeat
      ioinforward(inp);
      if inp^=char(eofr) then ioingetinput(inp,true);
      until fsBinaryWsTab[inp^]<>' ';

   chi:= (hextoint(ch1) shl 4);
   chi:= (chi shl pshift1) and $ff;
   chi:= chi shr (pshift1 + 4);
   fspshend(ps,alinttohex(chi));
   end
else begin
   (* 1st nibble extends into 2nd character *)
   ch1:= inp^;

   // Go to 2nd char
   repeat
      ioinforward(inp);
      if inp^=char(eofr) then ioingetinput(inp,true);
      until fsBinaryWsTab[inp^]<>' ';

   if inp^<>eofs then begin
      cnt:= cnt+1;
      ch2:= inp^;
      chi:= (hextoint(ch1) shl 4) + hextoint(ch2);
      chi:= (chi shl pshift1) and $ff;
      chi:= chi shr (pshift1 + 4 - pshift2);
      fspshend(ps,alinttohex(chi));
      end;
   end;

(* 4. Get any remaining nibbles. *)
while (cnt<pnch) and (inp^<>eofs) do begin
   ch1:= inp^;
   repeat
      ioinforward(inp);
      if inp^=char(eofr) then begin
         (* Get more data only if necessary. cnt=pnch-1 is ok if pshift2=0. *)
         if (pnch>cnt+1) or (pshift2>0) then ioingetinput(inp,true);
         end;
      until fsBinaryWsTab[inp^]<>' ';

   if (inp^<>eofs) or (pshift2=0) then begin
      cnt:= cnt+1;
      if pshift2=0 then begin
         chi:= hextoint(ch1);
         end
      else begin
         ch2:= inp^;
         chi:= (hextoint(ch1) shl 4) + hextoint(ch2);
         chi:= (chi shl pshift2) and $ff;
         chi:= chi shr 4;
         end;
      fspshend(ps,alinttohex(chi));
      end;
   end;

phexerror:= hexerror;

end; (*algetbits*)

procedure alOpenCallTraceLog; forward;


procedure alsetflag( var pargs: xargblock; var pstateenv: xstateenv );
(* <setflag ch>:
   Simple flag variable defined by a character.
   Exammple:
   <setflag a>
   ...
   <ifflag a,...>
*)

var
ch: CHAR;
mem: alevalmem;

begin (*alsetflag*)

alevaluate(pargs,pstateenv,mem,[1]);

ch:= pargs.arg[1]^;
alToUppercase(ch);
if ch IN ['A'..'Z'] then begin
   (* The following condition statements have no effect on result but
      makes it possible to put breakpoints here which stop the execution
      when the X reaches a particular position in the script (where
      for example <setflag A> is). *)
   if ch='A' then
      flagtab['A']:= true
   else if ch='B' then
      flagtab['B']:= true
   else if ch='C' then
      flagtab['C']:= true
   else if ch='F' then
      flagtab['F']:= true
   else if ch='G' then
      flagtab['G']:= true;

   flagTab[ch]:= true;
   if ch='E' then
      (* ++ Start logging of call trace information. *)
      // alOpenCallTraceLog;
   end

else if ch IN [char($C5),char($C4),char($D6)(*'Å','Ä','Ö'*)] then flagTab[ch]:= true

else xScriptError('X: Error - illegal flag - '+ch+'.');

aldispose(pargs,mem);

end; (*alsetflag*)

procedure alRange( var pargs: xargblock; var pstateenv: xstateenv; pfuncret: fsptr);
(*--------------*)
(* <range n1,n2[,delim]>:
   Returns a list of numbers, from n1 to n2, delimited by delim (default: "|").
   Normally used in <foreach ...> statements, to process something that is
   numbered from n1 to n2.
   Example: <foreeach $n,1,5,<case $tab[$n],...>>

   Equivalent to (except that delimiter is fixed):
   <function range,
   -<var $n,$1>
   -<if $2'>=$1,
   --$1
   --<while $n'<$2,
   ---<update $n,+1>
   ---|$n
   --->
   -->
   ->
*)
var
mem: alevalmem;
n1,n2,n: integer;
delimchar: char;
delimstr: string;
delimLen: integer;
good: boolean;
nrlist:string;


begin
alevaluate(pargs,pstateenv,mem,[1..3]);
n1:= 1; n2:= 0; // To please compiler
with pargs do begin
   good:= alfstoint(arg[1],n1);
   if good then good:= alfstoint(arg[2],n2);
   if good then begin
      // Determine delimiter
      if narg>2 then begin
         delimStr:= alfstostr(arg[3],eoa);
         delimLen:= length(delimstr);
         if delimLen=1 then delimChar:= delimstr[1];
         end
      else begin
         delimChar:= '|';
         delimLen:= 1;
         end;
      if n2>=n1 then begin
         n:= n1;
         alinttofs(n,pfuncret);
         while n<n2 do begin
            n:= n+1;
            if delimLen=1 then fspshend(pfuncret,delimChar)
            else fscopy (arg[3],pfuncret,eoa);
            alinttofs(n,pfuncret);
            end;
         end;
      end // good
   else
       // Not good
       xScriptError('Range: integers were expected as arg1 and arg2, but "' +
         alfstostr(arg[2],eoa) + '" and "' + alfstostr(arg[3],eoa) + '" were found.');
   end; // with
end; // alRange



procedure alresetflag( var pargs: xargblock;  var pstateenv: xstateenv );
(* <resetflag ch>:
   Reset a simple flag variable, defined by a character.
   See functions <setflag ch>, <flag ch> and <ifflag ch>.
   Example:
   <setflag a>
   ...
   <ifflag a,...>
   ...
   <resetflag a>
   ...
   <ifflag a,...>
*)

var
ch: CHAR;
mem: alevalmem;

begin (*alresetflag*)

alevaluate(pargs,pstateenv,mem,[1]);

ch:= pargs.arg[1]^;
alToUppercase(ch);
if ch IN ['A'..'Z'] then begin
   flagTab[ch]:= false;
   if ch='E' then
      (* If logging of calls were started with <setflag E> then
         it is now ended. *)
      alCloseCallTraceLog;
   end

else xScriptError('X: Error - illegal flag - '+ch+'.');

aldispose(pargs,mem);

end; (*alresetflag*)


procedure alflag( var pargs: xargblock; var pstateenv: xstateenv; pfuncret: fsptr);
(* <flag ch>:
   Returns "1" if set, else "0".
   Example: <wcons Flag a = <flag a>.>
*)

var ch: CHAR;
mem: alevalmem;

begin (*alflag*)

alevaluate(pargs,pstateenv,mem,[1]);

ch:= pargs.arg[1]^;
alToUppercase(ch);
if flagTab['D'] then iodebugmess('AFLAG: CH='+CH);
if ch in ['A'..'Z'] then begin
   if flagTab[ch] then fspshend(pfuncret,'1') else fspshend(pfuncret,'0');
   end

else xScriptError('X: Error - illegal flag - '+ch+'.');

aldispose(pargs,mem);

end; (*alflag*)


FUNCTION alflagga( pch: CHAR ): BOOLEAN;
(* RETURNERA FLAGGAS VÄRDE *)

begin
alToUppercase(pch);
alflagga:= flagTab[pch];
end;


procedure alifflag( var pargs: xargblock;
                pevalkind:xevalkind;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <ifflag ch,thenstr[,elsestr]>:
   where x is a flag identified by one character a-z.
   Example:
   <setflag a>
   ...
   <ifflag a,...,...>
*)
(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate). *)

var n: alint16; ch: CHAR;
mem: alevalmem;

begin (*alifflag*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

    ch:= arg[1]^; alToUppercase(ch);
    if ch IN ['A'..'Z'] then begin
        if flagTab[ch] then n:= 2 else n:= 3;
        if n<=narg then begin
            if rekursiv[n] then
               xevaluate(arg[n],eoa,pevalkind,pstateenv,pfuncret)
            else fscopy(arg[n],pfuncret,eoa);
            end;
        end

   else xScriptError('X: Error - illegal flag - '+ch+'.');
   end;

aldispose(pargs,mem);

end; (*alifflag*)

(* Copy to small buffer, allocate new bigger if necessary. *)
procedure copyToBuffer(parg1: fsptr; pSmallBufSize: integer; var pBufp: ioInPtr;
   var pEndp: ioInPtr);
var
slen: alint16;
a1,a2: fsptr;
ip: ioinptr;
blen: alint16;

begin

   (* First try with a small buffer. *)
   slen:= 0;
   a1:= parg1;
   ip:= pbufp;
   while not ((a1^=eoa) or (slen=psmallbufsize-1)) do begin
      ip^:= a1^;
      fsforward(a1);
      ip:= ioinptr(ioint32(ip)+1);
      slen:= slen+1;
      end;

   if a1^<>eoa then begin
      (* Smallbuf was too small. Use getmem to allocate a sufficient buffer. *)
      a1:= parg1;
      a2:= a1;
      fsforwendch(a2,eoa);
      slen:= fsdistance(a1,a2);
      getmem(pbufp,slen+1);
      ip:= pbufp;
      blen:= 0;

      while not (a1^=eoa) do begin
         ip^:= a1^;
         fsforward(a1);
         ip:= ioinptr(ioint32(ip)+1);
         blen:= blen+1;
         end;
      if blen<>slen then xProgramError('X: program error - blen<>slen.');
      if a1<>a2 then xProgramError('X: program error - a1<>a2.');
      end;

   pEndp:= ip;

   (* String shall end with eofs. *)
   pEndp^:= char(eofs);


end;(*copyToBuffer*)

// (new:)
procedure alifeq( var pargs: xargblock;
   pevalkind: xevalkind;
   var pstateenv: xstateenv;
   pfuncret: fsptr );
(* <ifeq str1,str2,thenstr,elsestr>:
   Compares two strings.
   str2 can contain patterns (<...>).
   thenstr can contain <xp n> (part of str1 according to '<...'> in str2).
   Example:
   <ifeq <p 1>,<integer> <integer>,<wcons i1 = <xp 1>', i2 = <xp 2>>
*)
(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate). *)

const smallbufsize = 100;

var
mem: alevalmem;
equal: BOOLEAN;
smallbuf: array[1..smallbufsize] of char;
bufp,endp: ioinptr;
saveinp: ioinptr;
optsave: char;
xparoffset0,nxpar0: integer;
savecompare: boolean;
savebitsmode: boolean;
saveshiftbits: integer;

begin (*alifeq*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

   (* Use current regard-cr-as-blank-for-files -option even if current input is console. *)
   optsave:= xoptcr;
   xoptcr:= xoptcrfile;
   if xoptcr=char(13) then xoptcr2:= char(10) else xoptcr2:= ' ';

   // Copy arg[1] to bufp, allocate a new larger buffer if necessary
   bufp:= @smallbuf[1];
   copyToBuffer(pargs.arg[1],smallbufsize,bufp,endp);
   (* At this stage: bufp points at evaluated arg1. endp points after
      last real character in bufp and at eofs. If smallbuf was to small
      then bufp points at a new buffer which was allocated with getmem. *)

   saveinp:= pstateenv.cinp;
   saveCompare:= pstateenv.compare;
   savebitsmode:= bitsmode;
   saveshiftbits:= shiftbits;
   bitsmode:= false;

   pstateenv.cinp:= bufp;

   (* This is to check that states which read in files are not called. *)
   pstateenv.compare:= true;

   with pstateenv.pars do begin
      (* Push current <xp n>, and reset for additional: *)
      xparoffset0:= xparoffset;
      nxpar0:= nxpar;
      end;
   xcompare(pargs.arg[2],eoa,FALSE,true,pstateenv,equal);
   if equal and (pstateenv.cinp<>endp) then
      equal:= false;
   pstateenv.cinp:= saveinp;
   pstateenv.compare:= savecompare;
   bitsmode:= savebitsmode;
   shiftbits:= saveshiftbits;

   (* Restore xoptcr *)
   xoptcr:= optsave;
   if xoptcr=char(13) then xoptcr2:= char(10) else xoptcr2:= ' ';

   if equal then begin
      (*  Then... *)
      if narg>=3 then begin
         if rekursiv[3] then xevaluate(arg[3],eoa,pevalkind,pstateenv,pfuncret)
         else fscopy(arg[3],pfuncret,eoa);
         end;
      with pstateenv.pars do begin
         xparoffset:= xparoffset0;
         nxpar:= nxpar0;
         end;
      end
   else begin
      (* Else ... (old <xp ...> variables shall again be available in else clause). *)
      with pstateenv.pars do begin
         xparoffset:= xparoffset0;
         nxpar:= nxpar0;
         end;
      if narg>=4 then begin
         if rekursiv[4] then xevaluate(arg[4],eoa,pevalkind,pstateenv,pfuncret)
         else fscopy(arg[4],pfuncret,eoa);
         end;
      end;

   (* Restore allocated buffer if any. *)
   if bufp<>@smallbuf[1] then
      Freemem(bufp);
   end;(* with pargs *)

aldispose(pargs,mem);

end; (*alifeq*)



(* alIfGt
   --------
   <ifgt i1,i2,str1[,str2]>
   - If integer i1 > integer i2, execute str1, else execute (optional) str2.
   <ifgt str1,str2,str3[,str4]>
   - compare str1 with str2 alphabetically execute str3 if str1 is "after" str2, else
      execute (optional) str4.

   (Converted from Xnew C-version)
*)
procedure alifgt( var pargs: xargblock;
   pevalkind: xevalkind;
   var pstateenv: xstateenv;
   pfuncret: fsptr );
(* <ifgt str1,str2,thenstr,elsestr>:
   = if str1 > str2 then thenstr else elsestr
   primarily numerical comparison.
*)
(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate). *)

var
mem: alevalmem;
arg1,arg2: fsptr;
ptr1,ptr2,endPtr1,endPtr2,newEndPtr: fsptr;
leader,n: integer;
numbers: boolean;

begin (*alifgt*)

alevaluate(pargs,pstateenv,mem,[1,2]);

with pargs do begin
   arg1:= arg[1];
   arg2:= arg[2];
   end;

// 0. Skip leading blanks.
while (arg1^=' ') or (arg1^=char(9)) do fsforward(arg1);
while (arg2^=' ') or (arg2^=char(9)) do fsforward(arg2);

numbers:= false;
leader:= 0;
ptr1:= arg1;
ptr2:= arg2;

if (ptr1^>='0') and (ptr1^<='9') and (ptr2^>='0') and (ptr2^<='9') then begin

   // Assume that arg1 and arg2 are numbers
   numbers:= true;

   // 1. Compare as integer or real numbers

   // 2. Skip redundant leading zeroes
   while (ptr1^='0') do fsforward(ptr1);
   // There must be at least one digit, even if it is zero.
   if (ptr1<>arg1) and ( (ptr1^<'0') or (ptr1^>'9') ) then fsback(ptr1);
   while (ptr2^='0') do fsforward(ptr2);
   if (ptr2<>arg2) and ( (ptr2^<'0') or (ptr2^>'9') ) then fsback(ptr2);

   while (ptr1^>='0') and (ptr1^<='9') and (ptr2^>='0') and (ptr2^<='9') do
      begin
      if leader=0 then begin
         if ptr1^>ptr2^ then leader:= 1
         else if ptr2^>ptr1^ then leader:= 2;
         end;
      fsforward(ptr1);
      fsforward(ptr2);
      end;

   (* Either ptr1^ or ptr2^ (or both) is not a digit. If anyone of them is,
      then it will be the winner, regardless of who was leading. *)
   if (ptr1^>='0') and (ptr1^<='9') then begin
      leader:= 1;
      while (ptr1^>='0') and (ptr1^<='9') do fsforward(ptr1);
      end
   else if (ptr2^>='0') and (ptr2^<='9') then begin
      leader:= 2;
      while (ptr2^>='0') and (ptr2^<='9') do fsforward(ptr2);
      end;

   (* At this stage, neither ptr1 or ptr2 points at a digit. The integral part have
      been passed but either arg1 or arg2 can have a fractional part. *)
   if (ptr1^='.') then fsforward(ptr1);
   if (ptr2^='.') then fsforward(ptr2);

   // Compare both fractions
   while (ptr1^>='0') and (ptr1^<='9') and (ptr2^>='0') and (ptr2^<='9') do
      begin
      if leader=0 then begin
         if ptr1^>ptr2^ then leader:= 1
         else if ptr2^>ptr1^ then leader:= 2;
         end;
      fsforward(ptr1);
      fsforward(ptr2);
      end;

   (* Now there is either fraction digits from arg1 or from arg2 or none of them left
      If a leader has not yet been found, then any digit > 0 will make the difference. *)
   // See if arg1 has any remaining fraction digit(s) >0.
   while (ptr1^>='0') and (ptr1^<='9') do begin
      if (leader=0) and (ptr1^>'0') then leader:= 1;
      fsforward(ptr1);
      end;
   // See if arg2 has any remaining fraction digit(s) >0.
   while (ptr2^>='0') and (ptr2^<='9') do begin
      if (leader=0) and (ptr2^>'0') then leader:= 2;
      fsforward(ptr2);
      end;

   // Now, both number 1 and number 2 are completely scanned
   // Skip any trailing blanks.
   while (ptr1^=' ') or (ptr1^=char(9)) do fsforward(ptr1);
   while (ptr2^=' ') or (ptr2^=char(9)) do fsforward(ptr2);

   (* if there is anytning left in arg1 or arg2, then either of them was not
      a number after all. *)
   if (ptr1^<>eoa) or (ptr2^<>eoa) then numbers:= false;
   end;

if (not numbers) then begin

   (* Either arg1 or arg 2 or both was not numerical - start
      all over again with an alphabetical comparison. *)
   leader:= 0;
   ptr1:= arg1;
   ptr2:= arg2;

   // Skip trailing blanks
   endPtr1:= ptr1;
   newEndPtr:= nil;
   while endPtr1^<>eoa do begin
      if (endPtr1^=' ') or (endPtr1=char(9)) then begin
         if newEndPtr=nil then newEndPtr:= endPtr1;
         end
      else newEndPtr:= nil;
      fsforward(endPtr1);
      end;
   if newEndPtr<>nil then endPtr1:= newEndPtr;

   endPtr2:= ptr2;
   newEndPtr:= nil;
   while endPtr2^<>eoa do begin
      if (endPtr2^=' ') or (endPtr2=char(9)) then begin
         if newEndPtr=nil then newEndPtr:= endPtr2;
         end
      else newEndPtr:= nil;
      fsforward(endPtr2);
      end;
   if newEndPtr<>nil then endPtr2:= newEndPtr;

   // Compare as strings
   while (fslcWsTab[ptr1^]=fslcWsTab[ptr2^]) and (ptr1<>endPtr1) and (ptr2<>endPtr2) do
      begin
      fsforward(ptr1);
      fsforward(ptr2);
      end;

   // if both pointers are
   if (ptr1=endPtr1) and (ptr2<>endPtr2) then
      // arg1 is at the end but there is more to read in arg2
      leader:= 2
   else if (ptr2=endPtr2) and (ptr1<>endPtr1) then
      // arg2 is at the end but there is more to read in arg1
      leader:= 1
   else begin
      if fslcWsTab[ptr1^]>fslcWsTab[ptr2^] then leader:= 1
      else leader:= 2;
      end;

   end;// (not numerical)

// Finally - evaluate arg3 if arg1 > arg2, else evaluate (optional) arg4.
with pargs do begin
    if leader=1 then n:= 3 else n:= 4;
    if n<=narg then begin
        if rekursiv[n] then
           xevaluate(arg[n],eoa,pevalkind,pstateenv,pfuncret)
        else fscopy(arg[n],pfuncret,eoa);
        end;
    end;

aldispose(pargs,mem);

end;// (alIfGt)


procedure alfstoreal( var ps: fsptr; var pr: REAL ); forward;
(* Convert fs to real. Ps points at 1st digit. After, ps
   points just after last digit. *)



// (new:)
procedure alcase( var pargs:xargblock; pevalkind: xevalkind;
   var pstateenv: xstateenv; pfuncret: fsptr );
(* <case control,[test1,res1[,test2,res2,...]][,,elseres]>:
   control: input string
   testn: pattern string n (can contain <...>)
   resn: evaluate and return if testn is matched by control.
*)
(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate). *)

const smallbufsize = 100;

var
resarg: alint16;
found:BOOLEAN;
mem: alevalmem;
equal: BOOLEAN;
arg1copied: boolean;
smallbuf: array[1..smallbufsize] of char;
bufp,endp: ioinptr;
saveinp: ioinptr;
xparoffset0,nxpar0: integer;
savecompare: boolean;
savebitsmode: boolean;
saveshiftbits: integer;

begin (*alcase*)

alevaluate(pargs,pstateenv,mem,[1]);

if not odd(pargs.narg) then
   xScriptError('X: '+
   'Odd number of arguments was expected but ' + inttostr(pargs.narg) +
   ' arguments were found.')

else with pargs do begin

   found:= FALSE;
   arg1copied:= false;
   resarg:= 3;

   with pstateenv.pars do begin
      (* Push current <xp n>, and reset for additional: *)
      xparoffset0:= xparoffset;
      nxpar0:= nxpar;
      end;

   while not ( (resarg>narg) or found ) do begin

      if rekursiv[resarg-1] then begin

         (* Copy arg1 to a shortstring if not already done. *)
         if not arg1copied then begin


            // Copy arg[1] to bufp, allocate a new larger buffer if necessary
            bufp:= @smallbuf[1];
            copyToBuffer(pargs.arg[1],smallbufsize,bufp,endp);
            (* At this stage: bufp points at evaluated arg1. endp points after
               last real character in bufp and at eofs. If smallbuf was to small
               then bufp points at a new buffer which was allocated with getmem. *)

            arg1copied:= true;
            end;

         (* Force xcompare to work on bufp instead of input stream. *)
         saveinp:= pstateenv.cinp;
         pstateenv.cinp:= bufp;
         savecompare:= pstateenv.compare;
         savebitsmode:= bitsmode;
         saveshiftbits:= shiftbits;
         bitsmode:= false;
         pstateenv.compare:= true;
         xcompare(pargs.arg[resarg-1],eoa,FALSE,true,pstateenv,equal);
         if equal and (pstateenv.cinp<>endp) then begin
            equal:= false;
            // <xp n> are no longer valid (in the "others" case).
            pstateenv.pars.nxpar:= 0;
            end;

         pstateenv.cinp:= saveinp;
         pstateenv.compare:= savecompare;
         bitsmode:= savebitsmode;
         shiftbits:= saveshiftbits;

         if equal then found:= true;
         end(* rekursiv *)

      else begin
         if fsequal(arg[1],arg[resarg-1],eoa,eoa) then found:= TRUE
         end;
      if not found then resarg:= resarg + 2;
      end; (*while*)

   if not found and odd(narg) and (arg[narg-1]^=eoa) then begin
      resarg:= narg; (* OTHERS *)
      found:= TRUE;
      end;
   if found then begin
      if rekursiv[resarg] then
         xevaluate(arg[resarg],eoa,pevalkind,pstateenv,pfuncret)
      else fscopy(arg[resarg],pfuncret,eoa);
      end
   else if alcasewarning then
      xScriptError('X: Unable to find a matching '+
         'alternative (and <settings casewarning,yes> is active).');

   with pstateenv.pars do begin
      xparoffset:= xparoffset0;
      nxpar:= nxpar0;
      end;

   // Release any storage allocated in copyToBuffer
   if arg1copied and (bufp<>@smallbuf[1]) then
      Freemem(bufp);
   end; (*with pargs*)

aldispose(pargs,mem);

end; (*alcase*)


function calc( ps: fsptr; var perror: boolean ): real; forward;

procedure alwhile( var pargs: xargblock;
                   pevalkind: xevalkind;
                   var pstateenv: xstateenv;
                   pfuncret: fsptr );
(* <while condition,dostr[,timeout][,timeoutaction]>:
   Evaluate dostr until condition is >0 or yes or timeout.
   Default timeout = 10000 ms (10 s)
   Empty timeout = No timeout (go on forever)
*)
(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate). *)

var
mem: alevalmem;
a1,s: fsptr;
r: real;
finished, timeout: boolean;
starttime: Tdatetime;
maxtime: int64;
error: boolean;

begin (*alwhile*)

alevaluate(pargs,pstateenv,mem,[3]);
if pargs.rekursiv[1] then fsnew(a1);

with pargs do begin

   finished:= false;
   timeout:= false;
   starttime:= time;
   maxtime:= 10000; (* Default *)
   if narg>2 then begin

      if arg[3]^=eoa then
         // No timeout
         maxtime:= 0

      else begin
         maxtime:= fsposint(arg[3]);
         if maxtime<0 then begin
            finished:= true;
            xScriptError('X: '+
               'Positive integer expected expected as arg 3, found "'+
               alfstostr100(arg[3],eoa)+'".');
            maxtime:= 0;
            end;
         end;
      end;

   while not (finished or timeout or ioclosing or iodoingcleanup or xfault) do begin

      if rekursiv[1] then begin
         fsrewrite(a1);
         xevaluate(arg[1],eoa,xevalnormal,pstateenv,a1);
         s:= a1;
         fspshend(s,eoa);
         end
      else a1:= arg[1];

      r:= calc(a1,error);

      if r<>0.0 then
         xevaluate(arg[2],eoa,pevalkind,pstateenv,pfuncret)
      else finished:= true;

      if (millisecondsbetween(time,starttime)>maxtime) and (maxtime>0)
         and not xfault then begin
         timeout:= true;
         if pargs.narg>3 then
            xevaluate(arg[4],eoa,pevalkind,pstateenv,pfuncret)
         else
            xScriptError('X: '+
               'Timeout in while loop and no timeout action specified.');
         end;
      end; (* while *)
   end; (* with pargs *)

if pargs.rekursiv[1] then fsdispose(a1);
aldispose(pargs,mem);

end; (*alwhile*)



procedure alif( var pargs: xargblock;
                pevalkind: xevalkind;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <if condition,thenstr[,elsestr]>:
   Condition contains an algebraic expression.
   Remember that < and > must be quoted not to be interpreted as
   start and end of function call

   Example:
   <if $a'>$b & $c=$d,<wcons a'>b and c=d.>,<wcons Other values.>>
*)
(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate). *)

var
mem: alevalmem;
r: real;
error: boolean;

begin (*alif*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

    r:= calc(arg[1],error);
    if r<>0.0 then
       xevaluate(arg[2],eoa,pevalkind,pstateenv,pfuncret)
    else if narg>2 then
       xevaluate(arg[3],eoa,pevalkind,pstateenv,pfuncret);
    end; (* with pargs *)

aldispose(pargs,mem);

end; (*alif*)


procedure alifelseif( var pargs: xargblock;
                pevalkind: xevalkind;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <if cond1,thenstr1,cond2,thenstr2[,cond3,thenstr3...][,elsestr]>:
   An <if ...> statement can be extended to an if ... elseif ... then ...
   elseif ... then ..., just by adding new conditions and new then strings
   An optional conditionsless else string can be added at the end.
*)
(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate). *)

var
mem: alevalmem;
r: real;
error: boolean;
found,n: integer;
condStr,condStr0: fsptr;

begin (*alifelseif*)

fsnew(condStr);
condStr0:= condStr;

with pargs do begin

   found:= 0;
   n:= 1;

   // Test conditions one by one except last condition
   while (n+1<=narg) and (found=0) do begin

      xevaluate(arg[n],eoa,xevalnormal,pstateenv,condStr);
      fspshend(condStr,eoa);
      r:= calc(condStr0,error);
      if r<>0.0 then found:= n+1
      else begin
         // Prepare to test next condition
         n:= n+2;
         fsrewrite(condStr);
         end;
      end;

   if found=0 then begin

      (* n+1>narg and no successful condition found yet. Use the default else arg
         if there is one. *)
      if n=narg then found:= n

      // For backwards compatibility: Accept empty last alt as default
      else if narg>=7 then begin
         if (n=narg+1) and (arg[n-2]^=eoa) then
            // Last elseif condition was empty, use as default (old format)
            found:= narg;
         end;
      end;

   if found>0 then
      // Evaluate the thenstr associated with the first found condition
      xevaluate(arg[found],eoa,pevalkind,pstateenv,pfuncret);
   end; (* with pargs *)

// Release condition string;
fsDispose(condStr);

end; (*alifelseif*)


procedure alUnless( var pargs: xargblock;
                pevalkind: xevalkind;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <unless condition,thenstr>:
   Condition contains an algebraic expression.
   Remember that < and > must be quoted not to be interpreted as
   start and end of function call

   Example:
   <unless $timepassed=0,<set $speed,<calc $distance/$timepassed>>
*)

var
mem: alevalmem;
r: real;
error: boolean;

begin (*alUnless*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

    r:= calc(arg[1],error);
    if r=0.0 then xevaluate(arg[2],eoa,pevalkind,pstateenv,pfuncret)
    end; (* with pargs *)

aldispose(pargs,mem);

end; (*alUnless*)


procedure alDo( var pargs: xargblock;
                pevalkind: xevalkind;
                var pstateenv: xstateenv);
(* <do str>:
   Evaluate str without returning its output.
   Equivalent to the ugglier <ifeq str,,>.
*)

var
mem: alevalmem;

begin (*alDo*)

alevaluate(pargs,pstateenv,mem,[1]);

aldispose(pargs,mem);

end; (*alDo*)



procedure alifis( var pargs: xargblock;
                pevalkind: xevalkind;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <ifis str,thenstr[,elsestr]>:
   Shorter and faster version of <if <is str>,thenstr[,elsestr]>
*)

var
mem: alevalmem;

begin (*alifis*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

    if arg[1]^<>eoa then
       xevaluate(arg[2],eoa,pevalkind,pstateenv,pfuncret)
    else if narg>2 then
       xevaluate(arg[3],eoa,pevalkind,pstateenv,pfuncret);
    end; (* with pargs *)

aldispose(pargs,mem);

end; (*alifis*)


procedure alifempty( var pargs: xargblock;
                pevalkind: xevalkind;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <ifempty str,thenstr[,elsestr]>:
   Shorter and more readable version of <ifeq str,,thenstr[,elsestr]>
*)

var
mem: alevalmem;

begin (*alifempty*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

    if arg[1]^=eoa then
       xevaluate(arg[2],eoa,pevalkind,pstateenv,pfuncret)
    else if narg>2 then
       xevaluate(arg[3],eoa,pevalkind,pstateenv,pfuncret);
    end; (* with pargs *)

aldispose(pargs,mem);

end; (*alifempty*)


procedure alis( var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <is str>, <is str,str,str...>:
   Return yes if all str are non-empty.
   Examples: <is 1> => Yes, <is 1,> => No, <is 1,2,3> => Yes.
*)

var
mem: alevalmem;
answer: boolean;
n: integer;

begin (*alis*)

alevaluate(pargs,pstateenv,mem,[1..pargs.narg]);

if pargs.narg=1 then begin
   // Single argument - simple version
   if pargs.arg[1]^<>eoa then alstrtofs('yes',pfuncret)
   else alstrtofs('no',pfuncret);
   end
else begin
   // Multiple arguments, loop version
   answer:= true;
   n:= 1;
   with pargs do begin
      while answer and (n<=narg) do begin
         if arg[n]^=eoa then answer:= false;
         n:= n+1;
         end;
      end;

   if answer then alstrtofs('yes',pfuncret)
   else alstrtofs('no',pfuncret);
   end;

aldispose(pargs,mem);

end; (*alis*)


procedure alEmpty( var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <empty str>, <empty str,str,str...>:
   Return yes if all str are empty.
   Examples: <empty 1> => No, <is 1,> => No, <empty ,,> => Yes.
*)

var
mem: alevalmem;
answer: boolean;
n: integer;

begin (*alEmpty*)

alevaluate(pargs,pstateenv,mem,[1..pargs.narg]);

if pargs.narg=1 then begin
   // Single argument - simple version
   if pargs.arg[1]^=eoa then alstrtofs('yes',pfuncret)
   else alstrtofs('no',pfuncret);
   end
else begin
   // Multiple arguments, loop version
   answer:= true;
   n:= 1;
   with pargs do begin
      while answer and (n<=narg) do begin
         if arg[n]^<>eoa then answer:= false;
         n:= n+1;
         end;
      end;

   if answer then alstrtofs('yes',pfuncret)
   else alstrtofs('no',pfuncret);
   end;

aldispose(pargs,mem);

end; (*alEmpty*)



procedure aleq( var pargs: xargblock;
                  var pstateenv: xstateenv;
                  pfuncret: fsptr );
(* <eq str1,str2>:
   Compare str1 and str2 in the same way as <ifeq ...>.
   <...> can be used in str2, for example <integer> or <alt ...>.
   Normally used for string comparison in algebraic conditions.
   Example:
   <if $a=1 & <eq $s,abc> & $b=2,...>
*)

const smallbufsize = 100;

var
mem: alevalmem;
equal: BOOLEAN;
slen: alint16; a1,a2: fsptr;
smallbuf: array[1..smallbufsize] of char;
bufp,ip: ioinptr;
blen: alint16;
saveinp: ioinptr;
optsave: char;
xparoffset0,nxpar0: integer;
savecompare: boolean;
savebitsmode: boolean;
saveshiftbits: integer;

begin (*aleq*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

   (* Use current regard-cr-as-blank-for-files -option even if current input is console. *)
   optsave:= xoptcr;
   xoptcr:= xoptcrfile;
   if xoptcr=char(13) then xoptcr2:= char(10) else xoptcr2:= ' ';

   (* First try with a small buffer. *)
   slen:= 0; a1:= pargs.arg[1];
   bufp:= @smallbuf[1];
   ip:= bufp;
   while not ((a1^=eoa) or (slen=smallbufsize-1)) do begin
      ip^:= a1^;
      fsforward(a1);
      ip:= ioinptr(ioint32(ip)+1);
      slen:= slen+1;
      end;

   if a1^<>eoa then begin
      (* Smallbuf was too small. Use getmem to allocate a sufficient buffer. *)
      a1:= pargs.arg[1];
      a2:= a1;
      fsforwendch(a2,eoa);
      slen:= fsdistance(a1,a2);
      getmem(bufp,slen+1);
      ip:= bufp;
      blen:= 0;

      while not (a1^=eoa) do begin
         ip^:= a1^;
         fsforward(a1);
         ip:= ioinptr(ioint32(ip)+1);
         blen:= blen+1;
         end;
      if blen<>slen then xProgramError('X: program error - blen<>slen.');
      if a1<>a2 then xProgramError('X: program error - a1<>a2.');
      end;

   (* At this stage: bufp points at evaluated arg1. ip points after
      last character in bufp. *)
   ip^:= char(eofs);

   saveinp:= pstateenv.cinp;
   pstateenv.cinp:= bufp;
   savecompare:= pstateenv.compare;
   pstateenv.compare:= true;
   savebitsmode:= bitsmode;
   saveshiftbits:= shiftbits;
   bitsmode:= false;

   with pstateenv.pars do begin
      (* Push current <xp n>, and reset for additional: *)
      xparoffset0:= xparoffset;
      nxpar0:= nxpar;
      end;
   (* I cannot see the point in setting <xp n> parameters here, since there
      is no context for them to be used (they are deleted directly after finding
      the result (yes or no)/BFn 2020-01-22. *)
   xcompare(pargs.arg[2],eoa,FALSE,(*false better?*)true,pstateenv,equal);
   if equal and (pstateenv.cinp<>ip) then
      equal:= false;
   pstateenv.cinp:= saveinp;
   pstateenv.compare:= savecompare;
   bitsmode:= savebitsmode;
   shiftbits:= saveshiftbits;

   (* Restore allocated buffer if any. *)
   if bufp<>@smallbuf[1] then Freemem(bufp);
   (* Restore xoptcr *)
   xoptcr:= optsave;
   if xoptcr=char(13) then xoptcr2:= char(10) else xoptcr2:= ' ';

   with pstateenv.pars do begin
      xparoffset:= xparoffset0;
      nxpar:= nxpar0;
      end;
   if equal then alstrtofs('yes',pfuncret)
   else alstrtofs('no',pfuncret);
   end;

aldispose(pargs,mem);

end; (*aleq*)


procedure alchar( var pargs: xargblock;
             var pstateenv: xstateenv; pfuncret: fsptr);
(* <char int>:
   return a character with a certain ascii code
   Example: <char 48> returns "0".
*)
var
mem: alevalmem;
i: integer;

begin (*alchar*)

alevaluate(pargs,pstateenv,mem,[1]);

i:= fsposint(pargs.arg[1]);
if (i<0)  or (i>252) then
   xScriptError('X: An integer between 0 and 252 was expected (253..255 are reserved).')
else fspshend(pfuncret,char(i));

aldispose(pargs,mem);

end; (*alchar*)

(* MACROHANTERING *)
(*----------------*)

(* By using alreset error and alerror, xload can check if any errors were
   discovered during evaluation of <...>-calls. *)
procedure alreseterror; begin errorsfound:= 0; end;
function alerror: boolean; begin alerror := (errorsfound>0); end;
procedure alindexDelete(pnr: integer); forward;


type defnametype = (defdef,deffunction,defpreldef);

// (new: store state refs, stay 2 bytes in argl)
procedure aldef( var pargs: xargblock; pdefname: defnametype;
                 var pstateenv: xstateenv );
(* <function name,...,[,minargs[,maxargs]]>:
   Create a function that can be called as <name ...>

   The number of arguments is either automatic (= highest $n reference used in
   the code (...), or specified with minargs and maxargs.

   The code (...) consists of text, <...>-expressions and $n references
   (n is an argument number).

   During evaluation, $n in the code will be replaced by the corresponding
   argument in the call, without evaluation.
   This means that an X function works similar to a macro.

   For example. <function do123,$1<sleep 1000>$1<sleep 1000>$1>> when
   called as <do123 <time>>, will be converted to
      "<time><sleep 1000><time><sleep 1000><time>" before being evaluated.
*)
(* <def name,...,[,minargs[,maxargs]]>:
   Another name for <function name,...,[,minargs[,maxargs]]>.

   The implementation is exaclty same as <function ...>.
   The reason for allowing an alternate name is to be able to express that the
   code is more of a definition than an executable function.
*)

(* <prelDef name,...,[,minargs[,maxargs]]>:
   Preliminary definition of a function name. It can be redefined later.
   <preldef ...> is often used to create recursive functions. If a function
   name is preliminary defined, it can be used to call it self in the real
   definition further down.

   Example:
   The following function is very convenient when you want to define a pattern
   that is a list of another pattern:

   <preldef list>
   <def list,<alt $1$2<list $1,$2>,$1>>

   In X, a function name must always be defined before it is used.
   Preldef allows the name "list" to be preliminary defined, so that the function
   <list ...> can call itself.
*)


(* pDefname:
   alDef can be called from <def ...>, <function ...> or <preldef ...>
   Parameter pDefname tells where it is called from:

   defdef: It is called from <def name,str[,minargs[,maxargs]]>.
   deffunction: It is called from <function name,str[,minargs[,maxargs]]>.
   defpreldef: It is called from <preldef name,str[,minargs[,maxargs]]>.
      Preliminary define macro.
      New <def ...>, <function ...> or <preldef ...> with the same name
      is still allowed.

   The macro will be local to the current state (xstate) if the current
   state is <> 0.
*)
var
funcnr,filenr: alint16;
i:		alint16;
a1: fsptr;
instr,mtab: fsptr;
arg2len: alint16;
mem: alevalmem;
cnt: alint16;
ch: CHAR;
pncall: integer; (* >0 Contains <p n> or <pdec n> -calls. *)
cleanupcall: boolean; (* Contains call(s) to <cleanup>. *)
fnam: string;
error: boolean;
state: alint16;
parmin,parmax,maxusedpar,newmup: alint16;
newparmin, newparmax: alint16;
nextin: fsptr;
instate: (normal,stanread,nr,nr0,nr1,lvlev,nargs,argl1OrRek,eoarg,setpop,
   cj);
fnr: integer;
cjcnt: integer;
arg1: string;
tempptr: fsptr;
preldef: boolean;
wherenr: integer;
l2ptr: fsptr;
cjkind: integer;
extraCond: xExtraConditionType;

procedure calculateArgumentNumber;

begin
   parmac[funcNr]:= True;
   (* calculate argument number. *)
   newmup:= 0;
   tempptr:= instr;
   while (tempptr^ in ['0'..'9']) and (newmup<=xmaxnarg) do begin
      newmup:= newmup*10 + alint16(tempptr^)-alint16('0');
      fsforward(tempptr);
      end;
   if newmup>xmaxnarg then begin
      xScriptError('X: A parameter ($...) between $1 and $' +
         inttostr(xmaxnarg)+ ' was expected but $' + inttostr(newmup) + ' was found.');
      xsetcompileerror;
      newmup:= 0;
      end;

   if newmup>maxusedpar then maxusedpar:= newmup;
end;(* calculateArgumentNumber *)


begin (*aldef*)
(****)if alflagga('D') then with pargs do begin
(****)  if rekursiv[2] then iodebugmess('->aldef: rekursiv[2]=true')
(****)  else iodebugmess('->aldef: rekursiv[2]=false');
(****)  end;

alevaluate(pargs,pstateenv,mem,[1,5]);

(* fnam is for error message only. *)
case pdefname of
   defdef: fnam:= 'def';
   deffunction: fnam:= 'function';
   defpreldef: fnam:= 'preldef';
   end;

preldef:= pdefname=defpreldef;

error:= false;
parmin:= 0; parmax:= 0; // (to please compiler)
cleanupcall:= false; pncall:= 0; // -"-


with pargs do begin

   arg1:= alfstostr(arg[1],eoa);

   a1:= arg[1];

   if alflagga('D') then
      iodebugmess('aldef("'+arg1+'"): funcNr='+inttostr(funcNr));

   (* Get parmin and parmax from arg 3-4 if specified. *)
   parmin:= 0;
   parmax:= xmaxnarg;
   if narg>2 then begin
      parmin:= fsposint(arg[3]);
      if parmin<0 then begin
         error:= true;
         xScriptError('X: A number was expected as arg 3, but  "'+
            // (new:)
            alShowArg(arg[3],rekursiv[3])+'"  was found.');
            // (old:) alfstostr100(arg[3],eoa)+'".');
         errorsfound:= errorsfound+1;
         xsetcompileerror;
         end;
      end;

   if narg>3 then begin
      parmax:= fsposint(arg[4]);
      if parmax<0 then begin
         error:= true;
         xScriptError('X: A number was expected as arg 4, but "'+
            alShowArg(arg[4],rekursiv[4])+'"  was found.');
         errorsfound:= errorsfound+1;
         xsetcompileerror;
         end;
      end;

   // Optional extra condition
   extraCond:= xNoCond;
   if narg>4 then begin
      if alfstostrlc(arg[5],eoa)='oddnarg' then
         extraCond:= xOddNarg
      else if alfstostrlc(arg[5],eoa)='evennarg' then
         extraCond:= xEvenNarg
      else if alfstostrlc(arg[5],eoa)='nocond' then
         extraCond:= xNoCond
      else begin
         error:= true;
         xScriptError('X: "oddnarg", "evennarg" or "nocond" expected as arg 5, found "'+
            alfstostr100(arg[5],eoa)+'".');
         errorsfound:= errorsfound+1;
         xsetcompileerror;
         end;
      end;

   pncall:= 0;
   cleanupcall:= false;

   if not error then begin
      xDefineFunction(arg1,parmin,parmax,extraCond,preldef,funcnr,error);
      if error then begin
         errorsfound:= errorsfound+1;
         xsetcompileerror;
         end;
      end;

   if not error then begin

      if mactab[funcNr]<>NIL then begin
         if integer(mactab[funcNr])<=alIndexMaxNr then begin
            xProgramError('aldef: mactab entries for tables were expected to be '+
               'cleared, but mactab['+inttostr(funcnr)+'] was found to contain '+
               'one ('+inttostr(integer(mactab[funcNr]))+')(1).');
            (* (old:) *) alindexdelete(integer(mactab[funcnr]));
            mactab[funcnr]:= nil;
            end
         else
            fsdispose(mactab[funcNr]);
         end;
      fsnew(mactab[funcNr]);
      parmac[funcNr]:= False;
      maxusedpar:= 0;
      containscleanup[funcNr]:= False;

      if narg<2 then begin
         // No argument = fill with empty string.
         mtab:= mactab[funcNr];
         fspshend(mtab,eoa);

         recursivemac[funcNr]:= false
         end

      else if rekursiv[2] then begin

         instr:= arg[2]; mtab:= mactab[funcNr];
         (* Find out length of argument. *)
         (* Note - we are using the fact that we know that
            arg[2] points into the compiled call, and that
            in a compiled call, every argument is preceded
            by two bytes defining its length (see xcompilestring). *)
         fsback(instr);

         l2ptr:= instr;
         fsback(instr);
         arg2len:= integer(instr^)*250+integer(l2ptr^);
         instr:= arg[2];

         (* Copy arg + eoa-mark to mactab[funcNr]. *)
         cnt:= 0;
         instate:= normal;
         ch:= instr^; fsforward(instr);

         while not (cnt>=arg2len+1) do begin

            (* This state machine is to prevent function numbers, narg,
               or arglens to be mistaken for '$'-signs. There is still a risk
               that ra1, ra2 ... (see xcompilestring) is mistaken for '$'-sign
               but then the definition must contain a function call with at least
               28 parameters, where parameter 28 is recursive. *)

            (* Instate sometimes tells what has been read, examples: stanread, nr,
               argl1, eoarg. Othertimes, it tells what is expected, e.g.
               nr0, nr1, lvlev.. *)
            case instate of

            stanRead: begin
               fnr:= integer(ch);
               if fnr=0 then instate:= nr0
               else if (fnr=alSetFuncnr)  or (fnr=alAppendFuncnr) or (fnr=alPopFuncnr) or
                  (fnr=alForeachFuncnr) or (fnr=alUpdateFuncnr) or (fnr=alIndexesFuncnr) then
                  instate:= setpop (* set, append, update, pop and foreach uses binary arg1. *)
               else if (fnr=alCfuncnr) then begin
                  (* Prepare to save a pointer to args in stateRefTab, in order to
                     resolve it when the end of the file is reached. *)
                  instate:= cj; // <c/j/c_lateevaluation ...>
                  cjkind:= 1;
                  cjcnt:= 4;
                  end
               else if (fnr=alJfuncnr) then begin
                  instate:= cj;
                  cjkind:= 2;
                  cjcnt:= 4;
                  end
               else if (fnr=alC_lateevaluationfuncnr) then begin
                  instate:= cj;
                  cjkind:= 3;
                  cjcnt:= 4;
                  end
               else instate:= nr;
               end;
            nr0: begin
               fnr:= integer(ch)*250;
               instate:= nr1;
               end;
            nr1: begin
               fnr:= fnr + integer(ch);
               if fnr>xmaxfuncnr then instate:= lvlev
               else instate:= nr
               end;
            setpop: begin
               (* Wait for eoa of binary arg. *)
               if ch=char(eoa) then instate:= eoarg;
               end;
            lvlev: instate:= nr;
            nr:begin
               (* nr has been read. ch is number of arguments. Jump directly to
                  normal if there are no args. *)
               if ch=char(0) then instate:= normal
               else instate:= nargs
               end;
            nargs: instate:= argl1OrRek;
            argl1orRek: begin
               // arglen byte 1 has been read. ch is byte 2,
               // or first byte in list or recursive arguments have been read.
               if ch=char(eoa) then
                  (* Previous byte was probably 0 (end of list of recursive args),
                     which ended a function call at the end of an argument. *)
                  instate:= eoarg
               else if ch=char(xstan) then
                  (* Previous byte was probably 0 (end of list of recursive args),
                     which ended a function call followed by another function call. *)
                  instate:= stanread

               else begin
                  instate:= normal;
                  // Moved from below (see "2020-04-10").
                  if (ch='$') and (instr^ in ['1'..'9']) then calculateArgumentNumber;
                  end;
               end;
            cj: begin
               cjcnt:= cjcnt-1;
               if cjcnt=0 then begin
                  xAddFuncStateRef(mtab,cjkind);
                  instate:= normal;
                  end;
               if ch=char(eoa) then instate:= eoarg;
               end;
            normal: begin
               if ch=char(eoa) then instate:= eoarg
               else if ch=char(xstan) then begin
                  instate:= stanRead;
                  (* <P n>-calls must be evaluated directly: *)
                  if instr^=char(alPfuncnr) then pncall:=alPfuncnr
                  else if instr^=char(alPdecfuncnr) then pncall:=alPdecfuncnr
                  else if instr^=char(cleanupfuncnr) then cleanupcall:= true
                  else if instr^=char(loadfuncnr) then begin
                     nextin:= instr;
                     fsforward(nextin);
                     if nextin^=char(0) then
                        (* <load> with no parameters. *)
                        cleanupcall:= true;
                     end
                  end

               // Moved from below (see "2020-04-10").
               else if (ch='$') and (instr^ in ['1'..'9']) then calculateArgumentNumber;
               end;
            eoarg:
               if ch<>char(eoa) then instate:= argl1OrRek;

            else begin
               xprogramerror('aldef: Unexpected state: ' + inttostr(integer(instate)) + '.');
               end;
            end; (* (case) *)

            fspshend(mtab,ch);

            (* BFn 2020-04-10: Why is this here and not under instate=normal?
               If <calc ...> starts with a number, and la = 36 (=ascii code '$') then
               the the below code will be triggered although there is no arg reference
               (the '$' is from La and not in the argument of <calc ...>. The following
               X-code gave an erroneous error message (argnr too high - $645):
               <function convertMps,
               -<var $deltaSpeed>
               -<calc 645 + (12.1 - 0.056 *$deltaSpeed) *$deltaSpeed>
               ->.
               Therefore this code is moved to under normal. Hope it works.

            if (instate=normal) and (ch='$') and (instr^ in ['1'..'9']) then begin
               parmac[funcNr]:= True;
               ( * calculate argument number. * )
               newmup:= 0;
               tempptr:= instr;
               while (tempptr^ in ['0'..'9']) and (newmup<=xmaxnarg) do begin
                  newmup:= newmup*10 + alint16(tempptr^)-alint16('0');
                  fsforward(tempptr);
                  end;
               if newmup>xmaxnarg then begin
                  xScriptError('X: A parameter ($...) between $1 and $' +
                     inttostr(xmaxnarg)+ ' was expected but $' + inttostr(newmup) + ' was found.');
                  xsetcompileerror;
                  newmup:= 0;
                  end;

               if newmup>maxusedpar then maxusedpar:= newmup;
               end;

               BFn 2020-06-08: This also has to be done when going from state argl1orRek
                  to normal (see state argl1orRek above).
            *)

            ch:= instr^;
            fsforward(instr);
            cnt:= cnt+1;

            end; // (while not(cnt>= ...)

         fsback(mtab);
         if not (mtab^=eoa) then
            xProgramError('X: Error - cannot find eoa.');
         recursivemac[funcNr]:= true;
         if pncall>0 then begin
            if pncall=alPdecfuncnr then
               xScriptError('X: Warning - arg contains <pdec n>-call, is evaluated directly.')
            else
               xScriptError('X: Warning - arg contains <p n>-call, is evaluated directly.');
            (* Evaluate directly *)
            fsrewrite(mactab[funcNr]); mtab:= mactab[funcNr];
            xevaluate(arg[2],eoa,xevalnormal,pstateenv,mtab);
            fspshend(mtab,eoa);
            recursivemac[funcNr]:= false;
            end;
         if cleanupcall then containscleanup[funcNr]:= True;
         end

      else begin

         (* not rekursiv[2] *)

         instr:= arg[2]; mtab:= mactab[funcNr];
         while not ((instr^=eoa) or (instr^=eofs)) do begin
            ch:= instr^;
            fspshend(mtab,instr^);
            fsforward(instr);
            if (ch='$') and (instr^ in ['1'..'9']) then begin
               parmac[funcNr]:= True;
               newmup:= 0;
               while instr^ in ['0'..'9'] do begin
                  newmup:= newmup*10 + alint16(instr^)-alint16('0');
                  fspshend(mtab,instr^);
                  fsforward(instr);
                  end;
               if newmup>maxusedpar then maxusedpar:= newmup;
               end;
            end;
         fspshend(mtab,eoa);

         recursivemac[funcNr]:= false;
         end;

      (* Redefine parmin and parmax according to used parameters if it was not
         specified in <def ...> . *)
      newparmin:= parmin;
      newparmax:= parmax;
      if (narg<3) and not preldef then newparmin:= maxusedpar;
      if (narg<4) and not preldef then newparmax:= maxusedpar;

      if (newparmin<>parmin) or (newparmax<>parmax) then
         xDefineParMinMax(funcnr,newparmin,newparmax);
         // (old:) xdefine(arg1,funcNr,newparmin,newparmax,false,preldef,error);
      end; (* not error *)
   end; (*with*)

aldispose(pargs,mem);

end; (*aldef*)


const
locvaroffsetstacksize = 100;
var
locVarOffsetStack: array[1..locVarOffsetStackSize] of integer; (* Used to remember
   offsets from the calling functions, which is necesary when evaluating local
   variable references that entered the current function in a parameter and
   thus belongs to a scope of a calling funtion. For example: See
   xargblock. LocVarEvalLevel is used to index the stack. *)

locVarOffset: integer = 0;(* How many local variables have been stacked
   in higher function levels. Example: if <function a,...> has 2 local variables
   and <function b,...> has 3, and <a ...> calls <b ...> which calls <c ...> then
   locVarOffset will be 5 in function c, 2 in function b and 0 in function a.
   <var ...,initvalue>: use mactab[xmaxfuncnr+locVarOffset+locVarEvalCount]
   $...; use mactab[n+locVarOffset] *)

locVarEvalCount: integer = 0; (* Counts local variables in currently evaluated
   function. Example: if <b ...> has 3 local variables, and local variable
   2 has been initialized but not 3, then locVarEvalCount = 2.
   locVarEvalCount is used to identify local variables that shall be initialised
   (see locVarOffset), and to step up locVarOffset when a function with local
   variables is calling another function (which may also have local variables). *)

locVarEvalLevel: integer = 0; (* Used by alvar do see if it is called during evaluation
   of a function (local variable) or on top level (normal variable). 0= not in
   function evaluation: alvar shall define a static variable. >0= in function
   evaluation: alvar shall initialise an already defined local variable. *)

procedure alInitLocVarParameters;
(* This procedure is available in case exception handling would disturb
   the state of these variables. *)
begin
locVarOffset:= 0;
locVarEvalCount:= 0;
locVarEvalLevel:= 0;
end;

(* Tables *)
(**********)

var
(* For each index: contains the strings in order of creation. *)
stringtab: array [0..alIndexMaxNr] of Tstringlist;
stringtabmac: array [0..alIndexMaxNr] of integer;
   (* Points back to the variable number in mactab of the corresponding
      table variable. Used to erase this entry in mactab when the
      table is erased, so that no false references are left behind. *)
delimtab1: array [0..alIndexMaxNr] of string;
delimtab2: array [0..alIndexMaxNr] of string;

(* 0 is default index number. 1..max can be selected with <select ...> *)
indexnr:integer = 0;
firstfreeindexnr: integer =11; (* First 10 indexes reserved for old syntax until
   all old scripts are rewritten. *)
lastcreatedindexnr: integer = 0;

// Separate indexes for help strings:
helpTabIndexNr: integer = 0;

// String for helpFunc
helpFunctionsStr: string = '';

(* This is an attempt to move examples.txt too x.exe. It is tentative and not
   connected.
   <examples ...> is also not good documentation. Needs to be improved. *)
examplesTabIndexNr: integer = 0;



procedure alindexReset;
(* Delete all indexes. *)
var ixnr,mac: integer;
begin
for ixnr:= 1 to lastcreatedindexnr do begin
   if stringtab[ixnr]<>nil then stringtab[ixnr].Destroy;
   // Clear reference in mactab
   mac:= stringtabmac[ixnr];
   // mac 0 is used for helpText (see alhelp)
   if mac<>0 then begin
      if mactab[mac]=fsptr(ixnr) then mactab[mac]:= nil
      else xProgramError('alIndexReset: mactab['+inttostr(mac)+
         '] was expected to point at table index '+inttostr(ixnr)+
         ' but it was found to contain '+inttostr(integer(mactab[mac]))+
         ' instead.');
      end;
   stringtab[ixnr]:= nil;
   stringtabmac[ixnr]:= 0;
   delimtab1[ixnr]:= '';
   delimtab2[ixnr]:= '';
   end;
helpTabIndexNr:= 0;
indexnr:= 0;
firstfreeindexnr:= 11;(* First 10 indexes reserved for old syntax until
   all old scripts are rewritten. *)
lastcreatedindexnr:= 0;
end;

(* (Not used anymore except for old abnormal event:) *)
procedure alindexDelete(pnr: integer);
var mac: integer;
begin
xProgramError('alIndexDelete unexpectedly called.');
if stringtab[pnr]<>nil then begin
   stringtab[pnr].Destroy;
   // Clear reference in mactab
   mac:= stringtabmac[pnr];
   if mac<>0 then begin
      if mactab[mac]=fsptr(pnr) then mactab[mac]:= nil
      else xProgramError('alIndexDelete: mactab['+inttostr(mac)+
         '] was expected to point at table index '+inttostr(pnr)+
         ' but it was found to contain '+inttostr(integer(mactab[mac]))+
         ' instead.');
      end;
   stringtab[pnr]:= nil;
   stringtabmac[pnr]:= 0;
   delimtab1[pnr]:= '';
   delimtab2[pnr]:= '';
   if pnr<firstfreeindexnr then firstfreeindexnr:= pnr;
   end;
end;



procedure alindexdelim(pdelimnr: integer; pixnr: integer; pdelimstr: string);
begin
case pdelimnr of

   1: delimtab1[pixnr]:= pdelimstr;
   2: delimtab2[pixnr]:= pdelimstr;
   end;
end;(*alindexdelim*)


procedure alindexinit(pnr: integer; pvalue: fsptr; pendchar: char);
(* Erase index pnr then build it up again from pvalue.
   Example:
   pvalue =
   "1|1111|
   a|aaaa|"
   Initiates the index with two values: 1:1111 and 2:aaaa.
   Used by <var name[],...> and by <set $ix1,...>
*)
var ptr: fsptr; ix,value: string;
state: (s1,s2,s3,s4);
ch: char;
delim1,delim2: string;
delim1ch1,delim2ch1: char;
delim1len,delim2len: integer;
buffer: string;
delimix: integer;

begin
stringtab[pnr].Clear;
ptr:= pvalue;
ix:= '';
state:= s1;

delim1:= delimtab1[pnr];
if delim1='' then delim1:= ':';
delim2:= delimtab2[pnr];
if delim2='' then delim2:= '|';
delim1ch1:= delim1[1];
delim2ch1:= delim2[1];
delim1len:= length(delim1);
delim2len:= length(delim2);

   while ptr^<>pendchar do begin
   ch:= ptr^;
   fsforward(ptr);
   case state of
      s1: (* Reading index. *)
      if ch=delim1ch1 then begin
         if length(delim1)=1 then begin
            state:= s3;
            value:= '';
            end
         else begin
            buffer:= ch;
            state:= s2;
            delimix:= 1;
            end;
         end
      else ix:= ix + ch;

      s2: begin
         (* Reading delimiter 1 *)
         buffer:= buffer+ch;
         delimix:= delimix+1;
         if ch<>delim1[delimix] then begin
            // (fail)
            ix:= ix + buffer;
            state:= s1;
            end
         else if delimix=delim1len then begin
            // (success)
            value:= '';
            state:= s3;
            end
         else
            (* continue *);
         end;

      s3: begin
         (* Reading value. *)
         if ch=delim2ch1 then begin
            if delim2len=1 then begin
               (* Set value *)
               stringtab[pnr].Values[ix]:= value;
               state:= s1;
               ix:= '';
               end
            else begin
               buffer:= ch;
               state:= s4;
               delimix:= 1;
               end;
            end
         else
            value:= value + ch;
         end;(*s3*)

      s4: begin
         (* Reading delimiter 2 *)
         buffer:= buffer+ch;
         delimix:= delimix+1;
         if ch=delim2[delimix] then begin
            // OK so far, check if complete
            if delimix=delim2len then begin
               // (success)
               stringtab[pnr].Values[ix]:= value;
               state:= s1;
               ix:= '';
               end;
            end
         else begin
            // (fail - put back buffer in value)
            value:= value + buffer;
            state:= s3;
            end
         end;

      end; (*case*)
   end;(*while*)

if (state=s3) or (state=s4) then begin
   if state=s4 then value:= value+buffer;
   stringtab[pnr].Values[ix]:= value;
   state:= s1;
   ix:= '';
   end;

if (state<>s1) or (ix<>'') then xScriptError(
   '<var $name[],...> or <set $name,...> where name was created as name[]: '+
   'An index on format "(ix1)|(value1)|(cr)...(ixn)|(valuen)" was expected, but "' +
   alfstostr(pvalue,eoa) + '" was found.');

end;(*alindexinit*)


(* Version of alIndexInit using string instead of fsPtr.
   Used by alHelp. *)
procedure alindexinitStr(pnr: integer; pvalue: string);
(* Erase index pnr then build it up again from pvalue.
   Example:
   pvalue =
   "1|1111|
   a|aaaa|"
   Initiates the index with two values: 1:1111 and 2:aaaa.
   Used by <var name[],...> and by <set $ix1,...>
*)
var
ix,value: string;
state: (s1,s2,s3);
i: integer;
ch: char;
delim1,delim2,delim3: char;
size: integer;
buffer: string;
delimix: integer;

begin
stringtab[pnr].Clear;
ix:= '';
state:= s1;

// Between index and value
delim1:= ':';

// Between value and next item
delim2:= char(13);
delim3:= '|';

size:=length(pvalue);

for i:= 1 to size do begin

   ch:= pvalue[i];
   case state of
      s1: (* Reading index. *)
      if ch=delim1 then begin
         state:= s2;
         value:= '';
         end
      else ix:= ix + ch;

      s2: begin
         (* Reading value. *)
         (* Detect end of value = delim2 + delim3. *)
         if ch=delim2 then begin
            if i<size then begin
               if pvalue[i+1]=delim3 then state:= s3;
               end;
            end;
         if state=s2 then value:= value + ch;
         end;(*s2*)

      s3: begin
         (* We already know that the ch is delim3. *)
         if ch<>delim3 then xProgramError('alIndexInitStr: ch = "' + delim3 +
            '" was expected but "' + ch + '" was found.');
         (* Set value *)
         stringtab[pnr].Values[ix]:= value;
         state:= s1;
         ix:= '';
         end;(*s3*)

      end; (*case*)
   end;(*while*)

if state<>s1 then begin
   stringtab[pnr].Values[ix]:= value;
   state:= s1;
   ix:= '';
   end;

if (state<>s1) or (ix<>'') then xScriptError(
   '<help funcname>: '+
   'An index on format "(ix1)|(value1)|(cr)...(ixn)|(valuen)" was expected, but "' +
   pvalue + '" was found.');

end;(*alindexinitStr*)


function alIndexCreate(pmacnr: integer): integer;
(* Create an index. Used by <var name[]>. *)
var ixnr: integer;
found: boolean;

begin

ixnr:= 0;
if firstfreeindexnr>alIndexMaxNr then begin
   xScriptError('X(<index create>): X expected that '+inttostr(alIndexMaxNr)+
      ' indexes would be sufficient for a script, but this script requires at least '+
      inttostr(alIndexMaxNr+1)+ ' indexes.');
   end
else begin

   ixnr:= firstfreeindexnr;
   stringtab[firstfreeIndexnr]:= Tstringlist.create;
   stringtabmac[firstfreeindexnr]:= pmacnr;

   (* Index created at slot firstfreeindexnr. Update lastfreeindexnr
      unless it is already higher or equal to the newly created
      index. *)
   if lastcreatedindexnr<firstfreeindexnr then
      lastcreatedindexnr:= firstfreeindexnr;

   // Now find a new free index number
   found:= false;
   while (firstfreeindexnr<=alIndexMaxNr) and not found do begin
      if stringtab[firstfreeindexnr]=nil then found:= true
      else firstfreeindexnr:= firstfreeindexnr+1;
      end;
   end;

alindexcreate:= ixnr;

end;(*alindexcreate*)

procedure alIndexSet(pixnr: integer; pix,pvalue: string);
begin
   stringtab[pixnr].Values[pix]:= pvalue;
end;(*alindexset*)

procedure alIndexAppend(pixnr: integer; pix,pvalue: string);
begin
   stringtab[pixnr].Values[pix]:= stringtab[pixnr].Values[pix] + pvalue
end;(*alindexAppend*)

procedure alIndexAppendWithDelim(pixnr: integer; pix,pvalue,pdelim: string);
begin
   if stringtab[pixnr].Values[pix] = '' then
      stringtab[pixnr].Values[pix]:= stringtab[pixnr].Values[pix] + pvalue
   else
      stringtab[pixnr].Values[pix]:= stringtab[pixnr].Values[pix] + pDelim + pvalue;
end;(*alindexAppendWithDelim*)

(* Implementation of $(name) when name is an index, or <index getall> *)
procedure alIndexGetAll(pindexnr: integer;pdelim1,pdelim2: string;
   pfuncret: fsptr);
var
all,name,value: string;
i,count: integer;
begin
all:= '';
if pdelim1='' then pdelim1:= delimtab1[pindexnr];
if pdelim1='' then pdelim1:= ':';
if pdelim2='' then pdelim2:= delimtab2[pindexnr];
if pdelim2='' then pdelim2:= '|';
count:= 0;
for i:= 0 to stringtab[pindexnr].count-1 do begin
   name:= stringtab[pindexnr].names[i];
   value:= stringtab[pindexnr].values[name];
   // Print only entries which have a value
   if length(value)>0 then begin
      count:= count+1;
      if count>1 then all:= all + pdelim2 + name + pdelim1 + value
      else all:= all + name + pdelim1 + value;
      end;
   end;
alstrtofs(all,pfuncret);
end;(*alIndexGetall*)


(* Implementation of <indexes $(name)[,delim]>. *)
(* (new:) *)
procedure Indexes(pindexnr: integer; pdelim: string;
   pfuncret: fsptr);
var
all,name: string;
i: integer;
count: integer;
begin
all:= '';
count:= 0;
if pdelim='' then pdelim:= '|';
for i:= 0 to stringtab[pindexnr].count-1 do begin
   if stringtab[pindexnr].ValueFromIndex[i]<>'' then begin
      if count>0 then all:= all + pdelim;
      name:= stringtab[pindexnr].names[i];
      all:= all + name;
      count:= count+1;
      end;
   end;
alstrtofs(all,pfuncret);
end;(*Indexes*)

(* (old:) *)
procedure Indexes0(pindexnr: integer; pdelim: string;
   pfuncret: fsptr);
var
all,name: string;
i: integer;
begin
all:= '';
if pdelim='' then pdelim:= '|';
for i:= 0 to stringtab[pindexnr].count-1 do begin
   name:= stringtab[pindexnr].names[i];
   all:= all + name;
   if i<stringtab[pindexnr].count-1 then
      all:= all + pdelim;
   end;
alstrtofs(all,pfuncret);
end;(*Indexes0*)


procedure alIndexGet(pnr: integer; var pargs: xargblock; var pstateenv: xstateenv;
                 pfuncret: fsptr );
(* $(name)[ix] or $(name)[*], when name is an index. *)
var
mem: alevalmem;

begin (*alIndexGet*)

alevaluate(pargs,pstateenv,mem,[1]);
with pargs do begin
   if narg=0 then begin
      (* Return whole index. *)
      alIndexGetall(pnr,'','',pfuncret);
      end
   else begin
      (* return $(name)[(arg2)]. *)
      alstrtofs(stringtab[pnr].values[alfstostr(arg[1],eoa)],pfuncret);
      end;
   end; (*with*)

aldispose(pargs,mem);

end; (*alIndexGet*)

(* End table *)
(*************)


var
loadLocVarEvalLevel: integer = 0; (* This variable became needed to allow <load ...>
   from within a function. alVar distinguishes between normal and local variables
   by checking if locVarEvalLevel is higher than this value or not.
   It is maintained by alLoad and used by alVar. *)


procedure alvar( var pargs: xargblock; var pstateenv: xstateenv );
(* <var $varname[,initvalue][...]>:
   Define a variable or a table.

   <var $varname[,initvalue]...>
   Variables can be defined at top level in an x-file, but also
   locally in functions and states.

   Local variables.
   Local variables in functions are created dynamically and lose their values
   after return. If a function calls itself,the local variables will be created
   as a new set that is independent of the first call (local variables can be
   used for recursive function calls).
   Local variables in states are resident. They are only created once and
   never deleted (local variables in states cannot be used for recursive calls
   between states). Local variables in states, being resident, can be accessesd
   from outside the states with dot-notation ($statename.variablename).

   Tables.
   <var $varname[][,initvalue][,delim1][,delim2]>:
   Define a table that can be indexed with any string. Example:
   <var $tab1[]>
   <set $tab1[abc],def>
   <set $tab1[123],456>
   <wcons $tab1[abc], $tab1[123]> - Prints "def, 456".

   A table can be accessed by index but also as a whole. Example.
   <wcons $tab1> - Prints the whole table as "abc:def|123:456"
   <set $tab1,aaa:bbb|yyy:zzz> - Sets a whole table.

   When accessing a table as a whole, a delimeter ":"is inserted between index
   and value, and an "|" between the value and the next index. Other separators
   can be chosen as arg3 and arg4 when the table is created. Example:
   <var $tab2,,/,
   >
   <set $tab2[111],222>
   <set $tab2[222],333>
   <wcons $tab2> - Prints the table as
   "111/222
   222/333"
*)
(* The variable will be local to the current state (xstate) if the current
   state is <> 0.

   If the variable is local to a function (locVarEvalLevel)>0), then it was
   already defined temporarily during compilation and shall now only be initialised.
*)

var
varnr: alint16;
mtab: fsptr;
mem: alevalmem;
error: boolean;
state: alint16;
a1: fsptr;
i: integer;
arg1,arg2: string;
index: boolean;

begin (*alvar*)

alevaluate(pargs,pstateenv,mem,[1..4]);
error:= false;

with pargs do if locVarEvalLevel>loadLocVarEvalLevel then begin

   locVarEvalCount:= locVarEvalCount+1;
   varnr:= xmaxfuncnr+locVarOffset+locVarEvalCount;
   if mactab[varnr]=nil then fsnew(mactab[varnr]);
   fsrewrite(mactab[varnr]);
   mtab:= mactab[varnr];
   if narg>1 then
      (* Initialize variable. *)
      fscopy(arg[2],mtab,eoa);
   fspshend(mtab,eoa);
   end

else begin
   // normal <var ...> declaration
   varnr:= 0;
   a1:= arg[1];
   // $ before name in <var $name...> is mandatory
   if a1^='$' then fsforward(a1);
   arg1:= alfstostr(a1,eoa);
   if narg>1 then arg2:= ',...' else arg2:= '';

   if arg[1]^<>'$' then begin
      xcompileError2(
         'X (<var '+arg1+arg2+'>):'+
         '"$" was expected before variable name ('+arg1+') but not found.');
      error:= true;
      end
   else

      (* Define variable. *)
      xDefineNormalVariable(arg1,varnr,index);

   if index then begin
      (* <var $name[]> *)
      mactab[varnr]:= fsptr(alindexcreate(varnr));
      if narg>=3 then alindexdelim(1,integer(mactab[varnr]),alfstostr(arg[3],eoa));
      if narg>=4 then alindexdelim(2,integer(mactab[varnr]),alfstostr(arg[4],eoa));
      if narg>1 then alindexinit(integer(mactab[varnr]),arg[2],eoa);
      end

   else begin

      if mactab[varnr]<>NIL then begin
         if integer(mactab[varnr])<=alIndexMaxNr then begin
            xProgramError('aldef: mactab entries for tables were expected to be '+
               'cleared, but mactab['+inttostr(varnr)+'] was found to contain '+
               'one ('+inttostr(integer(mactab[varNr]))+')(2).');
            (* (old:) *) alIndexDelete(integer(mactab[varnr]));
            mactab[varnr]:= nil;
            end
         else
            fsdispose(mactab[varnr]);
         end;
      fsnew(mactab[varnr]);
      parmac[varnr]:= False;
      containscleanup[varnr]:= False;
      mtab:= mactab[varnr];
      if narg>1 then
         (* Initialize variable. *)
         fscopy(arg[2],mtab,eoa);
      fspshend(mtab,eoa);
      end; (* not error *)
   end; (* with *)

aldispose(pargs,mem);

end; (*alvar*)


procedure alset( var pargs: xargblock; var pstateenv: xstateenv; pAppend: boolean );
(* <set $varname,str>:
   evaluate str, then set variable to that.

   <set $varname[index],str>:
   Evaluate index and str, then set table[index] to str.
   $varname must be a table (created with <var $varname[]...>).

   Index cannot contain the character '='. This is an inherent
   characteristic of TStrings.values in Free Pascal.
*)
(* <append $varname,str[,delimeter]>:
   Add str to the end of variable $varname.
   If delimiter is specified, insert it between the
      existing contents and str, but not if the existing contents
      is empty.

   <append $varname[index],str[,delimeter]>:
   Same function but for a table entry.
*)

(* Implementation:
   <set $binnr,str> - evaluate str, then set macro.
   <append $binnr,str>
   <append $binnr,str,delimeter> - Insert delimiter between the
      existing contents and str, but not if the existing contents
      is empty.
   <set $binnr,index,str> - if $binnr is a table:
      evaluate index and str, then set macro. *)

var
nr: alint16;
mtab: fsptr;
mem: alevalmem;
a1ptr: fsptr;
lvnestlevel: integer;
ptr: fsptr;

begin (*alset*)
(****)if alflagga('D') then with pargs do begin
(****)  if rekursiv[2] then iodebugmess('->alset: rekursiv[2]=true')
(****)  else iodebugmess('->alset: rekursiv[2]=false');
(****)  end;

alevaluate(pargs,pstateenv,mem,[2,3]);

with pargs do begin

   a1ptr:= arg[1];
   nr:= ord(a1ptr^);
   lvnestlevel:= 0;
   fsforward(a1ptr);
   if (nr=0) and (a1ptr^<>eoa) then begin
      nr:= ord(a1ptr^);
      fsforward(a1ptr);
      nr:= nr*250 + ord(a1ptr^);
      fsforward(a1ptr);
      if nr>xmaxfuncnr then begin
         lvnestlevel:= integer(a1ptr^);
         fsforward(a1ptr);
         end;
      end;

   if nr=0 then xProgramError('X(alset): Program error - nr>0 was expected.')
   else if a1ptr^<>eoa then
      xProgramError('X(alset): Program error - end of argument 1 was expected.')
   else begin
   // if alflagga('D') then iodebugmess('alset(nr='+inttostr(nr)+').');

      // Local variable? Then add offset for outer level local variables.
      if nr>xmaxfuncnr then begin
         if lvnestlevel>0 then
            nr:= nr+locVarOffsetStack[lvnestlevel]
         else nr:= nr+locVarOffset;

         if pappend then begin
            // Remove eoa
            ptr:= mactab[nr];
            fsforwend(ptr);
            fsback(ptr);
            fsdelrest(ptr);
            if narg>2 then begin
               // Insert delimeter if current contents is not empty
               if ptr<>mactab[nr] then fscopy(arg[3],mactab[nr],eoa);
               end;
            end
         else fsrewrite(mactab[nr]);
         fscopy(arg[2],mactab[nr],eoa);
         mtab:= mactab[nr];
         fspshend(mtab,eoa);
         end
      else if integer(mactab[nr])<=alIndexMaxNr then begin
         //$binnr is a table
         if narg=2 then alindexinit(integer(mactab[nr]),arg[2],eoa)
         else begin
            if arg[2]^=eoa then
               // There must be an index (empty string is not considered one)
               xScriptError('An index was expected but it was empty.')
            else if pAppend then begin
               (* <append $arr,ind,value[,sepstr]>. *)
               if narg=4 then
                  alIndexAppendWithDelim(integer(mactab[nr]),alfstostr(arg[2],eoa),
                     alfstostr(arg[3],eoa),alfstostr(arg[4],eoa))
               else alIndexAppend(integer(mactab[nr]),alfstostr(arg[2],eoa),
                  alfstostr(arg[3],eoa));
               end
            else
               (* <set $arr,ind,value>. *)
               alIndexSet(integer(mactab[nr]),alfstostr(arg[2],eoa),
                  alfstostr(arg[3],eoa));
            end;
         end
      else if (narg>2) and not pAppend then
         // <set call with Normal variable but narg=3.
         xScriptError('Two arguments were expected but three were found.')
      else begin

         // Normal variable
         if pappend then begin
            // Remove eoa
            ptr:= mactab[nr];
            fsforwend(ptr);
            fsback(ptr);
            fsdelrest(ptr);
            if narg>2 then begin
               // Insert delimeter if current contents is not empty
               if ptr<>mactab[nr] then fscopy(arg[3],mactab[nr],eoa);
               end;
            end
         else fsrewrite(mactab[nr]);

         fscopy(arg[2],mactab[nr],eoa);
         mtab:= mactab[nr];
         fspshend(mtab,eoa);
         recursivemac[nr]:= false;
         parmac[nr]:= False;
         containscleanup[nr]:= false;
         end;
      end;
    end; (* with *)

aldispose(pargs,mem);

end; (*alset*)


(* (modelled from alset:) *)
procedure alPack( var pargs: xargblock; var pstateenv: xstateenv);
(* <pack $str,delim,value1,value2, ...>:
   Pack a number of values into a single variable.
   Example:
   <pack $tab[2], ,$var1,$var2,$var3,$var4,$var5> =
   <set $tab[2],$var1 $var2 $var3 $var4 $var5>

   Can be used to save context data before switching to another context
   that uses the same script.
*)

var
nr: alint16;
mtab: fsptr;
mem: alevalmem;
a1ptr: fsptr;
lvnestlevel: integer;
n: integer;

begin (*alPack*)

alevaluate(pargs,pstateenv,mem,[2..pargs.narg]);

with pargs do begin

   a1ptr:= arg[1];
   nr:= ord(a1ptr^);
   lvnestlevel:= 0;
   fsforward(a1ptr);
   if (nr=0) and (a1ptr^<>eoa) then begin
      nr:= ord(a1ptr^);
      fsforward(a1ptr);
      nr:= nr*250 + ord(a1ptr^);
      fsforward(a1ptr);
      if nr>xmaxfuncnr then begin
         lvnestlevel:= integer(a1ptr^);
         fsforward(a1ptr);
         end;
      end;

   if nr=0 then xProgramError('X(alPack): Program error - nr>0 was expected.')
   else if a1ptr^<>eoa then
      xProgramError('X(alPack): Program error - end of argument 1 was expected.')
   else begin

      // Local variable? Then add offset for outer level local variables.
      if nr>xmaxfuncnr then begin
         if lvnestlevel>0 then
            nr:= nr+locVarOffsetStack[lvnestlevel]
         else nr:= nr+locVarOffset;

         fsrewrite(mactab[nr]);
         for n:= 4 to narg do begin
            fscopy(arg[n],mactab[nr],eoa);
            if n<narg then fscopy(arg[3],mactab[nr],eoa);
            end;
         mtab:= mactab[nr];
         fspshend(mtab,eoa);
         end
      else if integer(mactab[nr])<=alIndexMaxNr then begin
         //$binnr is a table
         (* Reference to the table itself is not allowed in alPack, only to
            an item in the table. *)
         // arg2 is assumed to be the index
         if arg[2]^=eoa then
            // There must be an index (empty string is not considered one)
            xScriptError('alPack: An index was expected but it was empty.')
         else begin
            // arg3 = delimiter
            alIndexSet(integer(mactab[nr]),alfstostr(arg[2],eoa),'');
            for n:= 4 to narg do begin
               alIndexAppendWithDelim(integer(mactab[nr]),alfstostr(arg[2],eoa),
                 alfstostr(arg[n],eoa),alfstostr(arg[3],eoa))
               end
            end;
         end
      else begin

         // Normal variable
         fsrewrite(mactab[nr]);
         for n:= 4 to narg do begin
            fscopy(arg[n],mactab[nr],eoa);
            if n<narg then fscopy(arg[3],mactab[nr],eoa);
            end;
         mtab:= mactab[nr];
         fspshend(mtab,eoa);
         end;
      end;
    end; (* with *)

aldispose(pargs,mem);

end; (*alPack*)



procedure alUnpack( var pargs: xargblock; var pstateenv: xstateenv);
(* <unpack str,delim,$var1,$var2, ...>:
   Unpack a string to a series of variables. Example:
   <unpack abc 123 44 5.0 blabla, ,$var1,$var1,$var1,$var1,$var1> =
   <set $var1,abc>
   <set $var2,123>
   <set $var3,44>
   <set $var4,5.0>
   <set $var5,blabla>
   Can be used to switch "environment" for code that shall work
   in parallell with several contexts.
*)

var
mem: alevalmem;
inptr,outptr: fsptr;
delimchar: char;
varix: integer;

function eraseAndGetPtr(pargptr: fsptr): fsptr;
var
nr,lvnestlevel: integer;

begin
if pargptr^=char(xstan) then begin
   fsforward(pargptr);
   nr:= ord(pargptr^);
   lvnestlevel:= 0;
   fsforward(pargptr);
   if (nr=0) and (pargptr^<>eoa) then begin
      nr:= ord(pargptr^);
      fsforward(pargptr);
      nr:= nr*250 + ord(pargptr^);
      fsforward(pargptr);
      if nr>xmaxfuncnr then begin
         lvnestlevel:= integer(pargptr^);
         fsforward(pargptr);
         end;
      end;
   // narg=0
   fsforward(pargptr);

   if nr=0 then begin
      xProgramError('X(alUnpack): Program error - nr>0 was expected.');
      eraseAndGetPtr:= nil;
      end
   else if pargptr^<>eoa then begin
      xProgramError('X(alUnpack): Program error - end of argument 1 was expected.');
      eraseAndGetPtr:= nil;
      end

   else begin
      // Local variable? Then add offset for outer level local variables.
      if nr>xmaxfuncnr then begin
         if lvnestlevel>0 then nr:= nr+locVarOffsetStack[lvnestlevel]
         else nr:= nr+locVarOffset;
         fsrewrite(mactab[nr]);
         eraseAndGetPtr:= mactab[nr];
         end
      else if integer(mactab[nr])<=alIndexMaxNr then begin
         //mactab[nr] is a table
         xProgramError('X(alUnpack): Script error - variable was expected but table was found.');
         eraseAndGetPtr:= nil;
         end
      else begin
         // Normal variable
         fsrewrite(mactab[nr]);
         eraseAndGetPtr:= mactab[nr];
         end;
      end;
   end (* starts with stan *)
else begin
   xScriptError('alunpack: Variable reference ($...) was expected but '+
      alfstostr(pargptr,eoa) + ' was found.');
   eraseAndGetPtr:= nil;
   end

end;(* eraseAndGetPtr *)


begin (*alunpack*)

alevaluate(pargs,pstateenv,mem,[1,2]);

with pargs do begin

   (* Divide str (arg1) in substrings, using arg2 as delimeter. *)
   inptr:= pargs.arg[1];
   delimchar:= pargs.arg[2]^;
   varix:= 3;
   outPtr:= eraseAndGetPtr(pargs.arg[varix]);
   while (inPtr^<>eoa) and not xfault do begin
      if inPtr^=delimChar then begin
         fspshend(outPtr,eoa);
         varix:= varix+1;
         if varix<=pargs.narg then outPtr:= eraseAndGetPtr(pargs.arg[varix]);
         end
      else if varix<=pargs.narg then fspshend(outPtr,inptr^);
      fsforward(inptr);
      end;
   fspshend(outPtr,eoa);
   end;

   if varix<>pargs.narg then begin
	   if varix>pargs.narg then
         xscripterror('alUnpack('+alfstostr(pargs.arg[1],eoa)+',...): '+
            'The number of values in arg1 ('+inttostr(varix-2)+
            ') was more than the number of variables (' +
            inttostr(pargs.narg-2) + ') to put them in.')
      else (*varix<pargs.narg*)
         xscripterror('alUnpack('+alfstostr(pargs.arg[1],eoa)+',...): '+
            'The number of values in arg1 ('+inttostr(varix-2)+
            ') was less than the number of variables (' +
            inttostr(pargs.narg-2) + ') to put them in.');
      end;

end; (*alUnpack*)


// BFn 2016-12-13: Implement by calling Indexes (the current contents
// is just copied from alUpdate). *)
procedure alIndexes( var pargs: xargblock; var pstateenv: xstateenv;
   pfuncret: fsptr);
(* <indexes $name[,delim]>:
   Return a list of all indexes in a table.
   Example:
   <var $tab[]>
   <set $tab[book],2>
   <set $tab[magazine],15>
   <indexes $tab> => "2|15"
   <set $tab[magazine],>
   <indexes $tab> => "2"

   Normally used in in combination with <foreach ...> to process all entries
   in a table. Example:
   <wcons Contents of tab is:
   -<foreach $ix,<indexes $tab>, tab[$ix] = $tab[$ix]>.
   ->
*)

var
nr: alint16;
tabnr: integer;
mem: alevalmem;
a1ptr: fsptr;
delim: string;

begin (*alIndexes*)

alevaluate(pargs,pstateenv,mem,[2]);

with pargs do begin

   // 1. Get macro number from arg1.
   a1ptr:= arg[1];
   nr:= ord(a1ptr^);
   fsforward(a1ptr);
   if (nr=0) and (a1ptr^<>eoa) then begin
      nr:= ord(a1ptr^);
      fsforward(a1ptr);
      nr:= nr*250 + ord(a1ptr^);
      fsforward(a1ptr);
      end;

   // 2. Get indexes for table, if arg1 is a table
   if nr=0 then xProgramError('X(alIndexes): Program error - nr>0 was expected.')

   else if a1ptr^<>eoa then
      xProgramError('Program error - end of argument 1 was expected.')

   else if integer(mactab[nr])<=alIndexMaxNr then begin
      //$binnr is a table
      tabnr:= integer(mactab[nr]);
      delim:= '|';
      if narg>=2 then delim:= alfstostr(arg[2],eoa);

      // Copy index list to funcret
      Indexes(tabnr,delim,pfuncret);
      end
   else begin
      if nr>xmaxfuncnr then
         // Local variable
         xScriptError('<indexes $name...>: For argument 1, a table was ' +
            'expected, but a local variable was instead found.')
      else
         // Normal variable
        xScriptError('<indexes $name...>: For argument 1, a table was ' +
           'expected, but a plain variable was instead found.');
      end;
   end; // (with)

aldispose(pargs,mem);

end; (*alIndexes*)


procedure alParamStr( var pargs: xargblock; var pstateenv: xstateenv;
   pfuncret: fsptr);
(* <paramstr n>:
   Return command line parameter, where n = 0..number of command line
      parameters to x.
   Examples:
   <paramstr 0> => C:\Users\David\Desktop\Program files (x86)\x\x.exe
   <paramstr 1> => "<load decodelog>"'
*)

var
nr: alint16;
mem: alevalmem;

begin (*alParamStr*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

   // Get parameter number. 0 = full path to the exe file.
   if alFsToInt(arg[1],nr) then begin
      if (nr>=0) and (nr<=paramCount) then alStrToFs(paramstr(nr),pfuncret);
      end
   else xScriptError('paramStr expected a number 0.. but found ' +
      alFsToStr(arg[1],eoa) + '.');
   end; // (with)

aldispose(pargs,mem);

end; (*alParamStr*)


(* (new:) Supports HELPTAB, EXAMPLES and HELPFUNC. *)

procedure createHelpTab;
var
// Windows style resource files
S: TResourceStream;
str: string;
size: integer;

begin

(* Get X language help from Windows style resource files. *)

(* Do not load help if in DLL version, because x language
   help is not expected to be needed when x is used as DLL. *)
if alDllVersion then begin
   // Create empty help indexes (without x language help)
   helpTabIndexNr:= alindexcreate(0);
   examplesTabIndexNr:= alindexcreate(0);
   end

else begin

   (* Create a resource stream which points to our resource (which
      contains x language help texts for each function) *)
   (* HELPTAB: *)
   S := TResourceStream.Create(HInstance, 'HELPTAB', RT_RCDATA);
   size:= s.size;
   setlength(str,size);
   s.read(str[1],size);

   // Now create a table and fill it with str
   helpTabIndexNr:= alindexcreate(0);
   alindexinitStr(helpTabIndexNr,str);
   s.free;

   (* EXAMPLES: *)
   S := TResourceStream.Create(HInstance, 'EXAMPLES', RT_RCDATA);
   size:= s.size;
   setlength(str,size);
   s.read(str[1],size);

   // Now create a table and fill it with str
   examplesTabIndexNr:= alindexcreate(0);
   alindexinitStr(examplesTabIndexNr,str);
   s.free;

   (* HELPFUNC: *)
   S := TResourceStream.Create(HInstance, 'HELPFUNC', RT_RCDATA);
   size:= s.size;
   setlength(str,size);
   s.read(str[1],size);

   // Now save the string in helpFuncTabStr
   alHelpFunctionsStr:= str;
   s.free;
   end;

end; (* createHelpTab. *)


(* (old:) Only supports HELPTAB. *)
procedure createHelpTab0;
var
// Windows style resource files
S: TResourceStream;
str: string;
size: integer;

begin

(* Get X language help from Windows style resource files. *)

(* Do not load help if in DLL version, because x language
   help is not expected to be needed when x is used as DLL. *)
if alDllVersion then
   // Create an empty help index (without x language help)
   helpTabIndexNr:= alindexcreate(0)

else begin

   (* Create a resource stream which points to our resource (which
      contains x language help texts for each function) *)
   S := TResourceStream.Create(HInstance, 'HELPTAB', RT_RCDATA);
   size:= s.size;
   setlength(str,size);
   s.read(str[1],size);

   // Now create a table and fill it with str
   helpTabIndexNr:= alindexcreate(0);
   alindexinitStr(helpTabIndexNr,str);
   s.free;
   end;

end; (* createHelpTab0. *)


procedure alHelp( var pargs: xargblock; var pstateenv: xstateenv;
   pfuncret: fsptr);
(* <help funcname>:
   Funcname is the name of a function.
   Examples:
   <help select> => (Help text for <select ...>)
   <help alt> => (Help text for <alt ...>)
*)

var
mem: alevalmem;

begin (*alHelp*)

alevaluate(pargs,pstateenv,mem,[1..2]);

// Create a help table if this is not already done
if helpTabIndexNr=0 then createHelpTab;

if pargs.narg=2 then

   // Set up a new slot in helptab
   stringtab[helpTabIndexNr].Values[alfstostr(pargs.arg[1],eoa)]:=
      alfstostr(pargs.arg[2],eoa)
else if pargs.narg=1 then begin

   // Return the string under index arg1
   alstrtofs(stringtab[helpTabIndexNr].values[alfstostr(pargs.arg[1],eoa)],pfuncret);
   if pfuncret=eofs then alStrtofs('No such function. Use <help> for list of functions.',pfuncret);
   end

else begin

   // No arguments, return the string associated with empty index
   alstrtofs(stringtab[helpTabIndexNr].values[''],pfuncret);
   // New: Try create help window.
   iofHelp;
   end;


aldispose(pargs,mem);

end; (*alHelp*)

(* Example:
   if alFsLeftEqual(linestr,'enter:') then ...
*)
function alFsLeftEqual(pstr1: fsptr; pstr2: string): boolean; forward;

procedure alExamples( var pargs: xargblock; var pstateenv: xstateenv;
   pfuncret: fsptr);
(* <examples funcname>:
   Funcname is the name of a function.
   Open file examples.txt (in the same directory as x.exe) and lookup
   examples for the chosen function and return them.
   Examples:
   <examples select> => (Usage examples for <select ...>)
   <examples alt> => (Usage examples for <alt ...>)

   Example of example in examples.txt:

   ---------------------------------------------------------------------------------
   <append $varname,str[,delimeter]>:
   Append a string to a variable, optionally with delimeters between appended
      strings.
   ...
   ?"<format hh>"?
   !"<update $bytecnt,+1><append $errorbuf,<p 1>>"!
   (Append unexpected data to errorBuf for later error message)
   ...
   <append $result,<c itemRead,<htod <p 1>>>, >
   (Add items, read with itemRead, to result, separated by blanks)
   ---------------------------------------------------------------------------------
*)

var
mem: alevalmem;
xexedir,filename,funcname: string;
last,ior1: integer;
exampleFile: File;
readBufPtr,readBufPtr0,dashcopyPtr: fsptr;
readState: (s0,s1,s2,s3);
found: boolean;

begin (*alExamples*)

alevaluate(pargs,pstateenv,mem,[1]);
fsnew(readBufPtr);
fsnew(dashCopyPtr);
readBufPtr0:= readBufPtr;
funcname:= alFsToStr(pargs.arg[1],eoa);

// Get directory of x.exe
xexedir:=paramstr(0);

// Remove "x.exe"
last:= length(xexedir);
while (last>1) and (xexedir[last]<>'\') do last:= last-1;
if xexedir[last]='\' then last:= last-1;
xexedir:= LeftStr(xexedir,last);
filename:= xexedir + '\examples.txt';
found:= false;
readState:= s0;

// Open examples.txt

if fileexists(filename) then begin

   // 2. Load the file
   alOpenForRead(exampleFile,filename,ior1);

   if (ior1=0) then begin

      // Read file, line by line
      while (not eof(exampleFile)) and (readState<>s3) do begin

         fsRewrite(readBufPtr);
         alReadLine(exampleFile,readBufPtr);

         case readState of
            s0: if alFsLeftEqual(readBufPtr0,'---------------------') then begin
               fsrewrite(dashCopyPtr);
               fscopy(readBufPtr,dashCopyPtr,eofs);
               readState:= s1;
               end;
            s1: if alFsLeftEqual(readBufPtr0,'<'+ funcname) then begin
               found:= true;
               fsbackEnd(dashCopyPtr);
               fscopy(dashCopyPtr,pfuncret,eofs);
               fspshend(pfuncret,char(13));
               fscopy(readBufPtr0,pfuncret,eofs);
               readState:= s2;
               end
            else readState:= s0;
            s2: begin
               fspshend(pfuncret,char(13));
               fscopy(readBufPtr0,pfuncret,eofs);
               if alFsLeftEqual(readBufPtr0,'---------------------') then readState:= s3;
               end;
            s3: ;

            end;
         end;// (while not eof...)

      // Close file
      close(exampleFile);

      if not found then xscripterror('<examples ...>: No examples found for function ' +
         funcname + '.');
      end;// (ior 1 = 0)

   end
else xscripterror('<examples ...>: This function works only if the file '+
   '"examples.txt" exists in the same directory as x.exe.');

fsdispose(dashCopyPtr);
fsdispose(readBufPtr);
aldispose(pargs,mem);

end; (*alExamples*)


(* (old:) *)
procedure alIntro0( var pargs: xargblock; var pstateenv: xstateenv;
   pfuncret: fsptr);
(* 
   (intro str)
   - This is obsolete and replaced by <usage ...> -
   
   If loadlevel=1, clear screen, and print introduction text.
   Note that special characters in str need to be quoted, unless they are
   intended to be evaluated.

   Example:
   <intro ,,,,-
   compileSwe.x: Compile trackfile script
   ======================================
   Example usage (from file to screen): '<comp trackfile.txt'>
      or (from file to file): '<comp trackfile.txt',trackfile.trk'>
      or (from screen to screen): '<compile Si 270/40''', 1000m'>
   Example input file:
      1 100 Si 270/40', 1000m
      2 200 Si 270/40', 1000m 10-superv.
      3 300 Si 270/40', 1000m P-extended 1000m 10-superv.
   For detailed documentation of symbolic format', see:
      N:\STM-N\U - System Verification and Validation\FAT\Test Environment_Requirements\SVS_STM1_Compile_ATC2 Balises_ETCS balises.doc>>
   ->
*)

var
mem: alevalmem;
nargSave,a: integer;
introStr: string;
moveform: boolean;

begin (*alIntro*)


// <if <loadlevel>=1,
if alLoadLevel=1 then begin

   alevaluate(pargs,pstateenv,mem,[1..pargs.narg]);

   // <windowClear>
   iofClear;

   // Print text
   introStr:=  alfstostr(pargs.arg[1],eoa);

   // Insert commas which script programmer forgot to quote.
   with pargs do for a:= 2 to narg do begin
      introStr:= introStr + ',' + alfstostr(pargs.arg[a],eoa);
      end;

   // <wcons ...>
   iofwcons(introStr);

   aldispose(pargs,mem);
   end;

end; (*alIntro*)


procedure almacro( pnr: alint16; var pargs: xargblock;
   pevalkind: xevalkind; (* Tells xevaluate what to do with the stuff (see
   xevaluate). *)
   var pstateenv: xstateenv; pfuncret: fsptr ); forward;

procedure alrealtofs( pr: REAL; pdec: alint16; var ps: fsptr ); forward;
(* Convert floating point to fs, use pdec decimals. *)


(* (new:) *)
procedure alUpdate( var pargs: xargblock; var pstateenv: xstateenv);
(* <update $name,str[,decimals][,initvalue]>, <update $name[$index],str[,decimals][,initvalue]>:
   Modify a value with <calc ...>.
   Examples:
   <update $i,+1> = <set $i,<calc $i+1>>
   <update $tab[$n],+1> = <set $tab[$n],<calc $tab[$n]+1>>
   <update $r,*0.5,2> = <set $r,<calc $r*0.5,2>>
   <update $tab[$i],+1,,0> =
      <ifempty $tab[$i],<set $tab[$i],<calc 0+1>>
      -,{else]<set $tab[$i],<calc $tab[$i]+1>>

   It is adviceable to put brackets around the variable name if it can
   contain an expression, to avoid unexpected results.
   Example:
   <set $a,2 + 3>
   <update $a,*2> => 2 + 3*2 = 8
   <update ($a),*2> => (2+3)*2 = 10
*)

var
nr: alint16;
tabnr,opArgNr,decArgNr,initArgNr: integer;
mtab: fsptr;
mem: alevalmem;
a1ptr: fsptr;
lvnestlevel: integer;
ptr: fsptr;
evalstr,evalstr0: fsptr;
r: real;
errorFound: boolean;
decimals: integer;

begin (*alUpdate*)
(****)if alflagga('D') then with pargs do begin
(****)  if rekursiv[2] then iodebugmess('->alset: rekursiv[2]=true')
(****)  else iodebugmess('->alset: rekursiv[2]=false');
(****)  end;

alevaluate(pargs,pstateenv,mem,[2..5]);

with pargs do begin
   fsnew(evalstr);
   evalstr0:= evalstr;
   errorFound:= false;
   tabnr:= 0;

   // 1. Get macro number from arg1.
   a1ptr:= arg[1];
   nr:= ord(a1ptr^);
   lvnestlevel:= 0;
   fsforward(a1ptr);
   if (nr=0) and (a1ptr^<>eoa) then begin
      nr:= ord(a1ptr^);
      fsforward(a1ptr);
      nr:= nr*250 + ord(a1ptr^);
      fsforward(a1ptr);
      if nr>xmaxfuncnr then begin
         lvnestlevel:= integer(a1ptr^);
         fsforward(a1ptr);
         (* lvnestlevel is 0 except when $name is used in an argument to a macro,
            which is not the case here. *)
         if lvnestlevel>0 then
            xProgramError('alUpdate: Program error - locvarnestlevel 0 was expected but '+
               inttostr(lvnestlevel)+' was found.')
         end;
      end;

   // 2. Set evalstr = current value of the variable. Example: "1"
   if nr=0 then xProgramError('X(alUpdate): Program error - nr>0 was expected.')

   else if a1ptr^<>eoa then
      xProgramError('Program error - end of argument 1 was expected.')

   else if integer(mactab[nr])<=alIndexMaxNr then begin
      //$binnr is a table
      tabnr:= integer(mactab[nr]);
      opargnr:= 3; // Operator in arg 3
      decargnr:= 4; // Optional number of decimals in arg 4
      initargnr:= 5; // Optional init value

      // Copy $(name)[(arg2)] to evalstr. *)
      alstrtofs(stringtab[tabnr].values[alfstostr(arg[2],eoa)],evalstr);
      end
   else begin
      // nr is a local variable or a normal variable
      opargnr:= 2; // Operator in arg 2
      decargnr:= 3; // Optional number of decimals in arg 3
      initargnr:= 4; // Optional init value
      // Local variable? Then add offset for outer level local variables.
      if nr>xmaxfuncnr then begin
         // (lvnestlevel shall not be possible here)
         nr:= nr+locVarOffset;
         fscopy(mactab[nr],evalstr,eoa);
         (* ++ Diagnostic:
         if (evalstr0^=eofs) then begin
            xScriptError('alUpdate: old value was empty. nr='+inttostr(nr)+'.');
            end;*)
         end
      else begin
         // Normal variable
         fscopy(mactab[nr],evalstr,eoa);
         end;
      end;

   // 3. See if value is empty and if there is a default start value (initargnr).
   if (narg>=initargnr) and (evalstr0^=eofs) then fscopy(arg[initargnr],evalstr,eoa);

   (* 4. Add evaluated arg2 (or arg3 if table) to evalstr.
      Example: evalstr = '0', arg[opargnr] = '+1' => evalstr = '0+1'. *)
   fscopy(arg[opargnr],evalstr,eoa);

   // 5. Add eoa to evalstr, because calc expects it.
   fspshend(evalstr,eoa);

   // 6. Run calc on resulting string, example: r= 1+1=2.0
   r:= calc(evalstr0,errorFound);

   // 7. Calculate number of decimals
   decimals:= 0;
   if narg>=decArgNr then begin
      if arg[decArgNr]^<>eoa then begin
         decimals:= fsposint(arg[decArgNr]);
         if decimals<0 then begin
            xScriptError('X(<update ...,decimals>): Expectec decimals to be a '+
               'number >=0, but found "'+alfstostr100(arg[decArgNr],eoa)+'".');
            decimals:= 0;
            errorFound:= true;
            end;
         end;
      end;

   // 8. Set variable $name or tablearg1[arg2] to the result.
   if not errorFound then begin
      if opargnr=2 then begin
         // Normal or local variable
         fsrewrite(mactab[nr]);
         mtab:= mactab[nr];
         alrealtofs(r,decimals,mtab);
         fspshend(mtab,eoa);
         end
      else begin
         // Table
         // fsdelrest(evalstr); // (this needed?)
         evalstr0:= evalstr;
         alrealtofs(r,decimals,evalstr);
         stringtab[tabnr].Values[alfstostr(arg[2],eoa)]:= fstostr(evalstr0);
         end;
      end;

   fsdispose(evalstr)
   end; (* with *)

aldispose(pargs,mem);

end; (*alUpdate*)



var
scriptError: boolean;
scriptErrorMessage: string;


procedure almacro( pnr: alint16; var pargs: xargblock;
                   pevalkind: xevalkind; (* Tells xevaluate what to do
                                            with the stuff (see
                                            xevaluate). *)
                   var pstateenv: xstateenv;
                   pfuncret: fsptr );
(* <(name) a1,...>:
   A user defined function (or definition).

   Evaluate function name as a macro and return the resulting string.

   Arguments appear in the following way in the string:

   $n is converted to argument n.
   $n&&& is converted to argument n followed by spaces until it occupies
      at least) 5 columns.
   &&&$n is as $n&&& but the argument will be rightadjusted.

   User defined functions can also be used in strings that are used for
   comparison (patterns), for example in ?"..."?, <ifeq str,...> and
   <case instr,compstr1,resultstr2,compstr2,resultstr2,...>
*)

var
nr: integer;
ins,ut,utstart:		fsptr;
dumant: alint16;
dumandr: BOOLEAN;
stan: CHAR;
mem: alevalmem;
i: integer;
recursivearg: boolean;
dumrecursive: boolean;
mac: fsptr;
//name: xstring32;
name: string;

failure: boolean;
debugstr: shortstring;
debugsave: boolean;
savemacnr: integer;
saveLocVarEvalCount: integer;
saveLocVarOffset: integer;
oldScriptError: boolean;

(*--- LOKALA PROCEDURER -----*)

procedure fylli( var pantalpsh: alint16; (* OUT: Number of fspshend
                                            (minus n:r of deleted chars)
                                            during fylli. *)
          var pandrad: BOOLEAN;          (* out: arg contained $n which
                                            has been replaced. *)
          var precursive: boolean        (* out: The string written to
                                            ut contains <...>-calls. *)
          );

(* fylli is used to replace $n with the corresponding argument when a macro
   <f ...> is called. alMacro first checks that the macro has $n rererences
   in its body, and then calls fylli to replace these references with arguments.
   fylli also calls itself recursively for each function call argument it
   finds in the body of the macro. This is needed to update the length of the
   all arguments on all levels when $n is expanded to the corresponding
   argument.
   When fylli sees $n, it calls bytut to replace it with the corresponding
   argument.
   fylli continues until it sees eoa. Therefore all macro bodies
   in mactab must be ended by eoa, since fylli is also called for the full
   macro. *)

(* Fylli reads from ins and writes to ut to convert the raw macro body to a
   macro body with $n arguments expanded.
   ins: points at first char in a <...>-argument at entry, points at eoa at exit.
   ut: points at where to put result at entry, points just after end of result
      string at eofs (just after eoa).
   pantalpsh returns the number of written characters.
*)

(* fylli is rather complicated, and it calls itself recursively.
   The complexity of fylli is due to the fact that $n may be in
   arguments of nested <...>-calls, and the length coding of
   these arguments has to be updated after the substitution. *)

var
ch: CHAR;
antalarg: alint16;
argnr: alint16;
inlpos,utlpos,utlpos2: fsptr;
inarglen,utarglen: alint16;
antpsh: alint16;
andrad: BOOLEAN;
kod: CHAR;
rekur: alint16;
newrecursivetab:
  array[1..xmaxnarg] of boolean; (* true = argument [..] of the currently
                                    processed <...>-call either was
                                    recursive to start with, or became
                                    recursive through $n insertion. *)
brecursive: boolean;
funcnr: integer;
tests: fsptr;

(*--------*)

procedure bytut( var pantalpsh: alint16; (* IN: Number of pushed char's
                                            (to ut) before bytut.
                                            OUT: Number of pushed char's
                                            (to ut) after bytut. *)
                 var precursive: boolean (* out: The string inserted
                                            in place of $n contains
                                            <...>-calls. *)
                    );

(* Replace one $n with the corresponding argument pargs.arg[n].

   It also fills with spaces if $n has & before or after it (fixed field width).
   It reads from ins and writes to ut.
   It updates pantalpsh (number of written characters).

   When bytut is called, ins points at the character after '$'. *)

var
n:		alint16;
preceding:	alint16;			(* For &-calculation... *)
following:	alint16;
missingblanks:	alint16;
lblanks:	alint16;
fblanks:	alint16;
cnt:		alint16;
arglen:		alint16;
argn,argp: fsptr;
s: fsptr;
digits: integer;
ch: char;

inIfeqOrCaseOddArg3plus: boolean;
   (* Used to determince if the occurence of <xp n> in the value of a
      function argument ($n) relates to the context in the function, or
      the context where the function was called. If $n contains a call to
      <ifeq ...> or <case ...> statement and <xp n> is in the "yes" strings
      of this statement (arg3, 5, 7 but not the default arg of <case ...>, then
      inIfeqOrCaseOddArg3plus is set to true and <xp n> can be evaluated in the
      local context. Otherwise, it shall be evaluated in the context where
      the function was called. In this case, xparoffset is copied in as an
      invisialb "arg2" of <xp n> and used as xparoffset when <xp n> is
      evaluated.
      Meaning:
      True = we are in a place where <xp n> relates to something locally
      (in <ifeq ...> or <case ...>) in the argument string.
      Since the argument string is copied to the place where $n earlier was,
      then <xp n> can be evaluated normally. But if <xp n> is seen where it
      does not adress anything in the argument string, then it shall be evaluated
      in the context of the function call instead.
   *)

procedure bytutfunc;
(* Called from bytut.
   Copies a function call inside an argument ($n) to output (ut).

   argp^ = stan. Copy from argp to ut and increment cnt for each read/write.
   Handle offsets in local variable references and xp references.
   Continue until end of function call. *)

var
narg,argcnt,argstartcnt,arglen,argendcnt: alint16;
inIfeqOrCaseWasSetHere: boolean;
utTemp: fsptr;
begin
   // (stan)
   fspshend(ut,argp^);
   fsforward(argp);
   cnt:= cnt + 1;
   (* nr *)
   funcnr:= integer(argp^);
   fspshend(ut,argp^);
   fsforward(argp);
   cnt:= cnt+1;
   if funcnr=0 then begin
      (* Long number *)
      funcnr:= integer(argp^)*250;
      fspshend(ut,argp^);
      fsforward(argp);
      funcnr:= funcnr + integer(argp^);
      fspshend(ut,argp^);
      fsforward(argp);
      cnt:= cnt+2;
      if (funcnr>xmaxfuncnr) then begin
         (* Local variable reference - if 0 - write valid index to
            locVarOffsetStack instead. *)
         if argp^=char(0) then
            fspshend(ut,char(locvarevallevel))
         else
            fspshend(ut,argp^);
         fsforward(argp);
         cnt:= cnt+1;
         end;
      end;(* long func nr *)
   // Read arguments
   if argp^=char(0) then begin
      // No arguments
      fspshend(ut,argp^);
      fsforward(argp);
      cnt:= cnt+1;
      end
   else begin
      narg:= alint16(argp^);
      fspshend(ut,argp^);
      fsforward(argp);
      cnt:= cnt+1;
      argcnt:= 0;
      inIfeqOrCaseWasSetHere:= false;
      while argcnt<narg do begin
         argcnt:= argcnt+1;

         (* Check if we are in <ifeq ... or <case ... in odd arg >=3 (because
            then offset in <xp ...> shall not be set). *)
         if argcnt>=3 then begin
            if not inIfeqOrCaseOddArg3plus then begin
               if (funcnr=alIfeqFuncnr) or (funcnr=alCaseFuncnr) then begin
                  if argcnt mod 2=1 then begin
                     (* argnr>=3 and odd. We are in <ifeq ...,...,here,...,here,...>
                        or <case ...,...,here,...,here,...>
                        This means that a match is found in <ifeq ...> or <case ...>. *)

                     // Deactivate setting of xparoffset in calls to <xp n>
                     inIfeqOrCaseOddArg3plus:= true;
                     // Remember to reset this flag at end of this arg.
                     inIfeqOrCaseWasSetHere:= true;
                     end;
                  end;
               end;
            end;

         arglen:= alint16(argp^)*250;
         fspshend(ut,argp^);
         fsforward(argp);
         cnt:= cnt+1;
         arglen:= arglen + alint16(argp^);
         fspshend(ut,argp^);
         fsforward(argp);
         cnt:= cnt+1;
         argstartcnt:= cnt;
         argendcnt:=  argstartcnt+arglen;
         while (argp^<>eoa) do begin
            if argp^=stan then bytutfunc
            else begin
               fspushandforward(argp,ut);
               cnt:= cnt+1;
               end;
            end;
         if cnt<>argendcnt then begin
            if cnt>argendcnt then
               xProgramError('Program error in al.pas: '+
               'bytutfunc. Number of characters in arg '+inttostr(argcnt)+' of function '+
               xname(funcnr)+ ' was expected to be '+inttostr(arglen)+ ' but was found to be '+
               inttostr(cnt-argstartcnt)+' instead.')
            else begin
               while cnt<argendcnt do begin
                 fspushandforward(argp,ut);
                 cnt:= cnt+1;
                 end;
               end;
            if argp^<>eoa then
               xProgramError('Program error in al.pas: '+
               'bytutfunc. Eoa was expected after moving pointer to end of arg but ' +
               argp^ + ' was found instead (expected arglen was '+
               inttostr(arglen)+ ') n arg '+inttostr(argcnt)+' of function '+
               xname(funcnr)+ '.')
            end; // (cnt<>argendcnt)

         // eoa
         fspshend(ut,argp^);
         fsforward(argp);
         cnt:= cnt+1;

         if inIfeqOrCaseWasSetHere then begin
            // Reset the ifeq/case arg odd arg nr 3+ flag.
            inIfeqOrCaseOddArg3Plus:= false;
            inIfeqOrCaseWasSetHere:= false;
            end;
         end; (* while argcnt<narg *)

      if (funcnr=alXpFuncNr) then begin
         if not inIfeqOrCaseOddArg3Plus then begin
            (* This is a call to <xp n> and arg2 shall be set to xparoffset if it has
               not been set before (250). *)
            utTemp:= ut;
            fsback(utTemp);
            fsback(utTemp);
            if utTemp^=char(250) then begin
               utTemp^:=char(pstateenv.pars.xparoffset);
               end;
            end;
         end;
      // List of recursive arguments.
      while argp^<>char(0) do begin
         fspshend(ut,argp^);
         fsforward(argp);
         cnt:= cnt+1;
         end;
      // Final char(0)
      fspshend(ut,argp^);
      fsforward(argp);
      cnt:= cnt+1;
      end; // function with arguments.

end;// (bytutfunc)

begin (*bytut*)

precursive:= false;
inIfeqOrCaseOddArg3plus:= false;

(* n:= ORD(ins^) - ORD('0'); *)
n:= ORD(ins^) - ORD('0');
digits:= 0;
if ins^ in ['0'..'9'] then begin
   digits:= 1;
   fsforward(ins);
   while ins^ in ['0'..'9'] do begin
      n:= n*10 + alint16(ins^) - alint16('0');
      digits:= digits+1;
      fsforward(ins);
      end;
   fsback(ins);
   end;

(*
if n>xmaxnarg then begin
   xProgramError('X(almacro): Program error - $n was read but n was > xmaxnarg.');
   end; *)

with pargs do if (digits>0) and (n>0) and (n<=xmaxnarg) then begin

   (* Remove $ and preceding &'s *)
   preceding:= 0;
   fsback(ut); (* $ *)
   pantalpsh:= pantalpsh-1;

   (* Find optional preceding &'s *)
   while ((ut^='$') or (ut^='&')) and (pantalpsh>0) do begin
      fsback(ut);
      pantalpsh:= pantalpsh-1;
      if ut^='&' then preceding:= preceding+1;
      end;
   if (ut^<>'$') and (ut^<>'&') then begin
      fsforward(ut);
      pantalpsh:= pantalpsh+1;
      end;

   (* Ut now points at $ or the first & *)
   fsdelrest(ut);

   (* Remove following &'s *)
   fsforward(ins);
   following:= 0;
   while (ins^='&') do begin
      fsforward(ins);
      following:= following + 1;
      end;

   (* Calculate how many blanks must be added *)
   arglen:= 0;
   if n<=narg then begin

      (* New 990306: *)
      if mem[n]=nil then begin
         (* Not evaluated (or not recursive) -
            evaluate (as in alevaluate) if recursive and
            there is fillout (&'s). The fillout will not work
            properly otherwise (it will be adopted to the
            length of the unevaluated argument instead of the
            length of the final evaluated argument). The reason
            we do not always evaluate here, is that it is better
            to postpone evaluation to as late as possible (macros
            such as <list <id>,',> will not work otherwise). *)
         if rekursiv[n] and ((preceding+following)>0) then begin
             mem[n]:= arg[n];
             fsnew(arg[n]);
             xevaluate(mem[n],eoa,xevalnormal,pstateenv,arg[n]);
             s:= arg[n];
             fspshend(s,eoa);
             rekursiv[n]:= false;
             end;
          end;

      if mem[n]<>NIL then begin
         (* arg[n] is a new string appended by eoa. *)
         argn:= arg[n];
         fsforwend(argn);
         arglen:= fsdistance(arg[n],argn) - 1;
         end
      else begin
         (* arg[n] points into a compiled <...>-call where
            every argument is preceded by a byte telling its
            length. *)
         (* Note: arglen can become a little to large if the
            argument is longer than 64 char's (see xarglen)
            but this will only have any effect if the &&&-field
            is even longer, and the effect will only be that the
            number of fillout blanks will be to small. This is
            either a "feature" or a "known bug". Maybe a later
            implementation will use 16 bits for argument length
            instead of 8 or perhaps a coding where bit7=1 means
            another length byte coming, which would give unlimited
            argument length.
            990515: This problem is now fixed. *)
         argn:= arg[n];

         // (new:)
         fsback(argn);
         arglen:= integer(argn^);
         fsback(argn);
         arglen:= arglen+integer(argn^)*250;
         fsmultiforw(argn,arglen+1);

         (* (old:)
         fsback(argn);
         arglen:= xarglen(argn^);
         fsmultiforw(argn,arglen);
         *)
         (* argn now points at last char in arg, unless there
            are extra eoa's *)
         if argn^=eoa then
            xProgramError('X(bytut): Program error - eoa where not expected.');
         (* (old:)
         if arglen>0 then while argn^=eoa do begin
            fsback(argn);
            arglen:= arglen-1;
            end;
         *)
         end;
      end;

   if (preceding=0) and (following=0) then
      missingblanks:= 0 (* Do not fill if no "&"-char's *)
   else missingblanks:= 1 + digits + preceding + following - arglen;

   (* following=0=> rightadjusted, preceding=0 => leftadjusted,
      preceding>0 and following>0 => middle. Compute necessary
      number of leading and following blanks: *)
   if following = 0 then begin

      lblanks:= missingblanks;
      fblanks:= 0;
      end

   else if preceding = 0 then begin

      lblanks:=0;
      fblanks:= missingblanks;
      end

   else begin

      lblanks:= missingblanks DIV 2;
      fblanks:= missingblanks - lblanks;
      end;

   (* Write field to ut... *)

   for cnt:= 1 TO lblanks do fspshend(ut,' ');
   if lblanks>0 then pantalpsh:= pantalpsh + lblanks;

   if (n<=narg) then begin
      if rekursiv[n] then precursive:= true;
      argp:= arg[n];
      cnt:= 0;
      while cnt < arglen do begin
         (* Detect local variable references and xp references to insert valid
            offset stack indexes if necessary. *)
         if argp^=stan then bytutfunc

         else begin
            // (new:)
            fspushandforward(argp,ut);
            (* (old:)
            fspshend(ut,argp^);
            fsforward(argp);*)
            cnt:= cnt + 1;
            end;
         end;
      pantalpsh:= pantalpsh+cnt;
      if not (argp^=eoa) then
         xProgramError('X:bytut): Error - argp^<>eoa.');
      end;

   for cnt:= 1 TO fblanks do fspshend(ut,' ');
   pantalpsh:= pantalpsh + fblanks;
   end;

end; (*bytut*)

(*--------*)


begin (*fylli*)

(****)(*iodebugmess('fylli: ins^= "'+alfstostr100(ins,eofs)+'".');*)

pantalpsh:= 0;
pandrad:= FALSE;
precursive:= false;

while not (ins^=eoa)
(****)(*and not (ins^=eofs)*)
do begin

   ch:= ins^;
   fspshend(ut,ins^);
   fsforward(ins);
   pantalpsh:= pantalpsh + 1;

   if ch=stan then begin (* <...>-ANROP *)

      precursive:= true;
      (* nr *)
      funcnr:= integer(ins^);
      fspshend(ut,ins^); pantalpsh:= pantalpsh+1;
      fsforward(ins);
      if funcnr=0 then begin
         (* Long number *)
         funcnr:= integer(ins^)*250;
         fspshend(ut,ins^);
         fsforward(ins);
         funcnr:= funcnr + integer(ins^);
         fspshend(ut,ins^);
         fsforward(ins);
         pantalpsh:= pantalpsh+2;
         if (funcnr>xmaxfuncnr) then begin
            // Local variable reference - nesting level
            fspshend(ut,ins^);
            fsforward(ins);
            pantalpsh:= pantalpsh+1;
            end;
         end;

      antalarg:= ORD(ins^);
      fspshend(ut,ins^); pantalpsh:= pantalpsh+1;
      fsforward(ins);

      for argnr:= 1 TO antalarg do begin

         inlpos:= ins;
         utlpos:= ut;

         fspshend(ut,ins^); pantalpsh:= pantalpsh + 1;
         utlpos2:= ut;
         fsforward(ins);
         inarglen:= integer(inlpos^)*250+integer(ins^);

         fspshend(ut,ins^); pantalpsh:= pantalpsh + 1;
         (* (only for debugging:)
         if ins^=eofs then
            xProgramError('X(fylli): Program error - unexpected eofs.');*)
         fsforward(ins);

         (* NU PÅ 1:A TECKEN I ARG (EL EOA) *)

         fylli(antpsh,andrad,newrecursivetab[argnr]);
         pantalpsh:= pantalpsh + antpsh;

         if andrad then begin

            utlpos^:= char(antpsh div 250);
            utlpos2^:= char(antpsh mod 250);
            fspshend(ut,eoa); pantalpsh:= pantalpsh+1;
            antpsh:= antpsh+1;

            (* 2 (TILL 1:A TECKEN) + INARGLEN (TILL EOA)
               + 1 (TILL JUST EFTER EOA) *)
            ins:= inlpos;
            // (new:)
            fsmultiforw(ins,inarglen+3);
            // (old:) fsmultiforw(ins,inarglen+2);
            pandrad:= TRUE;
            end

         else while not (antpsh=inarglen+1) do begin
            (* EX: ARGLEN=0 => 1 FRAMÅT FÖR ATT KOMMA TILL NÄSTA ARG *)
            fspushandforward(ins,ut);
            antpsh:= antpsh+1; pantalpsh:= pantalpsh + 1;
            end;
         (* VI SKA NU VARA PRECIS EFTER EOA-MARKERING *)
(****)tests:= ins; fsback(tests);
   if tests^<>eoa then xProgramError('X(fylli): tests^-1 ej eoa: antpsh='+inttostr(antpsh)+', inarglen+1='+
      inttostr(inarglen+1)+', funcnr='+inttostr(funcnr)+
   ', argnr='+inttostr(argnr)+', inlpos^='+inttostr(integer(inlpos^))
(****)+', tests-1^='+inttostr(integer(tests^))+'.');
         end;

      if antalarg>0 then begin
         (* Read recursive markings and zero terminator. *)
         REPEAT (* REKURSIVMARKERINGAR *)
            rekur:= ORD(ins^);
            if (rekur>0) and (rekur<=antalarg) then
               newrecursivetab[rekur]:= true;
            fsforward(ins);
            UNTIL rekur=0;
         (* Write recursive markings and zero terminator. *)
         for argnr:= 1 TO antalarg do begin
            if newrecursivetab[argnr] then begin
               fspshend(ut,char(argnr));
               pantalpsh:= pantalpsh + 1;
               end;
            end;
         fspshend(ut,char(0)); pantalpsh:= pantalpsh + 1;
         end;

      end (* ANROP *)

   else if ch='$' then begin
      bytut(pantalpsh,brecursive);
      pandrad:= TRUE;
      precursive:= precursive or brecursive;
      end;
   end; (* while *)

end; (*fylli*)

(*--- SLUT LOKALA PROC ------*)

begin (*almacro*)

oldScriptError:= scriptError;

with pStateEnv do begin
   savemacnr:= macnr;
   macnr:= pnr;
   end;

if alflagga('d') then begin
   debugstr:= '->almacro('+inttostr(pnr)+')';
   if pnr<=xmaxfuncnr then if recursivemac[pnr] then
     debugstr:= debugstr+' - rekursiv';
   iodebugmess(debugstr);
   end;

(* Disable debug unless stepdown was requested. *)
debugsave:= iofdebug;
if iofdebug and not iofstepdown then begin
   iofdebug:= false;
   end;
iofstepdown:= false;

alevaluate(pargs,pstateenv,mem,[]); (* (Modified 990306) *)

stan:= char(xstan);

if pnr>xmaxfuncnr then begin
   // Local variable, skip variables for outer levels of function calls
   // Compensate if reference was in the scope of a calling function
   if pargs.locvarnestlevel>0 then
      nr:= pnr+locVarOffsetStack[pargs.locvarnestlevel]
   else nr:= pnr+locVarOffset;
   fscopy(mactab[nr],pfuncret,eoa);
   end
else if (pargs.narg = 0) and not parmac[pnr] then begin
   if recursivemac[pnr] then begin

      // Update local variable offset
      saveLocVarEvalCount:= locVarEvalCount;
      saveLocVarOffset:= locVarOffset;
      locVarOffset:= locVarOffset+locVarEvalCount;
      locVarEvalCount:= 0;
      locVarEvalLevel:= locVarEvalLevel+1;(* we are evaluating a function. *)

      (* Update locvaroffsetstack, used to compensate for locvarnestinglevel
         (see xargblock). *)
      if locVarEvalLevel>locvaroffsetstacksize then begin
         if locvarevallevel=locvaroffsetstacksize+1 then
            xProgramError('X(almacro): Up to ' + inttostr(locvaroffsetstacksize) +
            ' calling levels of user defined functions is supported, ' +
            ' but this script would require at least ' +
            inttostr(locvarevallevel) + ' levels of calling depth (1).');
         end
      else locvaroffsetstack[locvarevallevel]:= locVarOffset;

      // Evaluate function
      if containscleanup[pnr] then begin
         fsnew(mac);
         fscopy(mactab[pnr],mac,eofs);
         xevaluate(mac,eoa,pevalkind,pstateenv,pfuncret);
         fsdispose(mac);
         end
      else xevaluate(mactab[pnr],eoa,pevalkind,pstateenv,pfuncret);

      // Restore local variable count and offset
      locVarEvalCount:= saveLocVarEvalCount;
      locVarOffset:= saveLocVarOffset;
      locVarEvalLevel:= locVarEvalLevel-1;
      end
   else fscopy(mactab[pnr],pfuncret,eoa);
   end

else begin
   ins:= mactab[pnr];
   recursivearg:= false;
   for i:= 1 to pargs.narg do if pargs.rekursiv[i] then
      recursivearg:= true;
   if recursivemac[pnr] or recursivearg then begin
      // Fill in parameters
      fsnew(ut);
      utstart:= ut;
      fylli(dumant,dumandr,dumrecursive);

      // Update local variable offset
      saveLocVarEvalCount:= locVarEvalCount;
      saveLocVarOffset:= locVarOffset;
      locVarOffset:= locVarOffset+locVarEvalCount;
      locVarEvalCount:= 0;
      locVarEvalLevel:= locVarEvalLevel+1;

      (* Update locvaroffsetstack, used to compensate for locvarnestinglevel
         (see xargblock). *)
      if locVarEvallevel>locvaroffsetstacksize then begin
         if locvarevallevel=locvaroffsetstacksize+1 then
            xProgramError('X(almacro): Up to ' + inttostr(locvaroffsetstacksize) +
            ' calling levels of user defined functions is supported, ' +
            ' but this script would require at least ' +
            inttostr(locvarevallevel) + ' levels of calling depth (2).');
         end
      else locvaroffsetstack[locvarevallevel]:= locVarOffset;

      // Evaluate function
      xevaluate(utstart,eofs,pevalkind,pstateenv,pfuncret);

      // Restore local variable count and offset
      locVarEvalCount:= saveLocVarEvalCount;
      locVarOffset:= saveLocVarOffset;
      locVarEvalLevel:= locVarEvalLevel-1;
      fsdispose(ut);
      end
   else begin
      if containscleanup[pnr] then begin
         fsnew(mac);
         fscopy(mactab[pnr],mac,eofs);
         ins:= mac;
         ut:= pfuncret;
         fylli(dumant,dumandr,dumrecursive);
         fsdispose(mac);
         end
      else begin
         ut:= pfuncret;
         fylli(dumant,dumandr,dumrecursive);
         end;
      end;
   end;

(* Pickup script error when leaving the macro where the script error originated.
   There can be new macro calls before the reaching the end of this macro.
   oldScriptError is used to prevent picking up the error in these, lower level, calls. *)
if scripterror then begin
   if not oldScriptError then begin
      ScriptError:= False;
      alevaluate(pargs,pstateenv,mem,[1..xmaxnarg]); (* (Modified 990306) *)
      xScriptError(scriptErrorMessage);
      end;
   end;

aldispose(pargs,mem);

(* Restore debug mode. *)
iofdebug:= debugsave;

pStateEnv.macnr:= savemacnr;

end; (*almacro*)


function alinmac(pxpos: fsptr): integer;
(* Return number of macro that pxpos points at, or 0 if none found. *)
var nr,lastnr: integer;
begin

nr:= 1;
lastnr:= xgetfreenr;
while (mactab[nr]<>pxpos) and (nr<lastnr) do nr:= nr+1;

if mactab[nr]=pxpos then alinmac:= nr
else alinmac:= 0;

end; (*alinmac*)

procedure alpop( var pargs: xargblock; var pstateenv: xstateenv;
                 pfuncret: fsptr );
(* <pop name,divchar>:
   Pop from a stack. Typical use:
   <set stack,<stack>|<pos>>
   ...
   <in ,<pop stack,|>>
*)
var
mem: alevalmem; divchar: CHAR;
nr: alint16; sp,startsp: fsptr;
a1ptr: fsptr;

begin (*alpop*)

(* alevaluate(pargs,pstateenv,mem,[1,2]); (old)*)
alevaluate(pargs,pstateenv,mem,[2]);
with pargs do begin
   a1ptr:= arg[1];
   nr:= ord(a1ptr^);
   fsforward(a1ptr);
   if (nr=0) and (a1ptr^<>eoa) then begin
      nr:= ord(a1ptr^);
      fsforward(a1ptr);
      nr:= nr*250 + ord(a1ptr^);
      fsforward(a1ptr);
      end;
   if nr=0 then xProgramError('X(alpop): Program error - nr>0 was expected.')
   else if a1ptr^<>eoa then xProgramError('X(alpop): Program error - nr to large.')
   else if integer(mactab[nr])<=alIndexMaxNr then xProgramError('X(alpop): Script error - variable was expected as arg1 but index (name[]) was found.')
   else begin

      divchar:= arg[2]^;
      sp:= mactab[nr]; startsp:= sp;
      (* Start searching from the end of the string. *)
      fsforwendch(sp,eoa);
      while not ((sp^=divchar) or (sp=startsp)) do fsback(sp);
      if sp^=divchar then begin
         fsforward(sp);
         fscopy(sp,pfuncret,eoa);
         fsback(sp);
         fsdelrest(sp);
         end
      else begin
         fscopy(sp,pfuncret,eoa);
         fsdelrest(sp);
         end;
      fspshend(sp,eoa);
      end;
   end; (*with*)

aldispose(pargs,mem);

end; (*alpop*)


procedure alcd( var pargs: xargblock; var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <cd path>:
   Change default directory to path. Typical use:
   <ifeq <cd \öresund\analysprog>,,,Invalid directory!>
   ( cd returns an error code if it fails )
   Cd to internet address (\\...) works but is not supported by
   command. Later call to <command ...> will instead use c:\windows as
   current directory.
*)

var
mem: alevalmem;
s: string; ior: integer;
dir: string;

begin (*alcd*)

if pargs.narg=0 then begin

   // Return current default directory
   getdir(0,dir);
   // Convert to Latin-1
   dir:= ioUni2iso(dir);
   alstrtofs(dir,pfuncret);
   end

else begin

   alevaluate(pargs,pstateenv,mem,[1]);

   s:= xfstostr(pargs.arg[1],eoa);
   s:= ioIso2Uni(s);
   {$I-}
   ChDir(s);
   ior:= IOResult;
   {$I+}
   if ior<>0 then begin
      xScriptError('X: Script error - Unable to change current directory to '+s+' (code '+inttostr(ior)+
         '='+syserrormessage(ior)+').');
      alinttofs(ior,pfuncret);
      end
   else
      // Update if internet address was used (not supported by <command ...> = cmd.exe).
      alCdIsInternetAddress:= AnsiLeftStr(s,2)='\\';

   aldispose(pargs,mem);
   end;

end; (*alcd*)


procedure aldos( var pargs: xargblock; 
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <dos doscommand>:
   - Rarely used - normally replaced by <command ...> -
   Execute a dos command Typical use:
      <dos sort temp1.tmp temp2.tmp>
*)

var
mem: alevalmem;
s: string; r: integer;

begin (*aldos*)

alevaluate(pargs,pstateenv,mem,[1]);

s:= xfstostr(pargs.arg[1],eoa);
r:= WinExec(PChar('command.com /C '+s),SW_SHOWNORMAL);

if r<>0 then alinttofs(r,pfuncret);

aldispose(pargs,mem);

end; (*aldos*)


(* From Torry's Delphi pages: *)
(******************************)
// With ShellExecuteEx:
//*****************************************************


// (new:)
procedure ShellExecute_AndWait1(
   FileName: string; // Example: 'com'
   Params: string; (* Example:
   '/S /C ""x.exe" "<load decodelog> <test pc_simulator.log>"" >cmdres.tmp 2>cmderr.tmp' *)
   ptimeoutms: integer;  // ptimeoutms=0 => No timeout, >0 = max time in ms.
   var pTimeout: boolean // maxtime was spent without finishing program.
   );

var
exInfo: TShellExecuteInfo;
Ph: DWORD;
timePassedMs: cardinal; // (unsigned, hopefully wrap around).
useTimeout: boolean;

begin

pTimeout:= false;
useTimeout:= (ptimeoutms>0);

FillChar(exInfo, SizeOf(exInfo),0);
with exInfo do begin
   cbSize := SizeOf(exInfo);
   fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_DDEWAIT;
   Wnd := GetActiveWindow();
   ExInfo.lpVerb := 'open';
   ExInfo.lpParameters := PChar(Params);
   lpFile := PChar(FileName);
   //nShow := SW_SHOWNORMAL;
   nShow := SW_hide;
   end;

if ShellExecuteExA(@exInfo) then begin
   Ph := exInfo.HProcess;
   timePassedMs:= 0;
   while (WaitForSingleObject(ExInfo.hProcess, 50) <> WAIT_OBJECT_0) and
      ((timePassedMs<=ptimeoutms) or not useTimeout) do begin
      // Application.ProcessMessages;
      timePassedMs:= timePassedMs+50;
      end;

   if useTimeout and (timePassedms>ptimeoutms) then begin
      pTimeout:= true;
      terminateprocess(ph,0);
      end;

   windows.closeHandle(Ph);
   end
else xScriptError('X(shell_execute_andwait1): Unable to start program '+
   filename + ' ' + params +', because "' + SysErrorMessage(GetLastError) + '".');
end; (*ShellExecute_AndWait1*)



(*******************************)

// (new: call processmessages only when in main thread)
function ShellExecute_AndWait2(Operation, FileName, Parameter, Directory: string;
  Show: Word; bWait: Boolean): Longint;
var
  bOK: Boolean;
  Info: TShellExecuteInfo;
  shellresult: longint; // FPC+
(*
  ****** Parameters ******
  Operation:

  edit  Launches an editor and opens the document for editing.
  explore Explores the folder specified by lpFile.
  find Initiates a search starting from the specified directory.
  open Opens the file, folder specified by the lpFile parameter.
  print Prints the document file specified by lpFile.
  properties Displays the file or folder's properties.

  FileName:

  Specifies the name of the file or object on which
  ShellExecuteEx will perform the action specified by the lpVerb parameter.

  Parameter:

  String that contains the application parameters.
  The parameters must be separated by spaces.

  Directory:

  specifies the name of the working directory.
  If this member is not specified, the current directory is used as the working directory.

  Show:

  Flags that specify how an application is to be shown when it is opened.
  It can be one of the SW_ values

  bWait:

  If true, the function waits for the process to terminate
*)
begin
   shellResult:= -1;
   FillChar(Info, SizeOf(Info), char(0));
   Info.cbSize := SizeOf(Info);
   Info.fMask := SEE_MASK_NOCLOSEPROCESS;
   Info.lpVerb := PChar(Operation);
   Info.lpFile := PChar(FileName);
   Info.lpParameters := PChar(Parameter);
   Info.lpDirectory := PChar(Directory);
   Info.nShow := Show;
   bOK := Boolean(ShellExecuteExA(@Info));
   if bOK then begin
      if bWait then begin
         while WaitForSingleObject(Info.hProcess, 100) = WAIT_TIMEOUT do begin
            if alThreadNr = mainThreadId then
               application.processMessages;
            // Earlier (commented way):   
            // If althreadnr=0 then // FPC+
            (*Application.ProcessMessages *);
            end;
         bOK := GetExitCodeProcess(Info.hProcess, DWORD(Result));
         if bOk then shellResult:= 0;
         end
      else shellResult := 0;
   end;
   ShellExecute_AndWait2:= shellResult;
   
end;(* ShellExecuteEx_Andwait2 *)



(* Other shellexecute example:
If ShellExecuteExA( @exInfo ) then begin
    While GetExitCodeProcess( exinfo.hProcess, exitcode )
    and (exitcode = STILL_ACTIVE) and (Scripthalt = False)
    Do begin
       WaitForSingleObject(ExInfo.hProcess,500);
       application.ProcessMessages;
       if scriptHalt
          then terminateProcess(exInfo.hProcess, WM_QUIT);
       end;
    windows.closeHandle( exinfo.hProcess );
    End;
*)

procedure dostoiso(var ps: string);
(* convert from MSDOS extended ascii character code (the swedish part of it),
   used by cmd.exe, to iso-8859. *)
var i: integer;
begin
for i:= 1 to length(ps) do case ps[i] of
   char($FF)(*'ÿ'*): ps[i]:= ' '; //
   char($86)(*'†'*): ps[i]:= char($E5); // 'å'
   char($84)(*'„'*): ps[i]:= char($E4); // 'ä'
   char($94)(*'�?'*): ps[i]:= char($F6); // 'ö'
   char($8F)(* (undef) *): ps[i]:= char($C5); // 'Å'
   char($8E)(*'Ž'*): ps[i]:= char($C4); // 'Ä'
   char($99)(*'™'*): ps[i]:= char($D6); // 'Ö'
   end;
end; (*dostoiso*)



// New version: If error then error message is returned and not ordinary output.
procedure alcommand( var pargs: xargblock;
   pevalkind: xevalkind;
   var pstateenv: xstateenv;
   pfuncret: fsptr );
(* <command command[,timeoutms][,timeoutaction]>:
   Execute a command like in the the Win32 command interpreter.
   Default timeout is 10s (10000ms). Empty timeout = no timeout
   (goes on forever if necessary).
   Default timeoutaction is script error and error message.
   Typical use:
      <command sort temp1.tmp temp2.tmp>
      <command del /Q *.log>
   Uses shellexecute and cmd.exe (windows command interpreter)
*)

var
mem: alevalmem;
arg1,params: string;
getresult, geterrors: boolean;
resfilename,errfilename: string;
resultfile: text;
errorsfile: text;
line,errors,result,dir: string;
ior: integer;
ignoreresult: boolean;
maxtime: integer;
timeout: boolean;



function findunusedtmpfilename(pname: string): string;
var count: integer;
name: string;
begin

name:=sysutils.GetEnvironmentVariable('temp')+'\'+pname+inttostr(getcurrentprocessid);

if not fileexists(name+'.tmp') then
   findunusedtmpfilename:= name+'.tmp'
else begin
   count:= 0;
   while fileexists(name+inttostr(count)+'.tmp') and (count<999) do
      count:= count+1;
   if fileexists(name+inttostr(count)+'.tmp') then begin
      xProgramError('X: X program error - ' +
         'unable to create temporary cmdres or cmderr file because previous ' +
         'tmp files were not successfully removed.');
      findunusedtmpfilename:= '';
      end
   else findunusedtmpfilename:= name+inttostr(count)+'.tmp';
   end;
end; (* findunusedtmpfilename *)

function findunusedtmpfilename0(pname: string): string;
var count: integer;
begin

if not fileexists(pname+'.tmp') then
   findunusedtmpfilename0:= pname+'.tmp'
else begin
   count:= 0;
   while fileexists(pname+inttostr(count)+'.tmp') and (count<999) do
      count:= count+1;
   if fileexists(pname+inttostr(count)+'.tmp') then begin
      xProgramError('X: X program error - ' +
         'unable to create temporary cmdres or cmderr file because previous ' +
         'tmp files were not successfully removed.');
      findunusedtmpfilename0:= '';
      end
   else findunusedtmpfilename0:= pname+inttostr(count)+'.tmp';
   end;
end; (* findunusedtmpfilename0 *)

begin (*alcommand*)

alevaluate(pargs,pstateenv,mem,[1,2]);

if alCdIsInternetAddress then begin
   getDir(0,dir);
   iofshowmess('X(<command ...>): Current working directory ('+dir+') appears to be a network path (starting with "\\") '+
   'This is normally caused by reaching the directory either through "My network places" or by using a shortcut '+
   'where the destination starts with "\\". You can reach the same directory through a mapped drive (path starting '+
   'with a letter followed by a colon, for example "N:") or through a shortcut where the destination start with '+
   'a letter followed by a colon. This is needed for <command ...> to work properly, at least on Windows 7.');
   end;

arg1:= xfstostr(pargs.arg[1],eoa);
params:= '/S /C '+ '"' + arg1 +'"';

(* calculate timeout time. *)
maxtime:= 10000; (* Default *)
with pargs do if narg>1 then begin
   if arg[2]^=eoa then maxtime:= 0 // No timeout

   else begin
      maxtime:= fsposint(arg[2]);
      if maxtime<=0 then begin
         xScriptError('X: Positive integer, or empty arg, was expected expected as arg 2 (timeout ms), but "'+
            alfstostr(arg[2],eoa)+'" was found.');
         maxtime:= 10000;
         end;
      end;
   end;

getresult:= False;
ignoreresult:= false;
geterrors:= False;
resfilename:= findunusedtmpfilename('cmdres');
errfilename:= findunusedtmpfilename('cmderr');

if (resfilename<>'') and not ansicontainsStr(params,' >') then begin
   getresult:= true;
   params:= params + ' >'+resfilename;
   end;

if (errfilename<>'') and not ansicontainsStr(params,' 2>') then begin
   geterrors:= true;
   params:= params + ' 2>'+errfilename;
   end;

shellExecute_andwait1('cmd',params,maxtime,timeout);
if timeout then begin
   if pargs.narg>=3 then
      // Perform timeoutaction
      xevaluate(pargs.arg[3],eoa,pevalkind,pstateenv,pfuncret)

   else xScriptError('X(shell_execute_andwait1): Command was ' +
      'aborted because of timeout.');
   end;


//shellExecute_andwait2('open','cmd',params,'',sw_shownormal,true);

if geterrors then begin
   if timeout then begin
      //Timeout, error file is undetermined.
      if fileexists(resfilename) then deletefile(pChar(resfilename));
      end
   else begin
      assignfile(errorsfile,errfilename);
      (*$I-*) (* Turn off IO error exceptions. *)
      reset(errorsfile);
      ior:= ioresult;
      (*$I+*)
      if ior<>0 then
         xProgramError('X: Program error - Unable to open '+errfilename+' (code '+inttostr(ior)+
            '='+syserrormessage(ior)+').')
      else begin
         if not eof(errorsfile) then begin
            // An error message was returned
            while not eof(errorsfile) do begin
               readln(errorsfile,line);
               errors:= errors + line;
               if not eof(errorsfile) then
                  errors:= errors + char(13);
               end;
            dostoiso(errors);
            (* Return found error string. Start with "2>" to indicate that this is
               error an not result. *)
            alstrtofs('2>' + errors,pfuncret);
            // Skip standard output
            ignoreresult:= true;
            end;
         closefile(errorsfile);
         deletefile(pchar(errfilename));
         end; (* not error from reset *)
      end;(* not timeout *)
   end; (*geterrors*)

if getresult then begin
   if timeout then begin
      //Timeout, result file is undetermined.
      if fileexists(resfilename) then deletefile(pchar(resfilename));
      end
   else begin

      assignfile(resultfile,resfilename);
      (*$I-*) (* Turn off IO error exceptions. *)
      reset(resultfile);
      ior:= ioresult;
      (*$I+*)
      if ior<>0 then
         xProgramError('X: Program error - Unable to open '+resfilename+' (code '+inttostr(ior)+
            '='+syserrormessage(ior)+').')
      else begin
         while not eof(resultfile) do begin
            readln(resultfile,line);
            result:= result + line;
            if not eof(resultfile) then
               result:= result + char(13);
            end;
         dostoiso(result);
         if not ignoreresult then
            alstrtofs(result,pfuncret);
         closefile(resultfile);
         deletefile(pchar(resfilename));
         end; (* not error from reset *)
      end; (* not timeout *)
   end; (*getresult*)

aldispose(pargs,mem);

end; (*alcommand*)


procedure alrun( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <run exefilename parameters>:
   - rarely used - normally replaced by <command ...> -
   Run a program, possibly with parameters.
   Usage example:
      <run N:\STM-N\U - System Verification and Validation\FAT\X-scripts\x.exe
      - "'<load N:\STM-N\U - System Verification and Validation\FAT\X-scripts\decodelog'>
      <run "N:\STM-N\U - System Verification and Validation\FAT\X-scripts\x.exe",
      -"'<load N:\STM-N\U - System Verification and Validation\FAT\X-scripts\decodelog'>>
      -'<test pc_simulator.log',pc_simulator.txt'>">
   Uses shellexecute with open.
*)

var
mem: alevalmem;
arg1,arg2: string;
line,errors,result: string;
ior: integer;

begin (*alrun*)

alevaluate(pargs,pstateenv,mem,[1,2]);

arg1:= xfstostr(pargs.arg[1],eoa);
arg2:= xfstostr(pargs.arg[2],eoa);

shellExecute_andwait2('open',arg1,arg2,'',sw_shownormal,true);
aldispose(pargs,mem);

end; (*alrun*)


procedure alStartProgram( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <startProgram exefilename parameters>:
   Start a program, possibly with parameters, without waiting for it to end.
   Usage example:
      <startProgram N:\STM-N\U - System Verification and Validation\FAT\X-scripts\x.exe
      - "'<load N:\STM-N\U - System Verification and Validation\FAT\X-scripts\decodelog'>
      <startProgram "N:\STM-N\U - System Verification and Validation\FAT\X-scripts\x.exe",
      -"'<load N:\STM-N\U - System Verification and Validation\FAT\X-scripts\decodelog'>>
      -'<test pc_simulator.log',pc_simulator.txt'>">
   Uses shellexecute with open.
*)

var
mem: alevalmem;
arg1,arg2,arg3: string;
error,wait: boolean;

begin (*alStartProgram*)

(* (new:) *)
alevaluate(pargs,pstateenv,mem,[1..3]);

(* (old:) alevaluate(pargs,pstateenv,mem,[1,3]); *)

arg1:= xfstostr(pargs.arg[1],eoa);
arg2:= xfstostr(pargs.arg[2],eoa);
error:= false;
wait:= false;
if pargs.narg>2 then begin
   arg3:= alfstostrlc(pargs.arg[3],eoa);
   if arg3='yes' then wait:= true
   else if arg3='no' then (* - *)
   else if arg3='' then (* - *)
   else begin
      xScriptError('StartProgram: arg 3 = yes or no or empty was expected, but "' +
         arg3 + '" was found.');
      error:= true;
      end;
   end;

if not error then shellExecute_andwait2('open',arg1,arg2,'',sw_shownormal,wait);

aldispose(pargs,mem);

end; (*alStartProgram*)


(* aldate and altime *)
(*********************)

procedure aldate( pfuncret: fsptr );
(* <date>:
   Returns date in format "2018-06-07"
*)

var
present: TDateTime;
day,month,year:	word;

begin (*aldate*)

present:= now;
DecodeDate(present,year,month,day);

fsbitills(year,pfuncret);
fspshend(pfuncret,'-');
if month<10 then fspshend(pfuncret,'0');
fsbitills(month,pfuncret);
fspshend(pfuncret,'-');
if day<10 then fspshend(pfuncret,'0');
fsbitills(day,pfuncret);

end; (*aldate*)


procedure altime( pfuncret: fsptr );
(* <time>:
   Returns current time in format "15:35:42"
*)

var
present: TdateTime;
hour,minute,second: word;
msec: word;

begin (*altime*)

present:= now;
DecodeTime(present,hour,minute,second,msec);
if hour<10 then fspshend(pfuncret,'0');
fsbitills(hour,pfuncret);
fspshend(pfuncret,':');
if minute<10 then fspshend(pfuncret,'0');
fsbitills(minute,pfuncret);
fspshend(pfuncret,':');
if second<10 then fspshend(pfuncret,'0');
fsbitills(second,pfuncret);

end; (*altime*)

procedure alinttofs(pi: longint; var ps: fsptr );
(* Append string(pi) to ps. *)
var s: fsptr; n,d: alint16;
begin
fsnew(s);
if pi<0 then begin
    pi:= -pi;
    fspshend(ps,'-');
    end;
n:= 0;
REPEAT
   d:= pi MOD 10; n:= n+1;
   fspshend(s,CHAR(ORD('0') + d));
   pi:= pi DIV 10;
   UNTIL pi=0;

REPEAT
    fsback(s);
    fspshend(ps,s^);
    n:= n-1;
    UNTIL n=0;

fsdispose(s);
end;

procedure alstrtofs(ps1: string; ps2: fsptr );
(* Append string ps1 to ps2. *)
var i: integer;
begin
for i:= 1 to length(ps1) do fspshend(ps2,ps1[i]);
end; (* alstrtofs *)

(* alSaveIo
   --------
   Save current input and output file numbers.
   Called when in or out is changed the first time after calling a macro
   (<name ...>) or a state (<c ...> or <c_lateevaluation ...>).
   Used to restore io before returning from macro or state.
   Since current in and out only need to be saved once, alSaveIo deletes
   the pointer to the saved record after having saved. (But the
   records itself is addressable in alcall).
*)
procedure alSaveIo;
begin
with alSaveIoPtr^ do begin
   oldInputFileNr:= ioGetInFileNr;
   oldOutputFileNr:= ioGetOutFileNr;
   oldOutString:= xcurrentStateEnv^.outstring;

   oldLastIOWasPersistent:= alLastIOWasPersistent;
   alLastIOWasPersistent:= false;
   end;

alSaveIoPtr:= NIL;

end; (*alSaveIo*)



var optionlist: string=
   'binary, string, local, circularbuffer, restorein, restoreout, client, server, clean';

procedure algetoptions( var pargs:xargblock; var ppos: integer;
                        var poptions: ioOptions;
                        var pprefrole: ioprefroles;
                        var pconfig: string);
(* Get options "binary", "string", "local", "client", "server", "clean" or (number)
   or "baud=... parity=... ..." (for serial ports)
   or "restorein", "restoreout" (do not change in- or out-file) *)
var
a,pos: integer;

begin

ppos:= -1;
poptions:= [];
pprefrole:= ionone;

for a:= 2 to pargs.narg do with pargs do begin

    if (arg[a]^<>eoa) then begin
        if alfstostrlc(arg[a],eoa)='binary' then poptions:= poptions+[ioBinary]
        else if alfstostrlc(arg[a],eoa)='string' then poptions:= poptions+[ioString]
        else if alfstostrlc(arg[a],eoa)='local' then poptions:= poptions+[ioLocal]
        (* (obsolete:) else if alfstostrlc(arg[a],eoa)='persistent' then
         poptions:= poptions+[alPersistent] *)
        else if alfstostrlc(arg[a],eoa)='circularbuffer' then
          poptions:= poptions+[iocircularbuffer]
        else if alfstostrlc(arg[a],eoa)='client' then pprefrole:= ioclient
        else if alfstostrlc(arg[a],eoa)='server' then pprefrole:= ioserver
        else if alfstostrlc(arg[a],eoa)='eofaccept' then poptions:= poptions+[ioEofAccept]
        else if alfstostrlc(arg[a],eoa)='clean' then poptions:= poptions+[ioClean]
        else if alfscontains(arg[a],eoa,'=') then pconfig:= xfstostr(arg[a],eoa)
        else begin
            pos:= fsposint(arg[a]);
            if pos<0 then xScriptError(
               'X: Unable to recognize option "'+ alfstostr100(arg[a],eoa)+
               '", available options are: '+
               optionlist+'.')
            else if ppos<>-1 then xScriptError(
               'X: More than one position specified ('+alfstostr100(arg[a],eoa)+
               ').')
            else ppos:= pos;
            end; (* <> binary, client or server *)
        end; (* <> eoa *)
    end; (* for *)

if [ioBinary,ioString] <= poptions then xScriptError(
   'X: Unable to use both binary and string option at the same time.');

if [iobinary,ioCircularbuffer] <= poptions then xScriptError(
   'X: Unable to use both binary and circularbuffer option at the same time.');

(* (persistent is obsolete:)
if [alLocal,alPersistent] <= poptions then xScriptError(
   'X: "Local" and "Persistent" options were found together but they have '+
   'opposite meaning and can only be used one at a time.');
*)

end; (*algetoptions*)

var
pushfs: fsptr = nil;
popfs: fsptr = nil;

// (new: adding option "clean"
procedure alin( var pargs:xargblock;
                var pstateenv: xstateenv; var pfuncret: fsptr);
(* <in filename>:
   <in filename,pos> <in filename,option>
   <in filename,pos,option> <in ,pos>
   <in domain:portnr> <in domain:portnr,option> <in>
      option can be "binary"
   <in ...,string> ... is a string (not a file name). Input will be taken
      from this string, until leaving the current state.
   <in com1:,baud=19200 parity=n data=8 stop=1> - To open a serial port
   <in com14:baud=115200,createretries=2> - To open bluetooth serial port using
      max 2 create retries (instead of 10) to prevent unnecessary delay if
      the connection is not available.
   <in filename,option1,option2> where option1=string and option2=local -
      Use str as input file in the current state. Input is automatically
      restored after returning from the state (or statemachine).
   Available options are: binary, string, local (obsolete), persistent,
      circularbuffer, client, server, eofaccept, clean (obsolete).
   <in name,circularbuffer> - If name is used for the first time, create a
      circular buffer, which works like a file, except read data may be overwritten
      with new write so that total length is limited to one buffer.
      Name shall a valid filename, and option binary is not implemented for this
      kind of file.
   <in ,eofAccept>(* Acknowledge eof from tcp/ip socket. If connection is
      restored again, it will then again be possible to read data.
   <in> - Return name of current input file.
   *)
var mem: alevalmem;
ior: alint16; pos: ioint32;
options: ioOptions;
prefrole: ioprefroles;
config: string;
currentinfile: fsptr;


begin
if pargs.narg=0 then
    ioinfilename(pfuncret)
else with pargs do begin

    alevaluate(pargs,pstateenv,mem,[1,2,3,4]);

    pos:= -1;
    prefrole:= ionone;
    algetoptions(pargs,pos,options,prefrole,config);
    (* if ioclean in options then
       iofwcons('++ alin('+alfstostr(arg[1],eoa)+','+alfstostr(arg[2],eoa)+'):
       Clean option used.');*)

   if not xFault and (ioString in options) then with pstateenv do begin
      // The input is not a file but a string
      if pstateenv.altnr>0 then xscripterror(
         'X: String option is only allowed in preaction.')
      else if statenr=0 then xScriptError(
         'X: String option can only be used '
         + 'in a called state.')
      else if stringInputPtr<>NIL then xScriptError(
         'X: string option can only be used once'
         + ' in a called state.');
      if not xFault then begin
        iounread(pargs.arg[1],eoa,iounrpush,pstateenv);
        stringInputPtr:= pstateenv.cinp;
        end;
      end // string

    else if not xFault then begin
      // File  input
      if iolocalstring then begin
         fsnew(currentinfile);
         ioinfilename(currentinfile);
         if alfstostrlc(arg[1],eoa) = alfstostrlc(currentinfile,eofs) then
            xProgramError('X (<in ...>): Unable to read from current input file while processing a string '+
            'from <in ...,string,local>.');
         fsdispose(currentinfile);
         end;

      if not xFault then begin

         ioin(arg[1],eoa,options,pos,ioBinary in options,prefrole,config,
            ioCircularbuffer in options,ioEofAccept in options,
            pstateenv.cinp);

         end;(* not xFault *)
      end;

    aldispose(pargs,mem);
    end; (* narg>0 *)
end; (*alin*)





procedure alinpos( var pstateenv: xstateenv; pfuncret: fsptr);
(* <inpos>:
   Returns current position in file or console buffer.
   First position = 0. All other positions are memory addresses.
*)
begin
fsbitills(ioinpos(pstateenv.cinp),pfuncret);
end; (*alinpos*)

procedure aloutpos(pfuncret: fsptr);
(* <outpos>:
   Returns current position in output file or console buffer.
   First position = 0. All other positions are memory addresses
*)
begin
fsbitills(iooutpos,pfuncret);
end; (*aloutpos*)

procedure allinenr(  var pargs:xargblock;
   var pstateenv: xstateenv; pfuncret: fsptr);
(* <linenr>:
   Returns current line in the current input file.
   First line = 1.
*)
var mem: alevalmem; ptr: ioinptr; count: integer;

begin
if pargs.narg=0 then fsbitills(iolinenr(pstateenv.cinp),pfuncret)
else begin (* narg=1*)

   alevaluate(pargs,pstateenv,mem,[1]);
   if alfstostrlc(pargs.arg[1],eoa)='string' then with pstateenv do begin
      ptr:= stringInputPtr;
      count:= 0;
      if ptr<>nil then begin
         (* count number of cr until cinp. *)
         while (ptr<>cinp) and (ptr^<>eofs) do begin
            if ptr^=char(13) then count:= count+1;
            ioinforward(ptr);
            end;

         if ptr<>cinp then
            (* This error message was removed because the part of the
               input string which is before cinp may be overwritten
               through state calls (<c ...>) with <in ...,string>
               that was made from the current state (in which case the
               data following stringInputPtr may not be so reliable anymore).
               The new data ends with eofs which can stop the ptr above
               before reaching cinp. This happened for example when attempting
               to print an error message (<logwchap ...>) in filtersvs:
               makeinitialstate, first alternative, in which both
               <updatepos <p 2>> and <c commands,<p 5>> overwrites
               the data pointed at by stringInputPointer, which caused
               the (now removed) program error to be activated. /BFn 20120229 .*)
            (* xProgramError('alLinenr (string): Program error - cinp ('+
            inttostr(integer(cinp))+') was not found in input string ('+
            inttostr(integer(stringInputPtr))+').');
            *)
         end
      else
         (* Return 0 if not in a string (so that <calc <linenr>+<linenr string>>
            can be used without risk for script error). *)
         ;
      (* (old: else alFault('Script error - <linenr string> can only be used in states where input '+
         'is taken from a string (using <in ...,string>) but in this case this '+
         'appears not to be the case (stringInputPtr=NIL).',xotherfault);*)
      fsbitills(count,pfuncret)
      end
   else xScriptError('<linenr> or <linenr string> was expected but <linenr '+
      alfstostr(pargs.arg[1],eoa)+'> was found.');
   end; (* narg>0 *)

end; (*allinenr*)



procedure alout( var pargs:xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr);
(* <out filename>:
   <out filename,pos> <out filename,option>
   <out filename,option,pos> <out ,pos>
   <out domain:portnr> <out domain:portnr,option>
   <out name,circularbuffer>
   <out ,string>
   <out>
*)
var mem: alevalmem; ior: alint16;
prefrole: ioprefroles; pos: ioint32;
config: string; options: ioOptions;

begin
if pargs.narg=0 then iooutfilename(pfuncret)
else with pargs do begin (* narg>=1*)

   alevaluate(pargs,pstateenv,mem,[1,2,3,4]);

   // Store current args, for use by alOut in error messages
   pstateenv.argsPtr:= @pargs;

   algetoptions(pargs,pos,options,prefrole,config);

   if (iostring in options) and (arg[1]^<>eoa) then
      xScriptError('X: Empty filename '+
         'was expected when option string is used, but "' +
         alfstostr(arg[1],eoa)+ '" was found.');

   if not xFault then begin

      if iostring in options then pstateenv.outstring:= true

      else begin

         ioout(arg[1],eoa,pos,iobinary in options,prefrole,config,
            iocircularbuffer in options,pstateenv.cinp);

         (* (old:)
         if arg[1]^<>eoa then alLastOutWasPersistent:= alPersistent in options;
         *)

         if alflagga('D') then
            iodebugmess('ALOUT: IOR = '+inttostr(IOR));
         if not xFault then pstateenv.outstring:= false;
         end;(* not alstring *)
      end; (* not xFault *)

   aldispose(pargs,mem);
   end;
end; (*alout*)



procedure alclose( var pargs:xargblock;
                   var pstateenv: xstateenv; pfuncret: fsptr);
(* <close filename>:
   <close domain:portnr>
   <close *>
   <close filename,asfilename> (Save output file under other name)
*)
var filename, asfilename: fsptr; mem: alevalmem;
begin
alevaluate(pargs,pstateenv,mem,[1,2]);
fsnew(filename);
fscopy(pargs.arg[1],filename,eoa);
fsnew(asfilename);
if pargs.narg>1 then fscopy(pargs.arg[2],asfilename,eoa);
ioclose(filename,asfilename,pstateenv.cinp);
fsdispose(filename);
fsdispose(asfilename);
aldispose(pargs,mem);
end; (*alclose*)


procedure aldelete( var pargs:xargblock;
                    var pstateenv: xstateenv );
(* <delete filename>:
   <delete domain:portnr>
*)
var filename: fsptr; mem: alevalmem;
begin
alevaluate(pargs,pstateenv,mem,[1]);
fsnew(filename);
fscopy(pargs.arg[1],filename,eoa);
iodelete(filename,pstateenv.cinp);
fsdispose(filename);
aldispose(pargs,mem);
end; (*aldelete*)


procedure alrename( var pargs:xargblock;
                    var pstateenv: xstateenv );
(* <rename filename,filename>:
   <rename domain:portnr,filename>
*)
var filename1,filename2: fsptr; mem: alevalmem;
begin
alevaluate(pargs,pstateenv,mem,[1,2]);
fsnew(filename1);
fsnew(filename2);
fscopy(pargs.arg[1],filename1,eoa);
fscopy(pargs.arg[2],filename2,eoa);
iorename(filename1,filename2,pstateenv.cinp);
fsdispose(filename1);
fsdispose(filename2);
aldispose(pargs,mem);
end; (*alrename*)



procedure alPersistentIO;
(* <persistentIO>:
   (Disables restore of IO after return from function or state.
*)
begin

(* This seems a little contradictory (why saving IO when it shall be persistent,
   but alSaveIo also saves the callers value of alLastIOWasPersistent. If alSaveIO
   is not called here, then it will later, when <in ...> or <out ...> is called,
   save the value True as the callers value of alLastIOWasPersistent (which then
   actually would be the local value). *)
if (alSaveIoPtr<>nil) then alSaveIo;

alLastIOWasPersistent:= true;
end;


procedure alUniqueFileName(pfuncret: fsptr);
(* <uniqueFileName>:
   (Creates and returns a file name, intended for temporary usage, that is
   guaranteed different from other file names. Also, it is not saved on disk
   unless explicitly by <close ...>.
   Names are on format "tf#n", where n is a number.
*)
(* <tempFileName>: Obsolete name for <uniqueFileName>. Use <uniquefilename> instead.
   This function has been renamed to <uniqueFilename> which better
   describes what it does.
   The old name is only to be supported for a limited period of time.
*)
var
found: boolean;
i: integer;

begin

ioUniqueFileName(pfuncret);

end;// (alUniqueFileName)


procedure alunread( var pargs: xargblock;

                    var pstateenv: xstateenv );
(* <unread str>:
   Unread a string to an unread buffer
   <unread> - go back to previous position (before ?"..."?)

   <unread str> and <unread> are implemented quite differently.
   <unread str> puts str in an unread buffer and
   moves the input pointer to the beginning of this string (which
   is connected to the regular input file so it is like
   inserting a string in the regular input file.
   <unread> only moves the input pointer to where it were before
   reading the last ?"..."?.
*)
var mem: alevalmem;
begin
alevaluate(pargs,pstateenv,mem,[1]);
if pargs.narg=0 then begin
   (* <unread> *)
   if pstateenv.inpback=NIL then
      xProgramError('X(<unread>): <unread> is invalid because the input string is located ' +
      'in the unread buffer (either through <unread ...> or <in ...,string,local)'+
      'and other state(s) have been called which may change this area.')
   else
      iounread(nil,eoa,iounrnormal,pstateenv);
   end
else begin
   // Normal <unread ...>
   if xunr.active then xunr.unrUnread(pargs.arg[1],eoa,pstateenv)
   else iounread(pargs.arg[1],eoa,iounrnormal,pstateenv);
   end;

aldispose(pargs,mem);
end; (*alunread*)

var
eofLoopCnt: integer = 0;
eofLoopAction: fsptr = NIL;

procedure alselectInput( var pargs: xargblock;
                    pevalkind: xevalkind; (* Tells xevaluate what to do
                                            with the stuff (see
                                            xevaluate). *)
                    var pstateenv: xstateenv; pfuncret: fsptr );
(* <select file1,action1[,file2,action2[,...]],timeoutms,defaultaction>:
   waits until file 1..n has readable data available.
   It then opens that file and executes the corresponding action.
   Default timeout is no timeout. Empty timeout is also no timeout.
   Defaultaction is performed if no input is received and
   timeoutms milliseconds has passed.
   File can be a file, a socket, a serial port or empty. If file is empty,
   then it is not used for waiting. This can be used to dynamically select
   which files to wait for.
*)

var
mem: alevalmem;
ftab: iofilenametab;
atab: array[1..IoMaxSelectSources] of integer;
argnr: integer;
i: integer;
fnr,n: integer;
eset: alevalset;
config: string;
timeoutms: integer;
timeoutcase: integer;
infilesave: fsptr;
oldCinp: fsptr;
selectFileName: fsptr;

begin

(* 0. Check that number of arguments is even (default case shall have
   an empty file parameter). *)
if odd(pargs.narg) then
   xScriptError('X: Select statement expects even number of arguments '
      + '- n pairs of file,action and an optional pair of timeout,timeoutaction. '
      + '(Example: <select localhost:3000,<read *>,,<wcons End of file.>>).')

else with pargs do begin
   eset:= [];
   timeoutms:= maxint;
   timeoutcase:= 0;

   (* 1. Evaluate all odd arguments (filenames). *)
   for i:= 1 to pargs.narg do if odd(i) then eset:= eset + [i];
   alevaluate(pargs,pstateenv,mem,eset);

   // 2. Put all odd arguments (filenames) in ftab.
   fnr:= 0;
   with pargs do for i:= 1 to narg do if odd(i) then begin
      (* (new:) *)
      if i=narg-1 then begin
         (* Last two args are timeout (ms) and timeout action. *)
         if arg[i]^=eoa then begin
            (* timeout = no timeout *)
            timeoutms:= maxint;
            timeoutcase:= narg;
            end
         else if fsposint(arg[i])>=0 then begin
            (* timeout milliseonds *)
            timeoutms:= fsposint(arg[i]);
            timeoutcase:= narg;
            end
         else
            xScriptError('X: <select ...> expected timeout (next to last arg) '+
               'to be empty or contain a number, but found instead '+
               alfstostr(arg[i],eoa)+'.')
         end

      else if arg[i]^<>eoa then begin
         (* Put in table *)
         fnr:= fnr+1;
         ftab[fnr]:= arg[i];
         atab[fnr]:= i+1;
         end;

      end;

   // 3. Wait for input data
   n:= ioselect(pstateenv.cinp,ftab,fnr,eoa,timeoutms);

   if n>0 then begin

      // 4a. Save old file name
      fsnew(infilesave);
      ioinfilename(infilesave);

      // 4. Open selected file
      config:= '';
      ioin(ftab[n],eoa,[],-1,false,ionone,config,false,false,pstateenv.cinp);

      // 5. Prepare for loop detection by saving old input pointer
      oldCinp:= pstateenv.cinp;

      // 6. Do selected action
      argnr:= atab[n];
      if pargs.narg-2>=argnr then
         xevaluate(pargs.arg[argnr],eoa,pevalkind,pstateenv,pfuncret)
      else
         xProgramError('alselectInput: argnr was expected to be less or equal '+
            'to number of args ('+inttostr(pargs.narg)+') less two, but it was '+
            inttostr(argnr)+'.');

      // 7a. Loop detection
      if pstateenv.cinp = oldCinp then begin
         // input pointer has not moved
         // Selected file was a disconnected (tcp/ip) connection
         if pstateenv.cinp^ = eofs then begin
            // still eofs (disconnected tcp/ip connection)
            if eofLoopCnt = 0 then begin
               // Start loop counting
               eofLoopCnt:= 1;
               eofloopAction:= pargs.arg[argnr];
               end // eofLoopCnt=0
            else begin
               // Check that it is the same select call and the same action
               if pargs.arg[argnr] = eofloopAction then begin
                  // Count to 100
                  eofLoopCnt:= eofLoopCnt+1;
                  if eofLoopCnt = 100 then begin
                     // Loop detected
                     fsnew(selectFilename);
                     ioinfilename(selectFilename);
                     xScriptError('X(<select ...>): Presumably eternal loop was ' +
                        'detected, eof was read 100 times in a row, from file "'+
                        xfstostr(ftab[n],eoa) +
                        '". A possible cause for this is when a tcp/ip '+
                        'connection is disconnected from the other side, ' +
                        'but the script activated by select does not notice this.');
                      eofLoopCnt:= 0;
                      eofLoopAction:= NIL;
                      end;
                   end;
               end;// eofLoopCnt>0
            end // pstateenv.cinp = eofs
         end; //cinp has not moved

      // 7b. Reset loop detection when loop is broken
      if eofLoopCnt>0 then begin
         if pargs.arg[argnr] = eofLoopAction then begin
            // Same select statement and same action
            (* Reset loop counter if pointer has moved or if it does no
               longer point at eofs. *)
            if (pstateenv.cinp <> oldCinp) or (pstateenv.cinp^<>eofs) then begin
               (* Pointer has not moved, or no longer points at eofs. The latter
                  might be impossible, but assume anyway that the loop is broken. *)
               eofLoopCnt:= 0;
               eofLoopAction:= NIL;
               end;
            end;
         end;

      // 8. Restore old input file
      ioin(infilesave,eofs,[],-1,false,ionone,config,false,false,pstateenv.cinp);

      fsdispose(infilesave);
      end // n>0

   else if timeoutcase>0 then
      // timeout/default case
      xevaluate(pargs.arg[timeoutcase],eoa,pevalkind,pstateenv,pfuncret);

   aldispose(pargs,mem);

   end;// (with pargs)

end; (*alselectInput*)


(* Excel OLE interface *)
(* =================== *)
(* For information about how to use Excel through the OLE interface.
   See:
   * https://wiki.freepascal.org/Office_Automation#Reading.2FWriting_an_Excel_file_using_OLE

*)

var
  ExcelApp: OleVariant; (* Excel application. *)
  columnIndex: Tstringlist = nil;
  rowIndex: Tstringlist = nil;


procedure excelCreateIndexes;
  var i: integer;
begin

try
  (* Create indexes for rows and columns. *)

  if rowindex=nil then rowindex:= Tstringlist.create
  else rowindex.clear;

  // To make tstring indexes equal to excel indexes:
  rowindex.Add('Dummy0');
  rowindex.Add('Dummy1');
  i:= 2;
  while not ((string(ExcelApp.Cells[i,1].value)='')) do begin
    rowindex.Add(string(ExcelApp.Cells[i,1].value));
    i:= i+1;
    end;

  if columnindex=nil then columnindex:= Tstringlist.create
  else columnindex.clear;
  // To make tstring indexes equal to excel indexes:
  columnindex.Add('Dummy0');
  i:= 1;
  while not ((string(ExcelApp.Cells[1,i].value)='')) do begin
    columnindex.Add(string(ExcelApp.Cells[1,i].value));
    i:= i+1;
    end;
  except
    xProgramError('excelCreateIndexes: Error from excel.');
    exit;
  end;

end; (*excelCreateIndexes*)

var coInitDone: boolean = false;

procedure coInit;
begin
if not coInitDone then begin
   CoInitializeEx(nil, 0);
   coInitDone:= true;
   end;
end;



procedure excelOpen(pfilename: string; pvisible: boolean);
var filename: widestring;
begin
  coInit;
  // By using GetActiveOleObject, you use an instance of Excel that's already running,
  // if there is one.
  try

      ExcelApp := GetActiveOleObject('Excel.Application');
  except
    try
      // If no instance of Word is running, try to Create a new Excel Object
      ExcelApp := CreateOleObject('Excel.Application');
    except
      xScriptError('<excel open,...>: Cannot start Excel/Excel not installed ?');
      Exit;
    end;
  end;

  ExcelApp.Visible:= pvisible;
  try
    // ExcelApp.Workbooks.Open('U:\Working\X-Compiler\X-Fpc\test.xlsx');
    filename:= UTF8Decode(pfilename);
    ExcelApp.Workbooks.Open(filename);
    except
      xScriptError('<excel open,...>: Unable to open file "'+pfilename+'".');
      Exit;
    end;

  excelCreateIndexes;

end; (*excelOpen*)

procedure excelSelect(psheetname:string);
  var sheets: olevariant;
begin
try
  (* Select sheet *)
  Sheets := ExcelApp.Sheets;
  Sheets.Item[psheetname].Activate;

  except
    xScriptError('<excel select,...>: Unable to select sheet '+psheetname+'".');
    exit;
    end;

  (* Create indexes for rows and columns. *)
  excelCreateIndexes;

end; (*excelSelect*)

function excelget(prow,pcolumn: string): string;
  var row,column: integer;
begin

try
  row:= rowindex.indexof(prow);
  if row=-1 then xScriptError('Excel: Unable to find row "'+prow+'".');
  column:= columnindex.IndexOf(pcolumn);
  if column=-1 then xScriptError('Excel: Unable to find column "'+pcolumn+'".');
  if (row=-1) or (column=-1) then
    excelGet:= ''
  else
    excelGet:= string(ExcelApp.Cells[row,column].value);
  except
    xScriptError('<excel get,...>: Unable to get '+prow+','+pcolumn+'.');
    end;
end;(*excelGet*)

procedure excelSet(prow,pcolumn,pvalue: string);
  var row,column: integer;
begin
try
  row:= rowindex.indexof(prow);
  if row=-1 then iofshowmess('Excel setvalue: Unable to find row "'+prow+'".');
  column:= columnindex.IndexOf(pcolumn);
  if column=-1 then iofshowmess('Excel setvalue: Unable to find column "'+pcolumn+'".');
  if (row>-1) and (column>-1) then
    ExcelApp.Cells[row,column].value:= pvalue;
  except
    xScriptError('<excel set,...>: Unable to set '+prow+','+pcolumn+' to '+pvalue+'.');
    end;

end;(* excelSet *)

procedure excelSave;
begin
if not VarIsEmpty(ExcelApp) then ExcelApp.Save;
end; (*excelSave*)

(* Example:
   <excel saveas,,.csv>.
*)
procedure excelSaveAs(pfilename: string; pfiletype:fsptr);
var
filename: widestring;
filetype: string;
filetypenr: integer;
begin
if not VarIsEmpty(ExcelApp) then

   (* Filename. *)
   if pfilename<>'' then filename:= UTF8Decode(pfilename)
   else filename:= ExcelApp.WorkBooks[1].name;

   (* Filetype. *)
   filetypenr:= 0;
   if pfiletype^<>eoa then begin
      // Filetype is specified
      filetypenr:= fsposint(pfiletype);
      if filetypenr<0 then begin
         if alfstostrlc(pfiletype,eoa)='.csv' then filetypenr:= 6
         else xscripterror('Expected filetype as number (according to ' +
            'https://docs.microsoft.com/en-us/office/vba/api/excel.xlfileformat) '+
            'or ".csv" but found "' + alfstostr(pfiletype,eoa) + '".');
         end;
      end;
   if not xFault then begin
      if pfilename<>'' then ExcelApp.Workbooks[1].SaveAs(filename,filetypenr)
      else ExcelApp.Workbooks[1].SaveAs(,filetypenr);
      end;

   //ExcelApp.SaveAs('U:\Working\X-Compiler\X-Fpc\Test.csv','xlCSV');
end; (*excelSaveAs*)


procedure excelClose;
begin
if not VarIsEmpty(ExcelApp) then begin
    ExcelApp.DisplayAlerts := False;  // Discard unsaved files....
    ExcelApp.Quit;
    end;
end; (*excelClose*)


procedure alExcel( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <excel open,filename[,yes]>:
      Start excel and open excel file filename (add ",yes" to make it visible)
   <excel select,sheetname> - Select sheet sheetname as active sheed
   <excel get,row,column> - Get value from table using row and column indexes
   <excel set,row,column> - Set value in table using row and column indexes
   <excel save> - File/save
   <excel saveAs,filename[,filetype]> - File/saveAs
   <excel close> - File/close

   Example of table with row and column indexes:
   employee  name  address salary
   2          Hans  Visby   10000
   5         Diana  Sunne   12000
   11        Sigvard Norsborg 9000

   <excel get,5,address> returns "Sunne"
*)

var
mem: alevalmem;
arg2,arg3,arg4: string;

begin
alevaluate(pargs,pstateenv,mem,[1..pargs.narg]);

with pargs do begin

   if narg>=2 then arg2:= xfstostr(arg[2],eoa);
   if narg>=3 then arg3:= xfstostr(arg[3],eoa);
   if narg>=4 then arg4:= xfstostr(arg[4],eoa);

   if (alfstostrlc(arg[1],eoa)='open') then begin

      if (narg=2) then excelOpen(arg2,false)
      else if narg=3 then begin
         if (alfstostrlc(arg[3],eoa)='yes') then excelOpen(arg2,true)
         else if (alfstostrlc(arg[3],eoa)='no') then excelOpen(arg2,false)
         else xscripterror('Arg3 (=visible) = "yes" or "no" was expected but "' +
            alfstostrlc(arg[3],eoa) + '" was found.');
         end;
      end

   else if (alfstostrlc(arg[1],eoa)='select') and (narg=2) then excelSelect(arg2)
   else if (alfstostrlc(arg[1],eoa)='get') and (narg=3) then
      alstrtofs(excelGet(arg2,arg3),pfuncret)
   else if (alfstostrlc(arg[1],eoa)='set') and (narg=4) then excelSet(arg2,arg3,arg4)
   else if (alfstostrlc(arg[1],eoa)='save') and (narg=1) then excelSave
   else if (alfstostrlc(arg[1],eoa)='saveas') and (narg=2) then excelSaveAs(arg2,'')
   else if (alfstostrlc(arg[1],eoa)='saveas') and (narg=3) then excelSaveAs(arg2,arg[3])
   else if (alfstostrlc(arg[1],eoa)='close') and (narg=1) then excelClose
   else xScriptError('<excel ...>: Unable to decode command.');
   end;

aldispose(pargs,mem);
end; (*alExcel*)



(* msWord OLE interface *)
(* =================== *)
var
  WordApp: OleVariant; (* Word application. *)
  WordDoc: OleVariant;

procedure WordOpen(pfilename: string);
begin
   coInit;
  // By using GetActiveOleObject, you use an instance of msWord that's already running,
  // if there is one.
  try
    WordApp := GetActiveOleObject('Word.Application');
  except
    try
      // If no instance of Word is running, try to Create a new Word Object
      WordApp := CreateOleObject('Word.Application');
    except
      xScriptError('<msWord open,...>: Cannot start Word/Word not installed ?');
      Exit;
    end;
  end;

  WordApp.Visible:= True;
  try
    WordDoc:= WordApp.Documents.Open(pfilename);
    except
      xScriptError('<msWord open,...>: Unable to open file "'+pfilename+'".');
      Exit;
    end;

end; (*WordOpen*)

procedure WordSave;
begin
if not VarIsEmpty(WordApp) then WordApp.documents.Save;
end; (*WordSave*)

procedure WordSaveAs(pfilename: string; pType: integer);
begin
if not VarIsEmpty(WordApp) then begin

  try
   //wordApp.documents.SaveAs(FileName:=pfilename, AddToRecentFiles:= False);
   wordDoc.SaveAs(pfilename, pType);
    except
      xScriptError('<msWord saveas,...>: Unable to save file as "'+pfilename+'".');
      Exit;
    end;
  end;

end; (*WordSaveAs*)

procedure WordClose;
begin
if not VarIsEmpty(WordApp) then begin
    WordApp.DisplayAlerts := False;  // Discard unsaved files....
    WordApp.Quit;
    end;
end; (*WordClose*)


procedure almsWord( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <msWord open,filename>:
    - Start Word and open Word file filename
   <msWord save> - File/save
   <msWord saveAs,filename[,filetype]> - File/saveAs
   <msWord close> - File/close
*)

var
mem: alevalmem;
arg2,arg3,arg4: string;
wdtype: integer;

begin
alevaluate(pargs,pstateenv,mem,[1..pargs.narg]);

with pargs do begin

    if narg>=2 then arg2:= xfstostr(arg[2],eoa);
    if narg>=3 then arg3:= xfstostr(arg[3],eoa);
    if narg>=4 then arg4:= xfstostr(arg[4],eoa);

    if (alfstostrlc(arg[1],eoa)='open') and (narg=2) then WordOpen(arg2)
    else if (alfstostrlc(arg[1],eoa)='save') and (narg=1) then WordSave
    else if (alfstostrlc(arg[1],eoa)='saveas') and ((narg=2) or (narg=3)) then begin
      wdtype:= 0;
      if narg=3 then begin
         if (alfstostrlc(arg[3],eoa)='document') then wdtype:= 0
         else if (alfstostrlc(arg[3],eoa)='document97') then wdtype:= 0
         else if (alfstostrlc(arg[3],eoa)='text') then wdtype:= 2
         else if (alfstostrlc(arg[3],eoa)='textlinebreaks') then wdtype:= 3
         else if (alfstostrlc(arg[3],eoa)='dostext') then wdtype:= 4
         else if (alfstostrlc(arg[3],eoa)='dostextlinebreaks') then wdtype:= 5
         else if (alfstostrlc(arg[3],eoa)='rtf') then wdtype:= 6
         else if (alfstostrlc(arg[3],eoa)='unicodetext') then wdtype:= 7
         else if (alfstostrlc(arg[3],eoa)='html') then wdtype:= 8
         // (Some types missing here ...)
         else if (alfstostrlc(arg[3],eoa)='pdf') then wdtype:= 17
         else begin
            wdtype:= fsposint(pargs.arg[1]);
            if wdtype<0 then
               xScriptError('X(<msword saveas,type>): Expected '+
               'type "document", "document97", "text", "textlinebreaks", '+
               '"dostext", "dostextlinebreaks", "rtf", "unicodetext", "html", '+
               '"pdf", or an integer but found '+ alfstostr100(pargs.arg[2],eoa)+
               '".')
            end;
         end;

      if wdtype>=0 then WordSaveAs(arg2,wdtype);
      end
    else if (alfstostrlc(arg[1],eoa)='close') and (narg=1) then WordClose
    else xScriptError('<msWord ...>: Unable to decode command.');
    end;

aldispose(pargs,mem);
end; (*almsWord*)



function greaterThanNumerical(List: TStringList; Index1, Index2: Integer): Integer;
var
  Tmp1,
  Tmp2: string;
  len1,len2,numlen1,numlen2,minlen,i: integer;
  finished: boolean;
  res: integer;
begin
   res:= 0;
   Tmp1:=List[Index1];
   Tmp2:=List[Index2];
   len1:= length(tmp1);
   len2:= length(tmp2);
   if (Length(Tmp1) >= 1) and (Length(Tmp2) >= 1) then begin
      if (tmp1[1] in ['0'..'9']) and (tmp2[1] in ['0'..'9']) then begin
         numlen1:= 1;
         finished:= false;
         repeat
            if numlen1=len1 then finished:= true
            else begin
               numlen1:= numlen1+1;
               if not (tmp1[numlen1] in ['0'..'9']) then begin
                  finished:= true;
                  numlen1:= numlen1-1;
                  end;
               end;
            until finished;
         numlen2:= 1;
         finished:= false;
         repeat
            if numlen2=len2 then finished:= true
            else begin
               numlen2:= numlen2+1;
               if not (tmp2[numlen2] in ['0'..'9']) then begin
                  finished:= true;
                  numlen2:= numlen2-1;
                  end;
               end;
            until finished;
         if numlen1>numlen2 then res:= 1
         else if numlen2>numlen1 then res:= -1
         end;(* tmp1[1] and tmp[2] in '0'..'9' *)
      end;(* len1 and len2 >=1 *)

   if res=0 then begin
      // Perform normal sort.
      minlen:= len1;
      if len2<minlen then minlen:= len2;
      i:= 1;
      finished:= false;
      while (i<=minlen) and (res=0) do begin
         res:=ansiCompareText(Tmp1[i], Tmp2[i]);
         i:= i+1;
         end;

      // If still equal, compare length
      if res=0 then begin
         if len1>len2 then res:= 1
         else if len2>len1 then res:= -1;
         end;
      end;

   result:= res;

end;(* greaterThanNumerical *)


function greaterThanCombi(List: TStringList; Index1, Index2: Integer): Integer;
(* This function is a combination between numerical and alphabetical sorting,
   The only difference, compared to alphabetical sorting, is that numbers
   are valued higher than letters.
   Example:
   "1234abc" > "123abc"
   *)
var
  Tmp1,
  Tmp2: string;
  len1,len2,len:  integer;
  finished: boolean;
  res, resDigit: integer;
  ix: integer;
  ch1, ch2: char;
begin
   res:= 0;
   Tmp1:=List[Index1];
   Tmp2:=List[Index2];
   len1:= length(tmp1);
   len2:= length(tmp2);
   // len is the shortest of len1 and len2
   if len1<len2 then len:= len1 else len:= len2;
   ix:= 1;
   resDigit:= 0; // resDigit is a temporary result for comparing numbers.
   while (ix<=len) and (res=0) do begin
      ch1:= tmp1[ix];
      ch2:= tmp2[ix];
      if ch1=ch2 then begin
         (* ch1=ch2. Stop if there is a preliminary result in resDigit and
            they are not digits. *)
         if resDigit<>0 then begin
            if not (ch1 in ['0'..'9']) then res:= resDigit;
            end;
         end
      else begin
         if ch1 in ['0'..'9'] then begin
            (* ch1 is digit. *)
            if (ch2 in ['0'..'9']) then begin
               (* Both are digits, and they are different. *)
               if resDigit=0 then begin
                  if integer(ch1)>integer(ch2) then resDigit:= 1 else resDigit:= -1;
                  end;
               end
            else begin
               (* ch1 is digit but not ch2. Digit>letter. *)
               res:= 1;
               end;
            end
         else begin
            (* ch1 is not digit. *)
            if (ch2 in ['0'..'9']) then begin
               (* ch2 is digit but not ch1. Digit>letter. *)
               res:= -1;
               end
            else begin
               (* ch1 and ch2 are non-digits and different. *)
               if resDigit<>0 then res:= resDigit
               else begin
                  (* Perform standard comparison. *)
                  res:= ansiCompareText(ch1, ch2);
                  end;
               end;
            end;(* ch1 is not a digit. *)
         end; (* ch1 != ch2 *)
      ix:= ix+1;
      end; (* while *)

   if res=0 then begin
      (* Let longer strings be higher than shorter when the same otherwise,
         so that the shorter string, that is the beginning of a longer string,
         comes before the longer string. *)
      if len1>len2 then res:= 1
      else if len1<len2 then res:= -1;
      end;

   result:= res;

end;(* greaterThanCombi *)

function lessThanCombi(List: TStringList; Index1, Index2: Integer): Integer;
(* This function like greaterThanCombi, but sorts in decending order
instead of ascending
   Example:
   "124abc" < "123abc"
   "1234abc" < "123abc"
   *)
begin
   result:= -greaterThanCombi(List,Index1,Index2);
end;(* lessThanCombi *)

procedure alSort( var pargs: xargblock);
(* <sort $table[,numerical/combi/combiDescending]>:
   Sort table according to its indexes.
   The sorting method "combi" (or combiDescending) is recommended.
   It combines alphabetical sorting with numerical. When there are numbers,
   longer numbers are sorted as larger than shorter numbers.

   Example:
   <var $tab[]>
   <set $tab[],5:a|4:b|3:c>
   <sort $tab,combi> => $tab = "3:c|4:b|5:a"
   <sort $tab,combiDescending> => $tab = "5:a|4:b|3:c"

   How "combi" works:
   "abc1234" > "abc124"

   Example:
   <set $tab,abc124:1|abc1234:2>
   <sort $tab>
   => $tab = abc1234:2|abc124:1
   <sort $tab,combi>
   => $tab = abc124:1|abc1234:2
*)

var a1ptr: fsPtr;
result: boolean;
nr,ixnr: integer;
arg2: string;
begin
   result:= false;
   a1Ptr:= pargs.arg[1];
   if a1Ptr^=char(xstan) then begin
      fsforward(a1Ptr);
      nr:= integer(a1Ptr^);
      if nr=0 then begin
         fsforward(a1Ptr);
         nr:= integer(a1Ptr^);
         fsforward(a1Ptr);
         nr:= nr*250 + integer(a1Ptr^);
         end;
      ixnr:= integer(mactab[nr]);
      fsforward(a1Ptr); // (lvnestlevel)
      fsforward(a1Ptr); // (eoa)

      if a1Ptr^=eoa then begin
         if (ixnr>0) and (ixnr<=alIndexMaxNr) then begin
            result:= true;
            if (pargs.narg>1) and (pargs.arg[2]^<>eoa) then begin
               arg2:= alfstostrlc(pargs.arg[2],eoa);
               if arg2='numerical' then stringtab[ixnr].CustomSort(greaterThanNumerical)
               else if arg2='combi' then stringtab[ixnr].CustomSort(greaterThanCombi)
               else if arg2='combidescending' then stringtab[ixnr].CustomSort(lessThanCombi)
               else xScriptError('alSort: Expected no arg2 or "numerical" as arg2 '+
                  'but found "'+alfstostr(pargs.arg[2],eoa)+'".');
               end
            else stringtab[ixnr].Sort;
            end;
         end;
      end;

   if not result then xProgramError('alSort: $name, where name was a table was expected, but '+alfstoStr100(pargs.arg[1],eoa)+' was found.');
end; (*alSort*)


procedure alNameAs( var pargs: xargblock; var pstateenv: xstateenv);
(* <nameas str>:
   Give an x-file group a different name than its file name.
   E.g. an x file is named util-1.x but functions in it shall be adressed
   (from other x-files) as "<util.func ...>". This can be done
   by inserting the command <nameAs util> on top level in the file util-1.x.
*)
var mem: alevalmem;
begin
alevaluate(pargs,pstateenv,mem,[1]);

xnameas(alfstostr(pargs.arg[1],eoa));

aldispose(pargs,mem);
end; (* alNameAs *)


procedure alReplaceWith( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <replacewith str>:
   Replace last ?"..."? in input file with str. This can be used
   to convert a file at the same time as it is being read.
*)

var
s: fsptr;
error: boolean;

begin

iocheckcinp(pstateenv);

(* Force evaluation because ioreplacewith requires string ended by eofs. *)
fsnew(s);
xevaluate(pargs.arg[1],eoa,xevalnormal,pstateenv,s);

ioreplacewith(s,pstateenv);

iocheckcinp(pstateenv);

fsdispose(s);

// Invalidate <p n>
pstateenv.pars.invalidBecauseOfRpw:= true;

end; (*alReplaceWith*)

procedure alprogtest( var pargs: xargblock;
                    var pstateenv: xstateenv);
(* <progtest fs/io/x>:
   - (only for internal X development work) -
   Call a test procedure.
*)
var mem: alevalmem; str: string;
begin
alevaluate(pargs,pstateenv,mem,[1]);
str:= alfstostrlc(pargs.arg[1],eoa);
if str='fs' then fstest
else if str='io' then iotest
else if str='x' then xtest(false)
else xScriptError('<progtest ...>: Unknown argument: "'+str+'" (should be fs, io or x).');
aldispose(pargs,mem);
end;

var
useDefForFunction: boolean = true;
statesInGroupsVisible: boolean = true;

dllCallLogTo: boolean = false;
dllCallLogToFileName: string = '';
dllCallLogToFile: textfile;

// Function to trace all calls to a certain file.
traceCallsTo: integer;


procedure initsettings;
(* Default values of all settings (configured using the function
   <settings ...>). *)
(* BFn 170318: Many of these initialisations are doubled in other
   places (at variable declaration and in xxInit procedure).
   Remove these initialisations, to avoid redundancy. But
   this will require some regression testing. *)

begin
alAllowBlanksBeforeCommentToEoln:= true;
alAllowFunctionCallsAfterPreact:= false;
xAllowJumpsBetweenNormalStates:= true;
allowNewlineInBinaryInput:= true;
alcasewarning:= true;
alCheckUnreadPosAtExit:= false;
xcheckvar:= false;
alCompileAlts:= true;
ShowWindow(iofCurrentFormHandle,sw_shownormal);
dllCallLogToFileName:= '';
dllCallLogTo:= false;
iomsgboxtooutputwindow:= false;
xlinecommentasblank:= false;
xcommentasblank:= ' ';
xoptcrfile:= ' ';
restoreioaftermacro:= false;
xSameParentRequiredForJump:= false;
xlinecomment:= false;
xskipcomment:= ' ';
statesInGroupsVisible:= true;
iosuppressbadcharmessage:= false;
iofDefaultOutPut:= 0;
useDefForFunction:= true;
xUseIndentation:= false;
traceCallsTo:= 0;
end; // (initSettings)


procedure alsettings( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <settings option[,value]>:
   Set up X option.
   <settings allowBlanksBeforeCommentToEoln,[yes/no]> (x-file local)
   <settings allowFunctionCallsAfterPreact[,yes/no]> (x-file local)
   <settings AllowJumpsBetweenNormalStates[,yes/no]>
   <settings AllowNewlineInBinaryInput[,yes/no]>
   <settings casewarning[,yes/no]>
   <settings checkvar[,yes/no]> (x-file local)
   <settings compileAlts[,yes/no]> (x-file local)
   <settings dllCallLogTo[,filename]>
   <settings filechangewarning[,yes/no]>
   <settings formvisible[,yes/no]>
   <settings msgboxtooutputwindow[,yes/no]>
   <settings prelDefWithNarg[,yes/no]>
   <settings regardcommentasblank[,Ada/Pascal/C/;/no]>
   <settings regardCrAsBlank[,yes/no]>
   <settings restoreioaftermacro[,yes/no]>
   <settings SameParentRequiredForJump[,yes/no]>
   <settings skipcomment[,Ada/Pascal/C/;/no]>
   <settings statesInGroupsVisible[,yes/no]> (old - apparently not in use)
   <settings suppressbadcharmessage[,yes/no]>
   <settings tracecallsto[,xfilename-w/o-.x]>
   <settings unractive[,yes/no]>
   <settings useasoutput[,handle]>
   <settings usedefforfunction[,yes]>
   <settings useindentation[,yes/no]> (x-file local)

   x-file local means settings is valid only in the x-file where the
   <setting ...> call is used. In all other x-files default values are
   used.
*)
var mem: alevalmem; str1,str2: string;
style: integer;
handle: integer;
cnt,nr: integer;
kind: xgroupkindtype;

procedure returnsetting(pname: string; pvalue: boolean);
begin
   if cnt>0 then alstrtofs(char(13),pfuncret);
   cnt:= cnt+1;
   alstrtofs(pname,pfuncret);
   alstrtofs(' = ',pfuncret);
   if pvalue then alstrtofs('yes',pfuncret) else alstrtofs('no',pfuncret);
end;

procedure returnsettingInt(pname: string; pvalue: integer);
begin
   if cnt>0 then alstrtofs(char(13),pfuncret);
   cnt:= cnt+1;
   alstrtofs(pname,pfuncret);
   alstrtofs(' = ',pfuncret);
   fsbitills(pvalue,pfuncret);
end;

procedure returnsettingStr(pname: string; pvalue: string);
begin
   if cnt>0 then alstrtofs(char(13),pfuncret);
   cnt:= cnt+1;
   alstrtofs(pname,pfuncret);
   alstrtofs(' = ',pfuncret);
   alstrtofs(pvalue,pfuncret);
end;

begin
alevaluate(pargs,pstateenv,mem,[1,2]);
if pargs.narg>0 then str1:= alfstostrlc(pargs.arg[1],eoa);
if pargs.narg>1 then str2:= alfstostrlc(pargs.arg[2],eoa);

if pargs.narg=0 then begin
   (* Return all settings. *)
   cnt:= 0;
   returnsetting('allowBlanksBeforeCommentToEoln',alAllowBlanksBeforeCommentToEoln);
   returnsetting('allowFunctionCallsAfterPreact',alAllowFunctionCallsAfterPreact);
   returnsetting('allowJumpsBetweenNormalStates',xAllowJumpsBetweenNormalStates);
   returnsetting('allowNewlineInBinaryInput',allowNewlineInBinaryInput);
   returnsetting('casewarning',alcasewarning);
   returnsetting('CheckUnreadPosAtExit',alCheckUnreadPosAtExit);
   returnsetting('checkvar',xcheckvar);
   returnsetting('compileAlts',alCompileAlts);
   returnsettingStr('dllCallLogTo',dllCallLogToFileName);
   returnsetting('formvisible',(style and $10000000)<>0);
   returnsetting('msgboxtooutputwindow',iomsgboxtooutputwindow);
   returnsetting('prelDefWithNarg',alPrelDefWithNarg);
   returnsetting('regardscrasblank',xoptcrfile<>' ');
   returnsetting('restoreioaftermacro',restoreioaftermacro);
   returnsetting('sameParentRequiredForJump',xSameParentRequiredForJump);
   returnsetting('statesingroupsvisible',statesInGroupsVisible);
   returnsetting('suppressbadcharmessage',iosuppressbadcharmessage);
   returnsetting('unractive',xunr.active);
   returnsettingInt('useasoutput',iofDefaultOutPut);
   returnsetting('useDefForFunction',useDefForFunction);
   returnsetting('useindentation',xUseIndentation);
   end

else if str1='allowblanksbeforecommenttoeoln' then begin
   if pargs.narg=1 then begin
      // Just read value
      if alAllowBlanksBeforeCommentToEoln then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then alAllowBlanksBeforeCommentToEoln:= True (* Allow blanks
         before comment that continues to (or beyond) the end of the line
         (ignore the blanks). Used by ioxRead. *)
      else if str2='no' then alAllowBlanksBeforeCommentToEoln:= False
      else xScriptError('X: Value yes or no was expected but "'+str2+'" was found.');
      end;
   end
else if str1='allowfunctioncallsafterpreact' then begin
   if pargs.narg=1 then begin
      // Just read value
      if alAllowFunctionCallsAfterPreact then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then alAllowFunctionCallsAfterPreact:= True (* Allow function
         calls after preaction (needed to use <settings compileAlts,yes/no>). *)
      else if str2='no' then alAllowFunctionCallsAfterPreact:= False
      else xScriptError('X: Value yes or no was expected but "'+str2+'" was found.');
      end;
   end
else if str1='allowjumpsbetweennormalstates' then begin
   if pargs.narg=1 then begin
      // Just read value
      if xAllowJumpsBetweenNormalStates then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then xAllowJumpsBetweenNormalStates:= True (* OK to jump
         between ordinary states (---). *)
      else if str2='no' then xAllowJumpsBetweenNormalStates:= False (* New style:
         Jumps only allowed between substates. *)
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='allownewlineinbinaryinput' then begin
   if pargs.narg=1 then begin
      // Just read value
      if allownewlineinbinaryinput then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then begin
         allownewlineinbinaryinput:= True; (* OK to jump
            between ordinary states (---). *)
         fsAllowNewlineInBinaryInput(true);
         end
      else if str2='no' then begin
         allownewlineinbinaryinput:= False; (* New style:
            Jumps only allowed between substates. *)
         fsAllowNewlineInBinaryInput(false);
         end
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='casewarning' then begin
   (* To show error message when a case function call has no matching alternative. *)
   if pargs.narg=1 then begin
      // Just read value
      if alcasewarning then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then alcasewarning:= True
      else if str2='no' then alcasewarning:= False (* (Default) *)
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='checkunreadposatexit' then begin
   if pargs.narg=1 then begin
      // Just read value
      if alCheckUnreadPosAtExit then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then alCheckUnreadPosAtExit:= True (* If unread was used
         in preaction - check that position is same when returning from the
         called state. Used by xCheckExitState. *)
      else if str2='no' then alCheckUnreadPosAtExit:= False
      else xScriptError('X: Value yes or no was expected but "'+str2+'" was found.');
      end;
   end
else if str1='checkvar' then begin
   if pargs.narg=1 then begin
      // Just read value
      if xcheckvar then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then xcheckvar:= True (* Only <var defines variables shall be
                                              set by <set ...> *)
      else if str2='no' then xcheckvar:= False
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='compilealts' then begin
   if pargs.narg=1 then begin
      // Just read value
      if alCompileAlts then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then alCompileAlts:= True (* Turn on compilation of alts. *)
      else if str2='no' then alCompileAlts:= False
      else xScriptError('X: Value yes or no was expected but "'+str2+'" was found.');
      end;
   end
else if str1='formvisible' then begin
   style:= GetWindowLong(iofCurrentFormhandle,-16);
   if pargs.narg=1 then begin
      // Just read value
      if (style and $10000000)<>0 then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then
         ShowWindow(iofCurrentFormHandle,sw_shownormal)
      else if str2='no' then
         ShowWindow(iofCurrentFormHandle,sw_hide)
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='dllcalllogto' then begin
   (* To log dll calls to a file:
      Str2 = (filename) - Start logging of dll calls to file (filename).
      Str2 = (empty) - Stop logging of dll calls. *)
   if pargs.narg=1 then begin
      // Just read value
      alstrtofs(dllCallLogToFileName,pfuncret)
      end
   else begin
      if str2='' then begin
         closeFile(dllCallLogToFile);
         dllCallLogToFileName:= '';
         dllCallLogTo:= false;
         end
      else begin
         dllCallLogToFileName:= str2;
         AssignFile(dllCallLogToFile,dllCallLogToFileName);
         rewrite(dllCallLogToFile);
         dllCallLogTo:= true;
         end;
      end;
   end
else if str1='msgboxtooutputwindow' then begin
   (* To send msgbox messages (sendmessage) to output window instead. *)
   if pargs.narg=1 then begin
      // Just read value
      if iomsgboxtooutputwindow then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then iomsgboxtooutputwindow:= True
      else if str2='no' then iomsgboxtooutputwindow:= False (* (Default) *)
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='preldefwithnarg' then begin
   (* Check that min narg is specified in <preldef ...>. *)
   if pargs.narg=1 then begin
      // Just read value
      if alPrelDefWithNarg then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      alInSettingPrelDefWithNarg:= true;
      if str2='yes' then begin
          alPrelDefWithNarg:= True;
          // New way: String and min arg must be specified
          xdefinepdf('preldef',prelDefFuncNr,3,4);
          end
      else if str2='no' then begin
          alPrelDefWithNarg:= False; (* (Default) *)
          (* Old way: Only name need to be specified, number of args
             will not be checked in references to the preliminary defined
             function. *)
          xdefinepdf('preldef',prelDefFuncNr,1,4);
          end
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      alInSettingPrelDefWithNarg:= false;
      end;
   end
else if str1='regardcommentasblank' then begin
   if pargs.narg=1 then begin
      // Just read value
      if xlinecommentasblank then alstrtofs(xcommentasblank,pfuncret)
      else case xcommentasblank of
          '-': alstrtofs('ada',pfuncret);
          '/': alstrtofs('c',pfuncret);
          '(': alstrtofs('pascal',pfuncret);
          ' ': alstrtofs('no',pfuncret);
         end;
      end
   else begin
     (* To regard comments as blanks when processing source code files. *)
      if str2='ada' then begin xlinecommentasblank:= false; xcommentasblank:= '-' end
      else if str2='c' then begin xlinecommentasblank:=false; xcommentasblank:= '/' end
      else if str2='pascal' then begin xlinecommentasblank:=false; xcommentasblank:= '(' end
      else if str2='no' then begin xlinecommentasblank:= false; xcommentasblank:= ' ' (* (Default) *) end
      else if length(str2)=1 then begin xlinecommentasblank:=true; xcommentasblank:= str2[1] end
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be Ada, C, Pascal, /, ; or no).');
      end;
   end
else if str1='regardcrasblank' then begin
   if pargs.narg=1 then begin
      // Just read value
      if xoptcrfile=' ' then alstrtofs('no',pfuncret)
      else alstrtofs('yes',pfuncret)
      end
   else begin
      if str2='yes' then xoptcrfile:= ctrlM (* Allow CR as white space *)
      else if str2='no' then xoptcrfile:= ' '
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='restoreioaftermacro' then begin
   (* To automatically restore input and output file at the end of a macro function *)
   if pargs.narg=1 then begin
      // Just read value
      if restoreioaftermacro then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then restoreioaftermacro:= True (* (See almacro) *)
      else if str2='no' then restoreioaftermacro:= False (* (Default) *)
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='sameparentrequiredforjump' then begin
   if pargs.narg=1 then begin
      // Just read value
      if xSameParentRequiredForJump then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then xSameParentRequiredForJump:= True (* Same parent
         required for jump (not ok to jump between files). *)
      else if str2='no' then xSameParentRequiredForJump:= False (* Same parent
         not required. OK to jumb between states in different files.
         (Used by cmdfilereader to put system specific commands in separate
         x-files). *)
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='skipcomment' then begin
   if pargs.narg=1 then begin
      // Just read value
      if xlinecomment then alstrtofs(xskipcomment,pfuncret)
      else case xskipcomment of
          '-': alstrtofs('ada',pfuncret);
          '/': alstrtofs('c',pfuncret);
          '(': alstrtofs('pascal',pfuncret);
          ' ': alstrtofs('no',pfuncret);
         end;
      end
   else begin

      (* To skip comments as blanks when processing source code files. *)
      if str2='ada' then begin xlinecomment:= false; xskipcomment:= '-' end
      else if str2='c' then begin xlinecomment:=false; xskipcomment:= '/' end
      else if str2='pascal' then begin xlinecomment:=false; xskipcomment:= '(' end
      else if str2='no' then begin xlinecomment:= false; xskipcomment:= ' ' (* (Default) *) end
      else if length(str2)=1 then begin xlinecomment:=true; xskipcomment:= str2[1] end
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be Ada, C, Pascal, /, ; or no).');
      end;
   end
else if str1='statesingroupsvisible' then begin
   if pargs.narg=1 then begin
      // Just read value
      if statesInGroupsVisible then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then statesInGroupsVisible:= True (* Makebits like in Delphi-X *)
      else if str2='no' then xScriptError('<settings '+str1+'...>: States in '+
         'groups not being globally visible is only available in the C-version of X.')
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='suppressbadcharmessage' then begin
   (* To silently convert reserved characters, e.g. eofs, in non binary textfiles.
      without showing any error message. *)
   if pargs.narg=1 then begin
      // Just read value
      if iosuppressbadcharmessage then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then iosuppressbadcharmessage:= True
      else if str2='no' then iosuppressbadcharmessage:= False (* (Default) *)
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='tracecallsto' then begin
   (* To print all calls to functions in a certain x-file. Used for debugging. *)
   if pargs.narg=1 then begin
      // Just read value
      if tracecallsto>0 then alstrtofs(xname(tracecallsto),pfuncret);
      end
   else begin
      if str2='' then tracecallsto:= 0
      else begin
         tracecallsto:= 0;
         xseekgroup(str2,a_file,nr);
         if (nr>0) then tracecallsto:= nr
         else if nr>0 then xscripterror(str2 + 'was expected to be a file, but ' +
            ' it was something else ('+ inttostr(integer(kind)) + ').')
         else xscripterror(str2 + ' was not found among loaded x-files.');
         end;
      end;
   end

else if str1='unractive' then begin
   (* To activate experimental version of cleaned up unread function, to allow
      several files to have active unread strings simultaneously. *)
   if pargs.narg=1 then begin
      // Just read value
      if xunr.active then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then xunr.active:= True
      else if str2='no' then xunr.active:= False (* (Default) *)
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else if str1='useasoutput' then begin
   if pargs.narg=1 then begin
      // Just read value
      alinttofs(iofDefaultOutPut,pfuncret);
      end
   else begin
      if alfstoint(pargs.arg[2],handle) then begin
         iofDefaultOutput:= handle;
         // Test if handle is valid
         setlasterror(0);
         GetWindowTextLength(handle);
         if getlasterror<>0 then
            xscripterror('Tried to use handle '+inttostr(handle)+
            ' for output but it appeared to be invalid. Received error code '+
            alSystemErrorMessage+'.')
         end
      else xScriptError('<settings '+str1+','+str2+'>: Unknown value: "'
         +str2+'" (should be integer handle).');
      end;
   end
else if str1='usedefforfunction' then begin
   if pargs.narg=1 then begin
      // Just read value
      if usedefforfunction then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then usedefforfunction:= True (* Makebits like in Delphi-X *)
      else if str2='no' then xScriptError('<settings '+str1+'...>: Not using def '+
         'for <function...> is only available in the C-version of X.')
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
(* (old:)  *)
else if str1='usehexformakebits' then begin
   if pargs.narg=1 then alstrtofs('yes',pfuncret);
   (* (old:)
   if pargs.narg=1 then begin
      // Just read value
      if alUsehexformakebits then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then alUsehexformakebits:= True
      else if str2='no' then alUsehexforMakeBits:= false
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   *)
   end
(* *)
else if str1='useindentation' then begin
   if pargs.narg=1 then begin
      // Just read value
      if xUseIndentation then alstrtofs('yes',pfuncret)
      else alstrtofs('no',pfuncret)
      end
   else begin
      if str2='yes' then xUseIndentation:= True (* Only <var defines variables shall be
                                              set by <set ...> *)
      else if str2='no' then xUseIndentation:= False
      else xScriptError('<settings '+str1+'...>: Unknown value: "'
         +str2+'" (should be yes or no).');
      end;
   end
else xScriptError('<settings ...>: Unknown setting: "'+str1+'".');
aldispose(pargs,mem);
end;


(* (new:) *)
procedure alread( var pargs: xargblock;
                  var pstateenv: xstateenv; pfuncret: fsptr );
(* <read ln>:
    - Read and return a line from input. CR not included.
   <read n>  - Read and return n characters from input.
   <read *>  - Read and return the rest of the input file.
*)
var n,count: alint16;
mem: alevalmem; infilename: fsptr;
ch: char;
infilenr: integer;

begin (*alread*)

alevaluate(pargs,pstateenv,mem,[1]);

if pstateenv.cinp<>nil then begin
   // Input file exist.
   if pstateenv.cinp^=eofr then begin
      ioingetinput(pstateenv.cinp,false);
      end;

   infilenr:= iogetinfilenr;

   with pargs do if arg[1]^ in ['L','l'] then begin (* <read LN> *)
      if ioInfileBinary then
         xScriptError('<read ln> expected a file with text, but the current ' +
            'input file is binary (contains only hexadecimal characters).')
      else begin
         while not ( (pstateenv.cinp^=char(13)) or (pstateenv.cinp^=char(10))
            or (pstateenv.cinp^=eofr) or (pstateenv.cinp^=eofs) ) do begin
            ch:= pstateenv.cinp^;
            if ch=char(10) then ch:= char(13);
            fspshend(pfuncret,ch);
            ioinforward(pstateenv.cinp);
            if pstateenv.cinp^=eofr then begin
               if pstateenv.statenr=0 then ioinadvancereadpos(pstateenv.cinp);
               ioingetinput(pstateenv.cinp,false);
               end;
            end;
         if (pstateenv.cinp^=char(13)) or (pstateenv.cinp^=char(10)) then ioinforward(pstateenv.cinp);
         end;
      end

   else if arg[1]^='*' then begin (* <read *> *)
      fsnew(infilename);
      ioinfilename(infilename);
      while not ( (pstateenv.cinp^=eofr) or (pstateenv.cinp^=eofs) ) do begin
         ch:= pstateenv.cinp^;
         if ch=char(10) then ch:= char(13);
         fspshend(pfuncret,ch);
         ioinforward(pstateenv.cinp);
         if (pstateenv.cinp^=eofr) and
            not (fstostr(infilename)='cons') then begin
            if pstateenv.statenr=0 then ioinadvancereadpos(pstateenv.cinp);
            ioingetinput(pstateenv.cinp,false);
            end;
         end;
      fsdispose(infilename);
      end
   else if arg[1]^ in ['0'..'9'] then begin (* <READ n> *)
      n:= fsposint(arg[1]);
      if n<0 then xScriptError('X(<read n>): Expected a number >=0, found "'+
         alfstostr100(pargs.arg[1],eoa)+'".');
      count:= 0;
      while not ( (count=n) or (pstateenv.cinp^=eofr) or (pstateenv.cinp^=eofs) )
         do begin
         fspshend(pfuncret,pstateenv.cinp^);
         ioinforward(pstateenv.cinp);
         if pstateenv.cinp^=eofr then begin
            if pstateenv.statenr=0 then ioinadvancereadpos(pstateenv.cinp);
            ioingetinput(pstateenv.cinp,false);
            end;
         count:= count+1;
         end;
      end;

   (* To prevent buffer overflow if x is in a state reading another source
      and then <in ...> is temporarily used to read lot of data from
      this source (for example when closing a connection): *)
   if ioinreadrescnt=0 then
      (* Mark read characters as consumed. *)
      ioinadvancereadpos(pstateenv.cinp);

   end; // (input file exists)

aldispose(pargs,mem);

end; (*alread*)

(* (Accidental double implementation of logto)

var logToFileName: string;

procedure ioLogTo(pFilename: string);
begin

end; // (ioLogTo)

( * alLogTo
   -------
   Control X-window logging (copying of X-window output box to a file).
   <logTo filename> = Start logging to a file.
   <logTo > = Stop logging and close file
   <logTo> = Return name of current logging file (if any).
* )
procedure alLogTo( var pargs: xargblock;
   var pstateenv: xstateenv; pfuncret: fsptr );

var
mem: alevalmem;
ptr: fsptr;
addExtension: boolean;

begin ( *alLogTo* )

alevaluate(pargs,pstateenv,mem,[1]);

if pargs.narg<>0 then with pargs do begin

   // There is an argument
   if arg[1]^=eoa then begin
      // Empty filename - stop logging and close log file
      logToFileName:= '';
      ioLogTo('');
      end
   else begin
      // Check if extension shall be added
      ptr:= arg[1];
      fsforwendch(ptr,eoa);
      addExtension:= true;
      while ptr<>arg[1] do begin
         if (ptr^='.') then begin
            addExtension:= false;
            ptr:= arg[1];
            end
         else if (Ptr^='/') or (ptr^='\') then
            // Abort search
            ptr:= arg[1]
         else fsback(ptr);
         end;

      // Save new log file name
      logToFileName:= fstostr(arg[1]);
      if (addExtension) then logToFilename:= logToFilename + '.log';

      // Create new directory if necessary
      ioCreateDirIfNecessary(logToFileName);

      // Start logging
      ioLogTo(logToFileName);
      end; // arg1 not empty
   end // (there is an argument)
else       // No argument - return name of log file
   alstrtofs(inttostr(fsusecount),pfuncret);

aldispose(pargs,mem);

end;// (alLogTo)
*)


procedure alinfo( var pargs: xargblock;
                  var pstateenv: xstateenv; pfuncret: fsptr );
(* <info filename[:port]>:
   Return information about a file or a socket.
*)
var mem: alevalmem;

begin (*alinfo*)

alevaluate(pargs,pstateenv,mem,[1]);

if alfstostrlc(pargs.arg[1],eoa)='usecount' then
   alstrtofs(inttostr(fsusecount),pfuncret)

else ioinfo(pargs.arg[1],eoa,pfuncret);

aldispose(pargs,mem);

end; (*alinfo*)


procedure alwrite( var pargs: xargblock;
                   var pstateenv: xstateenv;
                   var pfuncret: fsptr );
(* <write str>:
   Write a string to the current output.
*)
var mem: alevalmem; str: fsptr;
begin (*alwrite*)
alevaluate(pargs,pstateenv,mem,[1]);

if pstateenv.outstring then fscopy(pargs.arg[1],pfuncret,eoa)
else if iogetoutfilenr=0 then
   xScriptError('Unable to write because current output is undefined. Current '+
      'output becomes undefined when <out> is closed without opening a new output.')
else begin
   fsnew(str);
   fscopy(pargs.arg[1],str,eoa);
   iooutwritefs(str,pstateenv.cinp);
   iochecksbuf;
   fsdispose(str);
   end;

aldispose(pargs,mem);
end; (*alwrite*)


procedure alp( var pargs: xargblock;
               var pstateenv: xstateenv;
               var pfuncret: fsptr )
(* Append par[p1..p2] to pfuncret. *);

var inp: ioinptr;
n,n1,n2: alint16;
cnt: alint16;
atptr: ioinptr;
hexerror: char;
binary: boolean;
ch: char;
mem: alevalmem;
inpEnd: ioinptr;
// for decimal evaluation:
funcret0,s: fsptr;
dec: packed array[1..10] of char;
res: longword;
i,j: integer;


begin (*alp*)

alevaluate(pargs,pstateenv,mem,[1..2]);

n1:= fsposint(pargs.arg[1]);
if pargs.narg>1 then begin
   n2:= fsposint(pargs.arg[2]);
   if n2<0 then xScriptError('X(<p n1,n2>): Expected a number n2 >=0, found "'+
      alfstostr100(pargs.arg[2],eoa)+'".')
   end

else n2:= n1;

if n1<0 then xScriptError('X(<p n>): Expected a number >=0, found "'+
  alfstostr100(pargs.arg[1],eoa)+'".')
else for n:= n1 to n2 do begin

   if pstateenv.pars.invalidBecauseOfRpw then
      xScriptError('X(<p '+inttostr(n)
         +'>): If <replacewith ...> is used in an alternative, then <p ...> can '+
         'only be used before it because <replacewith ...> invalidates '+
         'the pointers used to identify <p n>, but here <p n> was found to be called '+
         'after <replacewith ...>.')
   else if (pstateenv.altnr=0) or (pstateenv.altnr=999) then xScriptError(
      'X(<p '+inttostr(n)
      +'>): <p ...> function unexpectedly used in pre or post action.'
      + 'Use <sp n> if you wish to refer to the state parameter.')
   
   else if n=0 then with pstateenv.pars do begin
      (* <p 0> = everything between ?" and "?. *)
      binary:= false;
      if (npar>0) then begin
         if par[1].bitsas>0 then binary:= true;
         if par[npar].bitsas>0 then binary:= true;
         end;
      if binary and false (* +++ *) then
         xProgramError('X(<p 0>): <p 0> can only handle text input, not binary (<bits ...>).')
      else if pstateenv.inpback=NIL then
         xProgramError('X(<p 0>): <p 0> is invalid because it is located in the unread buffer ' +
         '(either through <unread ...> or <in ...,string,local)'+
         'and other state(s) have been called which may change this area.')
      else begin
         inp:= pstateenv.inpback;
         inpEnd:= pstateenv.inpend;
         while not(inp=inpEnd) do begin
            ch:= inp^;
            if ch=char(10) then ch:= char(13);
            fspshend(pfuncret,ch);
            ioinforward(inp);
            end;
         end;
      end (* <p 0> *)

   else with pstateenv.pars do begin
      if (n>npar) then
         (* Non-existent parameter. *)
         xScriptError('X: Non-existent parameter. Existing parameters in this ' +
            'alternative are <p 0>..<p '+inttostr(npar)+'> was expected but <p '+
            inttostr(n)+'> was referenced.')
      else if par[n].fs<>nil then
         fscopy(par[n].fs,pfuncret,eofs)
      else with par[n] do if bitsAs>0 then begin
         inp:= atp;
         cnt:= 0;
         while not (inp=afterp) do begin
            if (fsBinaryWsTab[inp^]<>' ')
               then cnt:= cnt+1;
            ioinforward(inp);
            end;

         (* Make sure that pfuncret is at the end (this is not certain because
            pfuncret is for unknown reason local (not var) in alcall.
            /BFn 170808. *)
         if pfuncret^<>eofs then fsforwend(pfuncret);
         funcret0:= pfuncret;
         algetbits(atp,cnt,atshift,aftershift,pfuncret,hexerror);
         if hexerror<>'0' then
            xProgramError('X(alp): Program error. Only hexadecimal characters'
               +' were expected but "'+hexerror+'..." was read.')
         else begin
            if bitsAs=1 then begin
               // Decimal (default)
               // convert funcret0... to decimal (see alHtod)
               // 1. Convert to 32 bit integer
               res:= 0;
               s:= funcret0;
               cnt:= 0;
               while not (s^=eofs) do begin
                  if s^<>' ' then begin
                     cnt:= cnt+1;
                     if cnt<=8 then res:= (res shl 4) or alhextoint(s^);
                     end;
                  fsforward(s);
                  end;
               if cnt>8 then xScriptError(
                     'x(<p ...>): Unable to conv hexadecimal numbers longer than 8 chars to dec.')

               else begin
                  // 2. Convert result to string, starting with last digit.
                  i:= 10;
                  while (res>0) do begin
                     dec[i]:= char( alint16('0') + res mod 10);
                     res:= res div 10;
                     i:= i-1;
                     end;
                  if i=10 then begin
                     dec[i]:='0';
                     i:= i-1;
                     end;
                  // 3. Print to funcret (overwriting hex digits)
                  fsdelrest(funcret0);
                  pfuncret:= funcret0;
                  for j:= i+1 to 10 do fspshend(pfuncret,dec[j]);
                  end;(* not size error *)
               end (* bitsAs=1 *)
            else if bitsAs=3 then begin
               // Return hex: already there - no further action
               end
            else xProgramError('X(alp): Program error. BitsAs = 1 or 3 was ' +
               'expected, but ' + inttostr(bitsAs) + ' was found.');
            end; (* not hexerror *)

         end (* bitsAs>0 *)
      else begin
         inp:= atp;
         while not ((inp = afterp) or (inp^=eofs)) do begin
            ch:= inp^;
            if ch=char(10) then ch:= char(13);
            fspshend(pfuncret,inp^);
            ioinforward(inp);
            end;
         if inp<>afterp then begin
            atptr:= atp;
            xProgramError('alp: Program error - inp ('+inttostr(qword(inp)) +
               ') was expected to be = afterp(' + inttostr(qword(afterp)) +
               ') but it was not. (atp= "'+ioptrtostr400(atptr)+'").');
            end;
          end;
      end;(* (with pstateenv.pars) *)
   end; (* (for n:= ...) *)

aldispose(pargs,mem);

end; (*alp*)

(* Keeping track of context for <xp n>.
   ====================================

   This analysis was written by BFn 2020-01-24 because of an error when
   arg2 of <xp n> was not set which caused an error message in alxp.
   The error was a missing initialisation of inIfeqOrCaseOddArg3Plus in
   the procedure bytut, and it has been fixed.

   Testxp.x:

   <var $logpos,100>
   <var $logspeed,80>

   <function logevent,
   -<var $arg,$1>
   -<wcons $arg>
   ->

   <function logvalue,
   -<logevent $1 = <ifeq $3,,$2>>
   -,2,3>

   <function f1,<ifeq abc123,abc<integer>,<wcons here:abc<xp 1> from caller:$1.>>>

   // Works=> <xp 1,0>):
   <function test,
   -<ifeq L15A10/BL 40+
   ,<to
   ,<eof>><anything>,
   --<logvalue Test env. label,<xp 1>>
   -->
   ->

   Example
   =======

   Sequence of evaluation and almacro->fylli->bytut:

   Working:
   -------
   <function test,
   -<ifeq L15A10/BL 40+
   ,<to
   ,<eof>><anything>,
   --<logvalue Test env. label,<xp 1>>
   -->
   ->

   Evaluate logvalue:
   <function logvalue,
   -<logevent Test env. label = <ifeq ,,<xp 1>>>
   -,2,3>

   Evaluate logevent:
   <function logevent,
   -<var $arg,Test env. label = <ifeq ,,<xp 1>>>
   ->


   Analysis
   ========

   Test:
   -----
   <xp 1> refers to "<to
,<eof>>" which represents "L15A10/BL 40+".

   Logvalue1:
   ----------
   $1 = "Test env. label"
   $2 = "<xp 1>"

   When <logvalue1 Test env. label,<xp 1>> is interpreted,
      "almacro(pnr,pargs,pevalkind,pstateenv,pfuncret);"
   will be called, where pnr represents the number of the function logvalue1.

   almacro:
   --------
   almacro will replace $1, $2, and $3 with:
      $1: "Test env. label"
      $2: "<xp 1>"
      $3: "" (there is no $3 and $3 is optional).

   When almacro sees the beginning of a function call (<logevent ...>), it scans all the arguments
   (there is only one: "$1 = <ifeq $3,,$2,<ifeq $2,<integer><alt .<integer>,>,$2 $3,$2>>", by
   calling the function fylli(dumant,dumandr,dumrecursive) to fill in all occurrences
   of $n with the corresponding argument.

   Fylli will look for $n and replace it with the corresponding argument string (see the list above).
   It does this by calling "bytut(pantalpsh,brecursive)" when it sees the character '$'.

   Since replacing $n with a new string can change the length of the argument, in order to keep
   track of all nested function calls, fylli has to call itself recursively when it encoungers
   new function calls (in this case:
   "<ifeq $3,,$2,<ifeq $2,<integer><alt .<integer>,>,$2 $3,$2>>").
   2nd level "fylli" will discover $3 and replace it with "", and $2 (1st encounter) with "<xp 1>".

   Fylli will also call itself recursively to fill in <ifeq $2,<integer><alt .<integer>,>,$2 $3,$2> but
   we can ignore this for now, because this branch will not be executed in the above example,
   since $3 is empty (="").

   bytut:
   ------
   Byt ut calculates the number after "$", for example "1". It also counts optional "&" characters
   before and after, which are used to fill out the string to a fixed length, either to left, to right,
   or both.

   It will insert the actual argument values at the places of $n.

   When a function call (<f ...>) is encountered in the actual argument value, then bytut will only
   evaluate it the field length is fixed ($n preceded or followed by '&' characters), but not otherwise.
   This is to follow the rule of late evaluation.

   Keeping track of the <xp n> context
   ===================================

   nxPar is set whenever <case ...> or <ifeq ...> is executed. It is valid in the "then" parts of
   these calls. The <xp n> parameters are stored after the <p n> parameters in the same table, which
   is called par. The number of pn parameters is called npar.
   The index of an <xp n> parameter in the par table is calculated as npar + xparoffset + n.

   xparoffset contains the offset that hides the <xp n> strings beloning to higher levels in
   a nested statement. Example:
   <case abc123,abc<integer>,<ifeq <xp 1>,12<format d>,<wcons <xp 1>>>
   When the first <xp 1> is evaluated, xparoffset=0 and <xp 1> refers to "123".
   When the second <xp 1> is evaluated, xparoffset=1 and <xp 1> refers to "3".

   In a "then" part of a <case ...> or <ifeq ...> statement, the <xp n> parameters can be normally be
   found in par[npar + xparoffset+1..npar + xparoffset+nxpar], npar being number of <p n> parameters.

   But there is an exception to the rule. If <xp n> was not a part of the <case ...> or <ifeq ...>
   expression, but instead was inserted there, bytut function (see above), to replace an $n reference,
   then it should be evaluated in the context where the current function was called.

   Example:

   <function f1,<ifeq abc123,abc<integer>,<wcons here:abc<xp 1> from caller:$1.>>>

   <ifeq abc456,abc<integer>,<f1 <xp 1>>>

*)


procedure alxp( var pargs: xargblock;
               var pstateenv: xstateenv;
               var pfuncret: fsptr )

(* <xp n>:
   Returns a string corresponding to a <...>-call in pattern n, in a <case ...>
   or <ifeq ...> statement.

   Example:
   <case abc123def!
   -,<to <integer>><integer><anything>,
   -...
   ->

   Under the pattern "<to <integer>><integer><anything>":
   <xp 1> will return the string corresponding to "<to <integer>>", which is "abc".
   <xp 2> will return the string corresponding to "<integer>", which is "123".
   <xp 3> will return the string corresponding to "<anything>", which is "def!"

   If variable names like "$xxx" appear on top level, then these will also count as
   a <...>-calls. This is however an unwanted side effect of how X is implemented.
*)


(* L�gg inneh�llet i par(xp n) till slutet av pfuncret. *);

var inp: ioinptr;
n,ix: alint16;
cnt: alint16;
atptr: ioinptr;
hexerror: char;
binary: boolean;
ch: char;
mem: alevalmem;
a2,nxp: integer;
// For decimal evaluation:
funcret0,s: fsptr;
dec: packed array[1..10] of char;
res: longword;
i,j: integer;

begin (*alxp*)

alevaluate(pargs,pstateenv,mem,[1]);

n:= fsposint(pargs.arg[1]);

if n<0 then xScriptError('X(<xp n>): Expected a number >=0, found "'+
  alfstostr100(pargs.arg[1],eoa)+'".')

else if n=0 then with pstateenv.pars do
   (* <p 0> *)
   xScriptError('X(<xp 0>): n>0 was expected.')

(* (old:)
else if (n>pstateenv.pars.nxpar) then (* xScriptError(
    'alxp: Error - parameter <xp '+inttostr(n)+'> does not exist.') *)
    (* (Accept unused parameters as empty strings?) *)

else with pstateenv.pars do begin

   nxp:= pstateenv.pars.nxpar;
   if pargs.narg=1 then begin
      // Old format
      ix:= npar+xparoffset+n;
      xProgramError('alXp: expected narg=2 but found narg=1 (obsolete?). ')
      end
   else begin
      (* New format - to handle the case when <f <xp 1>> is called
         and f = ... <ifeq ...,...,...$1.... <xp 1> must then
         use the xparoffset from when f was called (and not from within
         <ifeq ....>). *)
      a2:= integer(pargs.arg[2]^);
      (* Initially =250 (no offset). If <xp n> appears in an argument of a
         function call, then when this call is evaluated, this argument will be
         processed (in almacro.bytutfunc).
         If <xp n> appears in argument 3 (or 5, 7, ...)
         in <ifeq ...> or <case ...>
         inIfeqOrCaseOddArg3Plus
         Can be changed during
         execution if <xp n> is an argument to a function and evaluated as $n
         inside the function. <xp n> shall then be evaluated in the context of
         the call for example "...<f ... <xp n>...> ...", and not in the context
         of the reference ($n) inside the function. arg2 is used to for this purpose.
         *)
      if a2<250 then begin
         (* Special case: There is an offset - <xp n> is evaluated in another
            context than where it was written. *)
         ix:= npar+a2+n;
         if n>nxp then
            (* This is not completely safe - if user adresses a
               too high <xp n> it may return an <xp n> from an inner
               level./BFn 2011-02-18 *)
            nxp:= xparoffset+nxp;
         end
      else begin
         (* Normal case: <xp n> is evaluated is the same context as where it was
            written. *)
         if (n>pstateenv.pars.nxpar) then begin
            (* n > number of <xp n> parameters here. Print error message. *)
            if pstateenv.pars.nxpar=0 then
               xScriptError('alxp: parameter <xp '+inttostr(n)+'> does not exist' +
                  ' (there is no <xp n> at this place.')
            else if pstateenv.pars.nxpar=1 then
               xScriptError('alxp: <xp 1> was expected but <xp '+inttostr(n)+
                  '> was found.')
            else
               xScriptError('alxp: <xp (1..'+inttostr(pstateenv.pars.nxpar)+
                  ')> was expected but <xp '+inttostr(n)+'> was found.');
            end
         else
            // OK - Normal evaluation
            ix:= npar+xparoffset+n;
         end;
      end;

   if n>nxp then (* xScriptError(
      'alxp: Error - parameter <xp '+inttostr(n)+'> does not exist.') *)
      (* (Accept unused parameters as empty strings?) *)
   else if par[ix].fs<>nil then fscopy(par[ix].fs,pfuncret,eofs)
   else with par[ix] do if bitsAs>0 then begin
      inp:= atp;
      cnt:= 0;
      while not (inp=afterp) do begin

         if fsBinaryWsTab[inp^]<>' ' then cnt:= cnt+1;
         ioinforward(inp);
         end;

      (* Make sure that pfuncret is at the end (this is not certain because
         pfuncret is for unknown reason local (not var) in alcall.
         /BFn 170808. *)
      if pfuncret^<>eofs then fsforwend(pfuncret);
      funcret0:= pfuncret;
      algetbits(atp,cnt,atshift,aftershift,pfuncret,hexerror);
      if hexerror<>'0' then xProgramError('X(alxp): Program error. '+
         'Only hexadecimal characters were expected but "'+hexerror+
         '..." was read.')
      else begin
         // This part was copied from alP (BFn 170808):
         if bitsAs=1 then begin
            // Decimal (default)
            // convert funcret0... to decimal (see alHtod)
            // 1. Convert to 32 bit integer
            res:= 0;
            s:= funcret0;
            cnt:= 0;
            while not (s^=eofs) do begin
               if s^<>' ' then begin
                  cnt:= cnt+1;
                  if cnt<=8 then res:= (res shl 4) or alhextoint(s^);
                  end;
               fsforward(s);
               end;
            if cnt>8 then xScriptError(
               'x(<xp ...>): Unable to conv hexadecimal numbers longer than 8 chars to dec.')

            else begin
               // 2. Convert result to string, starting with last digit.
               i:= 10;
               while (res>0) do begin
                  dec[i]:= char( alint16('0') + res mod 10);
                  res:= res div 10;
                  i:= i-1;
                  end;
               if i=10 then begin
                  dec[i]:='0';
                  i:= i-1;
                  end;
               // 3. Print to funcret (overwriting hex digits)
               fsdelrest(funcret0);
               pfuncret:= funcret0;
               for j:= i+1 to 10 do fspshend(pfuncret,dec[j]);
               end;(* not size error *)
            end (* bitsAs=1 *)
         else if bitsAs=3 then begin
            // Return hex: already there - no further action
            end
         else xProgramError('X(alp): Program error. BitsAs = 1 or 3 was ' +
            'expected, but ' + inttostr(bitsAs) + ' was found.');
         end;
      end
   else begin
      inp:= atp;
      while not ((inp = afterp) or (inp^=eofs)) do begin
         ch:= inp^;
         if ch=char(10) then ch:= char(13);
         fspshend(pfuncret,inp^);
         ioinforward(inp);
         end;
      if inp<>afterp then begin
         atptr:= atp;
         xProgramError('alxp: Program error - atp= "'+ioptrtostr(atptr)
            +'".');
         end;
      end;
   end;

aldispose(pargs,mem);

end; (*alxp*)


procedure alsp( var pargs: xargblock;
   pevalkind: xevalkind;
   var pstateenv: xstateenv;
   var pfuncret: fsptr );
(* <sp n>:
   Returns state parameter n.
*)

var n: alint16;
mem: alevalmem;

begin (*alsp*)

alevaluate(pargs,pstateenv,mem,[1]);

n:= fsposint(pargs.arg[1]);

if n<=0 then xScriptError('X(<sp n>): Expected a number >0, found "'+
  alfstostr100(pargs.arg[1],eoa)+'".')
else with pstateenv do begin
   if (n>nspar) then (* xScriptError(
      'alp: Error - parameter <p '+inttostr(n)+'> does not exist.') *)
   (* (Accept unused parameters as empty strings?) *)
   else if spar[n]<>nil then begin
      if sparlateeval[n] then
         xevaluate(spar[n],eoa,pevalkind,pstateenv,pfuncret)
      else fscopy(spar[n],pfuncret,eofs);
      end;
  end;

aldispose(pargs,mem);

end; (*alsp*)

(* This is disabled for time being, because <sp n> shall be used for
   both state parameters and substate parameters. Parameters in calls to
    substates, or in jumpsIf substate parameters
   are used in the call, they overwrite the state parameters, otherwise
   <sp n> returns the parameters of the last called state, ...  *)

(* (old:) *)
procedure alssp0( var pargs: xargblock;
   pevalkind: xevalkind;
   var pstateenv: xstateenv;
   var pfuncret: fsptr );
(*
   <ssp n>
   - Obsolete (disabled) -
   Returns substate parameter n.
*)

var n,i: alint16;
mem: alevalmem;

begin (*alssp0*)

alevaluate(pargs,pstateenv,mem,[1]);

n:= fsposint(pargs.arg[1]);

if n<=0 then xScriptError('X(<sp n>): Expected a number >0, found "'+
  alfstostr100(pargs.arg[1],eoa)+'".')
else with pstateenv do if n<=nsspar then begin
   // (Accept unused parameters as empty strings)
   (* <ssp n> = spar[nspar+n] *)
   i:= nspar+n;
   if (spar[i]<>nil) then begin
   (* (from alsp but would require j_lateevaluation:) if sparlateeval[i] then
         xevaluate(spar[i],eoa,pevalkind,pstateenv,pfuncret)
      else *)
      fscopy(spar[i],pfuncret,eofs);
      end;
  end;

aldispose(pargs,mem);

end; (*alssp0*)

procedure alpfail( var pargs: xargblock;
   var pstateenv: xstateenv; var pfuncret: fsptr );
(* <pfail n,str>:
   Return <p n> but insert str at the position after which
   comparison of previous alternatives (?"..."?) failed.
   Useful to detect causes of when a state does not regognize a
   string.
   This is how it is normally used, at the end of a state, when
   all other alternatives have failed. � will then be inserted before the
   first character that could not be matched to any of the alternatives
   in the state.

   ?"<to
   >
   "?
   !"<wcons *** Unable to match <pfail 1,�>.>"!
*)
(*
   (see xfailpos and ioinlastpos).
*)

var
mem: alevalmem;
inp: ioinptr;
cnt: alint16;
n: alint16;
atptr: ioinptr;
hexerror: char;
ch: char;

begin (*alpfail*)

alevaluate(pargs,pstateenv,mem,[1,2]);

n:= fsposint(pargs.arg[1]);

if n<=0 then xProgramError(
   'X(<pfail n>): Expected a number >0, found "'+
   alfstostr100(pargs.arg[1],eoa)+'".')

else with pstateenv.pars do begin
   if (n>npar) then (* xScriptError(
      'alpfail: Error - parameter <pfail '+inttostr(n)+'> does not exist.') *)
      (* (Accept unused parameters as empty strings?) *)
   else if par[n].fs<>nil then begin
      fscopy(par[n].fs,pfuncret,eofs);
      xScriptError('alpfail: Warning - <pfail ...> only supposed to be called in'
         +' output strings.');
      end
   else with par[n] do if bitsAs>0 then begin
      inp:= atp;
      cnt:= 0;
      while not (inp=afterp) do begin
         if fsBinaryWsTab[inp^]<>' ' then cnt:= cnt+1;
         ioinforward(inp);
         end;

      algetbits(atp,cnt,atshift,aftershift,pfuncret,hexerror);
      if hexerror<>'0' then
         xProgramError('X(alpfail): Program error. Only hexadecimal characters'
         +' were expected but "'+hexerror+'..." was read.');
      xScriptError('alpfail: Warning - <pfail ...> not implemented for binary files.');
      end
   else begin
      inp:= atp;
      if inp=xfailpos then fscopy(pargs.arg[2],pfuncret,eoa);
      while not ((inp = afterp) or (inp^=eofs)) do begin
         ch:= inp^;
         if ch=char(10) then ch:= char(13);
         fspshend(pfuncret,ch);
         ioinforward(inp);
         if inp=xfailpos then fscopy(pargs.arg[2],pfuncret,eoa);
         end;
      if inp<>afterp then begin
         atptr:= atp;
         xProgramError('alpfail: Program error - atp= "'+ioptrtostr(atptr)
            +'".');
         end;
      end;
   end;

aldispose(pargs,mem);

end; (*alpfail*)


(* (new:) *)
procedure alj( var pargs: xargblock;
               var pstateenv: xstateenv; pfuncret: fsptr );
(* <j statename>:
   Jump to state statename.
   If the current state is a jumped to state, then its postaction
   will be carried out.
   The preaction of the new state will be carried out.
   If the current state is a called state, then its postaction will
   not be carried out (it is saved for the reterning with <r ...>).
*)

var mem: alevalmem;
arg1ptr,ptr: fsptr;
oldstate,newstate: alint16;
oldStateParent,newStateParent: alint16;
newstatename,part1,part2: string;
i,n,part,cnt,groupnr,saveGroup: integer;

begin
alevaluate(pargs,pstateenv,mem,[1..xmaxnarg]);

arg1ptr:= pargs.arg[1];
oldstate:= pstateenv.statenr;
newstate:= 0;

(* 1. Get state name and state number. *)
if arg1ptr^='@' then begin
   fsforward(arg1ptr);
   newstate:= 250*integer(arg1ptr^);
   fsforward(arg1ptr);
   newstate:= newstate +integer(arg1ptr^);
   newstatename:= xgroupname(newstate);
   end
else if not pargs.rekursiv[1] then begin
   (* Probably a non-toplevel reference that has become active
      through a top level call in the x-file. Example:
      a file has has a state with two substates, one containing a
      jump to the other. After this state is defined, it is called
      directly from the top level of the x-file. Now it executes
      the jump between its substates, but the state reference is not
      yet resolved, because it is supposed to be resolved first
      when reaching the end of the xfile (and example of this can be
      found in test file testsortmod.x). *)
   // Try to resolve the reference, and remove it from the table
   xResolveAndRemove(arg1ptr);(* Note: this does not always work,
   because if the reference is in a function with arguments, then
   arg1ptr will not be found in the state reference table, because
   it points to a copy of the function, which was created to fill in
   the arguments. *)
   // Try again
   if arg1ptr^='@' then begin
      fsforward(arg1ptr);
      newState:= 250*integer(arg1ptr^);
      fsforward(arg1ptr);
      newState:= newState +integer(arg1ptr^);
      newStateName:= xgroupname(newState);
      end
   end;

if newstate=0 then begin

(* Reference was not resolved and could not be resolved from the
   state reference table. There can be two reasons for this. One
   is the reason described above, as a note. The other is if
   arg1 is recursive (contains function call or variable reference).
   Such references are not resolved during compilation. Try to resolve
   it here instead. *)
   ptr:= arg1ptr;
   part:= 1; // look for part1 first
   cnt:= 0;
   // Identify newStateName.part2, or newStateName
   newStateName:= '';
   part2:= '';
   while not ( (ptr^=eoa) or (part=3) ) do begin
      case part of
         1: begin
            if ptr^='.' then part:= 2 // Look for part2
            else newStateName:= newStateName + ptr^;
            end;
         2: begin
            if ptr^='.' then part:= 3 // Error
            else part2:= part2 + ptr^;
            end;
         end;
      fsforward(ptr);
      cnt:= cnt+1;
      end;

   if part=3 then xScriptError('alJ: State name "'+ alfstostr100(pargs.arg[1],eoa) +
         '" contains two dots (".") - one or none was expected.')
   else if cnt>32 then
      xScriptError('alJ: State name "'+ alfstostr100(pargs.arg[1],eoa) +
         '" is too long (32 char''s max for recursive state ref''s).')

   (* 2. Get state number. *)
   else begin

      newState:= 0;
      if part=2 then begin
         // Look for group first
         xseekgroup(newStateName,a_group,groupnr);
         if groupnr>0 then begin
            // Simulate being in this group, to make the state visible
            saveGroup:= xCurrentGroupNr;
            xCurrentGroupNr:= groupNr;
            xseekgroup(part2,a_state,newState);
            // Restore current group
            xCurrentGroupNr:= saveGroup;
            end;
         end
      else if part=1 then begin
         xseekgroup(newStateName,a_state,newState);
         if newState=0 then begin
            (* Allow call to substate but only from its parent or from
               a substate with the same parent. *)
            oldstate:= pstateenv.stateNr;
            xseekgroup(newStateName,a_subState,newState);
            if newState>0 then
               if xParent(newState)<>oldstate then
                  if xParent(newState)<>xParent(oldstate) then newState:= 0;
            end;
         end;

      if (newState=0) then
         xScriptError('alJ: State ' + alfstostr100(pargs.arg[1],eoa) +
            ' does not exist or is not visible here.');
      end;
   end;

if newstate>0 then begin

   oldStateParent:= xParent(oldState);
   newStateParent:= xParent(newState);

   (* if xSameParentRequiredForJump then only jumps between states belonging to same parent,
      and between a substate and its parentstate, are allowed. *)
   if xSameParentRequiredForJump and (newStateParent<>oldStateParent) and
      (newStateParent<>oldState) and (oldStateParent<>newstate) then
      xScriptError('<j '+alfstostr(pargs.arg[1],eoa)+'>: '+' Due to <setting sameparentrequiredforJump,yes>, '+
         'jump can only be done between states belonging to same file, group or '+
         'state, or between a substate and its parentstate, but current state ('+
         xStateName(oldState)+') belongs to '+xparentname(oldstate)+' and new state '+
         'belongs to '+xparentname(newstate)+'.')

   else with pargs do begin

      (* It is allowed to pass parameters to an x-file jump. They
         can be retrieved as <sp 1>, <sp 2>. Leave old <sp n> untouched
         if there are no jump parameters. *)

      with pstateenv do begin
         if narg-1>xmaxnpar then
            xProgramError('X(<j '+statename+',...>: X assumed ' +
            'that the maximum number of <j ...> state parameters would be below '+
            inttostr(xmaxnpar)+' but <j '+statename+'> uses '+
            inttostr(narg-1)+' state parameters.')
         else begin
            // Enough room for narg-1 state parameters.
            (* Leave spar and nspar as it is if no parameters were included because
               cmdfilereader.x expects to be able to access call parameters
               after jump. *)
            if narg>1 then begin
               for i:= 2 to narg do begin
                  if i-1>nspar then fsnew(spar[i-1])
                  else fsrewrite(spar[i-1]);
                  fscopy(arg[i],spar[i-1],eoa);
                  end;
               for i:= narg to nspar do fsdispose(spar[i]);
               nspar:= narg-1;
               end;
            nsspar:= 0;
            end;// Enough room
         end;// with
      end;// else with pargs

   // Jump is done by setting newstatenr which is read in xcallstate
   if pstateenv.newstatenr<>pstateenv.statenr then
      xProgramError('X(<j ...>): Warning - multiple jumps (<j ...>).');
   pstateenv.newstatenr:= newstate;
   end;

aldispose(pargs,mem);
end; (*alj*)


// (old:)
procedure alj0( var pargs: xargblock;
               var pstateenv: xstateenv; pfuncret: fsptr );
(* (old:)
<j statename> *)

var mem: alevalmem;
oldstate,newstate: alint16;
oldStateParent,newStateParent: alint16;
newstatename: string;
i,n: alint16;

begin
alevaluate(pargs,pstateenv,mem,[1..xmaxnarg]);
newstatename:= alfstostr100(pargs.arg[1],eoa);
newstate:= 0;
oldstate:= pstateenv.statenr;

xseekgroup(newstatename,a_state,newstate);
if newstate=0 then xseekgroup(newstatename,a_subState,newstate);
if newstate=0 then
   xScriptError('State '+newstatename+' does not exist or is not visible here.')
else begin

   oldStateParent:= xParent(oldState);
   newStateParent:= xParent(newState);

   (* if xSameParentRequiredForJump then only jumps between states belonging to same parent,
      and between a substate and its parentstate, are allowed. *)
   if xSameParentRequiredForJump and (newStateParent<>oldStateParent) and
      (newStateParent<>oldState) and (oldStateParent<>newstate) then
      xScriptError('<j '+newstatename+'>: '+' Due to <setting sameparentrequiredforJump,yes>, '+
         'jump can only be done between states belonging to same file, group or '+
         'state, or between a substate and its parentstate, but current state ('+
         xStateName(oldState)+') belongs to '+xparentname(oldstate)+' and new state ('+
         newstatename+') belongs to '+xparentname(newstate)+'.')

   else with pargs do begin

      (* It is allowed to pass parameters to an x-file jump. They
         can be retrieved as <sp 1>, <sp 2>. Leave old <sp n> untouched
         if there are no jump parameters. *)

      with pstateenv do begin
         if narg-1>xmaxnpar then
            xProgramError('X(<j '+statename+',...>: X assumed ' +
            'that the maximum number of <j ...> state parameters would be below '+
            inttostr(xmaxnpar)+' but <j '+statename+'> uses '+
            inttostr(narg-1)+' state parameters.')
         else begin
            // Enough room for narg-1 state parameters.
            (* Leave spar and nspar as it is if no parameters were included because
               cmdfilereader.x expects to be able to access call parameters
               after jump. *)
            if narg>1 then begin
               for i:= 2 to narg do begin
                  if i-1>nspar then fsnew(spar[i-1])
                  else fsrewrite(spar[i-1]);
                  fscopy(arg[i],spar[i-1],eoa);
                  end;
               for i:= narg to nspar do fsdispose(spar[i]);
               nspar:= narg-1;
               end;
            nsspar:= 0;
            end;// Enough room
         end;// with
      end;// else with pargs

   // Jump is done by setting newstatenr which is read in xcallstate
   if pstateenv.newstatenr<>pstateenv.statenr then
      xProgramError('X(<j ...>): Warning - multiple jumps (<j ...>).');
   pstateenv.newstatenr:= newstate;
   end;

aldispose(pargs,mem);
end; (*alj0*)


(* (new:) If a call is done to an unresolved state, it has to be
   resolved and also removed from statereftab. *)

procedure alc( var pargs:xargblock;
   plateeval: boolean; (* False: <c ...>, True: <c_lateevaluation ...> *)
   var pstateenv: xstateenv;
   pfuncret: fsptr );
(* <c statename[,par1[,par2 ...]]>:
   Call a state or a substate.
   The parameters are evaluated before running the state, and can be
   be referenced as <sp 1>, <sp 2> in it.

   A state consists of an underscored* name and three sections:
   A preaction:
   !"..."!
   Alternatives:
   ?"..."?
   !"..."!
   ...
   A postaction:
   !"..."!

   The three sections (preaction, alternatives and postaction) are all optional.
   Preaction is executed when entering the state, and postaction when returning from it.
   The alternatives are used to decode and interpret the current input
   (everything that can be opened with <in ...>).
   The alternatives are tested one by one, starting with the first, until one is
   found which has matching input part (?"..."?). When an alternative is found,
   its output part !"..."! is executed. After executing the output part, the state
   will continue to read and decode input data, unless the output part contained
   the return statement (<r> or <r ...>), in which case it will return after first having
   executed the postaction.

   When an output part !"..."! is executed, its evaluated contents, if any, will
   be written to the current output file (specified by <out ...>).

   * Underscored by dashes "-" or dors ".". Dots are used for substates.
*)

(* <c_lateevaluation statename[,par1[,par2 ...]]>:
   Like <c ...> except that evaluation of parameters is deferred until they
   are used (as in functions).
*)
var
part1, part2: string;
mem: alevalmem;
i: alint16;
oldStateEnv: xstateenvPtr;
stateenv: xstateenv;
groupnr, statenr: integer;
datamoved: boolean;
arg1ptr, ptr: fsptr;
oldoutPtr: ioinptr;
oldState: alint16;
part,cnt,saveGroup: integer;

// New may 2018:
bottomPtrAtEntryToCurrentStateSave: ioinptr;


begin

if plateeval then alevaluate(pargs,pstateenv,mem,[1])
else alevaluate(pargs,pstateenv,mem,[1..xmaxnarg]);

arg1ptr:= pargs.arg[1];
statenr:= 0;

(* 1. Get state name and state number. *)
if arg1ptr^='@' then begin
   fsforward(arg1ptr);
   statenr:= 250*integer(arg1ptr^);
   fsforward(arg1ptr);
   statenr:= statenr +integer(arg1ptr^);
   part1:= xgroupname(statenr);
   end
else if not pargs.rekursiv[1] then begin
   (* Probably a non-toplevel reference that has become active
      through a top level call in the x-file. Example:
      a file has two states, one calling the other.
      After theses two states are defined, the first state
      is called directly from the top level of the x-file.
      Now it calls the other state, but the state reference is not
      yet resolved, because it is supposed to be resolved first
      when reaching the end of the xfile (and example of this can be
      found in test file test2.x). *)
   // Try to resolve the reference, and remove it from the table
   xResolveAndRemove(arg1ptr); (* Note: this does not always work,
   because if the reference is in a function with arguments, then
   arg1ptr will not be found in the state reference table, because
   it points to a copy of the function, which was created to fill in
   the arguments. *)
   // Try again
   if arg1ptr^='@' then begin
      fsforward(arg1ptr);
      statenr:= 250*integer(arg1ptr^);
      fsforward(arg1ptr);
      statenr:= statenr +integer(arg1ptr^);
      part1:= xgroupname(statenr);
      end
   end;

if statenr=0 then begin

   (* Reference was not resolved and could not be resolved from the
      state reference table. There can be two reasons for this. One
      is the reason described above, as a note. The other is if
      arg1 is recursive (contains function call or variable reference).
      Such references are not resolved during compilation. Try to resolve
      it here instead. *)
   ptr:= arg1ptr;
   part:= 1; // look for part1 first
   cnt:= 0;
   // Identify part1.part2, or part1
   part1:= '';
   part2:= '';
   while not ( (ptr^=eoa) or (part=3) ) do begin
      case part of
         1: begin
            if ptr^='.' then part:= 2 // Look for part2
            else part1:= part1 + ptr^;
            end;
         2: begin
            if ptr^='.' then part:= 3 // Error
            else part2:= part2 + ptr^;
            end;
         end;
      fsforward(ptr);
      cnt:= cnt+1;
      end;

   if part=3 then xScriptError('State name "'+ alfstostr100(pargs.arg[1],eoa) +
         '" contains two dots (".") - one or none was expected.')
   else if cnt>32 then
      xScriptError('State name "'+ alfstostr100(pargs.arg[1],eoa) +
         '" is too long (32 char''s max for recursive state ref''s).')

   (* 2. Get state number. *)
   else begin

      statenr:= 0;
      if part=2 then begin
         // Look for group first
         xseekgroup(part1,a_group,groupnr);
         if groupnr>0 then begin
            // Simulate being in this group, to make the state visible
            saveGroup:= xCurrentGroupNr;
            xCurrentGroupNr:= groupNr;
            xseekgroup(part2,a_state,statenr);
            // Restore current group
            xCurrentGroupNr:= saveGroup;
            end;
         end
      else if part=1 then begin
         xseekgroup(part1,a_state,statenr);
         if statenr=0 then begin
            (* Allow call to substate but only from its parent or from
               a substate with the same parent. *)
            oldstate:= pstateenv.statenr;
            xseekgroup(part1,a_subState,statenr);
            if statenr>0 then
               if xParent(statenr)<>oldstate then
                  if xParent(statenr)<>xParent(oldstate) then statenr:= 0;
            end;
         end;

      if (statenr=0) then
         xScriptError(alfstostr100(pargs.arg[1],eoa) +
            ' does not exist or is not visible here.');
      end;
   end;

if statenr>0 then begin

   if xunr.active then begin
      // Save bottomPtrAtEntry and update bottomptr at state entry.
      bottomPtrAtEntryToCurrentStateSave:= xunr.UnrBottomPtrAtEntryToCurrentState;
      xunr.UnrBottomPtrAtEntryToCurrentState:= xunr.unrbottomPtr;
      end;

   xinitstateenv(stateenv,pstateenv.cinp);
   stateenv.compare:= pstateenv.compare;
   if part=1 then stateenv.statename:= part1
   else stateenv.statename:= part1 + '.' + part2;
   stateenv.statenr:= statenr;
   stateenv.newstatenr:= statenr;
   stateenv.cstatenr:= statenr;
   if stateEnv.substatenr<>0 then
       stateenv.newstatenr:= stateEnv.substatenr;

   stateenv.outstring:= pstateenv.outstring;

   (* 4. Set up <sp n>  *)
   with stateenv do begin
      nspar:= pargs.narg-1;
      for i:= 1 TO nspar do begin
         if plateeval and pargs.rekursiv[i+1] then begin
            (* Let spar[i] point into X code. *)
            spar[i]:= pargs.arg[i+1];
            sparlateeval[i]:= true;
            end
         else begin
            (* Create a new string. *)
            fsnew(spar[i]);
            fscopy(pargs.arg[i+1],spar[i],eoa);
            sparlateeval[i]:= false;
            end;
         end;
      nsspar:= 0;
      end; (*with*)

    (* 5. Input pointer *)
    (* stateenv.cinp:= pstateenv.cinp;*)

    (* Push <p n> parameters to the bottom of unread buffer
       to protect them from being overwritten. *)
    if not xunr.active then // (new: condition /BFn 180512)
    iopushpn(pstateenv.pars,datamoved)
    else datamoved:= false;

    (* If data was moved, inpback and inpend may also become invalid. *)
    if datamoved then begin
      pstateenv.inpback:= NIL;
      pstateenv.inpend:= NIL;
      end;

    (* Save old state env pointer. *)
    oldStateEnv:= xCurrentStateEnv;

    (* Move funcnr and argsptr to new state. *)
    stateenv.funcnr:= oldstateenv.funcnr;
    stateenv.argsPtr:= oldstateenv.argsPtr;

    xCurrentStateEnv:= @StateEnv;

    // ++ For reading state info when X has stopped to read data.
    xLastCurrentStateEnv:= xCurrentStateEnv;

    (* Call state. *)
    try
    xcallState(stateenv,pfuncret);
    except

      (* Release parameter buffer stack. *)
      if not xunr.active then// (new: condition)
      iopoppn();

      xProgramError('Exception from xcallstate');
      raise;
      end;

    (* Restore state env pointer. *)
    xCurrentStateEnv:= oldStateEnv;

    // ++ For reading state info when X has stopped to read data.
    xLastCurrentStateEnv:= xCurrentStateEnv;

    (* Take over input pointer. *)
    pstateenv.cinp:= stateenv.cinp;

    (* Release parameter buffer stack. *)
    if not xunr.active then // (new)
    iopoppn();

    (* Dispose pars. *)
    xdisposepn(stateenv.pars); (* old v *)
    with stateenv do  (* new v *)
      for i:= 1 to nspar do
         if not sparlateeval[i] then fsdispose(spar[i]);

    // New unread function (ported from c in May 2018):
    if xunr.active then begin
       // Restore bottomPtrAtEntry
       xunr.UnrBottomPtrAtEntryToCurrentState:= bottomPtrAtEntryToCurrentStateSave;

       // Update ioUnrBottomPtrInCurrentState
       if (xunr.UnrBottomPtr = xunr.UnrBottomPtrAtEntryToCurrentState) then
          xunr.UnrBottomPtrInCurrentState:= nil
       else if (xunr.UnrBottomPtr<xunr.UnrBottomPtrAtEntryToCurrentState) then
          xunr.UnrBottomPtrInCurrentState:= xunr.UnrBottomPtr
       else begin
          // (ioUnrBottomPtr>ioUnrBottomPtrAtEntryToCurrentState)
          if (xunr.UnrBottomPtr>xunr.UnrBottomPtrAtEntryToCurrentState) then
             xProgramError('ioCleanup: UnrBottomPtr(' +
                intToStr(qword(xunr.UnrBottomPtr)) +
                ') was expected to be less or same as UnrBottomPtrAtEntryToCurrentState (' +
                intToStr(qword(xunr.UnrBottomPtrAtEntryToCurrentState)) +
                ') but it was not.');

          xunr.UnrBottomPtrInCurrentState:= nil;
          end;
       end;

    end; // (statenr<>0)

if scripterror then begin
   ScriptError:= False;
   xScriptError(scriptErrorMessage);
   end;

aldispose(pargs,mem);

end; (*alc*)


var
toploadname: fsptr = NIL; (* Last xfilename used on top level. *)

topLoadCurrentDirectory: string; (* Remember current directory of top level
   load file, start dir so that the same dir can be used when <load> is called.
   (See alLoad). *)

runningtitle: fsptr = NIL; (* Evaluation strings for running threads. *)
usagemessage: fsptr = NIL; (* Usagemessage (from <usage ...>) if loadlevel 1. *)


(* Example: filtersvs.x Used in x window title. *)
function altoploadtitle: string;
var tlp: fsptr;
begin
if toploadname=NIL then altoploadtitle:=''
else begin
  // title is the filename excluding the path to it. *)
  tlp:= toploadname;
  fsforwend(tlp);
  while not ((tlp^='\') or (tlp^='/') or (tlp^=':') or (tlp=toploadname)) do fsback(tlp);
  if (tlp^='\') or (tlp^='/') or (tlp^=':') then fsforward(tlp);
  altoploadtitle:= alfstostrlc(tlp,eofs);
  end;
end; // altoploadtitle

(* Running threads. *)
function alrunningtitle: string;
begin
alrunningtitle:= alfstostrlc(runningtitle,eofs);
end;

procedure alcleanup(var pstateenv: xstateenv); forward;

var
xtopdir: fsptr; (* This is where the top level script is loaded from.
   for example: "C:\Documents and Settings\Harry\Skrivbord\X-scripts".
   It is only set once, when a script is loaded (regardless if this script it its
   turn loads other scripts).
   *)
xdefaultdir: fsptr; (* X default directory. When a hierarchy of x-scripts are loaded,
   they will normally only be identified with the script name, for example "config.x"
   and x will then expect to find it on the X default directory, which initially
   is the same as the xtopdir. But the default directory can change in a hierachical way.
   if for example an X-script references another script with "\special\config2.x"
   and the xtopdir is "C:\Documents and Settings\Harry\Skrivbord\X-scripts" like the
   example above, then the xdefaultdir will be changed to
   "C:\Documents and Settings\Harry\Skrivbord\X-scripts\Special" for as long as
   new x-scripts, without paths, are loaded from config2.x. After leaving config2.x,
   xdefaultdir will be restored to "C:\Documents and Settings\Harry\Skrivbord\X-scripts"
   and so on. *)
workingdir: string; (* This is the current working directory (as of getdir(0,dir))
   for x.exe. It can be a completely different from where x.exe is located.
   Workindir is used when developing x-scripts. If a script of the same name
   exists on the working directory, then X will ask if the user wants to load
   this instead of the script on the default directory. A developer can thereby
   copy a script to his or her working directory and work with it there, without
   having to overwrite the old stable version of the script, until the new
   version is finished. *)

function alworkingdir: string;
begin
alworkingdir:= workingdir;
end;

function alTopLoaded: boolean; // true = <load... was entered and alLoadLevel = 1
begin
alTopLoaded:= iofLoadEntered and (alLoadLevel=1);
end;

procedure alload(ploadfrom: boolean; var pargs:xargblock; var pstateenv: xstateenv; pfuncret: fsptr);
(* <load xfilename>:
   Typical use: To load an x-file before it is called, in order
   to define an output macro so references to it can be compiled.

   <load>
   Cleanup and reload the X-file which was first loaded after last cleanup.

   Typical use:
   <load compile>
   ...
   (do tests)
   (change compile.x)
   ...
   <load>
   ...
   When calling x through xdll (<load ...> returns a number if it fails):
   if <load filename>="" ...
*)
(* <loadfrom groupname,xfilename>:
   Unknown, and appartently unused, function.
   Possible functionality: To load an X-script starting from the path
   groupname (remains to be verified).
*)

(* Rules for finding x source file:
   A. Filenames with a full path will be used as they are (unless superseeded
      acc. to C).
   B. Otherwise, the path hierarchy will be the same as the load hierarchy.
      Example: From top level: <load C:\d1\f1.x>
               in f1.x: <load \d2\f2> loads c:\d1\d2\f2.x
               in f2.x: <load \d21\f21> loads c:\d1\d2\d21\f21.x
               in f1.x: <load f11.x> loads c:d1\f11.x>
      This means that the directory if the currently loaded x file always
      serves as the current directory for nested loads
   C. In order to enable working with "test versions" of a file, the programmer
      can copy a source file to the windows default directory. X will then
      use this file instead. The file path hierarchy shall however not be
      affected by this temporary replacement. Once the test version on the
      default directory is removed, X will again use the normal file in the
      path hierarchy. Assume for example that the file f21.x is available in the
      default directory c:\work. This file will then be used in the above example in
      place of c:\d1\d2\d21\f21.x:
               From top level: <load C:\d1\f1.x> loads C:\d1\f1.x
               in f1.x: <load \d2\f2> loads c:\d1\d2\f2.x
               in f2.x: <load \d21\f21> loads c:\work\f21.x
               in f1.x: <load f11.x> loads c:d1\f11.x>

   To implement this - the program shall function as follows
   1. If pfilename contains a full path (with x:...) - then use it as
      it is.
   2. Else: Add the path of the current x file (xdefaultdir), to the file name. If there
      is no such path (because the file to be loaded is the top x file),
      use the current directory (<cd>). Save the new file path for use in
      later loads.
   3. If the file (without path) is available at the default directory,
      then query the user if he/she wants to use this file instead.
      It is then assumed that the programmer wishes to replace the original
      file by the file on the default directory. This is handled in ioxreset.
   4. When the x file is loaded, restore the xdefaultdir to what
      it was before the x file was loaded.
*)

var
mem: alevalmem;
i,n: alint16;
xfilename: fsptr;
xfilenr: alint16;
visname: string;
dir: string;
xolddefdir: fsptr;
ptr,endpath,arg1,xdptr: fsptr;
fullpath: boolean;
nameStartNr: integer;
saveLoadLocVarEvalLevel: integer;
fileNameSave: fsptr;
line1Save, line2Save: integer;
shortname: boolean;

(* For saving current directory at <load>. *)
dirSave: string;
ior: integer;

begin

alevaluate(pargs,pstateenv,mem,[1..xmaxnarg]);

(* loadLocVarEvalLevel is normally 0 but can be >0 if <load ...> is called from
   a function. It is used to distinguish normal and local variable definitions. *)
saveLoadLocVarEvalLevel:= loadLocVarEvalLevel;
loadLocVarEvalLevel:= locVarEvalLevel;

alLoadLevel:= alLoadLevel+1;

fsnew(xfilename);
fsnew(xolddefdir);

if (pargs.narg=0) and (not alTopLoaded) then
   xScriptError('X(<load>): <load> cannot be recursively called from'
     +' <load ...> or <load> (load not done).')
else if (pargs.narg=0) and (toploadname=NIL) then
   xScriptError('X(<load>): <load> was called when no x filename has been saved'
      + ' from previous <load ...> (load not done).')
(* These two conditions removed 2011-10-26 to allow <load ...> during running of
   a script, e.g. simreccontrol.test:
else if althreadnr<>0 then
  xScriptError('X(<load ...>): <load ...> cannot be called from a thread (load not done).')
else if pstateenv.statenr>0 then
  xScriptError('X(<load ...>): <load ...> cannot be called from a state (load not done).')
*)
else begin

   // Clear caption
   iofrestorecaption;

(* Clear iofspecialcaption (restore standard form caption) and
   update caption. *)

   if xdefaultdir=nil then fsnew(xdefaultdir);
   if xtopdir=nil then fsnew(xtopdir);

   (* 4. Save old x default path to be able to restore it later. *)
   fscopy(xdefaultdir,xolddefdir,eofs);

   if pargs.narg=0 then begin

      (* <load> *)
      (* Use saved x file name. *)
      fscopy(toploadname,xfilename,eofs);

      (* Set xdefaultdir to the directory of the top load file. *)

      (* Cleanup before reload. *)
      alcleanup(pstateenv);

      (* New: Save current directory, change to the directory that was used at load, and then restore
         current directory. The point with this, is that if you load X with a shortcut, and the shortcut
         changes directory after load, then if it tries to read a file during next load, it will try to
         read from the new directory instead of the when from which it was loaded.

         Historical background.
         The purpose is that <load> shall work in the same way as the original <load ...> with
         a shortcut. This means that the current directory has to be the same as it was
         during the original load.

         X is normally started with a shortcut, that also loads the script. Sometimes, this
         shortcut also change the current directory after load. The current directory
         can also be changed after X has been started.

         We want <load> to be equivalent with the original load that was done
         with the shortcut. This means that current directory has to be temporarily set
         to where the shortcut was during <load>, and then restored after <load>.
         *)
      getdir(0,dirSave);

      {$I-}
      ChDir(topLoadCurrentDirectory);
      ior:= IOResult;
      {$I+}
      if ior<>0 then xProgramError('X(alLoad): Script error - Unable to change current ' +
         'directory to '+topLoadCurrentDirectory+' (code '+inttostr(ior)+'='+syserrormessage(ior)+').');
      end

   else if pargs.arg[1]='' then
      xScriptError('X(<load ...>): Filename was expected but it was empty "<load >".')

   else begin

      if alTopLoaded then
         (* Clear memory of if user wants to use local versions of x files. *)
         ioclearlocalfilenamecache;

      (* 1. Find out whether xfilename contains a full path (X:...) or not. *)
      fullpath:= false;
      if ploadfrom then arg1:= pargs.arg[2]
      else arg1:= pargs.arg[1];

      ptr:= arg1;
      while not ((ptr^=':') or (ptr^=eoa)) do fsforward(ptr);
      if ptr^=':' then begin
         fsforward(ptr);
         if (ptr^='\') or (ptr^='/') then fullpath:= true
         else begin
            xScriptError('X(<load ...>): Filename "'+xfstostr(arg1,eoa)+'" specifies device but not full'
               +' path, but X requires a full path if device name is specified.'
               +' File name will therefore be interpreted as "'+xfstostr(ptr,eoa)+'" instead.');
            arg1:= ptr;
            end;
         end;

      (* 1a. Determine if arg1 is short filename (no path). This is used by
         ioxreset to remove path, when looking for internal files. *)
      if fullpath then shortname:= false
      else begin
         // Short name (no path)?
         ptr:= arg1;
         while (ptr^<>'/') and (ptr^<>'\') and (ptr^<>eoa) do fsforward(ptr);
         shortname:= ptr^=eoa;
         end;

      (* 2. Copy current path if necessary. *)
      if not fullpath then begin
         if alTopLoaded then begin
            (* Add windows default path. *)
            GetDir(0,dir);
            alstrtofs(dir,xfilename);
            end
         else
            (* Add current x default directory to xfilename. *)
            fscopy(xdefaultdir,xfilename,eofs);
         ptr:= xfilename;
         fspshend(ptr,'\');
         end;

      (* 3. Add filename from arg1. *)
      fscopy(arg1,xfilename,eoa);

      if alTopLoaded then begin

         // On top level:

         // Update topLoadName from xfilename.
         if toploadname<>NIL then fsdelrest(toploadname)
         else fsnew(toploadname);
         fscopy(xfilename,toploadname,eofs);

         (* Use windows default directory as primary X file source. *)
         getdir(0,workingdir);

         // Save also as topLoadCurrentDirectory.
         topLoadCurrentDirectory:= workingdir;

         (* Cleanup before load from input window. *)
         alcleanup(pstateenv);
         end;
      end; (* narg>=1 *)

   (* Set new x default path for nested loads. *)
   ptr:= xfilename;
   fsforwend(ptr);
   while not ((ptr^='/') or (ptr^='\') or (ptr=xfilename)) do fsback(ptr);
   if not ((ptr^='/') or (ptr^='\')) then
      xProgramError('X(<load '+xfstostr(pargs.arg[1],eoa)+
         '>): Program error - "/" or "\" was expected in path.');
   endpath:= ptr;
   ptr:= xfilename;
   fsdelrest(xdefaultdir);
   xdptr:= xdefaultdir;
   while not (ptr=endpath) do begin
      fspshend(xdptr,ptr^);
      fsforward(ptr);
      end;

   // Save file name and line nr for xImport;
   filenameSave:= xCompileFileName;
   line1Save:= xCompileLine1;
   line2Save:= xCompileLine2;

   (* (new:) Moved to here from after iofUpdateFormCaption *)
   (* Save directory if on top level. *)
   if alTopLoaded then begin
      fsdelrest(xtopdir);
      fscopy(xdefaultdir,xtopdir,eofs);
      end;

   (* Load the file. *)
   if ploadfrom then begin
      xload(alfstostr(pargs.arg[1],eoa),xfilename,shortname,pstateenv,xfilenr);
      namestartnr:= 3;
      end
   else begin
      xload('',xfilename,shortname,pstateenv,xfilenr);
      nameStartNr:= 2;
      end;

   (* Update title in window and save toplevelnr. *)
   if alTopLoaded then begin
      iofupdateFormCaption;
      altoploadnr:= xfilenr;
      end;

   (* Restore x default path *)
   fsdelrest(xdefaultdir);
   fscopy(xolddefdir,xdefaultdir,eofs);

   (* If <load> - restore current directory. *)
   if pargs.narg=0 then begin

      {$I-}
      ChDir(dirSave);
      ior:= IOResult;
      {$I+}
      if ior<>0 then xProgramError('X(alLoad): Program error - Unable to restore current ' +
         'directory to '+dirSave+' (code '+inttostr(ior)+'='+syserrormessage(ior)+').');
      end;


   (* Import names arg2...  *)
   if xfilenr>0 then with pargs do for n:= nameStartNr to narg do begin
      visname:= xfstostr(arg[n],eoa);

      // ximport will need these if an error message needs to be printed:
      xcompilefilename:= filenameSave;
      xcompileline1:= line1Save;
      xcompileline2:= line2Save;

      ximport(xfilenr,visname);
      end;
  end; (* no error *)

fsdispose(xfilename);
fsdispose(xolddefdir);

(* Print usage description? *)
if (alLoadLevel=1) then begin
   if (usageMessage<>nil) and not xCompileErrorActive then begin
      (* <windowClear> *)
      iofclear;
      (* Copied from alwcons: *)
      xevaluate(usageMessage,eofs,xevalwcons,pstateenv,pfuncret);
      iofWritelnToWbuf('');
      iofWriteWbufToResarea(true);
      fsdispose(usageMessage);
      end;
   end;

alLoadLevel:= alLoadLevel-1;

(* Restore loadLocVarEvalLevel. *)
LoadLocVarEvalLevel:= saveLoadLocVarEvalLevel;

aldispose(pargs,mem);

end; (*alload*)


procedure alLoadFile( var pargs:xargblock;
                  var pstateenv: xstateenv;
                  pfuncret: fsptr);
(* <loadFile xfilenamepart1[,filenamepart2...]>:
   Typical use: To use in association of X-files with the x-program
   Since file name may contain commas, these will be interpreted
   as different parameters when the <loadFile ...> command is
   compiled. Therefore, make them one again.

   Example:
   <loadfile N:\STM\Pos 6, Development of STM\Software Development Files\Common\Demo 060130\decode.x>
   Changes to:
   <load N:\STM\Pos 6', Development of STM\Software Development Files\Common\Demo 060130\decode.x>

   Typical usage (in file association):
   "...x.exe" "<loadfile %1>"
*)

var
mem: alevalmem;
i: integer;
nargsave: integer;
filename,filename0: fsptr;
arg1save: fsptr;

begin
fsnew(filename); filename0:= filename;
alevaluate(pargs,pstateenv,mem,[1..xmaxnarg]);

fscopy(pargs.arg[1],filename,eoa);

with pargs do for i:= 2 to narg do begin
    fspshend(filename,',');
    fscopy(arg[i],filename,eoa);
    end;
fspshend(filename,eoa);

nargsave:= pargs.narg;
arg1save:= pargs.arg[1];
pargs.narg:= 1;
pargs.arg[1]:= filename0;

alload(false,pargs,pstateenv,pfuncret);

pargs.narg:= nargsave;
pargs.arg[1]:= arg1save;

aldispose(pargs,mem);

fsdispose(filename);

end; (*alloadfile*)

procedure alremovefromrunningtitle(pevalstr: fsptr);
(* Remove evalstr from running title. Example:
   pevalstr^= "<c starttesting>"
   running title = "<logfunction> <c starttesting> <pollfunction>"
   resulting running title: "<logfunction> <pollfunction>"
*)
var afterp,rtp,remp,startp: fsptr;
found: boolean;
begin

fsnew(afterp);

rtp:= runningtitle;
startp:= rtp;
remp:= pevalstr;
found:= false;

while not (found or (rtp^=eofs)) do begin
  if rtp^<>remp^ then begin
    fsforward(rtp);
    startp:= rtp;
    remp:= pevalstr;
    end
  else begin
    fsforward(remp);
    fsforward(rtp);
    if (remp^=eofs) and ((rtp^=' ') or (rtp^=eofs)) then found:= true;
    end;
  end;


(* If pevalstr was found then startp points at first char of pevalstr in
   runningtitle, and rtp at ' ' or eofs. *)
if found then begin

  // there is something after pevalstr - move it to afterp
  if rtp^<>eofs then begin
    fscopy(rtp,afterp,eofs);
    fsdelrest(rtp);
    end;

  // If there is anything before startp, remove the blank that separates it
  // from pevalstr
  if startp<>runningtitle then begin
    fsback(startp);
    if startp^<>' ' then begin
      xProgramError('X(alremovefromrunningtitle) - program error,'
        +' " " was expected but "'+startp^+'" was found.');
      fsforward(startp);
      end;
    end;
  fsdelrest(startp);
  // Add following strings after the new string.
  fscopy(afterp,startp,eofs);
  end
else xProgramError('X(alremovefromrunningtitle) - program error,'
        +' thread eval string was not found in title.');

fsdispose(afterp);

end; // alremovefromrunningtitle

(* Thread variables: *)
type
threadpar = record (* input parameters to threadfunc *)
   pinp: ioinptr;
   pevalstr: fsptr;
   nr: integer;
   end;

var
tpars: threadpar;
tparsinuse: boolean = False;

const almaxnthreads = 50;

var thread: array[1..almaxnthreads] of record
    state: (free,running,finished);
    handle: integer;
    id: longword;
    end;

var lastthread: alint16; (* Last used record in thread *)

procedure alThreadInit;
begin
alSaveIoPtr:= @saveIo;

(* (new:) *)
alLastIOWasPersistent:= false;

(* (old:)
alLastInWasPersistent:= false;
alLastOutWasPersistent:= false;
*)

end;


procedure threadfunc( parameter: pointer );
var
ptr: ^threadpar;
pinp: ioinptr;
pevalstr: fsptr;
fret: fsptr;
stateenv: xstateenv;
oldStateEnv: xstateEnvPtr;
oldIODummy: xSavedIODataRecord;
nr: integer;
threadnr: integer; /// FPC+


begin

(* count threads. *)
althreadcount:= althreadcount+1;

(* Get exclusive rights. *)
iodisableotherthreads(26);

// (old: moved to after setting althreadnr)iofupdateformcaption;

(* IO functions to be performed after entering a thread. *)
pinp:= nil;
ioEnterThread(pinp);

xInitStateenv(stateenv,pinp);
alSaveIoPtr:= @oldIODummy; // (needed?)

(* (new:) *)
alLastIOWasPersistent:= false;

(* (old:)
alLastInWasPersistent:= false;
alLastOutWasPersistent:= false;
*)

(* iodisableotherthreads; *)


fsnew(fret);

(* 1. Get parameters. *)
ptr:= parameter;
(* pinp:= ptr^.pinp; Not used any more because input is started at cons/bf060330 *)
pevalstr:= ptr^.pevalstr;
althreadnr:= ptr^.nr;

(* 1aa. Add eval string to running title. - (not used any more) *)
(* fscopy(pevalstr,runningtitle,eofs); *)

(* 1a. Release tpars for use by other thread. *)
tparsinuse:= False;

(* 1b. Initialise X thread variables. *)
xThreadInit;

(* ... and xioform and xal. *)
iofThreadInit;
alThreadInit;

(* 1b. Init xstatestack which is used to store debug info for error messages. *)
xstatecalllevel:= 0;

oldStateEnv:= xCurrentStateEnv;
xCurrentStateEnv:= @stateenv;

// (new: Moved from earlier in same procedure
iofupdateformcaption;

try
   (* 2. Evaluate pevalstr. *)
   xevaluate(pevalstr,eofs,xevalnormal,stateenv,fret);

   except on e:exception do begin
      xProgramError(e.message+' X: Error in thread (exception raised). ');
      end;
   end; (* try *)

xCurrentStateEnv:= oldStateEnv;

(* 2a. If anything written to result window - show it. *)
iofWriteWbufToResarea(false);

(* 3. Check that nothing was returned. *)
if stateenv.pars.npar>0 then begin
   xProgramError('thread: Thread eval str returned pars - npars = '
     +inttostr(stateenv.pars.npar)+' (not expected to do so).');
   xresetpn(stateenv);
   end;
if fret^<>eofs then
   (* xScriptError('thread: Thread eval str returned: "'+fstostr(fret)
     +'" (not expected to return anyting).')*);

(* 3a. Remove eval string from title. - (not used any more) *)
(* alremovefromrunningtitle(pevalstr); *)

(* 4. Clean up *)
fsdispose(pevalstr);
fsdispose(fret);

(* IO functions to be performed before leaving a thread. *)
ioLeaveThread(stateenv.cinp);

iofthreadrelease;


(* BFn 111114: Moved from after iofRestoreCaption, because
   ioerrmess... will try to enable/disable other threads so these
   must be disabled before. *)
(* If a fault was discovered in a thread, reset the fault when
   all threads have finished and there is no basic task
   (from enterstring) running. *)
if xfault and (althreadcount=0) and (iofentercallcnt=0) then begin
   xfault:= false;
   xProgramFault:= false;
   ioErrmessWithDebugInfo('X: Terminating evaluation.');
   end;


ioenableotherthreads(26);
thread[althreadnr].state:= finished;

(* count threads. *)
althreadcount:= althreadcount-1;

iofRestoreCaption;
(* (old:) Update caption. * )
iofcheckrestorecaption(True);*)

(* Added 060330: *)
with thread[althreadnr] do if state= finished then begin
      windows.closeHandle(handle);
      state:= free;
      end;

EndThread(0);

end;(*threadfunc*)

procedure althread( var pargs:xargblock;
   var pstateenv: xstateenv; pfuncret: fsptr  );
(* <thread evalstr>:
   Typical use: To run an x statemachine which waits for input without
   locking up the program, but enabling other tasks to be performed
   simultaneously.
   <thread <c stmsimulator>>( * Simulator which runs until stopstm=yes. * )
   ...<set stopstm,yes>

   To get id of current thread (or 0 if not in one): <thread>
*)
var
evalstr: fsptr;
xp:fsptr;
ch: char;
nr,narg,argnr,alen,i,n: integer;

begin

if pargs.narg>0 then begin

   (* Start a new thread. *)

   (* 0. Wait until tpars is free for use. *)
   while tparsinuse do ioEnableAndSleep(10);

   tparsinuse:= true;
   
   (* 1. Close handles for finished threads. *)
   for i:= 1 to lastthread do
     with thread[i] do
       if state= finished then begin
         windows.closeHandle(handle);
         state:= free;
         end;
   
   (* 2. Find a free record. *)
   n:= 1;
   while Not ((thread[n].state=free)
     or (n+1>almaxnthreads) ) do n:= n+1;

   if not (thread[n].state=free) then xScriptError(
      '<thread ...>: Too many threads (>'+inttostr(almaxnthreads)+').')

   else if locvaroffset>0 then xScriptError(
      '<thread ...>: Cannot be called, directly or indirectly, '+
      'from a function that has local variables.')

   else begin

     (* Set read pointer in current input file. *)
     iosetinpsave(pstateenv.cinp);

     thread[n].state:= running;
     if n>lastthread then lastthread:= n;
   
     fsnew(evalstr);
     tpars.pevalstr:= evalstr;
     tpars.pinp:= pstateenv.cinp;
     tpars.nr:= n;
   
     (* Copy arg[1] to evalstr (could this have been done easier by using
        fsback to get arglen?/Bfn 100622) *)
     xp:= pargs.arg[1];
     while not (xp^=eoa) do begin
       fspshend(evalstr,xp^);
       ch:= xp^;
       fsforward(xp);
   
          (* Evaluate <..>-calls. *)
       if ch=char(xstan) then begin
   
         nr:= integer(xp^);
         fspshend(evalstr,xp^);
         fsforward(xp);
         if nr=0 then begin
           (* Long number. *)
           nr:= integer(xp^);
           fspshend(evalstr,xp^);
           fsforward(xp);
           nr:= nr*250 + integer(xp^);
           fspshend(evalstr,xp^);
           fsforward(xp);
           end;
   
         narg:= ORD(xp^);
         fspshend(evalstr,xp^);
         fsforward(xp);
   
         for argnr:= 1 TO narg do begin
           // (new:)
           alen:= integer(xp^)*250;
           fspshend(evalstr,xp^);
           fsforward(xp);
           alen:= alen+integer(xp^);
           fspshend(evalstr,xp^);
           fsforward(xp);
   
           (* (old:)
           alen:= xarglen(xp^);
           fspshend(evalstr,xp^);
           fsforward(xp);
           *)
   
           (* Jump to eoa-mark *)
           for i:= 1 to alen do begin
             fspshend(evalstr,xp^);
             fsforward(xp);
             end;
           if xp^<>eoa then
               xProgramError('althread('+inttostr(nr)
                 +'): Error. Cannot find eoa for arg '
                 +inttostr(argnr)+'.'+'alen='+inttostr(alen)+'.');
   
           (* Go to next argument. *)
           fspshend(evalstr,xp^);
           fsforward(xp);
           end;
   
         (* Remember that the last nul is only there if narg>0: *)
   
         if narg>0 then REPEAT
           argnr:= ORD(xp^);
           fspshend(evalstr,xp^);
           fsforward(xp);
           UNTIL argnr=0;
   
         (* Now, xp points at the character following nul (or narg=0) *)
         end;
       end; (*while xp^<>eoa*)

     (* Start the thread. *)
     thread[n].handle:=
       BeginThread(nil,0,Addr(threadfunc),Addr(tpars),0,thread[n].id);
     end; (* not thread overflow *)
   end

else begin

   (* Return id of current thread, or 0 if not in a thread. *)
   if alThreadnr=0 then fspshend(pfuncret,'0')
   else alinttofs(windows.getCurrentThreadId(),pfuncret);
   end;

end; (*althread*)

procedure alr( var pargs: xargblock;
               var pstateenv: xstateenv; pfuncret: fsptr );
(* <r [str]>:
   Return from a state (after completing current action),
   optionally with a return string (to <c state>).
*)

var mem: alevalmem;

begin
with pstateenv do if (newstatenr<>statenr) then begin
   if (newstatenr<>substatenr) then begin
      if (newstatenr<>0) then begin

         if pargs.narg>0 then
            xScriptError('X(<r ...>): Warning - <r ...> overrides earlier <j ...>.')
         else
            xScriptError('X(<r>): Warning - <r> overrides earlier <j ...>.');
         end;
      end;
   end;

pstateenv.newstatenr:= 0;

if pstateenv.statenr=0 then

   xScriptError('X expects <r ...> to be called only in states (or substates) '+
      'but it was now called in another place.')

else with pargs do if narg>0 then begin

    alevaluate(pargs,pstateenv,mem,[1]);
    // (new:)
    fscopy(arg[1],pstateenv.rstr,eoa);
    // (old:) fscopy(arg[1],pfuncret,eoa);
    aldispose(pargs,mem);
    end;
end;(*alr*)


procedure aldebuglog(pwhere,pname,pvalue: string);
begin
iofWriteToWbuf('In '+pwhere+': '+pname+'='+pvalue+'.');
iofWriteWbufToResarea(false);
end;


procedure alwcons( var pargs:xargblock;
                   var pstateenv: xstateenv; pfuncret: fsptr );
(* <wcons str[,str[,str...]]>:
   Write str to console (terminal).
*)
var a: integer;
begin

(* Handle multiple arguments as comma's in a text. *)
with pargs do for a:= 1 to narg do begin
   xevaluate(pargs.arg[a],eoa,xevalwcons,pstateenv,pfuncret);
   if a<narg then iofWriteToWbuf(',');
   end;
iofWritelnToWbuf('');

iofWriteWbufToResarea(true);

end; (*alwcons*)


procedure alfstorealbig( var ps: fsptr; var pr: REAL );
(* Convert fs to real for big numbers which would cause overflow with
   alfstoreal. Ps points at 1st digit. After, ps
   points just after last digit. *)
var
num,decimal: real; (* whole-number, decimal *)
dividend: real;
begin
num:= ORD(ps^) - ORD('0');
fsforward(ps);
while ps^ IN ['0'..'9'] do begin
     num:= 10*num + ORD(ps^) - ORD('0');
     fsforward(ps);
     end;
decimal:= 0;
dividend:= 1;
if ps^= '.' then begin
    fsforward(ps);
    while ps^ IN ['0'..'9'] do begin
        decimal:= decimal*10 + ORD(ps^) - ORD('0');
        dividend:= dividend*10;
        fsforward(ps);
        end;
    end;
pr:= num + decimal / dividend;
end; (*alfstorealbig*)

procedure alfstoreal( var ps: fsptr; var pr: REAL );
(* Convert fs to real. Ps points at 1st digit. After, ps
   points just after last digit. *)
var
num,decimal: alint32; (* whole-number, decimal *)
dividend: alint32;
overflow: BOOLEAN;
ps0: fsptr;
begin
ps0:= ps;
num:= ORD(ps^) - ORD('0');
overflow:= FALSE;
fsforward(ps);
while (ps^ IN ['0'..'9']) and (not overflow) do begin

     if num < 214748364 then num:= 10*num - ORD('0') + ORD(ps^)
     else overflow:= TRUE;
     fsforward(ps);
     end;
decimal:= 0;
dividend:= 1;
if (ps^= '.') and (not overflow) then begin
    fsforward(ps);
    while (ps^ IN ['0'..'9']) and (not overflow) do begin
        if dividend < 21474836 then begin
            decimal:= decimal*10 + ORD(ps^) - ORD('0');
            dividend:= dividend*10;
            end
        else overflow:= true;
        fsforward(ps);
        end;
    end;
if overflow then begin
    ps:= ps0;
    alfstorealbig(ps,pr);
    end
else begin
    pr:= num;
    pr:= pr + decimal / dividend;
    end;
end; (*alfstoreal*)

procedure alrealtofs( pr: REAL; pdec: alint16; var ps: fsptr );
(* Convert floating point to fs, use pdec decimals. *)
var
wnumstart: fsptr;
wnumdigits: alint16;
insert,save: CHAR;
digit: alint16;

begin

(* Negative? *)
if pr < 0 then begin
    if (pdec=0) and (round(pr)=0) then (* - *)
    else fspshend(ps,'-');
    pr:= -pr;
    end;

wnumstart:= ps;

(* Find out number of digits in whole number part. *)
wnumdigits:= 0;
while (pr >= 1.0) or (wnumdigits=0) do begin
    pr:= pr/10;
    wnumdigits:= wnumdigits+1;
    end;

(* Convert: *)
while (wnumdigits>0) or (pdec>0) do begin
    pr:= pr*10;
    (* Truncate all digits except the last, which is rounded: *)
    if (wnumdigits+pdec)>1 then digit:= TRUNC(pr)
    else digit:= ROUND(pr);
    pr:= pr-digit;
    if digit>10 then begin
        xProgramError(
'X (alrealtofs): Program error - digit = '+inttostr(digit)+'.');
        digit:= 10;
        end;
    if digit=10 then begin
        fspshend(ps,'9');
        fsback(ps);
        while ((ps^='9') or (ps^='.')) and (ps<>wnumstart) do begin
            if ps^='9' then ps^:= '0';
            fsback(ps);
            end;
        (* Now, we are either standing at the start of the whole
           number part, or at a digit <> 9... *)
        if ps^='9' then begin
            (* Start of whole number - change "9" to "10": *)
            ps^:= '0';
            insert:= '1';
            while not (ps^=eofs) do begin
                save:= ps^;
                ps^:= insert;
                insert:= save;
                fsforward(ps);
                end;
            fspshend(ps,insert);
            end (* ps^='9' *)
        else ps^:= CHAR(ORD(ps^)+1);
        end (* digit = 10 *)
    else fspshend(ps,CHAR(digit + ORD('0')));

    (* Count digits. *)
    if wnumdigits>0 then begin
        wnumdigits:= wnumdigits - 1;
        if (wnumdigits=0) and (pdec>0) then fspshend(ps,'.');
        end
    else pdec:= pdec - 1;
    end; (* while *)

(* Check that ps stands at end of string: *)
if ps^<>eofs then fsforwend(ps);

end; (*alrealtofs*)


function calc( ps: fsptr; var perror: boolean): real;
(* Calculate result of an expression.
   Grammar:

   logicexpr:
       logicterm | logicexpr
       logicterm

   logicterm:
       relation & logicterm
       relation

   relation:
       expr > expr
       expr < expr
       expr = expr
       expr

   expr:
       term + expr
       term - expr
       term

   term:
       primary / term
       primary * term
       primary % term
       primary

   primary:
       NUMBER
       - primary
       ! primary
       ( logicexpr )

*)
var
s: fsptr;
currtok: CHAR; (* '0' = initial state, 'F' = Error (failure), 'N' = number,
                  'S' = string (stringconsumed must be set = true after this).
                  'E' = end, '{' = <=, '}' = >=, '#' = !=. *)
numbervalue: REAL;
stringvalue: string;
stringconsumed: boolean;
parlevel: alint16;
r: REAL;
errspec: string;
fname: string;

   procedure gettoken;
   var
   finished: BOOLEAN;
   n: REAL;
   errstr: shortstring;
   nstr: shortstring;
   s1,sptr: fsptr;
   ch: char;
   str: string;

   begin
   finished:= FALSE;

   (* Skip if string not consumed. *)
   if not stringconsumed and (currtok='S') then finished:= true;

   while not finished do begin

      if currtok = 'F' then finished:= true (* failure *)

      else if s^ IN ['0'..'9'] then begin
         s1:= s;
         alfstoreal(s,n);
         if currtok IN
            ['0','+','-','/','*','%','<','=','>','{','}','#','&','|','!','('] then begin
            currtok:= 'N';
            numbervalue:= n;
            finished:= TRUE;
            end
         else begin
            sptr:= s1;
            nstr:= '';
            while not (sptr=s) do begin
               nstr:= nstr + sptr^;
               fsforward(sptr);
               end;
            errspec:= 'Unexp. number: "'+nstr
               +'" - number can only follow +, -, /, *, <, =, >, &, |, ! or (.';
            currtok:= 'F';
            finished:= true;
            end;
         end
      else if s^ IN ['=','|','&'] then begin
         if currtok IN ['N','S',')'] then begin
            currtok:= s^;
            finished:= TRUE;
            end
         else begin
            errspec:= 'Unexpected "'+s^+'" - "'+s^+
              '" can only follow number, string or ).';
            currtok:= 'F';
            finished:= true;
            end;
         fsforward(s);
         end
      else if s^ IN ['+','/','*','%','<','>','!'] then begin
         ch:= s^;
         if ch='!' then begin
            (* Look for !=  *)
            fsforward(s);
            if s^='=' then ch:= '#'
            else fsback(s);
            end;
         if ch='!' then begin
            currtok:= '!';
            finished:= TRUE;
            end
         else if currtok IN ['N',')'] then begin
            if (ch='<') or (ch='>') then begin
               (* Look for >= or <=. *)
               fsforward(s);
               if s^='=' then begin
                  if ch='<' then ch:= '{'
                  else ch:= '}';
                  end
               else fsback(s);
               end;
            currtok:= ch;
            finished:= TRUE;
            end
         // (new:)
         else if (currtok IN ['N','S',')']) and (ch='#') then begin
            // != can follow number, string or ")".
            currtok:= ch;
            finished:= TRUE;
            end
         else begin
            if ch='#' then
               errspec:= 'Unexpected "!=" - "!=" can only follow number, string  or ).'
            else
               errspec:= 'Unexpected "'+ch+'" - "'+ch+'" can only follow number or ).';
            currtok:= 'F';
            finished:= true;
            end;
         fsforward(s);
         end
      else if s^='-' then begin
         currtok:= '-';
         fsforward(s);
         finished:= TRUE;
         end
      else if s^='(' then begin
         if currtok IN
            ['0','-','+','/','*','%','<','=','>','{','}','#','&','|','!','('] then begin
            currtok:= '(';
            parlevel:= parlevel + 1;
            finished:= TRUE;
            end
         else begin
            errspec:= 'Unexpected "(" - "(" can only follow '+
              '+, -, /, *, <, =, >, &, |, ! or (.';
            currtok:= 'F';
            finished:= true;
            end;
         fsforward(s);
         end
      else if s^= ')' then begin
         if parlevel = 0  then begin
            errspec:= 'Error - superflous ")".';
            currtok:= 'F';
            finished:= true;
            end
         else if currtok IN ['N',')','S'] then begin
            parlevel:= parlevel - 1;
            currtok:= ')';
            finished:= TRUE;
            end
         else begin
            errspec:= 'Unexpected ")" - ")" can only follow number or ")".';
            currtok:= 'F';
            finished:= true;
            end;
         fsforward(s);
         end
      else if s^=eoa then begin
         if parlevel > 0 then begin
            errspec:= 'Missing ")" at end.';
            //currtok:= ')';
            currtok:= 'F';
            parlevel:= parlevel - 1;
            end
         else currtok:= 'E';
         finished:= TRUE;
         end
      // (new:)
      else if (fsLcWsTab[s^]=' ') or (s^=CHAR(13)) then
      // (old:) else if (s^=' ') or (s^=CHAR(9)) or (s^=CHAR(13)) then
         fsforward(s) (* (ignore) *)
      else if s^ IN ['A'..'Z','a'..'z'] then begin
         (* Boolean literal or string. *)
         while s^ IN ['0'..'9','A'..'Z','a'..'z'] do begin
            ch:= s^;
            if ch in ['a'..'z'] then ch:= char(integer(ch)-integer('a')+integer('A'));
            str:= str + ch;
            fsforward(s);
            end;

         // (new:)
         str:= ansiLowerCase(str);
         if (str='yes') or (str='true') then begin
            currtok:= 'N';
            numbervalue:= 1.0;
            finished:= TRUE;
            end
         else if (str='no') or (str='false') then begin
            currtok:= 'N';
            numbervalue:= 0.0;
            finished:= TRUE;
            end
         else if currtok in ['0','=','#','&','|','('] then begin
            currtok:= 'S';
            stringvalue:= str;
            stringconsumed:= false;
            finished:= TRUE;
            end

         else begin
            errspec:= 'Unexpected string: "'+str+
             '" - string can only follow ''='',''#'',''&'',''|'' or ''(''.';
            currtok:= 'F';
            finished:= true;
            end;
         end (* string *)
      else begin (* illegal character *)
         errstr:= '';
         // (new:)
         while not ( (s^ IN ['0'..'9','+','-','/','*','%','<','=',
         // (old:) while not ( (s^ IN [' ','0'..'9','+','-','/','*','%','<','=',
            // (new:)
            '>','&','|','!','(',')']) or (fsLcWsTab[s^]=' ') or (s^=CHAR(13)) or
            // (old:) '>','&','|','!','(',')']) or (s^=CHAR(9)) or (s^=CHAR(13)) or
            (s^=eoa) ) do begin
            if length(errstr)<250 then errstr:= errstr+s^;
            fsforward(s);
            end;
         errspec:= 'Illegal character(s) - "'
            +errstr+'".';
         currtok:= 'F';
         finished:= true;
         end; (* else *)
      end; (* while *)
   end; (*gettoken*)

   FUNCTION prim: REAL; FORWARD;
   FUNCTION term: REAL; FORWARD;
   FUNCTION expr: REAL; FORWARD;
   FUNCTION relation: REAL; FORWARD;
   FUNCTION logicterm: REAL; FORWARD;

   FUNCTION logicexpr: REAL;
   var
   left: REAL;
   finished: BOOLEAN;
   begin
   left:= logicterm;
   finished:= FALSE;
   while not finished do begin
      if currtok = '|' then begin
         left:= abs(left) + abs(logicterm);
         if left > 1.0 then left:= 1.0;
         end
      else finished:= TRUE;
      end;
   logicexpr:= left;
   end; (*logicexpr*)

   FUNCTION logicterm: REAL;
   var
   left: REAL;
   finished: BOOLEAN;
   begin
   left:= relation;
   finished:= FALSE;
   while not finished do begin
      if currtok = '&' then begin
         left:= left * relation;
         if left > 1.0 then left:= 1.0;
         end
      else finished:= TRUE;
      end;
   logicterm:= left;
   end; (*logicterm*)

   FUNCTION relation: REAL;
   var
   left,right: REAL;
   leftstr: string;
   diff: REAL;
   prevtok: char;
   begin
   left:= expr;
   if currtok ='>' then begin
      if left > expr then left:= 1.0
      else left:= 0.0;
      end
   else if currtok = '<' then begin
      if left < expr then left:= 1.0
      else left:= 0.0
      end
   else if currtok ='}' then begin (* >= *)
      right:= expr;
      if left >= right then left:= 1.0
      else left:= 0.0;
      end
   else if currtok = '{' then begin (* <= *)
      if left <= expr then left:= 1.0
      else left:= 0.0
      end
   else if currtok = '#' then begin (* != *)
      if left <> expr then left:= 1.0
      else left:= 0.0
      end
   else if currtok = '=' then begin
      diff:= left - expr;
      (* BFn 2020-04-13: This is a little controversial and not
         consistent with != and is known to cause problems. *)
      if (diff < 0.5) and (diff > -0.5) then left:= 1
      else left:= 0;
      end
   else if currtok = 'S' then begin
      (* String comparison. *)
      leftstr:= stringvalue;
      stringconsumed:= true;
      gettoken;
      if currtok = 'F' then
         (* Error already reported. *)
      else if currtok in ['=','#'] then begin
         prevtok:= currtok;
         gettoken;
         if currtok = 'F' then
            (* Error already reported. *)
         else if currtok = 'S' then begin
            if leftstr = stringvalue then begin
               // Strings are equal
               if prevtok='=' then left:= 1.0 else left:= 0.0;
               end
            else begin
               // Strings are different
               if prevtok='=' then left:= 0.0 else left:= 1.0;
               end;
            stringconsumed:= true;
            gettoken;
            end
         else begin
            errspec:= 'String value expected,' +currtok+ ' seen. (exits)';
            currtok:= 'F';
            left:= 0.0;
            end;
         end
      else if (currtok='&') or (currtok='|') or (currtok='E') or (currtok=')') then begin
         leftstr:= ansiLowerCase(leftstr);
         if (leftstr='yes') or (leftstr='true') then
            left:= 1.0
         else if (leftstr='no') or (leftstr='false') then
            left:= 0.0
         else begin
            errspec:= '"yes", "no", "true" or "false" ' +
               'expected before ' +currtok+'. "'+leftstr+'" seen. (exits)';
            currtok:= 'F';
            left:= 0.0;
            end;
         end
      else if (currtok<>'F') then begin
         errspec:= '"=", "&", "|" or ")" expected after string, ' +
            currtok + ' seen. (exits)';
         currtok:= 'F';
         left:= 0.0;
         end;
      end;

   relation:= left;
   end; (*relation*)

   FUNCTION expr: REAL;
   var
   left: REAL;
   finished: BOOLEAN;
   begin
   left:= term;
   finished:= FALSE;
   while not (finished or (currtok='F')) do begin
      if currtok = '+' then left:= left + term
      else if currtok = '-' then left:= left - term
      else finished:= TRUE;
      end;
   expr:= left;
   end; (*expr*)

   FUNCTION term: REAL;
   var
   left: REAL;
   d: REAL;
   finished: BOOLEAN;
   begin
   left:= prim;
   finished:= FALSE;
   while not (finished or (currtok='F')) do begin
      if currtok = '*' then left:= left * prim
      else if currtok = '/' then begin
         d:= prim;
         if d=0 then left:= 2147483647
         else left:= left / d;
         end
      else if currtok = '%' then begin
         d:= prim;
         if d=0 then left:= 0
         else left:= left - trunc(left / d) * d;
         end
      else finished:= TRUE;
      end;
   term:= left;
   end; (*term*)

   FUNCTION prim: REAL;
   var
   v: REAL;
   begin
   gettoken;
   if currtok = 'F' then
      (* Error already reported. *)
      prim:= 0.0
   else if  currtok = 'N' then begin
      v:= numbervalue;
      gettoken;
      prim:= v;
      end
   else if currtok = '-' then
      prim:= -prim
   else if currtok = '!' then begin
      if prim = 0 then prim:= 1 else prim:= 0;
      end
   else if currtok = '(' then begin
      v:= logicexpr;
      if currtok = 'F' then
         (* Error already reported. *)
      else if currtok <> ')' then begin
         errspec:= '")" expected, ' + currtok+' seen.';
         currtok:= 'F';
         end
      else gettoken;
      prim:= v;
      end
   else if currtok = 'S' then
      (* Do nothing. primstr shall be used to get the string. *)
      prim:= 0.0
   else begin
      errspec:= 'Primary expected, '+currtok+' seen.';
      prim:= 0.0;
      currtok:= 'F';
      end;
   end; (*prim*)


begin (*calc*)

s:= ps;
currtok:= '0';
errspec:= '';
stringconsumed:= true;
parlevel:= 0;
gettoken;
r:= 0.0;

if currtok = 'F' then
   (* Error already reported. *)
else if currtok IN ['N','S','(','-','!'] then begin

   (* There is something here, back and call logicexpr: *)
   s:= ps;
   currtok:= '0';
   parlevel:= 0;
   r:= logicexpr;
   if currtok='F' then r:= 0.0;

   (* Any illegal stuff at the end? Gettoken will check this. *)
   while not ((currtok = 'E') or (currtok = 'F')) do begin
      gettoken;
      // Handle 'S' here to  avoid eternal loop
      if currtok='S' then begin
          currtok:= 'F';
          errspec:= 'Unexpected string value:"'+stringvalue+'"';
          end;
      end;
   end

else if currtok = 'E' then r:= 0.0

else begin
   currtok:= 'F';
   errspec:= 'Illegal expression';
   end;

calc:= r;
perror:= (currtok='F');

if perror then begin
   fname:= xname(xCurrentStateEnv^.funcnr);
   // (new;)
   xScriptError('Error in arithmetic expression: "' +
   alfstostr(ps,eoa) +
   '". ' + errspec);
   // (old:) xScriptError('Error in arithmetic expression. ' + errspec);
   end;

end; (*calc*)


procedure alcalc( var pargs: xargblock;
                  var pstateenv: xstateenv; var pfuncret: fsptr );
(* <calc expr[,decimals]>:
   Evaluate an algebraic expression.
*)
var
mem: alevalmem;
decimals: alint16;
arg2err: boolean;
r: real;
error: boolean;

begin (*alcalc*)

alevaluate(pargs,pstateenv,mem,[1,2]);

(* Check that number of decimals is ok. *)
arg2err:= false;
with pargs do begin
   if narg < 2 then decimals:= 0
   else begin
      decimals:= fsposint(arg[2]);
      if decimals<0 then begin
         xScriptError('X(<calc '+alfstostr100(arg[1],eoa)+
            ',decimals>): Decimals shall be a number >=0, found "'+
            alfstostr100(arg[2],eoa)+'".');
         decimals:= 0;
         arg2err:= true;
         end;
      end; (* narg >= 2 *)
   end; (* with, if *)

if arg2err then r:= 0
else r:= calc(pargs.arg[1],error);

alrealtofs(r,decimals,pfuncret);

aldispose(pargs,mem);

end; (*alcalc*)


procedure alMax( var pargs: xargblock;
                  var pstateenv: xstateenv; var pfuncret: fsptr );
(* <calc expr1,expr2[,decimals]>:
   Evaluate an algebraic expressions expr1 and expr2 and return the
   highest.
   Example:
   <set $a,1.9>
   <max $a-2.3,0,1> => 0
   <max $a-1.3,0,1> => 0.6
*)
var
mem: alevalmem;
decimals: alint16;
arg2err: boolean;
r1,r2: real;
error: boolean;

begin (*alMax*)

alevaluate(pargs,pstateenv,mem,[1..3]);

(* Check that number of decimals is ok. *)
arg2err:= false;
with pargs do begin
   if narg < 3 then decimals:= 0
   else begin
      decimals:= fsposint(arg[3]);
      if decimals<0 then begin
         xScriptError('X(<calc '+alfstostr100(arg[1],eoa)+
            ',decimals>): Decimals shall be a number >=0, found "'+
            alfstostr100(arg[3],eoa)+'".');
         decimals:= 0;
         arg2err:= true;
         end;
      end; (* narg >= 3 *)
   end; (* with, if *)

if arg2err then r1:= 0
else begin
  r1:= calc(pargs.arg[1],error);
  r2:= calc(pargs.arg[2],error);
  if r2>r1 then r1:= r2;
  end;

alrealtofs(r1,decimals,pfuncret);

aldispose(pargs,mem);

end; (*alMax*)


procedure alabs( var pargs: xargblock;
                  var pstateenv: xstateenv; var pfuncret: fsptr );
(* <abs expr[,decimals]>:
   Like <calc ...> except it negates the result if it
   is negative, to make it positive.
*)
var
mem: alevalmem;
decimals: alint16;
arg2err: boolean;
r: real;
error: boolean;

begin (*alabs*)

alevaluate(pargs,pstateenv,mem,[1,2]);

(* Check that number of decimals is ok. *)
arg2err:= false;
with pargs do begin
   if narg < 2 then decimals:= 0
   else begin
      decimals:= fsposint(arg[2]);
      if decimals<0 then begin
         xScriptError('X(<calc '+alfstostr100(arg[1],eoa)+
            ',decimals>): Decimals shall be a number >=0, found "'+
            alfstostr100(arg[2],eoa)+'".');
         decimals:= 0;
         arg2err:= true;
         end;
      end; (* narg >= 2 *)
   end; (* with, if *)

if arg2err then r:= 0
else r:= calc(pargs.arg[1],error);

if r<0.0 then r:= -r;

alrealtofs(r,decimals,pfuncret);

aldispose(pargs,mem);

end; (*alabs*)



procedure alfsstrtoreal( var ps: fsptr; var pr: REAL );
(* Convert fs to real. Ps points at 1st digit. After, ps
   points just after last digit. *)
var
num,decimal: alint32; (* whole-number, decimal *)
dividend: alint32;
overflow: BOOLEAN;
ps0: fsptr;
begin
ps0:= ps;
num:= ORD(ps^) - ORD('0');
overflow:= FALSE;
fsforward(ps);
while (ps^ IN ['0'..'9']) and (not overflow) do begin
     if num < 214748364 then num:= 10*num + ORD(ps^) - ORD('0')
     else overflow:= TRUE;
     fsforward(ps);
     end;
decimal:= 0;
dividend:= 1;
if (ps^= '.') and (not overflow) then begin
    fsforward(ps);
    while (ps^ IN ['0'..'9']) and (not overflow) do begin
        if decimal < 21474836 then begin
            decimal:= decimal*10 + ORD(ps^) - ORD('0');
            dividend:= dividend*10;
            end
        else overflow:= true;
        fsforward(ps);
        end;
    end;
if overflow then begin
    ps:= ps0;
    alfstorealbig(ps,pr);
    end
else begin
    pr:= num;
    pr:= pr + decimal / dividend;
    end;
end; (*alfsstrtoreal*)

procedure alsqrt( var pargs: xargblock; 
                  var pstateenv: xstateenv; var pfuncret: fsptr );
(* <sqrt expr[,decimals]>:
   Evaluate expr and return its square root.
*)

var
fr,fr0: fsptr;
r: REAL;
count,decimals: alint16;

begin (*alsqrt*)

(* Save pointer to where alcalc will put its return value. *)
fr:= pfuncret;

alcalc(pargs,pstateenv,pfuncret);

(* Get value calculated by calc. *)
fr0:= fr; (* (alfstoreal increments fr) *)
alfstoreal(fr,r);

(* Get number of decimals by counting digits from end of funcret. *)
count:= 0;
decimals:= 0;
while not (pfuncret=fr0) do begin
  fsback(pfuncret);
  if pfuncret^='.' then decimals:= count;
  count:= count+1;
  end;

(* Calculate square root. *)
r:= sqrt(r);

(* Replace result from alcalc with r. *)
pfuncret:= fr0;
fsdelrest(pfuncret);
alrealtofs(r,decimals,pfuncret);

end; (*alsqrt*)

procedure alRegisterFunctions; Forward;
(* Register predefined functions. *)

var speccharwarningissued: boolean = False; (* Used by alhtos *)


procedure alcleanup( var pstateenv: xstateenv );
(* <cleanup>:
   Run the X-code specified by <atcleanup>
   Seldom used function.
   Probably not safe to call when there are threads running!!
*)
var str: string; ch: char;
begin

(* Do script specified <atcleanup ...> cleanup .*)
(* (Note that alatcleanup requires args.narg to be = 0 to execute the
   atcleanup code.) *)
str:= '<atcleanup>';

// Compile and run string, dont lock x because it is already locked.
iofenterstring(pstateenv,str,false);

if althreadnr<>0 then
   xScriptError('X(<cleanup>): <cleanup> cannot be called from a thread (cleanup not done).')
else if pstateenv.statenr>0 then
   xScriptError('X(<cleanup>): <cleanup> cannot be called from a state (cleanup not done).')
else begin
   (* Close io files. *)
   iocleanup(pstateenv.cinp);

   (* Clear states. *)
   xclearxfiles;

   (* Clear function and macro names. *)
   xcleartab;

   xUseIndentation:= false;

   (* Redefine predefined functions. *)
   alRegisterFunctions;

   (* Clear bits. *)
   alBitsClear;

   (* Clear indexes. *)
   alindexreset;

   (* Clear special character warning flag. *)
   speccharwarningissued:= false;

   // Casewarning shall be default.
   // alcasewarning:= false;

   alWin32WindowProc:= 0;

   (* Delete top level window(s) of the class "xwindowclass" if any. *)
   iofCleanup;

   (* Clear flags. *)
   for ch:= 'A' TO 'Z' do flagTab[ch]:= FALSE;

   (* Usage message. *)
   if usageMessage<>nil then fsdispose(usageMessage);

   (* Apparently, mactab is not erased here.
      Instead, each entry is released when redefined (see aldef). *)


   end;

   fsAllowNewlineInBinaryInput(AllowNewlineInBinaryInput);

end;


procedure alanything( var pstateenv: xstateenv );
(* <anything>*:
   Matches anything, to the end of the string or file.
*)

begin (*alanything*)

while not (pstateenv.cinp^=char(fseofs)) do begin
    if pstateenv.cinp^=eofr then ioingetinput(pstateenv.cinp,true);
    if pstateenv.cinp^<>char(fseofs) then ioinforward(pstateenv.cinp);
    end;

end; (*alanything*)


type ch1array = array[1..xmaxnarg] of char;

(* (new:) *)

procedure getch1array( var pargs: xargblock;
   var pch1: ch1array; (* Out: First char of each arg (or 1st char in a variable). *)
   var pemptyArgFound: boolean (* Out: Empty arg was found (indicates
      that anything is accepted) . *)
   );

(* Put the first char of each arg, in array pch1.
   If first char was stan and stan points at a variable, then
   put the first char of the variable instead.
   Also check if there is any empty arg, and put result of this check
   in pEmptyArgFound. *)

var
i: alint16;
aptr: fsptr;
mch1: char;
m: alint16;

begin

pEmptyArgFound:= false;

(* What is the first character of each argument? (speedup) *)
with pargs do for i:= 1 to narg do begin
    pch1[i]:= arg[i]^;
    aptr:= arg[i];
    if aptr^=char(xstan) then begin
         fsforward(aptr);
         m:= ord(aptr^);
         if m=0 then begin
             (* Long number. *)
             fsforward(aptr);
             m:= alint16(aptr^);
             fsforward(aptr);
             m:= m*250 + integer(aptr^);
             end;

         if mactab[m]<>nil then begin
            if integer(mactab[m])>alIndexMaxNr then begin
                mch1:= mactab[m]^;
                if (mch1<>char(eoa)) and (mch1<>'$') and (mch1<>'&')
                then pch1[i]:= mch1;
                end
            else begin
               // (new - copied from old x:)
               // (Was this deliberately removed from Xgui?)
               mch1:= mactab[m]^;
               if (mch1<>char(eoa)) and (mch1<>'$') and (mch1<>'&')
               then pch1[i]:= mch1;
               end;
            end;
         end (*xstan*)
    (* Empty arg means accept anything. *)
    else if aptr^=eoa then pemptyArgFound:= True
    else if aptr^=char(13) then begin
        (* Accept end of file as end of line. *)
        (* fsforward(aptr);
        if aptr^=eoa then pemptyArgFound:= True; *)
        (* Removed because it causes loops when ?"<to
        >"?
        !""! is used. *)
        end
    end;

end; (*getch1array*)


procedure alto( var pargs: xargblock;
   var pstateenv: xstateenv;
   pwholeword: boolean;
   pWithinLine: boolean;
   pfuncret: fsptr);
(* <to str1,str2,...>*:
   Accept all input to but not including any of strings str1, str2,...
*)
(* <towholeword str1,str2,...>*:
   - like <to ...> except that it only accepts a whole word - the string
   must not have a letter or digit before or after it.
*)
(* <to_wholeword str1,str2,...>*:
   Renamed to <toWholeword str1,str2,...>.
   Temporarily supported for backwards compatibility.
*)
(* <towithinLine str1,str2,...>*:
   - Like <to ...> except that it only looks within the current line,
   which ends either at a line delimiter or eof.
*)
(* <to_withinLine str1,str2,...>*:
   Renamed to <toWithinline str1,str2,...>.
   Temporarily supported for backwards compatibility.
*)
(* <towl str1,str2,...>*:
   New shorter name for <towithinline ...>.
*)

var
found,equal: BOOLEAN;
i: alint16;
inp1,inp2,saveinp: ioinptr;
inptr,lastchptr: ioinptr;
cnt: integer;
ch1: ch1array;
endoffile: boolean;
oldlastpos: ioinptr;
emptyArgFound: boolean;
nch: integer;
checkproperly: Boolean;
argptr: fsptr;

begin (*alto*)

found:= FALSE; inp1:= pstateenv.cinp;
oldlastpos:= ioinlastpos;

(* What is the first character of each argument? (speedup) *)
getch1array(pargs,ch1,emptyArgFound);

(* Added for <towl>. (/BFn 210527) *)
if pWithinLine then
   if pargs.narg=0 then emptyArgFound:= true;

(* Check for each character in input stream ... *)
if inp1=nil then
   xProgramError('x(alto): inp1=nil!!!');

endoffile:= false;
while not ( found or endoffile ) do with pargs do begin

   (* Check all search strings and possible additional char in ch1 array
        (see getch1array). *)

   i:= 1;
   while not ((i>narg) or found) do begin
      (* (new:) Skip preliminary evaluation if waiting for data, otherwise e.g.
         <to <eofr>> will block here. *)
      checkproperly:= False;
      if inp1^=eofr then begin
         if ioinreadable(inp1) then ioingetinput(inp1,true)
         else begin
            argptr:= arg[i];
            checkproperly:= true;
            end;
         end;
      if checkProperly then
         (* Skip the first prelimary evaluation. *)
      else begin

         (* First preliminary evaluation using ch1: *)
         if (inp1^=xcommentasblank) and (xcommentasblank<>' ') then begin
            (* Move to end of comment. *)
            ioskipcomment(inp1,xlinecommentasblank);
            (* Check that ch1=blank *)
            if ch1[i]=' ' then begin
               (* Check it properly. *)
               argptr:= arg[i];
               fsforward(argptr);
               checkproperly:= True;
               end;
            end (* = xcommentasblank *)

         else if inp1^=ch1[i] then begin
            checkproperly:= True;
            argptr:= arg[i];
            end (* match in ch1[i] *)
         else if
            (* (from xx.pas) Optional case-insensitive equality. *)
            ((((ord(inp1^) xor ord(ch1[i])) and xcasemask)
            or (not ord(inp1^) and $40)) = 0)
            or (ch1[i]=char(xstan)) or (inp1^=eofr)
            or (inp1^=xoptcr) or (inp1^=xoptcr2)
            then begin

            checkproperly:= True;
            argptr:= arg[i];
            end (* match in ch1[i] *)
         else if (ch1[i]=char(13)) then begin
            if (inp1^=char(10)) then begin
               checkproperly:= True;
               argptr:= arg[i];
               end; (* match in ch1[i] *)
            end;
         end;//(not checkProperly)

      // To please the compiler:
      inp2:= pstateenv.cinp;
      lastchptr:= pstateenv.cinp;

      if checkproperly then begin
         saveinp:= pstateenv.cinp;
         pstateenv.cinp:= inp1;
         xcompare(argptr,eoa,false,false,pstateenv,equal);
         inp2:= pstateenv.cinp;
         pstateenv.cinp:= saveinp;
         if equal then begin
            found:= true;
            if pwholeword then begin
               inptr:= inp1;
               lastchptr:= inp1;
               while not (inptr=inp2) do begin
                  lastchptr:= inptr;
                  ioinforward(inptr);
                  end;
               end; (* pwholeword *)
            end; (*equal*)
         checkproperly:= False;
         end; (* checkproperly *)

      i:= i+1;
      end; (* while *)

    (* Wholeword: Check that next char is not a letter or digit if last char is
       (we must allow a last char being non letter/digit because
       it is often necessary to search for single characters such
       as new-line, at the same time as searching for a word).
       BF 2007-05-22: Accept "_" as letter (code 95), because it is allowed
       in identifiers. *)
   if pwholeword then if found and (
        ((lastchptr^>=char(48)) and (lastchptr^<=char(57)))
          or ((lastchptr^>=char(65)) and (lastchptr^<=char(90)))
          or (lastchptr^=char(95))
          or ((lastchptr^>=char(97)) and (lastchptr^<=char(122)))
          or ((lastchptr^>=char(192)) and (lastchptr^<>char(215))
             and (lastchptr^<>char(247)) and (inp1<>inp2))
          ) then begin
          if inp2^=eofr then ioingetinput(inp2,true);
          if ((inp2^>=char(48)) and (inp2^<=char(57)))
            or ((inp2^>=char(65)) and (inp2^<=char(90)))
            or (inp2^=char(95))
            or ((inp2^>=char(97)) and (inp2^<=char(122)))
            or ((inp2^>=char(192)) and (inp2^<>char(215))
               and (inp2^<>char(247)) and (inp2^<>char(fseofs)))
            then found:= false;
        end;

    if inp1^=eofs then endoffile:= true
    else if pWithinLine then begin
       if (inp1^=char(13)) or (inp1^=char(10)) then endoffile:= true
       else if not found then
          (* Otherwise, just move one step ahead. *)
          ioinforward(inp1);
       end
    else if not found then begin
        cnt:= 0;
        if pwholeword then begin
          (* Read past rest of word (if it starts with a letter). *)
          while ((inp1^>=char(48)) and (inp1^<=char(57)))
            or ((inp1^>=char(65)) and (inp1^<=char(90)))
            or (inp1^=char(95))
            or ((inp1^>=char(97)) and (inp1^<=char(122)))
            or ((inp1^>=char(192)) and (inp1^<>char(215))
            and (inp1^<>char(247))) do begin
            ioinforward(inp1);
            if inp1^=char(eofr) then ioingetinput(inp1,true);
            cnt:= cnt + 1;
            end;
          end;
        (* Otherwise, just move one step ahead. *)
        if cnt=0 then begin
          ioinforward(inp1);
          (* Not necessary:? - Removed to enable using <to <eofr>>/Bf 070315. *)
          (* if inp1^=char(eofr) then ioingetinput(inp1,true); *)
          end;
        end;
    end;

(* Empty arg accepts anything. *)
if not found and emptyArgFound then found:= true;

if not found then begin (* eof reached without success *)
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    (* Restore ioinlastinpos. *)
    ioinlastpos:= oldlastpos;
    end
else pstateenv.cinp:= inp1;

end; (*alto*)


procedure alformat( var pargs: xargblock;
                    var pstateenv: xstateenv; pfuncret: fsptr);
(* <format xxx...>*:
   where x = d shall be digit
             l          letter
             x          any character (not ctrl-char)
*)

var fch,ich: CHAR; a: fsptr;
mem: alevalmem;
equal: BOOLEAN;
inp: ioinptr;

begin (*alformat*)

alevaluate(pargs,pstateenv,mem,[1]);

inp:= pstateenv.cinp;
equal:= TRUE;

a:= pargs.arg[1];

while not ( (a^=char(xeoa)) or (inp^=char(fseofs)) or not equal ) do begin

   if inp^=eofr then ioingetinput(inp,true);
   fch:= a^;
   if fch IN ['a'..'z',char($E5), char($E4),char($F6)(*'å','ä','ö'*)] then
      fch:= char( ORD(fch) - 32 );
   ich:= inp^;
   if ich IN ['a'..'z',char($E5), char($E4),char($F6)(*'å','ä','ö'*)] then
      ich:= char( ORD(ich) - 32 );

   if ( (fch='D') and not (ich IN ['0'..'9']) )
   or ( (fch='H') and not (ich IN ['0'..'9','A'..'F']) )
   or ( (fch='X') and not (* (new:) *)(integer(ich)<integer(eofr)) )
      // (old:) not ( (integer(ich) >= integer(' ')) and (integer(ich)<integer(eofr)) ) )
   or ( (fch='L') and
      not (ich IN ['A'..'Z',char($C5),char($C4),char($D6)(*'Å','Ä','Ö'*)]) )
   or ( not (fch IN ['D','H','L','X']) and not (ich=fch) )
      then equal:= FALSE
   else begin
      fsforward(a);
      ioinforward(inp);
      end;
   end;

if not (a^=char(xeoa)) then equal:= FALSE;

aldispose(pargs,mem);

if not equal then begin
   if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
   else fspshend(pfuncret,'#');
   end
else pstateenv.cinp:= inp;

end; (*alformat*)


(* (new:) *)
procedure alinteger( var pargs: xargblock;
                     var pstateenv: xstateenv; pfuncret: fsptr);
(* <integer [i1[,i2]]>*:
   Matches an integer, optionally limited by i1 and i2.
*)
var
minus: BOOLEAN;
mem: alevalmem;
inp: ioinptr;
argp: fsptr;
error: boolean;
i1,i2: integer;
equal: boolean;
r: real;

begin

alevaluate(pargs,pstateenv,mem,[1,2]);

with pargs do begin

    inp:= pstateenv.cinp;

    if inp^=eofr then ioingetinput(inp,true);
    if inp^='-' then begin
        minus:= TRUE;
        ioinforward(inp);
        if inp^=eofr then ioingetinput(inp,true);
        end
    else minus:= FALSE;

    if not (inp^ IN ['0'..'9']) then equal:= FALSE
    else begin
        equal:= TRUE; r:= 0.0;
        while (inp^ IN ['0'..'9']) do begin
            r:= r*10 + ORD(inp^) - ORD('0');
            ioinforward(inp);
            if inp^=eofr then ioingetinput(inp,true);
            end;
        if minus then r:= -r;
        end;

   (* Test i1 if there is one. *)
   if equal and (narg>0) then begin
      (* get i1 *)
      argp:= arg[1];
      error:= False;
      while (argp^=' ') do fsforward(argp);
      if (argp^=eoa) then
         (* - (Empty arg1 = no lower limit) *)

      else begin
         if argp^='-' then begin
            fsforward(argp);
            i1:= fsposint(argp);
            if i1<0 then error:= true
            else i1:= -i1;
            end
         else begin
            i1:= fsposint(argp);
            if i1<0 then error:= true;
            end;
         if error then begin
             equal:= false;
             xProgramError('<integer ...>: Integer expected as arg 1, found "'+
                alfstostr100(arg[1],eoa)+'".');
             end
          else if not (r>( i1 - 0.5 )) then equal:= FALSE
          end; (* narg>0 *)
      end; (* equal and narg>0)

   (* Test i2 if there is one. *)
   if equal and (narg>1) then begin
      (* get i2 *)
      argp:= arg[2];
      error:= False;
      while (argp^=' ') do fsforward(argp);
      if (argp^=eoa) then
         (* - (Empty arg1 = no lower limit) *)
      else begin
         if argp^='-' then begin
            fsforward(argp);
            i2:= fsposint(argp);
            if i2<0 then error:= true
            else i2:= -i2;
            end
         else begin
            i2:= fsposint(argp);
            if i2<0 then error:= true;
            end;
         if error then begin
            equal:= false;
            xProgramError('<integer ...>: Integer expected as arg 2, found "'+
               alfstostr100(arg[2],eoa)+'".');
            end
         else if not (r<( i2 + 0.5 )) then equal:= FALSE;
         end;// (else)
      end; // (equal and narg>1)

   end; (*with*)

aldispose(pargs,mem);

if not equal then begin
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end
else pstateenv.cinp:= inp;

end; (*alinteger*)

procedure alDecimal( var pargs: xargblock;
                     var pstateenv: xstateenv; pfuncret: fsptr);
(* <decimal [d1[,d2]]>*:
   Matches a decimal, optionally limited by d1 and d2.
   d1 and d2 currently only accepting integer numbers.
*)
var
minus: BOOLEAN;
mem: alevalmem;
inp: ioinptr;
argp: fsptr;
error: boolean;
i1,i2: integer;
equal: boolean;
r: real;
divider: integer;

begin

alevaluate(pargs,pstateenv,mem,[1,2]);

with pargs do begin

    inp:= pstateenv.cinp;

    if inp^=eofr then ioingetinput(inp,true);
    if inp^='-' then begin
        minus:= TRUE;
        ioinforward(inp);
        if inp^=eofr then ioingetinput(inp,true);
        end
    else minus:= FALSE;

    if not (inp^ IN ['0'..'9']) then equal:= FALSE
    else begin
        equal:= TRUE; r:= 0.0; divider:= 0;
        while (inp^ IN ['0'..'9']) do begin
            r:= r*10 + ORD(inp^) - ORD('0');
            divider:= divider*10;
            ioinforward(inp);
            if inp^=eofr then ioingetinput(inp,true);
            if divider=0 then begin
               if inp^='.' then begin
                  divider:= 1;
                  ioinforward(inp);
                  if inp^=eofr then ioingetinput(inp,true);
                  end;
               end;
            end;
        if divider>0 then r:= r/divider
        else equal:= false; (* No "." = not a decimal. *)
        if minus then r:= -r;
        end;

   (* Test i1 if there is one. *)
   (* +++ This part is not updated for decimal limits./BFn 2021-05-18 *)
   if equal and (narg>0) then begin
      (* get i1 *)
      argp:= arg[1];
      error:= False;
      while (argp^=' ') do fsforward(argp);
      if (argp^=eoa) then
         (* - (Empty arg1 = no lower limit) *)

      else begin
         if argp^='-' then begin
            fsforward(argp);
            i1:= fsposint(argp);
            if i1<0 then error:= true
            else i1:= -i1;
            end
         else begin
            i1:= fsposint(argp);
            if i1<0 then error:= true;
            end;
         if error then begin
             equal:= false;
             xProgramError('<integer ...>: Integer expected as arg 1, found "'+
                alfstostr100(arg[1],eoa)+'".');
             end
          else if not (r>i1) then equal:= FALSE
          end; (* narg>0 *)
      end; (* equal and narg>0)

   (* Test i2 if there is one. *)
   if equal and (narg>1) then begin
      (* get i2 *)
      argp:= arg[2];
      error:= False;
      while (argp^=' ') do fsforward(argp);
      if (argp^=eoa) then
         (* - (Empty arg1 = no lower limit) *)
      else begin
         if argp^='-' then begin
            fsforward(argp);
            i2:= fsposint(argp);
            if i2<0 then error:= true
            else i2:= -i2;
            end
         else begin
            i2:= fsposint(argp);
            if i2<0 then error:= true;
            end;
         if error then begin
            equal:= false;
            xProgramError('<integer ...>: Integer expected as arg 2, found "'+
               alfstostr100(arg[2],eoa)+'".');
            end
         else if not (r<i2) then equal:= FALSE;
         end;// (else)
      end; // (equal and narg>1)

   end; (*with*)

aldispose(pargs,mem);

if not equal then begin
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end
else pstateenv.cinp:= inp;

end; (*alDecimal*)


(* (new:) *)
procedure alaFilename( var pstateenv: xstateenv; pfuncret: fsptr );
(* <afilename>*:
   Accepts a file name (max length 1000 chars).
   A filenames consists of all (writable) characters except ", *,
      , <, >, ?, and |.
   space is allowed.
   /, : and \ are allowed to enable paths.
*)
(* <filename>*:
   Renamed to <afilename>.
   Temporarily supported for backwards compatibility.
*)

var
bratecken: SET OF CHAR;
cnt,spacecnt: alint16;
equal: BOOLEAN;
inp,lastinp,spaceinp: ioinptr;

begin (*alaFilename*)

inp:= pstateenv.cinp;
equal:= FALSE;
cnt:= 0;
bratecken:=
// Space and "/" added 2007-04-03
[' ','!','#'..')','+'..'.','/','0'..';','=','@'..'{','}'..'~',
   char($A3)..char($FC)(*'£'..'ü'*)];
lastinp:= inp;
spaceinp:= inp;
spacecnt:= 0;

if inp^=eofr then ioingetinput(inp,true);
while (inp^ IN bratecken) and (cnt<1000) do begin
   lastinp:= inp;
   if inp^=' ' then begin
      if spacecnt=0 then begin
         spaceinp:= inp;
         spacecnt:= 1;
         end
      else spacecnt:= spacecnt+1;
      end
   else spacecnt:= 0;
   ioinforward(inp);
   if inp^=eofr then ioingetinput(inp,true);
   cnt:= cnt+1;
   end;

if (cnt>0) and (lastinp^=':') then begin
   (* Back one step. *)
   inp:= lastinp;
   cnt:= cnt-1;
   end;

(* Do not end with space. *)
if lastinp^=' ' then begin
   inp:= spaceinp;
   cnt:= cnt-spacecnt;
   end;

if cnt>0 then equal:= TRUE;

if not equal then begin
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end
else pstateenv.cinp:= inp;

end; (*alaFilename*)



var
wordTab: array[0..255] of boolean; // True = 'is word character'

procedure alWord( var pstateenv: xstateenv; pfuncret: fsptr );
(* <word>*:
   One or more of letters, digits and uncerscores
*)

var
cnt: alint16;
equal: BOOLEAN;
inp: ioinptr;

begin (*alWord*)

// (new:)
inp:= pstateenv.cinp;
cnt:= 0;
if inp^=eofr then ioingetinput(inp,true);
while wordtab[integer(inp^)] do begin
   ioinforward(inp);
   if inp^=eofr then ioingetinput(inp,true);
   cnt:= cnt+1;
   end;

if cnt>0 then equal:= TRUE;

if not equal then begin
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end
else pstateenv.cinp:= inp;

end; (*alWord*)

procedure alalt( var pargs:xargblock; var pstateenv: xstateenv;
                  pfuncret: fsptr);
(* <alt alt1,alt2,...>*:
   Alternative can contain patterns (<...>).
   Can also be empty.
*)

var n: alint16; equal: BOOLEAN;
saveinp: ioinptr;

begin (*alalt*)

saveinp:= pstateenv.cinp;
equal:= FALSE;
n:= 0;
with pargs do while not ((n=narg) or equal) do begin
    n:= n+1;
    xcompare(arg[n],char(xeoa),false,false,pstateenv,equal);
    end;

if not equal then begin
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    pstateenv.cinp:= saveinp;
    end;

end; (*alalt*)


procedure alopt( var pargs:xargblock; var pstateenv: xstateenv;
                  pfuncret: fsptr);
(* <opt alt1,alt2,...>*:
   alt 1, alt 2, ... or nothing
*)

var n: alint16; equal: BOOLEAN;
saveinp: ioinptr;

begin (*alopt*)

saveinp:= pstateenv.cinp;
equal:= false;
n:= 0;
with pargs do while not ((n=narg) or equal) do begin
    n:= n+1;
    xcompare(arg[n],char(xeoa),false,false,pstateenv,equal);
    end;

if not equal then pstateenv.cinp:= saveinp;

end; (*alopt*)


procedure alid( var pstateenv: xstateenv; pfuncret: fsptr);
(* <id>*:
   Identifier, like in for example Pascal, including non-american letters
   (latin-1 extension) except special characters in x (FD-FF):

   ['A'..'Z','_','-','0'..'9',char($C0)..char($FB)]
*)

var ch: CHAR; equal: BOOLEAN;
inp: ioinptr;

debugstr: shortstring;

begin (*alid*)

inp:= pstateenv.cinp;
if inp^=eofr then ioingetinput(inp,true);
ch:= inp^;
if alflagga('D') then debugstr:= 'ID: inp^= '+ch;
alToUppercase(ch);

(* Include non-american letters (latin-1 extension)
   But exclude special characters 253..255 (FD-FF). *)
if ch IN ['A'..'Z',char($C0)..char($FC)] then begin

    equal:= TRUE;
    while ch IN ['A'..'Z','_','-','0'..'9',char($C0)..char($FB)] do begin
        ioinforward(inp);
        if inp^=eofr then ioingetinput(inp,true);
        ch:= inp^;
if alflagga('D') then debugstr:= debugstr+', '+ch;
        alToUppercase(ch);
        end;
   end

else equal:= FALSE;

if alflagga('D') then begin
   if equal then debugstr:= debugstr+' LIKA'
   else debugstr:= debugstr+' OLIKA';
   iodebugmess(debugstr);
   end;

if not equal then begin
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end
else pstateenv.cinp:= inp;

end; (*alid*)


procedure allwsp( var pstateenv: xstateenv; pfuncret: fsptr );
(* <lwsp>*:
   Linear white space = any number of space or htab.
*)
var equal: BOOLEAN;
inp: ioinptr;

begin

inp:= pstateenv.cinp;
equal:= FALSE;

if inp^=eofr then ioingetinput(inp,true);
// (new:)
while fsLcWsTab[inp^]=' ' do begin
// (old:) while (inp^=' ') or (inp^= char(9)) do begin
    equal:= TRUE;
    if inp^=eofr then ioingetinput(inp,true);
    ioinforward(inp);
    end;

if not equal then begin
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end
else pstateenv.cinp:= inp;

end; (*allwsp*)


procedure alfollowedby( var pargs: xargblock;  
                 var pstateenv: xstateenv;
                 pfuncret: fsptr );
(* <followedby str1[,str2[,...]]>*:
   Accept if input is followed by any of the argument strings str1, str2, .. .
*)
var equal: BOOLEAN; n: alint16; saveinp: ioinptr;

begin

equal:= FALSE;
n:= 0;
saveinp:= pstateenv.cinp;

with pargs do while not ( (n=narg) or equal ) do begin

    n:= n+1;
    pstateenv.cinp:= saveinp;
    xcompare(arg[n],eoa,false,false,pstateenv,equal);
    end;

pstateenv.cinp:= saveinp;

if not equal then begin
    (* Signal failure: *)
    if (pstateenv.cinp^='#') then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end;

end; (*alfollowedby*)

procedure alnotfollowedby( var pargs: xargblock;  
                 var pstateenv: xstateenv; 
                 pfuncret: fsptr );
(* <notfollowedby str1,str2,...>*:
   Accept only if input differs from all argument strings.
*)
var equal: BOOLEAN; n: alint16; saveinp: ioinptr;

begin

equal:= FALSE;
n:= 0;
saveinp:= pstateenv.cinp;

with pargs do while not ( (n=narg) or equal ) do begin

    n:= n+1;
    pstateenv.cinp:= saveinp;
    xcompare(arg[n],eoa,false,false,pstateenv,equal);
    end;

pstateenv.cinp:= saveinp;

if equal then begin
    (* Signal failure: *)
    if (pstateenv.cinp^='#') then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end;

end; (*alnotfollowedby*)


procedure aleof( var pstateenv: xstateenv; pfuncret: fsptr);
(* <eof>*:
   Accept if input pointer stands and the end of the input file.
*)
(* End of file:
   pstateenv.cinp^=eofs
*)
var inp: ioinptr;
begin (*aleof*)

if pstateenv.cinp^=eofr then
ioingetinput(pstateenv.cinp,true);
inp:= pstateenv.cinp;

(* Allow blanks before eof *)
(* BR 2007-09-14: Removed because
<def contains,<ifeq $1,<to $2><to <eof>>,yes,no>>
did not work when string ended with ' '. *)
(* while (inp^=' ') or (inp^=char(9)) do begin
  ioinforward(inp);
  if inp^=eofr then ioingetinput(pstateenv.cinp,true);
  end;*)

if inp^=eofs then
    // Success
    pstateenv.cinp:= inp
else begin
    // Fail
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end;

end; (*aleof*)

// (new:)

procedure aleofr( var pstateenv: xstateenv; pfuncret: fsptr);
(* <eofr>*:
   Accept only if input pointer is past the last available character
   in a file that can receive more characters (for example
   tcp/ip ports, serial ports, and circular buffers)
*)
(* Implementation:
   pstateenv.cinp^=eofr and no more data to read
*)
var match: boolean;
begin (*aleofr*)

if (pstateenv.cinp^=eofr) then begin
   if ioinreadable(pstateenv.cinp) then begin
      // Read next to make sure it is not LF in CRLF
      ioingetinput(pstateenv.cinp,false);
      if (pstateenv.cinp^=eofr) then  match:= true
      else match:= false;
      end
   else match:= true;
   end
else match:= false;

if not match then fspshend(pfuncret,'#');

end; (*aleofr*)

procedure aleoln( pfuncret: fsptr);
(* <eoln>*:
   returns char(13).
   Used in places like:
   ?"...<to <eoln>>
   "?
   to avoid extra line in the x- file.
*)
begin (*aleofr*)

fspshend(pfuncret,char(13));

end; (*aleoln*)


procedure alxdefaultdir( pfuncret: fsptr);
(* <xdefaultdir>:
   Returns the default directory for reading
   x files. E.g.
   <load C:\Documents and Settings\Bertil Friman\Skrivbord\X-scripts\dmi.x>
   => <xdefaultdir> = "C:\Documents and Settings\Bertil Friman\Skrivbord\X-scripts"
   inside dmi.x.
   Outside dmi.x it will also be the same if dmi.x is the top x file.
*)

var i: integer;

begin (*alxdefaultdir*)

if xdefaultdir^<>eofs then fscopy(xdefaultdir,pfuncret,eofs)
else if xtopdir<>nil then fscopy(xtopdir,pfuncret,eofs);

end; (*alxdefaultdir*)

procedure alBitsDec( var pargs: xargblock;
   var pstateenv:
   xstateenv; pfuncret: fsptr );
(* <bitsdec n[,str]>*:
   Read and accept n bits. Optionally compare with str.
   When referenced with <p n> or <xp n>, or when compared with str,
   the bits will first be converted to a decimal value.
   <bitsdec ...> is a variant of the more basic <bits m[,str]>.
   It can be used for fields which represent decimal values. The decimal
   can then be referenced directly, with <p n> or <xp n> (or str), without
   having to decode it with <htod ...>.

   How it is implemented:
   Start at saved bitpos.
   Save bitpos for 1st and last char's.
   Update saved bitpos.
   Input assumed to be hexadecimal.
*)

var
mem: alevalmem;
equal: BOOLEAN;
inp: ioinptr;
str: fsptr;
cnt,nbits,newshift,nchar: alint16;
ss: shortstring; //slen: alint16; stre: fsptr;
arg2: fsptr;
saveinp: ioinptr;
hexerror: char;
oldshiftbits: integer;
// for decimal evaluation:
strp: fsptr;
dec: packed array[1..10] of char;
res: longword;
i,j: integer;

begin

alevaluate(pargs,pstateenv,mem,[1]);

oldshiftbits:= shiftbits;
fsnew(str);

(* 1. If starting bitsmode, initialize bitmode. *)
if not bitsmode then begin
  bitsmode:= true;
  shiftbits:= 0;
  end;

(* 2. OK until otherwise proved. *)
equal:= True;

(* 3. Get number of bits and calculate number of hex characters to read
   with ioinforward, and the new shift number. *)
nbits:= fsposint(pargs.arg[1]);
if nbits<0 then begin
   xScriptError('X(<bits '+alfstostr100(pargs.arg[1],eoa)+
      '...>: Number of bits shall be >=0.');
   nbits:= 0;
   equal:= false;
   end;

nchar:= (shiftbits + nbits) div 4;
(* Examples: 0,4 => 1  0,5 => 1  3,1 => 1  2,1 => 0  3,2 => 1 *)
newshift:= (shiftbits + nbits) mod 4;
(* Examples: 0,4 => 0  0,5 => 1  3,1 => 0  2,1 => 3  3,2 => 1 *)

(* 4. If there is an arg[2], check bits against that. *)
if pargs.narg>1 then begin
   (* Read nbits from input (pstateenv.cinp), without advancing cinp.
      (Ordinary reading from input is done further down). *)
   inp:= pstateenv.cinp;
   algetbits(inp,nchar,shiftbits,newshift,str,hexerror);
   if hexerror<>'0' then equal:= false
   else begin
      (* No hex error in input, and the input value is 32 or less bits long.
         Convert it to an integer, and then to a string. *)
      strp:= str;

      // 1. Convert to 32 bit integer
      res:= 0;
      cnt:= 0;
      while (strp^=' ') or (strp^='0') do fsforward(strp);
      while not (strp^=eofs) do begin
         if strp^<>' ' then begin
            cnt:= cnt+1;
            if cnt<=8 then res:= (res shl 4) or alhextoint(strp^);
            end;
         fsforward(strp);
         end;
      if cnt>8 then begin
         xScriptError('x(<bitsdec ...,...>): Expected too check a decimal number ' +
            'representing <= 8 hex chars (32 bits) but found ' + inttostr(cnt) +
            ' hex chars.');
         equal:= false;
         end

      else begin
         // 2. Convert result to string, starting with last digit.
         i:= 10;
         while (res>0) do begin
            dec[i]:= char( alint16('0') + res mod 10);
            res:= res div 10;
            i:= i-1;
            end;
         if i=10 then begin
            dec[i]:='0';
            i:= i-1;
            end;
         // 3. Copy from dec[i+1..10] to ss
         ss:= '';
         for j:= i+1 to 10 do begin
           ss:= ss + dec[j];
           end;
         ss:= ss + char(eofs);
         end;(* not size error *)

      if equal then begin

         // Still no error found. Compare with arg2
         arg2:= pargs.arg[2];

         (* We must force xcompare to work on ss instead of input stream. *)
         saveinp:= pstateenv.cinp;
         pstateenv.cinp:= ioinptr(@ss[1]);
         xcompare(arg2,eoa,false,false,pstateenv,equal);
         if pstateenv.cinp^<>eofs then equal:= false;
         pstateenv.cinp:= saveinp;
         end;
      end; (* slen <= 250 *)
   end; (* narg>1 *)

(* 5. If still equal: Increment pstateenv.cinp to next position and check that all
   char's were hex. *)
if equal then begin
   cnt:= 0;
   inp:= pstateenv.cinp;
   while (cnt<nchar) and equal do begin
      if inp^=char(eofr) then ioingetinput(inp,true);
      if inp^=char(eofs) then begin
         equal:= false;
         (* xScriptError('alBitsDec: unable to read specified number of bits.'); *)
         end
      else begin
         if (fsBinaryWsTab[inp^]<>' ') then begin
            cnt:= cnt+1;
            if integer(fsHtodTab[inp^])>15 then
               begin
               equal:= false;
               end;
            end;
         ioinforward(inp);
         end;
      end; (* while *)
   if equal and (newshift>0) then begin
      if inp^=char(eofr) then ioingetinput(inp,true);
      if inp^=char(eofs) then begin
         equal:= false;
         (* xScriptError('alBitsDec: unable to read specified number of bits.'); *)
         end
      else begin
         while fsBinaryWsTab[inp^]=' ' do begin
            ioinforward(inp);
            if inp^=char(eofr) then ioingetinput(inp,true);
            end;

         if integer(fsHtodTab[inp^])>15 then begin
            equal:= false;
            (* if inp^<>eofs then xScriptError('X(alBitsDec): Non-hexadecimal character received: "'
              +inp^+'" (ascii '+inttostr(ord(inp^))+').'); *)
            end;
         end; (* not eofs *)
      end; (* newshift>0 *)

   if equal then pstateenv.cinp:= inp;
   end;

(* 6. If still equal: Set the shift parameters in next par, where we know
   that xcompare will register this input. *)
if equal then begin
   with pstateenv.pars do if npar < xmaxnpar then with par[bitsnpar+1] do begin
      bitsAs:= 1;
      atshift:= shiftbits;
      aftershift:= newshift;
      end;

   (* 5C. Update shiftbits to new value. *)
   shiftbits:= newshift;
   end

(* 6. If not equal, then reset shiftbits to what it was at the beginning
   of the tested string, and indicate failure through pfuncret. *)
else begin
   if pstateenv.pars.npar>0 then begin
      if pstateenv.pars.par[1].bitsAs>0 then
         shiftbits:= pstateenv.pars.par[1].atshift
      else begin
         (* In case par[1] is not from <bits ...> (bitsAs=0) then
            atshift is invalid. Then look for first parameter
            that is from <bits ...> or use old shiftbits if none is. *)
         i:= 2;
         shiftbits:= oldshiftbits;
         while i<= pstateenv.pars.npar do begin
            if pstateenv.pars.par[i].bitsAs>0 then begin
               // Found
               shiftbits:= pstateenv.pars.par[i].atshift;
               i:= pstateenv.pars.npar+1;
               end
            else i:= i+1;
            end;
         end;

      end;
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end;
fsdispose(str);
aldispose(pargs,mem);

end; (*alBitsDec *)

procedure albits( var pargs: xargblock; var pstateenv: xstateenv;
   pfuncret: fsptr );

(* Bits: Assuming Hex input and producing hex output
   when referenced by <p n>. *)
(* <bits n[,str]>*:
   Read n bits. Optionally compare with str.
   Start at bit bitpos.
   Save bitpos for 1st and last char's.
   Input assumed to be hexadecimal.
*)

var
mem: alevalmem;
equal: BOOLEAN;
inp: ioinptr;
str: fsptr;
cnt,nbits,newshift,nchar: alint16;
ss: shortstring; slen: alint16; stre: fsptr; arg2: fsptr;
saveinp: ioinptr;
hexerror: char;
oldshiftbits,i: integer;

begin

alevaluate(pargs,pstateenv,mem,[1]);

oldshiftbits:= shiftbits;
fsnew(str);

(* 1. If starting bitsmode, initialize bitmode. *)
if not bitsmode then begin
  bitsmode:= true;
  shiftbits:= 0;
  end;

(* 2. OK until otherwise proved. *)
equal:= True;

(* 3. Get number of bits and calculate number of hex characters to read
   with ioinforward, and the new shift number. *)
nbits:= fsposint(pargs.arg[1]);
if nbits<0 then begin
   xScriptError('X(<bits '+alfstostr100(pargs.arg[1],eoa)+
      '...>: Number of bits shall be >=0.');
   nbits:= 0;
   equal:= false;
   end;

nchar:= (shiftbits + nbits) div 4;
(* Examples: 0,4 => 1  0,5 => 1  3,1 => 1  2,1 => 0  3,2 => 1 *)
newshift:= (shiftbits + nbits) mod 4;
(* Examples: 0,4 => 0  0,5 => 1  3,1 => 0  2,1 => 3  3,2 => 1 *)

(* 4. If there is an arg[2], check bits against that. *)
if pargs.narg>1 then begin
    inp:= pstateenv.cinp;
    algetbits(inp,nchar,shiftbits,newshift,str,hexerror);
    if hexerror<>'0' then
      equal:= false;
    stre:= str; fsforwend(stre);
    slen:= fsdistance(str,stre);
    if slen>250 then begin
      iodebugmess('X (albits): <bits ...,check> can only check 250 chars ('
      +inttostr(slen)+').');
      equal:= false;
      end
    else begin
      arg2:= pargs.arg[2];
      (* Remove leading zeroes from str and arg[2]. *)
      (* if str^='0' then begin (removed because it does not work if <alt ...>
          is usedin arg[2])
          while str^='0' do fsforward(str);
          if str^=eofs then fsback(str);
          end;
      if arg2^='0' then begin
          while arg2^='0' do fsforward(arg2);
          if arg2^=eoa then fsback(arg2);
          end;*)

      (* We must force xcompare to work on str instead of input stream. *)
      if equal then begin
        ss:= fstostr(str);
        ss:= ss + char(eofs);
        (* ss[slen+1]:= char(eofs); *)
        saveinp:= pstateenv.cinp;
        pstateenv.cinp:= ioinptr(@ss[1]);
        xcompare(arg2,eoa,false,false,pstateenv,equal);
        if pstateenv.cinp^<>eofs then equal:= false;
        pstateenv.cinp:= saveinp;
        end;
      end; (* slen <= 250 *)
    end; (* narg>1 *)

(* 5. If still equal: Increment pstateenv.cinp to next position and check that all
   char's were hex. *)
if equal then begin
   cnt:= 0;
   inp:= pstateenv.cinp;
   while (cnt<nchar) and equal do begin
      if inp^=char(eofr) then ioingetinput(inp,true);
      if inp^=char(eofs) then begin
         equal:= false;
         (* xScriptError('albits: unable to read specified number of bits.'); *)
         end
      else begin
         if (fsBinaryWsTab[inp^]<>' ') then begin
            cnt:= cnt+1;
            // (new:)
            if integer(fsHtodTab[inp^])>15 then
            // (Old:) if (inp^<'0') or ((inp^>'9') and (inp^<'A')) or (inp^>'F') then
               begin
               equal:= false;
               end;
            end;
         ioinforward(inp);
         end;
      end; (* while *)
   if equal and (newshift>0) then begin
      if inp^=char(eofr) then ioingetinput(inp,true);
      if inp^=char(eofs) then begin
         equal:= false;
         (* xScriptError('albits: unable to read specified number of bits.'); *)
         end
      else begin
         while fsBinaryWsTab[inp^]=' ' do begin
            ioinforward(inp);
            if inp^=char(eofr) then ioingetinput(inp,true);
            end;

         // (new:)
         if integer(fsHtodTab[inp^])>15 then begin
         // (old:) if ((inp^<'0') or ((inp^>'9') and (inp^<'A')) or (inp^>'F')) then begin
            equal:= false;
            (* if inp^<>eofs then xScriptError('X(albits): Non-hexadecimal character received: "'
              +inp^+'" (ascii '+inttostr(ord(inp^))+').'); *)
            end;
         end; (* not eofs *)
      end; (* newshift>0 *)

   if equal then pstateenv.cinp:= inp;
   end;

(* 6. If still equal: Set the shift parameters in next par, where we know
   that xcompare will register this input. *)
if equal then begin
   // (New:)
   with pstateenv.pars do if npar < xmaxnpar then with par[bitsnpar+1] do begin
   // (old:)with pstateenv.pars do if npar < xmaxnpar then with par[npar+1] do begin
      bitsAs:= 3;
      atshift:= shiftbits;
      aftershift:= newshift;
      end;

   (* 5C. Update shiftbits to new value. *)
   shiftbits:= newshift;
   end

(* 6. If not equal, then reset shiftbits to what it was at the beginning
   of the tested string, and indicate failure through pfuncret. *)
else begin
   if pstateenv.pars.npar>0 then begin
      if pstateenv.pars.par[1].bitsAs>0 then
         shiftbits:= pstateenv.pars.par[1].atshift
      else begin
         (* In case par[1] is not from <bits ...> (bitsAs=0) then
            atshift is invalid. Then look for first parameter
            that is from <bits ...> or use old shiftbits if none is. *)
         i:= 2;
         shiftbits:= oldshiftbits;
         while i<= pstateenv.pars.npar do begin
            if pstateenv.pars.par[i].bitsAs>0 then begin
               // Found
               shiftbits:= pstateenv.pars.par[i].atshift;
               i:= pstateenv.pars.npar+1;
               end
            else i:= i+1;
            end;
         end;

      end;
    if pstateenv.cinp^='#' then fspshend(pfuncret,'x')
    else fspshend(pfuncret,'#');
    end;
fsdispose(str);
aldispose(pargs,mem);

end; (*albits *)



procedure albitscount( var pstateenv: xstateenv; pfuncret: fsptr );
(* <bitscount>:
   Return number of bits that was read in the current input pattern ?"..."?
   (or from pattern in <ifeq ...> or <case ...>. Useful when counting the
   number of consumed bits in a binary message or package.
*)

var
bitscount: integer;
inp: ioinptr;
cnt: integer;


begin

bitscount:= 0;

(* 1. Check that we are in bitsmode (there are <bits ...> or <bitsdec ...>
   in the pattern (?"..."?). *)
if not bitsmode then
   xProgramError('X(<bitscount>): This function is only valid in bit mode.')

else with pstateenv.pars do begin

   if npar>0 then begin
      if not ( (par[1].bitsAs>0) and (par[npar].bitsAs>0) ) then
         xScriptError('X(<bitscount>): bitsAs was expected to be active (from '+
            '<bits ...>) in first and last parameter but par[1].bitsAs='+
            inttostr(integer(par[1].bitsAs))+
            ' par[npar].bitsAs='+inttostr(integer(par[npar].bitsAs))+'). '+
            'The most common reason for this is that there is a parameter within '+
            '?"..."? which is not based on <bits ...>.')

      else begin
         (* npar>0 and bitsAs>0 *)
         inp:= par[1].atp;
         cnt:= 0;
         while not (inp=par[npar].afterp) do begin
            if (fsBinaryWsTab[inp^]<>' ')
               then cnt:= cnt+1;
            ioinforward(inp);
            end;
         bitscount:= cnt*4-par[1].atshift+par[npar].aftershift;
         end; (*bitsAs>0*)
      end; (*npar>0*)
  end;

alinttofs(bitscount,pfuncret);

end; (*albitscount*)

procedure alBitsClear;
(* <bitsClear>:
   Resets the bit position memory of the <bits ...> function,
   so that next use of <bits ...> shall start to read from the first bit of
   the first (hexadecimal) character.
*)
begin
bitsmode:= False;
end;

procedure alshiftbits( pfuncret: fsptr );
(* <shiftbits>:
   Return number of already consumed bits in next char in input stream.
   Can be useful for debugging.
*)

begin
// Return shiftbits
alinttofs(shiftbits,pfuncret)
end; (*alshiftbits*)


procedure dtoh32(p1,p2: fsptr; pendch: char)
(* Convert 32 bit unsigned integer (p1) into hex string (p2).
   Callers p1 and p2 remain unchanged (since  they are not var-declared). *);
var
ui: longword;
decPtr,decPtr0: fsptr;
hextab: array[1..8] of char;
cnt,ix,digit,dcnt: integer;
overflow: boolean;

begin
ui:= 0;
cnt:= 0;
overflow:= false;
decPtr:= p1;

// 1. Remove leading blanks and zeroes
while (decPtr^=' ') do fsforward(decPtr);

// Save next to last char in case the value is '0'.
decPtr0:= decPtr;
while (decPtr^='0') do begin
   decPtr0:= decPtr;
   fsforward(decPtr);
   end;
if decPtr^=pendch then decPtr:= decPtr0;

// 2. Calculate value, avoid creating a number higher than 32 bits unsigned.
while (decPtr^<>pendch) and (cnt<10) do begin
   cnt:= cnt+1;
   digit:= integer(decPtr^) - integer('0');
   if cnt=10 then begin
      // check that the resulting value us <= 4294967295 (FFFFFFFF).
      if digit>4 then overflow:= true
      else if digit=4 then begin
         if ui>294967295 then overflow:= true;
         end;
      if not overflow then ui:= ui*10 + digit;
      end(* cnt=10 *)
   else ui:= ui*10 + digit;
   fsforward(decPtr);
   end;(*while*)
if decPtr^<>pendch then overflow:= true;

// Save decimal count for later check
dcnt:= cnt;

// 2. Convert to hex.
cnt:= 0;
while ui>0 do begin
   hextab[8-cnt]:= fsDtoHTab[ui mod 16];
   ui:= ui div 16;
   cnt:= cnt+1;
   end;
if cnt=0 then begin
   cnt:= 1;
   hextab[8]:= '0';
   end;

if dcnt=0 then xScriptError('Tried to convert decimal number to hex but the '+
   'number (' + fstostr(p1) + ') was empty or blank.')
else if overflow then xScriptError('Tried to convert decimal number to hex but the '+
   'number (' + fstostr(p1) + ') was to big (> 32bits =4294967295).')
else begin
   // 3. Print to p2 (example: cnt=1 => only hextab[8] is printed).
   for ix:= 9-cnt to 8 do begin
      fspshend(p2,hextab[ix]);
      end;
   end;

end; (*dtoh32*)



var
savechar: char; (* '0'..'9', 'A'..'F' *)
nsavedbits: alint16; (* 0..3 *)
makebitscount: alint16; (* Set by <makebitscount n> incremented by almakebits.
                      Retrieved by <makebitscount>. *)
temps: string;

procedure almakebits( var pargs: xargblock;
   var pstateenv: xstateenv;
   pDecimal: boolean;
   pfuncret: fsptr );
(* <makebits n,str>:
   Make n bits from str. Add saved bits to front. Return
   all bits except trailing odd bits (if total number of bits
   is not a multiple of 4).
   Save trailing odd bits, to be added at next call to almakebits.
   Input assumed to be hexadecimal.
*)

var
mem: alevalmem;
nibs,slen,n,nzeroes: alint16;
unusedbits,unusedsave,i1,i2: alint16;
str,newstr,s: fsptr;
retnibs,cnt: alint16;
overflow: boolean;
ch,newch: char;
hex: integer;

begin

alevaluate(pargs,pstateenv,mem,[1,2]);
fsnew(newstr);
fsnew(str);

(* 00. Get arguments. *)
n:= fsposint(pargs.arg[1]);
if n<0 then begin
   xScriptError('X(<makebits '+alfstostr100(pargs.arg[1],eoa)+
      '...>: Expected a number >=0.');
   n:= 0;
   end

else if n=0 then begin
   // Check that arg[2]=0.
   s:= pargs.arg[2];
   // (new:)
   while fsLcWsTab[s^]=' ' do fsforward(s);
   // (old:) while (s^=' ') or (s^=char(9)) do fsforward(s);

   if (s^<>eoa) and (s^<>'0') then xScriptError('X: 0 or empty arg was '+
      'expected but '+xfstostr(pargs.arg[2],eoa)+' was found.');
   end

else begin

   // (n>0)
   nibs:= (n + 3) div 4; (* 0=>0, 1=>1, 4=>1, ... *)
   if pDecimal then
      // Convert from decimal to hexadecimal (miniversion of aldtoh).
      dtoh32(pargs.arg[2],str,eoa)
   else fscopy(pargs.arg[2],str,eoa);

   (* 1. Remove blanks from beginning of str. *)
   while fsLcWsTab[str^]=' ' do fsforward(str);

   s:= str;
   fspshend(s,eoa);
   slen:= alfslen(str,eoa);
   nzeroes:= 0;

   (* 2. Calculate unused bits in first valid nibble of str and in savechar. *)
   unusedBits:= (4 - (n mod 4)) and 3; (* 0=>0, 1=>3, 4=>0, ... *)
   unusedSave:= 4 - nsavedbits;

   (* 3. Remove redundant leading zeroes and check that the value is not longer
      than the number of bits to be created (overflow). *)
   overflow:= false;
   while slen>nibs do begin
      if str^<>'0' then overflow:= true;
      fsforward(str);
      slen:= slen-1;
      end;

   if (slen=nibs) and (str^<>eoa) then begin
      ch:= str^;
      if unusedbits>0 then begin
         hex:= alhextoint(ch);
         case unusedbits of
            1: newch:= alinttohex(hex and 7);
            2: newch:= alinttohex(hex and 3);
            3: newch:= alinttohex(hex and 1);
            end;
         if newch<>ch then overflow:= true;
         str^:= newch;
         end;
      end;

   (* 4. Call Script error if value was to big. *)
   if overflow then begin
      temps:= '';
      case n mod 4 of
         0: temps:= 'F';
         1: temps:= '1';
         2: temps:= '3';
         3: temps:= '7';
         end;
      for cnt:= 2 to nibs do temps:= temps+'F';

      xScriptError('X: 0..'+temps+' was expected but '+
         xfstostr(pargs.arg[2],eoa)+' was found.');
      end;

   (* 5. Add zeroes to beginning of str if str is to short for n bits. *)
   if slen < nibs then nzeroes:= nibs-slen;

   (* 6. Add zero to beginning of str if saved bits is more than
      unused leading bits of str. *)
   if nsavedbits > unusedbits then nzeroes:= nzeroes+1;
   
   (* 7. Set up newstr = str + possible leading zeroes. *)
   s:= newstr;
   for cnt:= 1 to nzeroes do fspshend(s,'0');
   fscopy(str,s,eoa);
   
   (* 8. If nsavebits = number of unused bits in str, then nsavebits fits
      exactly in the hole in the beginning of newstr. *)
   if nsavedbits = unusedbits then begin
      i1:= alhextoint(newstr^); (* Take 1st char of newstr *)
      i1:= ((i1 shl unusedbits) and $0f) shr unusedbits; (* Delete unused bits. *)
      i2:= alhextoint(savechar); (* Take saved char. *)
      i2:= (i2 shr unusedsave) shl unusedsave; (* Delete unused bits *)
      newstr^:= alinttohex(i1+i2); (* combine *)
      end
   
   (* 9. If unused bits in str > nsavebits, then new bits fits into newstr, but
      the whole new string has to be shifted left by unusedbits-nsavebits. *)
   else if unusedbits > nsavedbits then begin
      i1:= alhextoint(newstr^); (* Take 1st char of newstr *)
      i1:= ((i1 shl unusedbits) and $0f) shr unusedbits; (* Delete unused bits. *)
      i2:= alhextoint(savechar); (* Take saved char. *)
      i2:= (i2 shr unusedsave); (* Delete unused bits *)
      i2:= i2 shl (4-unusedbits); (* Move it to just before the
                                     used bits of str^*)
      newstr^:= alinttohex(i1+i2); (* combine *)
      alfsshl(newstr,(unusedbits-nsavedbits)); (* Remove the remaining unused bits
                                     from the beginning of the string. *)
      end
   
   (* 10. If nsavebits > unused bits in string, a zero has been added to the string,
      and the saved bits shall be put into place in the two first char's. *)
   else begin
      i1:= alhextoint(savechar); (* Get saved char. *)
      i1:= (i1 shr unusedsave) shl unusedsave; (* Remove unused savebits *)
      i1:= i1 shl 4; (* Put it in high nibble. *)
      i1:= i1 shr (unusedbits+unusedsave); (* Shift it so its last bits comes
         just before the first used bit in the 1st char of the string. *)
      i2:= i1 and $0f; (* Separate 1st and 2nd nibble. *)
      i1:= i1 shr 4;
      s:= newstr;
      s^:= alinttohex(i1); (* Put nibble 1 and 2 in 1st and 2nd char of string. *)
      fsforward(s);
      if s^<>eofs then s^:= alinttohex(i2 + alhextoint(s^));
  
      (* All unused bits are now at the beginning of the string - remove them. *)
      alfsshl(newstr,unusedbits+unusedsave);
      end;
   
   (* 11. The new string is now correct, but its last character may contain
      unused bits. Save the unused bits, and return the remainder of the string. *)
   retnibs:= (nsavedbits+n) div 4;
   nsavedbits:= (nsavedbits+n) mod 4;
   s:= newstr;
   for cnt:= 1 to retnibs do begin
      fspshend(pfuncret,s^);
      fsforward(s);
      end;
   if nsavedbits>0 then begin
      savechar:= s^;
      if savechar=eoa then begin
         iodebugmess('X (almakebits): Prog error - unexpected eoa.');
         savechar:= '0';
         end;
      end
   else savechar:= '0';
   
   makebitscount:= makebitscount + n;
   end; (* n>0 *)

fsdispose(str);
fsdispose(newstr);
aldispose(pargs,mem);

end; (*almakebits*)


procedure alMakeBitsClear;
(* <makebitsclear>:
   Reset makebits bit counter.
*)
begin
nsavedbits:= 0;
savechar:= '0';
makebitscount:= 0;
end;


procedure almakebitscount( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <makebitscount n>:
   Sets makebitscount. <makebitscount> returns makebitscount.
*)

var
mem: alevalmem; bc: alint16;

begin
alevaluate(pargs,pstateenv,mem,[1]);
if pargs.narg=0 then alinttofs(makebitscount,pfuncret)
else begin
  bc:= fsposint(pargs.arg[1]);
  if bc<0 then xScriptError('X(<makebitscount n>): Expected a number >= 0, found "'+
      alfstostr100(pargs.arg[1],eoa)+'".')
  else makebitscount:= bc;
  end;
aldispose(pargs,mem);
end; (*makebitscount*)

procedure alhtod( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <htod str>:
   Converts hexadecimal number to decimal.
*)

var
mem: alevalmem;
result: longword;
s: fsptr;
i,j: alint16;
dec: packed array[1..10] of char;
cnt: integer;

begin
alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

   result:= 0;
   s:= arg[1];
   cnt:= 0;
   while not ((s^=eoa)) do begin
      if s^<>' ' then begin
         cnt:= cnt+1;
         if cnt<=8 then result:= (result shl 4) or alhextoint(s^);
         end;
      fsforward(s);
      end;
   if cnt>8 then xScriptError(
       'x(<htod ...>): Unable to conv strings longer than 8 chars to dec.')

   else begin
      i:= 10;
      while (result>0) do begin
          dec[i]:= char( alint16('0') + result mod 10);
          result:= result div 10;
          i:= i-1;
          end;
      if i=10 then begin
          dec[i]:='0';
          i:= i-1;
          end;
      for j:= i+1 to 10 do fspshend(pfuncret,dec[j]);
      end;(* not error *)
   end; (* with *)

aldispose(pargs,mem);
end; (*alhtod*)


procedure aldtoh( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <dtoh str>:
   Converts a decimal number to hexadecimal.
*)

var
mem: alevalmem;
result: cardinal;
str: fsptr;
i,j: alint16;
hex: packed array[1..10] of char;
error: boolean;
cnt,numcnt: integer;
skip: boolean;
resReal: real;

begin
alevaluate(pargs,pstateenv,mem,[1]);

error:= False;
str:= pargs.arg[1];
numcnt:= 0;

repeat

    cnt:= 0;
    skip:= false;

    (* Remove leading spaces. *)
    while fsLcWsTab[str^]=' ' do
       fsforward(str);

   if str^<>eoa then begin
      result:= 0;
      while str^ in ['0'..'9'] do begin
         cnt:= cnt+1;
         if cnt>9 then begin
            if cnt=10 then
               resReal:= round(result)*10.0 + round(alint32(str^) - alint32('0'))
            else
               resReal:= resReal*10.0 + round(alint32(str^) - alint32('0'));
            end
         else begin
            result:= result*10 - alint32('0') + alint32(str^);
            end;
         fsforward(str);
         end;(* while *)

      if cnt>9 then begin
         if resReal>4294967295.4 then begin
            if not error then begin
               xProgramError('X(<dtoh ' + alfstostr(pargs.arg[1],eoa) + '>): ' +
                  'Unable to convert args which would give a result higher than FFFFFFFF.');
               error:= true;
               result:= 0;
               end;
            end
         else result:= round(resReal);
         end;

      if cnt=0 then begin
         (* Other characters than '0'..'9'. *)
         xProgramError('X(<dtoh ' + alfstostr(pargs.arg[1],eoa) + '>): ' +
            'Expected only characters "0".."9".');
         error:= true;
         result:= 0;
         end
      else if not ((str^=eoa) or (fsLcWsTab[str^]=' ')) then begin
         (* Other characters efter '0'..'9'. *)
         xProgramError('X(<dtoh ' + alfstostr(pargs.arg[1],eoa) + '>): ' +
            'Expected sequences of "0".."9" separated by spaces.');
         error:= true;
         result:= 0;
         end
      end
   else begin
      (* eoa. *)
      if numcnt=0 then begin
         xProgramError('X(<dtoh ' + alfstostr(pargs.arg[1],eoa) + '>): ' +
            'Expected characters "0".."9" but argument was empty.');
         error:= true;
         result:= 0;
         end
      else
         (* Trailing spaces. *)
         skip:= true;
      end;

   (* Print one number (0) even if there is an error. *)
   if error and (numcnt>0) then skip:= true;

   if not skip then begin
      (* Separete hex numbers with space. *)
      if numcnt>0 then fspshend(pfuncret,' ');

      (*  Convert to hex. *)
      i:= 10;
      while (result>0) do begin
         hex[i]:= alinttohex(result mod 16);
         result:= result div 16;
         i:= i-1;
         end;
      if i=10 then begin
         hex[i]:= '0';
         i:= i-1;
         end;
      for j:= i+1 to 10 do fspshend(pfuncret,hex[j]);

      numcnt:= numcnt+1;
      end;

   until (str^=eoa) or error;

aldispose(pargs,mem);

end; (*aldtoh*)




procedure albtoh( var pargs: xargblock;  
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <btoh str>:
   Converts a binary number to hexadecimal.
*)

var
mem: alevalmem;
str,p: fsptr;
strlen,len1,lenrest,i: alint16;
digit: alint16;
ch: char;
error: boolean;

begin
alevaluate(pargs,pstateenv,mem,[1]);

str:= pargs.arg[1];
strlen:= alfslen(str,eoa);
error:= false;

(* Decode the first (possibly odd bit numbered) hex digit. *)
len1:= strlen mod 4;
digit:= 0;
p:= str;
for i:= 1 to len1 do begin
  ch:= p^;
  if ch='0' then digit:= digit*2
  else if ch='1' then digit:= digit*2 + 1
  else begin
     error:= true;
     digit:= digit*2;
     end;
  fsforward(p);
  end;
if len1>0 then fspshend(pfuncret,alinttohex(digit));

(* lenrest shall be evenly dividable by 4 now.
   Decode the remaining hexadecimal digits. *)
lenrest:= strlen-len1;
digit:= 0;
for i:= 1 to lenrest do begin
  ch:= p^;
  if ch='0' then digit:= digit*2
  else if ch='1' then digit:= digit*2 + 1
  else begin
     error:= true;
     digit:= digit*2;
     end;
  if (i mod 4) = 0 then begin
     fspshend(pfuncret,alinttohex(digit));
     digit:= 0;
     end;
  fsforward(p);
  end;

(* Illegal characters (other than 0 or 1)? *)
if error then xScriptError(
  'X(<btoh ...>): Argument contains other characters than "0" or "1" ('
    + alfstostr100(str,eoa) + ').');

(* Diagnostic: p shall now point at eoa. *)
if (p^<>eoa) or (digit<>0) then xProgramError('X(albtoh): eoa and digit=0 expected.');

aldispose(pargs,mem);
end; (*albtoh*)


procedure alhtob( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <htob str[,nbits]>:
   Converts a hexadecimal number to binary.
   Limit to last nbits if specified.
*)

var
mem: alevalmem;
p: fsptr;
binstr: string;
arg2,len,i1,i: integer;
ch: char;
error: boolean;

begin
alevaluate(pargs,pstateenv,mem,[1]);
p:= pargs.arg[1];
error:= false;
binstr:= '';

while not ((p^=eoa) or error) do  begin
   ch:= p^;
   case ch of
      '0': binstr:= binstr + '0000';
      '1': binstr:= binstr + '0001';
      '2': binstr:= binstr + '0010';
      '3': binstr:= binstr + '0011';
      '4': binstr:= binstr + '0100';
      '5': binstr:= binstr + '0101';
      '6': binstr:= binstr + '0110';
      '7': binstr:= binstr + '0111';
      '8': binstr:= binstr + '1000';
      '9': binstr:= binstr + '1001';
      'A': binstr:= binstr + '1010';
      'B': binstr:= binstr + '1011';
      'C': binstr:= binstr + '1100';
      'D': binstr:= binstr + '1101';
      'E': binstr:= binstr + '1110';
      'F': binstr:= binstr + '1111';
      'a': binstr:= binstr + '1010';
      'b': binstr:= binstr + '1011';
      'c': binstr:= binstr + '1100';
      'd': binstr:= binstr + '1101';
      'e': binstr:= binstr + '1110';
      'f': binstr:= binstr + '1111';
      else begin
         if (ch<>' ') then begin
            error:= true;
            xProgramError('<htob ...>: Expected 0-9, A-F or " ", but found '+ch+'.');
            end;
         end;
      end;
   fsforward(p);
   end; (*while*)

if not error then begin

   len:= length(binstr);
   if pargs.narg>1 then begin
      arg2:= fsposint(pargs.arg[2]);

      // Fill with extra zeroes in beginning if arg2>len
      for i:= 1 to arg2-len do fspshend(pfuncret,'0');

      // Skip leading bits if arg2<len
      if arg2<len then i1:= 1 + (len-arg2)
      else i1:= 1;
      end
   else i1:= 1;

   // add bits from binstr
   for i:= i1 to len do fspshend(pfuncret,binstr[i]);
   end;

aldispose(pargs,mem);
end; (*alhtob*)


procedure alhtos( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <htos str>:
   Converts hexadecimal string to textstring.
   Example: "4142" => "AB"
   Converts CRLF (0D0A) to CR (0D).
*)

var
mem: alevalmem;
arg1WithoutSpaces,fromPtr,toPtr,s: fsptr;
i,len: alint16;
ch: char;
lastWasCR: boolean;

begin
alevaluate(pargs,pstateenv,mem,[1]);

lastWasCR:= false;
with pargs do begin

   // Create a copy of arg 1 without spaces
   fromPtr:= arg[1];
   fsNew(arg1WithoutSpaces);
   toPtr:= arg1WithoutSpaces;
   len:= 0;
   while (fromPtr^<>eoa) and (fromPtr^<>eofs) do begin
      ch:= fromPtr^;
      if fslcWsTab[ch]<>' ' then begin
         fspshend(toPtr,ch);
         len:= len+1;
         end;
      fsforward(fromPtr);
      end;
   fspshend(toPtr,eoa);

   if odd(len) then begin
      iodebugmess(
'x(<htos ...>): Warning: Hex string is of odd len. Removes last char.');
      len:= len-1;
      end;

   s:= arg1WithoutSpaces;

   // To please the compiler:
   ch:= '0';

   for i:= 1 to len do begin
      if odd(i) then ch:= char(alhextoint(s^))
      else begin
         ch:= char( integer(ch)*16 + alhextoint(s^) );
         if ord(ch)>=ioeobl then begin
            if not speccharwarningissued and
               not iosuppressbadcharmessage then begin
               ioErrmessWithDebugInfo('X(<htos ...>): Warning: Special character '
                  + ch + ' found.'
                  +'Characters with code 253..255 ('
                  + char(253) + char(254) + char(255) + ') are not allowed'
                  +' because these values are reserved for use by X.'
                  +'Character will be converted to code 216 ('
                  +char(216)+'). Further warnings will not be shown.');
               speccharwarningissued:= True;
               end;
            ch:= char(216); (* Ø *)
            end;

         // (new: CRLF -> CR)
         if (ch=char(10)) and lastWasCR then
            // (skip)
         else begin
            fspshend(pfuncret,ch);
            lastwasCR:= (ch=char(13));
            end;
         end;
      fsforward(s);
      end; (* for *)

   fsDispose(arg1WithoutSpaces);
   end; (* with *)

aldispose(pargs,mem);
end; (*alhtos*)




// (new:)
procedure alstoh( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <stoh str>:
   Converts text string to hexadecimal string.
   Example: "AB" => "4142"
   Convert new line (CR) to CRLF.
   The reason to this is (i think) that the hexadecimal
   notation is used externally (for binary files), where
   CRLF is a common way to represent newline, while as the
   string is for internal use in X, where CR is used to represent
   newline.
*)

var
mem: alevalmem;
s: fsptr;

begin
alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

   s:= arg[1];
   while not (s^=eoa) do begin
      if s^=char(13) then begin
         fspshend(pfuncret,'0');
         fspshend(pfuncret,'D');
         fspshend(pfuncret,'0');
         fspshend(pfuncret,'A');
         fsforward(s);
         if s^=char(10) then fsforward(s);
         end
      else begin
	      fspshend(pfuncret,alinttohex(integer(s^) div 16));
	      fspshend(pfuncret,alinttohex(alint16(s^) mod 16));
	      fsforward(s);
         end;
      end;
   end; (* with *)

aldispose(pargs,mem);
end; (*alstoh*)



procedure alsleep( var pargs: xargblock;
                   var pstateenv: xstateenv );
(* <sleep n>:
   Sleep for n milliseconds.
   Allow possible other threads during sleep.
*)

var
mem: alevalmem;
n: integer;

begin
alevaluate(pargs,pstateenv,mem,[1]);
n:= fsposint(pargs.arg[1]);
if n<0 then xScriptError('X(<sleep n>): Expected a number >= 0, found "'+
    alfstostr100(pargs.arg[1],eoa)+'".');
if n>0 then ioEnableAndSleep(n);

aldispose(pargs,mem);
end; (*alsleep*)




procedure alexec( var pargs: xargblock;
                   var pstateenv: xstateenv; pfuncret: fsptr );
(* <exec str>:
   Compile and execute a string.
*)
var mem: alevalmem; compout: fsptr; error: boolean;
begin (*alexec*)
alevaluate(pargs,pstateenv,mem,[1]);

if not xCompileErrorActive then begin
   fsnew(compout);

   // (new:)
   xCompileAndResolve(pargs.arg[1],compout,eoa,false,nil,0,0);
   // (old:)xcompilestring(pargs.arg[1],compout,eoa,false,nil,0,0);

   if not xCompileErrorActive then
      xevaluate(compout,eofs,xevalnormal,pstateenv,pfuncret);
   fsdispose(compout);
   end;

aldispose(pargs,mem);
end; (*alexec*)

(* (Temporary version, later deserted. Allows exec to be performed even
   if a compilation error earlier was found. Probably not a good idea.) *)
procedure alexec_temp( var pargs: xargblock;
                   var pstateenv: xstateenv; pfuncret: fsptr );
(*  temp <exec str>. Compile and execute a string. *)
var mem: alevalmem; compout: fsptr; error: boolean;
savecompileerroractive: boolean;
begin (*alexec_temp*)
alevaluate(pargs,pstateenv,mem,[1]);

savecompileerroractive:= xCompileErrorActive;
xCompileErrorActive:= false;

fsnew(compout);

// (new:)
xCompileAndResolve(pargs.arg[1],compout,eoa,false,nil,0,0);
// (old:)xcompilestring(pargs.arg[1],compout,eoa,false,nil,0,0);

if not xCompileErrorActive then
      xevaluate(compout,eofs,xevalnormal,pstateenv,pfuncret);
fsdispose(compout);

xCompileErrorActive:= saveCompileErrorActive;

aldispose(pargs,mem);
end; (*alexec_temp*)


procedure alconnected( var pargs: xargblock;
                 var pstateenv: xstateenv; pfuncret: fsptr );
(* <connected domain:portnr>:
   Returns yes if arg[1] is a connected socket.
*)

var
mem: alevalmem;

begin
alevaluate(pargs,pstateenv,mem,[1]);

if ioconnected(pargs.arg[1],eoa,pstateenv.cinp) then begin
    fspshend(pfuncret,'y');
    fspshend(pfuncret,'e');
    fspshend(pfuncret,'s');
    end
else begin
    fspshend(pfuncret,'n');
    fspshend(pfuncret,'o');
    end;

aldispose(pargs,mem);
end; (*alconnected*)

var semlevel:integer= 0;

function alErrCode2Message(perrcode: integer): string;
(* Usage example:
   e:= getlasterror;
   if e<>0 then xProgramError(alErrCode2Mess(e));. *)
var
P: PChar;
e,f: dword;
begin

semlevel:= semlevel+1;
e:= perrcode;

f:= FormatMessage(Format_Message_Allocate_Buffer + Format_Message_From_System,
   nil,
   e,
   0,
   @P,
   0,
   nil);

if f <> 0 then begin
   Result := inttostr(e)+' ('+p+')';
   LocalFree(Integer(P))
   end
else begin
   if semlevel<2 then
      Result := inttostr(e)+ ' '+ alSystemErrorMessage
   else
      Result:= inttostr(e);
   end;

semlevel:= semlevel-1;
end; (*alErrCode2Message*)


function alSystemErrorMessage: string;
(* From Torry's Delphi pages. *)
var e: dword;
begin
e:= getlasterror;
result:= alErrCode2Message(e);
end; (*alSystemErrorMessage*)

function alSystemErrorMessage0: string;
(* From Torry's Delphi pages. *)
var
P: PChar;
e,f: dword;
begin

semlevel:= semlevel+1;
e:= getlasterror;

f:= FormatMessage(Format_Message_Allocate_Buffer + Format_Message_From_System,
   nil,
   e,
   0,
   @P,
   0,
   nil);

if f <> 0 then begin
   Result := inttostr(e)+' ('+p+')';
   LocalFree(Integer(P))
   end
else begin
   if semlevel<2 then
      Result := inttostr(e)+ ' '+ alSystemErrorMessage
   else
      Result:= inttostr(e);
   end;

semlevel:= semlevel-1;
end; (*alSystemErrorMessage0*)

function alseerrmess(perrcode: integer): string;
(* Decodes error code from shellexecute.
From newsgoups:Borland:borland public ... *)
begin
if perrcode <= 32 then case perrcode of
   0: alSeErrMess := 'The operating system is out of memory or resources.';
   Error_File_Not_Found,
   Error_Path_Not_Found,
   Error_Bad_Format,
   SE_Err_AccessDenied,
   SE_Err_AssocIncomplete,
   SE_Err_DDEBusy,
   SE_Err_DDEFail,
   SE_Err_DDETimeout,
   SE_Err_DLLNotFound,
   SE_Err_NoAssoc,
   SE_Err_OOM,
   (* SE_Err_PNF, *)
   SE_Err_Share: alSEErrMess := SysErrorMessage(perrcode);
   else alSEErrMess := 'Unexpected error';
end;
end;

function alshowcmd(ps:fsptr; pendch: char): integer;
(* Decode showcmd string (used in shellexecute). Example:
   alshowcmd('SW_SHOWNORMAL') = SH_SHOWNORMAL. *)
var str: string; res: integer;
begin
res:= SW_SHOWNORMAL;
str:= alfstostrlc(ps,pendch);
if str='sw_hide' then res:= sw_hide
else if str='sw_maximize' then res:= sw_maximize
else if str='sw_minimize' then res:= sw_minimize
else if str='sw_restore' then res:= sw_restore
else if str='sw_show' then res:= sw_show
else if str='sw_showdefault' then res:= sw_showdefault
else if str='sw_showmaximized' then res:= sw_showmaximized
else if str='sw_showminimized' then res:= sw_showminimized
else if str='sw_showminnoactive' then res:= sw_showminnoactive
else if str='sw_showna' then res:= sw_showna
else if str='sw_shownoactivate' then res:= sw_shownoactivate
else if str='sw_shownormal' then res:= sw_shownormal
else xScriptError('x(alshowcmd): Unidentified show cmd: "'+str+'".');
alshowcmd:= res;
end; //alshowcmd

procedure alTerminate;
(* <terminate>:
   Terminates the X program.
*)

begin
postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFTERMINATE,0)
end;


const
startposx = 30;
startposy = 70;

var
curposx: integer = startposx;
curposy: integer = startposy;
lineheight: integer = 0;
editstyle: cardinal = WS_VISIBLE or WS_CHILD;
editExStyle: cardinal = WS_EX_CLIENTEDGE;
buttonstyle: cardinal = WS_VISIBLE or WS_CHILD;
buttonExStyle: cardinal = WS_EX_CLIENTEDGE;
tform1style: cardinal = $16CF0000;
tform1exstyle: cardinal = $10100;
defaultstyle: cardinal = WS_VISIBLE or WS_CHILD;
defaultExStyle: cardinal = 0;
defaultWidth: integer = 100;
defaultHeight: integer = 20;

handleTable: array[1..100] of hWnd;
lastCreatedWindow: integer= 0;

procedure alwin32( var pargs: xargblock;
   var pstateenv: xstateenv;
   pfuncret: fsptr);
(* <win32 function[,parameters...]>:
   <win32 clearCommError,port>
   <win32 createprocess,commandstr>
   <win32 createwindow>
   <win32 createwindowex>
   <win32 createwindowex,button[,...]>
   <win32 createwindowex,edit[,...]> => nr
   <win32 destroywindows>
   <win32 dialogmessageloop[,handle]>
   <win32 gettickcount>
   <win32 getEnvironmentVariable,name>
   <win32 getHandle,nr>
   <win32 getlasterror>
   <win32 happlication>
   <win32 hinstance>
   <win32 hmainwindow>
   <win32 hresultarea>
   <win32 minimize>
   <win32 restore>
   <win32 setwindowtext,...>
   <win32 shellexecute,showcmd,filename[,arguments[,defaultdir]]>
   <win32 shellexecuteex,showcmd,filename[,arguments[,defaultdir]]>
         (showcmd = sw_shownormal, sw_showhide, ...)
   <win32 style,...>
   <win32 terminate>
   <win32 terminateprocess,...>
   <win32 updateform> - Force update of form
   <win32 waitforsingleobject,...>

   ShellexecuteEx is like Shellexecute, except that it waits for
   completion.
*)
const
SEE_MASK_NOASYNC = SEE_MASK_FLAG_DDEWAIT;

type pshellexecuteinfoa = ^tshellexecuteinfoa; // FPC


var
mem: alevalmem;
arg2,arg3,arg4,arg5: string;
arg6,arg7,arg8,arg9: string;
pi: TProcessInformation;
si: TStartupInfo;
tickcount: longint;
success: boolean;
se,i: integer;
argptr:^xargblock;
filep,argp,dirp: PCHAR;
showcmd: integer;
process: cardinal;
shellinfo: shellexecuteinfo;
WndClass: array[0..255] of char;
n:integer;
iarg2,iarg4,iarg5,iarg6,iarg7,iarg8:integer;
useoption,error: boolean;
handle: hwnd;
exStyle,style: cardinal;
hmenu: integer;
processint: integer;

(* for clearCommError. *)
comhandle: THandle;
comErrors: Cardinal;
comstate: Tcomstat;
comstateptr: pComstat;
comres: boolean;
comErrorStr: string;
comStateStr: string;
comFlag: DWORD;
cbInQue: DWORD;
cbOutQue: DWORD;

begin
alevaluate(pargs,pstateenv,mem,[1..5]);

with pargs do begin

   if narg>=2 then arg2:= xfstostr(arg[2],eoa)
   else arg2:= '';
   if narg>=3 then arg3:= xfstostr(arg[3],eoa)
   else arg3:= '';
   if narg>=4 then arg4:= xfstostr(arg[4],eoa)
   else arg4:= '';
   if narg>=5 then arg5:= xfstostr(arg[5],eoa)
   else arg5:= '';
   if narg>=6 then arg6:= xfstostr(arg[6],eoa)
   else arg6:= '';
   if narg>=7 then arg7:= xfstostr(arg[7],eoa)
   else arg7:= '';
   if narg>=8 then arg8:= xfstostr(arg[8],eoa)
   else arg8:= '';

   // Gettickcount is placed first for efficiency reasons.
   if alfstostrlc(arg[1],eoa)='gettickcount' then begin
      tickcount:= gettickcount;
      alinttofs(tickcount,pfuncret);
      end

   else if (alfstostrlc(arg[1],eoa)='clearcommerror') and (narg=2) then begin

      comHandle:= ioComHandle(arg[2],eoa);
      if comHandle<>0 then begin
         comErrors:= 0;
         comStatePtr:= @comState;
         comres:= ClearCommError(comhandle,comErrors,comStatePtr);
         if comres=true then begin
            //Print errors and state
            comerrorstr:= '';
            if ComErrors and $0010 <> $0000 then comErrorStr:= comErrorStr + '+CE_BRAKE';
            if ComErrors and $0008 <> $0000 then comErrorStr:= comErrorStr + '+CE_FRAME';
            if ComErrors and $0002 <> $0000 then comErrorStr:= comErrorStr + '+CE_OVERRUN';
            if ComErrors and $0001 <> $0000 then comErrorStr:= comErrorStr + '+CE_RXOVER';
            if ComErrors and $0004 <> $0000 then comErrorStr:= comErrorStr + '+CE_RXPARITY';
            alStrToFs('Errors = ' + inttostr(ComErrors) + ' (' + comErrorStr + ')' + char(13),pfuncret);

            // State
            comStateStr:= '';
            comFlag:= comStatePtr^.flag0;
            cbInQue:= comStatePtr^.cbInQue;
            cbOutQue:= comStatePtr^.cbOutQue;
            comStateStr:= '';
            if (comFlag and $80000000) <> $0000 then comStateStr:= comStateStr + '+fCtsHold';
            if (comFlag and $40000000) <> $0000 then comStateStr:= comStateStr + '+fDsrHold';
            if (comFlag and $20000000) <> $0000 then comStateStr:= comStateStr + '+fRlsdHold';
            if (comFlag and $10000000) <> $0000 then comStateStr:= comStateStr + '+fXoffHold';
            if (comFlag and $08000000) <> $0000 then comStateStr:= comStateStr + '+fXoffSent';
            if (comFlag and $04000000) <> $0000 then comStateStr:= comStateStr + '+fEof';
            if (comFlag and $02000000) <> $0000 then comStateStr:= comStateStr + '+fTxim';
            alStrToFs('State: Flags=' + inttostr(comFlag) + ' (' + comStateStr + ')' +
               ' cbInQue=' + inttostr(cbInQue) + ' cbOutQue=' + inttostr(cbOutQue) +
               '.',pfuncret);
            end;
         end
      else xscriptError('X(<win32 clearCommError,...>: Name of serial port was ' +
         ' expected, but "' + arg2 + '" does not appear to be a serial port (no comhandle).');
      end

   else if (alfstostrlc(arg[1],eoa)='createprocess') and (narg>=2) then begin

      FillMemory(@si,sizeof(si),0);
      si.cb:= sizeof(si);
      success:= CreateProcess(nil,PChar(arg2),nil,nil,false,
        NORMAL_PRIORITY_CLASS,nil,nil,si,pi);
      if not success then
         xScriptError('X(<win32 createprocess,...>): Failed with code '+
          alSystemErrorMessage+'.');

      process:= pi.hProcess;
      if (process <> 0) then
         waitForSingleObject(process,INFINITE);

      windows.closeHandle(pi.hThread);
      windows.closeHandle(process);
      end

   else if (alfstostrlc(arg[1],eoa)='createwindow') and (pargs.narg=1) then
     // Create main window
     iofapphandle:= CreateWindow('xwindowclass','Title Bar',
             WS_OVERLAPPEDWINDOW or WS_VISIBLE,
             10,10,340,220,0,0,hInstance,nil)

   else if (alfstostrlc(arg[1],eoa)='createwindowex') and (pargs.narg>=2) then begin
     (* Examples: <win32 createwindow,edit,,<htod 50800004>,100,100> *)
     if (alfstostrlc(arg[2],eoa)='edit') then begin
        exStyle:= editExStyle;
        style:= EditStyle;
        end
     else if (alfstostrlc(arg[2],eoa)='button') then begin
        exStyle:= buttonExStyle;
        style:= ButtonStyle;
        end
     else if (alfstostrlc(arg[2],eoa)='tform1') then begin
        exStyle:= tform1ExStyle;
        style:= tform1Style;
        end
     else begin
        exStyle:= defaultExStyle;
        style:= defaultStyle;
        end;

     if pargs.narg>=4 then iarg4:= fsposint(pargs.arg[4])// width
     else iarg4:= defaultwidth;

     if pargs.narg>=5 then iarg5:= fsposint(pargs.arg[5])// height
     else iarg5:= defaultheight;

     if pargs.narg>=6 then iarg6:= fsposint(pargs.arg[6])// additional style options
     else iarg6:= 0;
     style:= style or iarg6;

     if pargs.narg>=7 then iarg7:= fsposint(pargs.arg[7])// additional ExStyle options
     else iarg7:= 0;
     exstyle:= exstyle or iarg7;

     lastCreatedWindow:= lastCreatedWindow+1;
     // CreateWindowEx(WS_EX_CLIENTEDGE,pansichar(arg2), pansichar(arg3),
     if (ws_child and style)<>0 then hmenu:= lastCreatedWindow
     else hmenu:= 0;

     handle:= CreateWindowEx(exStyle,pansichar(arg2), pansichar(arg3),
        style,
        curposx+10, curposy+10, iarg4, iarg5,
        iofapphandle,
        hmenu, hInstance, nil);
     if handle>0 then begin
        handleTable[lastCreatedWindow]:= handle;
        curposx:= curposx+10+iarg4;
        if lineheight<iarg5 then lineheight:= iarg5;
        alinttofs(lastcreatedwindow,pfuncret)
        end
     else begin
        xProgramError('<win32 createwindowex,arg2,...>: Unable to create window - ' +
           alSystemErrorMessage() + '.');
        lastCreatedWindow:= lastCreatedWindow-1;
        end;
     end

   else if (alfstostrlc(arg[1],eoa)='destroywindows') and (pargs.narg=1) then begin
     for i:= 1 to lastCreatedWindow do
        destroywindow(handleTable[i]);
     lastCreatedWindow:=0;
     curposx:= startposx;
     curposy:= startposy;
     end

   else if (alfstostrlc(arg[1],eoa)='dialogmessageloop') and (pargs.narg<=2) then begin
      (* Run the standard message loop until wm_quit is received, use
         isDialogMessage(...) if arg 2 is specified. *)
      if pargs.narg=2 then handle:= fsposint(pargs.arg[2]) else handle:= 0;
      iofDialogMessageLoop(handle);
      end

   else if alfstostrlc(arg[1],eoa)='getenvironmentvariable' then begin
      alstrtofs(sysutils.getEnvironmentVariable(arg2),pfuncret);
      end

   else if (alfstostrlc(arg[1],eoa)='gethandle') and (pargs.narg=2) then begin
     iarg2:= fsposint(arg[2]);
     if (iarg2>0) and (iarg2<=lastCreatedWindow) then
        alinttofs(handleTable[iarg2],pfuncret)
     else
        alinttofs(0,pfuncret);
     end

   else if (alfstostrlc(arg[1],eoa)='getlasterror') and (pargs.narg=1) then
     alStrToFs(alSystemErrorMessage(),pfuncret)

   else if alfstostrlc(arg[1],eoa)='happlication' then begin
      if narg>1 then begin
         if alfstoint(arg[2],iarg2) then
            iofapphandle:= iarg2
         else
            xProgramError('X(<win32 happlication' + alfstostr(arg[2],eoa) +
            '>): Expected an integer but found "' +
            alfstostr(arg[2],eoa) + '".');
         end
      else begin
         handle:= iofapphandle;
         alstrtofs(inttostr(integer(handle)),pfuncret);
         end;
      end

   else if alfstostrlc(arg[1],eoa)='hinstance' then begin
      alstrtofs(inttostr(integer(hinstance)),pfuncret);
      end

   else if alfstostrlc(arg[1],eoa)='hmainwindow' then begin
      alstrtofs(inttostr(iofCurrentFormHandle),pfuncret);
      end

   else if alfstostrlc(arg[1],eoa)='hresultarea' then begin
      alstrtofs(inttostr(iofResultAreaHandle),pfuncret);
      end

   else if alfstostrlc(arg[1],eoa)='minimize' then begin
      postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFMINIMIZE,0);
      end

   else if alfstostrlc(arg[1],eoa)='restore' then begin
      postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFRESTORE,0);
      end

   else if (alfstostrlc(arg[1],eoa)='setwindowtext') and (pargs.narg>=3) then begin
     iarg2:= fsposint(arg[2]);
     if not SetWindowText(iarg2, pansichar(arg3)) then
        // In case of failure
        xProgramError('<win32 setwindowtext,'+arg2+','+arg3+'>: Unable to set window text - ' +
           alSystemErrorMessage() + '.');
     end

   else if (alfstostrlc(arg[1],eoa)='shellexecute') and (narg>=3)
      and (narg<=5) then begin

      if althreadnr=0 then begin

         (* Main thread - run directly *)
         showcmd:= alshowcmd(pargs.arg[2],eoa);
         filep:= PChar(arg3);
         if narg>=4 then argp:= PChar(arg4) else argp:= nil;
         if narg>=5 then dirp:= PChar(arg5) else dirp:= nil;
         ioenableotherthreads(27);
         try
            se:= ShellExecute(iofCurrentFormhandle,PChar('open'),filep,
               argp,dirp,showcmd);
         finally
            iodisableotherthreads(27);
            end;
         if se<=32 then begin
            xScriptError('X(<win32 shellexecute,...'+arg3+'...>): Failed with code '+
             inttostr(se) + ' - "'+alseerrmess(se) + '".');
            alinttofs(se,pfuncret);
            end;
         end
      else begin
         (* Sub thread - run via postmessage to main form. *)
         // <win32 Shellexecute,operation,filename[,arguments[,defaultpath]]>
         // copy arguments 2..n to a new record
         new(argptr);
         for i:= 2 to pargs.narg do begin
            fsnew(argptr^.arg[i-1]);
            fscopy(pargs.arg[i],argptr^.arg[i-1],eoa);
            end;
         argptr^.narg:=pargs.narg-1;

         // Send to main form
         postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFSHELLEXECUTE,longint(argptr));

         // Enable windows to do shellexecute
         ioEnableAndSleep(1);
         end;
      end (* <win32 shellexecute ...> *)

   else if (alfstostrlc(arg[1],eoa)='shellexecuteex') and (narg>=3)
      and (narg<=5) then begin

      if (althreadnr=0) or true then begin

         (* Main thread - run directly *)
         showcmd:= alshowcmd(pargs.arg[2],eoa);
         filep:= PChar(arg3);
         if narg>=4 then argp:= PChar(arg4) else argp:= nil;
         if narg>=5 then dirp:= PChar(arg5) else dirp:= nil;
         FillMemory(@shellinfo,sizeof(shellinfo),0);
         shellinfo.cbSize:= sizeof(shellinfo);
         shellinfo.fMask:= see_mask_flag_no_ui or see_mask_nocloseprocess or
            see_mask_noasync;
         shellinfo.lpFile:= filep;
         shellinfo.lpParameters:= argp;
         shellinfo.nShow:= showcmd;
         shellinfo.lpDirectory:= dirp;
         ioenableotherthreads(28);
         process:= 0;

         try
            success:= ShellExecuteExA(pshellexecuteinfoa(@shellinfo));
            process:= shellinfo.hProcess;
            (* (old:)
            if (process <> 0) then
              waitForSingleObject(process,INFINITE);*)

         finally
            iodisableotherthreads(28);
            end;

         if not success then begin
            se:= getlasterror();
            xScriptError('X(<win32 shellexecuteex,...'+arg3+'...>): '+
               alseerrmess(se) +'.');
            process:= 0;
            end;

         // Return process handle.
         alstrtofs(inttostr(process),pfuncret);
         end
      else begin
         (* BFn 111107: This branch has been bypassed because we do not see why
            shellexecuteeex could not be called directly from a thread.
            (see "true" above). *)
         (* Sub thread - run via postmessage to main form. *)
         // <win32 Shellexecute,operation,filename[,arguments[,defaultpath]]>
         // copy arguments 2..n to a new record
         new(argptr);
         for i:= 2 to pargs.narg do begin
            fsnew(argptr^.arg[i-1]);
            fscopy(pargs.arg[i],argptr^.arg[i-1],eoa);
            end;
         argptr^.narg:=pargs.narg-1;

         // Send to main form
         postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFSHELLEXECUTEEX,longint(argptr));

         // Enable windows to do shellexecute
         ioEnableAndSleep(1);
         end;
      end (* <win32 shellexecuteex ...> *)

   else if (alfstostrlc(arg[1],eoa)='style') and (pargs.narg>=4) then begin
     if alfstostrlc(arg[4],eoa)='yes' then useoption:= true
     else if alfstostrlc(arg[4],eoa)='no' then useoption:= false
     else error:= true;

     if not error then begin
        if alfstostrlc(arg[2],eoa)='edit' then begin
           if alfstostrlc(arg[3],eoa)='es_multiline' then begin
              if useoption then editstyle:= editstyle or $4
              else editstyle:= editstyle and (not $4);
              end;
           end;
        end;
     end

   else if alfstostrlc(arg[1],eoa)='terminate' then begin
      postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFTERMINATE,0);
      end

   else if alfstostrlc(arg[1],eoa)='terminateprocess' then begin
      processInt:= fsPosInt(pargs.arg[2]);
      if processInt>=0 then begin
         if (processInt <> 0) then begin
            success:= terminateProcess(processInt,0);
            if success then
               (* Do not close handle unless success because CloseHandle can raise exception if
                  the handle is invalid. *)
               windows.closeHandle(processInt)

            else begin
               se:= getlasterror();
               if se=error_access_denied then begin
                  (* Accept because this is what is returned if the process was already
                     terminated. *)
                  windows.closeHandle(processInt);
                  success:= true;
                  end
               else begin
                  xScriptError('X(<win32 terminateProcess,'+arg2+'>): '+alseerrmess(se)+'.');
                  end;
               end;

            end;
         end
      else xScriptError('win32 TerminateProcess: Expected positive integer as arg but found '+arg2+'.');
      end

   else if alfstostrlc(arg[1],eoa)='updateform' then begin
      postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFUPDATEFORM,0);
      end

   else if alfstostrlc(arg[1],eoa)='waitforsingleobject' then begin
      processInt:= fsPosInt(pargs.arg[2]);
      if processInt>=0 then begin
         if (processInt <> 0) then begin
            waitForSingleObject(processInt,INFINITE);
            windows.closeHandle(processInt);
            end;
         end
      else xScriptError('win32 waitforsingleobject: Expected positive integer as arg but found '+arg2+'.');
      end

   else xScriptError('X(<win32 ...>): Unknown Win32 function - '
     +alfstostr100(arg[1],eoa)+'.');
   end;

aldispose(pargs,mem);
end; (*alwin32*)


procedure alWindowFormat( var pargs: xargblock;
                 var pstateenv: xstateenv;
                 pfuncret: fsptr);
(* <windowFormat x,y,xsize,ysize>:
   Moves, or changes the size of, the X interpreter window.
*)
(* <formmove x,y,xsize,ysize>:
   Renamed to <windowFormat ...>.
   Temporarily supported for backwards compatibility.
*)

var
mem: alevalmem;
var x,y,xsize,ysize: integer;

begin
alevaluate(pargs,pstateenv,mem,[1..4]);

if pargs.narg=0 then begin
   iofGetFormValues(x,y,xsize,ysize);
   fsbitills(x,pfuncret);
   fspshend(pfuncret,' ');
   fsbitills(y,pfuncret);
   fspshend(pfuncret,' ');
   fsbitills(xsize,pfuncret);
   fspshend(pfuncret,' ');
   fsbitills(ysize,pfuncret);
   end

else iofrunthreadsafe(iofformmovefid,pargs,pfuncret);

aldispose(pargs,mem);
end; (*alWindowFormat*)


procedure alformcaption( var pargs: xargblock;
                 var pstateenv: xstateenv;
                 pfuncret: fsptr);
(* <formcaption[ string]>:
   <formcaption string>:
   Change X window caption, but only when some x program is running.
   <formcaption>:
   Return current X window caption
*)

var
mem: alevalmem;

begin
alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin
   if narg>0 then iofspecialcaption:= alfstostr(arg[1],eoa)
   else iofspecialcaption:= '';
   iofupdateformcaption;
   end;

aldispose(pargs,mem);
end; (*alformcaption*)


procedure alinputbox( var pargs: xargblock;
                 var pstateenv: xstateenv;
                 pfuncret: fsptr);
(* <inputbox caption,prompt[,default]>:
   Get a field of data from the user with an input box.
*)

var
mem: alevalmem;

begin
alevaluate(pargs,pstateenv,mem,[1..3]);

iofrunthreadsafe(iofinputboxfid,pargs,pfuncret);

aldispose(pargs,mem);
end; (*alinputbox*)



procedure almessagebox( var pargs: xargblock;
                    var pstateenv: xstateenv);
(* <messageBox str>:
   Show modal message and wait for OK from user.
   Example:
   <messagebox Please push button B.>
*)
var mem: alevalmem;
begin
alevaluate(pargs,pstateenv,mem,[1]);

(* iomessagebox calls iofshowmess. *)
iomessagebox(alfstostr(pargs.arg[1],eoa));

aldispose(pargs,mem);
end; (* almessagebox *)


procedure almessagedialog( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <messageDialog msg,buttons>:
   Show modal message and wait for answer from user.
   Example:
   <messageDialog Do you want to start Wlana?,yes/no>
*)
var mem: alevalmem; answers: TMsgDlgButtons;
a2: fsptr; s2: string; answer: word;
begin
alevaluate(pargs,pstateenv,mem,[1,2]);

answers:= [mbyes,mbno];

if pargs.narg>1 then begin
  fsnew(a2);
  fscopy(pargs.arg[2],a2,eoa);
  answers:= [];
  while not (a2^=eofs) do begin
    s2:= alfstostrlc(a2,'/');
    if s2='yes' then answers:= answers + [mbyes]
    else if s2='no' then answers:= answers + [mbno]
    else if s2='ok' then answers:= answers + [mbok]
    else if s2='cancel' then answers:= answers + [mbcancel]
    else if s2='abort' then answers:= answers + [mbabort]
    else if s2='retry' then answers:= answers + [mbretry]
    else if s2='ignore' then answers:= answers + [mbignore]
    else if s2='all' then answers:= answers + [mball]
    else if s2='notoall' then answers:= answers + [mbnotoall]
    else if s2='yestoall' then answers:= answers + [mbyestoall]
    else if s2='help' then answers:= answers + [mbhelp]
    else xScriptError('X(<messagedialog ...>): Unable to identify button '+s2+'.');
    while not ((a2^='/') or (a2^=eofs)) do fsforward(a2);
    if a2^='/' then fsforward(a2);
    end;
  fsdispose(a2);
  end; (* narg>1 *)


(* Old:

if answers<>[] then
  answer:= MessageDlg(alfstostr(pargs.arg[1],eoa),mtcustom,answers,0);
*)

(* New: *)

if answers=[] then begin
   xScriptError('X(<messagedialog ...>): Answers expected in arg2 but not found. Using yes/no instead.');
   answers:= [mbyes,mbno];
   end;

answer:= iofmessagedialog(alfstostr(pargs.arg[1],eoa),answers);

case answer of
   mrYes: alstrtofs('yes',pfuncret);
   mrNo: alstrtofs('no',pfuncret);
   mrOk: alstrtofs('ok',pfuncret);
   mrCancel: alstrtofs('cancel',pfuncret);
   mrAbort: alstrtofs('abort',pfuncret);
   mrRetry: alstrtofs('retry',pfuncret);
   mrIgnore: alstrtofs('ignore',pfuncret);
   mrAll: alstrtofs('all',pfuncret);
   mrNotoall: alstrtofs('notoall',pfuncret);
   mrYestoall: alstrtofs('yestoall',pfuncret);
   else alstrtofs('?',pfuncret);
   end;

aldispose(pargs,mem);
end; (* almessagebox *)

var
environmenthandle: sqlhenv = 0;
connectionhandle: sqlhdbc = 0;

procedure alsql( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <sql function,parameters ...>:
   Calls to ODBC:
   <sql connect,servername,username,password>
   Example:
   <sql connect,My Database,root,1234>
   <sql query,show databases;>
   ...
   <sql disconnect>
*)
var mem: alevalmem; callid: string;
    servername,username,password,query: string;
    result: sqlreturn;
    ok: boolean;
    stmthandle: sqlhstmt;
    columns,i: sqlsmallint;
    indicator: sqlinteger;
    buf: packed array[1..512] of char;
    j: integer;
    done: boolean;
begin
alevaluate(pargs,pstateenv,mem,[1..4]);
ok:= false; result:= 0;
callid:= alfstostrlc(pargs.arg[1],eoa);
if callid='connect' then with pargs do begin
   if narg=4 then begin
      servername:= alfstostr(arg[2],eoa);
      username:= alfstostr(arg[3],eoa);
      password:= alfstostr(arg[4],eoa);

      if connectionhandle=0 then begin
         if odbcsucceeded(sqlallocenv(environmenthandle)) then begin
            if odbcsucceeded(sqlallocconnect(environmenthandle,connectionhandle))
               then begin
               (* OK *)
               end
            else connectionhandle:= 0;
            end
         else connectionhandle:= 0;
         end;

      if connectionhandle<>0 then begin
         result:= sqlconnect(connectionhandle,
            sqlpchar(servername),length(servername),
            sqlpchar(username),length(username),
            sqlpchar(password),length(password));
         if odbcsucceeded(result) then
            ok:= true
         else
            xScriptError('<sql connect,'+servername+
               '...>: Connect failed with error code '+inttostr(result)+'.');
         end
      else xProgramError('<sql connect,'+servername+
         '...>: Unable to allocate environment or connection handle.');
      end
   else xScriptError('<sql connect,'+servername+
      '...>: Expected four parameters, found '+inttostr(narg)+'.');
   if not ok then begin
      if result=0 then result:= 10;
      alinttofs(result,pfuncret);
      end;
   end (*connect*)
else if callid='query' then with pargs do begin
   if narg=2 then begin
      query:= alfstostr(arg[2],eoa);
      if connectionhandle=0 then
         xScriptError('<sql query,'+query+'>: No database to query.')
      else begin
         ok:= True;
         if not odbcsucceeded(sqlallocstmt(connectionhandle,stmthandle)) then
            ok:= False;
         if ok then
            if not odbcsucceeded(sqlexecdirect(stmthandle,sqlpchar(query),length(query))) then
               ok:= False;
         if ok then
            if not odbcsucceeded(SQLNumResultCols(stmthandle,columns)) then
               ok:= False;
         if ok then begin
            (* Loop through the rows in the result-set *)
            while odbcsucceeded(sqlfetch(stmthandle)) do begin
               (* printf("Row %d\n", row++);*)
               (* Loop through the columns *)

               for i:= 1 to columns do begin
                  (* retrieve column data as a string *)
               	if odbcsucceeded(SQLGetData(stmthandle, i, SQL_C_CHAR,
                     sqlpointer(@buf),sizeof(buf),sqlpinteger(@indicator)))
                     then begin
                     fspshend(pfuncret,'|');
                     (* Handle null columns *)
                     if indicator = SQL_NULL_DATA then
                        alstrtofs('NULL',pfuncret)
                     else begin
                        j:= 1;
                        done:= false;
                        while not done do begin
                           if j>sizeof(buf) then done:= true
                           else if buf[j]=char(0) then done:= true
                           else fspshend(pfuncret,buf[j]);
                           j:= j+1;
                           end;
                        end;
	                  (* printf("  Column %u : %s\n", i, buf);*)
                     end
                  end;
               fspshend(pfuncret,char(13));
               end; (*while*)
            end;
         end
      end
   else xScriptError('<sql query>: Expected two parameters, found '+inttostr(narg)+'.');
   end
else if callid='disconnect' then with pargs do begin
   if narg=1 then begin
      if connectionhandle=0 then
         xScriptError('<sql disconnect>: No database to disconnect.')
      else if odbcsucceeded(sqldisconnect(connectionhandle)) then
         connectionhandle:= 0;
      end
   else xScriptError('<sql disconnect>: Expected one parameter, found '+inttostr(narg)+'.');
   end
else xScriptError('<sql '+callid+'...>: Unknown SQL function.');
aldispose(pargs,mem);
end;(* alsql *)


procedure aldebug( var pstateenv: xstateenv );
(* <debug>:
   - Currently not in order -
*)

begin

// if debugform=nil then debugform:= tform2.Create(application);
   //if debugform=nil then debugform:= tform1.Create(application);
      iofstartdebug;
   //debugform.ShowModal;
   //debugform.Show; (* <debug> *)
   //debugshowinfile(pstateenv.cinp);

end; (*aldebug*)


procedure alfileisopen( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <fileisopen fname>:
   Return "yes" if pargs.arg[1] is the name of an
   existing file.
   Example:
   <if <fileisopen localhost:3000>,<close localhost:3000>>
*)
var mem: alevalmem;
begin
alevaluate(pargs,pstateenv,mem,[1]);

if iogetfilenr(alfstostr(pargs.arg[1],eoa))>0 then alstrtofs('yes',pfuncret)
else alstrtofs('no',pfuncret);

aldispose(pargs,mem);
end; (* alfileisopen *)


procedure alfileexists( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <fileexists fname>:
   Return "yes" if pargs.arg[1] is the name of an
   existing file on the disk.
   Example:
   <if <fileexist logfile.txt><command del logfile.txt>>
*)
var mem: alevalmem; filename: string;
begin
alevaluate(pargs,pstateenv,mem,[1]);

filename:= alfstostr(pargs.arg[1],eoa);

if fileexists(filename) then alstrtofs('yes',pfuncret)
else alstrtofs('no',pfuncret);

aldispose(pargs,mem);
end; (* alfileexists *)


procedure aldirectoryexists( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <directoryexists dirname>:
   Return "yes" if pargs.arg[1] is the name of an
   existing directory on the disk.
*)
var mem: alevalmem; filename: string;
begin
alevaluate(pargs,pstateenv,mem,[1]);

filename:= alfstostr(pargs.arg[1],eoa);

if directoryexists(filename) then alstrtofs('yes',pfuncret)
else alstrtofs('no',pfuncret);

aldispose(pargs,mem);
end; (* aldirectoryexists *)


var funcNamtab: Tstringlist = nil;

procedure alfunctions( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <functions[ funcnam]>:
   Return names of all predefined functions (no funcnam)
   or a description of function funcnam.
*)
var
mem: alevalmem;
nr: integer;
defined,predefined: boolean;
name: string;
all: string;
i: integer;

begin (*aFunctions*)

alevaluate(pargs,pstateenv,mem,[1]);

if pargs.narg=0 then begin
   (* Return list of functions. *)

   if funcNamTab=NIL then begin
      funcNamTab:= Tstringlist.create;

      for nr:= 1 to xmaxfuncnr do begin
         xgetfuncinfo(nr,defined,predefined,name);
         if defined and predefined then begin
            // Put names in a stringlist to be able to sort them later.
            funcnamtab.Values[name]:= '1';
            end;
         end;
      // Sort
      funcnamtab.Sort;
      end;
   // Print
   for i:= 0 to funcnamtab.count-1 do begin
      name:= funcnamtab.names[i];
      if i>0 then all:= all+' ';
      all:= all + name
      end;
   alstrtofs(all,pfuncret);
   end
else begin
   // narg = 1. Print help for a specific function

   // Create a help table if this is not already done
   if helpTabIndexNr=0 then createHelpTab;

   // Return the string under index arg1
   alstrtofs(stringtab[helpTabIndexNr].values[alfstostr(pargs.arg[1],eoa)],pfuncret)
   end;

aldispose(pargs,mem);

end; (* alfunctions *)


var
dllfileIndex: Tstringlist = nil;
type
  TSLData = class
    public
      X1: Thandle;
  end;

function alhandle(pfilename: string): Thandle;
var h: Thandle; ix: integer;
begin

if dllfileindex=NIL then dllfileindex:= Tstringlist.Create;

   ix:= dllfileindex.indexof(pfilename);
   if ix=-1 then begin
      // New dll file
      dllfileindex.Add(pfilename);
      ix:= dllfileindex.indexof(pfilename);
      dllfileindex.Objects[ix]:= TSLData.Create;

      h:= loadlibrary(pchar(pfilename));
      if h>32 then TSLData(dllfileindex.Objects[ix]).x1:= h
      else begin
         TSLData(dllfileindex.Objects[ix]).x1:= 0;
         // (new:)
         xScriptError('X(<dllcall ...>): Win32 LoadLibrary was unable to return '+
            'a handle to library '+pfilename+'. Returned value was '+inttostr(h)+
            '. Win32 getlasterror said: '+alSystemErrorMessage+'.');
         end;
      end;
   alhandle:= TSLData(dllfileindex.Objects[ix]).x1;

end; (*alhandle*)

const
dllBufferSize = 100;

type dllRefPartypetype = (refInt,refStr,refSingle);

var
dllBuffer: array[1..dllBufferSize] of integer;
dllbufLast: integer; (* dllBuffer 1.. dllbufLast are in use, rest are not
   (and can be expected to be clear = 0,int).
   dllbufLast is only decreased by <dllbufferclear> *)
dllRefpartype: array[1..dllBufferSize] of dllRefpartypetype;

procedure aldllcall( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <dllcall library,function[,parametertype[,parameter]...],ret-type>:
   Call dll function
   Examples:
   <dllCall user32,MessageBoxA,int,0,str,Do you want to save the file?,str,Save file,int,4,int>
   <dllCall user32,MessageBoxA,int,0,str,It was not possible to
      save the file under the filename xxx.yyy,str,Filename error,int,0,>

   171017:
   parameter types
   ---------------
   int: A 32 bit integer is directly pushed to the stack as argument.

   str: The string is copied to a free entry in a string table (stab).
      The address to the string is pushed to the stack as argument.

   refint: A pointer to the next free entry in dllBuffer is pushed to the stack
      as argument. The entry is a 32 bit integer. It can be accessed before
      and after the call with <dllbuffer n,...>.

   refint*n: A pointer to a free block of n entries is pushed to the stack
      as argument. Each entry contains a 32 bit integer. The entries can be
      accessed before and after the dllcall with <dllbuffer ...>.

   refstr: The next free entry in dllBuffer is allocated. It contains the pointer
      to a buffer of size 2000 bytes. The same pointer is also pushed to the
      stack as argument. The entry can be accessed as string before and after
      the dllcall. The difference between type refstr and type str is that the
      dll-function is allowed to write to the string when refstr is used.
      The str type is intended to be used for strings which are only read by the
      dll function.
      Refstr differs from refint, by pushing the pointer to the string as argument
      (same as str), while as refint pushes a pointer to an entry in dllbuffer.

   ref: A pointer to the next free entry in dllBuffer is pushed to the stack
      as argument. The entry can either be a 32 bit integer or a pointer to a
      2000 byte string buffer. This shall be determined before the call, using
      argument 3 (type str or int) of <dllbuffer ...>. The entry can be accessed
      before and after the dllcall.

   ref*n: A pointer to a free block of n entries is pushed to the stack
      as argument. Each entry can either be a 32 bit integer or a pointer to a
      2000 byte string buffer. This shall be determined before the call, using
      argument 3 (type str or int) of <dllbuffer ...>. The entries can be accessed
      before and after the dllcall.
*)
(* Implementation:

   +++ Cleanup (BFn 170928):
   In order to make the interface less complicated, the possibility to specify
   output parameter types is consistently put in <dllBuffer ...> (which probably
   ought to be renamed to <dllrefpar ...>). But to complete this change
   all scripts which use refStr, refInt, and out*n need to be updated.
*)

var mem: alevalmem;
dllhandle: Thandle;
dllfunc: dword;
dllResult: dword;
a,i: integer;
stab: array[1..18] of string;
atab: array[1..30] of integer;
funcname: string;
espreg0, ebpreg0: longword;
espreg1, ebpreg1: longword;
addr: integer;
fail: boolean;
strcnt,argcnt: integer;
buffer: pChar;
arga: string;
nstr: fsptr;
multiplier: integer;
refCnt: integer;
resPtr: fsptr;

begin
alevaluate(pargs,pstateenv,mem,[1..xmaxnarg]);

if dllCallLogTo then begin
   write(dllCallLogToFile,alShowCall(xCurrentStateEnv^.funcnr,pargs));
   resPtr:= pfuncret;
   fsforwend(resptr);
   end;

with pargs do begin
   fail:= false;
   dllhandle:= alhandle(alfstostr(arg[1],eoa));
   if dllhandle=0 then begin
      xProgramError('X(<dllcall ...>): Unable to find library "' +
      alfstostr(arg[1],eoa) + '".');
      fail:= true;
      end;

   if not fail then begin
      // Get function name
      funcname:= alfstostr(arg[2],eoa);

      // Save current ESP and EBP
      asm
         MOV espreg0,ESP
         MOV ebpreg0,EBP
         end;
      end; (* not fail *)

   // (see http://www.delphi3000.com/articles/article_3771.asp?SK=)

   if not fail then begin
      // We have an odd number of arguments - find function address
      dllfunc:= dword(GetProcAddress(dllhandle,pchar(funcname)));
      if dllfunc=0 then begin
         xScriptError('X(<dllcall ...>): Unable to find function/procedure "' + funcname +
            '" in library "' + alfstostr(arg[1],eoa) +
            '" (note that character case is significant in the name).');
         fail:= true;
         end;
      end;

   if not fail then begin

      // Reset the buffer table
      refCnt:= 0;

      // Put the arguments, according to type, in atab
      strcnt:= 0; argcnt:=0;
      a:=3;
      while (a<=narg-1) and not fail do begin
         argcnt:= argcnt+1;
         arga:= alfstostrlc(arg[a],eoa);
         if
            // (new:)
            (ansiLeftStr(arga,7)= 'refint*') or
            // (old:)
            (ansiLeftStr(arga,7)= 'intout*')
            then begin
            // Prepare by getting number after *
            nstr:= arg[a];
            fsmultiforw(nstr,7);
            multiplier:= fsposint(nstr);
            if multiplier>0 then arga:= ansileftstr(arga,6)
            end
         else if
            // (new:)
            (ansiLeftStr(arga,4)= 'ref*') or
            // (old:)
            (ansiLeftStr(arga,4)= 'out*')
            then begin
            // Prepare by getting number after *
            nstr:= arg[a];
            fsmultiforw(nstr,4);
            multiplier:= fsposint(nstr);
            if multiplier>0 then arga:= ansileftstr(arga,3)
            end
         else begin
            multiplier:= 1;
            end;

         if arga='str' then begin
            strcnt:= strcnt+1;
            stab[strcnt]:= alfstostrConvCrToCrLf(arg[a+1],eoa);
            atab[argcnt]:= integer(stab[strcnt]);
            a:= a+2;
            end
         else if arga='int' then begin
            if not alfstoint(arg[a+1],atab[argcnt]) then
               xScriptError('Since argument ' + inttostr(a) +
                  ' was "int", an integer was expected as argument ' +
                  inttostr(a+1) + ' but instead "' + alfstostr(arg[a+1],eoa) +
                  '" was found.');
            a:= a+2;
            end
         else if
            // (new:)
            (arga='refint') or
            // (old:)
            (arga='intout')
            then begin
            // Handles also refInt*n (old: intout*n) (see above)
            refCnt:= refCnt+1;
            atab[argcnt]:= integer(@dllBuffer[refCnt]);

            if dllRefpartype[refCnt]=refStr then begin
               FreeMem(pointer(dllBuffer[refCnt]));
               dllRefPartype[refCnt]:= refInt;
               end;

            multiplier:= multiplier-1;
            // Reserve and typeset int 2..n if refInt*n was used
            while multiplier>0 do begin
               refCnt:= refCnt+1;
               if dllRefpartype[refCnt]=refStr then begin
                  // Release old string buffer
                  FreeMem(pointer(dllBuffer[refCnt]));
                  dllRefpartype[refCnt]:= refInt;
                  end;
               multiplier:= multiplier-1;
               end;
            a:= a+1;
            end
         else if
            // (new:)
            (arga='refstr') or
            // (old:)
            (arga='strout')
            then begin
            refCnt:= refCnt+1;
            if dllRefpartype[refCnt]<>refStr then begin
               // Get new string buffer.
               GetMem(Buffer, 2000);
               dllBuffer[refCnt]:= integer(Buffer);
               dllRefpartype[refCnt]:= refStr;
               end;
            atab[argcnt]:= dllBuffer[refCnt];
            a:= a+1;
            end
         else if
            // (new:)
            (arga='ref') or
            // (old:)
            (arga='out') then begin
            // Handles also ref*n (old: out*n) (see above)
            (* Like refInt*n except it expects types to have been
               set beforehand, using <dllBuffer ...>. *)
            refCnt:= refCnt+1;
            atab[argcnt]:= integer(@dllBuffer[refCnt]);
            // Reserve additional n-1 pars
            refCnt:= refCnt+multiplier-1;
            a:= a+1;
            end
         else begin
            xScriptError('X(<dllcall ...>): Expected "int", "str", "refInt", '+
               '"refStr" or "out" but found "' + alfstostr(arg[a],eoa) +
               '" (dll function not called).');
            fail:= true;
            end;
         end;
      end;

   (* Update dllbufLast, which tells how many buffer slots are in use
      (the rest are expected to be 0 and int). *)
   if dllbufLast<refCnt then dllbufLast:= refCnt;

   if not fail then begin


      // Calling a dll function can cause exceptions of parameters are wrong

      (* Try was put here because if it was put after pushing arguments,
         then result appeared to be wrong (GetActiveWindow
         appeared to return an invalid handle). *)
      (* ***** This exception frame does not appear to work - program
         aborts without being handled by the exception. *)
      try

        // For FPC:
        (* Save current ESP and EBP again because try changes ESP in
           Free Pascal Compiler. *)
        asm
           MOV espreg0,ESP
           MOV ebpreg0,EBP
           end;


      // Push the arguments to the stack, in reverse order
      for a:= argcnt downto 1 do begin
         addr:= atab[a];
         asm
            push addr
            end;
         end;

      // Call the function
         asm
            call dllfunc
            mov dllResult,eax
            end;

      // Check and, if necessary, restore stack pointer
      asm
         MOV espreg1,ESP
         MOV ebpreg1,EBP
         end;
      if (espreg1<>espreg0) then begin
         asm
            MOV ESP,espreg0
            end;

         (* This error message removed, because it Aonix ada is told to
            use the standard calling convention (DLL_STDCALL), then X does
            not find the funtion
         xScriptError('X(<dllcall ...,'+funcname+
            '...>: The stack pointer was not properly restored '+
            'by the called function. It differed by '+
            inttostr(espreg0-espreg1)+ ' (restored). Suggestion: check if '+
            'number and types of arguments are correct and that the called '+
            'function uses the standard calling convention.'); *)
         end;

      except
        on E: Exception do xScriptError('Dllcall raised exception: '+E.Message);
      end;(* Try *)

      if (ebpreg1<>ebpreg0) then
         xProgramError('X(<dllcall ...>): Program error? - Unexpected change of ebpreg.');

      // Return dllResult if result type is not empty
      if alfstostr(arg[narg],eoa)='' then
         // Do not return any result
      else if alfstostr(arg[narg],eoa)='str' then try
         // String type
         alstrtofs(string(pchar(dllResult)),pfuncret)
         except
            xScriptError('X(<dllcall ...>): Because return type was "str", '+
            'dllcall expected it to point at a string, but when trying to read '+
            'this string, an exception was raised.');
         end (* try *)
      else if alfstostr(arg[narg],eoa)='int' then begin

         // Integer type
         alinttofs(integer(dllResult),pfuncret);

         // Keep track of created top level windows.
         if (alfstostrlc(arg[2],eoa)='createwindowa') and
            (alfstostrlc(arg[4],eoa)='xwindowclass') and
            (atab[8]=0)(* no parent *)
            or
            (alfstostrlc(arg[2],eoa)='createwindowexa') and
            (alfstostrlc(arg[6],eoa)='xwindowclass') and
            (atab[9]=0)(* no parent *)
            then begin

            if dllResult>0 then
               (* A top level window of class xwindowclass was created
                  - Save reference so it can be deleted at cleanup. *)
               iofAddTopLevelWindow(dllResult);
            end;
         end (* int *)
      else
         // Wrong result type
         xScriptError('X(<dllcall ...>): Expected result type "", "str" or "int" but found "'+
            alfstostr(arg[narg],eoa) + '".');

      end; (* not fail *)

   end; (*with*)

if dllCallLogTo then
   writeln(dllCallLogToFile,' => '+fstostr(resPtr));

aldispose(pargs,mem);
end; (* aldllcall *)

type singleToInt = RECORD CASE integer OF
           1: (s: single);
           2: (i: longint);
          end;

(* (new:) *)
procedure aldllBuffer( var pargs: xargblock;
                    var pstateenv: xstateenv;
                    pfuncret: fsptr);
(* <dllBuffer nr[,value]>:
   Handle reference parameters and structs for dllcalls.
   Example 1:
   <dllcall mylib,myfunc,int,1234,refInt,>
   <set $handle,<dllBuffer 1>>

   Example 2:
   <dllBuffer 1,0>
   <dllBuffer 2,0>
   <dllcall user32,ClientToScreen,int,$1,refInt*2,int>
   <set $origox,<dllBuffer 1>>
   <set $origoy,<dllBuffer 2>>

   Example 3:
   ( *
   ofn.lStructSize = sizeof ( ofn ); (1)
   ofn.lpstrFilter = "All\0*.*\0Text\0*.TXT\0"; (4)
   ofn.nFilterIndex =1; (7)
   ofn.lpstrFile = szFile ; (8)
   ofn.lpstrFile[0] = '\0';
   ofn.nMaxFile = sizeof( szFile ); (9)
   ofn.Flags = OFN_PATHMUSTEXIST|OFN_FILEMUSTEXIST ; (14)
   GetOpenFileName( &ofn );
   MessageBox ( NULL , ofn.lpstrFile , "File Name" , MB_OK);
   * )
   <dllBufferclear>
   <dllBuffer 1,88>
   <dllBuffer 4,All<char 0>*.*<char 0>Text<char 0>*.TXT,str>
   <dllBuffer 7,1>
   <dllBuffer 8,,str>
   <dllBuffer 9,2000>
   <dllBuffer 10,<calc <htod 1000>+<htod 800>>>
   <dllcall Comdlg32,GetOpenFileNameA,out*22,int>
   <wcons filename=<dllBuffer 8>>
*)

var mem: alevalmem; nr: integer; arg2: integer; arg3: string;
buffer: pChar;
rvalue: real;
svalue: singleToInt;
begin
alevaluate(pargs,pstateenv,mem,[1,2]);

nr:= fsposint(pargs.arg[1]);

if pargs.narg>=2 then begin
   // narg>=2, set parameter
   // arg3 = type (int, str or single), default: int
   if pargs.narg>2 then
      arg3:= alfstostrlc(pargs.arg[3],eoa)
   else arg3:= 'int';

   if (nr<=0) or (nr>dllBufferSize) then
      xScriptError('<dllbuffer ' + alfstostr(pargs.arg[1],eoa) +
      ','+alfstostr(pargs.arg[2],eoa)+'>: Output parameter nr 1..'+
      inttostr(dllBufferSize) + 'was expected (nothing returned).')
   else begin
      if arg3='int' then begin
         arg2:= fsposint(pargs.arg[2]);
         if arg2<0 then
            xScriptError('<dllbuffer ' + alfstostr(pargs.arg[1],eoa) +
            ','+alfstostr(pargs.arg[2],eoa)+'>: Positive integer was expected as arg 2 '+
            '(no par set).')
         else begin
            // Release old string, if any.
            if dllRefpartype[nr]=refStr then begin
               FreeMem(pointer(dllBuffer[nr]));
               dllRefpartype[nr]:= refInt;
               end;
            dllBuffer[nr]:= arg2
            end;
         end
      else if arg3='str' then begin
         (* 'str' *)
         if dllRefpartype[nr]<>refStr then begin
            // Get new string buffer
            GetMem(Buffer, 2000);
            dllBuffer[nr]:= integer(Buffer);
            dllRefpartype[nr]:= refStr;
            end;
         alfstoCstrConvCrToCrLf(pargs.arg[2],eoa,2000,ioInPtr(dllBuffer[nr]));
         end
      else if arg3='single' then begin
         (* single precision floating point number *)
         alfstoreal(pargs.arg[2],rvalue);
         svalue.s:= rvalue;
         // Release old string, if any.
         if dllRefpartype[nr]=refStr then begin
            FreeMem(pointer(dllBuffer[nr]));
            dllRefpartype[nr]:= refInt;
            end;
         dllBuffer[nr]:= svalue.i;
         dllRefpartype[nr]:= refSingle;
         end
      else
         xScriptError('<dllbuffer ...>: "int", "str" or "single" was expected in arg 3 but "'+arg3+'" was found.')
      end;

   if nr>dllbufLast then dllbufLast:= nr;
   end

else begin

  // narg=1, return parameter
  if (nr<=0) or (nr>dllbufLast) then
  xScriptError('<dllbuffer ' + alfstostr(pargs.arg[1],eoa) +
    '>: Output parameter nr 1..'+inttostr(dllbufLast) +
    'was expected (nothing returned).')

  else case dllRefpartype[nr] of
     refInt: alinttofs(dllBuffer[nr],pfuncret);
     refStr: alstrtofs(pChar(dllBuffer[nr]),pfuncret);
     refSingle: begin
         svalue.i:=dllBuffer[nr];
         rvalue:= svalue.s;
         // 23 bits mantissa: 2^23 = 8388608 = 7 digit. Use 8 to be on the safe side.
         alRealToFs(rvalue,8,pfuncret);
         end;
      end;
  end;

aldispose(pargs,mem);

end; (* aldllBuffer *)

procedure aldllBufferClear;
(* <dllBufferClear>:
   Clear dllBuffer table and reset dllbufLast.
*)
var nr: integer;
begin
for nr:= 1 to dllbufLast do begin
   // Release old string, if any.
   if dllRefpartype[nr]=refStr then begin
      FreeMem(pointer(dllBuffer[nr]));
      dllRefpartype[nr]:= refInt;
      end;
   dllBuffer[nr]:= 0;
   end;
dllbufLast:= 0;
end; (* aldllBufferClear *)



procedure alatcleanup(var pargs: xargblock;
                     pevalkind: xevalkind; (* Tells xevaluate what to do
                                               with the stuff (see
                                               xevaluate). *)
                      var pstateenv: xstateenv;
                      pfuncret: fsptr );
(* <atcleanup str>:
   Define action (str) to be done before cleanup including when form is closed).
   Used by the X application to clean up, when the user closes the X window,
   and when reinitialising the script (<load...>).
*)
(* For test purpose:
   <atcleanup> - Execute the atcleanup code (mainly for test purposes)
*)
var
mem: alevalmem;
fromptr,toptr: fsptr;
cnt, arg1len: integer;

begin
(* Only one arg and it shall not be evaluated. *)
alevaluate(pargs,pstateenv,mem,[]);

with pargs do begin
   if narg>0 then begin

      (* Define atcleanup *)
      if atcleanup<>nil then fsdispose(atcleanup);
      fsnew(atcleanup);
      toptr:= atcleanup;
      fromptr:= arg[1];

      (* Find out length of argument 1. *)
      (* Note - we are using the fact that we know that
         arg[2] points into the compiled call, and that
         in a compiled call, every argument is preceded
         by a byte that defines its length (see xcompilestring
         and xarglen). *)
      // (new:)
      fsback(fromptr);
      arg1len:= integer(fromptr^);
      fsback(fromptr);
      arg1len:= arg1len+integer(fromptr^)*250;
      fromptr:= arg[1];
      (* (old:)
      fsback(fromptr);
      arg1len:= xarglen(fromptr^);
      fsforward(fromptr);
      *)

      (* copy to atcleanup. *)
      for cnt:= 1 to arg1len do begin
         fspshend(toptr,fromptr^);
         fsforward(fromptr);
         end;
      (* End with eoa, and use xevaluate to eoa (eofs would probably work too
         with the new length encoding). *)
      fspshend(toptr,eoa);
      end
   else begin
      (* <atcleanup> - execute it. *)
      if atcleanup<>nil then
         xevaluate(atcleanup,eoa,pevalkind,pstateenv,pfuncret);
      end;
   end; (* with *)

aldispose(pargs,mem);
end; (* alatcleanup *)

var
logtofilename: string = '';

procedure allogto(var pargs: xargblock;
                  var pstateenv: xstateenv;
                  pfuncret: fsptr );
(* <logto[ [,filename][,thread]]>:
   <logto filename> - Send data from output window also to a logfile.
                      Default extension = .log
   <logto filename,thread> - Same as <logto filename>, but writes to
      the log file in a separate thread, to avoid blocking.
   <logto > - Stop sending data from output window to logfile, and
      close log file.
   <logto> - Current name of logfile.
*)
var
mem: alevalmem;
ptr: fsptr;
addextension: string;
res: integer;
usethread: boolean;

begin
(* Only one arg and it shall not be evaluated. *)
alevaluate(pargs,pstateenv,mem,[1]);

res:=0;

with pargs do begin
   if narg>0 then begin

      if narg>1 then
         if arg[2]^=eoa then
            usethread:= false
         else if alfstostrlc(arg[2],eoa)='thread' then
            usethread:= true
         else begin
            xScriptError
              ('X: If present, second argument to function logto shall be empty or "thread".');
            usethread:= false
            end
      else
         usethread:= false;

      if arg[1]^=eoa then begin
         (* Empty filename - stop logging. *)
         logtofilename:= '';
         res:= ioflogto(logtofilename,false);
         end
      else begin

         ptr:= arg[1];
         addextension:= '.log';
         while ptr^<>eoa do begin

            if (ptr^='.') then addextension:= ''
            else if (ptr^='/') or (ptr^='\') then addextension:= '.log';
            fsforward(ptr);
            end;
         logtofilename:= alfstostr(arg[1],eoa) + addextension;
         
         (* Create directory if new directory is in the path. *)
         iocreateDirIfNecessary(logtofilename);

         res:= ioflogto(logtofilename,usethread);
         end;
      end
   else begin
      (* narg=0 - return filename *)
      alstrtofs(logtofilename,pfuncret);
      end;
   end; (* with *)

aldispose(pargs,mem);
end; (*allogto*)


(* Play *)
(********)


var
playFile: file of byte; // (former playFp)
playfilename: string;

playLogFile: file of byte; // (former playLogFpw)

playDiffCount: integer;

playCancel: boolean;// (Used by alPlayStrEqual... to allow user to abort the play)



procedure writeline(var pfile: file; pStr: string);
var
strlen: integer;
buf: array [1..2] of byte;
ior1,ior2,ior: integer;
expectcnt,wrcnt1,wrcnt2,wrcnt: integer;

begin
strlen:= length(pStr);

// Create small string with CRLF
buf[1]:= 13;
buf[2]:= 10;

// Write to file
(*$I-*)
BlockWrite(pFile,pChar(pStr)^,strlen,wrcnt1);
ior1:= ioResult;
BlockWrite(pFile,buf,2,wrcnt2);
ior2:= ioResult;

ior:= ior1;
if ior=0 then ior:= ior2;
expectcnt:= strlen;
if wrcnt1=expectcnt then begin
   expectcnt:= 2;
   wrcnt:= wrcnt2;
   end;

if ior<>0 then begin
   xProgramError('X(writeline): Error during writing to file '+
      '(Error code '+inttostr(ior)+'="'+
      SysErrorMessage(ior)+'").');
   end
else if expectcnt<>wrcnt then
   xProgramError(
      'X(writeline): Expected to write ' + inttostr(expectcnt) +
      ' characters, but ' + inttostr(wrcnt) + ' characters were written.');
(*$I+*)
end; // (writeline)


procedure alReadLine(var pfile: file; pStr: fsptr);
(* Read a line, from a (binary)file . *)
var
endofline:  boolean;
pos,i,rdcnt,cnt: integer;
blockbuf: packed array[1..22] of byte;
ch: char;

begin
endofline:= false;
while not endofline and not eof(pFile) and not xFault do begin
   pos:= filepos(pfile);
   BlockRead(pFile,blockbuf,20,rdcnt);
   i:= 0;
   while (i<rdcnt) and not endofline do begin
      i:= i+1;
      if blockbuf[i]=13 then begin
         endofline:= true;
         // Read LF
         i:= i+1;
         if i<=rdcnt then begin
            ch:= char(blockbuf[i]);
            // Reset file pointer to after CRLF
            seek(pfile,pos+i);
            end
         else begin
            // CR was the 20th char, read one more (LF)
            blockbuf[1]:= 0;
            if eof(pFile) then xprogramerror('alReadLine: Unexpected end of file '+
               'when trying to read LF after CR.')
            else begin
               BlockRead(pfile,blockbuf,1,cnt);
               if cnt=0 then
                  xprogramerror('alReadLine: Unexpected end of file '+
                  'when trying to read LF after CR.');
               end;
            ch:= char(blockbuf[1]);
            end;
         if ch<>char(10) then
            xprogramerror('alReadLine: LF (char 10) ' +
            'was expected after CR but instead char '+inttostr(integer(blockBuf[i]))+
            'was found.');
         end
      else begin
         // Copy the line but not CRLF
         fspshend(pstr,char(blockbuf[i]));
         end;
      end; // (while)

   // i = rdcnt, limited to end of line (CRLF)
   pos:= pos + i;
   end; // (while)

end; (* alReadLine *)



procedure showCompareMessage(pFound: fsptr; pExpected: fsptr; pEnter: boolean);
var answer: word;
begin

playDiffCount:= playDiffCount+1;
if not playCancel then begin
   if pEnter then
      answer:= iofmessagedialog('<Play ...>: Difference found.' +
         'Expected: No output.' + char(13) +
         'Found:' + char(13) + '"' + fsToStr(pFound) + '".',[mbyes,mbno,mbOk,mbCancel])
   else
      answer:= iofmessagedialog('<Play ...>: Difference found.' +
         'Expected:' + char(13) + '"' + fsToStr(pExpected) + '".' + char(13) +
         'Found:' + char(13) + '"' + fsToStr(pFound) + '".',[mbyes,mbno,mbOk,mbCancel]);

   case answer of
      mrYes: ;
      mrNo: ;
      mrOk: ;
      mrCancel: playCancel:= true;
      end;
   end;

end;// (showCompareMessage)


(* alPlayLog
   ---------
   To capture output data during logging. Helps comparing actual output
   with played input file.
   Help function to <play filename>
   Called recursively by ioLog if (alPlayRunning).
   Example (from ioLog):
   if (alPlayRunning)
      alPlayLog(pStr);
*)
var playlogcallcnt: integer;
var skipCompareCnt: integer;

// (new:)
procedure alPlayLog(pStr: string);
var
i,j,startline,strlen,len: integer;
endofline: boolean;
logline,logline0,playline: fsptr;
savepos: integer;

begin

fsnew(logline);
fsnew(playline);

if alPlayRunning and (playlogcallcnt=0) then begin

   i:= 1;
   startline:= i;

   strlen:= length(pstr);

   while (i<=strlen+1) (*and not playCancel*) do begin

      endofline:= false;
      if i>strlen then endofline:= true
      else if pStr[i]=char(13) then endofline:= true;

      if endofline then begin

         // Write to playLogFile
         len:= i-startline;
         writeline(playLogFile,copy(pstr,startline,len));

         // Skip reading from play file lines belonging to an "enter: ..."
         // statement , because they are already read.
         if SkipCompareCnt>0 then skipCompareCnt:= skipCompareCnt-1
         else begin
            // Read line from playfile and compare it with the logged line.
            savepos:= filepos(playFile);
            alReadLine(playFile,playline);

            fsrewrite(logline);
            logline0:= logline;
            for j:= startline to i-1 do fspshend(logline,pStr[j]);

            if not fsequal(logline0,playline,eofs,eofs) then begin
               // See if it was "enter:..."
               if leftstr(fstostr(playline),6)='enter:' then begin
                  showCompareMessage(logline0,playline,true);
                  // Unread the string because is shall be read by alPlay
                  seek(playFile,savepos);
                  end
               else
                  showCompareMessage(logline0,playline,false);
               end;
            end;
         end;

      i:= i+1;
      end; // (while)
   end; // (if)

fsdispose(logline);
fsdispose(playline);

end; // (alPlayLog)




(* Example:
   if alFsLeftEqual(linestr,'enter:') then ...
*)

function alFsLeftEqual(pstr1: fsptr; pstr2: string): boolean;
var
ptr1: fsptr; ptr2: integer;
ch1,ch2: char;
begin
ptr1:= pstr1;
ptr2:= 1;
ch1:= ptr1^; ch2:= pstr2[ptr2];
while ch1=ch2 do begin
   fsforward(ptr1);
   ptr2:= ptr2+1;
   ch1:= ptr1^; ch2:= pstr2[ptr2];
   end;
alFsLeftEqual:= (pstr2[ptr2]=char(0));
end; // (alFsLeftEqual)



(* alPlayGetInput
   --------------
   Help function to <play filename>
   Called recursively through iofEnterString ... (xio) getConsoleData
   to enter console input file data that was logged with "in:..." in the
   played log file. Example (from getConsoleData):
      if (alPlayRunning) {
         // Take data from log file instead
         len = alPlayGetInput(ConsoleInputBufferSize-1,consoleInputBuffer);
         }
      else {
         // Normal input
         len = iofInputBox(ConsoleInputBufferSize-1,consoleInputBuffer);
         }
*)

function alPlayGetInput: string;

var
lineBufPtr: fsptr;
inFound: boolean;

begin

fsnew(lineBufPtr);

// Read line
if not eof(playFile) then begin
  alReadLine(playfile,lineBufPtr);
  // Skip comparing the input line which has already been read.
  skipCompareCnt:= skipCompareCnt+1
  end;

// 1. See if line starts with "in:" or "enter:"
if alfsLeftEqual(lineBufPtr,'in:') then begin
   inFound:= true;
   fsmultiforw(lineBufPtr,3);
   alPlayGetInput:= fsToStr(lineBufPtr);
   end

else alPlayGetInput:= '';

fsdispose(lineBufPtr);

end;// (alPlayGetInput)


procedure alOpenForRead(var pfile: file; pname: string; var pior: integer);
(* Open a file  with FileMode:= fmOpenRead + fmShareDenyNone.
   This allows opening a file that is already locked by another program.
*)
var
ior,ior1,ior2,ior3,saveFileMode: integer;

begin

(*$I-*) (* Turn off IO error exceptions. *)
(* Close file just in case it was open. ioresult must be called
   after every io operation in case there was an error. *)
ior:= 0;
closeFile(pFile);
ior1:= ioresult;

assignFile(pFile,pName);
ior2:= ioresult;

(* Use filemode 0, because filemode 2 (default) causes access denied
   if the file is readonly. *)
saveFileMode:= FileMode;
FileMode:= fmOpenRead + fmShareDenyNone;(* (Allows opening a file that is
     already locked by another program) *)
reset(pfile,1);
ior3:= ioresult;
FileMode:= SaveFileMode;
(*$I+*)

(* Ignore close error but recognize assign and open errors. *)
if ior2<>0 then ior:= ior2
else ior:= ior3;

if ior<>0 then begin
   xScriptError('alOpenForRead: Unable to open file "'
      +pName+'" (Error code '+inttostr(ior)
      +'="'+SysErrorMessage(ior)+'").');
   end;
pior:= ior;

end; // (alOpenForRead)


procedure alOpenForWriteAndRead(var pfile: file; pname: string; var pior: integer);
(* (See ioxreset). *)
var
ior,ior1,ior2,ior3,saveFileMode: integer;

begin

(*$I-*) (* Turn off IO error exceptions. *)
(* Close file just in case it was open. ioresult must be called
   after every io operation in case there was an error. *)
ior:= 0;
closeFile(pFile);
ior1:= ioresult;

assignFile(pFile,pName);
ior2:= ioresult;

(* Use filemode 0, because filemode 2 (default) causes access denied
   if the file is readonly. *)
saveFileMode:= FileMode;
FileMode:= fmOpenReadWrite;(* (Allows opening a file that is
     already locked by another program) *)
rewrite(pfile,1);
ior3:= ioresult;
FileMode:= SaveFileMode;
(*$I+*)

(* Ignore close error but recognize assign and open errors. *)
if ior2<>0 then ior:= ior2
else ior:= ior3;

if ior<>0 then begin
   xScriptError('alOpenForWriteAndRead: Unable to open file "'
      +pName+'" (Error code '+inttostr(ior)
      +'="'+SysErrorMessage(ior)+'").');
   end;
pior:= ior;

end; // (alOpenForWriteAndRead)



(* <play filename>:
   Play a file that was recorded using <logto ...>
   Example: <play logtest1a.log>
   enter: = X command
   in: = console input
   The new input and output are saved in a file called playlog.txt.
*)
procedure alPlay(var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr);
var
mem: alevalmem;
filenameptr,dotPtr: fsPtr;
level: integer;
quote: boolean;
ch: char;
enterFound: boolean;
readBufPtr,readBufPtr0: fsPtr;
ior1,ior2: integer;
enterStringPtr: fsPtr;
enterStr: string;

begin

fsnew(readBufPtr);
readBufPtr0:= readBufPtr;

(* 1. Evaluate filename. *)
alevaluate(pargs,pstateenv,mem,[1]);

playCancel:= false;

// 0. Tell getConsoleData that play is running
playDiffCount:= 0;

// This counter is used to prevent alPlaylog to read lines from playFile
// which have already been read.
SkipCompareCnt:= 0;

// 1. Get fileName
playfilename:= alfstostr(pargs.arg[1],eoa);
filenameptr:= pargs.arg[1];
dotptr:= filenameptr;
fsforwendch(dotptr,eoa);

// Add .log if no extension specified
while (dotPtr<>filenameptr) and (dotPtr^<>'.') and (dotPtr^<>'/') and
   (dotPtr^<>'\') do
   fsback(dotPtr);
if (dotPtr^<>'.') then playfilename:= playfilename + '.log';

// 2. Load the file
alOpenForRead(playFile,playfilename,ior1);

(* 2a. Make sure output is on beginning of a line to avoid an extra line
   in the playlog. (perhaps not necessary in pascal version/BFn 2016-10-27) *)
// iofConsumeLatentEmptyLine();

if ior1=0 then begin
   // 3. Open playLogFile for write and for read
   alOpenForWriteAndRead(playLogFile,'playLogFile.txt',ior2);
   end;

if (ior1=0) and (ior2=0) then begin

   alPlayRunning:= true;
   enterFound:= false;

   // Read file, line by line
   while (not eof(playFile)) (*and not playCancel*) and not xFault do begin

      fsRewrite(readBufPtr);
      alReadLine(playFile,readBufPtr);

      // The lines read from here cannot be read again when comparing in alPlayLog
      skipCompareCnt:= skipCompareCnt+1;

      // 1. See if line starts with "enter:"
      if alfsLeftEqual(readBufPtr0,'enter:') then begin
         // Found - Get string to be entered, continue on next line if in <...> call
         level:= 0;
         quote:= false;
         fsmultiforw(readBufPtr,6);
         enterStringPtr:= readBufPtr;

         while not ((readBufPtr^=eofs) and ((level=0) or eof(playFile))) do begin
            // Keep track of level and quote
            while readBufPtr^<>eofs do begin
               ch:= readBufPtr^;
               if quote then quote:= false
               else begin
                  if ch='''' then quote:= true
                  else begin
                     if ch='<' then level:= level+1
                     else if ch='>' then level:= level-1;
                     end;
                  end;
               fsforward(readBufPtr);
               end; // (while)

            // Send line to x
            // (new:)
            iofEnterLine(fstostr(enterStringPtr));
            // (old:)iofSetInitString(fstostr(enterStringPtr));

            if (level>0) and not eof(playFile) then begin
               enterStringPtr:= readBufPtr;
               alReadLine(playFile,readBufPtr);
               skipCompareCnt:= skipCompareCnt+1;
               end;
            end; // (while)

         end; // (enter:)
      end;// (while not eof...)
   end;// (ior 1&2 = 0)

// Close files
if (ior1=0) then close(playFile);
if (ior2=0) then close(playlogFile);

// Play no longer running
alPlayRunning:= false;

// Return number of differing lines.
fsbitills(playDiffCount,pfuncret);

aldispose(pargs,mem);

fsdispose(readBufPtr);

end; // (alPlay)


(* End Play *)
(************)





procedure allocalio( var pargs: xargblock;
                pevalkind: xevalkind;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <localio script>:
   Save id of input and output file, run script, then restore input and output files.
*)

var
currentinfile,currentoutfile: integer;
currentoutstring: boolean;
failure: boolean;

currentPersIO: boolean;

begin (*allocalio*)

(* Save id of input and output file. *)
currentinfile:= iogetinfilenr;
currentoutfile:= iogetoutfilenr;
currentoutstring:= pstateenv.outstring;

(* Save persistence. *)

(* (new:) *)
currentpersIO:= alLastIOWasPersistent;

(* (old:)
currentpersin:= alLastInWasPersistent;
currentpersout:= alLastOutWasPersistent;
*)

(* In <localio ...> pevalkind xevalcompare probably causes confusion if <in ...>
   is used to change current input. 20120323, exception occurred in
   filtersvs.comparefiles.x, probably caused by this.
   Use then xevalnormal instead. *)
if pevalkind=xevalcompare then pevalkind:= xevalnormal;

(* Run script. *)
xevaluate(pargs.arg[1],eoa,pevalkind,pstateenv,pfuncret);

(* Restore input file. *)
if currentinfile<>iogetinfilenr then
   ioinwithfilenr(currentinfile,pstateenv.cinp);

(* Restore output file. *)
if currentoutfile<>iogetoutfilenr then
   iooutwithfilenr(currentoutfile);

(* Restore outstring setting. *)
pstateenv.outstring:= currentoutstring;

(* Restore persistence. *)

(* (new:) *)
alLastIOWasPersistent:= currentpersIO;

(* (old:)
alLastInWasPersistent:= currentpersin;
alLastOutWasPersistent:= currentpersout;
*)

end; (*allocalio*)


(* <enterfromfile filename>:
   Read file filename and enter each line into the x-window as if the user had
   entered them.
   Example: <enterFromFile testAll.log>
   Where testAll.log is:
   <play test1a>
   <play test1b>
   <plaY test2>
   ...
*)
procedure alEnterFromFile(var pargs: xargblock;
   var pstateenv: xstateenv);
var
mem: alevalmem;
readBufPtr,readBufPtr0: fsPtr;
enterfilename: string;
filenameptr,dotPtr: fsPtr;
ior1: integer;
enterFile: file of byte;

enterStr: string;

begin

fsnew(readBufPtr);
readBufPtr0:= readBufPtr;

(* 1. Evaluate filename. *)
alevaluate(pargs,pstateenv,mem,[1]);

// 2. Get fileName
enterfilename:= alfstostr(pargs.arg[1],eoa);
filenameptr:= pargs.arg[1];
dotptr:= filenameptr;
fsforwendch(dotptr,eoa);

// Add .log if no extension specified
while (dotPtr<>filenameptr) and (dotPtr^<>'.') and (dotPtr^<>'/') and
   (dotPtr^<>'\') do
   fsback(dotPtr);
if (dotPtr^<>'.') then enterfilename:= enterfilename + '.log';

// 2. Load the file
alOpenForRead(enterFile,enterfilename,ior1);

if (ior1=0) then begin

   // Read file, line by line
   while (not eof(enterFile)) and not xFault do begin

      fsRewrite(readBufPtr);
      alReadLine(enterFile,readBufPtr);
      enterStr:= fstostr(readBufPtr);
      iofEnterLine(enterStr);

      end;// (while not eof...)
   end;// (ior 1 = 0)

// Close file
if (ior1=0) then close(enterFile);

aldispose(pargs,mem);

fsdispose(readBufPtr);

end; // (alEnterFromFile)



procedure alforeach( var pargs: xargblock;
                   pevalkind: xevalkind;
                   var pstateenv: xstateenv;
                   pfuncret: fsptr );
(* <foreach name,values,action[,delimiter]>:
   Execute a for loop over all values in variable name,
   separated by delimiter (default "|").
*)
(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate).
*)

var
mem: alevalmem;
a1ptr,a2ptr,a4ptr: fsptr;
nr: integer;
delimiterchar: char;
loopvarptr: fsptr;
lvnestlevel: integer;

begin (*alforeach*)

(* 1. Evaluate value list and delimiter. *)
alevaluate(pargs,pstateenv,mem,[2,4]);

with pargs do begin

   (* 2. Get number of loop variable (copied from alset). *)
   a1ptr:= arg[1];
   nr:= ord(a1ptr^);
   fsforward(a1ptr);
   if (nr=0) and (a1ptr^<>eoa) then begin
      nr:= ord(a1ptr^);
      fsforward(a1ptr);
      nr:= nr*250 + ord(a1ptr^);
      fsforward(a1ptr);
      if nr>xmaxfuncnr then begin
         lvnestlevel:= integer(a1ptr^);
         fsforward(a1ptr);
         end;
      end;

   if nr>xmaxfuncnr then begin
      if lvnestlevel>0 then
         nr:= nr+locVarOffsetStack[lvnestlevel]
      else nr:= nr+locVarOffset;
      end;

   (* 3. Get delimiter char. *)
   if narg>3 then begin
      a4ptr:= arg[4];
      delimiterchar:= a4ptr^;
      fsforward(a4ptr);
      end
   else delimiterchar:= '|'; (* default *)

   (* 4. Check arguments. *)
   if nr=0 then xProgramError('X(alforeach): Program error - nr>0 was expected.')
   else if integer(mactab[nr])<=alIndexMaxNr then xScriptError('X(alforeach): Script error - variable was expected as arg1 but index (...[]) was found.')
   else if a1ptr^<>eoa then
      xProgramError('X(alforeach): Program error - end of argument 1 was expected.')
   else if (narg>3) and (a4ptr^<>eoa) then
      xProgramError('X(<foreach ...>): A single character delimiter was expected, '+
      'but "' + alfstostr(arg[4],eoa) + '" was found.')

   else begin
      if alflagga('D') then iodebugmess('alforeach(nr='+inttostr(nr)+').');

      (* 4. Clear loop variable. *)
      fsrewrite(mactab[nr]);
      loopvarptr:= mactab[nr];
      fspshend(loopvarptr,eoa);
      if nr<=xmaxfuncnr then begin
         recursivemac[nr]:= false;
         parmac[nr]:= False;
         containscleanup[nr]:= false;
         end;

      (* 5. Loop over arg2. *)
      a2ptr:= arg[2];
      while a2ptr^<>eoa do begin
         (* 5a. Copy next value to loop variable. *)
         fsrewrite(mactab[nr]);
         loopvarptr:= mactab[nr];
         while (a2ptr^<>delimiterchar) and (a2ptr^<>eoa) do begin
            fspshend(loopvarptr,a2ptr^);
            fsforward(a2ptr);
            end;
         if a2ptr^=delimiterchar then fsforward(a2ptr);
         fspshend(loopvarptr,eoa);

         (* 5b. Run action part. *)
         xevaluate(arg[3],eoa,pevalkind,pstateenv,pfuncret);
         end;
      end;
    end; (* with *)

aldispose(pargs,mem);

end; (*alforeach*)


procedure alstrlen( var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <strlen str>:
   Return length of str.
*)

var
mem: alevalmem;
ptr: fsptr;

begin (*alstrlen*)

alevaluate(pargs,pstateenv,mem,[1]);

ptr:= pargs.arg[1];
fsforwendch(ptr,eoa);
alstrtofs(inttostr(fsdistance(pargs.arg[1],ptr)),pfuncret);

aldispose(pargs,mem);

end; (*alstrlen*)


procedure alstruppercase( var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <struppercase str>:
   Return str in upper case (capitals).
*)

var
mem: alevalmem;
ptr: fsptr;
s: string;

begin (*alstrUpperCase*)

alevaluate(pargs,pstateenv,mem,[1]);

ptr:= pargs.arg[1];
while ptr^<>eoa do begin
   fspshend(pfuncret,fsUcTab[ptr^]);
   fsforward(ptr);
   end;

aldispose(pargs,mem);

end; (*alstrUpperCase*)


// (old:)
procedure alstruppercase0( var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(*
   <struppercase str>:
   Return str in (Ansi) upper case (capitals).
*)

var
mem: alevalmem;
ptr: fsptr;
s: string;

begin (*alstrUpperCase0*)

alevaluate(pargs,pstateenv,mem,[1]);

alStrToFs(ansiuppercase(alfstostr(pargs.arg[1],eoa)),pfuncret);

aldispose(pargs,mem);

end; (*alstrUpperCase0*)


procedure alstrLowercase( var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <strLowercase str>:
   Return str in Lower case.
*)

var
mem: alevalmem;
ptr: fsptr;
s: string;

begin (*alstrLowerCase*)

alevaluate(pargs,pstateenv,mem,[1]);

ptr:= pargs.arg[1];
while ptr^<>eoa do begin
   fspshend(pfuncret,fsLcWsTab[ptr^]);
   fsforward(ptr);
   end;

aldispose(pargs,mem);

end; (*alstrLowerCase*)

// (old:)
procedure alstrLowercase0( var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(*
<strLowercase str>:
   Return str in (Ansi) Lower case.
*)

var
mem: alevalmem;
ptr: fsptr;
s: string;

begin (*alstrLowerCase0*)

alevaluate(pargs,pstateenv,mem,[1]);

alStrToFs(ansiLowercase(alfstostr(pargs.arg[1],eoa)),pfuncret);

aldispose(pargs,mem);

end; (*alstrLowerCase0*)


procedure alCopyXcode(pfromPtr: fsPtr; var ptoptr: fsptr; pendchar: char);
(* This is only used by alUsage.
   Copy xcode that can contain calls starting with stan (254) and containing
   with its own eoa characters (254).
   |stan|nr|narg|la1(1)|la1(2)|...a1...|eoa|...|lan(1)|lan(2)|...an...|eoa|ra1|ra2|...|nul|
*)
var
fromptr,toptr,callptr: fsptr;
narg,cnt,n,arglen: integer;

// (For command history:)
quote,lastWasEndOfFunctionCall: boolean;
level: integer;
functionCallStr: string;

begin
fromptr:= pfromPtr;
toptr:= ptoptr;

// (For command history:)
quote:= false;
lastWasEndOfFunctionCall:= false;
level:= 0;
functionCallStr:= '';

(* Copy from pfromPtr to pendchar. *)
while (fromptr^<>pendchar) and not xFault do begin
   if fromptr^=char(xstan) then begin
      // Copy function call
      callptr:= fromptr;
      fsforward(callptr); // callptr ^ nr
      if callPtr^=char(0) then begin
         // Read 2 extra characters
         fsforward(callptr);
         fsforward(callptr);// callptr ^ nr2
         end;
      fsforward(callptr);// callptr ^ narg
      narg:= integer(callptr^);
      if narg>0 then begin
         fsforward(callptr);// callptr ^ la1(1) or nul
         for n:= 1 to narg do begin
            // callptr ^ lan(1)
            arglen:= integer(callptr^)*250;
            fsforward(callptr);// callptr ^ lan(2)
            arglen:= arglen + integer(callptr^);
            fsforward(callptr);// callptr ^ an(1)
            fsmultiforw(callptr,arglen); // callptr ^ eoa
            if callptr^<>eoa then xprogramerror('alCopyXcode: Expected eoa (#254) but found #' +
               inttostr(integer(callptr^)) + '.');
            fsforward(callptr);
            end;
         end;
      // callptr ^ ra1 or nul
      cnt:= 0;
      while (callptr^<>char(0)) and (cnt<narg) do begin
         fsforward(callptr);
         cnt:= cnt+1;
         end;
      if callptr^=char(0)then begin
         fsforward(callptr); // callptr ^ 1st char after call
         // copy to toptr
         while (fromptr<>callptr) do begin
            fspshend(toptr,fromptr^);
            fsforward(fromptr);
            end;
         end
      else xprogramerror('alCopyXcode: Expected char 0 (end of call) but found #' +
         char(callptr) + '.');

      // fromPtr ^ 1 st char after call
      end // (fromptr^=stan)
   else begin
      (* Other character than stan. *)

      (* Copy function calls from <usage ...>, ended by >*, to command history. *)
      // Detect '*' as a signal to save the call in the command history.
      if fromPtr^='*' then begin
         if lastWasEndOfFunctionCall then
            // Save function call in the beginning of the command history.
            xiofAddLineToBeginningOfHistory(1,functionCallStr);
         end;

      lastWasEndOfFunctionCall:= false;
      if not quote then begin
         // Detect begin of function call.
         if fromPtr^='<' then begin
            level:= level+1;
            // Reset commandstr
            if level=1 then functionCallStr:= '';
            end;

         // Copy function call to functionCallStr.
         if level>0 then functionCallStr:= functionCallStr+fromPtr^;

         // Detect end of function call
         if fromPtr^='>' then begin
            if level>0 then begin
               level:= level-1;
               if level=0 then lastWasEndOfFunctionCall:= true;
               end;
            end;
         end;
      if quote then quote:= false
      else if fromPtr^='''' then quote:= true;

      // Copy to output
      fspshend(toptr,fromptr^);
      fsforward(fromptr);
      end;
   end; // while (fromptr^<>pendchar)

// fromPtr^ = pendchar (normally eoa)

// Return toPtr so it can be reused to add more (arg[1]..arg[n])
pToPtr:= toPtr;

end;(* alCopyXcode *)


procedure alUsage( var pargs: xargblock; var pstateenv: xstateenv;
   pfuncret: fsptr);
(* <usage str[,name1|name2|...]>:
   Define text to be shown after loading of script, if loadlevel=1.
   Optionally, define a list of function and variable names that are visible
   outside the file (no list = all are visible).
   Note that special characters in str need to be quoted, unless they are
   intended to be evaluated.
   If a function call example is marked with an asterisk ( * ) then it will
   also be inserted in the history list so it can be entered with the up/down
   buttons.

   Example:
   <usage -
   compileSwe.x: Compile trackfile script
   ======================================
   Example usage (from file to screen): '<comp trackfile.txt'>
      or (from file to file): '<comp trackfile.txt',trackfile.trk'>*
      or (from screen to screen): '<compile Si 270/40''', 1000m'>
   Example input file:
      1 100 Si 270/40', 1000m
      2 200 Si 270/40', 1000m 10-superv.
      3 300 Si 270/40', 1000m P-extended 1000m 10-superv.
   For detailed documentation of symbolic format', see:
      N:\STM-N\U - System Verification and Validation\FAT\Test Environment_Requirements\SVS_STM1_Compile_ATC2 Balises_ETCS balises.doc>>
   -,comp compile>
*)

var
mem: alevalmem;
toPtr: fsPtr;
i: integer;

begin (*alUsage*)

// alevaluate(pargs,pstateenv,mem,[1..pargs.narg]);

// Check that this function is called during loading of a script.
if alLoadLevel>=1 then begin

   if alLoadLevel=1 then begin
      if usageMessage<>nil then begin
         xscripterror('alUsage: When preparing to save usage message, '+
            'one was already found. Double call to usage?');
         fsrewrite(usageMessage);
         end
      else fsnew(usageMessage);
      toPtr:= usageMessage;

      // Arg 1: Save usage message for later display, if specified and loadlevel=1
      for i:= 1 to pargs.narg do if pargs.arg[i]^<>eoa then begin
         // Copy arg1 to message (including any xcode). *)
         alCopyXcode(pargs.arg[i],toPtr,eoa);
         end; (* loadlevel=1 *)
      end; (* arg1 contains something. *)
   end // (loadlevel>=1)

else xScriptError('Usage: This function is expected to be used when a script '+
   'is loaded, but it seems not to be, because load level = ' +
   inttostr(alLoadLevel) + '.');

// aldispose(pargs,mem);

end; (*alUsage*)


procedure alInterface( var pargs: xargblock; var pstateenv: xstateenv;
   pfuncret: fsptr);
(* <interface name1 name2 ...>:
   Specifies the names of functions and variables that shall be visible from the
   outside of the X source file. If not used, all names are visible
   (except local variables in functions).

   Example (only <comp ...> and <compile ...> shall be visible outside the x-file:
   <interface comp compile>
*)

var
mem: alevalmem;
ptr,usageNames, usageNames0: fsPtr;
cnt: integer;

begin (*alInterface*)

alevaluate(pargs,pstateenv,mem,[1]);

// Check that this function is called during loading of a script.
if alLoadLevel>=1 then begin

	// Register external interface (allowed usage)
	fsnew(usagenames);
	usageNames0:= usageNames;
	(* Convert white space separated list to a "|" separated list. *)
	ptr:= pargs.arg[1];
	cnt:= 0;
	while fsBinaryWsTab[ptr^]=' ' do fsforward(ptr);
	while ptr^<>eoa do begin
	   cnt:= cnt+1;
	   if cnt>1 then fspshend(usageNames,'|');
	   // Copy name
	   while (ptr^<>eoa) and (fsBinaryWsTab[ptr^]<>' ') do begin
	      fspshend(usageNames,ptr^);
	      fsforward(ptr);
	      end;
	   // Go to next name, if any
	   while fsBinaryWsTab[ptr^]=' ' do fsforward(ptr);
	   end;
	xSetUsage(usageNames0);
	fsdispose(usageNames);
   end

else xScriptError('Interface: This function is expected to be used ' +
   'when a script is loaded, but it seems not to be, because load level = ' +
   inttostr(alLoadLevel) + '.');

aldispose(pargs,mem);

end; (*alInterface*)



procedure alDebugInfo( var pargs: xargblock;
                var pstateenv: xstateenv;
                pfuncret: fsptr );
(* <debuginfo str>:
   - For internal X development use -
   Return value of a variable (only readrescnt, lockcnt and serialbuffer
      are available).
*)

var
mem: alevalmem;
str1: string;
xCurrentStateEnvSave: XstateenvPtr;

begin (*alDebugInfo*)

alevaluate(pargs,pstateenv,mem,[1]);

with pargs do begin

   if narg=0 then begin
      xCurrentStateEnvSave:= xCurrentStateEnv;
      xCurrentStateEnv:= xLastCurrentStateEnv;
      alStrToFs(xDebugInfo,pfuncret);
      xCurrentStateEnv:= xCurrentStateEnvSave;
      end
   else begin
      str1:= alfstostrlc(pargs.arg[1],eoa);
      if str1='readrescnt' then
         alStrToFs(inttostr(ioreadrescnt),pfuncret)
      else if str1='lockcnt' then
         alStrToFs(inttostr(iolockcount),pfuncret)
      else if str1='serialbuffer' then
         alStrToFs(ioSerialBufferInfo(pstateenv.cinp),pfuncret)
         ;
      end;

   end;

aldispose(pargs,mem);

end; (*alDebugInfo*)


procedure alscripterror( var pargs: xargblock;
   var pstateenv: xstateenv);
(* <scripterror str>:
   Print error message str and abort script.
*)

var
mem: alevalmem;

begin (*alScriptError*)

alevaluate(pargs,pstateenv,mem,[1]);

ScriptError:= True;
ScriptErrorMessage:= alfstostr(pargs.arg[1],eoa);

aldispose(pargs,mem);

end; (*alScriptError*)

procedure alCheckScriptError;
(* General subroutine to pick up a script error if there is one stored. *)
begin
if scripterror then begin
   ScriptError:= False;
   xScriptError(scriptErrorMessage);
   end;
end;(* alCheckScriptError *)


procedure alX(var pargs: xargblock; var pstateenv: xstateenv; pfuncret: fsptr);
(* <x name>:
   Return value of an X variable.
   <x scriptdir>: The current default script directory, or the current
      working directory (if no script is loaded or being loaded)
   <x exedir>: The directory of x.exe
   <x startdir>: The the current directory when <load script> was started.
   <x varname,$name>: Return the name of variable $name.
   <x ManuallyResized>: Yes if user has manually changed size of window.
      Used in <usage ...> to keep manually window size if it has been
      manually resized.
*)
var mem: alevalmem; str1,currentdir: string;
funcret0,ptr,a2ptr: fsptr;
found: boolean;
// name: string;
nr: integer;
ch: char;


begin (*alX*)

alevaluate(pargs,pstateenv,mem,[1]);
str1:= alfstostrlc(pargs.arg[1],eoa);

if str1='scriptdir' then begin
   funcret0:= pfuncret;
   found:= false;
   if xdefaultdir<>nil then begin
      if xdefaultdir^<>eofs then begin
         fscopy(xdefaultdir,pfuncret,eofs);
         found:= true;
         end;
      end;
   if pfuncret=funcret0 then if not found then begin
      if xtopdir<>nil then begin
         if xtopdir^<>eofs then begin
            fscopy(xtopdir,pfuncret,eofs);
            found:= true;
            end;
         end;
      end;
   if pfuncret=funcret0 then if not found then begin
      (* No script has yet been loaded. Return working directory (which is
         where a script would be loaded from if path was not specified). *)
      getdir(0,currentdir);
      alstrtofs(currentdir,pfuncret);
      end;
   end

else if str1='exedir' then begin
   funcret0:= pfuncret;
   alstrtofs(paramstr(0),pfuncret);
   // Remove x.exe
   ptr:= pfuncret;
   fsforwend(ptr);
   while not (ptr^='\') and not (ptr=funcret0) do fsback(ptr);
   if (ptr^<>'\') then xProgramError('<x exedir>: Expected to find "\" but could not.');
   fsdelrest(ptr);
   // (old:) alstrtofs(xexestring,pfuncret);
   end
else if str1='startdir' then begin
   alstrtofs(topLoadCurrentDirectory,pfuncret);
   end

else if str1='varname' then with pargs do begin
   if narg<>2 then
      xscripterror('<x varname,...>: 2 arguments were expected, but ' +
         inttostr(narg) + ' were found.')
   else begin
      (* narg=2 *)
      a2ptr:= arg[2];
      (* (Modelled from xevaluate and xdecodecall). *)
      if a2ptr^<>char(xstan) then
         xscripterror('<x varname,...>: variable referens $name was expected, '+
            'but character "' + a2ptr^ + '" was found.')
      else begin
         (* a2ptr^=stan *)
         (* Calculate number of variable. *)
         fsforward(a2ptr);
         nr:= ord(a2ptr^);
         fsforward(a2ptr);
         if nr=0 then begin
            (* Long number. *)
            nr:= xint16(a2ptr^);
            fsforward(a2ptr);
            nr:= nr*250 + xint16(a2ptr^);
            end;
         if nr>xmaxfuncnr then
            xScriptError('X(<x varname,...>): Expected normal variable but found local variable.')
         else begin
              (* nr<=xmaxfuncnr *)
            if nr=0 then xProgramError('X(<x varname,...>): Program error - nr>0 was expected.')
            else
               (* Return name. *)
               alStrToFs(xname(nr),pfuncret);
            end;(* x<=xmaxfuncnr *)
         end; (* a2ptr^=stan *)
      end;(* narg=2 *)
   end (* varname *)
else if str1='manuallyresized' then begin
   if iofManuallyResized then alstrtofs('yes',pfuncret)
   else alstrtofs('no',pfuncret);
   end
else xScriptError('<x ...>: System variable "scriptdir", "exedir" or "manuallyresized" was ' +
   'expected but "'+str1+'" was found.');

aldispose(pargs,mem);

end; (*alX*)


(* Used to prevent evaluation if alShowCall is called recursively
   showcallcnt>1 indicates that a new error was found while creating
   the error message for the first error. In that case, avoid decompilation
   (or evaluation), since is the probable cause of the new error and
   it could cause an infinite loop. *)
var showcallcnt: integer =0;

function alShowCallSet(pnr: alint16; var pargs: xargblock): string;
(* Show decoded call for <set ...>, <append ...> or <update ...>. Used by alShowCall.
*)
var
s: string;
i: alint16;
nr: alint16;
a1ptr: fsptr;
lvnestlevel: integer;

begin (*alShowCallSet*)

s:= '<'+xname(pnr)+' ';

with pargs do begin

   a1ptr:= arg[1];
   nr:= ord(a1ptr^);
   lvnestlevel:= 0;
   fsforward(a1ptr);
   if (nr=0) and (a1ptr^<>eoa) then begin
      nr:= ord(a1ptr^);
      fsforward(a1ptr);
      nr:= nr*250 + ord(a1ptr^);
      fsforward(a1ptr);
      if nr>xmaxfuncnr then begin
         lvnestlevel:= integer(a1ptr^);
         fsforward(a1ptr);
         end;
      end;

   if nr=0 then s:= s+'(?),'
   else if a1ptr^<>eoa then s:= s+'(??),'
   else begin

      // Local variable? Then add offset for outer level local variables.
      if nr>xmaxfuncnr then begin
         if lvnestlevel>0 then
            nr:= nr+locVarOffsetStack[lvnestlevel]
         else nr:= nr+locVarOffset;
         s:= s+'(locvar '+inttostr(nr)+')';
         end
      else if integer(mactab[nr])<=alIndexMaxNr then begin
         // Table
         if narg=2 then begin
            s:=s+'$'+xname(nr)+',';
            end
         else begin
            s:=s+'$'+xname(nr)+'[';
            if rekursiv[2] then s:= s+'...],'
            else s:= s+ alFsToStr(arg[2],eoa)+'],';
            end;
         end
      else
         // Normal variable
         s:=s+'$'+xname(nr);

      // Add arguments...
      for i:=2 to narg do begin
         s:= s+',';
         if rekursiv[i] then s:= s+'...'
         else s:= s+alFsToStr(arg[i],eoa);
         end;
      s:= s+'>';
      end;
   end; (* with *)

alShowCallSet:= s;

end; (*alShowCallset*)


function alShowCallCJ(pnr: integer; var pargs: xargblock): string;
(* Show decoded call for <c ...> and <j ...>. Used by alShowCall.
*)
var
s: string;
i: alint16;
nr: alint16;
arg1ptr: fsptr;
statenr: integer;
statename: string;

begin (*alShowCallCJ*)

s:= '<'+xname(pnr);

arg1ptr:= pargs.arg[1];
statenr:= 0;

(* 1. Get state name and state number. *)
if arg1ptr^='@' then begin
   fsforward(arg1ptr);
   statenr:= 250*integer(arg1ptr^);
   fsforward(arg1ptr);
   statenr:= statenr +integer(arg1ptr^);
   statename:= xgroupname(statenr);
   end
else statename:= alfstostr100(pargs.arg[1],eoa);

s:= s+' '+statename;

with pargs do if narg>1 then begin

   for i:=2 TO narg do begin
      s:= s+',';
      if rekursiv[i] then s:= s+'...'
      else s:= s+alFsToStr(arg[i],eoa);
      end;
   end;

s:= s+'>';

alShowCallCJ:= s;


end; (*alShowCallCJ*)

// (new:)
function alShowCallCaseIfeq(pnr: integer; var pargs: xargblock): string;
(* Show decoded call for <case ...> and <ifeq ...>. Used by alShowCall.
*)
var
s,args: string;
i: alint16;
nr: alint16;
tempfs: fsptr;

begin (*alShowCallCaseIfeq*)

fsnew(tempfs);

s:= '<'+xname(pnr);

with pargs do begin

   for i:=1 TO narg do begin
      if i=1 then s:= s+' '
      else s:= s+',';

      if rekursiv[i] then begin
         // Decompile even arguments (patterns)
         if (i mod 2 = 0) and (showcallcnt<2) and
            // Skip the 'else' part of ifeq i=4)
            not ((pnr=alIfeqFuncnr) and (i=4)) then begin
            debugdecompile(arg[i],false,false,tempfs);
            s:= s+alfstostr100(tempfs,eofs);
            fsrewrite(tempfs);
            end
         else begin
            debugdecompile(arg[i],false,false,tempfs);
            args:= alfstostr100(tempfs,eofs);
            fsrewrite(tempfs);
            s:= s+args;
            // s:= s+'...'
            end;
         end
      else
         s:= s+alFsToStr(arg[i],eoa);
      end;
   end;

s:= s+'>';

alShowCallCaseIfeq:= s;

fsdispose(tempfs);

end; (*alShowCallCaseIfeq*)


// (old:)
function alShowCallCaseIfeq0(pnr: integer; var pargs: xargblock): string;
(* Show decoded call for <case ...> and <ifeq ...>. Used by alShowCall.
*)
var
s: string;
i: alint16;
nr: alint16;
tempfs: fsptr;

begin (*alShowCallCaseIfeq0*)

fsnew(tempfs);

s:= '<'+xname(pnr);

with pargs do begin

   for i:=1 TO narg do begin
      if i=1 then s:= s+' ' else s:= s+',';
      if rekursiv[i] then begin
         // Decompile even arguments (patterns)
         s:= s+'+++';
         if (i mod 2 = 0) and (showcallcnt<2) and
            // Skip the 'else' part of ifeq i=4)
            not ((pnr=alIfeqFuncnr) and (i=4)) then begin
            debugdecompile(arg[i],false,false,tempfs);
            s:= s+alfstostr100(tempfs,eofs);
            fsrewrite(tempfs);
            end
         else s:= s+'...'
         end
      else s:= s+alFsToStr(arg[i],eoa);
      end;
   end;

s:= s+'>';

alShowCallCaseIfeq0:= s;

fsdispose(tempfs);

end; (*alShowCallCaseIfeq0*)


function alShowCallDef(pnr: integer; var pargs: xargblock): string;
(* Show decoded call for <function ...> or <def ...>. Used by alShowCall.
*)
var
s: string;
i: alint16;
nr: alint16;
tempfs: fsptr;

begin (*alShowCallDef*)

fsnew(tempfs);

s:= '<'+xname(pnr);

with pargs do begin

   for i:=1 TO narg do begin
      if i=1 then s:= s+' ' else s:= s+',';
      if rekursiv[i] then begin
         // Decompile all arguments
         debugdecompile(arg[i],false,false,tempfs);
         s:= s+alfstostrLim(tempfs,eofs,10);
         fsrewrite(tempfs);
         end
      else s:= s+alFsToStr(arg[i],eoa);
      end;
   end;

s:= s+'>';

alShowCallDef:= s;

fsdispose(tempfs);

end; (*alShowCallDef*)



function alShowCall(pnr: integer; var pargs: xargblock): string;
(* Show decoded call. Used in error messages.
   Freely copied from alVisaAnrop)
   Usage example: alShowCall(xCurrentStateEnv^.funcnr,pargs);
*)
var
s1,s2: string;
i: alint16;
tempfs: fsptr;

begin

showCallCnt:=showCallCnt+1;

// Make sure that showCallCnt is updated even if there is an exception:
try
   if (pNr=alsetfuncnr) or (pNr=alAppendFuncNr) or (pNr=alUpdateFuncNr) or
      (pNr=alIndexesFuncnr) or (pNr=alIndexesFuncNr) then
      s1:= alshowcallSet(pNr,pargs)

   else if (pNr=alCfuncnr) or (pNr=aljfuncnr) or (pNr=alC_lateEvaluationFuncnr) then
      s1:= alshowcallCJ(pNr,pargs)

   else if (pNr=alCaseFuncnr) or (pNr=alIfeqFuncnr) then
      s1:= alshowcallCaseIfeq(pNr,pargs)

   else if (pNr=alDefFuncnr) or (pNr=alFunctionFuncnr) then
      s1:= alshowcallDef(pNr,pargs)

   else begin
      s1:= '<'+xname(pNr);

      with pargs do if narg>0 then begin
         fsnew(tempfs);
         for i:=1 TO narg do begin
            // Skip arg2 in <xp n> because it is an offset for internal use in X.
            if (pnr=alXpFuncnr) and (i=2) then (* - *)
            else begin
               if i=1 then s1:= s1+' '
               else s1:= s1+',';
               if rekursiv[i] then begin
                  // (new:)
                  debugdecompile(arg[i],false,false,tempfs);
                  s1:= s1+alfstostrLim(tempfs,eofs,20);
                  fsrewrite(tempfs);
                  // (old:) s1:= s1+'...'
                  end
               else
                  s1:= s1+alFsToStr100(arg[i],eoa);
               end;
            end;
         fsdispose(tempfs);
         end;
      s1:= s1+'>';
      end;

   finally
      showCallCnt:=showCallCnt-1;

      (* Replace nul characters with '(nul)' because they will otherwize terminate
         the string. *)
      s2:= '';
      for i:= 1 to length(s1) do begin
         if s1[i]=char(0) then s2:= s2+'(nul)' else s2:= s2+s1[i];
         end;

      alShowCall:= s2;
   end;

end; (* alShowCall *)


// (old:)
function alShowCall0(pnr: integer; var pargs: xargblock): string;
(* Show decoded call. Used in error messages.
   Freely copied from alVisaAnrop)
   Usage example: alShowCall(xCurrentStateEnv^.funcnr,pargs);
*)
var
s1,s2: string;
i: alint16;
nr: alint16;
begin
nr:= xCurrentStateEnv^.funcnr;

showCallCnt:=showCallCnt+1;

// Make sure that showCallCnt is updated even if there is an exception:
try
   if (nr=alsetfuncnr) or (nr=alAppendFuncNr) or (nr=alUpdateFuncNr) or
      (nr=alIndexesFuncnr) or (nr=alIndexesFuncNr) then
      s1:= alshowcallSet(nr,pargs)

   else if (nr=alCfuncnr) or (nr=aljfuncnr) or (nr=alC_lateEvaluationFuncnr) then
      s1:= alshowcallCJ(nr,pargs)

   else if nr=alCaseFuncnr then
      s1:= alshowcallCaseIfeq(nr,pargs)

   else if (nr=alDefFuncnr) or (nr=alFunctionFuncnr) then
      s1:= alshowcallDef(nr,pargs)

   else begin
      s1:= '<'+xname(nr);

      with pargs do if narg>0 then begin
         for i:=1 TO narg do begin
            if i=1 then s1:= s1+' '
            else s1:= s1+',';
            if rekursiv[i] then s1:= s1+'...'
            else s1:= s1+alFsToStr100(arg[i],eoa);
            end;
         end;
      s1:= s1+'>';
      end;

   finally
      showCallCnt:=showCallCnt-1;

      (* Replace nul characters with '(nul)' because they will otherwize terminate
         the string. *)
      s2:= '';
      for i:= 1 to length(s1) do begin
         if s1[i]=char(0) then s2:= s2+'(nul)' else s2:= s2+s1[i];
         end;

      alShowCall0:= s2;
   end;

end; (* alShowCall0 *)


function alShowArg(parg: fsptr; pRecursive: boolean): string;
(* Show an argument, decompile if recursive. Used for error
   messages.
   Example (from alDef):
   parmin:= fsposint(arg[3]);
   if parmin<0 then
      xScriptError('X: Number expected as arg 3, found "'+
      alShowArg(arg[3],rekursiv[3])+'".');
*)
var
s: string;
tempfs: fsptr;

begin
if pRecursive then begin

  fsnew(tempfs);
  // Decompile arg first
  debugdecompile(parg,false,false,tempfs);
  s:= alfstostrLim(tempfs,eofs,20);
  fsdispose(tempfs);
  end
else s:= alFsToStrLim(parg,eoa,30);

alShowArg:= s;

end;

var
firstcompare,lastcompare: integer; (* Funcnr for first and last function used
                                      in xcompare (comparing input to something)
                                      Used to check that pevalkind=xevalcompare
                                      when it is called. *)

procedure alRegisterFunctions;
(* Register predefined functions. *)
var name: xstring32;
savecurrentgroup: integer;

begin

(* Shall be done before xdefine of predefined functions: *)
savecurrentgroup:= xcurrentgroupnr;
xcurrentgroupnr:= 0; // 0 for predefined functions

(* 1 shall be reserved for calls to undefined functions. *)
xdefinepdf('setflag',2,1,1);
xdefinepdf('resetflag',3,1,1);
xdefinepdf('flag',4,1,1);
xdefinepdf('ifflag',5,2,3);
xdefineArgNames(5,'then else');
xdefinepdf('ifeq',6,3,4);
xdefineArgNames(6,'as then else');
xdefinepdf('case',7,3,xmaxnarg,xOddNarg);
xdefinepdf('char',8,1,1);
xdefinepdf('def',9,2,4);
xdefinepdf('date',10,0,0);
xdefinepdf('time',11,0,0);
xdefinepdf('in',12,0,4);
xdefinepdf('out',13,0,4);
xdefinepdf('unread',14,0,1);
xdefinepdf('read',15,1,1);
xdefinepdf('info',16,1,1);
xdefinepdf('progtest',17,1,1);
xdefinepdf('settings',18,0,2);
xdefinepdf('exec',19,1,1);
xdefinepdf('p',20,1,2);
xdefinepdf('j',21,1,xmaxnarg);
xdefinepdf('c',22,1,xmaxnarg);
xdefinepdf('r',23,0,1);
xdefinepdf('pfail',24,2,2);
xdefinepdf('wcons',25,1,xmaxnarg);
xdefinepdf('calc',26,1,2);
xdefinepdf('set',27,2,3);
xdefinepdf('inpos',28,0,0);
xdefinepdf('rename',29,2,2);
xdefinepdf('close',30,1,2);
xdefinepdf('delete',31,1,1);
xdefinepdf('write',32,1,1);
xdefinepdf('ifgt',33,3,4);
xdefineArgNames(33,'than then else');
cleanupfuncnr:= 34;
xdefinepdf('cleanup',cleanupfuncnr,0,0);
loadfuncnr:= 35;
xdefinepdf('load',loadfuncnr,0,xmaxnarg);
xdefinepdf('thread',36,0,1);
xdefinepdf('pop',37,2,2);
xdefinepdf('cd',38,0,1);
prelDefFuncNr:= 39;
xdefinepdf('preldef',prelDefFuncNr,1,4);
xdefinepdf('dos',40,1,1);
xdefinepdf('selectinput',41,2,10,xEvenNArg);
xdefinepdf('makebits',42,2,2);
(* 43: unused. *)
xdefinepdf('makebitscount',44,0,1);
xdefinepdf('htod',45,1,1);
xdefinepdf('dtoh',46,1,1);
xdefinepdf('sleep',47,1,1);
xdefinepdf('linenr',48,0,1);
xdefinepdf('connected',49,1,1);
xdefinepdf('terminate',50,0,0);
xdefinepdf('win32',51,1,8);
xdefinepdf('htos',52,1,1);
xdefinepdf('stoh',53,1,1);
xdefinepdf('var',54,1,4);
xdefinepdf('sqrt',55,1,2);
xdefinepdf('c_lateevaluation',56,1,xmaxnarg);
xdefinepdf('btoh',57,1,1);
xdefinepdf('while',58,2,4);
xdefinepdf('if',59,2,xmaxnarg);
xdefineArgNames(59,'then elseif/odd then/even else/last');
xdefinepdf('shiftbits',60,0,0);
xdefinepdf('loadfile',61,1,xmaxnarg);
xdefinepdf('htob',62,1,2);
xdefinepdf('select',63,1,10,xEvenNArg);
xdefinepdf('sp',64,1,1);
xdefinepdf('abs',65,1,2);
xdefinepdf('outpos',66,0,0);
xdefinepdf('enterfromfile',67,1,1);
(* xdefinepdf('ssp',67,1,1);  <ssp n> removed. <sp n> is, for time being, used
   for both <c ...> and <j ...>, regardless of if the goal is a state or a
   substate. <c ...> parameters are available also after a jump, but not if
   new parameters were used in the <j ...> call. New parameters in <j ...>
   overwrite parameters received from earlier <c ...> call, but if <j ...>
   is done without parameters, then the <c ...> parameters can still be accessed
   through <sp n>. This has worked for a long time, and there has not yet been
   any need to change it. *)

xdefinepdf('unless',68,2,2);
(* (old:) xdefinepdf('dlloutpar',68,1,3);*)

xdefinepdf('do',69,1,1);
(* (old:) xdefinepdf('dlloutparclear',69,0,0);*)

xdefinepdf('clear',70,0,0); (* <clear> *)
xdefinepdf('formmove',71,0,4);(* <formMove ...> *)
xdefinepdf('max',72,2,3);

(* 73: Vacant. *)

firstcompare:= 75;

(* To be removed when no longer in use (replaced with new names): *)
xdefinepdf('to_wholeword',75,1,xmaxnarg); (* <to_wholeword ...> *)
xdefinepdf('to_WithinLine',76,0,xmaxnarg); (* <to_withinline ...> *)
xdefinepdf('filename',77,0,0);

xdefinepdf('opt',78,1,xmaxnarg);
xdefinepdf('word',79,0,0);
(* Obsolete? Renamed to towl (96). *)
xdefinepdf('towithinline',80,0,xmaxnarg);
xdefinepdf('anything',81,0,0);
xdefinepdf('to',82,1,xmaxnarg);
xdefinepdf('format',83,1,1);
xdefinepdf('integer',84,0,2);
xdefinepdf('afilename',85,0,0);
xdefinepdf('decimal',86,0,2);
xdefinepdf('alt',87,1,xmaxnarg);
xdefinepdf('id',88,0,0);
xdefinepdf('lwsp',89,0,0);
xdefinepdf('followedby',90,1,xmaxnarg);
xdefinepdf('notfollowedby',91,1,xmaxnarg);
xdefinepdf('towholeword',92,1,xmaxnarg);
xdefinepdf('bits',93,1,2);
xdefinepdf('eof',94,0,0);
xdefinepdf('eofr',95,0,0);
xdefinepdf('towl',96,0,xmaxnarg);
xdefinepdf('bitsdec',97,1,2);
lastcompare:= 97;

xdefinepdf('excel',98,1,4);
xdefinepdf('replacewith',99,1,1);
xdefinepdf('loadlevel',100,0,0);
xdefinepdf('loadfrom',101,2,xmaxnarg);
xdefinepdf('messagebox',102,1,1);
xdefinepdf('messagedialog',103,1,2);
xdefinepdf('sql',104,1,4);
xdefinepdf('debug',105,0,0);
xdefinepdf('fileisopen',106,1,1);
xdefinepdf('functions',107,0,1);
xdefinepdf('bitscount',108,0,0);
xdefinepdf('dllcall',109,3,xmaxnarg);
xdefinepdf('command',110,1,3);
xdefinepdf('windowFormat',111,0,4);
xdefineArgNames(111,'x y xsize ysize');
xdefinepdf('atcleanup',112,0,1);
xdefinepdf('logto',113,0,2);
xdefinepdf('function',114,2,4); // synonym to <def ...>
xdefinepdf('startProgram',115,2,3);
xdefinepdf('xp',116,2,2);// arg2 is invisible and added by X.
xpFuncnr:= 116;
xdefinepdf('localio',117,1,1);
xdefinepdf('fileexists',118,1,1);
xdefinepdf('is',119,1,xmaxnarg);
xdefinepdf('eq',120,2,2);
xdefinepdf('eoln',121,0,0);
xdefinepdf('dllbufferclear',122,0,0);
xdefinepdf('xdefaultdir',123,0,0);
xdefinepdf('empty',124,1,xmaxnarg);
xdefinepdf('foreach',125,3,4);
xdefineArgNames(125,'value in do');
xdefinepdf('directoryexists',126,1,1);
xdefinepdf('formcaption',127,0,1);
xdefinepdf('strlen',128,1,1);
xdefinepdf('inputbox',129,2,3);
xdefinepdf('nameas',130,1,1);
xdefinepdf('scripterror',131,1,1);
xdefinepdf('windowclear',132,0,0);
(* 133: vacant *)
xdefinepdf('makebitsclear',134,0,0);
xdefinepdf('bitsclear',135,0,0);
xdefinepdf('append',136,2,4);
xdefinepdf('update',137,2,5);
xdefinepdf('struppercase',138,1,1);
xdefinepdf('strlowercase',139,1,1);
xdefinepdf('dllbuffer',140,1,3);
xdefinepdf('openfiles',141,0,0);
xdefinepdf('debuginfo',142,0,1);
xdefinepdf('makebitsdec',143,2,2);
xdefinepdf('sort',144,1,2);
(* 145: Vacant. *)
xdefinepdf('msword',146,1,4);
xdefinepdf('x',147,1,2);
xdefinepdf('persistentio',148,0,0);
(* tempfilename is in process of being replaced by uniqueFileName (150). *)
xdefinepdf('tempfilename',149,0,0);
xdefinepdf('uniquefilename',150,0,0);
xdefinepdf('ifelseif',151,4,xmaxnarg);
xdefineArgNames(151,'then elseif/odd then/even else/last');
xdefinepdf('play',152,1,1);
xdefinepdf('indexes',153,1,2);
xdefinepdf('paramstr',154,1,1);
xdefinepdf('help',155,0,2);
(* 156: Vacant. *)
(* (old:) xdefinepdf('intro',156,1,xmaxnarg);*)
xdefinepdf('ifis',157,2,3);
xdefineArgNames(157,'then else');
xdefinepdf('usage',158,1,1);
xdefinepdf('interface',159,1,1);

xdefinepdf('run',160,2,2); // (old)

xdefinepdf('examples',161,1,1);

xdefinepdf('range',162,2,3);
xdefinepdf('pack',163,3,xmaxnarg);
xdefinepdf('unpack',164,3,xmaxnarg);

xdefinepdf('ifempty',165,2,3);
xdefineArgNames(165,'then else');

xcurrentgroupnr:= savecurrentgroup;

(* Get the numbers for various functions. *)
alpfuncnr:= xgetvisiblenr('p');
alpdecfuncnr:= xgetvisiblenr('pdec0');
alSetFuncNr:= xgetvisiblenr('set');
alAppendFuncNr:= xgetvisiblenr('append');
alPackFuncNr:= xgetvisiblenr('pack');
alPopFuncnr:= xgetvisiblenr('pop');
alForeachFuncnr:= xgetvisiblenr('foreach');
alVarFuncnr:= xgetvisiblenr('var');
alFunctionFuncNr:= xgetvisiblenr('function');
alDefFuncNr:= xgetvisiblenr('def');
alPreldefFuncNr:= xgetvisiblenr('preldef');
alIfeqFuncNr:= xgetvisiblenr('ifeq');
alCaseFuncNr:= xgetvisiblenr('case');
alXpFuncNr:= xgetvisiblenr('xp');
alInFuncNr:= xgetvisiblenr('in');
alOutFuncNr:= xgetvisiblenr('out');
alCFuncNr:= xgetvisiblenr('c');
alJFuncNr:= xgetvisiblenr('j');
alC_lateEvaluationFuncNr:= xgetvisiblenr('c_lateevaluation');
alUpdateFuncNr:= xgetvisiblenr('update');
alIndexesFuncNr:= xgetvisiblenr('indexes');
alBitsFuncNr:= xgetvisiblenr('bits');
alRangeFuncNr:= xgetvisiblenr('range');
alDoFuncNr:= xgetvisiblenr('do');

end;

procedure alinit;

var ch: CHAR; nr: alint16;

begin (*alinit*)

// Init to default settings.
initsettings;

for ch:= 'A' TO 'Z' do flagTab[ch]:= FALSE;

eoa:= char(xeoa);
eofs:= char(fseofs);
eofr:= char(ioeofr);
ctrlM:= char(13);

if initialized then begin
  (* Leave macros but make it possible to define them again without warning
     messages. *)
  for nr:= 0 TO xmaxfuncnr do
    if (mactab[nr]<>NIL) then preldef[nr]:= true;
  end

else for nr:= 0 TO xmaxfuncnr do begin
    mactab[nr]:= NIL;
    recursivemac[nr]:= FALSE;
    parmac[nr]:= False;
    preldef[nr]:= FALSE;
    containscleanup[nr]:= false;
    end;

(* For <bits ...> *)
bitsmode:= False;
shiftbits:= 0;
makebitscount:= 0;

(* For <in ...> *)
if pushfs=nil then pushfs:= ionewfs('push');
if popfs=nil then popfs:= ionewfs('pop');

(* For <makebits ...> *)
savechar:= '0';
nsavedbits:= 0;

(* For <thread ...> *)
if not initialized then begin
  for nr:= 1 to almaxnthreads do thread[nr].state:= free;
  lastthread:= 0;
  althreadnr:= 0;
  end;

(* Start with an empty name table. *)
xcleartab;

(* Register predefined functions. *)
alRegisterFunctions;

fsnew(runningtitle);
fsnew(usageMessage);

(* Create table of word characters. (Assumed to be all false
   to start with.) *)
for nr:= 48 to 57 do wordtab[nr]:= true; // '0'..'9'
wordtab[95]:= true; // '_'
for nr:= 65 to 90 do wordtab[nr]:= true; // 'A'..'Z'
for nr:= 97 to 122 do wordtab[nr]:= true; // 'a'..'z'
for nr:= 192 to 253 do wordtab[nr]:= true; // 'À'..'ý'
wordtab[215]:= false; // '×'
wordtab[247]:= false; // '÷'

// Save id of main thread
mainThreadId:= getCurrentThreadId; // FPC+
initialized:= True;

end; (*alinit*)


procedure alvisaanrop( pnr: alint16; var pargs: xargblock; var pname: string);
(* debug *)
var i: alint16; p: fsptr; n,c: alint16;
debugstr: shortstring;
begin
with pargs do begin
   pname:= xname(pnr);
  debugstr:='-> <'+ pname;
  for i:=1 TO narg do begin
    if i=1 then debugstr:= debugstr+' '
    else debugstr:= debugstr+',';
    p:= arg[i];
    // (new:)
    fsback(p);
    n:= integer(p^);
    fsback(p);
    n:= n+integer(p^)*250;
    p:= arg[i];
    // (old:)fsback(p); n:= xarglen(p^); fsforward(p);
    for c:= 1 TO n do begin
        if p^=char(13) then
           debugstr:= debugstr+char(13) (*(used to be writeln)*)
        else begin
            if (ORD(p^)<ORD(' ')) or (ORD(p^)>=253) then
                debugstr:= debugstr+'('+inttostr(ORD(p^))+')'
            else debugstr:= debugstr+p^;
            end;
        fsforward(p);
        end;
    end;
  debugstr:= debugstr+'>';
  iodebugmess(debugstr);end;
end;


function alargs2str( var pargs:xargblock; ptoarg: integer; var pstateenv: xstateenv): string;
(* Example: <calc 123+456,2> => "123+456,2".
   Limit evaluation till ptoarg *)
var a,toarg: integer;
mem: alevalmem;
s: string;

begin

(* Limit evaluation to arg 1..ptoarg of ptoarg != 0. *)
toarg:= pargs.narg;
if (ptoarg>0) and (ptoarg<toarg) then toarg:= ptoarg;

alevaluate(pargs,pstateenv,mem,[1..toarg]);
s:= '';

(* Handle multiple arguments as comma's in a text. *)
with pargs do for a:= 1 to toarg do begin
   s:= s + alfstostr(pargs.arg[a],eoa);
   if a<toarg then s:= s + ',';
   end;

(* Print non-evaluated arguments as ",...". *)
if toarg<pargs.narg then s:= s + ',...';

aldispose(pargs,mem);

alargs2str:= s;

end; (*alargs2str*)

(* Debug system for restoring call trace after exception in X. *)
(* ----------------------------------------------------------- *)
(* Debug system for logging to a file so that a call trace can be
   available in the event of an exception. I january 2013, when
   resuming automated tests for STM Finland, exception was raised
   a short time (a few chapters) after start of tests. For unknown
   reason, the exception was not caught by the try ... except framework
   in alcall that is intended for this purpose. Therefor this code
   is added, so that trace loggings can continously be filed during
   running, to be available for analysis afterwards. *)

(* Usage example:
   if alflagga('E') then begin
      CallTraceLevel:= callTraceLevel+1;
      callTraceTab[callTraceLevel].nr:= pnr;
      callTraceLog('>' + inttostr(pnr));
      end;
*)
type
callTraceRecordType = record
   nr: integer;
   end;

var
callTraceLevel: integer = 0;
callTraceTab: array[1..500] of callTraceRecordType;
callTraceStarted: boolean= false;
callConnected: boolean=false;
callTraceFile: TextFile;
callTraceCount: integer = 0;
callTraceIndent: string =
'----------------------------------------------------------------------------------------------------';

callSocket: tsocket;
callhostentp: Phostent; (* A pointer to a record that has a field
                    (h_addr_list) that points at a pointer to
                    the ip-nr. *)
callsockaddr: TSockAddrIn; (* A record containing the ip-nr (.sin_addr)
                          and the portnr (.sin_port). *)
sbuf: ioinptr;

const callLogPort = 3400;


procedure callTraceLog(pstr: string);
var
len: integer;
fromPtr,toPtr: ioinptr;
begin

if callConnected then begin
   try
   callTraceCount:= callTraceCount+1;
   len:= length(pstr);
   fromPtr:= ioinptr(pstr);
   toptr:= sbuf;
   while (fromPtr^<>char(0)) do begin
      toPtr^:= fromPtr^;
      fromPtr:= ioinptr(integer(fromptr)+1);
      toPtr:= ioinptr(integer(toptr)+1);
      end;
   toPtr^:= char(13);
   toPtr:= ioinptr(integer(toptr)+1);
   toPtr^:= char(10);
   toPtr:= ioinptr(integer(toptr)+1);
   toPtr^:= char(0);
   except
   xScriptError('++ calltracelog: Try failed.');
   end;

   if send(callSocket,sBuf^,len+2,0) = socket_error then begin
      xScriptError('++ calltracelog: Send failed.');
      closesocket(callSocket);
      callconnected:= false;
      FreeMem(sbuf);
      end;
   end;
end; // (callTraceLog)


procedure alOpenCallTraceLog;
var
i,con: integer;
p: pinaddr;
seconds10: TDateTime;

begin

if not callTraceStarted then begin

   ioStartWinsock;

   callSocket:= socket( PF_INET,SOCK_STREAM,0 );

   callhostentp:= gethostbyname(pChar('localhost'));
   if callhostentp=nil then
      xScriptError('localhost is not a valid internet domain.')
   else begin
      (* Try to connect as client. *)
      callsockaddr.sin_family:= AF_INET;
      callsockAddr.sin_port:= htons(callLogPort);
      seconds10:= 10.0/24/3600; (* 10 seconds. *)
      p:= pinaddr(callhostentp^.h_addr_list^);
      callsockaddr.sin_addr:= p^;
      con:= connect(callsocket,callsockaddr,sizeof(callsockaddr));
      if con=0 then begin
         callConnected:= true;
         GetMem(sbuf,1024);
         end
      else xScriptError('alOpenCallTraceLog: Unable to connect to call log port (' + inttostr(calllogport) + ').')
      end;

   if not callConnected then closesocket(callSocket);

   callTraceStarted:= true;
  end;
end;

procedure alCloseCallTraceLog;
begin
if callTraceStarted then begin
   if callConnected then begin
      closesocket(callSocket);
      callConnected:= false;
      FreeMem(sbuf);
      end;
   callTraceStarted:= false;
   callTraceCount:= 0;
   end;
end;


(* --------------------------- *)
(* end of call trace framework *)



var wcount: integer = 0;

tracemem: alevalmem; // For traceCallsTo
tracecallcnt: integer = 0;
savefuncret: fsptr;


procedure alcall( pnr: alint16; var pargs: xargblock;
                  pevalkind: xevalkind;
                  var pstateenv: xstateenv;
                  pfuncret: fsptr );
(* BFn 2017-08-08: Should pfuncret be VAR here? It is in
   all the al... procedures. There was an error in alp which
   was caused by pfuncret not pointing at the end of funcret
   (because of earlier call to alp), and then alp assuming
   that it did, by creating a start output pointer called
   funcret0, and then using funcret for temporary storage
   (intermediate results), before overwriting it with
   the calculated output. Could there be more places when
   the value of pfuncret is saved in alp functions?
   *)

(* pevalkind contains information that tells xevaluate what to
   do with the stuff (see xevaluate). *)
(* If you are evaluating a string to pfuncret, pass pevalkind to
   xevaluate, so that it will know what to do with the stuff. *)

var
debugstr: shortstring;
fname: string;
savefuncnr: integer;
argsPtrSave: xargblockptrtype;
savedIO: xSavedIODataRecord;
oldSaveIoPtr: xSavedIODataPtrType;

// (new:)
procedure restoreio;
begin
if alSaveIoPtr=NIL then with savedIo do begin
   (* AlSaveIoPtr=NIL means that savedIo contains the input and output
      numbers prior to first change of in or out. *)

   if alLastIOWasPersistent then
      // Mark as (possibly) changed for next upper level.
      if (oldSaveIoPtr<>NIL) then begin
         oldSaveIoPtr^:=savedIo;
         oldSaveIoPtr:= NIL;
         end;

   (* Restore input and output file unless persistent. Persistent is erased to next
      for higher levels. If more levels are needed, this can be achieved with
      <persistentIO> at each level. *)
   if not alLastIOWasPersistent then begin
      if iogetinfilenr<>oldInputFileNr then
         ioinwithfilenr(oldInputFileNr,pstateenv.cinp);
      if iogetoutfilenr<>oldOutputFileNr then
         iooutwithfilenr(oldOutputFileNr);
      end;

   (* Restore outstring setting. *)
   pstateenv.outstring:= oldOutString;

   (* Restore value from calling level. *)
   alLastIOWasPersistent:= oldLastIOWasPersistent;

   end;// (alSaveIoPtr=NIL, with savedIO)

end; (*restoreio*)


begin (*alcall*)

try

if xCurrentStateEnv<>@pStateEnv then
   xProgramError('x(alcall): pstateenv was expected to be same as xCurrentStateEnv but it was not.');

(* for xdebuginfo: *)
// Save func nr and args ptr

(* (new:) Save call stack. BFn 2020-02-12: Some traces cause runtime errors.
   Therefore this function is disconnected.
with xCurrentStateEnv^ do if false then begin
  ( * This logging of stack trace was disconnected, partly because it causes a very long
     error message, and because it caused program error ("in2<>xpos") when running decodelog:
     <test stm_simulator.log> and the file does not exist. /BFn 2020-02-10. * )

   backLogCnt:= backLogCnt+1;
   if backLogCnt<=xt.backLogTabSize then with backLogTab[backLogCnt] do begin
      blsavefuncnr:= funcnr;
      blargsPtrSave:= argsptr;
      end
   else begin
     savefuncnr:= xCurrentStateEnv^.funcnr;
     argsPtrSave:= xCurrentStateEnv^.argsPtr;
     end;
   end;
*)

(* (old: (keep)) *)
savefuncnr:= xCurrentStateEnv^.funcnr;
argsPtrSave:= xCurrentStateEnv^.argsPtr;

xCurrentStateEnv^.funcnr:= pnr;
xCurrentStateEnv^.argsPtr:= @pargs;

if alflagga('D') then with xcurrentstateenv^ do begin
   if backLogCnt>xt.backLogTabSize then
      iofShowMess('++ alcall: old funcnr = ' + inttostr(backLogTab[backLogCnt].blsavefuncnr) +
         ', new funcnr = ' + inttostr(pnr) + '.')
   else
      iofShowMess('++ alcall: old funcnr = ' + inttostr(savefuncnr) +
         ', new funcnr = ' + inttostr(pnr) + '.')
   end;

fname:= '';
if alflagga('D') then alvisaanrop(pnr,pargs,fname);


if (pevalkind<>xevalcompare) and (pnr>=firstcompare)
   and (pnr<=lastcompare) then begin
   fname:= xname(pnr);
   xProgramError('X(<'+fname +' ...>): This function can only be called within ?"..."? ' +
      ' or as 2nd parameter in <ifeq ...> or as even parameter in <case ...>.');
   end

else if pnr>xLastpredefinedFuncNr then begin
   // Macro or variable
   if integer(mactab[pnr])>alIndexMaxNr then begin
      if pnr<=xmaxfuncnr then begin
         if recursivemac[pnr] then with pstateenv do begin
            // Macro with <...>-expressions
            // Create pointer to a space where old IO data can be saved in case of change

            // Tracing of function calls
            if traceCallsTo>0 then begin
               if tracecallcnt>0 then tracecallcnt:= tracecallcnt+1
               else if traceCallsTo=xDefinedIngroup(pnr) then
                  if xCurrentStateEnv<>nil then
                     if xCurrentStateEnv^.argsPtr<>nil then begin
                        tracecallcnt:= 1;
                        alevaluate(pargs,pstateenv,tracemem,[1..100]);
                        iofwcons(alShowCall(xCurrentStateEnv^.funcnr,xCurrentStateEnv^.argsPtr^));
                        alDispose(pargs,traceMem);
                        saveFuncret:= pfuncret;
                        end;
               end;

            oldSaveIoPtr:= alSaveIoPtr;
            alSaveIoPtr:= @savedIO;
            almacro(pnr,pargs,pevalkind,pstateenv,pfuncret);
            (* Restore IO if necessary. During almacro, current io was saved
               prior to first change of in or out, and the pointer was cleared
               to indicate that io has been saved and that it possibly has changed. *)
            if (alSaveIoPtr=NIL) then restoreio;

            // Restore pointer to old IO data
            alSaveIoPtr:= oldSaveIoPtr;

            // Tracing of function calls
            if tracecallcnt>0 then begin
               if tracecallcnt=1 then begin
                  fsforwend(pfuncret);
                  if pfuncret<>savefuncret then
                     iofwcons('=> "' + fstostr(savefuncret) + '"' +char(13))
                  else iofwcons(char(13));
                  end;
               tracecallcnt:= tracecallcnt-1;
               end;
            end
         else
            // Variable, or macro without <...>-expressions.
            almacro(pnr,pargs,pevalkind,pstateenv,pfuncret)
         end
      else
         // Local variable
         almacro(pnr,pargs,pevalkind,pstateenv,pfuncret)
      end

   else if integer(mactab[pnr])>0 then
      (* table *)
      alIndexGet(integer(mactab[pnr]),pargs,pstateenv,pfuncret)
   else begin
      fname:= xname(pnr);
      xScriptError('X (alcall): Routine <'+fname+'...> not defined.');
      end;
   end

else begin

// System for debugging exceptions jan 2013/BFn
//if false (*alflagga('E')*) then begin
if alflagga('E') then begin
   CallTraceLevel:= callTraceLevel+1;
   callTraceTab[callTraceLevel].nr:= pnr;
   //callTraceLog('>' + xname(pnr));
   callTraceLog('>' + inttostr(pnr));
   end;

   case pnr OF

   1: xProgramError('X (alcall): Call to undefined function.');

   2: alsetflag(pargs,pstateenv); (* <setflag ch> *)

   3: alresetflag(pargs,pstateenv); (* <resetflag ch> *)

   4: alflag(pargs,pstateenv,pfuncret); (* <flag ch> returns "1" if set*)

   5: alifflag(pargs,pevalkind,pstateenv,pfuncret); (* <ifflag ch,thenstr,elsestr> *)

   6: alifeq(pargs,pevalkind,pstateenv,pfuncret); (* <ifeq str1,str2,thenstr,elsestr> *)

   7: alcase(pargs,pevalkind,pstateenv,pfuncret); (* <case str,alt1,res1[,alt2,res2,...]
                                    [,,others]> *)

   8: alchar(pargs,pstateenv,pfuncret); (* <char ch> *)

   9: aldef(pargs,defdef,pstateenv); (* <def namn,str[,nargs]> *)

   10: aldate(pfuncret); (* <date> *)

   11: altime(pfuncret); (* <time> *)

   12: alin(pargs,pstateenv,pfuncret); (* <in filename[:port][,binary]>,
                                           <in>
                                           <in ,pos> *)

   13: alout(pargs,pstateenv,pfuncret); (* <out filename[:port][,binary]>, <out> *)

   14: alunread(pargs,pstateenv); (* <unread str> *)

   15: alread(pargs,pstateenv,pfuncret); (* <read ln/*/n> *)

   16: alinfo(pargs,pstateenv,pfuncret); (* <info filename[:port]> *)

   17: alprogtest(pargs,pstateenv); (* <progtest fs/io/x> *)

   18: alsettings(pargs,pstateenv,pfuncret); (* <settings regardCrAsBlank,yes> *)

   19: alexec(pargs,pstateenv,pfuncret); (* <exec x-expression> *)

   20: alp(pargs,pstateenv,pfuncret); (* <p n1[,n2]> *)

   21: alj(pargs,pstateenv,pfuncret);
        (* <j statename[,par1[,par2...]]> (jump to state) *)


   22: with pstateenv do begin

      // Create pointer to a space where old IO data can be saved in case of change
      oldSaveIoPtr:= alSaveIoPtr;
      alSaveIoPtr:= @savedIO;
      alc(pargs,false,pstateenv,pfuncret); (* <c statename[,par1[,par2...]]>
         (call state) *)
      // Restore IO if necessary
      if alSaveIoPtr=NIL then
         (*restoreio0; // (new:) *) restoreio;
      // Restore pointer to old IO data
      alSaveIoPtr:= oldSaveIoPtr;
      end;

   23: alr(pargs,pstateenv,pfuncret); (* <r>, <r str> *)

   24: alpfail(pargs,pstateenv,pfuncret); (* <pfail n,str> *)

   25: alwcons(pargs,pstateenv,pfuncret); (* <wcons str> *)

   26: alcalc(pargs,pstateenv,pfuncret); (* <calc expr[,decimals]> *)

   27: alset(pargs,pstateenv,false); (* <set $name,str> *)

   28: alinpos(pstateenv,pfuncret); (* <inpos> *)

   29: alrename(pargs,pstateenv); (* <rename filename,filename>,
                                       <rename domain:portnr,filename> *)

   30: alclose(pargs,pstateenv,pfuncret); (* <close filename>
                                               <close domain:portnr>
                                               <close *>
                                               <close filename,asfilename> *)

   31: aldelete(pargs,pstateenv); (* <delete filename>,
                                       <delete domain:portnr> *)

   32: alwrite(pargs,pstateenv,pfuncret); (* <write str> *)

   33: alifgt(pargs,pevalkind,pstateenv,pfuncret); (* <ifgt str1,str2,thenstr,elsestr> *)

   34: alcleanup(pstateenv); (* <cleanup> *)

   35: alload(false,pargs,pstateenv,pfuncret); (* <load xfilename> *)

   36: althread(pargs,pstateenv,pfuncret); (* <thread evalstr> *)

   37: alpop(pargs,pstateenv,pfuncret); (* <pop name,divchar> *)

   38: alcd(pargs,pstateenv,pfuncret); (* <cd path> *)

   39: aldef(pargs,defpreldef,pstateenv); (* <preldef name,str[,nargs]> *)

   40: aldos(pargs,pstateenv,pfuncret); (* <dos doscommand> *)

   41: alselectInput(pargs,pevalkind,pstateenv,pfuncret); (* <selectInput file1,action1[,file2,action2[,...]]> *)

   42: almakebits(pargs,pstateenv,false,pfuncret); (* <makebits n,str> *)

   (* 43: Vacant *)

   44: almakebitscount(pargs,pstateenv,pfuncret); (* <makebitscount>, <makebitscount n> *)

   45: alhtod(pargs,pstateenv,pfuncret); (* <htod str> *)

   46: aldtoh(pargs,pstateenv,pfuncret); (* <dtoh str> *)

   47: alsleep(pargs,pstateenv); (* <sleep n> *)

   48: allinenr(pargs,pstateenv,pfuncret); (* <linenr> *)

   49: alconnected(pargs,pstateenv,pfuncret); (* <connected domain:port> *)

   50: alTerminate; (* <terminate> *)

   51: alwin32(pargs,pstateenv,pfuncret); (* <win32 createprocess,commandstr>
      <win32 shellexecute,open,filename>
      <win32 shellexecute,open,filename,parameters>
      <win32 shellexecute,open,filename,parameters,defaultpath>
      <win32 minimize>
      <win32 restore>
      <win32 gettickcount> *)

   52: alhtos(pargs,pstateenv,pfuncret); (* <htos str> *)

   53: alstoh(pargs,pstateenv,pfuncret); (* <dtot str> *)

   54: alvar(pargs,pstateenv); (* <var namn[,initstr]> *)

   55: alsqrt(pargs,pstateenv,pfuncret); (* <sqrt expr[,decimals]> *)

   56: with pstateenv do begin
      // Create pointer to a space where old IO data can be saved in case of change
      oldSaveIoPtr:= alSaveIoPtr;
      alSaveIoPtr:= @savedIO;
      alc(pargs,true,pstateenv,pfuncret); (* <c_lateevaluation x-filename[,par1
         [,par2...]]> (call state, defer evaluation of parameters until they are used) *)
      // Restore IO if necessary
      if alSaveIoPtr=NIL then (*restoreio0; // (new:) *) restoreio;
      // Restore pointer to old IO data
      alSaveIoPtr:= oldSaveIoPtr;
      end;

   57: albtoh(pargs,pstateenv,pfuncret); (* <btoh str> *)

   58: alwhile(pargs,pevalkind,pstateenv,pfuncret); (* <while condition,dosstr[,timeoutms]> *)

   59: alIfElseIf(pargs,pevalkind,pstateenv,pfuncret); (* <if condition,thenstr1,
      elsecond,thenstr2[,elsecond,thenstr3...][,,elsestr]> *)

   60: alshiftbits(pfuncret); (* <shiftbits> *)

   61: alLoadFile(pargs,pstateenv,pfuncret); (* <loadfile xfilename> *)

   62: alhtob(pargs,pstateenv,pfuncret); (* <htob str> *)

   (* (old:) In process of being renamed to <selectinput ...>, as soon as runonetest.x has been
      updated. *)
   63: alselectInput(pargs,pevalkind,pstateenv,pfuncret); (* <select file1,action1[,file2,action2[,...]]> *)

   64: alsp(pargs,pevalkind,pstateenv,pfuncret); (* <sp n> *)

   65: alabs(pargs,pstateenv,pfuncret); (* <abs expr[,decimals]> *)

   66: aloutpos(pfuncret);

   67: alEnterFromFile(pargs,pstateenv);

   68: alUnless(pargs,pevalkind,pstateenv,pfuncret); (* <unless condition,thenstr> *)
   (* (old:) 68: aldllBuffer(pargs,pstateenv,pfuncret); ( * <dllOutpar nr> * )*)

   69: alDo(pargs,pevalkind,pstateenv); (* <do str> *)
   (* (old:) 69: aldllbufferclear; ( * <dllOutparClear> * )*)

   (* To be removed when no longer in use in our x-scripts (BFn 2021-04-30): *)
   70: iofclear; (* <clear> *)
   71: alWindowFormat(pargs,pstateenv,pfuncret); (* <formmove x,y,xsize,ysize> *)

   72: alMax(pargs,pstateenv,pfuncret); (* <max expr1,expr2[,decimals]> *)
   (* 73: Vacant *)

   (* To be removed (input functions) when no longer in use in our x-scripts (BFn 2021-04-30): *)
   75: alto(pargs,pstateenv,true,false,pfuncret);(* <to_wholeword str1,str2,...> *)
   76: alto(pargs,pstateenv,false,true,pfuncret);(* <to_WithinLine ...> *)
   77: alaFilename(pstateenv,pfuncret);(* <filename>. *)

   78: alopt(pargs,pstateenv,pfuncret); (* <opt alt1,alt2,...> *)

   79: alWord(pstateenv,pfuncret); (* <word> *)

   (* Obsolete? In process of being replaced by <towl> and <towl ...>. *)
   80: alto(pargs,pstateenv,false,true,pfuncret); (* <toWithinLine>, <toWithinLine str1,str2,...> *)

   81: alanything(pstateenv); (* <anything> *)

   82: alto(pargs,pstateenv,false,false,pfuncret); (* <to str1,str2,...> *)

   83: alformat(pargs,pstateenv,pfuncret); (* <format llddxx..> *)

   84: alinteger(pargs,pstateenv,pfuncret); (* <integer[ i1,i2]> *)

   85: alaFilename(pstateenv,pfuncret); (* <afilename> *)

   86: aldecimal(pargs,pstateenv,pfuncret); (* <decimal[ d1,d2]> *)

   87: alalt(pargs,pstateenv,pfuncret); (* <alt alt1,alt2,...> *)

   88: alid(pstateenv,pfuncret); (* <id> - (like in Pascal for example) *)

   89: allwsp(pstateenv,pfuncret); (* <lwsp> - Linear white space. *)

   90: alfollowedby(pargs,pstateenv,pfuncret);
       (* <followedby str1,str2,...> *)

   91: alnotfollowedby(pargs,pstateenv,pfuncret);
       (* <notfollowedby str1,str2,...> *)

   92: alto(pargs,pstateenv,true,false,pfuncret); (* <toWholeword str1,str2,...> *)

   93: albits(pargs,pstateenv,pfuncret); (* <bits n[,hexvalue]> *)

   94: aleof(pstateenv,pfuncret); (* <eof> *)

   95: aleofr(pstateenv,pfuncret); (* <eofr> *)

   96: alto(pargs,pstateenv,false,true,pfuncret); (* <towl>, <towl str1,str2,...> *)

   97: alBitsDec(pargs,pstateenv,pfuncret); (* <bitsdec n[,intvalue]> *)

   98: alExcel(pargs,pstateenv,pfuncret); (* <excel open,filename>
                                              <excel select,sheetname>
                                              <excel get,row,column>
                                              <excel set,row,column>
                                              <excel save>
                                              <excel close> *)

   99: alReplaceWith(pargs,pstateenv,pfuncret); (* <replacewith str> *)

   100: if iofLoadEntered then
            alinttofs(alLoadLevel,pfuncret)
         else
            (* To prevent intro printing when an x file is loaded when a script is
               running. *)
            alinttofs(alLoadLevel+1,pfuncret); (* <loadlevel> *)

   101: alload(true,pargs,pstateenv,pfuncret); (* <loadfrom groupname,xfilename> *)

   102: almessagebox(pargs,pstateenv); (* <messagebox str> *)

   103: almessagedialog(pargs,pstateenv,pfuncret);
      (* <messagedialog str,yes/no/ok/cancel,str> *)

   104: alsql(pargs,pstateenv,pfuncret);
      (* <sql connect,servername,username,password> *)

   105: aldebug(pstateenv); (* <debug> *)

   106: alfileisopen(pargs,pstateenv,pfuncret); (* <fileisopen filename> *)

   107: alfunctions(pargs,pstateenv,pfuncret); (* <functions[ funcnam]> *)

   108: albitscount(pstateenv,pfuncret); (* <bitscount> *)

   109: aldllcall(pargs,pstateenv,pfuncret);
      (* <dllcall dllfile,procname[,type1,arg1[,type2,arg2],[ret type]> *)

   110: alcommand(pargs,pevalkind,pstateenv,pfuncret); (* <command doscommand
      [,timeoutms][,timeoutaction]> *)

   111: alWindowFormat(pargs,pstateenv,pfuncret); (* <windowFormat x,y,xsize,ysize> *)

   112: alatcleanup(pargs,pevalkind,pstateenv,pfuncret);

   113: allogto(pargs,pstateenv,pfuncret);

   114: aldef(pargs,deffunction,pstateenv); (* <function name,str[,minargs][,maxargs]> *)

   115: alStartProgram(pargs,pstateenv,pfuncret); (* <startProgram prog,parameters> *)

   116: alxp(pargs,pstateenv,pfuncret); (* <xp n[,htod]> *)

   117: allocalio(pargs,pevalkind,pstateenv,pfuncret); (* <localio script> *)

   118: alfileexists(pargs,pstateenv,pfuncret); (* <fileexists filename> *)

   119: alis(pargs,pstateenv,pfuncret); (* <is str[,str,str,...]> => yes/no *)

   120: aleq(pargs,pstateenv,pfuncret); (* <eq str1,str2> => yes/no *)

   121: aleoln(pfuncret); (* <eoln> *)

   122: aldllbufferclear; (* <dllbufferclear> *)

   123: alxdefaultdir(pfuncret); (* <xdefaultdir> *)

   124: alempty(pargs,pstateenv,pfuncret); (* <empty str[,str,str,...]> => yes/no *)

   125: alforeach(pargs,pevalkind,pstateenv,pfuncret); (* <foreach name,values,delimiter,action> *)

   126: aldirectoryexists(pargs,pstateenv,pfuncret); (* <directoryexists directoryname> *)

   127: alformcaption(pargs,pstateenv,pfuncret); (* <formcaption str>, <formcaption> *)

   128: alstrlen(pargs,pstateenv,pfuncret); (* <strlen str> *)

   129: alinputbox(pargs,pstateenv,pfuncret); (* <inputbox caption,prompt[,default]> *)

   // (new:)
   130: alNameas(pargs,pstateenv);
   (* (old:)
   130: xnameas(alfstostr(pargs.arg[1],eoa));*)

   131: alScriptError(pargs,pstateenv); (* <scriptError str> *)

   132: iofclear; (* <windowClear>  *)

   (* 133: Vacant. *)

   134: alMakeBitsClear; (* <makebitsclear> *)

   135: alBitsClear; (* <bitsclear> *)

   136: alset(pargs,pstateenv,true); (* <append name,str> *)

   137: alUpdate(pargs,pstateenv); (* <update $name,str[,initvalue]> *)

   138: alstrUpperCase(pargs,pstateenv,pfuncret); (* <strUpperCase str> *)

   139: alstrLowerCase(pargs,pstateenv,pfuncret); (* <strLowerCase str> *)

   140: aldllBuffer(pargs,pstateenv,pfuncret); (* <dllBuffer nr> *)

   141: ioOpenFiles(pfuncret); (* <openfiles> *)

   142: alDebugInfo(pargs,pstateenv,pfuncret); (* <debuginfo str> *)

   143: alMakebits(pargs,pstateenv,true,pfuncret); (* <makebitsdec n,str> *)

   144: alSort(pargs); (* <sort $name>, where name is a table *)

   (* 145: Vacant. *)

   146: alMsWord(pargs,pstateenv,pfuncret); (* <Word open,filename>
                                              <Word save>
                                              <Word close> *)
   147: alX(pargs,pstateenv,pfuncret); (* <x scriptdir> *)

   148: alPersistentIO; (* <persistentIO> *)

   149: alUniqueFileName(pfuncret); (* <tempFileName> *)

   150: alUniqueFileName(pfuncret); (* <uniqueFileName> *)

   151: alIfElseIf(pargs,pevalkind,pstateenv,pfuncret); (* <if condition,thenstr1,
      elsecond,thenstr2[,elsecond,thenstr3...][,,elsestr]> *)

   152: alPlay(pargs,pstateenv,pfuncret); (* <play filename> *)

   153: alIndexes(pargs,pstateenv,pfuncret); (* <indexes $tab[,delim]> *)

   154: alParamStr(pargs,pstateenv,pfuncret); (* <paramstr 0..n> *)

   155: alHelp(pargs,pstateenv,pfuncret); (* <help funcname> *)

   (* 156: Vacant. *)

   (* (old: )156: alIntro(pargs,pstateenv,pfuncret); ( * Introduction if loadlevel=1 * )*)

   157: alifis(pargs,pevalkind,pstateenv,pfuncret); (* <ifis str,thenstr[,elsestr]> *)

   158: alUsage(pargs,pstateenv,pfuncret); (* <usage (description and examples)> *)

   159: alInterface(pargs,pstateenv,pfuncret); (* <interface name1 name2 ...>*)

   // (old:)
   160: alRun(pargs,pstateenv,pfuncret); (* <run prog,parameters>, to be replaced by
      <startprogram prog,parameters,yes>. *)

   161: alExamples(pargs,pstateenv,pfuncret); (* <examples funcname> *)

   162: alRange(pargs,pstateenv,pfuncret); (* <range n1,n2[,delim]> *)

   163: alPack(pargs,pstateenv); (* <pack $str,delim,$var1,$var2, ...> *)

   164: alUnpack(pargs,pstateenv); (* <unpack str,delim,$var1,$var2, ...> *)

   165: alifempty(pargs,pevalkind,pstateenv,pfuncret); (* <ifempty str,thenstr[,elsestr]> *)

   end; (*case*)

// System for debugging exceptions.
// if false (*alflagga('E')*) then begin
if alflagga('E') then begin
   (* Check that the level is not reduced below 0 (which would happen
      after activating it with <setflag E>). *)

   if callTraceLevel>0 then begin
      CallTraceLevel:= callTraceLevel-1;
      callTraceLog('<');
      //callTraceLog('<' + xname(pnr));
      end;
   end;

   end;

if fname<>'' then begin (* XFLAGGA VAR SATT VID ANROP *)
   debugstr:='<- <'+fname+'...>';
   iodebugmess(debugstr);
   end;

except on e:exception do begin
   fname:= xname(pnr);
   if fname='calc' then
      xProgramError('X: Program error - <'+fname+' '+alargs2str(pargs,0,pstateenv)+
         '> raised exception "'+e.message+'".')
   else if fname='if' then
      xProgramError('X: Program error - <'+fname+' '+alargs2str(pargs,1,pstateenv)+
         '> raised exception "'+e.message+'".')
   else if pargs.narg=0 then begin
      xProgramError('X: Program error - <'+fname+'> raised exception "'+e.message+'".')
      end
   else
      xProgramError('X: Program error - <'+fname+' ...> raised exception "'+e.message+'".');
   end;

end; (*try*)

if alflagga('D') then with xcurrentstateenv^ do begin
   if backLogCnt<=xt.backLogTabSize then
      iofShowMess('++ alcall: Returning from funcnr = ' + inttostr(pnr) +
         ' to funcnr = ' + inttostr(backLogTab[backLogCnt].blsavefuncnr) + '.')
   else
      iofShowMess('++ alcall: old funcnr = ' + inttostr(savefuncnr) +
         ', new funcnr = ' + inttostr(pnr) + '.')
   end;


// Restore funcnr and args pointer

(* Disconnected because it sometimes resulted in runtime errors. /BFn 2020-02-12
// (new:) and update index to backLogTab
with xCurrentStateEnv^ do begin
   if backLogCnt<=backLogTabSize then with backLogTab[backLogCnt] do begin
      funcnr:= blsavefuncnr;
      argsptr:= blargsPtrSave;
      end
   else begin
      funcnr:= savefuncnr;
      argsPtr:= argsPtrSave;
      end;
   backLogCnt:= backLogCnt-1;
   end;
*)

(* (old: keep.) *)
xCurrentStateEnv^.funcnr:= savefuncnr;
xCurrentStateEnv^.argsPtr:= argsPtrSave;

(* ++ For debugging purpose:
if ioOtherThreadsEnabled then begin
   if not xFault then
      xProgramError('alcall(at end): Other threads unexpectedly enabled.');
   end;
*)

end; (*alcall*)


end.
