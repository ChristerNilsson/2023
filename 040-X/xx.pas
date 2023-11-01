   (* XX.PAS *)

UNIT xx;

{$MODE Delphi}


(****) INTERFACE (****)

USES
   xt (* ioinptr, xparsrecord, xint16 *)
   ,xfs (* fsptr, fsforward, ... *)
   ,xio (* ioinit, ioxreset, ioxread, ioxclose *)
   ,sysUtils (* inttostr *)
   ,strUtils (* ansiPos, ansiLeftstr, ansiMidStr. *)
   // ,interfaces // FPC
   ,Forms (* Application *)
   ,controls (* mrCancel *)
   ,xioform (* iofThreadInit, iofWcons, iofLogto *)
   ,LCLIntf, LCLType, LMessages
   ,messages
   ;

var
xcasemask: ioint16; (* Determines if input comparison shall be
                       case sensitive or not. $FF = case sensitive.
                       $DF = not case sensitive. *)
xoptcrfile: char;   (* Determines if input comparison for files and tcp/ip
                       streams shall regard CR as white space. '<CR>' = do,
                       ' ' = Do not. xio shall copy xoptcrfile to xoptcr when
                       entering a file or stream. It shall copy ' ' to xoptcr
                       when entering console. *)

xskipcomment: char; (* Tells if comments shall be skipped, *)
xlinecomment: boolean;(* and what a comment is:
                        Programming languages:
                        '-',false = <settings skipcomment,ada>
                        '/',false = <settings skipcomment,c>
                        '(',false = <settings skipcomment,pascal>
                        '-',false = <settings skipcomment,ada>
                        Other kinds of line comments (example):
                        ';',true = <settings skipcomment,;>
                        '/',true = <settings skipcomment,/>
                        Do not skip comments:
                        ' ' = <settings skipcomment,no>
                        xskipcomment is compared with all characters
                        in the input stream, to see if it could be the beginning
                        of a comment. *)
xcommentasblank: char;   (* Tells if comments shall be regarded as blanks, *)
xlinecommentasblank: boolean;(* and what a comment is:
                        Programming languages:
                        '-',false = <settings regardcommentasblank,ada>
                        '/',false = <settings regardcommentasblank,c>
                        '(',false = <settings regardcommentasblank,pascal>
                        '-',false = <settings regardcommentasblank,ada>
                        Other kinds of line comments (example):
                        ';',true = <settings regardcommentasblank,;>
                        '/',true = <settings regardcommentasblank,/>
                        Do not regard comments as as blanks:
                        ' ' = <settings regardcommentasblank,no>
                        xcommentasblank is compared with all characters
                        in the input stream, to see if it could be the beginning
                        of a comment. *)
var
xUseIndentation: boolean;

threadvar
xoptcr: char;       (* Determines if input comparison shall regard
                       CR as white space. ' ' = Do not. '<CR>' = do. *)
xoptcr2: char;       (* = char(10) if xoptcr=char(13). *)


var
xfault: boolean;    (* A fault was detected which means that the output
                       currently generated may not be valid. Used to abort
                       xcallstate and alwhile until control is returned to the
                       input window. *)
xProgramFault: Boolean; (* Used to prevent eternal loops when a program error
   discovered when creatin a message for a program error. *)
xScriptInUndefinedState: boolean; (* Same as xFault but reset first after
   cleanup. Used to show a warning if other than <cleanup> or <load ...>
   is done after a fault. *)

var
xinputcompileerror: boolean; (* Compilation error instring from x window *)

xcurrentgroupnr: integer; (* During compilation:
   Nr of file if we are at the top level of a file
   Nr of group if we are at the top level of a group
   Nr of state if we are in a state.
   Nr 1 is reserved for x window.
   *)
xloading: xint16 = 0; (* >0 => xload is processing an x file. Used  by aldef to
                             prevent double <def ...> warnings when working
                             interactively. *)
xfailpos: ioinptr;      (* Position of failure for most succesful failed
                           alternative in xcallstate. Set by xcallstate,
                           used by <pfail ...>. *)
xcheckvar: boolean = False; (* True=> Give warning when <set ...> is used
                           on a name that was not defined by <var ...>. *)

(* (during compilation:) *)
xCurrentLocVarLevel: integer= -1; // (old) (see alDef and xargblock)

const xstatestacksize = 100;

(* This is public so that threadfunc shall be able to initialize it. *)
threadvar
xstatecalllevel: integer; (* 0 = xcallstate not yet called.
   1 = ... called once
   2 = ... called (recursively) twice.
   Used to check state calling depth that it is within reasonable limits,
   and to chech that unrpop is done at the same calling level as the
   corresponding unrpush. *)

(* Used by xDebugInfo: Pointer to inner-most pStateEnv of xCallState. *)
xcurrentStateEnv: XstateenvPtr;

(* Used by xcallstate to reset loop detection when the input pointer  in
   some other file has advanced. *)
xresetloopdetection: Boolean;

var
// ++ Debug - to get state info when thread has hung in a state
xLastCurrentStateEnv: XstateenvPtr;

TYPE
xint32= longint;

const
xmaxfuncnr= (*997*)1997; (* Max number for function call - new version. *)
                           (* Changed to 1997 by BFn 090121 because 997 was
                              not enough. - error message from xgetfreenr at load
                              of simreccontrol. *)
xmaxlocvarnr= 100; (* Max number of local variables in a function. functab
   [xmaxfuncnr+1..xmaxfuncnr+xmaxlocvarnr] is used to temporary store names
   of local variables in a function definition. *)
CONST
xstan= 253; (* START ANROP-TECKEN (ASCII-KOD) *)
xeoa= 254; (* end-OF-ARGUMENT -TECKEN (ASCII-KOD) (255=eofs) *)

TYPE
xstring32= packed array[1..32] OF char;
xstring64= packed array[1..64] OF char;
xtstring32= string[32];

var xexestring: string;


procedure xinit( pinp: ioinptr );

procedure xThreadInit;
(* X initialisation functions to be performed at entrance to a thread. *)

procedure xclearxfiles;
(* Clear loaded x-files. *)

procedure xcleartab;
(******************)
(* Delete all entries in functab.
   Typical use: Called by alinit before defining functions.
   (alinit is used by <cleanup>). *)

procedure xversal( var pch: char )
(* Convert to upper case if lower case. *);

procedure xgemen( var pch: char )
(* Convert from upper case to lower case. *);

type xgroupkindtype = (predefined,xwindow,a_file,a_group,a_state,a_subState);

procedure xseekgroup( var pname: string; pkind: xgroupkindtype; var pnr: xint16);
(* Return the number of file, group or state pname. Return 0 if not found. *)

function xsameparent(pstate1,pstate2: integer): boolean;
(* Check that pstate1 and 2 are defined in same file or group. *)

function xParent(pstate: integer): integer;
(* Return parent (state, group or file) nr for pstate. *)

function xStateName(pstate: integer): string;
(* Return name for pstate. *)

type xDefineSpecialType = (dsnone,dsvar,dspreldef);

type xExtraConditionType = (xNoCond,xOddNarg,xEvenNarg);

procedure xdefine(pname: string; pparmin,pparmax: xint16;
   pExtraCond: xExtraConditionType;
   pSpecial: xDefineSpecialType; var pn: xint16);
(*******************)
(* Usage: xdefine('ifeq',3,4,xNoCond,dsnone,6);
   if error then xsetcompilerror;
  (define function ifeq as number 6 and with 3 to 4 parameters.)
  xdefine('count',0,0,false,false,100);
  (define function count as number 100, with 0 parameters.
  pspecial=dsvar if xdefine is called from <var ...> (alvar).
  It means that <set pname,...> is allowed.
  pspecial=dspreldef if xdefine is called from <preldef ...>.
  It means that it can be redefined.
  Note that pn is double directed, if input pn=0, xdefine shall
  itself get a number of existing or new entry. But if pn>0
  xdefine must use it. Pn output is the used number in either case. *)

procedure xdefinepdf(pname: string; pn: xint16; pparmin,pparmax: xint16;
   pExtraCond: xExtraConditionType = xNoCond);
(*******************)
(* Define predefined function. Simpler version of xdefine.
   Usage example: xdefinepdf('ifeq',6,3,4);
  (define function ifeq as number 6 and with 3 to 4 parameters.)
*)

procedure xDefineArgNames(pn: xint16; pnames: string);
(*******************)
(* Define argument names that can be used in the code to check
   that commas are correctly placed in the call, using {argname:}.
   Examples:
   xdefineArgNames(59,'then else');
   xdefineArgNames(151,'then elseif/even then/odd else');
   *)

procedure xDefineNormalVariable(pname: string; var pn: xint16; var pindex: boolean);
(* Define normal (resident) variable. Simpler version of xdefine.
   Return pindex=true if pname ends with '[]'.
   Usage example: xdefineVariable('a',varnr,pfel);
   if not pfel then
      fsrewrite(mactab[varnr]);
      ...
*)

procedure xDefineFunction(pname: string; pparmin,pparmax: xint16;
   pExtraCond: xExtraConditionType;
   pprel: boolean; var pn: xint16; var perror: boolean);
(* Define a function in functab. Simpler version of xdefine.
   Note that a function definition can be a redefinition of
   a preliminary defined function. xDefineFunction shall return the
   proper function nr (new or old) so that aldef can put the
   macro string in the correct slot in mactab.
   Usage example: xdefinefunction('f',159,funcnr,pfel);
   if pfel then ...
*)

procedure xDefineParMinMax(pn: xint16; pparmin,pparmax: xint16);
(* Change only parmin and parmax of already defined function.
   Used by aldef which scan's for $-signs as it copies the function
   to the table. Parmin parmax shall be updated to lowest and highest
   $n if no other info given. *)

function xgetcurrentxfile: integer;

function xgetvisiblenr(pname: string): integer;
(********************)
(* Lookup pname in functab. If name is visible in xcurrentgroup return its
   number, else return 0. Print error message if pname is multiply visible.
 *)

procedure xSetUsage(ps: fsptr);
(* Set allowed external usage of variables and functions in the currently compiled file.
   ps = NIL: No checking of references.
   ps = empty string: No external references to this script allowed.
   ps = "name1|name2|...": External references to this script limited to name1,
      name2, ....
   *)

function xUserdefined(pname: string): boolean;
(* See if a name is a userdefined function. Used to print warning
   message after script error. *)

function xgroupname(pgroupnr: integer): string;

FUNCTION xgetfreenr: xint16;
(* Find a unused <>-name-entry in functab, return its index (or 1
   + error message). *)

function xname(pn: xint16): string;
(* Return name of function pn *)

procedure xcompilestring( pin,put: fsptr; pendch: char; pncallallowed: boolean;
                          pfilename: fsptr; plinenr1,plinenr2: integer );
(*********************)

(* Format in:

   ...<name a1,a2,...>...$name...

Format out:

   ...|stan|nr|narg|la1(1)|la1(2)|...a1...|eoa|...|lan(1)|lan(2)|...an...|eoa|ra1|ra2|...|nul|...

or, if narg=0 ($funcname or <varname>):

   ...|stan|nr|nul|...

or, if nr>=250:

   ...|stan|0|nr1|nr2|narg|la1(1)|la1(2)|...a1...|eoa|...|lan(1)|lan(2)|...an...|eoa|ra1|ra2|...|nul|...

or, if narg=0 and nr>=250 ($varname or <funcname>):

   ...|stan|0|nr1|nr2|nul|...

or, if nr>xmaxnarg ($varname - local variable reference):

   ...|stan|0|nr1|nr2|nlev|nul|...

where,
     stan     =  char(253)
     nr       =  function-nr <250(decoded name)
     nr1*250+nr2 = function-nr >=250
     narg     =  number of arguments
     la1(1)*250+la1(2)  =  length of argument 1 (possibly length div 16)
     ...a1... =  argument 1
     eoa      =  control-character for end-of-argument
     ra1      =  Recursive argument 1 (1..narg)
     nlev     =  nesting level. Initially 0. When fylli copies the string, it is
                 set to the current nesting level. Used to get correct offset for
                 evaluation of local variables references.
     nul      =  ascii NUL

   Nr, narg, lan  och  ran are binary (byte).

   Ra1..ran are numbers of the arguments which themselves contain calls.
   This is so that arguments which do not contain calls shall not need to
   be evaluated. The sequence is terminated by NUL.

   Ra1...nul are only inclúded if the call has arguments (narg>0).

   if name = "set", "pop" or "foreach" then A1 is compiled to a binary number (the
   number of the macro to be set). If the binary number is <=2490, it is coded as
   one byte: 1..249. If > 249 it is coded as three bytes: 0, 0..249 (nr/250),
   0..249 (nr mod 250).
   If name = "set" and the variable is a local variable (nr>xmaxfuncnr)
   then an empty byte (0) is added. This byte will later be used
   if the <set ...> call is later inserted in a macro (in $n) and used
   to ensure that the local variable will be evaluated in the context
   (offset) in which it was compiled.

   <set $name[ix],str> is compiled as <set $binnr,index,str>

   $name[index] is compiled as: <name index>. Index references are
   recognised by having string pointers (mactab[n]) containing a low
   number (<=alIndexMaxNr) instead of a pointer to an fs string.
   A pointer to an fs string is always a high number because the
   bottom of the memory in Win32 is not available for application program
   variables.

   <var $name> and <var $name,arg1> are compiled as a normal function calls
   ($name is representedas a string). If on top level, it will directly be
   evaluated and create a variable. If in a function body, a temporary local
   variable is created after it is compiled. If the function later is evaluated,
   then each call to <var ...> increments a local variable counter and,
   if there is an argument, initialises the corresponding local variable.

*)


// Like xCompileString but with instant resulution of state references
procedure xCompileAndResolve( pin,put: fsptr; pendch: char; pncallallowed: boolean;
                          pfilename: fsptr; plinenr1,plinenr2: integer );

// Resolve and remove an entry in statereftab. Used by alC.
procedure xResolveAndRemove(prefptr: fsptr);


procedure xdecodecall( var ps: fsptr; var pnr: xint16; var pargs:xargblock);

(* Decode compiled call from ps. stan was just read. *)

(* After return from xdecodecall, ps points at the first char
   following the call. *)

procedure xcompare( ptest: fsptr; pendch: char;
        psetpar,psetxpar: boolean; var pstateenv: xstateenv; var plika: boolean)

(* JÄMFÖR EN INSTRÄNG MED EN TESTSTRÄNG. TESTSTRÄNGEN KAN INNEHÅLLA
   ANROP. PLIKA=TRUE OM ÖVERENSSTÄMMelse FINNS TILL TESTSTRÄNGENS SLUT. *)

(* OBS! xcompare LAGRAR PEKARE IN I pinp, SOM SEDAN ANVÄDNS AV alp. alp FÅR
   DÄRFÖR INTE ANROPAS EFTER ATT pinp-STRÄNG ÄNDRATS, UTAN ATT NYTT
   ANROP TILL xcompare GJorTS. *);


procedure xinitpn( var pstateenv: xstateenv );(* Init <p n> buffers. *)

procedure xresetpn( var pstateenv: xstateenv ); (* Clear all <p n> buffers *)


procedure xdisposepn( var ppars: xparsrecord );
(* Dispose fs-strings connected to ppars. *)

function xfstostr( pp: fsptr; pendch: char ): string;
(* Instead of fstostr, to cope with eoa-termination. *)


TYPE xevalkind=    (xevalnormal, (* Evaluate (dont compare)
                                    pxp to pretstr. *)
                    xevalwrite,  (* Evaluate as xevalnormal,
                                    but write buffered char's to
                                    output before each <>-call. *)
                    xevalwcons,  (* Evaluate as xevalnormal,
                                    but write buffered char's to
                                    output window before each <>-call. *)
                    xevalcompare, (* Compare pxp^... with pinp^... *)
                    xevalsilent  (* Delete all output other than jump
                                    return data. Used in !/.../! *)
                    );

procedure xevaluate( pxp: fsptr; ptillch: char;
                     pevalkind: xevalkind;
                     var pStateEnv: xStateEnv;
                     pretstr: fsptr );
(* EVALUERA PIN FRAM TILL CH=PTILLCH. OM PSKRIV - SKRIV UT
   RESULTERandE STRÄNG ISTÄLLET FÖR ATT LÄGGA DEN TILL PUT.
   *)


procedure xcallstate( var pstateenv: xstateenv; pfuncret: fsptr );

procedure xinalt(pstatenr,paltnr: integer; paltstate: xaltstatetype; pxpos: fsptr;
   var pfound: boolean; var pxinpos: fsptr);
(* Check if pxpos points at the out-string of alt (paltnr) in state (pstatenr).
   Then set pfound and let pxinpos to point at the in string of that alt, else nil.
   If altnr=0 or 999, check preact and postact instead. *)

procedure xload(
   pfilegroup: string; (* "" or other name to be used instead of filename. *)
   pfilename:fsptr; (* In: Filename *)
   pShortName: boolean; (* In: original filename had no path. E.g. "test1.x"
      Used by ioxreset when looking for internal files. *)
   var pstateenv: xstateenv; (* In: ppars (<p n>), in/out: cinp *)
   var pfileNumber: xint16); (* out: Filenumber. *)
(* Compile and load a file. If already compiled - just return its number.

   EXEKVERA FRISTÅENDE <...>-ANROP. BYGG TILLSTÅND AV
   TILLSTÅNDSDEFINITIONS SATSER:

   !"..."!      - EXEKVERAS VID INTRÄDE TILL TILLSTÅND

   ?"..."?
   !"..."!      - ETT ALTERNATIV, IN OCH UT-DEL

   !"..."!      - Executed at exit from a state

EXEKVERING = EVALUERING + UTSKRIFT AV RESULTATSTRÄNGEN.
*)


procedure xInitStateEnv( var pstateenv: xstateenv; pinp: ioinptr);
(* Reset/initialize state environment. *)

procedure xsendto( pstr:string; var pstateenv: xstateenv; var pretstr: string );
(* Send a string (pstr), normally containing <...>-calls,
   to X and have it compiled and evaluated and return
   the result (pretstr). This version is used in the normal form.  *)

procedure xsendto_debug(pstateenvptr: xstateenvptr; pstr:string;
   ppncallallowed: boolean; var pretstr: string );
(* Send a string (pstr), normally containing <...>-calls,
   to X and have it compiled and evaluated and return
   the result (pretstr). This version is used in the debug form. *)

function xdebuginfo(): string;
(* Return info about current state and current alternative.
   (Used by ioerrmess). *)

procedure xtest(puseparamstr: boolean);
(* Test with X. Use command parameter string (paramstr(1)) if
   puseparamstr = True. *)

procedure xtest2;
(* Like xtest, except do not show x window, do not run main loop and iocleanup,
   and do not use paramstr.
   xtest2 is used by xdll. *)

procedure ximport(pfile: xint16; pname: string);
(*********)
(* Import pfile:pname to the currently compiled xfile.
   Check first that pname is defined in pfile.
   Used by alload to make names arg2... visible, after
   having called xLoad. *)

procedure ximportnr(pnr: integer);
(*********)
(* Import variable or function pnr to the currently compiled xfile.
   Used by <useShortNameFor ...> to make variables and functions
   visible through short names (like <name ...> or $name). *)

procedure xsetcompileError;
(* Set xCompileErrorActive if a file is being loaded.
   Used to stop compilation after errors detected in XAL (aldef). *)

function xgetcompileError: boolean;
(* Get xCompileErrorActive. Used by alload. *)

procedure xGetFuncInfo(pfuncnr: integer; var pdefined: boolean;
   var ppredefinedFunc: boolean; var pname: string);
(* Get info about function pfuncnr. Used by <functions>. *)

// where pnr is defined (which group)
function xdefinedingroup(pnr: integer): integer;

const
(* To define allowed 1st char and following characters in a dollarvariable
   reference. Example: $abcÅÄÖ_123. *)
xidchar1Range= ['A'..'Z','_','a'..'z',char($C0)..char($FB)];
xidcharRange= ['A'..'Z','_','0'..'9','a'..'z',char($C0)..char($FB)];

procedure xnameas(pname: string);
(* Implements <nameas name>.
   Change name of file group. *)

var
xCompileErrorActive: Boolean = False;
xCompileFilename: fsptr = nil;
xCompileLine1,xcompileLine2: integer;
xAllowJumpsBetweenNormalStates: boolean = true; (* Allow old jumps between ordinary states
   (-----). New style allows only jumps between substates. *)
xSameParentRequiredForJump: boolean = false; (* Allow jumps between files.
   This is used to extend cmdfilereader.command with extra commands for different
   systems, STM, Rio Tinto ... *)

function xgetsubstate1(pnr: integer): integer;
(* Return first substate if any, or 0. *)

function xparentname(pnr: integer): string;
(* Return name of parent (used for error messages). *)

procedure xCompileError2(perrmess: string);
(* Report compiletime error. *)

procedure xScriptError(perrmess: string);
(* Report script error found at runtime.
   Prints error message with ioerrmess and sets xfault. *)

procedure xProgramError(perrmess: string);
(* Report program error found at runtime.
   Prints error message with ioerrmess and sets xfault. *)

var
xLastPredefinedFuncNr: integer; (* Last nr of predefined function.
   Macros and variables start after this number.
   Used by alCall to separate predefined functions from macros and
   variables. This was implemented to remove the risk of defining
   a function in the case list and not with define (which would
   cause a predefined function being called when actually a variable
   was referenced). *)

(* State references in function definitions must be recorded
in alDef, because that is where the function string is created. *)
procedure xAddFuncStateRef(ps: fsptr; pkind: integer);


(****) IMPLEMENTATION (****)

uses
   xal   (* aljamfor, alcall, alinit, alflagga *)
   ,xunr // unrBottomPtrInCurrentState
// ,dialogs (* showmessage *)
;

(*
         ANROPSSTRUKTUR:

                    -------------------
                    |        X        |
                    |                 |         ------------
          --------->|XCOMPILESTRING   |         |    AL    |
                    |                 |         |          |
          --------->|XEVALUATE        |-------->|ALCALL    |
                    |                 |         |          |
          --------->|XCOMPARE         |         |          |
                    |            A    |         |          |
                    -------------|-----         ------------
                    |            |    |
          --------->|xload--------    |
                    |                 |
                    -------------------
*)


(* Loaded X-files. *)
const
filestacksize=100;
xmaxngroups=100;

var

(* (old:) compileError: Boolean = False; *)
errorroutinelevel: integer= 0; (* The load level where an error was found.
   Compared with xloading to produce intellegent messages from all load levels
   after a compilation error. *)

CONST
xmaxshortnr= 249; (* max short number for function call nr
                    (>=250 requires 2 bytes). *)
argNameTabSize = 50;

var
funcindex: array[0..xmaxfuncnr] of xint16; (* Only entries 0..xmaxfuncnr-1 are used. *)
functab:  array[0..xmaxFuncnr+xmaxlocvarnr] of record (* (0 is not used.) *)
  (* (xmaxfuncnr+1..xmaxfuncnr+xmaxlocvarnr is reserved for local variables) *)
   name: string;
   defined: boolean;
   special: xDefineSpecialType; (* xdsnone = <function ...> or <def ...>,
      xdsvar = <var ...>, xdspreldef = <preldef ...> *)
   parmin,parmax: xint16; (* Min and max number of par's to a call. *)
   extraCond: xExtraConditionType; (* Possibility to specify something else, like
      that number of argument must be odd or even. *)

   definedIn: xint16;      (* Nr of group (which could be a file, state, group or
      1=x window or 0=predefined) in which name is defined (same name can be defined separately in
      different groups).
                              0 = global. *)
   importedTo: fsptr;      (* Files, other than where defined, where the name
                               shall be visible. *)
   index: integer; (* in list pointed at by funcindex[index]. (Used for removing local
      variables when no longer needed.) *)
   argNameIndex: integer; (* Optional index to names of arguments to function, starting
      with argument 2. *)
   argNameCount: integer; (* Number of defined argument names for this function. *)
   next: xint16;
   end;

type argOptionType = (none,ArgEven,ArgOdd,argLast);

var
argNameTab: array[1..argNameTabSize] of record
   name: string;
   option: argOptionType;
   end;

argNameLast: integer = 0;

procedure xGetFuncInfo(pfuncnr: integer; var pdefined: boolean;
   var ppredefinedFunc: boolean; var pname: string);
(* Get info about function pfuncnr. Used by <functions>. *)
begin
pdefined:= False;
ppredefinedfunc:= False;
pname:= '';
if (pfuncnr>=1) and (pfuncnr<=xmaxfuncnr) then with functab[pfuncnr] do begin
   if defined then begin
      pdefined:= True;
      ppredefinedfunc:= (definedin=0);
      pname:= name;
      end;
   end;
end; (*xGetFuncInfo*)

function xdefinedingroup(pnr: integer): integer;
begin
xdefinedingroup:= functab[pnr].definedin;
end;

var
stan,eoa: char;
eofs: char;
eofr: char; (* End of input fragment (254). *)
ctrlM: char;
lastfree: xint16; (* Memory for xgetfreenr to avoid searching
                     from 1 every time. *)

(* VARIABLER FÖR TILLSTÅNDSMASKIN: *)
(*---------------------------------*)

TYPE
altp= ^altblock;
altblock= record
          kompin,kompout: fsptr;
          next: altp;
          end;

grouprecord = record
   kind: xgroupkindtype;
   name: string;
   next: xint16; (* next name in hash-list. *)
   free: boolean;
   definedIn: integer; (* Points to a group if it belongs to one, or 0. *)
   topLoad: boolean; (* True = directly loaded from x-window (or xdll or win32 arg).
      Used to give x-window direct access to names on top load level. *)
   usageNames: fsptr; (* if <> nil: Only these names (on top level)
      are accessible from outside. if=nil: All names are accessible from
      outside. Only used for afile. *)
   (* The remaining fields are only valid for kind=a_state: *)
   pre: fsptr; (* Executed when a state is entered (by j or c). *)
   post: fsptr; (* Executed when a state is left (by j or r). *)
   caselist: altp; (* Alternatives *)
   substate1: integer; (* (old) for state with substates: nr of first substate, else 0 *)
   loading: boolean; (* for kind=a_file: True if file is being loaded. Otherwise false.
      Used to provide better error message when a variable or function name is not
      found because it is in a file that is in the process of loading. *)
   end;

const
filetabstart= 2; (* 0 = predefined, 1 = X input window. *)
filetabsize= 241; (* Max number of files. Shall be limited to the non-special characters 0-252
   because they imported to lists are implemented as strings of characters. Shall preferably
   be a prime number. *)
grouptabstart= filetabstart+filetabsize;
grouptabsize= 241; (* Maximumum number of groups. Preferably a prime number *)
statetabstart=grouptabstart+grouptabsize;
statetabsize= 499; (* Maximum number of states. Preferably a prime number. *)
//statetabend= statetabstart+statetabsize-1;
substatetabstart=statetabstart+statetabsize;
substatetabsize= 241; (* Maximum number of states. Preferably a prime number. *)
substatetabend= substatetabstart+substatetabsize-1;

(* Primenumbers are supposed to be better in hashed tables. *)

var
grouptab: array[0..substatetabend] OF grouprecord; (* Group 0-1 are
   reserved for predefined functions and x input window group.
   Group 2..grouptabstart-1 are reserved for files. Groups grouptabstart...statetabstart-1
   are reserved for groups. Groups statetabstart..statetabend are reserved for states. *)

(* Init grouptab. If pdisposedata, then the structure may contain
   strings (fs), which shall be disposed first. *)



const stateRefTabSize = 500; (* This limits how many state references there
   can be in x files which are simultaneously being loaded. *)
const stateRefStartTabSize = 20; (* This limits how many x files which can
   simultaneously be loading. *)
type stateRefRecord = record
   stateRef: fsptr;
   groupNr: integer; // filenr, groupnr, statenr or substatenr (or 0 or 1)
   cjKind: integer; (* 1 = <c ...> 2 = <j ...> 3 = <c_lateevaluation ...>
      Used for error messages when a reference cannot be resolved. *)
   end;
var
(* It is allowed to call or jump to states early in a file, and then define
   the state later in the file. This means that the compiler (xLoad)  cannot
   always resolve a state reference (<c/j ...>) immidiately. The resolution of
   state references is therefore postponed until the entire x-file has been
   compiled.
   When a call or jump (<c/j ...>) is compiled, information is stored in
   stateRefTab. The information contains a pointer to the reference (which still
   is a string), and the number of the file, group or state or substate where
   the call or jump was located. The latter information is needed to because
   there are visibility rules for names and these refer to where the reference
   is located, and where the referenced state is located.
   When reaching the end of an x-file (at the end of xLoad), the state
   references belonging to this file are compiled (translated from strings
   to numbers). *)
stateRefTab: array[1..stateRefTabSize] of stateRefRecord;
stateRefCount: integer; // Number of currently stored references

(* stateRefStartTab[n] points at the last stored state reference of load
   level n-1. Consequentley. stateRefStartTab[1] always holds the value 0.
   At the end of xLoad, the state references for the newly loaded
   x file are statereftab[staterefstarttab[staterefloadlevel]+1]..staterefcount].
   These references are resolved before leaving xload.
   stateRefLoadLevel is basically the same as xLoading. *)
stateRefStartTab: array[1..stateRefStartTabSize] of integer;
stateRefLoadLevel: integer;

(* State references in function definitions must be recorded
   in alDef, because that is where the function string is created. *)
procedure xAddFuncStateRef(ps: fsptr; pkind: integer);
begin
staterefcount:= staterefcount+1;
with stateRefTab[staterefcount] do begin
   stateref:= ps;
   groupNr:= xcurrentgroupnr;
   cjKind:= pkind;
   end;
end;(* xAddFuncStateRef *)

procedure initgrouptab(pdisposedata: boolean);
var groupnr: integer;
altptr, oldalt: altp;

begin
with grouptab[0] do begin
   kind:= predefined;
   next:= 0;
   free:= False;
   name:= 'predefined';
   end;
with grouptab[1] do begin
   kind:= xwindow;
   next:= 0;
   free:= False;
   name:= 'xwindow';
   end;
for groupnr:= filetabstart to grouptabstart-1 do with grouptab[groupnr] do begin
   kind:= a_file;
   next:= 0;
   free:= True;
   name:= '';
   end;
for groupnr:= grouptabstart to statetabstart-1 do with grouptab[groupnr] do begin
   kind:= a_group;
   next:= 0;
   free:= True;
   name:= '';
   end;
for groupnr:= statetabstart to substatetabstart-1 do with grouptab[groupnr] do begin
   kind:= a_state;
   next:= 0;
   free:= True;
   name:= '';
   if pdisposedata then begin
      if pre<>nil then fsdispose(pre);
      if post<>nil then fsdispose(post);
      altptr:= caselist;
      while not (altptr=nil) do with altptr^ do begin
         fsdispose(kompin);
         fsdispose(kompout);
         oldalt:= altptr;
         altptr:= next;
         dispose(oldalt);
         end;
      end;
   pre:= NIL; post:= NIL;
   caselist:= NIL;
   end;
for groupnr:= substatetabstart to substatetabend do with grouptab[groupnr] do begin
   kind:= a_subState;
   next:= 0;
   free:= True;
   name:= '';
   if pdisposedata then begin
      if pre<>nil then fsdispose(pre);
      if post<>nil then fsdispose(post);
      altptr:= caselist;
      while not (altptr=nil) do with altptr^ do begin
         fsdispose(kompin);
         fsdispose(kompout);
         oldalt:= altptr;
         altptr:= next;
         dispose(oldalt);
         end;
      end;
   pre:= NIL; post:= NIL;
   caselist:= NIL;
   end;
end;


procedure xversal( var pch: char )
(* Convert to upper case if lower case. *);

(* OBS!! IMPLEMENTATIONSBEROENDE. *)

begin (*xversal*)

(* This is according to character set ISO 8859-1: *)
if pch IN ['a'..'z',char($E5),char($E4),char($F6)] then pch:= char( ord(pch) - 32 );

end; (*xversal*)

procedure xgemen( var pch: char )
(* Convert from upper case to lowe case. *);

(* Note!! Implementation dependent. *)

begin (*xgemen*)

(* This is according to character set ISO 8859-1: *)
if pch IN ['A'..'Z',char($C5),char($C4),char($D6)(*'Å','Ä','Ö'*)] then pch:= char( ord(pch) + 32 );

end; (*xgemen*)

procedure xlowercase(var pstr: string);
var i: integer; ch: char;
begin
for i:= 1 to length(pstr) do begin
    ch:= pstr[i];
    if ch IN ['A'..'Z',char($C5),char($C4),char($D6)(*'Å','Ä','Ö'*)] then ch:= char( ord(ch) + 32 );
    pstr[i]:= ch;
    end;
end; (*xlowercase*)


(* Hashed name tables for xfile names (file, group and state names) *)
(********************************************************************)


FUNCTION xhashgroup(var pname: string; pkind: xgroupkindtype ): xint16;
var  i,sum: xint16; tabsize,tabstart: integer;
begin
case pkind of
   a_file: begin
      tabsize:= filetabsize;
      tabstart:= filetabstart;
      end;
   a_group: begin
      tabsize:= grouptabsize;
      tabstart:= grouptabstart;
      end;
   a_state: begin
      tabsize:= statetabsize;
      tabstart:= statetabstart;
      end;
   a_subState: begin
      tabsize:= substatetabsize;
      tabstart:= substatetabstart;
      end;
   end;
sum:= 0;
for i:= 1 to length(pname) do sum:= sum + ord(pname[i]);
(* (new: this error must be old - found same in xwns 081223. I wonder what
   the -1 came from. Was discovered when creating state "getoutfile" in p2c.x,
   which had a sum evenly dividable by 499)/BFn 111016 *)
xhashgroup:= tabstart + (sum MOD tabsize);
// (old:)xhashgroup:= tabstart + (sum MOD tabsize-1);
end; (*xhashgroup*)


procedure xseekgroup( var pname: string; pkind: xgroupkindtype; var pnr: xint16);
(* Return the number of file, group or state pname. Return 0 if not found. *)
var i: xint16; ch: char; name: string;
begin
name:= pname;
xlowercase(name);
pnr:= xhashgroup(name,pkind);
while not ((pnr=0) or (grouptab[pnr].name=name)) do
      pnr:= grouptab[pnr].next;
if pnr>0 then if grouptab[pnr].free then pnr:=  0;
end;


(* checkNewName
   ------------
   Check if a new name is allowed, at the current place of compilation
   (xCurrentGroup). Return 0 if it is allowed, and otherwise the number of the
   first found conflicting file, group, state or substate.
   - A file name is allowed if no other file has it.
   - A group name is allowed if no other group has it, in the same file.
   - A state name is allowed if no other state or substate has it, in the same file.
   - A state name is also allowed if it is defined in a group, and has the same
      name as a state in another group, in the same file.
   - A substate name is allowed if:
      1. It follows the rules for state names (see above), and
      2. No other substate, to the same state, has it.

   xSeekVisibleGroup is used to check that names of groups, states and
   substates are unique in its scope of visibility. Usage example (from
   readsepstr):
   ( * New substate  * )
   ...
   ( * Check if there is any competing state or substate with the same name. * )
   xCheckNewName(newname,a_subState,newstatenr);
   if newstatenr<>0 then
      ( * substate name already exists. * )
      xCompileError('X: Substate name '+newname+' already exists in ' +
         grouptab[grouptab[newstatenr].definedin].name +'.');
   *)
procedure checkNewName( var pname: string; pkind: xgroupkindtype; var pnr: xint16);
var i: xint16; ch: char; name: string;
currentSubState, currentState, currentGroup, currentFile: integer;
existingNameSubState, existingNameState, existingNameGroup, existingNameFile: integer;
found: boolean;

procedure identifyCurrent;
var grp: integer;
begin
// Identify current substate, state, group and file from xCurrentGroup
currentSubState:= 0;
currentState:= 0;
currentGroup:= 0;
currentFile:= 0;
grp:= xCurrentGroupNr;
if grouptab[grp].kind=a_substate then begin
   currentSubState:= grp;
   grp:= grouptab[currentgroup].definedIn;
   end;
if grouptab[grp].kind=a_state then begin
   currentState:= grp;
   grp:= grouptab[currentgroup].definedIn;
   end;
if grouptab[grp].kind=a_group then begin
   currentGroup:= grp;
   grp:= grouptab[currentgroup].definedIn;
   end;
if grouptab[grp].kind=a_file then currentFile:= grp;
end;

procedure identifyExisting;
var grp: integer;
begin
// Identify existingName substate, state, group and file from pnr
existingNameSubState:= 0;
existingNameState:= 0;
existingNameGroup:= 0;
existingNameFile:= 0;
grp:= pnr;
if grouptab[grp].kind=a_substate then begin
   existingNameSubState:= grp;
   grp:= grouptab[existingNamegroup].definedIn;
   end;
if grouptab[grp].kind=a_state then begin
   existingNameState:= grp;
   grp:= grouptab[existingNamegroup].definedIn;
   end;
if grouptab[grp].kind=a_group then begin
   existingNameGroup:= grp;
   grp:= grouptab[existingNamegroup].definedIn;
   end;
if grouptab[grp].kind=a_file then existingNameFile:= grp;
end;

begin
name:= pname;
xlowercase(name);
pnr:= xhashgroup(name,pkind);
found:= false;
while not (pnr=0) or found do begin
   if (grouptab[pnr].name=name) then begin
      if pkind=a_file then found:= true
      else begin

         identifyCurrent;
         identifyExisting;

         // Check the different rules
         if pkind=a_group then begin
            (* Another group with the same name was found. Check if it is
               defined in the same file. *)
            if groupTab[pnr].definedIn = currentFile then found:= true;
            end
         else if pkind=a_state then begin
            if currentFile=existingNameFile then begin
               (* Both belong to the same file. New name is allowed if both are
                  defined in groups, and the groups are different. *)
               if (currentgroup=0) or (existingNameGroup=0) then found:= true
               else if currentgroup=existingNameGroup then found:= true;
               end
            else ;(* the existing name is defined in another file =>
               no conflict with the new name. *)
            end
         else if pkind = a_substate then begin
            // Check that the existing name does not belong to the same state.
            if currentState=existingNameState then found:= true;
            end;
         end; // (not a_file)
      end; // name was found in grouptab
   if not found then pnr:= grouptab[pnr].next;
   end; // while

if (pkind=a_state) and not found then begin
   // Check also conflicts with substate names
   pnr:= xhashgroup(name,a_substate);
   while not (pnr=0) or found do begin
      if (grouptab[pnr].name=name) then begin

         identifyCurrent;
         identifyExisting;

         if currentFile=existingNameFile then begin
            (* Both belong to the same file. New name is allowed if both are
               defined in groups, and the groups are different. *)
            if (currentgroup=0) or (existingNameGroup=0) then found:= true
            else if currentgroup=existingNameGroup then found:= true;
            end;// Same file
         end;// Same name
      if not found then pnr:= grouptab[pnr].next;
      end;// while
   end; // a_state and not found

if (pkind=a_substate) and not found then begin
   // Check also conflicts with state names
   pnr:= xhashgroup(name,a_state);
   while not ((pnr=0) or found) do begin
      if (grouptab[pnr].name=name) then begin

         identifyCurrent;
         identifyExisting;

         if currentFile=existingNameFile then begin
            (* Both belong to the same file. New name is allowed if both are
               defined in groups, and the groups are different. *)
            if (currentgroup=0) or (existingNameGroup=0) then found:= true
            else if currentgroup=existingNameGroup then found:= true;
            end;// Same file
         end;// Same name
      if not found then pnr:= grouptab[pnr].next;
      end;// while
   end; // a_state and not found

// (Is this needed? - Hope not) if pnr>0 then if grouptab[pnr].free then pnr:=  0;
end; // checkNewName


(* xSeekNextGroup: Like xSeekGroup, except it seeks next group if pnr>0.
   To search the first group, pnr shall be 0 as input value. *)
procedure xseekNextgroup( var pname: string; pkind: xgroupkindtype; var pnr: xint16);
(* Return the number of file, group or state pname. Return 0 if not found. *)
var i: xint16; ch: char; name: string;
begin
name:= pname;
xlowercase(name);
if pnr=0 then pnr:= xhashgroup(name,pkind)
else // Continue with next
   pnr:= grouptab[pnr].next;
while not ((pnr=0) or (grouptab[pnr].name=name)) do
   pnr:= grouptab[pnr].next;
if pnr>0 then if grouptab[pnr].free then pnr:=  0;
end;

(* Use plevel as input and output parameter!
   As input: level where to start looking. xgetvisiblegroup will work
   from the input plevel and up until it finds the groupname and it is
   visible, or until it fails
   As output: if found, plevel is the level where the name was found visible.
      if not found, plevel = 5.
   If the name was found a certain level, and the caller cannot find the function
   name there (for example $system in config.x on state level), then it can
   increment plevel and test a higher level (for example file level).

   If used in a loop to find a function or variable name, plevel shall
   start at 1.
   if *)
function xgetvisiblegroup(pname: string; var plevel: integer): integer;
(************************)
(* Lookup pname in grouptab. If name is visible in xcurrentgroup return its
   number, else return 0. Print error message if pname is multiply visible.

   Note that group, state and substate names are global in Delphi-X, in the
   sense that they cannot be used twice for the same purpose. The following
   X files will for example not compile, since there are two packages
   named pack1, one in test1.x and one in test2.x:

   test1.x:
   <load test2>
   pack1
   =====
   <var $test,test(test1.pack1).>
   pack2
   =====
   <var $test,test(test1.pack2).>

   test2.x:
   pack1
   =====
   <var $test,test(test2.pack1).>
   pack2
   =====
   <var $test,test(test2.pack2).>

   start with pstartlevel and continue until found or level  = 4 (file).
   The new level shall be returned to the caller.
   This is to make it possible to find for example a name in a file,
   if the file is directly loaded (topload) and contains a state or
   group with the same name as the file. For example: look for
   $config.system in a file confix.x which both contains a state called
   config.x (which does not contain the name system) and a variable
   called $system.
   *)

var
groupnr: integer;
definedin,next: integer;
visible: boolean;

begin

visible:= false;
groupnr:= 0;
// (old:) plevel:= 1;

while not visible and (plevel<=4) do begin

    // 1. Find group
    case plevel of
       1: xseekgroup(pname,a_subState,groupnr);
       2: xseekgroup(pname,a_state,groupnr);
       3: xseekgroup(pname,a_group,groupnr);
       4: xseekgroup(pname,a_file,groupnr);
       end;(* (case) *)

    if groupnr>0 then begin

       definedin:= grouptab[groupnr].definedin;

       // 2. Is it visible?
       // groups on top level are visible everywhere
       if definedIn =0 then visible:= true
       else begin

          // See if defined in or imported in current or parent group
          next:= xcurrentgroupnr;

          while next<>0 do begin
             // variables and functions defined in current or parent group are visible
             if next = definedIn then visible:=true;
             next:= grouptab[next].definedIn;
             end;(*while*)

          // Groups defined on top level of loaded files are visible in x-window (1)
          if (xcurrentgroupnr=1)
             and (grouptab[definedIn].definedIn=xcurrentgroupnr)
             and (grouptab[definedIn].topLoad)
             then visible:=true;
          end;(*else*)
       end;(* groupnr>0 *)

    // Step up level
    if not visible then plevel:= plevel+1;
    end; (* (while) *)

// Return answer
if visible then xgetvisiblegroup:= groupnr else xgetvisiblegroup:= 0;

end; (*xgetvisiblegroup*)


function xgetsubstate1(pnr: integer): integer;
(* Return first substate if any, or 0. *)
begin
xgetsubstate1:= grouptab[pnr].substate1;
end;

function xparentname(pnr: integer): string;
(* Return name of parent (used for error messages). *)
var parent: integer;
begin
parent:= grouptab[pnr].definedin;
xparentname:= grouptab[parent].name;
end;


function xsameparent(pstate1,pstate2: integer): boolean;
(* Check that pstate1 and 2 are defined in same file or group. *)
begin
xsameparent:= grouptab[pstate1].definedIn=grouptab[pstate2].definedin;
end;


function xParent(pstate: integer): integer;
(* Return parent (state, group or file) nr for pstate. *)
begin
xParent:= grouptab[pstate].definedIn;
end;


function xStateName(pstate: integer): string;
(* Return name for pstate. *)
begin
xStateName:= grouptab[pstate].name;
end;


procedure xcreategroup(var pname: string;
   pgroupkind: xgroupkindtype;
   var pnr: xint16;
   var perror: boolean);
(* Create a state with the name pname. Return its number - pnr. *)
var last, stopnr: xint16; i: xint16; ch: char; sname: string;
tabstart, tabend: integer;
currentgroupnr: integer;
begin
perror:= FALSE;
sname:= pname; (* (truncates if necessary) *)
xlowercase(sname);

(* Save xcurrentgroup because it may be overwritten by pnr:= ... *)
currentgroupnr:= xcurrentgroupnr;

pnr:= xhashgroup(sname,pgroupkind);
if grouptab[pnr].free then grouptab[pnr].Next:= 0

else begin

   (* 1. Find last *)
   last:= pnr;
   while not (grouptab[last].next=0) do last:= grouptab[last].next;

    (* 2. Find free *)
   case pgroupkind of
      a_file: begin
         tabstart:= filetabstart;
         tabend:= tabstart+filetabsize-1;
         end;
      a_group: begin
         tabstart:= grouptabstart;
         tabend:= tabstart + grouptabsize - 1;
         end;
      a_state: begin
         tabstart:= statetabstart;
         tabend:= tabstart + statetabsize - 1;
         end;
      a_substate: begin
         tabstart:= substatetabstart;
         tabend:= tabstart + substatetabsize - 1;
         end;
      end;

    stopnr:= pnr-1;
    if stopnr<tabstart then stopnr:= tabend;
    while not ((grouptab[pnr].free) or (pnr=stopnr)) do begin
        if pnr=tabend then pnr:= tabstart
        else pnr:= pnr+1;
        end;

    if grouptab[pnr].free then begin
        grouptab[last].next:= pnr;
        grouptab[pnr].next:= 0;
        end
    else begin
      xScriptError(
      'X: Cannot store x-file '+sname+' - tables full.');
      pnr:= 0; perror:= true;
      end;
    end; (* Search for free record *)

if pnr>0 then with grouptab[pnr] do begin
    name:= sname;
    kind:= pgroupkind;
    free:= false;
    definedin:= currentgroupnr;
    topLoad:= alTopLoaded;
    usageNames:= nil;
    if (pgroupkind=a_state) or (pgroupkind=a_subState) then begin
       fsnew(pre);
       fsnew(post);
       caselist:= nil;
       end;
    substate1:= 0;
    loading:= false;
    end;

if alflagga('D') then
  iodebugmess('xcreatestate: '+pname+':'+inttostr(pnr)+'.');

end; (*xcreategroup*)

procedure xnameas(pname: string);
(* Implements <nameas name>.
   Change name of file group. *)
var kind: string;
begin
if grouptab[xcurrentgroupnr].kind=a_file then
   grouptab[xcurrentgroupnr].name:= pname
else begin
   case grouptab[xcurrentgroupnr].kind of
   xwindow: kind:= 'xwindow';
   a_state: kind:= 'state';
   a_group: kind:= 'group';
   end;
   xScriptError('X (<nameas '+pname+'>): This function is expected to be called in '+
      'the beginning of an x-File, but appears to have been called in '+kind+' '+
      grouptab[xcurrentgroupnr].name+'.');
   xsetcompileerror;
   end;
end;(*xnameas*)



var
checkVarDefault: boolean;
useIndentationDefault: boolean;
compileAltsDefault: boolean;
allowFunctionCallsAfterPreactDefault: boolean;
allowBlanksBeforeCommentToEolnDefault: boolean;


procedure xinit( pinp: ioinptr );
(***************)

var
i: xint16;
statenr: xint16;

begin (*xinit*)

for i:= 0 to xmaxfuncnr do funcindex[i]:= 0;
for i:= 0 to xmaxfuncnr do functab[i].defined:= False;
xLastPredefinedFuncNr:= 0;
functab[0].name:= '';

lastfree:= 2; (* Used by xgetfreenr. *)
        (* Number 1 shall be reserved for calls to undefined functions. *)

stan:= char(xstan);
eoa:= char(xeoa);
eofs:= char(fseofs);
ctrlM:= char(13);

(* TILLSTÅNDSMASKIN: *)

initgrouptab(false);

(* Case insensitive comparisons is default. *)
xcasemask:= $DF;
xoptcrfile:= ' '; (* Do not allow CR as white space in files and sockets *)
xoptcr:= ' '; (* Do not allow Cr as white space in console input. *)
xoptcr2:= ' ';
xskipcomment:= ' ';(* Do not skip comments. *)
xlinecomment:= false;
xcommentasblank:= ' ';(* Do not regard comments as blanks. *)
xlinecommentasblank:= false;
xUseIndentation:= false;

eofr:= char(ioeofr);

(* Init thread variables for main thread. *)
xThreadInit;
iofThreadInit;
alThreadInit;

(* Get default values of x-file local settings. *)
CheckVarDefault:= xCheckVar;
useIndentationDefault:= xUseIndentation;
compileAltsDefault:= alCompileAlts;
allowFunctionCallsAfterPreactDefault:= alAllowFunctionCallsAfterPreact;
allowBlanksBeforeCommentToEolnDefault:= alAllowBlanksBeforeCommentToEoln;

end; (*xinit*)


procedure xThreadInit;
(* X initialisation functions to be performed at entrance to a thread. *)
begin
xstatecalllevel:= 0;
xoptcr:= ' ';
xoptcr2:= ' ';
xfault:= false;
xProgramFault:= false;
xresetloopdetection:= False;
end; (* xThreadInit *)


procedure xclearxfiles;
(*********************)
(* Clear all loaded x-files.
   Typical use: Through <cleanup> - after changing an x-file. *)

begin (*xclearxfiles*)

initgrouptab(true);

end; (*xclearxfiles*)


procedure xcleartab;
(******************)
(* Delete all entries in functab.
   Typical use: Called by alinit before defining functions.
   (alinit is used by <cleanup>). *)

var
i: xint16;

begin (*xcleartab*)

for i:= 0 to xmaxfuncnr do funcindex[i]:= 0;
for i:= 1 to xmaxfuncnr do functab[i].defined:= False;

lastfree:= 2; (* Used by xgetfreenr. *)
        (* Number 1 shall be reserved for calls to undefined functions. *)

// Erase table of argument names
argNameLast:= 0;

end; (*xcleartab*)


// Compilefilename stack - used to create load-sequence in error messages.
const
loadsequencesize= 50;
var
loadsequenceindex: integer = 0;
loadsequence: array[1..loadsequencesize] of fsptr;


function basicfilename(pfilename:string): string;
(* Example:
   "N:\STM-N\U - System Verification and Validation\FAT\X-scripts\cmdfilereader.x"
   => "cmdfilereader.x"
*)
var name: string;
slashpos: integer;
begin
name:= pfilename;
repeat
   slashpos:= ansipos('\',name);
   if slashpos=0 then
      slashpos:= ansipos('/',name);
   if slashpos<>0 then
      (* Remove until and including '\' *)
      (* Example: name= "a\b.c", length=5, slashpos=2, newlength=length-slashpos=3. *)
      name:= AnsiRightStr(name,length(name)-slashpos);
   until slashpos=0;
basicfilename:= name;
end; (*basicfilename*)

function getloadsequence: string;
var s: string; i: integer;
begin
if loadsequenceindex>1 then begin
   s:= '(Loadsequence: ';
   for i:= 1 to loadsequenceindex do
      s:= s + '->'+basicfilename(fstostr(loadsequence[i]));
   s:= s + ')';
   end;
getloadsequence:= s;
end;

var xshowloadsequence: boolean = false;

function xCompInfo: string;
(* Return compilation information. *)
begin
   if xCompileLine1=0 then begin
      (* - *)
      xinputcompileerror:= true;
      xCompInfo:= '';
      end
   else if xCompileLine1=xCompileLine2 then
      xCompInfo:= ' '#13'File '+basicfilename(fstostr(xcompilefilename))
      +': Line nr '+inttostr(xCompileLine1)+'.'
   else xCompInfo:= ' '#13'File '+basicfilename(fstostr(xcompilefilename))
      +': Within lines nr '+inttostr(xCompileLine1)+'...'+inttostr(xCompileLine2)+
      '.';
end; (* xCompInfo *)

procedure xCompileError2(perrmess: string);
(* Report compiletime error. *)
var s: string;
begin
   s:= perrmess + xCompInfo;
   (* (Skipped for normal compilation errors because it only disturbs error message: *)
   (* if xshowloadsequence then begin
      if loadsequenceindex>1 then s:= s + getloadsequence;
      xshowloadsequence:= false;
      end;*)
   ioerrmessCompile(s);
   xCompileErrorActive:= true;
   ErrorRoutineLevel:= xloading;
end;

procedure xCompileError3(perrmess: string);
(* Like xCompileError2 but adds load sequence. *)
begin
xshowloadsequence:= true;
xCompileError2(perrmess);
end;



procedure xScriptError(perrmess: string);
(* Report script error found at runtime.
   Prints error message with ioerrmess and sets xfault. *)
begin
   xFault:= true;
   xScriptInUndefinedState:= true;
   if xCurrentStateEnv<>nil then with xCurrentStateEnv^ do begin
      if argsPtr<>nil then begin
         pErrmess:= 'X ('+alShowCall(funcnr,argsPtr^)+'): '+perrmess;
         if backLogCnt<xt.backLogTabSize then begin
            if backLogCnt>0 then
               pErrMess:= pErrMess + '(from ' +
               alShowCall(backLogTab[backLogCnt].blsavefuncnr,backLogTab[backLogCnt].blargsPtrSave^) +
               ')';
            if backLogCnt>1 then
               pErrMess:= pErrMess + '(from ' +
               alShowCall(backLogTab[backLogCnt-1].blsavefuncnr,backLogTab[backLogCnt-1].blargsPtrSave^) +
               ')';
            if backLogCnt>2 then
               pErrMess:= pErrMess + '(from ' +
               alShowCall(backLogTab[backLogCnt-2].blsavefuncnr,backLogTab[backLogCnt-2].blargsPtrSave^) +
               ')';
            end;
         end;
   end;
   iomessage('Script error',perrmess);

   // Send to result area too, so that message is still visible after acking the message.
   (* Do not put in result area during  <play ...> because <play ...> will try to compare it
      with the expected output. *)
   if not alPlayRunning then
      iofWcons('Script error: ' + pErrmess);

   // Close and Complete any ongoing logging (so that the last message is included in whole)
   iofLogto('',false);
end;

procedure xProgramError(perrmess: string);
(* Report program error found at runtime.
   Prints error message with ioerrmess and sets xfault. *)
begin
   xFault:= true;
   if not xProgramFault then begin
      xProgramFault:= true;
      xScriptInUndefinedState:= true;
      if xCurrentStateEnv<>nil then with xCurrentStateEnv^ do begin
         if xCurrentStateEnv^.argsPtr<>nil then
            pErrmess:= 'X ('+alShowCall(funcnr,argsPtr^)+'): '+perrmess;
         end;
      iomessage('Program error',perrmess);

      // Send to result area too, so that message is still visible after acking the message.
      (* Do not put in result area during  <play ...> because <play ...> will try to compare it
         with the expected output. *)
      if not alPlayRunning then
         iofWcons('Program error: '+ pErrmess);

      // Close and Complete any ongoing logging (so that the last message is included in whole)
      iofLogto('',false);
      end;
end;


procedure testnewname(pname: string; pindex: integer; plocal: boolean;
   var pfuncnr: integer);
(**************)
(* Lookup pname in functab. Check if there is any conflict with existing
   name definitions. If so, print error message and return perror=true.
   Use funcindex[pindex] to find names equal to pname.
   Pfuncnr is used when redefining names. 0= no name found >0 = first name found.
 *)

var found: boolean; i: xint16;
imp: fsptr;
definedIn: integer;
next,child: integer;
impnext: fsptr;

begin

if xCompileErrorActive then
   xProgramError('*** X (testnewname): Program error - xcompileerroractive was ' +
      'expected to be false at entry of testnewname but it was true.');

pfuncnr:= 0;

i:= funcindex[pindex];

while (i<>0) and not xCompileErrorActive do begin
   if (functab[i].name = pname) then begin

      definedin:= functab[i].definedin;

      // Allow redefine of opt and abs because they are widely used in old code
      // <range ...> exists in decodelog.
      if (definedIn = 0) and (i<>alRangeFuncNr) and (i<>alDoFuncNr) then begin
         (* Remove these exceptions when the scripts defining them are old enoough to use
            their own x interpreters. *)
         // Exception for <settings preldefwithnarg,yes/no>
         if not alInSettingPrelDefWithNarg then
            xCompileError2(pname + ' is a predefined function, and cannot be redefined.');
         end
      else if (functab[i].definedIn = xcurrentgroupnr) and (xcurrentgroupnr=1) then begin
         // Defined in xwindow - OK to redefine in Xwindow but not as local variable.
         if plocal then begin
            xCompileError2(pname + ' is already defined in x window and cannot be redefined '+
               'as a local variable.');
            end;
         pfuncnr:= i;
         end
      else if (functab[i].definedIn = xcurrentgroupnr) and (functab[i].special=dspreldef) then begin
         // Defined in same group, but only preliminary - OK to redefine but not as local variable.
         if plocal then begin
            xCompileError2(pname + ' is already preliminary defined as normal variable in ' +
               grouptab[definedIn].name + ' and cannot be redefined as local variable.');
            end;
         pfuncnr:= i;
         end
      else begin

         // See if defined in or imported in current or parent group
         next:= xcurrentgroupnr;

         while (next<>0) and not xCompileErrorActive do begin
            if next = definedIn then begin
               (* pname is already defined in group 'definedIn' which is either
                  the same group (xcurrentgroup) or a parent to it (next). Print
                  a suitable error message depending on where the new definition
                  is (definedIn) and where the old is (next). *)
               case grouptab[definedIn].kind of
                  a_file: begin
                     // Old definition is on file group level
                     pfuncnr:= i;
                     xCompileError2(pname+' is already defined globally in the same file, '+
                        grouptab[definedIn].name + ' (not allowed).');
                     end;
                  a_group: begin
                     // Old definition is on group group level
                     if next=xcurrentgroupnr then begin
                        pfuncnr:= i;
                        xCompileError2(pname+' is already defined in the same group, '+
                           grouptab[definedIn].name + ' (not allowed).');
                        end
                     else begin
                        pfuncnr:= i;
                        xCompileError2(pname+' is already defined in parent group '+
                           grouptab[definedIn].name +' (not allowed).')
                        end
                     end;
                  a_state: begin
                     // Old definition is on state group level
                     if next=xcurrentgroupnr then begin
                        pfuncnr:= i;
                        xCompileError2(pname+' is already defined in the same state, '+
                           grouptab[definedin].name + ' (not allowed).');
                        end
                     else begin
                        pfuncnr:= i;
                        xCompileError2(pname+' is already defined in parent '+
                           grouptab[definedIn].name +' (not allowed).')
                        end;
                     end;
                  a_subState: begin
                     // Old definition is on substate group level
                     if next=xcurrentgroupnr then begin
                        pfuncnr:= i;
                        xCompileError2(pname+' is already defined in the same sub state, '+
                           grouptab[definedin].name + ' (not allowed).');
                        end
                     else
                        xProgramError('X(testnewname): X Program error - ' +
                           'Expected next('+inttostr(next)+')=xcurrentgroupnr('+
                           inttostr(xcurrentgroupnr)+') but it was not.');
                     end;
                  end;(*case*)
               end
            else begin
               // See if imported to a parent group
               impnext:= functab[i].importedTo;
               while impnext<>nil do begin
                  if impnext^=eofs then impnext:= nil
                  else begin
                     if integer(impnext^)=next then begin
                        pfuncnr:= i;
                        xCompileError2(pname+' is already imported to the same file '+
                           grouptab[integer(impnext^)].name +', cannot be redefined here.');                        impnext:= nil; // stop search
                        end
                     else fsforward(impnext);
                     end;
                  end;(*while*)
               end;
            next:= grouptab[next].definedIn;
            end;(*while*)

         // See if already defined in a child of current group
         next:= grouptab[functab[i].definedIn].definedIn;
         while (next<>0) and not xCompileErrorActive do begin
            if next = xcurrentgroupnr then begin
               case grouptab[functab[i].definedIn].kind of
                  a_file: begin
                     if xcurrentgroupnr=1 then begin
                        pfuncnr:= i;
                        // OK to redefine from x window but only if it was preliminary
                        if functab[i].special=dspreldef then
                           (* - *)
                        else
                           xCompileError2(pname+' is already defined in file group '+
                              grouptab[definedIn].name +
                              ' (not allowed unless defined with preldef).');
                        end
                     else xProgramError('X(xlookup): Program error - Expected a ' +
                        'group or a state but found a file.');
                     end;
                  a_group: begin
                     pfuncnr:= i;
                     xCompileError2(pname+' is already defined in child group '+
                        grouptab[definedIn].name +' (not allowed).');
                     end;
                  a_state: begin
                     pfuncnr:= i;
                     xCompileError2(pname+' is already defined in child state '+
                        grouptab[definedIn].name +' (not allowed).');
                     end;
                  end;(*case*)
               end;(*next=xcurrentgroup*)
            next:= grouptab[next].definedIn;
            end;(*while*)

         end;(*else*)
      end;(*functab[i].name=pname*)
   i:= functab[i].next;
   end;(*while*)

end; (*testnewname*)


procedure xdefine(pname: string; pparmin,pparmax: xint16;
   pExtraCond: xExtraConditionType;
   pSpecial: xDefineSpecialType; var pn: xint16);
(*******************)
(* Usage: xdefine('ifeq',3,4,xNoCond,dsnone,6);
   if error then xsetcompilerror;
  (define function ifeq as number 6 and with 3 to 4 parameters.)
  xdefine('count',0,0,false,false,100);
  (define function count as number 100, with 0 parameters.
  pspecial=dsvar if xdefine is called from <var ...> (alvar).
  It means that <set pname,...> is allowed.
  pspecial=dspreldef if xdefine is called from <preldef ...>.
  It means that it can be redefined.
  Note that pn is double directed, if input pn=0, xdefine shall
  itself get a number of existing or new entry. But if pn>0
  xdefine must use it. Pn output is the used number in either case. *)

var ch: char; i: xint16;
charsum,ix,nr: integer;
groupnr: integer;

begin (*xdefine*)

// 1. Convert to lower case and test name for unique visibility
charsum:= 0;
for i:= 1 to length(pname) do begin
   ch:= pname[i];
   if ord(ch)<ord('a') then begin
      xgemen(ch);
      pname[i]:= ch;
      end;
   charsum:= charsum + integer(ch);
   end;
ix:= charsum mod xmaxfuncnr;
TestNewName(pname,ix,(pn>xmaxfuncnr),nr);

// 2. If name existed but preliminary, then use the existing nr
// (move this part to testnewname?)
if not xcompileerroractive and (nr>0) then begin
   if pn>0 then
      xProgramError('X(xdefine): Program error in X: Pn=0 was expected since xdefine ' +
         'found existing legal entry in functab to use')
   else pn:= nr;
   end;

// 2. Get new number if necessary
if pn=0 then pn:= xgetfreenr;

// Special for win32windowproc
if (not xCompileErrorActive) and (pname='win32windowproc') then begin
   if alWin32WindowProc<>0 then begin
      xCompileError2('<function win32windowproc,...>: This function shall be called ' +
         'by Windows default window procedure and can only be defined at one place ' +
         'but an additional definition was found.');
      end
   else alWin32WindowProc:= pn;
   end;

// 3. Check number range
if not ( (pn>=1) and (pn<=xmaxfuncnr+xmaxlocvarnr) ) then begin
    xProgramError(
   'xdefine('+pname+'): X program error - number ('+inttostr(pn)+
   ') not within 1..'+inttostr(xmaxfuncnr+xmaxlocvarnr)+'.');
    end

else if functab[pn].defined then begin

   // 4. Handle update of already defined name
   (* Note: xdefine can be used to change min number of parameters to
      an already defined macro. *)
   if functab[pn].name=pname
      then begin
      functab[pn].parmin:= pparmin;
      functab[pn].parmax:= pparmax;
      functab[pn].extraCond:= pExtraCond;
      if pspecial<>functab[pn].special then begin
         // Diagnostic check:
         if (pspecial=dsnone) and (functab[pn].special=dspreldef) then
            // (ok)
            functab[pn].special:= pspecial
         else
            // (bad)
            xProgramError('xdefine: X program error - special field same or changed '+
               'from preldef to none was expected, but old special was '+
               inttostr(integer(functab[pn].special))+' and new was '+
               inttostr(integer(pspecial))+'.');
         end
      end
   else xProgramError(
      'xdefine: X program error - nr '+inttostr(pn)+' is already used.');
   end

else begin

   // 5. Handle creation of new entry in functab.
   functab[pn].name:= pname;
   functab[pn].index:= ix;
   functab[pn].next:= funcindex[ix];
   funcindex[ix]:= pn;
   functab[pn].defined:= true;
   functab[pn].special:= pspecial;
   functab[pn].parmin:= pparmin;
   functab[pn].parmax:= pparmax;
   functab[pn].extraCond:= pExtraCond;
   functab[pn].definedin:= xcurrentgroupnr;
   functab[pn].importedTo:= nil;
   functab[pn].argNameIndex:= 0;
   functab[pn].argNameCount:= 0;
   if (xcurrentgroupnr=0) and (pn>xLastPredefinedFuncNr) then
      xLastPredefinedFuncNr:= pn;
   end;

end; (*xdefine*)


procedure xDefineParMinMax(pn: xint16; pparmin,pparmax: xint16);
(* Change only parmin and parmax of already defined function.
   Used by aldef which scan's for $-signs as it copies the function
   to the table. Parmin parmax shall be updated to lowest and highest
   $n if no other info given. *)
begin

if functab[pn].defined then begin
   functab[pn].parmin:= pparmin;
   functab[pn].parmax:= pparmax;
   end
else xProgramError('xDefineParMinMax: X program error - A defined functab entry was '+
   ' expected, but entry nr ' + inttostr(pn)+' is not defined.');

end; (*xDefineParMinMax*)

procedure xdefinepdf(pname: string; pn: xint16; pparmin,pparmax: xint16;
   pExtraCond: xExtraConditionType = xNoCond
   );
(*******************)
(* Define predefined function. Simpler version of xdefine.
   Usage example: xdefinepdf('ifeq',6,3,4);
  (define function ifeq as number 6 and with 3 to 4 parameters.)
*)
var error: boolean;

begin

xdefine(pname,pparmin,pparmax,pExtraCond,dsnone,pn);
if xCompileErrorActive then
   xProgramError('X(xdefinepdf): X program error - Unexpected name conflict with predefined ' +
      'function ' + pname + '.');
end;(*xdefinepdf*)

procedure xDefineArgNames(pn: xint16; pnames: string);
(*******************)
(* Define argument names that can be used in the code to check
   that commas are correctly placed in the call, using {argname:}.
   Examples:
   xdefineArgNames(59,'then else');
   xdefineArgNames(151,'then elseif/even then/odd else');
   *)
var
blankpos,slashpos,count: integer;
argname,option: string;
begin

blankpos:= 1; // Dummy not to brake while loop
count:= 0;
while blankpos>0 do begin
   blankpos:= pos(' ',pnames);
   if blankPos>0 then begin
      argname:= copy(pnames,1,blankpos-1);
      pnames:= copy(pnames,blankpos+1,length(pnames)-blankpos);
      end
   else argname:= pnames;

   if length(argname)>0 then begin
      count:= count+1;
      // Handle /odd and /even
      slashpos:= pos('/',argname);
      if slashpos>0 then begin
         option:= copy(argname,slashpos+1,length(argname)-slashpos);
         argname:= copy(argname,1,slashpos-1);
         end
      else option:= '';
      // Save arg name
      argNameTab[argNameLast+count].name:= argname;
      if option='' then argNameTab[argNameLast+count].option:= none
      else if option='even' then argNameTab[argNameLast+count].option:= argEven
      else if option='odd' then argNameTab[argNameLast+count].option:= argOdd
      else if option='last' then argNameTab[argNameLast+count].option:= argLast
      else xprogramerror('xdefineArgNames('+inttostr(pn)+'): Option "even" or "odd" was expected but "' +
         option + '" was found.');

      end;

   end; // (while)

if count>0 then begin
   funcTab[pn].argNameIndex:= argNameLast+1;
   funcTab[pn].argNameCount:= count;
   argNameLast:= argNameLast+count;
   end;

end;(*xDefineArgNames*)


procedure xDefineNormalVariable(pname: string; var pn: xint16; var pindex: boolean);
(* Define normal (resident) variable. Simpler version of xdefine.
   Return pindex=true if pname ends with '[]'.
   Usage example: xdefineVariable('a',varnr,pfel);
   if not pfel then
      fsrewrite(mactab[varnr]);
      ...
*)

begin
   pn:= 0; // Let xdefine get the number
   if ansiendstext('[]',pname) then begin
      xdefine(ansileftstr(pname,length(pname)-2),0,1,xNoCond,dsvar,pn);
      pindex:= true;
      end
   else begin
      xdefine(pname,0,0,xNoCond,dsvar,pn);
      pindex:= false;
      end;

end;(*xDefineNormalVariable*)

procedure xDefineLocalVariable(pname: string; pn: xint16);
(* Define local variable. Simpler version of xdefine.
   Usage example: xdefineLocalVariable(arg1,xMaxFuncNr + locVarCount);
*)

begin
   if pn<=xmaxfuncnr then
      xProgramError('X(xDefineLocalVariable): Program error in X - number above ' +
         'xmaxfuncnr was expected but '+inttostr(pn) + ' was found.');

   xdefine(pname,0,0,xNoCond,dsvar,pn);
end;(*xDefineLocalVariable*)


procedure xDefineFunction(pname: string; pparmin,pparmax: xint16;
   pExtraCond: xExtraConditionType;
   pprel: boolean; var pn: xint16; var perror: boolean);
(* Define a function in functab. Simpler version of xdefine.
   Note that a function definition can be a redefinition of
   a preliminary defined function. xDefineFunction shall return the
   proper function nr (new or old) so that aldef can put the
   macro string in the correct slot in mactab.
   Usage example: xdefinefunction('f',159,funcnr,pfel);
   if pfel then ...
*)
begin
   pn:= 0;
   if pprel then xdefine(pname,pparmin,pparmax,pExtraCond,dspreldef,pn)
   else xdefine(pname,pparmin,pparmax,pExtraCond,dsnone,pn)
end; (*xDefineFunction*)




function xgetfilenr(pname: string): integer;
(* Return the nr associated with a certain file groupname. *)
var found: integer; groupnr: integer;
begin
found:= 0;
xlowercase(pname);
groupnr:= xhashgroup(pname,a_file);
while (found=0) and (groupnr<>0) do begin
   if grouptab[groupnr].name=pname then
      found:= groupnr
   else groupnr:= grouptab[groupnr].next;
   end;

xgetfilenr:= found;
end; (*xgetfilenr*)


function xgetcurrentxfile: integer;
var filenr: integer; found: boolean;
begin
filenr:= xcurrentgroupnr;

while (filenr<>0) and not found do begin
   if grouptab[filenr].kind=a_file then found:= true
   else filenr:= grouptab[filenr].definedIn;
   end;
xgetcurrentxfile:= filenr;
end;

function xgetcurrentfilename: string;
var filenr: integer; found: boolean;
begin
filenr:= xcurrentgroupnr;
while (filenr<>0) and not found do begin
   if grouptab[filenr].kind=a_file then found:= true
   else filenr:= grouptab[filenr].definedIn;
   end;
if filenr<>0 then xgetcurrentfilename:= grouptab[filenr].name
else xgetcurrentfilename:= '';
end;



FUNCTION xGetNr(pfilenr: xint16; var pname: string): xint16;
(**************)
(* Get number of function pname defined in file pfilenr. Return 0 if not found.
   Local names are disregarded. Function is used by ximport to find the
   imported names. *)
var found,count: xint16; i: xint16; name: string; ch: char;
charSum,ix: integer;

begin (*xGetNr*)

(* convert to lower case and calculate sum of characters *)
charsum:= 0;
name:= '';
for i:= 1 to length(pname) do begin
    ch:= pname[i];
    if ord(ch) < ord('a') then xgemen(ch);
    name:= name + ch;
    charsum:= charsum + integer(ch);
    end;

found:= 0;
count:= 0;
ix:= charsum mod xmaxfuncnr;
i:= funcindex[ix];
while not (i=0) do begin
    if (functab[i].definedIn=pfilenr)
      and (functab[i].name = name) then begin
        count:= count+1;
        if count=1 then found:= i;
        end;

    i:= functab[i].next;
    end;

(* Diagnostic: *)
if count>1 then begin
    xProgramError('X(xgetNr): Program error - name '+pname
    +' is inconsistent (doubly defined in the same file).');
    xCompileErrorActive:= True;
    end;

xGetNr:= found;

end; (*xGetNr*)

var
xgetLocalnrgroupname: string;
xgetLocalnrfuncname: string;

(* (new: Loops over group until found or group=0. *)
FUNCTION xgetLocalnr(var pname: string): xint16;
(**********************)
(* If pname is expressed as "groupname.funcname" then temporarily change
   group to groupname and search for number of funcname,
   otherwise return 0 or -1. -1 is used when the group is being loaded,
   and can be used to print an error message including this information.
*)
var
groupname: string;
funcname: string;
i,j,nr,statenr,savestate: xint16;
filenr: integer;
ch: char;
charsum: integer;
name: string;
startix: integer;
found,count: integer;
group: integer;
len: integer;
level: integer;
savegroup: integer;

// Allowednames:
allowedNames, aname: string;
allowedNamesSize: integer;
allowed: boolean;
delimpos, newsize: integer;


begin

nr:= 0;

i:= 1;
len:= length(pname);
groupname:= '';
funcname:= '';

if len>0 then begin
   (* 1. Separate pname into groupname and funcname. *)
   while not ((i=len) or (pname[i]='.')) do i:= i+1;
   if pname[i]= '.' then begin
      groupname:= '';
      for j:= 1 to i-1 do groupname:= groupname + pname[j];
      for j:= i+1 to len do funcname:= funcname + pname[j];
      xgetLocalnrgroupname:= groupname;
      xgetLocalnrfuncname:= funcname;

      (* 2. Find the start index number for funcname. *)
      charsum:= 0;
      name:= '';
      for i:= 1 to length(funcname) do begin
         ch:= funcname[i];
         if ord(ch) < ord('a') then xgemen(ch);
         name:= name + ch;
         charsum:= charsum + integer(ch);
         end;
      startix:= charsum mod xmaxfuncnr;

      // Try all levels (see xGetVisibleGroup): 1=substate, 2=state, 3=group, 4=file.
      level:= 1;
      nr:= 0;

      (* Same name can be used on different group levels. Start with the lowest level. *)
      group:= xGetVisibleGroup(groupname,level);

      while not ((nr>0) or (level>4) ) do begin

         nr:= -1; (* = Not found in group groupname*)

         (* 3. Look through all occurrences of funcname in functab. *)
         found:= 0;
         count:= 0;
         i:= funcindex[startix];
         while not (i=0) do begin
            if (functab[i].name = name) then begin
               if functab[i].definedIn = group then begin
                  (* Found!. *)
                  count:= count+1;
                  if count=1 then found:= i;
                  end
               end;

            i:= functab[i].next;
            end;(*while not i=0*)

         if found=0 then begin

            (* BFn 2016: If group is visible then xcurrentgroup should probably be
               set to group before looking for e.g a state in the group, because
               this state is only visible from inside the group.
               For example: <load testgroups1_1> and then $group1.test2.a is not
               found to be visible. *)
            // Testing
            savegroup:= xcurrentgroupnr;
            xcurrentgroupnr:= group;
            nr:= xGetLocalNr(funcname);
            xcurrentgroupnr:= savegroup;

            if (nr=0) and grouptab[group].loading then nr:= -1;
            end

         else begin
            (* found/=0 - funcname is defined (at top level) in group.
               if level=4 then groupname is a file and funcname is a name
               in functab that is defined (on top level) in this file.
               If reference is from another file (not x window) then it shall
               also be checked that funcname is among the allowed ones. *)
            if count>1 then xScriptError('X(getlocalnr): The name ' + groupname + '.' +
               funcname + ' is ambiguouos. It exists at more than one place in ' +
               'the code.');
            nr:= found;
            if (level=4) and (xcurrentgroupnr<>1) then begin
               (* Name is on top level i a file and reference not from x window:
                  Check if there are limits to access. *)
               if grouptab[group].usageNames<>nil then begin
                  (* Compare name with all names in the |-separated list.
                     Deny access if not found. *)
                  allowedNames:= fstostr(grouptab[group].usageNames);
                  allowedNamesSize:= length(allowedNames);
                  allowed:= false;
                  while not (allowed or (allowedNamesSize=0)) do begin
                     delimpos:= pos('|',allowedNames);
                     if delimpos>0 then begin
                        aname:= leftStr(allowedNames,delimpos-1);
                        newSize:=allowedNamesSize-delimpos;
                        allowedNames:= rightStr(allowedNames,newSize);
                        allowedNamesSize:= newSize;
                        end
                     else begin
                        aname:= allowedNames;
                        allowedNames:= '';
                        allowedNamesSize:= 0;
                        end;
                     if compareText(name,aname)=0 then allowed:= true;
                     end;
                  // Reject if the name was not in the list.
                  if not allowed then begin
                     nr:= 0;
                     xScriptError('X(getlocalnr): ' + groupname + '.' + funcname +
                        ' was referenced, but ' + funcname + ' was not in the usage-list: "' +
                        fstostr(grouptab[group].usageNames) + '".');
                     end;
                  end;// usageNames<>nil
               end;

            end;

         if nr<1 then begin
            (* if group was found, but not name, and file level (4) is not reached,
               then try on a higher group level. *)
            if level<4 then begin
               level:= level+1;
               group:= xGetVisibleGroup(groupname,level);
               end
            else if level=4 then level:= level+1;
            end;

         end; // while not (nr>0 or level>4)
         
      end;// '.' was found
   end; // len>0

xGetLocalNr:= nr;

end; (*xgetLocalNr*)


(* (old: Could not find $config.system, because config.x contained a state named config.
   and when failing to find $system there, it did not proceed to higher level (file).
   (BFn 2019-02-18) *)
FUNCTION xgetLocalnr0(var pname: string): xint16;
(**********************)
(* If pname is expressed as "groupname.funcname" then temporarily change
   group to groupname and search for number of funcname,
   otherwise return 0 or -1. -1 is used when the group is being loaded,
   and can be used to print an error message including this information.
*)
var
groupname: string;
funcname: string;
i,j,nr,statenr,savestate: xint16;
filenr: integer;
ch: char;
charsum: integer;
name: string;
ix: integer;
found,count: integer;
group: integer;
len: integer;
level: integer;
savegroup: integer;

// Allowednames:
allowedNames, aname: string;
allowedNamesSize: integer;
allowed: boolean;
delimpos, newsize: integer;


begin

nr:= 0;

i:= 1;
len:= length(pname);
groupname:= '';
funcname:= '';

if len>0 then begin
   (* 1. Separate pname into groupname and funcname. *)
   while not ((i=len) or (pname[i]='.')) do i:= i+1;
   if pname[i]= '.' then begin
      groupname:= '';
      for j:= 1 to i-1 do groupname:= groupname + pname[j];
      for j:= i+1 to len do funcname:= funcname + pname[j];
      xgetLocalnrgroupname:= groupname;
      xgetLocalnrfuncname:= funcname;

      // Try all levels (see xGetVisibleGroup): 1=substate, 2=state, 3=group, 4=file.
      // (old:) level:= 1;
      nr:= 0;

      group:= xGetVisibleGroup(groupname,level);

      if group>0 then begin

         nr:= -1; (* = Not found in group groupname*)

         (* 2. Find the index number for funcname. *)
         charsum:= 0;
         name:= '';
         for i:= 1 to length(funcname) do begin
            ch:= funcname[i];
            if ord(ch) < ord('a') then xgemen(ch);
            name:= name + ch;
            charsum:= charsum + integer(ch);
            end;
         ix:= charsum mod xmaxfuncnr;

         (* 3. Look through all occurrences of funcname in functab. *)
         found:= 0;
         count:= 0;
         i:= funcindex[ix];
         while not (i=0) do begin
            if (functab[i].name = name) then begin
               if functab[i].definedIn = group then begin
                  (* Found!. *)
                  count:= count+1;
                  if count=1 then found:= i;
                  end
               end;

            i:= functab[i].next;
            end;(*while not i=0*)

         if found=0 then begin

            (* BFn 2016: If group is visible then xcurrentgroup should probably be
               set to group before looking for e.g a state in the group, because
               this state is only visible from inside the group.
               For example: <load testgroups1_1> and then $group1.test2.a is not
               found to be visible. *)
            // Testing
            savegroup:= xcurrentgroupnr;
            xcurrentgroupnr:= group;
            nr:= xGetLocalNr(funcname);
            xcurrentgroupnr:= savegroup;

            if (nr=0) and grouptab[group].loading then nr:= -1;
            end

         else begin
            (* found/=0 - funcname is defined (at top level) in group.
               if level=4 then groupname is a file and funcname is a name
               in functab that is defined (on top level) in this file.
               If reference is from another file (not x window) then it shall
               also be checked that funcname is among the allowed ones. *)
            if count>1 then xScriptError('X(getlocalnr): The name ' + groupname + '.' +
               funcname + ' is ambiguouos. It exists at more than one place in ' +
               'the code.');
            nr:= found;
            if (level=4) and (xcurrentgroupnr<>1) then begin
               (* Name is on top level i a file and reference not from x window:
                  Check if there are limits to access. *)
               if grouptab[group].usageNames<>nil then begin
                  (* Compare name with all names in the |-separated list.
                     Deny access if not found. *)
                  allowedNames:= fstostr(grouptab[group].usageNames);
                  allowedNamesSize:= length(allowedNames);
                  allowed:= false;
                  while not (allowed or (allowedNamesSize=0)) do begin
                     delimpos:= pos('|',allowedNames);
                     if delimpos>0 then begin
                        aname:= leftStr(allowedNames,delimpos-1);
                        newSize:=allowedNamesSize-delimpos;
                        allowedNames:= rightStr(allowedNames,newSize);
                        allowedNamesSize:= newSize;
                        end
                     else begin
                        aname:= allowedNames;
                        allowedNames:= '';
                        allowedNamesSize:= 0;
                        end;
                     if compareText(name,aname)=0 then allowed:= true;
                     end;
                  // Reject if the name was not in the list.
                  if not allowed then begin
                     nr:= 0;
                     xScriptError('X(getlocalnr): ' + groupname + '.' + funcname +
                        ' was referenced, but ' + funcname + ' was not in the usage-list: "' +
                        fstostr(grouptab[group].usageNames) + '".');
                     end;
                  end;// usageNames<>nil
               end;

            end;

         end; // groupnr>0

      end;// '.' was found
   end; // len>0

xGetLocalNr0:= nr;

end; (*xgetLocalNr0*)


function xgetvisiblenr(pname: string): integer;
(********************)
(* Lookup pname in functab. If name is visible in xcurrentgroup return its
   number, else return 0. Print error message if pname is multiply visible.
 *)

var
funcnr1,funcnr2: integer;
count: integer;
name: string;
charsum: integer;
ch: char;
i,ix,next: integer;
definedin: integer;
impnext: fsptr;

procedure hit;
begin
count:= count+1;
if funcnr1=0 then funcnr1:= i
else if funcnr2=0 then funcnr2:= i;
end;

begin

funcnr1:= 0;
funcnr2:= 0;
name:= '';
count:= 0;

(* convert to lowercase and create hashed index. *)
charsum:= 0;
for i:= 1 to length(pname) do begin
   ch:= pname[i];
   if ord(ch) < ord('a') then xgemen(ch);
   name:= name+ch;
   charsum:= charsum + integer(ch);
   end;

ix:= charsum mod xmaxfuncnr;
i:= funcindex[ix];
while (* removed to count hits:(funcnr=0)and *)(i<>0) do begin
   if (functab[i].name = name) then begin

      definedin:= functab[i].definedin;

      // predefined functions are visible everywhere
      if definedIn = 0 then hit
      else begin

         // See if defined in or imported in current or parent group
         next:= xcurrentgroupnr;

         while next<>0 do begin
            // variables and functions defined in current or parent group are visible
            if next = definedIn then hit
            else begin
               impnext:= functab[i].importedTo;
               while impnext<>nil do begin
                  if impnext^=eofs then impnext:= nil
                  else begin
                     // variables and functions imported to current or parent group are visible
                     if integer(impnext^)=next then hit;
                        // (skip to count)begin ... impnext:= nil; end // stop search
                     fsforward(impnext);
                     end;
                  end;(*while*)
               end;
            next:= grouptab[next].definedIn;
            end;(*while*)

         // Names defined on top level of loaded files are visible in x-window (1)
         if (xcurrentgroupnr=1)
            and (grouptab[definedIn].definedIn=xcurrentgroupnr)
            and (grouptab[definedIn].topLoad)
            then hit;
         end;(*else*)
      end;(*functab[i].name=name*)
      i:= functab[i].next;
   end;(*while*)

   if count>1 then begin

      // Allow range and do to be redefined because they are widely used in old code
      if (functab[funcnr1].definedIn=0) and ( (funcnr1=alRangeFuncnr) or (funcnr1=alDoFuncnr) ) then
         // Select the user defined version.
         funcnr1:= funcnr2
      else if (functab[funcnr2].definedIn=0) and ( (funcnr2=alRangeFuncnr) or
         (funcnr2=alDoFuncnr) ) then begin
         // Select the user defined version
         // Nonsense code allow setting breakpoint
         if funcnr1=funcnr2 then funcnr1:= funcnr2;
         end

      else if xcurrentgroupnr=1 then
         // we are in xwindow
         xScriptError('Name ' + pname + ' is ambiguous (it is available both from ' +
         grouptab[functab[funcnr1].definedIn].name + ' and from ' +
         grouptab[functab[funcnr2].definedIn].name + '). Use dot-notation (xxx.yyy.zzz) '+
         'to specify which one you want to refer to.')
      else begin
         // it must be an error in x (multiple visibility shall not be possible in X)
         xProgramError('xgetvisiblenr: Program error in X - Name ' + pname +
            ' is ambiguous (it is available both from ' +
            grouptab[functab[funcnr1].definedIn].name + ' and from ' +
            grouptab[functab[funcnr2].definedIn].name + ').');
         end;
      end;

   xgetvisiblenr:= funcnr1;

end; (*xgetvisiblenr*)


procedure xSetUsage(ps: fsptr);
(* Set allowed external usage of variables and functions in the currently compiled file.
   ps = NIL: No checking of references.
   ps = empty string: No external references to this script allowed.
   ps = "name1|name2|...": External references to this script limited to name1,
      name2, ....
   *)
var filegroupnr: integer;

begin

fileGroupNr:= xcurrentgroupnr;
while not (grouptab[fileGroupNr].kind = a_file) do
   filegroupnr:= grouptab[fileGroupNr].definedIn;

if ps=nil then begin
   // Erase usageNames
   if grouptab[fileGroupNr].usageNames<>nil then
      fsdispose(grouptab[fileGroupNr].usageNames);
   end
else begin
   // Define usageNames for this file
   if grouptab[fileGroupNr].usageNames = nil then
      fsnew(grouptab[fileGroupNr].usageNames);
   fscopy(ps,grouptab[fileGroupNr].usageNames,eofs);
   end;

end; (* xSetUsage *)

function xUserdefined(pname: string): boolean;
(* See if a name is a userdefined function. Used to print warning
   message after script error. *)
var nr: integer;
userdefined: boolean;
begin

nr:= xgetVisiblenr(pname);
userdefined:= false;

if nr>0 then if functab[nr].definedin>0 then userdefined:= true;

xUserDefined:= userdefined;

end; (* xUserDefined*)



function xgroupname(pgroupnr: integer): string;
begin
xgroupname:= grouptab[pgroupnr].name;
end;

procedure ximport(pfile: xint16; pname: string);
(*********)
(* Import pfile:pname to the currently compiled xfile.
   Check first that pname is defined in pfile.
   Used by alload to make names arg2... visible, after
   having called xLoad. *)

var imp: fsptr; curfile,nr: integer;

begin

nr:= 0; // (to please compiler)

(* Ignore if xCompileErrorActive already. *)
if xCompileErrorActive then
    (* - *)

(* Check that <load ...> was called from file. *)
else if grouptab[xcurrentgroupnr].kind<>a_file then begin
    xCompileError2(
'X(<load ...>): parameters 2.. are only meaningful when load is called from a file.'
    );
    end

(* 2. Check that pname is defined in current xfile. *)
else begin

   nr:= xGetNr(pfile,pname);
   if nr=0 then
      xCompileError2('X(<load '+grouptab[pfile].name+',...,'+pname+',...>): parameter '+
         pname+' is not defined,  or is local to a group or a state,'+
         ' in the loaded file ('+grouptab[pfile].name+').');
   end;

if not xCompileErrorActive and (xcurrentgroupnr>1) then begin
   (* Find current x-file . *)
    (* Add current file to list of imported to file numbers. *)
    curfile:= xgetcurrentxfile;
    with functab[nr] do begin
        if importedto=nil then fsnew(importedto);
        imp:= importedto;
        while (imp^<>char(curfile)) and (imp^<>eofs) do fsforward(imp);
        if imp^<>char(curfile) then fspshend(imp,char(curfile));
        end;
    end;

end; (*ximport*)


procedure ximportnr(pnr: integer);
(*********)
(* Import variable or function pnr to the currently compiled xfile.
   Used by <useShortNameFor ...> to make variables and functions
   visible through short names (like <name ...> or $name). *)

var imp: fsptr; curfile: integer;

begin

(* Ignore if xCompileErrorActive already. *)
if xCompileErrorActive then
    (* - *)
else begin
   (* (copied from xImport:) *)
   (* Find current x-file . *)
   (* Add current file to list of imported to file numbers. *)
   curfile:= xgetcurrentxfile;
   with functab[pnr] do begin
      if importedto=nil then fsnew(importedto);
      imp:= importedto;
      while (imp^<>char(curfile)) and (imp^<>eofs) do fsforward(imp);
      if imp^<>char(curfile) then fspshend(imp,char(curfile));
      end;
   end;

end; (*ximportnr*)


type
nrlist=array[1..10] of xint16;

function ximportedTo(pname: string ): nrList;
(*******************)
(* Diagnostic function. Return the nr of the file(s) where pname is imported. *)

var i: xint16; name: string; ch: char;
charsum,ix: integer; imp: fsptr; nr: xint16;
list:nrlist;

begin

for nr:= 1 to 10 do list[nr]:= 0;
nr:= 0;

(* convert to lowercase *)
charsum:= 0;
name:= '';
for i:= 1 to length(pname) do begin
   ch:= pname[i];
   if ord(ch) < ord('a') then xgemen(ch);
   name[i]:= ch;
   charsum:= charsum + integer(ch);
   end;

ix:= charsum mod xmaxfuncnr;
i:= funcindex[ix];
while not (i=0) do begin
    if (functab[i].name = name) and (functab[i].importedTo<>NIL) then begin
       imp:= functab[i].importedTo;
       while not (imp^=eofs) do begin
           nr:= nr+1;
           if nr<=10 then list[nr]:= integer(imp^);
           fsforward(imp);
           end;
       end; (* name fits and importedTo<>nil *)

    i:= functab[i].next;
    end;

xImportedTo:= list;

end; (*xImportedTo*)


function xdefinedin(pname: string ): nrList;
(**************)
(* Diagnostic function. Return the nr of the file(s) where pname is defined. *)

var i: xint16; name: string; ch: char;
charsum,ix: integer; nr: xint16;
list:nrlist;

begin

for nr:= 1 to 10 do list[nr]:= 0;
nr:= 0;

(* convert to lower case *)
charsum:= 0;
name:= '';
for i:= 1 to length(pname) do begin
    ch:= pname[i];
    if ord(ch) < ord('a') then xgemen(ch);
    name:= name + ch;
    charsum:= charsum + integer(ch);
    end;

ix:= charsum mod xmaxfuncnr;
i:= funcindex[ix];
while not (i=0) do begin
    if (functab[i].name = name) then begin
        nr:= nr+1;
        if nr<=10 then list[nr]:= functab[i].definedin;
        end;
    i:= functab[i].next;
    end;

xdefinedin:= list;

end; (*xdefinedin*)

FUNCTION xgetfreenr: xint16;
(******************)
(* Find a unused entry in functab, return its index (or 1
   + error message). *)
var i: xint16;

begin

i:= lastfree;

// Do not use numbers in 2..lastPredefinedFuncnr
if i<=xLastPredefinedFuncnr then begin
   i:= xLastPredefinedFuncnr+1;
   if lastFree<>2 then
      xProgramError('X Program error (xgetfreenr): lastfree=2 was expected but '+
         inttostr(lastfree)+' was found (exits).');
   end;

while functab[i].defined and (i<xmaxfuncnr) do i:= i+1;
lastfree:= i;
xgetfreenr:= i;

if functab[i].defined then begin
   xCompileError2('xgetfreenr: Error - table full (too many <def ...>''s).');
   xgetfreenr:= 1;
   end;

end; (*xgetfreenr*)


function xname(pn: xint16): string;
(* Return name of function pn *)
begin (*xname*)
if pn>xmaxfuncnr then
   xname:= '(local variable '+inttostr(pn-xmaxfuncnr)+')'
else xname:= functab[pn].name;
end; (*xname*)


const maxarglen = 62500; (* 250*250 *)

var
functionlevel: integer = 0;
indentlevel: integer = 0;

// For local variables (compilation):
inFunction: boolean = false;
locVarCount: integer = 0;


procedure xcompilestring( pin,put: fsptr; pendch: char; pncallallowed: boolean;
                          pfilename: fsptr; plinenr1,plinenr2: integer );
(*********************)

(* Format in:

   ...<name a1,a2,...>...$name...

Format out:

   ...|stan|nr|narg|la1(1)|la1(2)|...a1...|eoa|...|lan(1)|lan(2)|...an...|eoa|ra1|ra2|...|nul|...

or, if narg=0 ($funcname or <varname>):

   ...|stan|nr|nul|...

or, if nr>=250:

   ...|stan|0|nr1|nr2|narg|la1(1)|la1(2)|...a1...|eoa|...|lan(1)|lan(2)|...an...|eoa|ra1|ra2|...|nul|...

or, if narg=0 and nr>=250 ($varname or <funcname>):

   ...|stan|0|nr1|nr2|nul|...

or, if nr>xmaxnarg ($varname - local variable reference):

   ...|stan|0|nr1|nr2|nlev|nul|...

where,
     stan     =  char(253)
     nr       =  function-nr <250(decoded name)
     nr1*250+nr2 = function-nr >=250
     narg     =  number of arguments
     la1(1)*250+la1(2)  =  length of argument 1 (possibly length div 16)
     ...a1... =  argument 1
     eoa      =  control-character for end-of-argument
     ra1      =  Recursive argument 1 (1..narg)
     nlev     =  nesting level. Initially 0. When fylli copies the string, it is
                 set to the current nesting level. Used to get correct offset for
                 evaluation of local variables references.
     nul      =  ascii NUL

   Nr, narg, lan  och  ran are binary (byte).

   Ra1..ran are numbers of the arguments which themselves contain calls.
   This is so that arguments which do not contain calls shall not need to
   be evaluated. The sequence is terminated by NUL.

   Ra1...nul are only inclúded if the call has arguments (narg>0).

   if name = "set", "pop" or "foreach" then A1 is compiled to a binary number (the
   number of the macro to be set). If the binary number is <=249, it is coded as
   one byte: 1..249. If > 249 it is coded as three bytes: 0, 0..249 (nr/250),
   0..249 (nr mod 250).
   If name = "set" and the variable is a local variable (nr>xmaxfuncnr)
   then an empty byte (0) is added. This byte will later be used
   if the <set ...> call is later inserted in a macro (in $n) and used
   to ensure that the local variable will be evaluated in the context
   (offset) in which it was compiled.

   <set $name[ix],str> is compiled as <set $binnr,index,str>

   $name[index] is compiled as: <name index>. Index references are
   recognised by having string pointers (mactab[n]) containing a low
   number (<=alIndexMaxNr) instead of a pointer to an fs string.
   A pointer to an fs string is always a high number because the
   bottom of the memory in Win32 is not available for application program
   variables.

   <var $name> and <var $name,arg1> are compiled as a normal function calls
   ($name is representedas a string). If on top level, it will directly be
   evaluated and create a variable. If in a function body, a temporary local
   variable is created after it is compiled. If the function later is evaluated,
   then each call to <var ...> increments a local variable counter and,
   if there is an argument, initialises the corresponding local variable.

*)

var ch: char; citation: boolean;
putspar: fsptr;
PI,PU: fsptr; c1,c2,c3: char; dmess: shortstring; (* Debug *)


procedure compilecall; forward;

procedure compiledollarvariable;

(* '$' just read. Compile $name or $name[index]. *)

var state: (s1,s2,s3); ch: char; nlen: xint16;
varname: string;
varnr: xint16;
npos,lpos,lpos2: fsptr;
recursivetab: array[1..xmaxnarg] OF boolean;
alen: xint16;
kalklen: xint16;
n: integer;

begin

// 0. Start variable reference ("function call")
fspshend(put,stan);

state:= s1;
nlen:= 0;
varname:= '';
varnr:= 0; lpos:= nil; npos:= nil;// (to please compiler)
citation:= false;

while not ((pin^=pendch) or (state=s3) or xCompileErrorActive) do begin

   ch:= pin^;
   fsforward(pin);

   case state of

      s1: begin
         (* 1. Read variable or index name *)
         varname:= varname + ch;
         if pin^ in xidcharrange then
            // Stay in s1
         else if pin^='.' then begin
            // If dot-notation then stay in s1, else finished (s3)
            fsforward(pin);
            if not (pin^ in xidcharrange) then state:= s3;
            fsback(pin);
            end
         else if pin^='[' then begin
            // (skip '[' and go to reading of index)
            fsforward(pin);
            state:= s2;
            end
         else
            // finished
            state:= s3;

         if state<>s1 then begin

            // 2. Decode variable name.
            varnr:= xgetvisiblenr(varname);
            if varnr=0 then varnr:= xGetLocalnr(varname);

            if varnr<=0 then begin
               if varnr=0 then begin
                  xCompileError2('X: Variable name "'+varname+'" is not defined. Cannot be used.');
                  end
               else
                  // (<0)
                  xCompileError3('X: Variable name "'+varname+'" is not defined. Cannot be used. '#13'The reason could be that '+
                     xgetlocalnrGroupName+ '.x is in the process of being loaded.'#13' Check that '+xgetlocalnrfuncname+
                     ' is defined in '+xgetlocalnrGroupname+'.x and, if it is, insert <preldef '+xgetlocalnrfuncname+
                     '> just before '#13'<load '+fstostr(xcompilefilename)+'> to enable '+varname+' to be found by the X compiler.');
               varnr:= 1; (* 1 shall be reserved for undefined functions *)
               end
            else if (functab[varnr].special<>dsvar) then begin
               xCompileError2('X: $'+varname+' was referenced but '+varname+' was found to be a function. '+
                  'Only variables can be referenced with $name.');
               varnr:= 1; (* 1 shall be reserved for undefined functions *)
               end;

            // 3. Write function number (long or short).
            if varnr>xmaxshortnr then begin
               fspshend(put,char(0));
               fspshend(put,char(varnr div 250));
               fspshend(put,char(varnr mod 250));

               if varnr>xmaxfuncnr then
                  // Local variable - add nesting level (see xargblock for info)
                  // (new:)
                  fspshend(put,char(0));
                  // (old:)fspshend(put,char(xCurrentLocVarLevel));
               end
            else
               fspshend(put,char(varnr));

            // 4. Number of arguments, initially 0
            npos:= put;
            fspshend(put,char(0));

            // 5. If index - prepare for length and increment narg
            if state=s2 then begin
               npos^:= char(1);
               recursivetab[1]:= false;
               lpos:= put;
               fspshend(put,char(0));
               lpos2:= put;
               fspshend(put,char(0));
               end;
            end;(*state<>s1*)

         end;(*s1*)

      s2: begin
         (* '[' just read. *)
         if (ch='''') and (pin^<>pendch) then begin
            citation:= true;
            ch:= pin^;
            fsforward(pin);
            end
         else citation:= FALSE;

         if (ch='<') and not citation then begin
            compilecall;
            recursivetab[integer(npos^)]:= true;
            end
         // Compile $name as a variable reference
         else if (ch='$') and not citation and (pin^ in xidchar1range)
            then begin
            compileDollarVariable;
            recursivetab[integer(npos^)]:= true;
            end
         else if (ch<>']') and (ch<>',') or citation then
            fspshend(put,ch)

         else begin
            (* (ch=']' or ',')  and not citation *)
            // End of argument.

            (* 6. Complete argument by filling in length in lpos and if needed
               add eoa's in order to comply with length code. End with eoa. *)
            // (new:)
            alen:= fsdistance(lpos,put)-2;
            // (old:) alen:= fsdistance(lpos,put)-1;
            if alen>maxarglen then begin
               xProgramError('X(xcompiledollarvariable): Program error - alen<='+inttostr(maxarglen) +
                  ' was expected, but ' + inttostr(alen) + ' was found.');
               xCompileErrorActive:= true;
               end
            // (new:)
            else begin
               lpos^:= char(alen div 250);
               lpos2^:= char(alen mod 250);
               end;
            (* (old:) lpos^:= xargkod(alen);
            kalklen:= xarglen(lpos^);
            while alen<kalklen do begin
               fspshend(put,eoa);
               alen:= alen + 1;
               end;*)
            fspshend(put,eoa);

            if ch=',' then begin
               (* New argument. *)
               if ord(npos^)>=xmaxnarg then xCompileError2(
                  'X (compiledollarvariable '+varname+
                  '): Too many arguments (max = '+inttostr(xmaxnarg)+').')
               else begin
                  npos^:= char(integer(npos^)+1);
                  recursivetab[ord(npos^)]:= false;
                  lpos:= put;
                  fspshend(put,char(0));
                  // (new:)
                  lpos2:= put;
                  fspshend(put,char(0));
                  end;
               end
            else begin
               (* ']' - end of index. *)
               for n:= 1 to integer(npos^) do if recursivetab[n] then
                  fspshend(put,char(n));
               fspshend(put,char(0));

               // Finished
               state:= s3;
               end;(*']'*)
            end;(* ']' or ',' and not citation *)
         end; (*s2*)
      end; (*case*)
   end; (*while*)

if xCompileErrorActive then (* - *)
else if state<>s3 then xCompileError2(
   'compiledollarvariable '+varname+': Error - index not terminated with "]".')
else if npos=nil then xCompileError2(
   'compiledollarvariable: Program error - '+
   'unable to find position for number of arguments (npos=NIL).')
else if ord(npos^) < functab[varnr].parmin  then xCompileError2(
   'compiledollarvariable '+varname+': too few parameters - '+inttostr(ord(npos^))
   +'(min '+inttostr(functab[varnr].parmin)+' expected).')
else if ord(npos^) > functab[varnr].parmax  then xCompileError2(
   'compiledollarvariable '+varname+': too many parameters - '+inttostr(ord(npos^))
   +'(max '+inttostr(functab[varnr].parmax)+' expected).')
else if functab[varnr].extraCond<>xNoCond then begin
   case functab[varnr].extraCond of
      xOddNarg:
         if not odd(ord(npos^)) then xCompileError2('compiledollarvariable '+
         varname+': Odd number of parameters was expected but '+
         inttostr(ord(npos^)) + ' parameters were found.');
      xEvenNarg:
         if odd(ord(npos^)) then xCompileError2('compiledollarvariable '+
         varname+': Even number of parameters was expected but '+
         inttostr(ord(npos^)) + ' parameters were found.');
      else ;
      end;
   end;

end; (*compiledollarvariable*)


var
tempStr: string;

procedure compilecall;

(* '<' just read. *)

var
state: (s1,s2,s3,s4);
ch: char; nlen: xint16;
funcname: string;
funcnr: xint16;
npos,lpos,lpos2,a1pos: fsptr;
rekursivtab: array[1..xmaxnarg] OF boolean;
n: xint16; citation: boolean;
alen: xint16;
kalklen: xint16;
callToSetAppend,calltosetpopforeach,calltovar,callToFunction: boolean;
CallToCJ: integer; // 0 = No, 1=C, 2=J, 3=C_lateevaluation
s: fsptr; i: xint16;
setpar: string;
setnr: xint16;
errfuncname: string;
list: nrlist; (* Debug *)
namecomplete: boolean;
groupnr: integer;
arg1,arg2: string; // For local variables
savelocvarcount: integer;
index,next: integer;
found: boolean;
readingindex: boolean;
argname: string;// for {name}
argNameIndex: integer;
savePin: ioinptr; // Storage for pin in case of rollback.

// For checking tags:
argNr,argIndex,argIndexLast,badNameIndex: integer;
tagfound,optfound: boolean;

function dstostr(pds: xDefineSpecialType): string;
begin
case pds of
   dsnone: dstostr:= 'function or def';
   dsvar: dstostr:= 'variable';
   dspreldef: dstostr:= 'preldef';
   end;
end;


begin

fspshend(put,stan);

state:= s1; ch:= 'x'; nlen:= 0;
funcname:= '';
funcnr:= 0; lpos:= nil; npos:= nil;// (to please compiler)
citation:= FALSE;
callToSetAppend:= False;
calltoSetpopforeach:= False;
calltovar:= False;
callToFunction:= False;
callToCj:= 0;
namecomplete:= False;
savelocvarcount:= locvarcount;
readingindex:= false;

while not ( ((ch='>') and not citation) or
  (pin^=pendch) or xCompileErrorActive ) do begin

   ch:= pin^;
   fsforward(pin);
   if (ch='''') and (pin^<>pendch) then begin
      citation:= true;
      ch:= pin^;
      fsforward(pin);
      end
   else citation:= FALSE;
   case state of

      s1: begin
         (* Reading function name *)
         (* Accept <name(newline)> as <name(space)(newline). *)
         if (citation or not ((ch='>') or (ch=' ') or (ch=ctrlM)))
         then begin
            (* Add character ch to function name. *)
            nlen:= nlen+1;
            if ord(ch) < ord('a') then xgemen(ch);
            if nlen<=64 then
               funcname:= funcname+ch
            else if nlen=65 then begin
               xCompileError2(
                  'X: Name starting with "'+funcname+'" is too long (>64 char''s).');
               end;
            end
         else begin
            (* End of function name. (ch='>' or ' ' or (CR)). *)
            if ch=ctrlM then begin
               (* Treat as blank and assume that the first char
                  of arg 1 is supposed to be (newline): *)
               ch:= ' ';
               fsback(pin);
               end;
            namecomplete:=True;
            end;

         if namecomplete then begin

            (* Decode function name. *)
            funcnr:= xGetVisibleNr(funcname);
            if funcnr=0 then begin
               funcnr:= xGetLocalnr(funcname);
               if funcnr<=0 then begin
                  if funcnr=0 then
                     xCompileError2('X: Function name "'+funcname+
                        '" is not defined. Cannot be used.')
                  else begin
                     // (<0)
                     if xCompilefilename<>nil then
                        tempStr:= fstostr(xcompilefilename)
                     else tempStr:= '';

                     xCompileError3('X: Function name "'+funcname+'" is not defined. '+
                        'Cannot be used.'#13'The reason could be that '+
                        xgetlocalnrGroupName+ '.x is in the process of being loaded.'#13''+
                        'Check that '+xgetlocalnrfuncname+' is defined in '+
                        xgetlocalnrGroupname+'.x and, if it is, insert <preldef '+
                        xgetlocalnrfuncname+'> just before '#13'<load '+
                        tempStr+'> to enable '+funcname+
                        ' to be found by the X compiler.');
                     end;
                  funcnr:= 1; (* 1 shall be reserved for undefined functions *)
                  end;
               end;

            if (funcnr>0) then begin
               if ch<>'>' then funcname:= funcname+'...';
               if functab[funcnr].special=dsvar then begin
                  xCompileError2('X: <'+funcname+'> was referenced but '+funcname+' was found to be a variable. '+
                     'Only functions (or def´s) can be referenced with <name ...>.');
                  funcnr:= 0;
                  end;
               // Restore funcname
               if ch<>'>' then funcname:= AnsiLeftStr(funcname,length(funcname)-3);
               end;

            (* Detect calls to <p n> (only valid in alt-out parts). *)
            if ((funcnr=alPfuncnr) or (funcnr=alPdecfuncnr)) and not pncallallowed then begin
               if funcnr = alpdecfuncnr then xCompileError2('X: Unexpected call to <pdec n>. '+
                  '<pdec n> is only valid in an alternative (?"..."? !"..."!). '+
                  'Use <sp n> instead if state parameter is intended.')
               else xCompileError2('X: Unexpected call to <p n>. '+
                  '<p n> is only valid in an alternative (?"..."? !"..."!). '+
                  'Use <sp n> instead if state parameter is intended.');
               end;

            (* Write function number (long or short) . *)
            if funcnr>xmaxshortnr then begin
               fspshend(put,char(0));
               fspshend(put,char(funcnr div 250));
               fspshend(put,char(funcnr mod 250));
               end
            else
               fspshend(put,char(funcnr));

            // Keep track of current locVarLevel (see xArgBlock for info)
            if xCurrentLocVarLevel>=0 then
               if functab[funcnr].definedIn>1 then
                  // This is a user defined function
                  xCurrentLocVarLevel:= xCurrentLocVarLevel+1;

            npos:= put;
            fspshend(put,char(0));

            (* Is this a call to <set/pop/foreach ...>? Then remember this, because
               arg 1 shall be compiled to a binary number. *)
            (* BFn 2016-11-13: callToSetPopForeach include all functions where
               the first argument shall be compiled to a binary number.
               CallToSetAppend is a subset of callToSetPopForeach, and includes
               only functions where arg1 can be indexed (e.g. "$tab[abc]").
               It is used to allow other functions to have '[' in its first
               argument. *)
            calltosetAppend:= (funcnr=alSetFuncNr) or (funcnr=alappendfuncnr) or
               (funcnr=alUpdateFuncNr) or (funcnr=alPackFuncNr);
            calltoSetpopforeach:= callToSetAppend or (funcnr=alPopFuncnr) or
               (funcnr=alForeachFuncnr) or (funcnr=alIndexesFuncNr);
            calltovar:= (funcnr=alVarFuncnr);

            if (funcnr=alCfuncnr) then callToCj:= 1
            else if (funcnr=alJfuncnr) then callToCj:= 2
            else if (funcnr=alC_lateEvaluationfuncnr) then callToCj:= 3
            else callToCj:= 0;

            if (not inFunction) then
               if (funcnr=alFunctionFuncnr) or (funcnr=alDefFuncnr) or (funcnr=alPreldefFuncnr)
               then begin
               inFunction:= true;
               callToFunction:= true;
               xCurrentLocVarLevel:= 0;
               end;

            if ch=' ' then begin
               npos^:= char( ord(npos^) + 1);
               rekursivtab[ord(npos^)]:= FALSE;
               lpos:= put;
               fspshend(put,char(0));
               lpos2:= put;
               fspshend(put,char(0));
               a1pos:= put;
               state:= s2;
               end;
            end; (* namecomplete *)
         end; (*S1*)

      s2: begin
         (* Reading arguments. *)
         if (ch='<') and not citation then begin
            compilecall;
            rekursivtab[ord(npos^)]:= true;
            end

         // Handle citation separately to simplify the following conditions.
         else if citation then fspshend(put,ch)

         (* Compile $name as a variable, unless it is the first argument
            in a call to <set ...>, <pop ...>, <foreach ...> or <var ...> *)
         else if (ch='$') and (pin^ in xidchar1range)
            and not ((calltoSetpopforeach or calltovar) and (integer(npos^)=1))
            then begin
            compileDollarVariable;
            rekursivtab[ord(npos^)]:= true;
            end
         else if readingindex and (ch=']') and ((pin^=',') or (pin^='>')) then
            // (End of index - skip ']'.

         else if not ( (ch='>') or (ch=',') or
               ((ch='[') and callToSetAppend and (integer(npos^)=1)) )
            then fspshend(put,ch)

         else begin

            (* Getting here means that end of argument was reached: ch is unquoted '>'
               or ',' or, if function was set/pop/foreach: '['. *)
            if (ch='[') then
               readingindex:= true;

            (* Complete argument by filling in length in lpos. End with eoa. *)
            alen:= fsdistance(lpos,put)-2;
            if callToCJ>0 then if npos^=char(1) then begin
               (* For <c ...>, <j ...> and <c_lateevaluation>: alen of arg1 must be >= 5
                  (2 length bytes + three bytes for state number (@nn). *)
               while alen<5 do begin
                  fspshend(put,eoa);
                  alen:= alen+1;
                  end;
               end;
            if alen>maxarglen then begin
               xCompileError2('X(xcompilestring): Program error - alen<='+inttostr(maxarglen) +
                  ' was expected, but ' + inttostr(alen) + ' was found.');
               end
            else begin
               lpos^:= char(alen div 250);
               lpos2^:= char(alen mod 250);
               end;

            fspshend(put,eoa);

            (* If <set ...>, <pop ...> or <foreach ...> then compile arg 1 to binary number: *)
            if (calltoSetpopforeach) and (ord(npos^)=1) then begin
               if rekursivtab[ord(npos^)] and false (* This test was moved further down to get
                  a better error message. /BFn 2019-03-07. *) then begin
                  xCompileError2(
                     'X (compilecall <'+funcname+
                     ' ...>): Argument 1 shall be $name. Cannot contain <...>-calls.');
                  end
               else if alen>64 then begin
                  xCompileError2(
                     'X (compilecall <'+funcname+
                     ' ...>): Argument 1 shall be $name. Full length is currently limited to 64 chars ('
                     +inttostr(alen)+').');
                  end
               else begin
                  (* Compile macroname to binary number. *)
                  s:= lpos2;
                  fsforward(s);
                  (* Read away the $ in <set/pop/foreach $name,...>. *)
                  if s^='$' then begin
                     fsforward(s);
                     alen:= alen-1;
                     end;

                  (* Read name. *)
                  for i:= 1 to alen do begin
                     if i<=64 then setpar:= setpar+s^;
                     fsforward(s);
                     end;

                  // This check is done after reading name because name is needed in error message.
                  if ioinptr(integer(lpos2)+1)^<>'$' then begin
                     // Check again because lpos2 could be at the end of a block.
                     s:= lpos2;
                     fsforward(s);
                     if s^<>'$' then xCompileError2(
                        'X (compilecall <'+funcname+' '+setpar+'...>):'+
                        '"$" was expected before variable name ('+setpar+') but not found.');
                     end;
                  end;

               // Improved error message for variable name containing "<" /BFn 2019-03-07
               if rekursivtab[ord(npos^)] then begin
                  n:= 0;
                  for i:= 1 to length(setpar) do begin
                     if integer(setpar[i])>=xstan then
                        if n=0 then n:= i-1;
                     end;

                  xCompileError2(
                     'X (compilecall <'+funcname+',$'+ leftstr(setpar,n) +
                     '<...): Argument 1 shall be $name. Cannot contain <...>-calls.');
                  end; // +++

               if not xCompileErrorActive then begin

                  setnr:= xgetvisiblenr(setpar);
                  if setnr=0 then setnr:= xGetLocalNr(setpar);
                  if setnr<=0 then begin
                     list:= xdefinedin(setpar);
                     if list[1]=0 then begin
                        if setnr=0 then
                           xCompileError2('X (compilecall <'+
                           funcname+' ...>): Argument 1 shall be a macro name ('+
                           setpar+ ' is not defined).')
                        else
                           // (<0)
                           xCompileError3('X (compilecall <'+funcname+
                              ' ...>): Argument 1 shall be a macro name ('+
                              setpar+ ' is not defined). '#13'The reason could be that '+
                              xgetlocalnrGroupName+ '.x is in the process of being loaded.'#13' '+
                              'Check that '+xgetlocalnrfuncname+' is defined in '+
                              xgetlocalnrGroupname+'.x and, if it is, insert <preldef '+
                              xgetlocalnrfuncname+'> just before '#13'<load '+
                              fstostr(xcompilefilename)+'> to enable '+setpar+
                              ' to be found by the X compiler.');
                        end
                     else begin
                        if setnr=0 then
                           xCompileError2('X (compilecall <'+funcname+
                              ' ...>): Argument 1 ('+setpar+ ') is not visible here.')
                        else
                           // (<0)
                           xCompileError3('X (compilecall <'+funcname+' ...>): Argument 1 ('+
                              setpar+ ') is not visible here.'+' '#13'The reason could be that '+
                              xgetlocalnrGroupName+ '.x is in the process of being loaded.'#13' '+
                              'Check that '+xgetlocalnrfuncname+' is defined in '+
                              xgetlocalnrGroupname+'.x and, if it is, insert <preldef '+
                              xgetlocalnrfuncname+'> just before '#13'<load '+
                              fstostr(xcompilefilename)+'> to enable '+setpar+
                              ' to be found by the X compiler.');

                        end;

                     if alflagga('D') then begin
                        ioErrmessWithDebugInfo(setpar+'is defined in file '+inttostr(list[1])+'.');
                        list:= ximportedto(setpar);
                        ioErrmessWithDebugInfo(setpar+'is imported to file '
                        +inttostr(list[1])+' '+inttostr(list[2])+' '+inttostr(list[3])
                        +'.');
                        end;
                     end
                  else if functab[setnr].definedin=0 then begin
                     xCompileError2(
                        'X (<'+funcname+' '+setpar+
                        ',...>): '+setpar+' is a predefined function.'+
                        'Cannot be altered by <'+funcname+' ...>.');
                     end
                  else begin
                     put:= lpos;
                     fsdelrest(put);
                     fspshend(put,char(0)); (* arglen - preliminary*)
                     fspshend(put,char(0));
                     alen:= 0;
                     if functab[setnr].special<>dsvar then
                        xCompileError2(
                           'X (compilecall:<'+funcname+' $'+setpar+
                           ',...>): For arg 1 in <set ...>, a variable was '+
                           'expected, but '+setpar+' was found to be a '+
                           dstostr(functab[setnr].special)+'.')

                     else if setnr>=250*250 then begin
                        xCompileError2(
                           'X (compilecall:<'+funcname+' $'+
                           setpar+
                           ',...>) Program error - too high setnr.');
                        end
                     else if setnr>=250 then begin
                        fspshend(put,char(0));
                        fspshend(put,char(setnr div 250));
                        fspshend(put,char(setnr mod 250));
                        alen:= alen+3;
                        if setnr>xmaxfuncnr then begin
                           // Local variable reference - add nesting level (see xargblock for info)
                           fspshend(put,char(0));
                           alen:= alen+1;
                           end;
                        end
                     else begin
                        fspshend(put,char(setnr));
                        alen:= alen+1;
                        end;

                     lpos^:= char(0);
                     lpos2^:= char(alen);
                     fspshend(put,eoa);
                     if (functab[setnr].special<>dsvar) and xcheckvar then
                        xCompileError2('X (<'+funcname+' '+setpar+
                           ',...>) Warning: Argument 1 is not a variable name.'+
                           'Use <var ...> instead of <def ...> to define '+
                           setpar+'.');
                     end;
                  end;
               end (*setpopforeach*)

            (* If <c ...> or <j ...> or <c_lateevaluation ...>: Save pointer to
               statename (arg 1) in stateRefTab, to be resolved later. *)
            else if calltoCJ>0 (* <c ...>, <j ...> or <c_lateevalutation ...> *) then begin
               // Skip compilation (for now) if arg 1 is an expression. (161120)
               if (ord(npos^)=1) and not rekursivtab[1] and not inFunction then begin
                  (* Save position of called state name, to be compiled to a number
                     when end of the file is reached. *)
                  if staterefcount<statereftabsize then begin
                     s:= lpos2;
                     fsforward(s);
                     (* (new:) *)
                     xAddFuncStateRef(s,callToCj);
                     (* (old:)
                     staterefcount:= staterefcount+1;
                     with stateRefTab[staterefcount] do begin
                        stateref:= s;
                        groupNr:= xcurrentgroupnr;
                        cjkind:= callToCj;
                        end;
                     *)
                     end
                  else
                     xCompileError2('X (<'+funcname+' '+alFsToStr(s,eoa)+
                     ',...>): This script appears to have very many state references ' +
                     '(<c ...>, <j ...> or <c_lateevaluation ...>). X is designed ' +
                     'to keep track of up to ' + inttostr(stateRefTabSize) +
                     'references in x files being simultaneously loading, ' +
                     'but this appears not to be enough for this script.');
                  end;
               end

            else if funcnr=alBitsFuncNr then begin
               if npos^=char(2) then begin
                  if not rekursivtab[1] and not rekursivtab[2] then begin
                     // Check that length of arg 2 corresponds to number of bits (arg1)
                     if alen<>(fsposint(a1pos)+3) div 4 then
                        xCompileError2('X (compilecall <'+funcname+
                           ' ...>): Argument 2 was expected to have length ' +
                           inttostr((fsposint(a1pos)+3) div 4) + ' (corresponding to ' +
                           inttostr(fsposint(a1pos)) + ' bits) but it was found to have length ' +
                           inttostr(alen) + '. Because of different length, it will never match.');
                     end;
                  end;
               end;

            if inFunction and (ord(npos^)=1) then begin
               if callToVar then begin
                  (* Local variable definition. *)
                  if rekursivtab[ord(npos^)] then xCompileError2(
                     'X (compilecall <var '+
                     ' ...>): Argument 1 shall be a name. Cannot contain <...>-calls.')
                  else begin
                     (* Get arg1 without $sign. *)
                     arg1:= '';
                     s:= lpos2;
                     fsforward(s);
                     (* Name in <var $name,...> shall have $ before it. *)
                     if s^='$' then begin
                        fsforward(s);
                        alen:= alen-1;
                        end;
                     for i:= 1 to alen do begin
                        arg1:= arg1+s^;
                        fsforward(s);
                        end;
                     locVarCount:= locVarCount+1;
                     if ch=',' then arg2:= ',...' else arg2:= '';
   
                     // This check is done after reading arg1 because arg1 is needed in error message.
                     if ioinptr(integer(lpos2)+1)^<>'$' then begin
                        // Check again because lpos2 could be at the end of a block.
                        s:= lpos2;
                        fsforward(s);
                        if s^<>'$' then xCompileError2(
                           'X (compilecall <'+funcname+' '+arg1+'...>):'+
                           '"$" was expected before variable name ('+arg1+') but not found.')
                        else
                           (* Define local variable. *)
                           xdefineLocalVariable(arg1,xMaxFuncNr + locVarCount);
                        end
                     else
                        (* Define local variable. *)
                        xdefineLocalVariable(arg1,xMaxFuncNr + locVarCount);
                     end;
                  end; (* callToVar *)
               end; (* inFunction and npos^=1) *)

            if (ch=',') or (ch='[') then begin
               // New argument
               if ord(npos^)>=xmaxnarg then begin
                  xCompileError2(
                     'X (compilecall '+funcname+'): Too many arguments (max = '+inttostr(xmaxnarg)+').');
                  end
               else begin
                  // New argument
                  npos^:= char( ord(npos^) + 1 );
                  rekursivtab[ord(npos^)]:= FALSE;
                  lpos:= put;
                  fspshend(put,char(0));
                  lpos2:= put;
                  fspshend(put,char(0));
                  end;
               if pin^='{' then if ch=',' then begin
                  // Could be a tag coming here...
                  // Save input pointer in case it was not a tag:
                  savepin:= pin;
                  state:= s3;
                  argName:= '';
                  end;
               end
            else begin (* > *)
               if funcnr=alXpFuncnr then begin
                  (* Add arg2 = initially char(250). This can set to a fixed offset
                     when a function argument $n is expanded in alMacro, to
                     prevent offset error in for example <ifeq ...,...,...$n...> *)
                  npos^:= char( ord(npos^) + 1 );
                  rekursivtab[ord(npos^)]:= FALSE;
                  fspshend(put,char(0)); // arglen for arg2 = 1
                  fspshend(put,char(1));
                  fspshend(put,char(250)); // arg2
                  fspshend(put,eoa);
                  end;

               for n:= 1 to ord(npos^) do if rekursivtab[n] then
                  fspshend(put,char(n));
               fspshend(put,char(0));
               end;
            end;
         end; (*s2*)

      s3: begin
         // Reading "{" in ",{name". Goto s4
         if ch='{' then begin
            argname:= '';
            state:= s4;
            end
         else begin
            xProgramError('X (compilecall '+funcname+
            ') s3: Expected "{" in {name:} but found "' + ch + '"... .');
            state:= s2;
            end;
         end; (*s3*)

      // (new:)
      s4: begin
         // Reading name in ",{name}".
         // Read until '}', then check name
         if ch in xidcharRange then
            argname:= argname + ch
         else if ch='}' then begin
            // Skip check if argnumber is above the allowed number
            if integer(npos^)>functab[funcnr].parmax then
               // No check, this will give error message later.
            else if functab[funcnr].argNameIndex=0 then
               xCompileError2('X (compilecall '+funcname+
               ') s4: Expected function to have arg names defined because "{' +
               argname + '} was used. But this function has no such definitions - '
               + '"{name}" cannot be used to document or verify argument names in function "' +
               funcname + '".')
            else if integer(npos^)=1 then
               xCompileError2('X (compilecall '+funcname+
               ') s4: Argument name was only expected for argument 2 and higher, but name "{' +
               argname + '} was used for argument 1.')
            else begin
               // Argument name (for arg>=2) is used, and argument names are defined for this function.
               // Loop through all specified names to look for a match.
               argNr:= integer(npos^);
               argindex:= funcTab[funcnr].argNameIndex-1;
               argIndexLast:= argindex+funcTab[funcnr].argNameCount;
               tagfound:= false;
               optfound:= false;
               badNameIndex:= 0;
               while not tagfound and (argIndex<argIndexLast) do begin
                  argIndex:= argIndex+1;
                  with argNameTab[argIndex] do begin
                     if (option=None) then begin
                        if not optfound then begin
                           // argnr=2 shall match argIndex=funcTab[funcnr].argNameIndex
                           if argnr = argIndex-funcTab[funcnr].argNameIndex+2 then begin
                              if name=argName then tagfound:= true
                              else badnameIndex:= argIndex;
                              end;
                           end;
                        end
                     else begin
                        optfound:= true;
                        case option of
                           argEven: if argnr mod 2 = 0 then begin
                              if name=argName then tagfound:= true
                              else badNameIndex:= argIndex;
                              end;
                           argOdd: if argnr mod 2 = 1 then begin
                              if name=argName then tagfound:= true
                              else badNameIndex:= argIndex;
                              end;
                           argLast:
                           // This should only work for last arg, but it is not possible to know here
                           if name=argName then tagfound:= true
                           else badNameIndex:= argIndex;
                           (* +++ Todo: Check that this is the last arg and check that
                              argEven and argOdd is not accepted if argLast is specified. *)
                           end;
                        end;
                     end;
                  end;

               if not tagfound then begin
                  if badNameIndex>0 then xCompileError2('X (compilecall '+funcname+
                     ') s4: Argument tag name "{' + argNameTab[badNameIndex].name +
                     '}" was expected for argument ' + inttostr(integer(npos^)) +
                     ' but tag "{' + argname + '}" was found.')
                  else xCompileError2('X (compilecall '+funcname+
                     ') s4: No tag was expected for argument ' + inttostr(integer(npos^)) +
                     ' but tag "{' + argname + '}" was found.');
                  end;
               end;
            state:= s2;
            end
         else begin
            // Assume that "{" was intended for other purpose than to insert a tag
            // roll back to the situation when pin^='{' was detected in s2.
            pin:= savePin;
            ch:= ',';
            state:= s2;
            end;
         end; //s4

      (* (old:)
      s4: begin
         // Reading name in ",{name}".
         // Read until '}', then check name
         if ch in xidcharRange then
            argname:= argname + ch
         else if ch='}' then begin
            // Skip check if argnumber is above the allowed number
            if integer(npos^)>functab[funcnr].parmax then
               // No check, this will give error message later.
            else if functab[funcnr].argNameIndex=0 then
               xCompileError2('X (compilecall '+funcname+
               ') s5: Expected function to have arg names defined because "{' +
               argname + '} was used. But this function has no such definitions - '
               + '"{name}" cannot be used to document or verify argument names in function "' +
               funcname + '".')
            else begin
               // Argument names are defined for this function. argNameIndex points
               // at argument nr 2 (first arg has no name).
               argNameIndex:= functab[funcnr].argNameIndex + integer(npos^) - 2;
               if integer(npos^)-1>funcTab[funcnr].argNameCount then
                  xCompileError2('X (compilecall '+funcname+
                  ') s5: Argument name "' +
                  argname + '" was specified for argument ' + inttostr(integer(npos^)) +
                  ' but the name of argument ' + inttostr(integer(npos^)) +
                  ' is not specified for this function.')
               else if argNameTab[argNameIndex]<>argName then
                  xCompileError2('X (compilecall '+funcname+
                  ') s5: Argument name {' +
                  argNameTab[argNameIndex] + '} was expected for argument ' + inttostr(integer(npos^)) +
                  ', but {'+argname+'} was found.');
               end;
            state:= s2;
            end
         else begin
            // Assume that "{" was intended for other purpose than to insert a tag
            // roll back to the situation when pin^='{' was detected in s2.
            pin:= savePin;
            ch:= ',';
            state:= s2;
            end;
         end; //s4
         *)

      end; (*case*)
   end; (*while*)

// Keep track of current locVarLevel (see xArgBlock for info)
if funcnr>0 then
   if xCurrentLocVarLevel>=0 then
      if functab[funcnr].definedIn>1 then
         // This was a call to a user defined function
         xCurrentLocVarLevel:= xCurrentLocVarLevel-1;

if xCompileErrorActive then (* - *)
else if ch<>'>' then begin
   xCompileError2(
      'compilecall '+funcname+': Error - call not terminated with ">".');
   end
else if npos=nil then begin
   xCompileError2('compilecall: Program error - unable to find position for number of arguments (npos=NIL).');
   end
else if ord(npos^) < functab[funcnr].parmin  then begin
   xCompileError2(
      'compilecall '+funcname+': too few parameters - '+inttostr(ord(npos^))
      +'(min '+inttostr(functab[funcnr].parmin)+' expected).');
   end
else if ord(npos^) > functab[funcnr].parmax  then begin
   xCompileError2(
      'compilecall '+funcname+': too many parameters - '+inttostr(ord(npos^))
      +'(max '+inttostr(functab[funcnr].parmax)+' expected).');
   end
else if functab[funcnr].extraCond<>xNoCond then begin
   case functab[funcnr].extraCond of
      xOddNarg:
         if not odd(ord(npos^)) then
         xCompileError2('compilecall '+
         funcname+': Odd number of parameters was expected but '+
         inttostr(ord(npos^)) + ' parameters were found.');
      xEvenNarg:
         if odd(ord(npos^)) then
         xCompileError2('compilecall '+
         funcname+': Even number of parameters was expected but '+
         inttostr(ord(npos^)) + ' parameters were found.');
      else ;
      end;
   end;


if locvarcount>savelocvarcount then if not calltovar then begin
   // remove local variables
   for i:= locvarcount downto savelocvarcount+1 do begin
      // free functab entry
      funcnr:= xmaxfuncnr+i;
      functab[funcnr].defined:= false;

      // Remove from index list
      index:= functab[funcnr].index;
      if funcindex[index]=funcnr then funcindex[index]:= functab[funcnr].next
      else begin
         next:= functab[index].next;
         found:= false;
         while not (found or (next=0)) do begin
            if next=funcnr then begin
               found:= true;
               functab[index].next:= functab[next].next;
               end
            else begin
               index:=next;
               next:= functab[index].next;
               end;
            end;(*while*)
         if not found then
            xCompileError2('compilecall ' + funcname +
               ': Program error in X: Trying to remove local variable ' +
               functab[funcnr].name + ' but was unable to find it.');
         end;(*else*)
      end;(*for*)
   locvarcount:= savelocvarcount;
   end;(*if*)

// Reset infunction
if callToFunction then begin
   inFunction:= false;
   locvarcount:= 0;
   xCurrentLocVarLevel:= -1;
   end;

end; (*compilecall*)


begin (*xcompilestring*)

pi:= pin; pu:= put; (* Debug *)

if xCompileErrorActive then
   xProgramError('*** xcompilestring: Program error - xCompileErrorActive was expected to ' +
      'be false at entry of xcompilestring, but it was true.');

xCompileFilename:= pfilename;
xCompileLine1:= plinenr1;
xCompileLine2:= plinenr2;

putspar:= put; if not (putspar^=eofs) then fsforwend(putspar);
while not ((pin^=pendch) or xCompileErrorActive) do begin

   ch:= pin^;
   fsforward(pin);
   if (ch='''') and (pin^<>pendch) then begin
      citation:= true;
      ch:= pin^;
      fsforward(pin);
      end
   else citation:= FALSE;
   // Handle citation separately to simplify the following conditions
   if citation then fspshend(put,ch)
   else if ch='<' then compilecall
   else if (ch='$') and (pin^ in xidchar1Range)
      then begin
      compileDollarVariable;
      end
   else fspshend(put,ch);
   end;

if xCompileErrorActive then begin
   fsdelrest(putspar);
   end;

if alflagga('D') then begin
   dmess:= 'xcompilestring: in="'+fstostr(pi)+'"';
   dmess:= dmess+'gives out="';
   c1:= ' '; c2:= ' '; c3:= ' ';
   while not (ord(pu^)=fseofs) do begin
      ch:= pu^;
      if (ord(ch) >= 253)
         or (ord(c1) = 253)
         or (ord(c2) = 253)
         or (ord(c3) = 253)
         or (ord(c1) = 254)
         or (ord(ch) < ord(' '))
         then dmess:= dmess+'('+inttostr(ord(ch))+')'
      else dmess:= dmess+ch;
      c3:= c2; c2:= c1; c1:= pu^;
      fsforward(pu);
      end;
   iodebugmess(dmess);
   end;

end; (*xcompilestring*)

procedure resolveStateRef(pn: integer); forward;

// Like xCompileString but with instant resulution of state references
procedure xCompileAndResolve( pin,put: fsptr; pendch: char; pncallallowed: boolean;
                          pfilename: fsptr; plinenr1,plinenr2: integer );

var stateRefCountSave,i: integer;

begin

// Remember top of stateRefTab, before compilation
staterefcountsave:= staterefcount;

xcompilestring(pin,put,pendch,pncallallowed,pfilename,plinenr1,plinenr2);

if not xCompileErrorActive then begin
   // State references need to be resolved directly
   if staterefcount>stateRefCountSave then begin
      for i:= stateRefCountSave+1 to staterefcount do resolvestateref(i);
      staterefcount:= stateRefCountSave;
      end;
   end;

end; // (xCompileAndResolve)


procedure xdecodecall( var ps: fsptr; var pnr: xint16; var pargs:xargblock);

(* Decode compiled call from ps. stan has just been read. *)

(* After return from xdecodecall, ps points at the first char
   following the call. *)

var
argnr: xint16;
alen: xint16;
cnt: integer;
s0: fsptr;

begin

s0:= ps;
pnr:= ord(ps^);
fsforward(ps);
if pnr=0 then begin
  (* Long number. *)
  pnr:= xint16(ps^);
  fsforward(ps);
  pnr:= pnr*250 + xint16(ps^);
  fsforward(ps);
  end;

with pargs do begin

   if pnr>xmaxfuncnr then begin
      (* Local variable: Local variable reference nesting level is needed to find
         the stack offset that is valid for the variable reference. *)
      locvarnestlevel:= integer(ps^);
      fsforward(ps);
      end;

    narg:= ord(ps^);
    fsforward(ps);

    for argnr:= 1 to narg do begin
        alen:= integer(ps^)*250;
        fsforward(ps);
        alen:= alen+integer(ps^);

        fsforward(ps);
        if argnr<=xmaxnarg then begin
            arg[argnr]:= ps;
            rekursiv[argnr]:= FALSE;
            end;
        (* Jump to eoa-mark *)
        fsmultiforw(ps,alen);
        if ps^<>eoa then begin
            xProgramError('X: program error in xdecodecall('+inttostr(pnr)
              +'): Error. Cannot find eoa for arg '
              +inttostr(argnr)+'.'+
              'alen='+inttostr(alen)+
              'arg="'+xfstostr(arg[argnr],eofs) + '".'
              );
            if alloadlevel>0 then xsetcompileerror;
            end;

        (* Go to next argument. *)
        fsforward(ps);
        end;

    if narg>xmaxnarg then begin
       xProgramError('X: program error in xdecodecall('+inttostr(pnr)
         +') - narg ('+inttostr(narg)+') > maxnarg ('
         +inttostr(xmaxnarg)+').');
       if alloadlevel>0 then xsetcompileerror;
       narg:= xmaxnarg;
       end;

    (* Remember that the last nul is only there if narg>0: *)

    if narg>0 then begin
      cnt:= 0;
      alen:= 0; // (to please compiler)
      REPEAT
        cnt:= cnt+1;
        if cnt=narg+2 then begin
           xProgramError('X: program error in xdecodecall('+inttostr(pnr)
              +') - cannot find nul in arg '
              +'narg='+inttostr(narg)
              +' pnr='+inttostr(pnr)
              +' ps="'+fstostr(ps)+'"'
              +' alen='+inttostr(alen)
              + '" call="'+fstostr(s0)
              +' arg[narg]="'+fstostr(arg[narg])
              + '".');
           if alloadlevel>0 then xsetcompileerror;
           argnr:= 0;
           end
        else argnr:= ord(ps^);
        if argnr>narg then begin
           xProgramError('X: program error in xdecodecall('+inttostr(pnr)+
              '): Found argnr ('+inttostr(argnr)+') in recursive arg list, '+
              'that was higher than narg ('+inttostr(narg)+').');
           if alloadlevel>0 then xsetcompileerror;
           end;
        fsforward(ps);
        if argnr<>0 then rekursiv[argnr]:= true;
        UNTIL argnr=0;
      end; (* narg>0 *)

    (* Now, ps points at the character following nul (or narg=0) *)
    end;

end; (*xdecodecall*)


type charptr = ^char;

// (new: accepting eofs as new line)
procedure xcompare( ptest: fsptr; pendch: char;
        psetpar,psetxpar: boolean; var pstateenv: xstateenv; var plika: boolean)

(* JÄMFÖR EN INSTRÄNG MED EN TESTSTRÄNG. TESTSTRÄNGEN KAN INNEHÅLLA
   ANROP. PLIKA=TRUE OM ÖVERENSSTÄMMelse FINNS TILL TESTSTRÄNGENS SLUT. *)

(* OBS! xcompare LAGRAR PEKARE IN I pinp, SOM SEDAN ANVÄDNS AV alp. alp FÅR
   DÄRFÖR INTE ANROPAS EFTER ATT pinp-STRÄNG ÄNDRATS, UTAN ATT NYTT
   ANROP TILL xcompare GJorTS. *);

var
args: xargblock;
nr: xint16;
saveinp: ioinptr;
funcret: fsptr;
tempatp: ioinptr;
tempnpar: integer;
i: xint16;
testchar: char;
setafterp: boolean;
nextch: char;
inp: ioinptr;
finished: boolean;
cinp00,cinp0: ioinptr;
cinp1,testc1: char;
setAnyPar: boolean;

begin (*xcompare*)

if alflagga('D') then begin
  iodebugmess('->xcompare(pinp^="'+ioptrtostr(pstateenv.cinp)+'")'
  +'ptest="'+xfstostr(ptest,pendch)+'")');
  end;

fsnew(funcret);

plika:= true;
setafterp:= False;
tempnpar:= 0;

setAnyPar:= pSetPar or pSetXPar;

if psetpar then with pstateenv.pars do begin
   for i:= 1 to npar do par[i].bitsAs:= 0;
 
   npar:= 0;
   invalidBecauseOfRpw:= false;
   xparoffset:= 0;
   // (old:) alDebugLog('xcompare(1)','xparoffset',inttostr(pstateenv.pars.xparoffset));
   nxpar:= 0;
   bitsnpar:= 0; //New, Added to enable bits in psetxpar
   // (old:) alDebugLog('xcompare(1)','nxpar',inttostr(pstateenv.pars.nxpar));
   end
else if psetxpar then with pstateenv.pars do begin
   tempnpar:= npar+xparoffset+nxpar;
   bitsnpar:= tempnpar; //New, Added to enable bits in psetxpar
   // nxpar:= 0; (removed so <xp ...> can be used in pattern).
   end;
saveinp:= pstateenv.cinp;

(* Check ptest^ to the end or until a difference is discovered: *)
while not ( ((ptest^=pendch) and (funcret^=eofs)) or not plika) do begin

   if alflagga('D') then iodebugmess('->xcompare(inp^="'+ioptrtostr(pstateenv.cinp)+'")'
      +'ptest="'+xfstostr(ptest,pendch)+'")');

   (* 1. Handle <..>-function calls *)
   while (ptest^=stan) and (funcret^=eofs) do begin

      (* 1A. Save input pointer for storing <p n> later *)
      tempatp:= pstateenv.cinp;

      (* 1B. Call function *)
      fsforward(ptest);
      xdecodecall(ptest,nr,args);
      fsrewrite(funcret);

      // (new:) Reset bitsAs field (will be set in albits if necessary)
      if setAnyPar then pstateenv.pars.par[tempnpar+1].bitsAs:= 0;

      alcall(nr,args,xevalcompare,pstateenv,funcret);

      if psetpar then begin
         if tempnpar=xmaxnpar then xCompileError2(
            'xcompare: To many parameters (>'+inttostr(xmaxnpar) + ').')
         else begin
            tempnpar:= tempnpar+1;
            pstateenv.pars.bitsnpar:= tempnpar; //New, Added to enable bits in psetxpar
            with pstateenv.pars.par[tempnpar] do begin
               if fs<>nil then fsdispose(fs);
               atp:= tempatp;
               afterp:= pstateenv.cinp;
               end;
            pstateenv.pars.npar:= tempnpar;
            end;
         end
      else if psetxpar then begin
         if tempnpar=xmaxnpar then xCompileError2(
            'xcompare: To many parameters (>'+inttostr(xmaxnpar) + ').')
         else with pstateenv.pars do begin
            // nxpar:= nxpar+1; (removed so <xp ...> can be used in pattern
            tempnpar:= tempnpar+1;
            bitsnpar:= tempnpar; //New, Added to enable bits in psetxpar
            with par[tempnpar] do begin
               if fs<>nil then fsdispose(fs);
               atp:= tempatp;
               afterp:= pstateenv.cinp;
               end;
            end;
         end;
      end;(* while stan and eofs *)

   if (ptest^=pendch) and (funcret^=eofs) then begin
      // success
      end

   else begin

      if funcret^<>eofs then begin
         (* Alcall can either move inp ahead, or put something
            in funcret. If funcret - check it: *)
         testchar:= funcret^;
         fsforward(funcret);
         (* Afterp shall be corrected to after end of funcret if there was a
            funcret. *)
         if (funcret^=eofs) and (psetpar or psetxpar) then setafterp:= true;
         end
      else begin
         testchar:= ptest^;
         fsforward(ptest);
         (* Skip extra blanks in x file. *)
         end;

      (* Skip extra blanks in x file or function return. *)
      if fsLcWsTab[testchar]=' ' then begin
         testchar:= ' ';
         // Remove leading blanks from function return
         while fsLcWsTab[funcret^]=' ' do
            fsforward(funcret);
         // Remove extra blanks in X file.
         if funcret^=eofs then
            while fsLcWsTab[ptest^]=' ' do
            fsforward(ptest);
         end;


      (* Do comparison: *)

      (* 2. Get next input char if necessary. *)
      if pstateenv.cinp^=eofr then
         ioingetinput(pstateenv.cinp,true);

      (* 3. Handle trailing blanks in input. *)
      if (testchar=ctrlm)
         and (fsLcWsTab[pstateenv.cinp^]=' ')
         then begin
         while (fsLcWsTab[pstateenv.cinp^]=' ') do begin
            ioinforward(pstateenv.cinp);
            if (pstateenv.cinp^=eofr) then
               (* (old:)
               if ioinreadable(pstateenv.cinp) then ioingetinput(pstateenv.cinp,true);*)
               // (new:)
               ioingetinput(pstateenv.cinp,false);
            end;
         if (pstateenv.cinp^=char(13)) or (pstateenv.cinp^=char(10)) then
            (* Consume ctrlm from inp. *)
            ioinforward(pstateenv.cinp)
         else plika:= false;
         end

      (* 3. Handle blank in x-file. *)
      else if testchar=' ' then begin

         (* A. ' ' in x-file represents any number of blanks or tabs (
            or new-lines if that option selected). *)

         if (fsLcWsTab[pstateenv.cinp^]=' ')
            (* (xoptcr/xoptcr2 either 10/13 or " " depending on if newlines shall
               be regarded as blanks.) *)
            or (pstateenv.cinp^=xoptcr) or (pstateenv.cinp^=xoptcr2)
            (* (xcommentasblank is first char of a comment if comments shall
               be regarded as blanks.) *)
            or (pstateenv.cinp^=xcommentasblank)
            then begin
            finished:= false;
            // cinp00 will be used later to test success (found blank(s))
            cinp00:= pstateenv.cinp;
            while not finished do begin
               if (fsLcWsTab[pstateenv.cinp^]=' ') or
               (pstateenv.cinp^=xoptcr) or (pstateenv.cinp^=xoptcr2)
               then begin
                  (* Read away blanks,tabs and new-lines. *)
                  ioinforward(pstateenv.cinp);
                  if (pstateenv.cinp^=eofr) then ioingetinput(pstateenv.cinp,false);
                  end
               else if pstateenv.cinp^=xcommentasblank then begin
                  (* 1st char in a comment recognized. See if it is a comment and
                     then read past it. *)
                  cinp0:= pstateenv.cinp;
                  ioskipcomment(pstateenv.cinp,xlinecommentasblank);
                  if pstateenv.cinp=cinp0 then
                     (* It was not a comment. *)
                     finished:= true;
                  end
               else
                  (* No more blanks, tabs, newlines or comments to read. *)
                  finished:= true;
               end;
            if pstateenv.cinp=cinp00 then plika:= false;
            end (* ' ' or char(9) or xoptcr or xcommentasblank *)

         (* B. Ignore trailing blanks in x-file. *)
         else if ((pstateenv.cinp^=ctrlm) or (pstateenv.cinp^=char(10)) or (pstateenv.cinp^=eofs))
            and (ptest^<>pendch) then
           (* (ok) *)

         else plika:= false;
         end (*while*)

      (* 2. Handle direct comparison. *)
      else if (pstateenv.cinp^=testchar) (* Full equality *)
         or (* Optional case-insensitive equality *)
         (
            (
               ((ord(pstateenv.cinp^) xor ord(testchar)) and xcasemask)
               or (not ord(pstateenv.cinp^) and $40)
            ) = 0
         )
         and ((ord(testchar) and $5F) <=90)
         then begin
         if pstateenv.cinp^=eofs then
            xProgramError('xcompare: Unexpected inp=eofs.')
         else
            ioinforward(pstateenv.cinp);
         end

      (* 3. LF accepted as new line (unix style). *)
      else if (testchar=ctrlm) then begin
         if (pstateenv.cinp^=char(10)) then ioinforward(pstateenv.cinp)
         else plika:= false;
         end

      (* 4. Else no match. *)
      else plika:= false; (* no match. *)

      (* 5. Correct afterp if neccessary. *)
      if setafterp then with pstateenv.pars.par[tempnpar] do begin
         afterp:= pstateenv.cinp;
         setafterp:= false;
         end;
      end; (* not pendch and eofs *)

   end; (* while not pendch and eofs *)

(* Do not allow a non-empty alternative with an empty input (would
   cause an endless loop). *)

(* Reset cinp if not success: *)
if not plika then begin
   pstateenv.cinp:= saveinp;

   (* Reset pars if not success: *)
   if psetpar then with pstateenv.pars do begin
      for i:= 1 to npar do par[i].bitsAs:= 0;
      npar:= 0;
      xparoffset:= 0;
      end
   end
else begin
   if psetxpar then with pstateenv.pars do begin
      (* Increment xparoffset with the old nxpar so that, for example,
         <xp 1> now will be found at index npar (number of <p n>) +
         xparoffset (number of <xp n> in outer levels) + 1. *)
      (* A problem with this stacking of new x parameters is that the old xparoffset
         and nxpar have to be restored after leaving the context where the <xp n>
         references are valid. We would have to search for every call to
         xcompare where psetxpar(par. 4)=true and the result was equal, and
         then restore xparoffset and nxpar with:

         xparoffset0:= xparoffset;
         nxpar0:= nxpar;
         ...
         xcompare(...);
         ...
         xparoffset:= xparoffset0;
         nxpar:= nxpar0;

         Such a search was successfully performed by BFn 2020-01-22.
         /BFn 2020-01-22. *)
      xparoffset:= xparoffset+nxpar;
      (* Set new number of <xp n> strings (where <xp 1> will be at
         npar + xparoffset + 1). *)
      nxpar:= tempnpar-(npar+xparoffset);
      end;
   end;

fsdispose(funcret);

if alflagga('D') then iodebugmess('<-xcompare');

end; (*xcompare*)


procedure xinitpn( var pstateenv: xstateenv );
(* Initilize all <p n> buffers *)

var i: xint16;
begin (*xinitpn*)
with pstateenv.pars do begin
  npar:= 0;
  invalidBecauseOfRpw:= false;
  xparoffset:= 0;
  // (old:) alDebugLog('xinitpn','xparoffset',inttostr(pstateenv.pars.xparoffset));
  nxpar:= 0;
  // (old:) alDebugLog('xinitpn','nxpar',inttostr(pstateenv.pars.nxpar));
  for i:= 1 to xmaxnpar do with par[i] do begin
    fs:= nil;
    atp:= pstateenv.cinp; afterp:= pstateenv.cinp;
    bitsAs:= 0;
    end;
  end;
end; (*xinitpn*)

procedure xresetpn( var pstateenv: xstateenv );
(* Clear all <p n> buffers *)

var i: xint16;
begin (*xresetpn*)
with pstateenv.pars do begin
  npar:= 0;
  invalidBecauseOfRpw:= false;
  xparoffset:= 0;
  // (old:) alDebugLog('xresetpn','xparoffset',inttostr(pstateenv.pars.xparoffset));
  nxpar:= 0;
  // (old:) alDebugLog('xresetpn','nxpar',inttostr(pstateenv.pars.nxpar));

  for i:= 1 to xmaxnpar do with par[i] do begin
    if fs<>nil then fsdispose(fs);
    atp:= pstateenv.cinp; afterp:= pstateenv.cinp;
    bitsAs:= 0;
    end;
  end;
end; (*xresetpn*)


procedure xdisposepn( var ppars: xparsrecord );
(* Dispose fs-strings connected to pn *)
var i: xint16;
begin
(* Dispose parameters. *)
with ppars do begin
  for i:= 1 to xmaxnpar do with par[i] do begin
    fsdispose(fs);
    end;
  for i:= 1 to npar do par[i].bitsAs:= 0;
  npar:= 0;
  end; (*with*)
end; (*xdisposepn*)

function xfstostr( pp: fsptr; pendch: char ): string
(* Instead of fstostr, to cope with eoa-termination. *);

var
s: string;

begin (*xfstostr*)

s:= '';

while not ((pp^=pendch) or (pp^=eofs)) do begin

    if (pp^=ctrlM) then s:= s + char(13) (*(used to be writeln)*)
    else s:= s + pp^;
    fsforward(pp);
    end;

if pp^<>pendch then xProgramError(
   'X(xfstostr): Program error. String did not end with '+
   'specified ending character ('+pendch+').');

xfstostr:= s;
end; (*xfstostr*)


procedure xevaluate( pxp: fsptr; ptillch: char;
                     pevalkind: xevalkind;
                     var pStateEnv: xStateEnv;
                     pretstr: fsptr );
(* EVALUERA pin FRAM TILL CH=PTILLCH. *)

(* pevalkind tells xevaluate what to do with the stuff.
   (see type xevaltype in the interface section). *)

(* If pevalkind=xevalwrite, and .nn returned from a <>-call - return
   .nn in pfuncret (needed for <R> and <J x-filename> to work).
   (See xcallstate.) *)

var
ch: char;
args: xargblock;
nr: xint16;
equal: boolean;
// (old:)jumpret: boolean;
newStateNr0: xint16;
pxp0,pxp1: fsptr;

begin (*xevaluate*)

pxp0:= pxp;

if pxp=NIL then (* - *)

else if pevalkind=xevalcompare then begin

    xcompare(pxp,ptillch,FALSE,false,pstateenv,equal);
    if not equal then begin
        if pstateenv.cinp^='#' then fspshend(pretstr,'x')
        else fspshend(pretstr,'#');
        end;
    end

else begin (* xevalwrite, xevalwcons, xevalnormal *)

    fsforwend(pretstr);

    while not ( (pxp^=ptillch) or (pxp^=eofs) or xfault) do begin

       ch:= pxp^;
       fsforward(pxp);

       (* Evaluate <..>-calls. *)
       if ch=stan then begin

            if iofdebug then begin
               pxp1:= pxp;
               fsback(pxp1);
               iofbreak(@pstateenv,pxp1);
               end;
            xdecodecall(pxp,nr,args);
            newStateNr0:= pstateenv.newstatenr;
            alcall(nr,args,pevalkind,pstateenv,pretstr);
            if (pevalkind=xevalwrite) or (pevalkind=xevalwcons)
               or (pevalkind=xevalsilent) then begin
                // (old:) jumpret:= pstateenv.newstatenr<>newStateNr0;

                (* (old:) if jumpret then
                   // If doing <r str>, leave output in pretstr.
                    fsforwend(pretstr)
                else *)
                if pevalkind=xevalwrite then begin
                    if pretstr^<> eofs then begin
                        if pstateenv.outstring then fsforwend(pretstr)
                        else iooutwritefs(pretstr,pstateenv.cinp);
                        end;

                    fsdelrest(pretstr);
                    end
                else if pevalkind=xevalwcons then begin
                    iofWriteToWbuf( xfstostr(pretstr,eofs) );
                    fsdelrest(pretstr);
                    end
                else if pevalkind=xevalsilent then begin
                    (* !/.../! - Throw any output. *)
                    fsdelrest(pretstr);
                    end;
                end; (* xevalwrite, xevalwcons, xevalsilent *)
            end (* stan *)

       else if pevalkind=xevalwrite then begin
         if pstateenv.outstring then fspshend(pretstr,ch)
         else iooutwrite(ch,pstateenv.cinp);
         end

       else if pevalkind=xevalwcons then begin
          if (ch=char(13)) then iofWritelnToWbuf('')
          else iofWriteToWbuf(ch);
          end

       else if pevalkind=xevalnormal then
           fspshend(pretstr,ch) (* xevalnormal *)
       else ;
           (* xevalsilent - throw ch *)
       end; (*while*)
    end; (* not xevalcompare *)

end; (*xevaluate*)


function countalts(pstate,psubstate: integer): integer;
var altptr: altp;
count: integer;
begin
if psubstate>0 then altptr:= grouptab[psubstate].caselist
else altptr:= grouptab[pstate].caselist;
count:= 0;
while altPtr<>nil do begin
   count:= count+1;
   altptr:= altptr^.next;
   end;
countalts:= count;
end;// (countalts)


function xdebuginfo(): string;
var s,fname: string;
var nr,filenr,groupnr: xint16;
begin
s:= '';
if (xCurrentStateEnv=nil)(* (Removed to get debuginfo also during load:) or (xloading>0) *) then
   (* - *)
else with xCurrentStateEnv^ do begin
   if xCurrentStateEnv.statenr>0 then begin
      if (statenr<0) or (statenr>substatetabend) then
         s:= 'state='+inttostr(statenr)
      else begin
         // Print name of file, group and state.
         filenr:= 0;
         groupnr:= 0;
         nr:= grouptab[statenr].definedIn;
         if nr>1 then begin
            if grouptab[nr].kind=a_group then begin
               groupnr:=nr;
               nr:= grouptab[nr].definedIn;
               end;
            end;
         if nr>1 then begin
            if grouptab[nr].kind=a_file then filenr:=nr;
            end;
         if filenr>0 then
            s:= 'File='+grouptab[filenr].name+'.x ';
         if groupnr>0 then
            s:= s+'group='+grouptab[groupnr].name+' ';
         s:= s+'state='+grouptab[statenr].name;
         end;
      if substatenr>0 then s:= s+' substate='+grouptab[substatenr].name;
      if altnr=0 then s:= s + ' preaction'
      else if altnr=999 then s:= s + ' postaction'
      else if altnr<=countalts(statenr,substatenr) then begin
        if xCurrentStateEnv.inInputPart then s:= s + ' in input part of'
        else s:= s + ' in output part of';
        s:= s + ' alternative nr '+inttostr(altnr);
        end;
      end;
   if macnr>0 then begin
      // Print name of file, group and function.
      filenr:= 0;
      groupnr:= 0;
      nr:= functab[macnr].definedIn;
      if nr>1 then begin
         if grouptab[nr].kind=a_group then begin
            groupnr:=nr;
            nr:= grouptab[nr].definedIn;
            end;
         end;
      if nr>1 then begin
         if grouptab[nr].kind=a_file then filenr:=nr;
         end;
      s:= s + ' (In user defined function ';
      if filenr>0 then
         s:= s+grouptab[filenr].name+'.';
      if groupnr>0 then
         s:= s+grouptab[groupnr].name+'.';
      fname:= xname(macnr);
      s:= s + fname+'.)';
      end;
   end;
if alLoadLevel>0 then begin
   // Error occured during compilation - add compilation info.
   s:= s + xCompInfo;
   end;
if length(s)>0 then s:= s + '.';
xdebuginfo:= s;
end;


(* New version: Starting in called substate *)

(* STATE MACHINE: *)
(*-------------------*)

(* X-based state machine for handling of menus etcetera.

   xCallState shall be able to support three cases:
   1. Calling a state and returning from it when <r ...> is found
      (the most common case).
   2. Calling a state and then jumping between states until <r ...> is found
      (Old style of jumping).
   3. Calling a state and then jumping to a substate and then between its
      substates until <r ...> is found (Gui style of jumping).

   At entry of the state:
   -  pstateenv.cstatenr points at the called state
   -  pstateenv.statenr points at the called state
   -  pstateenv.newstatenr points at the called state

   After a jump (<j ...>):
   -  pstateenv.newstatenr points at where to jump, which can be any state
      or a substate to the called state.

   Preaction:
   -  Shall always be done whenever entering a state by call (<c ...>)
   -  Shall be done when entering a state by jump (<j ...>) if the entered state
      is other than the called state. (the preaction of the called state is
      reserved for the call)

   Postaction:
   -  Shall always be done whenever leaving a state by return (<r ...>).
   -  Shall always be done when leaving a state by jump (<j ...>) if the left
      state is other than the called state. (the postaction of the called state is
      reserved for the call)
   -  This means that when leaving a state other than the called state with
      <r ...> then both the postaction of the current state (statenr) and that
      of the called state (cstatenr) are done.

   For the possible three cases mentioned above, the following program structures
   apply, to implement the above rules:

   1. Calling a state, that has no substates, and returning from it (both GUI
      and old style):
      Preaction(statenr)
      while (newStateNr=statenr)
         findalt
         xevaluate(outAction)
      PostAction(statenr)

   2. Calling a state, that has no substates, and jumping between (normal) states
      until <r ...> is found (old style of jumping):
      Preaction(cstatenr)
      while (newstatenr<>0)
         statenr:= newstatenr
         if statenr<>cstatenr Preaction(statenr)
         while (newStateNr=statenr)
            findalt
            xevaluate(outAction)
         if statenr<>cstatenr Postaction(statenr)
      PostAction(cstatenr)

   3. Calling a state that has one or more substates between whích it can jump
      (GUI style of jumping):
      Preaction(cstatenr)
      while (newstatenr<>0)
         statenr:= newstatenr
         if statenr<>cstatenr Preaction(substatenr)
         while (newStateNr=statenr)
            findalt
            xevaluate(outAction)
         if statenr<>cstatenr Postaction(statenr)
      Postaction(cstatenr)


   To combine these three cases, the following program structure was designed:

      PreAction(cStatenr)

      while (newstatenr<>0)

         statenr:= newStatenr

         if statenr<>cstatenr preAction(stateNr)

         while (newStateNr=statenr)
            findalt
            xevaluate(outAction)

         if statenr<>cstatenr postAction(stateNr)

      postAction(cStatenr)

*)
var blackliststr: string; (* (Put outside xcallstate to avoid timeconsuming
   initialisation at every call. *)

procedure xcallstate( var pstateenv: xstateenv; pfuncret: fsptr );

const
blacklistsize = 10; (* Max number of alternatives to skip because they do not
                       advance the input pointer. *)
var
p: altp; (* Currently evaluated alternative. Used to traverse the altarnatives
   in case list until a matching alternative is found. *)
equal: boolean; (* A matching alternative was found. *)

loopinp: ioinptr; (* Last input pointer. Used, together with loopcnt, to detect
   endless loops. *)
loopcnt: xint16; (* Number of turns without advancing the input pointer. *)

cinp0, cinp1: ioinptr; (* Input pointer before and after first preaction. Used to
   check that the called state does not add data to or remove data from the unread buffer. *)

blacklist: array[1..blacklistsize] of altp;(* Used to skip alternatives that do not
   forward the input pointer. *)
blacklistlast: integer; // Last valid entry in blacklist

alreadythere: boolean; (* Temporary variable used to avoid adding an entry to
   blacklist that is already there. *)

loopinp0: ioinptr; (* Used to avoid blacklisting alternatives if that advance
   the input pointer in input part and then reset them in the output part
   (normally using <unread>). *)

blacklisted1: boolean; (* Temporary variable used to check that first alternative
   in alternative list is not blacklisted. *)

i: integer; // Index in blacklist

infilep: iofileptr; (* Input file pointer (from io). Used to release readpointer
   after executing outaction of an alternative. *)

bp: altp; bnr: integer; (* Used to identify blacklisted alternatives in error message. *)

inputfile: Pointer; (* Remembers the input file that was used in ?"..."?.
   Used by unrCheckRelease, to release unread strings. *)


procedure setupDataBeforeFirstPreaction;
(* Only called after first preaction. *)
begin
pstateenv.cinp0:= nil; // cinp0 set by iounread
cinp0:= nil; // saved cinp0 for later check.

end; (*setupDataBeforeFirstPreaction*)


procedure setupDataAfterFirstPreaction;
(* Only called after first preaction. *)
begin

if pstateenv.cinp0<>nil then
   (* <unread ...> was called in preaction. Save the value that cinp had
      just before the unread, for later check. *)
   cinp0:= pstateenv.cinp0;

if pstateenv.compare then begin
   (* We are in <case ...> or <ifeq ...> - <c ...> is only allowed
      if string,local, because the original file pointer will be restored
      afterwards (cinp is not valid reading from the current file here). *)
   if (pstateenv.stringInputPtr=nil) then xScriptError('<c '+pstateenv.statename+
      '>: Unable to call state which reads from a file, from'+
      ' <ifeq ...>, <case ...> or <eq ...> (exits).');
   end;

end; (*setupDataAfterFirstPreaction*)


function nextalt(paltp: altp):altp;
var next: altp; blacklisted: boolean; i: integer;
   (* Look through all alternatives in the caselist. Skip blacklisted
      alternatives. Update altnr for error messages. *)
begin
next:= paltp^.next;
with pstateenv do altnr:= altnr+1;

if next<>nil then begin
   (* See if this alt is "blacklisted" meaning that it succeeded last turn but
      without advancing the pointer. *)
   blacklisted:= False;
   for i:= 1 to blacklistlast do
      if next=blacklist[i] then blacklisted:= True;

   if blacklisted then
      (* Find next alt by calling the same function recursively. *)
      next:= nextalt(next);
   end; (* <>nil *)

nextalt:= next;

end; (*nextalt*)

begin (*xcallstate*)

(* 1. Blacklist table initially empty. *)
blacklistlast:= 0;

(* 2. Set up data before first preaction. *)
setupDataBeforeFirstPreaction;

(* 3. Set up neutral 'after preaction' data, just in case (defensive programming). *)
cinp1:= nil;

(* 4. Keep track of calling level. *)
xstatecalllevel:= xstatecalllevel+1;

if xstatecalllevel > xstatestacksize then xScriptError(
   'xcallstate: Very deep state call level detected: '+
   inttostr(xstatestacksize)+'.');

fsnew(pstateenv.rstr);

pstateenv.altnr:= 0; // (=preaction)

(* 5. PreAction(cStatenr) *)
xevaluate(grouptab[pstateenv.cstatenr].pre,eofs,xevalwrite,pstateenv,pfuncret);
setupDataAfterFirstPreaction;

(* 6. Run state machine. *)
with pstateenv do while (newstatenr<>0) and not xFault do begin

   (* This loop is used when jumping between different states. *)

   if (newstatenr<statetabstart) or (newstatenr>substatetabend) then
      xProgramError('X(xcallstate): Program error - new jump state '+
         inttostr(newstatenr)+' does not exist (it is not in the state part ' +
         'of the table (entry ' + inttostr(statetabstart) + '..' +
         inttostr(substatetabend) + ').')

   else begin (* newstatenr within legal range *)

      // Catch exceptions so we can know where they happened.
      try

         (* 7. statenr:= newStatenr *)
         StateNr:= newStateNr;

         altnr:= 0; //(=preaction)

         (* 8. if statenr<>cstatenr preAction(stateNr) *)
         if statenr<>cstatenr then
            xevaluate(grouptab[statenr].pre,eofs,xevalwrite,pstateenv,pfuncret);

         loopcnt:= 0; loopinp:= cinp;
         (* Clear blacklist. *)
         blacklistlast:= 0;
         altnr:=0;

         (* 9. while (newStateNr=statenr)
                  findalt
                  xevaluate(outAction) *)
         while (newStateNr=stateNr) and not xFault do begin

            (* Go to state. *)

            p:= grouptab[stateNr].caselist;
            altnr:= 1;

            (* See if first alt is blacklisted (this function is later included
               automatically in nextalt). *)
            if p<>nil then begin
               blacklisted1:= False;
               for i:= 1 to blacklistlast do
                  if p=blacklist[i] then blacklisted1:= True;

               if blacklisted1 then
                  (* Use next alt instead (nextalt will also check for blacklist. *)
                  p:= nextalt(p);
               end; (* <>nil *)

            equal:= FALSE;

            (* Store the current position (for the <unread>, <p 0> and
               <replacewith ...> functions). *)
            inpback:= cinp;

            (* Reset last pos pointer. *)
            ioinlastpos:= cinp;
            xfailpos:= ioinlastpos;

            (*  For debug messages: *)
            inInputPart:= True;

            (* Reserve readpos to prevent if from being advanced before the
               output part has been fully evaluated. This is to protect data that
               can be accessed by <p n> in the output part. *)
            ioinReservereadpos(cinp,infilep);

            while not ( (p=NIL) or (equal) ) do begin

               if alflagga('D') then begin
                  iodebugmess('COMPARE: cinp="'+ioptrtostr(cinp)+'"'
                  +'kompin="'+fstostr(p^.kompin)+'"');
                  end;

               (* (xcompare does not move pinp unless success.) *)
                  xcompare(p^.kompin,eofs,true,false,pstateenv,equal);
               if not equal then begin
                  (* p:= p^.next; *)
                  p:= nextalt(p);

                  (* Get position where most successful alternative failed. *)
                  xfailpos:= ioinlastpos;
                  end;
               end; (* while *)

            (*  For debug messages: *)
            inInputPart:= False;

            // For <p 0> ...
            inpend:= cinp;

            if equal then begin
               if alflagga('D') then begin
                  iodebugmess('ALT found, response="'+fstostr(p^.kompout)+'"');
                  end;

               (* This is how far the input pointer has advanced in the input part
                  of the alternative. Avoid blacklisting if input pointer has advanced
                  before action part but not after, because the latter can be the
                  result of intentional <unread> to save the line for later use.
                  (Script evaluate.merge would not work otherwise). *)
               loopinp0:= cinp;

               (* Save the pointer to the input file that was used in ?"..."?,
                  in case that xevaluate will change the current input file.
                  (to be used by unrCheckRelease below) *)
               inputfile:= xio.iogetinfileptr;

               xevaluate(p^.kompout,eofs,xevalwrite,pstateenv,pfuncret);

               // New unread garbage collection (May 2018),
               if xunr.active then begin
                  (* Release the unread strings created since call of this state,
                     and consumed in preceding ?"..."? (or possibly during !"..."!). *)
                  if xunr.leavingUnrbuf(inpback,inpend) then begin
                     // Same file?
                     if xio.iogetinfileptr = inputfile then begin
                        // We have left the unread buffer, release unread strings if possible
                        if (xunr.unrCheckRelease(inputfile,pstateenv.cinp)) then
                           // Sign of progress => reset loop detection
                           loopCnt:= 0;
                        end;
                     end;
                  end;

               end
            else begin
               if blacklistlast>0 then begin
                  blackliststr:= ', and alternative';
                  if blacklistlast>1 then blackliststr:= blackliststr+'s';

                  for i:= 1 to blacklistlast do begin
                     bp:= grouptab[stateNr].caselist;
                     bnr:= 1;
                     while (bp<>blacklist[i]) and (bp<>nil) do begin
                        bp:= bp^.next;
                        bnr:= bnr+1;
                        end;
                     if bp=blacklist[i] then blackliststr:= blackliststr+' '+inttostr(bnr)
                     else blackliststr:= blackliststr+' ?'
                     end;
                  if blacklistlast>1 then blackliststr:= blackliststr+' were'
                  else blackliststr:= blackliststr+' was';
                  blackliststr:= blackliststr + ' skipped because of its inability to advance the input pointer'
                  end
               else blackliststr:= '';
               if cinp^=eofs then
                  xScriptError(
                  'X: Warning - Unable to match input to an alternative'+blackliststr+' - exits.' +
                  char(13) + 'Input file = '+ioinfilenamestr+', input = (end of file).')
               else xScriptError(
                  'X: Warning - Unable to match input to an alternative'+blackliststr+' - exits.' +
                  char(13) +'Input file = '+ioinfilenamestr+', input = "'+ioptrtostr(cinp)+'".');
               end;

            ioinReleaseReadpos(infilep);

            (* Check for endless loop: *)
            if cinp<>nil then if cinp^=eofr then begin
               loopcnt:= 0;
               (* Fragments (from sockets) can end on the same position. *)
               blacklistlast:= 0;
               end;

            if (cinp=loopinp) then begin

               (* Input pointer has not moved since last alt. *)

               if cinp=loopinp0 then begin
                  (* Loopinp0 is the position of cinp after the input part
                     of the alternative. *)
                  (* Put it on the blacklist unless already there. *)
                  alreadythere:= false;
                  if blacklistlast>0 then if blacklist[blacklistlast]=p then
                     alreadythere:= True;
                  if not alreadythere and (blacklistlast<blacklistsize) then begin
                     blacklistlast:= blacklistlast+1;
                     blacklist[blacklistlast]:= p;
                     end;
                  end;

               loopcnt:= loopcnt + 1;
               if loopcnt>100 then begin

                  if xresetloopdetection then begin
                     (* Input pointer has advanced in some other file. Wait. *)
                     loopcnt:= 0;
                     xresetloopdetection:= False;
                     end
                  else begin

                     if p<>nil then xScriptError(
                        'X: Endless loop in '+grouptab[stateNr].name+
                        'Input file = '+ioinfilenamestr+', input = "'+ioptrtostr(cinp)+'". '+
                         'Last accepted alternative = nr '+
                         inttostr(altnr))
                     else
                        xScriptError('X: Endless loop in '+grouptab[stateNr].name+'.');
                     end;
                  end; (* loopcnt>100 ... *)
               end
            else begin
               loopcnt:= 0;
               loopinp:= cinp;
               (* Clear blacklist. *)
               blacklistlast:= 0;
               end;

            end; (* while newStateNr=stateNr and not xFault *)

         altnr:= 999; // (= postaction)

         (* 10. if statenr<>cstatenr postAction(stateNr) *)
         if statenr<>cstatenr then
            xevaluate(grouptab[StateNr].post,eofs,xevalwrite,pstateenv,pfuncret);

      except on E:exception do
         raise exception.create('Exception:'+e.message +'state='+grouptab[stateNr].name+' altnr='
            +inttostr(altnr)+'(0=preact,999=postact).');
         end; (* try *)

      end; (* newstatenr within legal range *)

   (* (old:)Send return string to pfuncret
   if rstr^<>eofs then begin
      fscopy(rstr,pfuncret,eofs);
      fsrewrite(rstr);
      end;*)
   end; (* while newstatenr<>0 and not xFault *)

with pstateenv do begin
   (* 11. postAction(cStatenr) *)
   altnr:= 999; // (= postaction)
   xevaluate(grouptab[cstatenr].post,eofs,xevalwrite,pstateenv,pfuncret);

   // 12. Send return string to pfuncret
   if rstr^<>eofs then begin
      fscopy(rstr,pfuncret,eofs);
      fsrewrite(rstr);
      end;

   (* 13. Restore input if <in ...,string> was used. *)
   if (stringInputPtr<>nil) then
      iounread(nil,eoa,iounrpop,pstateenv);

   fsdispose(rstr);
   end;

(* 14. Check unread buffer - If unread was called during preaction (cinp0<>nil),
   then all unread text must have been read away in the state. *)
// (new:)
if not xFault then iocheckexitstate(pstateenv,cinp0);
// (old:) if not xFault then iocheckexitstate(pstateenv,cinp0,cinp1);

(* 14. Keep track of call depth. *)
xstatecalllevel:= xstatecalllevel-1;

end; (*xcallstate*)


procedure xinalt(pstatenr,paltnr: integer; paltstate: xaltstatetype; pxpos: fsptr;
   var pfound: boolean; var pxinpos: fsptr);
(* Check if pxpos points at the out-string of alt (paltnr) in state (pstatenr).
   Then set pfound and let pxinpos to point at the in string of that alt, else nil.
   If altnr=0 or 999, check preact and postact instead. *)
var altptr: altp; nr: integer; statenr: integer;
begin
pxinpos:= nil;
if pstatenr=0 then pfound:= false
else begin
   statenr:= pstatenr;
   with grouptab[statenr] do if paltnr=0 then pfound:= pxpos=pre
   else if paltnr=999 then pfound:= pxpos=post
   else begin
      nr:= 1;
      altptr:= caselist;
      if altptr=nil then nr:= 0
      else while (nr<paltnr) and (altptr<>nil) do begin
         altptr:= altptr^.next;
         if altptr<>nil then nr:= nr+1;
         end;
      if (nr=paltnr) then if (pxpos=altptr^.kompout) then begin
         pfound:= true;
         pxinpos:= altptr^.kompin;
         end;
      end;
   end;
end; (*xinalt*)


procedure xsetcompileError;
(* Set xCompileErrorActive if a file is being loaded.
   Used to stop compilation after errors detected in XAL (for instance by aldef). *)
begin
if xloading>0 then xCompileErrorActive:= True;
end;

function xgetcompileError: boolean;
(* Get xCompileErrorActive. Used by alload. *)
begin
xGetcompileError:= xCompileErrorActive;
end;

function kindStr(pkind: integer): string;
begin
if pkind=1 then kindstr:= 'c '
else if pkind=2 then kindstr:= 'j '
else if pkind=3 then kindstr:= 'c_lateevaluation '
else kindstr:= 'c/j ';
end;

procedure resolveStateRef(pn: integer);
(* Resolve each state reference (from <c ...>, <j ...> or <c_lateevaluation ...>)
   which was stored during the loading of one x file.
   Example:
   for i:= staterefstarttab[staterefloadlevel]+1 to staterefcount do
      resolvestateref(statereftab[i]);

 *)
var
part1, part2, part3: string;
found: boolean;
statenr, parent, line: integer;
i,cnt,part,currentgroupnr,validfilenr, validgroupnr, validstatenr,
   validsubstatenr, chosenstatenr, arglen: integer;
definedInFile, definedInGroup: integer;
arg1ptr, ptr, ptrx: fsptr;
refkind: integer;

// ++
defgroup,refgroup: integer;

begin

statenr:= 0;
with stateRefTab[pn] do begin
   arg1ptr:= stateRef;
   currentgroupnr:= groupNr;
   refkind:= cjkind;
   end;

// Get nr of file, group, state and substate from grouptab
validFileNr:= 0;
validGroupNr:= 0;
validStateNr:= 0;
validSubStateNr:= 0;
with grouptab[currentgroupnr] do begin
   if kind=a_file then begin
      validFileNr:= currentGroupNr;
      end
   else if kind= a_group then begin
      validGroupNr:= currentGroupNr;
      validFileNr:= groupTab[currentGroupNr].definedIn;
      end
   else if kind= a_state then begin
      validStateNr:= currentGroupNr;
      validFileNr:= groupTab[currentGroupNr].definedIn;
      if grouptab[validFileNr].kind=a_group then begin
         validGroupNr:= validFileNr;
         validFileNr:= grouptab[validGroupNr].definedIn;
         end;
      end
   else if kind = a_subState then begin
      validSubstateNr:= currentgroupnr;
      validStateNr:= groupTab[currentGroupNr].definedIn;
      validFileNr:= groupTab[validStateNr].definedIn;
      if grouptab[validFileNr].kind=a_group then begin
         validGroupNr:= validFileNr;
         validFileNr:= grouptab[validGroupNr].definedIn;
         end;
      end
   end;

ptr:= arg1ptr;
part:= 1; // look for part1 first

// Identify part1.part2, or part1
part1:= '';
part2:= '';
part3:= '';
arglen:= 0;
while not ( (ptr^=eoa) or (part=4) ) do begin
   case part of
      1: begin
         if ptr^='.' then part:= 2 // Look for part2
         else part1:= part1 + ptr^;
         end;
      2: begin
         if ptr^='.' then part:= 3 // Look for part 3
         else part2:= part2 + ptr^;
         end;
      3: begin
         if ptr^='.' then part:= 4 // (> 3 parts: error)
         else part3:= part3 + ptr^;
         end;
      end;
   fsforward(ptr);
   arglen:= arglen+1;
   // (new: Read past tailing ".x")
   if ptr^='.' then begin
      // Ignore ".x"
      ptrx:= ptr;
      fsforward(ptrx);
      if fslcWsTab[ptrx^]='x' then begin
         fsforward(ptrx);
         if ptrx=eoa then ptr:= ptrx;
         end;
      end;

   end;

if part>3 then
   xScriptError('ResolveStateRef: State name "'+ alfstostr100(arg1ptr,eoa) +
      '" contains three dots "." (or more) - zero, one or two were expected.')

else if arglen>50 then
   xScriptError('ResolveStateRef: State name ('+ alfstostr100(arg1ptr,eoa) +
      ') was expected to be max 50 char''s long but this was ' +
      inttostr(arglen) + ' characters.')

(* 2. Get state (or substate) number. *)
else begin

   (* Shift names to the right as far as it goes, and convert to lower
      case to be able to compare with names in grouptab. *)
   if part=1 then begin
      part3:= part1;
      part1:= '';
      lowercase(part3);
      end
   else if part=2 then begin
      part3:= part2;
      part2:= part1;
      part1:= '';
      lowercase(part2);
      lowercase(part3);
      end
   else begin (* (part=3) *)
      lowercase(part1);
      lowercase(part2);
      lowercase(part3);
      end;

   statenr:= 0;
   chosenstatenr:= 0;
   cnt:= 0;

   // ++
   defGroup:= 0;
   refGroup:= 0;

   // 1. Look for states
   repeat
      xseeknextgroup(part3,a_state,statenr);
      if statenr>0 then begin
         found:= false;
         if part2='' then begin
            (* Part3. Only statename given. It can be referenced from the same
               group, or if there is no group, from anywhere in the same
               file. *)
            parent:= grouptab[statenr].definedIn;
            if grouptab[parent].kind=a_group then begin
               definedInGroup:= parent;
               definedInFile:= grouptab[parent].definedIn;
               if definedInGroup = validGroupNr then found:= true
               else begin
                  // ++
                  defgroup:= definedInGroup;
                  refGroup:= validGroupNr;
                  end;
               end
            else if grouptab[parent].kind=a_file then begin
               definedInGroup:= 0;
               definedInFile:= parent;
               if definedInFile = validFileNr then found:= true
               else if validFileNr = 0 then Begin
                  (* If called from X window, states in the top loaded file
                     are visible.
                  if fsEqual(grouptab[parent].name,alTopLoadShortName) then
                     found:= true;
                  *)
                  if definedInFile = alTopLoadNr then found:= true
                  end;
               end;
            end
         else if part1='' then begin
            (* Part2.part3. Parent (File or Group) and statename are given. Check File/Group. *)
            parent:= grouptab[statenr].definedIn;
            if part2=grouptab[parent].name then begin
               (* If parent is file, then it is ok (global access),
                  else if it is group, then check that it belongs to same file. *)
               if grouptab[parent].kind=a_file then found:= true
               else if grouptab[parent].definedIn = validFileNr then found:= true
               (* If called from X window, accept if defined in the top loaded file. *)
               else if validFileNr = 0 then begin
                  if grouptab[parent].definedIn = alTopLoadNr then
                     found:= true;
                  end;
               end;
            end
         else begin
            (* part1.part2.part3. grandparent (file), parent (group) and statename are given.
               Check them. *)
            parent:= grouptab[statenr].definedIn;
            if grouptab[parent].name=part2 then begin
               parent:= grouptab[parent].definedIn;
               if grouptab[parent].name=part1 then found:= true;
               end;
            end;
         if found then begin
            cnt:= cnt+1;
            chosenStateNr:= stateNr;
            end;
         end; // (statenr>0)
      until statenr=0;

   // 2. Look for sub states
   repeat
      xseeknextgroup(part3,a_subState,statenr);
      if statenr>0 then begin
         found:= false;
         if part2='' then begin
            (* part3. Only substatename given. It can be referenced from anywhere
               within the same state. *)
            parent:= grouptab[statenr].definedIn;
            if (parent=validStatenr) then found:= true;
            end
         else if part1='' then begin
            (* part2.part3. Statename and substatename given. Check the
               statename. It can only be referenced from within the same
               state (part2 is unnecessary). *)
            parent:= grouptab[statenr].definedIn;
            if grouptab[parent].name = part2 then begin
               if parent=validStateNr then found:= true;
               end;
            end;
         if found then begin
            cnt:= cnt+1;
            chosenStateNr:= stateNr;
            end;
         end;// (statenr>0)
      until statenr=0;

   if cnt=0 then begin
      if xLoading>0 then
         xCompileError2('State reference <'+kindstr(refkind)+alfstostr100(arg1ptr,eoa)+
            '> could not be resolved. The state does not exist or is not '+
            'visible where it is referenced.' +
            '(refgroup='+inttostr(refgroup)+', defgroup='+inttostr(defgroup) +
            ').'
            )
      else xScriptError(alfstostr100(arg1ptr,eoa) +
         ' does not exist or is not visible here.')
      end
   else if cnt>1 then
      xProgramError(alfstostr100(arg1ptr,eoa) +
         ' is visible ' + inttostr(cnt) + ' times (only one was expected).')
   else begin
      (* Replace state name by state number. *)
      ptr:= arg1ptr;
      ptr^:= '@';
      fsforward(ptr);
      ptr^:= char(chosenstatenr div 250);
      fsforward(ptr);
      ptr^:= char(chosenstatenr mod 250);
      fsforward(ptr);
      ptr^:= eoa;
      end;
   end;

end; (* resolveStateRef *)


// Resolve and remove an entry in statereftab. Used by alC.
procedure xResolveAndRemove(prefptr: fsptr);
   var i,j: integer;
   found: boolean;
begin

i:= stateRefCount; found:= false;
while (i>0) and not found do begin
   if statereftab[i].stateRef=prefptr then found:= true
   else i:= i-1;
   end;
if found then begin
   if i<= stateRefStartTab[stateRefLoadLevel] then
      xCompileError2('A state ('+ alfstostr(prefptr,eoa) + ') was called before ' +
         'the script where it was located was fully compiled. This is only ' +
         'possible from the same file as where the state is located. But this ' +
         'reference appears to be from another file.')
   else begin
      resolveStateRef(i);
      // Remove the reference by moving all references above it one step down.
      for j:= i+1 to staterefcount do statereftab[j-1]:= statereftab[j];
      staterefcount:= staterefcount-1;
      end;
   end;

(* There are two possible reasons why a state reference is not found in the
   table. See procedure alC in xal.pas. *)

end; (* xResolveAndRemove *)



procedure xload(
   pfilegroup: string; (* "" or other name to be used instead of filename. *)
   pfilename:fsptr; (* In: Filename *)
   pShortName: boolean; (* In: original filename had no path. E.g. "test1.x"
      Used by ioxreset when looking for internal files. *)
   var pstateenv: xstateenv; (* In: ppars (<p n>), in/out: cinp *)
   var pfileNumber: xint16) (* out: Filenumber. *)

(* Compile and load an x-file.

   Execute <...>-calls. Build states from state-definition code:

   <...>         - <def ...> or <var ...> will be global in file (and can be
                   imported from other files)

   Groupname  - Name of Group. Clears state to enable additional
   =========    global macro definitions (<def ...>).

   <...>        - <def ...> or <var ...> will be local to group.


   statename    - Name of state.
   ---------

   substatename    - Name of substate.
   ............

   <...>        - <def ...> or <var ...> will be local to state.

   !"..."!      - Executed at entrance to a state

   ?"..."?
   !"..."!      - An alternative - in- and out-part

   !"..."!      - Executed at exit from a state

    -(new line) - Continue on next line

    ........... - End of substate. Continue on current state, group or file.
                  Enables <...> to be written after and between substate definitions.

    ----------- - End of state. Continue on current group or file.
                  Enables <...> to be written after and between state definitions.

    =========== - End of Group. Continue on current File.
                  Enables <...> to be written after and between group definitions.

*);

(* Statemachine using xcompilestring, xcompare and xevaluate. *)

var
filegroupname: string;  (* = the name of the file. *)
statenr: xint16;(* >0 for state or substate, otherwise 0. *)
statename: string;

exprstr: fsptr; (* Temporary storage for input and output strings. *)
exprstr0: fsptr; (* Pointer to 1st char in str. *)
strut: fsptr; (* Compiled version of str. *)
outstr: fsptr; (* Result from evaluation of strut. *)

readstate,oldreadstate,dbgreadstate(* debug *),savereadstate :
    (start,variableref,preact,afterpreact,altin,afteraltin,altout,
   postact,afterpostact);  (* State machine for reading X file. *)

endfile: boolean;
depth: xint16; (* <..>-depth. *)
stringdepth: xint16; (* !"..."!, ?"..."? or !/.../!-depth - 0 or 1. *)
olddepth: xint16;

ch1,ch2: char; (* From xreadchar. *)
special: boolean; (* From xreadchar. *)

p: altp; (* Temporary pointer into alternative list in state. *)
last: altp; (* Pointer to last case in caselist. *)

ext: char;  (* '.': test if next is x, 'x':extention =.x *)
fp: fsptr; (* Next char to read from pfilename. *)

sepstr,sepstr0: fsptr;
exprstr0lineno: xint16; (* Used to indicate start of a set of lines where an error
 occurred (see errorroutine2). *)
sp: fsptr; (* Locally used in altin to remove trailing blanks on input line. *)

n,found,i: integer;

dmess: string; (* debug *)

ststr: string;
writeaction: boolean;

errorfound: boolean;
savegroupnr: integer;

(* Saved values to restore x-file local settings after load: *)
saveCheckVar: boolean;
saveuseindentation: boolean;
saveCompileAlts: boolean;
saveAllowFunctionCallsAfterPreact: boolean;
saveAllowBlanksBeforeCommentToEoln: boolean;
pendingNewLine: boolean; (* For $name reference on top level: If followed by
   <...> expression instead of CR - evaluate this also before adding CR
   to write buffer. *)

// To remember state when adding a substate (see also savereadstate):
savestatenr: integer;
savelast: altp;


(* xreadchar (local to xload) *)
(******************************)

var
xrc: record
     prevch: char;
     ch,nextch: char;
     blockComment: boolean; // "(* ... *)"
     linecomment: boolean; // "//..."
     quote: boolean; // "'x"
     next: boolean; // There is a next character (nextCh) (not eof)
     lineno: xint16;
     infuncname: boolean;
     end;

procedure xCompileError(perrmess: string);
begin
   ioerrmessCompile(perrmess + ' File '+ioUni2iso(basicfilename(fstostr(pfilename)))
      +': Line nr '+inttostr(xrc.lineno)+'.');
   xCompileErrorActive:= true;
   ErrorRoutineLevel:= xloading;
end;

procedure xrcinit;
var feof: boolean;
begin
with xrc do begin
    prevch:= ' ';
    ch:= ' ';
    nextch:= ' ';
    blockComment:= false;
    linecomment:= false;
    quote:= false;
    ioxread(nextch,feof);
    next:= not feof;
    lineno:= 1;
    infuncname:= false;
    end;
end;

procedure errorroutine; forward;

(* (new: Removing detection of '-' at end of line in readch after comment,
   because this is already detected in xreadchar1, and when it it detected
   in readCh, it does not work in combination with '-' at the beginning of next
   line. Example:
   <function test,
   -<wcons Bla bla bla-
   --bla bla.>
   -<wcons Blu blu blu( *...* )-
   --blu blu.>
   ->
   *)
procedure xreadchar1( var pch1,pch2: char; var pspecial, pendfile: boolean);
(* Original version. *)

var count: integer; i: integer; s1,s2: string;

   procedure readch; (* OUTPUTS: prevch,ch,nextch,pendfile *)
   var feof: boolean; funcincom: integer; comstart: integer;
   begin
   with xrc do begin

      prevch:= ch;
      ch:= nextch;
      pendfile:= not next;
      ioxread(nextch,feof);
      next:= not feof;
      if (ch=ctrlM) then lineno:= lineno+1;

      // (new:)
      while ((ch='(') and (nextch='*') or (ch='/') and (nextch='/')) and
         not xCompileErrorActive do begin (* comment *)

         if (ch='(') and (nextch='*') then blockComment:= true else linecomment:= true;
         funcincom:= 0; comstart:= lineno;

         // After the loop, ch shall contain the first char after the comment.
         while linecomment and not feof and not xCompileErrorActive do begin

            // (new:)
            if nextCh=ctrlM then begin
               // End of comment - ch was the last character of the comment
               lineComment:= false;
               if infuncname then
                  // Change the last char of the comment to a blank
                  ch:= ' '
               else begin
                  // Normal - nextCh contains CtrlM. Move it to ch and read one more char
                  ch:= nextch;
                  pendfile:= not next;
                  ioxread(nextch,feof);
                  next:= not feof;
                  lineno:= lineno+1;
                  end
               end
            else begin
               ch:= nextch;
               pendfile:= not next;
               ioxread(nextch,feof);
               next:= not feof;
               end;

            (* (old:)
            if (ch=ctrlM) then begin
               lineno:= lineno+1;
               linecomment:= false;
               ch:= nextch;
               pendfile:= not next;
               ioxread(nextch,feof);
               next:= not feof;
               end;
               *)
            end;

      // Old: while (ch='(') and (nextch='*') and not xCompileErrorActive do begin (* comment *)
         // (old:) comment:= true; funcincom:= 0; comstart:= lineno;

         // After the loop, ch shall contain the first char after the comment.
         while blockComment and not feof and not xCompileErrorActive do begin

            ch:= nextch;
            pendfile:= not next;
            ioxread(nextch,feof);
            next:= not feof;
            if (ch=ctrlM) then lineno:= lineno+1;

            if (ch=ctrlM) and (nextch='<') and (funcincom=0) then funcincom:= lineno;

            if (ch='(') and (nextch='*') then xcompileerror(
               'X(<load ...>): Comment started at line ' +
               inttostr(comstart) + ' contained comment begin ("(*") when '+
               'comment text or comment end ("*)") was expected.');

            if (ch='*') and (nextch=')') then begin

               blockComment:= FALSE;
               // prevch is still the last character before the comment.
               (* Two characters shall be read here, the first to ch and the next
                  to nextcn. The code is simplified to read directly to ch first time
                  and to nextcn second time. *)
               ioxread(ch,feof);
               if (ch=ctrlM) then lineno:= lineno+1;

               if (ch=ctrlM) and infuncname then begin
                  // Insert blank (because of new line)
                  ch:= ' ';
                  (* Pretend we are still on the previous line (otherwise lineno
                     will be incremented twice). *)
                  lineno:= lineno-1;
                  pendfile:= false;
                  nextch:= ctrlM;
                  next:= not feof;
                  end

               else begin

                  pendfile:= feof;
                  ioxread(nextch,feof);
                  next:= not feof;

                  (* Removed:
                  ( * If '-' and new line, skip to next line. * )
                  if (ch='-') and (nextch=char(13)) then begin
                     // (new:)
                     prevch:= ch; // '-'

                     lineno:= lineno+1;
                     ioxread(ch,feof);
                     if (ch=ctrlM) then lineno:= lineno+1;
                     pendfile:= feof;
                     ioxread(nextch,feof);
                     next:= not feof;
                     end;
                  *)
                  end;// (else)
               end; // (if ch=* and nextch=*)
            end; (*while comment and feof ... *)

         end; (*while ch=( ... *)

      if (ch='*') and (nextch=')') then xCompileError(
         'X(<load ...>): Comment end ("*)") outside comment found at line ' +
         inttostr(lineno) + '. Not allowed since it is normally caused by errors in commenting.' +
         'Use quoting (''*'')) for intentional "*)".');

      if pendfile then begin
         if blockComment or lineComment then
            xCompileError('X- Warning: X-file ends inside comment. ');
         end;
      end; (*with xrc *)

   end; (* local procedure readch *)

begin (*xreadchar1*)

with xrc do begin

   pendfile:= FALSE;
   if infuncname and (nextch=ctrlM) then
      (* ioxread removes invisible blanks at end of line, insert blank
         between function name and CR. *)
      ch:= ' '
   else
      readch;

   pch1:= ch; pch2:= ' '; pspecial:= FALSE;

   if quote then quote:= FALSE
   else begin

      (* Not quote - check if special ... *)
      if (pch1='<') or (pch1='>') then begin
         pspecial:= true;
         if (pch1='<') then begin
            depth:= depth+1;
            functionlevel:= functionlevel+1;
            infuncname:= True;
            end
         else begin
            (* '>' *)
            if (depth>0)  then begin
               depth:= depth-1;
               functionlevel:= functionlevel-1;
               end
            else begin
               xCompileError('X: Extra ">" in X-file.');
               (* To prevent secondary failures: *)
               pch1:= ' ';
               pspecial:= False;
               end;
            infuncname:= False;
            end;
         end
      else if pch1='$' then begin
         if nextch in xidchar1range then pspecial:= true;
         end
      else if ((prevch<>'-') and (pch1='-') and (nextch=ctrlM)) then begin
         (* Special: Single '-' at end of line. *)
         pspecial:= true;
         readch; pch2:= ch;
         end
      else if (depth+stringdepth>0) and (
         (prevch=ctrlm) and (pch1='-') or
         (pch1=ctrlM) and (nextch='-') )
         then begin

         (* Special: "-" in beginning of line. *)
         pspecial:= true;
         if pch1='-' then begin
            pch1:= ctrlm;
            pch2:= '-';
            end
         else begin
            readch; pch2:= ch;
            end;

         (* Check depth and remove. *)
         count:= 1;
         while nextch='-' do begin
            count:= count+1;
            readch;
            end;
         if count<>depth+stringdepth then begin
            s1:= '';
            for i:= 1 to count do s1:= s1+'-';
            s2:= '';
            for i:= 1 to depth+stringdepth do s2:= s2+'-';
            xCompileError('Warning: Level indicated by "-" ('+inttostr(count) +
                ') differs from string/function level. "'+s1+'" was found when "'+
                s2+'" was expected.');
            end;
         end (* - in beginning of line *)
      else begin
         if ((pch1='?') and (nextch='"'))
         or ((pch1='"') and (nextch='?'))
         or ((pch1='!') and (nextch='"'))
         or ((pch1='"') and (nextch='!'))
         then begin
             pspecial:= true;
             readch; pch2:= ch;
             end
         else if pch1='''' then quote:= true
         else if infuncname then begin
            if ch1=' ' then infuncname:= False;
            end;
         end; (* Not - in beginning of a line *)
      end; (* not Quote *)
   end; (* with Xrc *)

if alflagga('D') then begin

    if readstate<>dbgreadstate then begin
        case readstate of
            start: dmess:= dmess + 'readstate: start';
            preact: dmess:= dmess + 'readstate: preact';
            afterpreact: dmess:= dmess + 'readstate: afterpreact';
            altin: dmess:= dmess + 'readstate: altin';
            afteraltin: dmess:= dmess + 'readstate: afteraltin';
            altout: dmess:= dmess + 'readstate: altout';
            postact: dmess:= dmess + 'readstate: postact';
            afterpostact: dmess:= dmess + 'readstate: afterpostact';
            else dmess:= dmess + 'readstate: unidentified.';
            end;
        dbgreadstate:= readstate;
        end;

    if (ch1=ctrlm) and (length(dmess)>0) then begin
        iodebugmess(dmess);
        dmess:= '';
        end
    else begin
        if (ord(ch1)>=32) and (ord(ch1)<=252) then
            dmess:= dmess+'+'+ch1
        else dmess:= dmess+'+('+inttostr(ord(ch1))+')';

        if pspecial then begin

          if ch2<>' ' then begin
            if (ord(ch2)>=32) and (ord(ch2)<=252) then
              dmess:= dmess+ch2
            else dmess:= dmess+'('+inttostr(ord(ch2))+')';
            end;
          dmess:= dmess + '(spec.)';
          end;
        end;
    end; (* debug flag *)

end; (*xreadchar1*)


procedure xreadchar2( var pch1,pch2: char; var pspecial, pendfile: boolean);

(* New version with indentation. *)

var count: integer; i: integer; s1,s2: string;

   procedure readch; (* OUTPUTS: prevch,ch,nextch,pendfile *)
   var feof: boolean; funcincom: integer; comstart: integer;
   
   begin
   with xrc do begin

      prevch:= ch;
      ch:= nextch;
      pendfile:= not next;
      ioxread(nextch,feof);
      next:= not feof;
      if (ch=ctrlM) then lineno:= lineno+1;

      // Ignore empty lines
      repeat

         while ((ch='(') and (nextch='*') or (ch='/') and (nextch='/')) and
            not xCompileErrorActive do begin (* comment *)

            if (ch='(') and (nextch='*') then blockComment:= true else linecomment:= true;
            funcincom:= 0; comstart:= lineno;

            (* Note !!! The code below probably need to be modified in accordance
               with readchar1, in order to skip line comments properly.
               See testlinecomment.x. /BFn 2018-02-05. *)
            while linecomment and not feof and not xCompileErrorActive do begin

               ch:= nextch;
               pendfile:= not next;
               ioxread(nextch,feof);
               next:= not feof;
               if (ch=ctrlM) then begin
                  lineno:= lineno+1;
                  linecomment:= false;
                  ch:= nextch;
                  pendfile:= not next;
                  ioxread(nextch,feof);
                  next:= not feof;
                  end;
               end;

            while blockComment and not feof and not xCompileErrorActive do begin

               ch:= nextch;
               pendfile:= not next;
               ioxread(nextch,feof);
               next:= not feof;
               if (ch=ctrlM) then lineno:= lineno+1;

               if (ch=ctrlM) and (nextch='<') and (funcincom=0)
                 then funcincom:= lineno;

               if (ch='(') and (nextch='*') then begin
                   xCompileError('X(<load ...>): Comment started at line ' +
                    inttostr(comstart) + ' contained comment begin ("(*") when '+
                       'comment text or comment end ("*)") was expected.');
                   end;

               if (ch='*') and (nextch=')') then begin

                  blockComment:= FALSE;
                  ioxread(ch,feof);
                  if (ch=ctrlM) then lineno:= lineno+1;
                  pendfile:= feof;
                  ioxread(nextch,feof);
                  next:= not feof;
                  (* If '-' and new line, skip to next line. *)
                  if (ch='-') and (nextch=char(13)) then begin
                     lineno:= lineno+1;
                     ioxread(ch,feof);
                     if (ch=ctrlM) then lineno:= lineno+1;
                     pendfile:= feof;
                     ioxread(nextch,feof);
                     next:= not feof;
                     end;
                  end;

               end; (*while blockComment and ... *)

            end; (*while ch=( ... *)

         // Skip empty lines
         if (prevch<>'''') and (ch=ctrlm) and (nextch=ctrlm) and (depth+stringdepth>0) then begin
            prevch:= ch;
            ch:= nextch;
            pendfile:= not next;
            ioxread(nextch,feof);
            next:= not feof;
            if (ch=ctrlM) then lineno:= lineno+1;
            end;

         until (prevch='''') or (ch<>ctrlm) or (nextch<>ctrlm) or (depth+stringdepth=0);

      if (ch='*') and (nextch=')') then begin
         xCompileError('X(<load ...>): Comment end ("*)") outside comment found at line ' +
            inttostr(lineno) + '. Not allowed since it is normally caused by errors in commenting.' +
               'Use quoting (''*'')) for intentional "*)".');
         end;

      if pendfile then begin
         if blockComment or lineComment then
            xCompileError('X- Warning: X-file ends inside comment. ');
         end;
      end; (*with xrc *)

   end; (* local procedure readch *)

begin (*xreadchar2*)

with xrc do begin

   pendfile:= FALSE;
   if infuncname and (nextch=ctrlM) then
      (* ioxread removes invisible blanks at end of line, insert blank
         between function name and CR. *)
      ch:= ' '
   else
      readch;

   pch1:= ch; pch2:= ' '; pspecial:= FALSE;

   if quote then quote:= FALSE
   else begin
      if (pch1='<') or (pch1='>') then begin
         pspecial:= true;
         if (pch1='<') then begin
            depth:= depth+1;
            functionlevel:= functionlevel+1;
            infuncname:= True;
            end
         else begin
            (* '>' *)
            if (depth>0)  then begin
               depth:= depth-1;
               functionlevel:= functionlevel-1;
               end
            else begin
               xCompileError('X: Extra ">" in X-file.');
               (* To prevent secondary failures: *)
               pch1:= ' ';
               pspecial:= False;
               end;
            infuncname:= False;
            end;
         end
      else if (pch1='$') and (nextch in xidchar1range)then pspecial:= true

      else if (depth+stringdepth>0) and (
         (prevch=ctrlm) and (pch1=' ') or
         (pch1=ctrlM) and (nextch=' ') )
         then begin
         pspecial:= true;
         if pch1=' ' then begin
            pch1:= ctrlm;
            pch2:= ' ';
            end
         else begin
            readch; pch2:= ch;
            end;

         (* " " in beginning of line - Check depth and remove. *)
         count:= 1;
         while nextch=' ' do begin
            count:= count+1;
            readch;
            end;
         if count mod 3 <> 0 then begin
            s1:= '';
            for i:= 1 to count do s1:= s1+' ';
            xCompileError('Warning: Indentation in steps of three was expected,' +
               ' but number of spaces was ' + inttostr(count) + ' or "' +
               s1 + '".');
            end

         else if count<>(depth+stringdepth)*3 then begin
            s1:= '';
            for i:= 1 to count do s1:= s1+' ';
            s2:= '';
            for i:= 1 to depth+stringdepth do s2:= s2+'   ';
            xCompileError('Warning: Indentation level ' + inttostr(depth+stringdepth) +
               ' ("' + s2 + '") was expected but level ' + inttostr(count div 3) +
               ' ("' + s1 + '") was found.');
            end;
         end (* - in beginning of line *)
      else begin
         if ((pch1='?') and (nextch='"'))
         or ((pch1='"') and (nextch='?'))
         or ((pch1='!') and (nextch='"'))
         or ((pch1='"') and (nextch='!'))
         // '-' at end of line:
         or ((prevch<>'-') and (pch1='-') and (nextch=ctrlM))
         then begin
            pspecial:= true;
            readch; pch2:= ch;
            end
         else if pch1='''' then quote:= true
         else if infuncname then begin
            if ch1=' ' then infuncname:= False;
            end;
         end;
      end;
   end; (* with xrc *)

if alflagga('D') then begin

   if readstate<>dbgreadstate then begin
      case readstate of
         start: dmess:= dmess + 'readstate: start';
         preact: dmess:= dmess + 'readstate: preact';
         afterpreact: dmess:= dmess + 'readstate: afterpreact';
         altin: dmess:= dmess + 'readstate: altin';
         afteraltin: dmess:= dmess + 'readstate: afteraltin';
         altout: dmess:= dmess + 'readstate: altout';
         postact: dmess:= dmess + 'readstate: postact';
         afterpostact: dmess:= dmess + 'readstate: afterpostact';
         else dmess:= dmess + 'readstate: unidentified.';
         end;
      dbgreadstate:= readstate;
      end;

   if (ch1=ctrlm) and (length(dmess)>0) then begin
      iodebugmess(dmess);
      dmess:= '';
      end
   else begin
      if (ord(ch1)>=32) and (ord(ch1)<=252) then dmess:= dmess+'+'+ch1
      else dmess:= dmess+'+('+inttostr(ord(ch1))+')';

      if pspecial then begin

         if ch2<>' ' then begin
            if (ord(ch2)>=32) and (ord(ch2)<=252) then dmess:= dmess+ch2
            else dmess:= dmess+'('+inttostr(ord(ch2))+')';
            end;
         dmess:= dmess + '(spec.)';
         end;
      end;
   end; (* debug flag *)

end; (*xreadchar2*)


procedure xreadchar( var pch1,pch2: char; var pspecial, pendfile: boolean);
begin

if xUseIndentation then xreadchar2(pch1,pch2,pspecial,pendfile)
else xreadchar1(pch1,pch2,pspecial,pendfile);

end;


procedure errorroutine;
begin
   if xloading>=errorroutinelevel then
      (* The file where the error occurrs. *)
      ioErrmessWithDebugInfo('File '+basicfilename(fstostr(pfilename))
         +': Line nr '+inttostr(xrc.lineno)+'.')
   else
      (* The file from which the file with error was loaded. *)
      ioErrmessWithDebugInfo('(Loaded from file '+basicfilename(fstostr(pfilename))
         +' Line nr '+inttostr(xrc.lineno)+'.)');

   xCompileErrorActive:= true;
   ErrorRoutineLevel:= xloading;
end;


procedure errorroutine2(pstartlno:xint16);
begin
   if xrc.lineno=pstartlno then ioerrmessCompile('File '+basicfilename(fstostr(pfilename))
      +': Line nr '+inttostr(xrc.lineno)+'.')
   else ioerrmessCompile('File '+basicfilename(fstostr(pfilename))
      +': Within lines nr '+inttostr(pstartlno)+'...'+inttostr(xrc.lineno)+
      '.');
   xCompileErrorActive:= true;
   ErrorRoutineLevel:= xloading;
end;

// (new:) (with direct calls to xCompileError)
procedure readsepstr;
(* Next character is available in ch1.

   Algorithm: Add characters to string sepstr until new line. Then
   test if string is a valid state/group name.

   This is called after having read not special characters at
   top level. sepstr contains those characters. This procedure
   assumes that those characters are the name of a new state
   or group.

   This text means "new group" (new global <def ...>'s allowed):

       (Groupname)
       ===========

   This text means "new state":

       (statename)
       -----------

   where (statename) consists of printable characters but not more
   than 32.

   Example of new state with specified input file:

      state.x
      -------
*)

type
underlinekindtype = (ulfile,ulgroup,ulstate);

var
strp: fsptr;
errorfound: boolean;
newname: string;
newstatenr: xint16;
errstr: string;
dashcnt, eqcnt, dotcnt: xint16;
finished: boolean;
ext: char;

underlinekind: underlinekindtype;

begin
finished:= false;

if ch1=char(13) then begin (* check string. *)

   strp:= sepstr0;

   (* Note: This program section is a little peculiar. Characters are added
      to sepstr - see if finished ... else ... far below. After first line (ch1=cr),
      it will scan through the sepstr for state/group name and then return (finished=false).
      Then it will again add more characters to sepstr.
      After second line (ch1=char(13) 2nd time), it will pass through
      both the 1st and the 2nd line of sepstr - state/group name and the
      underlining of it. Then it is finished (finished= true). *)

   (* new state or group name *)
   newname:= ''; ext:= ' ';

   (* If line starts with '-', '=' or '.', assume it is separate === line, meaning
      the end of a state or a group or a substate.*)
   if (sepstr0^<>'=') and (sepstr0^<>'-') and (sepstr0^<>'.') then begin
      while (ord(strp^)>ord(' ')) and (strp^<>eofs) do begin
         if ext=' ' then begin
            if strp^='.' then ext:= '.'
            else newname:= newname + strp^;
            end
         else if ext = '.' then begin
            if (strp^='x') or (strp^='X') then ext:= 'x'
            else xCompileError('X: Other extension than X after statename.');
            end
         else xCompileError('X: Too long extension after statename.');
         fsforward(strp);
         end;
      if length(newname)>32 then xCompileError('X: Too long statename "'
           +newname+'"(max 32 char''s).')
      else begin
         while (strp^<>eofs) and (strp^<>char(13)) do begin
            (* Only blank char's allowed after state name. *)
            if (ord(strp^)>ord(' ')) and not xCompileErrorActive then xCompileError(
          'X: New statename "'+newname+'": Non blank char''s after statename.');
            fsforward(strp);
            end; (* while *)
         end; (* else (length <=32)*)
      end; (* sepstr0^<>'=' *)

   (* check underline *)
   if not xCompileErrorActive and ((strp^=char(13)) or (sepstr0^='=') or (sepstr0^='-') or
      (sepstr0^='.')) then begin
      if strp^=char(13) then fsforward(strp);
      eqcnt:= 0; dashcnt:= 0; dotcnt:= 0;
      if strp^='=' then begin
         while strp^='=' do begin
            eqcnt:= eqcnt+1;
            fsforward(strp);
            end;
         end
      else if strp^='-' then begin
         while strp^='-' do begin
            dashcnt:= dashcnt+1;
            fsforward(strp);
            end;
         end
      else if strp^='.' then begin
         while strp^='.' do begin
            dotcnt:= dotcnt+1;
            fsforward(strp);
            end;
         end;

      if (eqcnt=0) and (dashcnt=0) and (dotcnt=0) then xCompileError(
          'X: New statename "'+newname+'" is not underlined')
      else while strp^<>eofs do begin
         if not xCompileErrorActive and (ord(strp^)>ord(' ')) then
            (* Nonblank char's after underline. *)
            xCompileError('X: New statename "'+newname+
               '": Non blank char''s after underlining.');
         fsforward(strp);
         end;

      (* A substate can be ended by a row of dots or by a new substate.*)
      if not xCompileErrorActive and (dotcnt>0) and
         ( (newname='') or (grouptab[xcurrentgroupnr].kind=a_subState) )
         then begin
         (* End of substate *)
         if grouptab[xcurrentgroupnr].kind<>a_subState then
            xCompileError('X: Unexpected ".......": Ending a substate when ' +
               'not in a substate.')
         else if dotcnt<3 then
            xCompileError('X: At least three "." was expected as end of substate.')
         else begin
            (* End of substate xcurrentgroupnr. *)
            xcurrentgroupnr:= grouptab[xcurrentgroupnr].definedIn;
            if xcurrentgroupnr=0 then xCompileError('X: New substatename "'+
               newname+'": program error - file>0 was expected.');

            (* Return to parent state. *)
            statenr:= savestatenr;
            last:= savelast;
            readstate:= savereadstate;
            finished:= true;
            end;
         end
      (* A state or substate can be ended by a row of dashes or by a new state.*)
      else if not xCompileErrorActive and (dashcnt>0) and
         ( (newname='') or (grouptab[xcurrentgroupnr].kind=a_state) or
            (grouptab[xcurrentgroupnr].kind=a_subState) )
         then begin

         (* End of substate (if in a substate). *)
         if grouptab[xcurrentgroupnr].kind=a_subState then
            xcurrentgroupnr:= grouptab[xcurrentgroupnr].definedIn;

         (* End of state *)
         if grouptab[xcurrentgroupnr].kind<>a_state then
            xCompileError('X: Unexpected "-------": Ending a state ' +
               'when not in a state.')
         else if dashcnt<3 then
            xCompileError('X: At least three "-" was expected as end of state.')
         else begin
            (* End of state xcurrentgroupnr. *)
            xcurrentgroupnr:= grouptab[xcurrentgroupnr].definedIn;
            if xcurrentgroupnr=0 then xCompileError('X: New statename "'+newname+
               '": program error - file>0 was expected.');

            (* Reset state parser. *)
            statenr:= 0;
            last:= nil;
            readstate:= start;
            finished:= true;
            end;
         end
      (* A group, state or substate can be ended by a row of equal signs or by
         a new group.*)
      else if not xCompileErrorActive and (eqcnt>0) and
         ( (newname='') or (grouptab[xcurrentgroupnr].kind<>a_file) )
         then begin

         (* End of substate (if in a substate). *)
         if grouptab[xcurrentgroupnr].kind=a_subState then
            xcurrentgroupnr:= grouptab[xcurrentgroupnr].definedIn;

         (* End of state (if in a state). *)
         if grouptab[xcurrentgroupnr].kind=a_state then
            xcurrentgroupnr:= grouptab[xcurrentgroupnr].definedIn;

         (* Pure end of group (not new group) only allowed when in a group. *)
         if (newname='') and (grouptab[xcurrentgroupnr].kind<>a_group) then
            xCompileError('X: Unexpected "======": Ending a group when not ' +
               'in a group.')
         else begin

            (* End of group (if in a group). *)
            if grouptab[xcurrentgroupnr].kind=a_group then
               xcurrentgroupnr:= grouptab[xcurrentgroupnr].definedIn;

            (* Reset state parser. *)
            statenr:= 0;
            last:= nil;
            readstate:= start;
            finished:= true;
            end;
         end;

      if (newname<>'') and (dotcnt>0) then begin

         (* New substate: *)
         if not xCompileErrorActive then begin
            (* Check that we are in a a_state. *)
            if grouptab[xcurrentgroupnr].kind<>a_state then
               (* Substate where ordinary state was expected. *)
               xCompileError('X: Ordinary state (underlined by ---) was ' +
                  'expected but instead a substate (underlined by ...), by ' +
                  'the name "'+ newname + '", was found.')
            else begin
               (* Check if already defined under the same state *)
               checkNewName(newname,a_subState,newstatenr);
               if newstatenr<>0 then
                  (* substate name already exists. *)
                  xCompileError('X: Substate name '+newname+' already exists in ' +
                     grouptab[grouptab[newstatenr].definedin].name +'.');
               end;
            end;

         (* If not - create new substate *)
         if not xCompileErrorActive then begin
            xcreategroup(newname,a_subState,newstatenr,errorFound);
            if errorFound then xCompileError('X: Unable to create a new substate "'+
               newname+'".')
            else begin

               (* If 1st substate - save its number in state. *)
               with grouptab[statenr] do if substate1=0 then substate1:= newstatenr;

               (* Save readstate of parent state to be returned to when leaving
                  the substate. *)
               savestatenr:= statenr;
               savelast:= last;
               savereadstate:= readstate;

               xcurrentgroupnr:= newstatenr;
               statenr:= xcurrentgroupnr;
               last:= NIL;
               readstate:= start;
               end;
            end; (* not xCompileErrorActive *)
         end (* new state *)

      else if (newname<>'') and (dashcnt>0) then begin

         (* New state: *)
         if not xCompileErrorActive then begin
            (* Check if already defined in same group or file. *)
            checkNewName(newname,a_state,newstatenr);
            if newstatenr<>0 then
               (* state already exists. *)
               xCompileError('X: State '+newname+' already exists in ' +
                  grouptab[grouptab[newstatenr].definedin].name +'.');
            end; (* not xCompileErrorActive *)

         (* If not - create new state *)
         if not xCompileErrorActive then begin
            xcreategroup(newname,a_state,newstatenr,errorFound);
            if errorFound then xCompileError('X: Unable to create a new state "'+
               newname+'".');
            if not xCompileErrorActive then begin
               xcurrentgroupnr:= newstatenr;
               statenr:= xcurrentgroupnr;
               last:= NIL;
               readstate:= start;
               end;
            end; (* not xCompileErrorActive *)
         end (* new state *)

      else if (newname<>'') and (eqcnt>0) then begin

         (* New group: *)
         if not xCompileErrorActive then begin
            (* Check if already defined in same file. *)
            checkNewName(newname,a_group,newstatenr);
            if newstatenr<>0 then
               (* group already exists. *)
               xCompileError('X: Group '+newname+' already exists.');
            end; (* not xCompileErrorActive *)

         if not xCompileErrorActive then begin
            xcreategroup(newname,a_group,xcurrentgroupnr,errorFound);
            statenr:= 0;
            if errorfound then xCompileError('X: Unable to create a new group "'+
               newname+'".');
            last:= NIL;
            readstate:= start;
            end; (* not xCompileErrorActive *)
         end; (* new state *)

      finished:= true;
      end; (* check underline *)
   end; (* check string *)

if xCompileErrorActive then finished:= true;

if finished then fsrewrite(sepstr)
else begin
   // Check that state or group name starts on a new line
   if sepstr=sepstr0 then begin
      if xrc.prevch<>ctrlm then
         xCompileError('X: New state or group name "'+ch1 +
            '..." was expected to start on a new line but last character was "' +
            xrc.prevch + '".')
      else fspshend(sepstr,ch1);
      end
   else fspshend(sepstr,ch1);
   end;

end; (*readsepstr*)


procedure handleFunctionCallsOnTopLevel;
var staterefcntsave,i: integer;
begin
if olddepth=0 then begin
   if depth<=0 then xProgramError('handleFunctionCallsOnTopLevel: '+
      'depth>0 was expected but depth='+inttostr(depth)+
      ' was found.');
   fsrewrite(exprstr);
   exprstr0:= exprstr;
   exprstr0lineno:= xrc.lineno;
   end;

fspshend(exprstr,ch1);

if special and (ch1<>'<') and (ch1<>'>') and (ch1<>'$') then begin
   xCompileError('X: Special char: '+ch1+ch2
      +' found inside <...>-expr (only allowed if quoted)');
   end
else if depth=0 then begin
   (* Compile and execute. *)
   fsrewrite(strut);

   // (old: functionCallsOnTopLevel:= true; (* State references in function definitions
   //    at top level, shall be resolved first at the end of loading the file, because
   //    the states are often not known before then. This flag is to prevent state
   //    references in function definitions to be prematurely resolved when
   //    xCompileAndResolve (see below) is called. *)

   xCompileAndResolve(exprstr0,strut,eofs,false,pfilename,exprstr0lineno,xrc.lineno);

   // functionCallsOnTopLevel:= false;

   if not xCompileErrorActive then begin

      fsrewrite(outstr);
      alreseterror;
      try
         xevaluate(strut,eofs,xevalnormal,pstateenv,outstr);
      except on xtimeoutevent do begin
          xCompileError('X(<load ...>: Unexpected timeout from '
            + ' evaluating expressions on top level.');
          end;
        end;
      // Catch calls to <scripterror ...>
      alCheckScriptError;

      // New (for circular load error messages):
      if (alerror or xCompileErrorActive) and xShowLoadSequence then
            errorroutine;
      iofWriteToWbuf(xfstostr(outstr,eofs));
      end;
   end (* depth = 0 *)
end; (* handleFunctionCallsOnTopLevel *)


begin (*xload*)

(* Set xcurrentgroupnr to 1 (X input window), so that all files have
   group 1 as their parent group. *)
savegroupnr:= xcurrentgroupnr;
xcurrentgroupnr:= 1;
stringdepth:= 0;

(* Save x-file local settings. *)
saveCheckVar:= xCheckVar;
saveuseindentation:= xuseindentation;
saveCompileAlts:= alCompileAlts;
saveAllowFunctionCallsAfterPreact:= alAllowFunctionCallsAfterPreact;
saveAllowBlanksBeforeCommentToEoln:= alAllowBlanksBeforeCommentToEoln;

// (old:)saveUseHexForMakeBits:= alUseHexForMakeBits;
// (old:) alUseHexForMakeBits:= alUseHexForMakeBitsDefault;

(* Initialise x-file local settings. *)
xCheckVar:= checkVarDefault;
xuseindentation:= useIndentationDefault;
alCompileAlts:= compileAltsDefault;
alAllowFunctionCallsAfterPreact:= allowFunctionCallsAfterPreactDefault;
alAllowBlanksBeforeCommentToEoln:= allowBlanksBeforeCommentToEolnDefault;

xloading:= xloading+1;

if xloading=1 then begin
   xCompileErrorActive:= False;
   xshowloadsequence:= false;
   ErrorRoutineLevel:= 0;
   xCurrentLocVarLevel:= -1;

   (* For resolution of state references: *)
   stateRefCount:=0;
   stateRefLoadLevel:=0;
   // functionCallsOnTopLevel:= false;
   end;

pfilenumber:= 0;
statenr:= 0;

(* Get filegroupname = pfilename except pathname and extention. *)
ext:= ' '; fp:= pfilename;
while not (fp^=eofs) do begin
   if ext='x' then begin
      filegroupname:= filegroupname + '.x';
      ext:= ' ';
      end
   else if ext='.' then begin
      if (fp^='x') or (fp^='X') then ext:= 'x'
      else begin
         filegroupname:= filegroupname+'.';
         ext:= ' ';
         end;
      end
   else if fp^='.' then ext:= '.';

   if ext<>' ' then (* - *)
   else if fp^='\' then filegroupname:= ''
   else filegroupname:= filegroupname+fp^;
   fsforward(fp);
   end;

(* Use pfilegroupname instead if it exists. *)
if pfilegroup<>'' then
   filegroupname:= pfilegroup;

(* Check if already loaded. *)
found:= xgetfilenr(filegroupname);

if found>0 then begin
   pfilenumber:= found;
   if xloading=1 then xCompileError(
      'X(<load ...>): File "'+filegroupname
       +'" is already loaded (use <cleanup> to remove).')
   else
      (* - Unnecessary loads are accepted when called from an x-file. *)
   end

else begin

   (* Load new x-file... *)

   (* Add .x to pfilename if it was not there already (default). *)
   if ext<>'x' then begin
      fspshend(fp,'.');
      fspshend(fp,'x');
      end;

   (* Open file. *)
   ioxreset(pfilename,pshortname,xCompileErrorActive);

   (* Parse and compile file. *)
   if not xCompileErrorActive then begin

      // Update load sequence (used for error messages)
      loadsequenceindex:= loadsequenceindex+1;
      loadsequence[loadsequenceindex]:= pfilename;

      (* Keep track of <c/j ...>  calls where the statename shall be filled
         in after reading the file.  *)
      staterefloadlevel:= staterefloadlevel+1;
      staterefstarttab[staterefloadlevel]:=staterefcount;

      fsnew(exprstr); exprstr0:= exprstr;
      fsnew(strut);
      fsnew(outstr);

      fsnew(sepstr); sepstr0:= sepstr;

      (* Create a filegroup. *)
      xcreategroup(filegroupname,a_file,xcurrentgroupnr,errorFound);

      if xCurrentGroupnr>0 then grouptab[xCurrentGroupnr].loading:= true;

      statenr:= 0;
      pfilenumber:= xcurrentgroupnr;

      if errorFound then begin
         xCompileError('X(<load ...>): Unable to create file ' + statename + '.');
         end;

      readstate:= start;
      dbgreadstate:= afterpostact; dmess:= ''; (* debug *)
      last:= NIL;
      xrcinit;
      endfile:= FALSE;
      depth:= 0;
      functionlevel:= 0;
      pendingNewLine:= false;

      while not (xCompileErrorActive or endfile) do begin

         olddepth:= depth;
         oldreadstate:= readstate;
         xreadchar(ch1,ch2,special,endfile);

         if (ch1='-') and (ch2=ctrlM) then
            (* - (special: '-' at end of line) Continue on next line. *)

         else if (ch1=ctrlm) and (ch2='-') then
            (* - (special: '-' in beginning of line) Continue. *)

         else if (ch1=ctrlm) and special and (ch2=' ') then
            (* - Continue on next line - indentation. *)

         else if not endfile then case readstate OF

         start: begin

            if ch1=ctrlM then begin
               if pendingnewline then begin
                  iofWritelnToWbuf('');
                  pendingNewLine:= false;
                  end;
               end;

            (* Use readsepstr to read state and group names. *)
            if sepstr0^<>eofs then readsepstr

            else if (depth>0) or (ch1='>') and special then begin (* < read. *)

               handleFunctionCallsOntopLevel;
               end (* depth>0 or '>' *)
            else if (ch1='!') and (ch2='"')
               then begin
               if (grouptab[xcurrentgroupnr].kind <> a_state) and
                  (grouptab[xcurrentgroupnr].kind <> a_subState) then begin
                  (* !"..."! in beginning of file or a group *)
                  if grouptab[xcurrentgroupnr].kind=a_file then
                     xCompileError('X: Preaction (!"..."!) was found on top level in file '+
                     grouptab[xcurrentgroupnr].name + 'but is only supposed to be inside '+
                     'a state (---) or a substate (...).')
                  else
                     xCompileError('X: Preaction (!"..."!) was found on top level in group '+
                     grouptab[xcurrentgroupnr].name + 'but is only supposed to be inside '+
                     'a state (---) or a substate (...).');
                  end
               else begin
                  fsrewrite(exprstr);
                  exprstr0:= exprstr;
                  exprstr0lineno:= xrc.lineno;
                  readstate:= preact;
                  end;
               end
            else if (ch1='?') and (ch2='"') then begin
               if (grouptab[xcurrentgroupnr].kind <> a_state) and
                  (grouptab[xcurrentgroupnr].kind <> a_subState) then begin
                  (* Alternatives only allowed in states (---) *)
                  xCompileError('X: Underscored (--- or ...) statename was expected but in group ' +
                     grouptab[xcurrentgroupnr].name +
                     ' but new alternative (?"...) was found.');
                  end
               else begin
                  if alCompileAlts then begin
                     (* Create a new case. *)
                     new(p);
                     with p^ do begin
                        fsnew(kompin);
                        fsnew(kompout);
                        next:= NIL;
                        end;

                     if last=NIL then grouptab[statenr].caselist:= p
                     else last^.next:= p;
                     last:= p;
                     end;
                  fsrewrite(exprstr);
                  exprstr0:= exprstr;
                  exprstr0lineno:= xrc.lineno;
                  readstate:= altin;
                  end;
               end
            else if special then begin
               if (ch1='$') and (xrc.nextCh<>ctrlm) and (xrc.nextch<>'<') then begin
                  // Start of a variable reference ($name)
                  readstate:= variableRef;
                  fsrewrite(exprstr);
                  exprstr0:= exprstr;
                  exprstr0lineno:= xrc.lineno;
                  fspshend(exprstr,ch1);
                  end

              else
                  (* pecial character(s) where it is not supposed to be, *)
                  xCompileError('X: Special char '+ch1+ch2+' at top level. '+
                    '(Only !", ?", <, $, statename or line supposed to be here)');
               end
            else if (ord(ch1)>ord(' ')) then begin

               (* Read name of state or substate. *)
               (* (new:) *)
               readSepStr();
               (* (old:) fspshend(sepstr,ch1) *)
               end;
            end; (* start *)

         variableRef: begin (* $name on top level *)

            if special then
               (* Special character(s) where it is not supposed to be, *)
               xCompileError('X: Special char '+ch1+ch2+' in $name variable ' +
                  'reference at top level. '+
                 '(Only letters supposed to be here)')
            else if ord(ch1) > ord(' ') then begin

               (* Read until new line or '<'. *)
               fspshend(exprstr,ch1);

               if (xrc.nextCh=ctrlm) or (xrc.nextCh='<') then begin
                  // Compile and evaluate

                  (* (Copied from handleFunctionCallsOnTopLevel:) *)
                  fsrewrite(strut);

                  xCompileAndResolve(exprstr0,strut,eofs,false,pfilename,exprstr0lineno,xrc.lineno);

                  if not xCompileErrorActive then begin
                     fsrewrite(outstr);
                     alreseterror;
                     try
                        xevaluate(strut,eofs,xevalnormal,pstateenv,outstr);
                     except on xtimeoutevent do begin
                        xCompileError('X(<load ...>: Evaluating $name - Unexpected timeout from '
                          + ' evaluating expressions on top level.');
                        end;
                     end;
                     // New (for circular load error messages):
                     if (alerror or xCompileErrorActive) and xShowLoadSequence then
                        errorroutine;

                     // Add newline after the end of the line
                     if xrc.nextch=ctrlm then
                        iofWritelnToWbuf(xfstostr(outstr,eofs))
                     else begin
                        iofWriteToWbuf(xfstostr(outstr,eofs));
                        pendingnewline:= true;
                        end;
                    end;

                  // Return to start state
                  readstate:= start;

                  end; (* next = ctrlm or < *)
               end (* ch1>' ' *)
            else
               (* Unexpected character character <= ' ' *)
               xCompileError('X: Invisible char #' + inttostr(ord(ch1)) +
                  ' found in $name variable reference at top level when ' +
                  'visible letter was expected.');

            end;(* (variableRef) *)

         preact,altout,postact: begin(* !" read - actions *)
            if (ch1='"') and (ch2='!') then begin
               if depth>0 then begin
                  xCompileError('X: Special char: "!'
                   +' found inside <...>-expr (only allowed if quoted)');
                  end
               else with grouptab[statenr] do begin
                  case readstate of
                     preact: begin
                        xcompilestring(exprstr0,grouptab[statenr].pre,eofs,false,pfilename,exprstr0lineno,xrc.lineno);
                        readstate:= afterpreact;
                        end;
                     altout: begin
                        if alCompileAlts then
                           xcompilestring(exprstr0,last^.kompout,eofs,true,pfilename,exprstr0lineno,xrc.lineno);
                        readstate:= afterpreact;
                        end;
                     postact: begin
                        xcompilestring(exprstr0,grouptab[statenr].post,eofs,false,pfilename,exprstr0lineno,xrc.lineno);
                        readstate:= afterpostact;
                        end;
                    end; (*case*)
                  end; (*with*)
               end (* "! *)
            else if special and not ((ch1='<') or (ch1='>') or (ch1='$')) then begin
               if readstate=preact then ststr:= 'preaction'
               else if readstate=altout then ststr:= 'output'
               else ststr:= 'postaction';

               xCompileError('X: Special char '+ch1+ch2+' in state '+ststr+' clause. '
                 +'(X looks for "!)');
               end
            else begin
               fspshend(exprstr,ch1);
               end; (* <, >, or unspecial character. *)
            end; (* preact,altout,postact *)

         afterpreact: begin (* !"..."! read. Looking for a new case. *)

            (* Use readsepstr to read state and group names. *)
            if sepstr0^<>eofs then readsepstr

            // (new:)
            else if (depth>0) or (ch1='>') and special then begin (* < read. *)
               if alAllowFunctionCallsAfterPreact then

                  handleFunctionCallsOntopLevel
               else
                  xCompileError('X: Function call ('+ch1+ch2+'...) found after '+
                     'pre action. Requires <settings allowFunctionCallsAfterPreact,yes>.'+
                     '(X looks for ?")');
               end (* depth>0 or '>' *)

            else if (ch1='?') and (ch2='"') then begin

               if alCompileAlts then begin
                  (* Create a new case. *)
                  new(p);
                  with p^ do begin
                     fsnew(kompin);
                     fsnew(kompout);
                     next:= NIL;
                     end;

                  if last=NIL then grouptab[statenr].caselist:= p
                  else last^.next:= p;
                  last:= p;
                  end;
                  
               fsrewrite(exprstr);
               exprstr0:= exprstr;
               exprstr0lineno:= xrc.lineno;
               readstate:= altin;
               end (* ?" *)

            else if (ch1='!') and (ch2='"') then begin
               fsrewrite(exprstr);
               exprstr0:= exprstr;
               exprstr0lineno:= xrc.lineno;
               readstate:= postact;
               end

            else if special then begin
               xCompileError('X: special char '+ch1+ch2
                 +' found after pre action. (X looks for ?")');
               end
            else if (ord(ch1) > ord(' ')) then begin
               (* Assume start of a sep-line or state/group name. *)
               (* (new:) *)
               readSepStr();
               (* (old:) fspshend(sepstr,ch1) *)
               end;
            end; (*afterpreact*)
 
         altin: (* ?" read. Reading input clause. *)
            if (ch1='"') and (ch2='?') then begin
               if depth>0 then begin
                  xCompileError('X: Special char: "?'
                   +' found inside <...>-expr (only allowed if quoted)');
                  end

               else with grouptab[statenr] do begin
                  // (old:)xcompilestring(exprstr0,last^.kompin,eofs,false,pfilename,exprstr0lineno,xrc.lineno);
                  if alCompileAlts then
                     xcompilestring(exprstr0,last^.kompin,eofs,true,pfilename,exprstr0lineno,xrc.lineno);
                  fsrewrite(exprstr);
                  exprstr0:= exprstr;
                  exprstr0lineno:= xrc.lineno;
                  readstate:= afteraltin;
                  end
               end
            else if special and not((ch1='<') or (ch1='>') or (ch1='$')) then begin
               xCompileError('X: special char '+ch1+ch2+' found in ?"..."?-clause.' +
                  ' (X looks for "?)');
               end
            else begin (* <, >, or unspecial character. *)

               (* Remove (invisible) blanks at end of X-file line. *)
               if (ch1=ctrlm) and (exprstr<>exprstr0) then begin
                   sp:= exprstr;
                   fsback(sp);
                   // (new:)
                   while (fsLcWsTab[sp^]=' ') and (sp<>exprstr0) do fsback(sp);
                   // (old:) while ((sp^=' ') or (sp^=char(9))) and (sp<>exprstr0) do fsback(sp);
                   if sp^<>' ' then fsforward(sp);
                   if sp<>exprstr then begin
                       fsdelrest(sp);
                       exprstr:= sp;
                       end;
                   end;

               fspshend(exprstr,ch1);
               end; (* <, >, unspecial *)
            (*altin*)
 
         afteraltin: begin (* Input clause ?"..."? read. Looking for output clause. *)
            if (ch1='!') and (ch2='"') then begin
               fsrewrite(exprstr);
               exprstr0:= exprstr;
               exprstr0lineno:= xrc.lineno;
               readstate:= altout;
               end
            else if special then begin
               xCompileError('X: special char '+ch1+ch2+' found'+
                  ' after ?"..."?-clause. (X looks for !")');
               end
            else if ord(ch1)>=33 then begin
               (* Visible char at top level after ?"..."? clause. *)
               xCompileError('X: Char '+ch1+' after ?"..."?-clause in X-file. '
                 +' (X looks for !")');
               end;
            end; (*afteraltin*)

         afterpostact: begin (* !"..."! read. Looking for a new state. *)

           (* Use readsepstr to read state and group names. *)
            if sepstr0^<>eofs then readsepstr

            else if special then begin
               xCompileError('X: special char '+ch1+ch2
                  +' found after exit clause. (X looks for new state)');
               end
            else if (ord(ch1) > ord(' ')) then
               (* Assume start of a sep-line or state/pack.-name. *)
               (* (new:) *)
               readSepStr();
               (* (old:) fspshend(sepstr,ch1) *)
            end; (*afterpostact*)
         end; (*case*)
 
         if readstate<>oldreadstate then begin
            (* Handle stringdepth *)
            if (readstate in [preact,altin,altout,postact]) then
               stringdepth:= 1
            else
               stringdepth:= 0;
            end;
         end; (*while not xCompileErrorActive or eof*)

      if not xCompileErrorActive and (depth>0) then begin
         xCompileError('X: X file ended inside <...>-call (level = '
            +inttostr(depth)+').');
         end;

      if not xCompileErrorActive
         and ((readstate=preact) or (readstate=altout) or (readstate=postact)) then begin
         xCompileError('X: X file ended inside !"..."!.');
         end;
  
      if not xCompileErrorActive
         and (readstate=altin) then begin
         xCompileError('X: X file ended inside ?"..."?.');
         end;
  
      (* If an error occurred - delete all states. *)
      if xCompileErrorActive then xclearxfiles;
  
      ioxclose;
      fsdispose(exprstr);
      fsdispose(strut);
      fsdispose(outstr);

      fsdispose(sepstr);

      (* Resolve state references in <c/j ...>  calls.  *)
      for i:= staterefstarttab[staterefloadlevel]+1 to staterefcount do begin
         if not (xFault or xCompileErrorActive) then resolvestateref(i);
         end;

      // Restore state ref count and load level
      staterefcount:= staterefstarttab[staterefloadlevel];
      staterefloadlevel:= staterefloadlevel-1;

      // Update load sequence (used for error messages)
      loadsequenceindex:= loadsequenceindex-1;

      if xCurrentGroupnr>0 then grouptab[xCurrentGroupnr].loading:= false;

      end; (* No error from opening file with ioxreset. *)
   end; (* File was not already loaded. *)

xloading:= xloading-1;

(* Restore current group nr. *)
xcurrentgroupnr:= savegroupnr;

(* Restore use x-file local settings. *)
xCheckVar:= saveCheckVar;
xuseindentation:= saveuseindentation;
alCompileAlts:= saveCompileAlts;
alAllowFunctionCallsAfterPreact:= saveAllowFunctionCallsAfterPreact;
alAllowBlanksBeforeCommentToEoln:= saveAllowBlanksBeforeCommentToEoln;
// (old:) alUseHexForMakeBits:= saveUseHexForMakeBits;

end; (*xload*)


procedure xInitStateEnv( var pstateenv: xstateenv; pinp: ioinptr);
(* Reset/initialize state environment. *)

begin

with pstateenv do begin

   statename:= '';
   cstatenr:= 0;
   statenr:= 0;
   newstatenr:= 0;
   substatenr:= 0;
   nspar:= 0;
   nsspar:= 0;
   pars.npar:= 0;
   pars.invalidBecauseOfRpw:= false;
   pars.xparoffset:= 0;
   pars.nxpar:= 0;
   cinp:= pinp;
   inpback:= pinp;
   inpend:= pinp;
   rstr:= nil;
   stringInputPtr:= nil;
   outstring:= false;
   altnr:= 0;
   altstate:= current;
   compare:= false;
   funcnr:= 0;
   macnr:= 0;

   // (new:)
   backLogCnt:= 0;
   end;

xinitpn(pstateenv);

end; (*xinitStateEnv*)


procedure xsendto( pstr:string;  var pstateenv: xstateenv;  var pretstr: string );
(* BFn 100314: Changed so that xsendto uses the callers stateenv instead
   of creating an own. See if it works. Perhaps there is a reason for
   itto create its own? In that case: revert and document the reason. *)
(* Send a string (pstr), normally containing <...>-calls,
   to X and have it compiled and evaluated and return
   the result (pretstr). This version is used in the normal form.  *)
var
i: integer;
str,compout,retstr,str0: fsptr;
l: integer;
stateenv: xstateenv;
oldstateenv: xstateenvptr;
stateenv0: xstateenv;
retstr0: fsptr;
oldIODummy: xSavedIODataRecord;

begin (*xsendto*)

fsnew(str); str0:= str;
fsnew(compout);
fsnew(retstr);
xinitstateenv(stateenv,pstateenv.cinp);
alSaveIoPtr:= @oldIODummy;

l:= length(pstr);
for i:= 1 to l do fspshend(str,pstr[i]);
xCompileErrorActive:= false;
xshowloadsequence:= false;
errorroutinelevel:= 0;
xcurrentgroupnr:= 1; // = X input window

// (new:)
xCompileAndResolve(str0,compout,eofs,false,nil,0,0);
// (old:) xcompilestring(str0,compout,eofs,false,nil,0,0);

if not xCompileErrorActive then begin
   alBitsClear; (* Reset possible bits mode *)
   oldstateenv:= xcurrentStateEnv;
   if althreadcount=0 then iomarkeoffiles(pstateenv);
   retstr0:= retstr;
   stateenv0:= pstateenv;
   xevaluate(compout,eofs,xevalnormal,pstateenv,retstr);
   pretstr:= fstostr(retstr);
   end;
xdisposepn(pstateenv.pars);
fsdispose(str);
fsdispose(compout);
fsdispose(retstr);

end; (*xsendto*)


procedure xsendto_debug(pstateenvptr: xstateenvptr; pstr:string;
   ppncallallowed: boolean; var pretstr: string );
(* Send a string (pstr), normally containing <...>-calls,
   to X and have it compiled and evaluated and return
   the result (pretstr). This version is used in the debug form. *)
var
i: integer;
str,compout,retstr,str0: fsptr;
l: integer;
retstr0: fsptr;
savegroup: integer;

begin (*xsendto_debug*)

fsnew(str); str0:= str;
fsnew(compout);
fsnew(retstr);

xcurrentStateEnv:= pstateenvptr;

(* Simulate presence in the current state,
   to enable function names to be visible. *)
if pstateenvptr^.statenr>0 then begin
   savegroup:= xcurrentgroupnr;
   xcurrentgroupnr:= pstateenvptr^.statenr;
   end
else savegroup:= -1;

l:= length(pstr);
for i:= 1 to l do fspshend(str,pstr[i]);

xCompileErrorActive:= false;
xshowloadsequence:= false;
errorroutineLevel:= 0;
xcurrentgroupnr:= 1; // = X input window

xCompileAndResolve(str0,compout,eofs,ppncallallowed,nil,0,0);

if not xCompileErrorActive then begin
   alBitsClear; (* Reset possible bits mode *)
   (* Mark eof files when an X program is started (no thread already running). *)
   (* if althreadcount=0 then iomarkeoffiles(stateenv); *)
   (* iomarkeoffiles removed because sendto use used by debug.
      iomarkeoffiles maybe should be done from xioform instead? *)
   (* if althreadcount=0 then iomarkeoffiles(pstateenvptr^); *)
   retstr0:= retstr;
   xevaluate(compout,eofs,xevalnormal,pstateenvptr^,retstr);
   pretstr:= fstostr(retstr);
   end;

(* Restore xcurrentgroup. *)
if savegroup>=0 then xcurrentgroupnr:= savegroup;

fsdispose(str);
fsdispose(compout);
fsdispose(retstr);

end; (*xsendto_debug*)


// Old stuff



(* SLUT TILLSTÅNDSMASKIN  *)
(*------------------------*)

(* TESTPROGRAM FÖR X *)
(*---------------------*)

procedure xtest(puseparamstr: boolean);
(* Test with X. Use command parameter string (paramstr(1)) if
   puseparamstr = True. *)

(* USE (from msdos):
   >X [(X expression)]
*)

var
inp: ioinptr;
handle: hwnd;
dir: string;

begin (*xtest*)

fsinit;
ioinit(inp);
xinit(inp);

(* Check if current directory is an internet path
   (Known to cause problems in alcommand). *)

(* Tell alcommand to give a warning if the current directory is
   a network path. *)
getdir(0,dir);
alCdIsInternetAddress:= AnsiLeftStr(dir,2)='\\';

alinit; (* FÅR EJ ANROPAS FÖRE XINIT! *)

// Create and show X window
handle:= iofCreateXform(true);
currentform:= 1; // Standard X window

// Create window class "xwindowclass" (for GUI applications)
iofinitform1(inp);

(* Handle added data. *)
ioxhandleInternalFiles;

(* X "<load ...> ... " *)
(* paramstr 1 is evaluated in X  *)
if puseparamstr and (paramcount>0) then iofSetInitString(paramstr(1))
else (* If there are internal files, load the first. *)
   if ioInternalFile1<>'' then iofSetInitString('<load ' + ioInternalFile1 +
      '>');

iofmainloop(1);

(* Delete all files and sockets. *)
iocleanup(inp);

end; (*xtest*)


procedure xtest2;
(* Like xtest, except do not show x window, do not run main loop and iocleanup,
   and do not use paramstr.
   xtest2 is used by xdll. *)
(* Test with X. Use command parameter string (paramstr(1)) if
   puseparamstr = True. *)

(* USE (from msdos):
   >X [(X expression)]
*)

var
inp: ioinptr;
handle: hwnd;
dir: string;


begin (*xtest2*)

// (debug:) iofshowmess('->test2');
fsinit;
ioinit(inp);
xinit(inp);

(* Check if current directory is an internet path
   (Known to cause problems in alcommand). *)

(* Tell alcommand to give a warning if the current directory is
   a network path. *)
getdir(0,dir);
alCdIsInternetAddress:= AnsiLeftStr(dir,2)='\\';

alinit; (* FÅR EJ ANROPAS FÖRE XINIT! *)

// Create X window but do not show
handle:= iofCreateXform(false);
currentform:= 1; // Standard X window

// Create window class "xwindowclass" (for GUI applications)
iofinitform1(inp);

(* Handle parameters. *)
(* X "<load ...> ... " *)
(* paramstr 1 is evaluated in X  *)
// if puseparamstr and (paramcount>0) then iofSetInitString(paramstr(1));

// iofmainloop(1);

(* Delete all files and sockets. *)
// iocleanup(inp);

// (debug:) iofshowmess('<-test2');

end; (*xtest2*)


end.

(* Unused functions and procedures: Kept for reference *)
(*---------------------------------------------------- *)

