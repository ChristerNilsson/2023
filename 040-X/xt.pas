
(* xtypes.pas *)

UNIT xt;

{$MODE Delphi}

(***) INTERFACE (***)

USES
xfs,                (* fsptr *)
sysutils;           (* exceptions. *)



CONST
xmaxnarg= 100;       (* <func a1,a2,...a100> is allowed. *)

type
xargblock= record
   narg: integer;
   arg: ARRAY[1..xmaxnarg] OF fsptr;
   (* Pointers to function call arguments in the X code. *)
   rekursiv: ARRAY[1..xmaxnarg] OF BOOLEAN; (* ARGUMENTET
      INNEHÅLLER ANROP. *)
   locvarnestlevel: integer; (* Only for local variable references.
      Example: <function f1,<var $v1><f2 hej,<f3 $v1>>> <f1>
      The locvarnestlevel for the reference to $v1 will be 1 so when
      $1 is evaluated in f3, locVarOffsetStack[1] is used as locvaroffset
      instead of the current locvaroffset. *)

   end;
type xargblockptrtype = ^xargblock;

CONST
xmaxnpar= 100; (* MAX ANTAL PARAMETRAR I INPUT-DEL TILL xcompare (<p n>). *)
backLogTabSize = 20;

TYPE
ioinptr= ^CHAR;
xint16= INTEGER; (* (smallint is enough, but INTEGER is recommended
                    for efficiency.) *)
xparsRecord= RECORD (* Record for <p ...> parameters *)
   npar: xint16;(* 0..xmaxnpar = Nr of last parameter in input string. *)
   bitsnpar: xint16;(* 0..xmaxnpar = temp npar (for albits). *)
   par: ARRAY[1..xmaxnpar] OF RECORD
      fs: fsptr; (* if fs<>nil then use it instead. *)
      atp: ioinptr;  (* Points at 1st char. *)
      afterp: ioinptr;  (* Points just after last char. *)
      bitsAs: xint16; (* This par relates to a <bits ...> function - use
                       atshift and aftershift if > 0. *)
      atshift: xint16; (* Number of bits that shall be shifted away
                        in 1st char (0..3).
                        Used by <bits ..> and <p n> *)
      aftershift: xint16; (* Number of bits that shall be shifted in from
                           1st char after <p n> (afterp). (0..3) *)
      END;
   invalidBecauseOfRpw: boolean; (* True = <replacewith ...> has invalidated the
      pointers that identify <p n>. Used to create fault when script uses <p n>
      after <replacewith ...> in same alt. *)
   xparoffset: xint16; (* Where xp starts, relative to npar.
      xparoffset is used when there nested calls to <case ...> or <ifeq ...>.
      When for example inside an action argument of <case ...>, the xparoffset
      is incremented by the number of <xp n> in the preceeding comparison, so
      Ex. Xparoffset=1, npar=3 => <xp 1> = <p 5>. *)
   nxpar: xint16; (* Number of extra parameters (<xp n>)  in the current context. *)
END;

xaltstatetype = (grandmother,mother,current);

xSavedIODataRecord = record
   oldInputFileNr: integer;
   oldOutputFileNr: integer;
   oldOutString: boolean;

   (* (new:) *)
   oldLastIOWasPersistent: boolean;

   (* (old:)
   oldLastInWasPersistent: boolean;
   oldLastOutWasPersistent: boolean;
   *)

   end;
xSavedIODataPtrType = ^xSavedIODataRecord;

xstateenv = record
    statename: string;
    cstatenr: integer; (* Called statenr *)
    statenr: integer; (* Current statenr *)
    newstatenr: integer; (* New statenr. =0 => <r>, <>statenr => <j ...> . *)
    subStatenr: integer; (* (old) >0: Current state. =0: statenr is current state.
      It is possible to jump between substates belonging to the same state. *)
    nspar: integer;
    nsspar: integer; (* Number of substate parameters, set in <j ...> *)
    spar: array[1..xmaxnpar] of fsptr; (* <sp n> and <ssp n>, where
      <ssp n> = spar[nspar+n]. *)
    sparlateeval: array[1..xmaxnpar] of boolean;
    (* True: spar[n] points into x-code and contains <...>-calls.
       False: spar[n] is an evaluated fs string.
       See procedure alc.
       Needed to implement <c_lateevaluation ...> *)
    pars: xparsRecord; (* <p n> in alternatives. *)
    cinp: ioinptr; (* Current input pointer. *)
    inpback: ioinptr; (* Position before last ?"..."? match. Used by <unread>,
                         <p 0> and <replacewith ...>. Set to nil when pn parame-
                         ters are moved (in unread buffer) to indicate that
                         the pointer cannot be used by <unread>. *)
    inpEnd: ioinptr; (* Position at end of last ?"..."? match. Used by
                         <p 0> and <replacewith ...>. Set to nil when pn parame-
                         ters are moved (in unread buffer) to indicate that
                         the pointer cannot be used. *)
    rstr: fsptr;         (* Return data from <r str>. (set in xcallstate). *)
    stringInputPtr: ioinptr; (* If <in ...,string> has been called - Pointer
      to inp after <in ...,string> was called, else nil. Used to check that a
      state is not called during comparison in <case ...>, <ifeq ...> or <eq ...>
      unless the state uses string as input. Also used by <allinenr string> *)
    outstring: boolean; (* Output shall be returned from <c ...>-call and not
                           sent to any file. *)
    altnr: xint16;          (* Currently processed alt in call n.
                               Diagnostic use in xdebuginfo.  *)
    inInputPart: boolean;   (* True = processing ?"..."?.
                               Diagnostic use in xdebuginfo.  *)
    altstate: xaltstatetype;

    compare: boolean; (* This is set to true when in <case ...> or <ifeq ...>,
      and used to avoid reading from files, because the current file pointer
      cinp will be restored afterwards, so cinp is not valid for reading from
      files. *)
    macnr: integer;  (* Initially 0. When in an X-function, nr of the current macro. *)

    (* Funcnr and argsptr should perhaps be stored as threadvar instead? They are not related
       to the state but to the function call stack (and the stack in in alcall
       where the old values are saved to restore these values at end of call):
       (/BFn 2011-02-18) *)
    funcnr: integer; (* Initially 0. When in an X-function, nr of the current function.
       Used for error messages. *)
    argsPtr: xargblockptrtype;
    cinp0: ioinptr; (* Used to check that if <unread ...> is used in preaction,
      then the whole unread string is also consumed (neither more nor less)
      in the called state. This is how it works: 1. cinp0=nil when state is called.
      2. iounread(iounrnormal) always sets cinp0=cinp if it was nil.
      3. After preaction of called state, if cinp0<>nil (unread was used in preaction)
         then cinp0 is saved for later check.
      4. At return from called state, if saved cinp0<>nil then cinp is expected to
         be = cinp0, otherwise either more or less than the unread string was
         consumed in the called state. *)
      backLogTab: array[1..backLogTabSize] of record
          blsavefuncnr: integer;
          blargsPtrSave: xargblockptrtype;
          end;
      backLogCnt: integer;

    end;
xStateEnvPtr = ^xStateEnv;

type xtimeoutevent = class(Exception);

IMPLEMENTATION

END.
