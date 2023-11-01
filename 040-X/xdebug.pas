unit xdebug;

{$MODE Delphi}


interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls
  // ,Interfaces // FPC
  ,Forms
  ,Dialogs, StdCtrls
  ,xt (* ioinptr *)
  ,xx (* xstring32, xname *)
  ,xfs (* fsptr, fspshend, fsforward. *)
  ,xal (* alfstostr *)
  ;

procedure debugshowinfile(pinp: ioinptr);

procedure debugdecompile(pxpos: fsptr;
   pShowAll: boolean; (* Go to beginning of enclosing fs before starting
      decompilation. Used by <debug> but not by alShowCall. *)
   pshowpos: boolean; (* Put a mark where pxpos is in the string. *)
   pout: fsptr);
(* Decompile a string at pxpos to pout, continue until eofs or eoa.
   if pshowpos then insert "¤" at the current position (pxpos). *)

type TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    inputfile: TMemo;
    outputfile: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Debugform: TForm2 = nil;

implementation

uses
xio; (* iogetlinesbefore *)

{$R *.lfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
ModalResult := mrOK;

end;


procedure debugdecompile(pxpos: fsptr;
   pShowAll: boolean; (* Go to beginning of enclosing fs before starting
      decompilation. Used by <debug> but not by alShowCall. *)
   pshowpos: boolean; (* Put a mark where pxpos is in the string. *)
   pout: fsptr);
(* Decompile a string at pxpos to pout, continue until eofs or eoa.
   if pshowpos then insert "¤" at the current position (pxpos). *)
var
xpos: fsptr;

procedure decompile(pPrint: boolean);

var
ch: CHAR;
funcnr: integer;
funcname: string;
nrofargs: integer;
argnr: integer;
inlpos: fsptr;
arglen: integer;
in2: fsptr;
varnr: integer;
varname: string;
setpopforeach: boolean;
knownError: boolean;

BEGIN (*decompile*)

knownerror:= false;
while not ( (xpos^=char(xeoa)) or (xpos^=char(fseofs)) or knownerror) do begin

   ch:= xpos^;
   if (xpos=pxpos) and pshowpos and pprint then fspshend(pout,char(164));
   fsforward(xpos);

   IF ch=char(xstan) then begin (* <...>-ANROP *)

      if pprint then fspshend(pout,'<');

      funcnr:= integer(xpos^);
      fsforward(xpos);
      if funcnr=0 then begin
         (* Long number *)
         funcnr:= integer(xpos^);
         fsforward(xpos);
         funcnr:= funcnr*250 + integer(xpos^);
         fsforward(xpos);
         end;
      (* Print function name. *)
      funcname:= xname(funcnr);
      if pprint then alstrtofs(funcname,pout);

      (* <set, append, setcalc, pop and foreach have special interpretation of arg1. *)
      if (funcnr=alsetFuncnr) or (funcnr=alAppendFuncnr) or (funcnr=alUpdateFuncnr) or
         (funcnr=alPopFuncnr) or (funcnr=alForeachFuncnr) or (funcnr=alIndexesFuncnr)
         then setpopforeach:= true
      else setpopforeach:= false;

      nrofargs:= ORD(xpos^);
      fsforward(xpos);

      if (nrofargs>0) and pprint then fspshend(pout,' ');

      for argnr:= 1 TO nrofargs DO if not knownerror then BEGIN

         inlpos:= xpos;
         arglen:= integer(inlpos^)*250;
         fsforward(xpos);
         arglen:= arglen+ integer(xpos^);

         fsforward(xpos);
         (* Now on 1st char in arg (or eoa) *)

         if setpopforeach and (argnr=1) then begin
            (* Special interpretation of arg1 - get function name
               from binary number. *)
            varnr:= ord(xpos^);
            fsforward(xpos);
            if varnr=0 then begin
               (* Long number. *)
               varnr:= ord(xpos^);
               fsforward(xpos);
               varnr:= varnr*250 + ord(xpos^);
               fsforward(xpos);
               end;
            (* Print variable name. *)
            varname:= xname(varnr);
            if pprint then alstrtofs(varname,pout);
            if varnr>xmaxfuncnr then
               // Local variable - read away empty place for nesting level
               fsforward(xpos);
            end (* setpopforeach *)
         else begin
            // arg2 in <xp n,...> shall not printed because it contains an offset for internal X use.
            if (funcnr=alXpFuncnr) and (argnr=2) then decompile(false)
            else decompile(true);
            end;

         while xpos^=char(xeoa) do fsforward(xpos);

         (* Double check. *)
         in2:= inlpos;
         fsmultiforw(in2,arglen+3); (* (length field 2 bytes, eoa 1 byte - 2+1=3) *)
         if in2<>xpos then begin
            // This happens from time to time but the reason is unknown
            knownError:= true;
            // xProgramError('X(debugdecompile): Program error - in2=xpos was expected.');
            end;

         (* We shall now be just after eoa-mark.  *)
         if (argnr<nrofargs) and pprint then begin
            // arg2 in <xp n,...> shall not printed because it contains an offset for internal X use.
            if (funcnr=alXpFuncnr) and (argnr=1) then (* - *)
            else fspshend(pout,',');
            end;
         end; (*for*)

        if nrofargs>0 then begin

            (* Read recursive markings and zero terminator. *)
            while xpos^<>char(0) do fsforward(xpos);
            fsforward(xpos);
            end;

        if pprint then fspshend(pout,'>');
        end (* stan *)

    else begin
       (* not stan *)
       if pprint then fspshend(pout,ch);
       end;
    end; (*while*)

end; (*decompile*)

begin (*debugdecompile *)

xpos:= pxpos;
if pShowAll then fsbackend(xpos);
decompile(true);

end; (*debugdecompile*)


procedure debugshowinfile(pinp: ioinptr);
var str: string; inp: ioinptr; n: integer;
begin
debugform.inputfile.Clear;
(*
inp:= pinp;
iobacklines(10,inp);
str:= '';
while not (inp=pinp) do begin
   if inp^=char(13) then begin
      debugform.inputfile.lines.Add(str);
      str:= '';
      end
   else str:= str + inp^;
   ioinforward(inp);
   end;
*)

debugform.inputfile.lines.Add(iogetlinesbefore(pinp,8)
+'***'+iogetlinesafter(pinp,4));
with debugform.inputfile do
   selstart:= selstart-1;
(* debugform.inputfile.lines.text:= iogetlinesbefore(pinp,7); *)

end;

end.
