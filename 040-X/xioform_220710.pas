(* xioform.pas *)
(* 06-05-02: Modified for threadsafe operation. *)
(* 00-04-20: Version 1.04 started. *)
(* 99-01-17: Version 1.02 creation. *)

unit xioform;

{$MODE Delphi}

(* Provides a windows-based user-interface to X. *)

interface

uses
   windows
  //  LCLIntf, LCLType, LMessages (* semaphore, ... *)
  ,Messages, SysUtils, Classes, Graphics, Controls
  // ,interfaces // FPC
  ,Forms
  ,Dialogs
  ,StdCtrls
  ,syncobjs (* TCriticalsection *)
  ,xt (* ioinptr, xmaxnarg, xargblock  *)
  ,xio (* ioinclearcons *)
  ,xfs (* fstostr, fsptr *)
  ,strutils (* ansistrright *)
  ;

function iofCreateXForm(pshow: boolean): hwnd;
(* Create the X window class and the window.
   Return its handle. *)

procedure iofDialogMessageLoop(pHandle: integer);
(* Message loop for dialogs. Implements <win32 dialogMessageLoop[,handle]> *)

procedure iofinitform1(pinp:ioinptr);
(* This is supposed to be called when the form is created. That is,
   just after Application.Createform. *)

procedure iofMainLoop(pi: integer);
(* Main message loop *)

procedure iofreadln(var ps: string);
(* Read a line using a pop-up window. *)

procedure iofWriteChToWbuf( pch: char );
(* Add a character to wbuf, if char is line separator (CR),
   then add a line to wbuf (emptying to result window first if necessary).
   Used by ioOutWrite. *)

procedure iofWriteToWbuf( ps: string);
(* Add a string to wbuf. String may contain line separatators.
   For each new line in wbuf, first check that wbuf is not full and
   if it is, empty it by sending it to output window.*)

procedure iofWritelnToWbuf(ps: string);
(* Add a string to current line in wbuf and start on a new line. The string is
   allowed to contain line separators too.
   If wbuf is full, then empty it first by sending it to output window. *)

procedure iofWriteWbufToResarea(pKeepcurrentline:boolean);
(* Empty wbuf by sending all completed lines to resultarea.
   If pcurrentline=true then also write the current, possibly not yet completed,
   line (wbufcurline). *)

function iofwbufempty: boolean;
(* Tell if write buffer is empty or not. *)

procedure iofclear;
(* Clear result area. *)

procedure iofupdateFormCaption;
(* Update form caption with active number of threads. *)
(* iofGetFormValues
   ----------------
   Return current left, top, width and height.
   Used by <formmove>.
*)

procedure iofWcons(pStr: string);
(* Like alWcons, but from the Pascal program. *)

procedure iofGetFormValues(var px,py,pxsize,pysize: integer);

procedure iofstartdebug;
(* Run a debug window. *)

procedure iofbreak(pstateenvptr: xstateenvptr; pxpos: fsptr);
(* Show the debug window and wait for user to step or run.
   mrCancel is returned if user decided to run. *)

procedure iofhelp;
(* Show the help window. *)

procedure iofenterString(var pstateenv: xstateenv; var ptext: string; pLock: boolean);
(* Used by alcleanup and by xdll to call X. pLock is false when calling from
   alcleanup, because ioxlock is then already acquired and need not to be
   acquired again. *)

(* iofEnterLine
   ------------
   Used by the function <enterfromfile ...>
*)
procedure iofEnterLine(Pline: string);

(* (new:) *)
procedure iofgetoutput1(pbufsize: integer; pbuf: pchar);
(* Remove the first pbuflen-1 chars from result window and
   put it in pbuf. Terminate with char(0).
   Used by xdll. *)

procedure iofgetoutput(var ptext: string);
(* Return contents of the output window, then clear the output window.
   Used by xdll. *)

procedure iofregistercallback(paddr: integer);
(* Register parameterless callback function which is called whenever
   something is written to the output window (writewbuf).
   used by xdll. *)

function iofmessagedialog(ps: string; panswers: TMsgDlgButtons): word;
(* Get a response using a message dialog. Used by almessagedialog. *)

procedure iofmove(pleft,ptop,pwidth,pheight: integer);
(* Move the X interpreter window. Used by <move ...> *)

function ioflogto(pfilename: string; usethread: boolean): integer;
(* Log output window to filename. Empty = close and stop. *)

procedure iofthreadinit;
(* Initialize thread local variables of xioform. *)

procedure iofthreadrelease;
(* Release thread-local buffers when leaving a thread. *)

function iofCurrentFormHandle: hwnd;
(* Return handle to xForm[currentform].
   Used, for example, by <win32 visible,...>. *)

function iofResultAreaHandle: hwnd;
(* Return handle to xForm[currentform].resultArea.
   Used by <win32 hresultarea> for debugging of xwgui. *)

type
ioffunctionidtype = (iofformmovefid,iofinputboxfid);

iofargblocktype= RECORD
   functionid: ioffunctionidtype;
   argblockptr: xargblockptrtype;
   funcret: fsptr;
   end;
iofargblockptr = ^iofargblocktype;

procedure iofrunthreadsafe(pfid: ioffunctionidtype;
   pargs: xargblock;
   pfuncret: fsptr);
(* Run a command threadsafe - using iofmessage.
   Example:
   iofrunthreadsafe(iofformmove,pargs); *)

procedure iofrestorecaption;
(* Clear iofspecialcaption (restore standard form caption) and
   update caption. *)

procedure iofSetInitString(pstr: string);
(* Used to execute command line parameters when X is started. *)

procedure iofAddTopLevelWindow(phandle: hwnd);
(* To keep track of userdefined top level windows. *)

procedure iofcleanup;
(* To delete of userdefined top level windows at cleanup,
   and delete iofdefaultoutput. *)

procedure iofShowMess(pStr: string);
(* Delphi independent version of showmessage. *)

procedure xiofAddLineToHistory(
   pi: integer; (* Form number. *)
   ptext: string (* Line. *)
   );
(* Add command (ptext) to the command history of form pi. *)

procedure xiofAddLineToBeginningOfHistory(
   pi: integer; (* Form number. *)
   ptext: string (* Line. *)
   );
(* Add command (ptext) to beginning of the command history of form pi.
   Used by alUsage to insert commands marked with "*". *)


function topLevelWindowHandle: hwnd; // (obsolete)

const
IOFMESSAGE = WM_USER +1; (* Used to distinguish between different messages to
                            tform1. *)
IOFADDWBUF = 1; (* Used to distinguish between different functions in tform1.
                    threadmessage. 1 = add wbuf to memo1. *)
IOFREADCONS = 2; (* Use inputbox to read a line from user (to readlnstr) . *)
IOFTERMINATE = 3; (* Used by <terminate>, so that X can be terminated from a
                     thread. *)
IOFSHOWMESSAGE = 4; (* Used to show a message from a thread. *)
IOFUPDATEFORMCAP = 5; (* Used to update form caption after ending a thread. *)
IOFMINIMIZE = 6; (* <win32 minimize> *)
IOFRESTORE = 7; (* <win32 restore> *)
IOFSHELLEXECUTE = 8; (* <win32 shellexecute,filename,arguments> *)
IOFSHELLEXECUTEEX = 9; (* <win32 shellexecute,filename,arguments> *)
IOFCLEARFORM = 10; (* <clear> *)
IOFUPDATEFORM = 11; (* <win32 updateform> *)
IOFSHOWDEBUGFORM = 12; (* Debug window started with <debug>. *)
IOFDIALOGBOX = 13; (* Use messagedialog to get select response from user
                     (to messagedialoganswer) . *)
IOFGENERAL = 14; (* General threadsafe function, function id given in argblock.
                   Example: (used by) <formmove 100,200,200,400> *)

var
  currentform: integer; (* normal operation: = 1. Debug mode: = 2 *)
  iofdebug: boolean= False; (* Debug mode (single step). *)
  iofstepdown: boolean= False; (* Step down button pushed. *)
  iofentercallcnt: integer = 0; (* Used when xfault shall be reset after error i thread.
      Also used when restoring caption after running an X-script, and to know
      when not to use iofdefaultoutput in place of resultareahandle. *)
  iofspecialcaption: string = ''; (* Caption created by <formcaption ...> *)
  iofdefaultStateEnv: xStateEnv;
  iofapphandle: hwnd;
  iofdefaultoutput: hwnd = 0; (* Enables a gui application to redirect output, e.g. by
      wcons, that normally is sent to resultarea, to its own control.
      See resultareaaddlines. *)
  iofLoadEntered: boolean; (* True = We are in enterString (string entered from
      X window) or iofEnterstring (string entered through xdll or alCleanup) with
      pText = "<load ...". Used by alLoad to detect when a script is loaded
      directly from the X window or from xdll. *)
  iofEnterTextLogged: boolean = false; // Used by play not to read "enter:..." lines
      // from the play file when it has already been read.
  iofManuallyResized: boolean = false; (* Detects when user changes the size of the window.
      Used (through <x manuallyResized>) to prevent resetting window when
      reloading script, if the user has manually adjusted the window size. *)


implementation

uses
xal, (* althreadclass *)
xx, (* xsendto, xsendto_debug *)
xdebug; (*debugdecompile*)


const
IOFWBUFARRAYSIZE = 50;

var
  xbuf: string; (* <...>-command buffer to pass to xsendto. *)
  level: integer; (* Current <>-level in xbuf. *)
  xBufContainsACall: boolean; (* xbuf contains a call (<...>). *)
  wbuf: array[1..IOFWBUFARRAYSIZE] of string; (* iofWriteToWbuf(..)-buffer. Text is only
                   sent to Memo1 in whole lines. *)
  wbufcurline: 1..IOFWBUFARRAYSIZE = 1; (* Current line. Init=1 max =iofwbufarraysixze *)

  formExists: boolean; (* True if Application is started. False if
                          program is run without a main window.
                          (see xtest). *)
  instr: string = '';
  instrWriteLock: syncobjs.tcriticalsection = nil;
  instrLoaded: tsimpleevent = nil;
  breakpointpassed: tsimpleevent = nil;
  xcodestr: string = ''; (* Decompiled x code for debug form. *)
  initstring: string = '';

  wbufLineLen: integer = 0;

  type intptr = ^integer;
  var sqlenv: intptr;

  stateenv: xstateenv;

  debugstateenvptr: xstateenvptr;
  cformsave: integer;

  eoa: char;
  GeneralWriteLock: syncobjs.tcriticalsection = nil;
  GeneralCompletion: tsimpleevent = nil;

DefaultWndProc: TWndMethod;

threadvar
(* These are made global variables to avoid frequent
   creation (fsnew) and disposal (fsdispose). *)
win32args: fsptr;
win32retstr: fsptr;

const
LineTabSize=50;

var
xForm: array[1..2] of record
   handle: hwnd;
   cmdLineId: integer;
   cmdLineHandle: hwnd;
   enterButtonHandle: hwnd;
   resultAreaId: integer;
   ResultAreaHandle: hwnd;
   ResAreaSelStart, ResAreaSelEnd: integer; // Used to remember position when jumping with tab
   ResAreaLength: integer; (* Storage of current length - to avoid unnesseccary calls to
      getWindowTextLength. *) 
   stepButtonHandle: hwnd;
   downButtonHandle: hwnd;
   runButtonHandle: hwnd;
   xCodeAreaId: integer;
   xCodeAreaHandle: hwnd;
   focus: hwnd; // Current local focus
   // Enter string history
   linenr,oldestlinenr: integer;
   linetab: array[0..LineTabSize] of string; (* 1..LineTabSize are used for history
      0 is used for temporary storage of current entry line. *)
   end;

(* For deleting created windows at cleanup: *)
const
topLevelWinTabSize = 20;

var
topLevelWintabOverflow: boolean= false;
topLevelWinTab: array[1..topLevelWinTabSize] of integer;
topLevelWinCount: integer = 0;

oldIODummy: xSavedIODataRecord;

procedure iofAddTopLevelWindow(phandle: hwnd);
(* To keep track of userdefined top level windows. *)
begin
if topLevelWinTabOverflow then
   // (nothing)
else if topLevelWinCount=topLevelWinTabSize then begin
   topLevelWinTabOverflow:= true;
   // (Error message could be put here)
   end
else begin
   TopLevelWinCount:= topLevelWinCount+1;
   topLevelWinTab[topLevelWinCount]:= phandle;
   end;
end;

function topLevelWindowHandle: hwnd;
begin
if topLevelWinCount>0 then topLevelWindowHandle:= topLevelWinTab[1]
else topLevelWindowHandle:= 0
end;


procedure iofcleanup;
(* To delete of userdefined top level windows at cleanup,
   and delete iofdefaultoutput. *)
var w: integer;
begin
(* Delete top level window(s) of the class "xwindowclass" if any. *)
for w:= 1 to topLevelWinCount do begin
   if w<= topLevelWintabSize then begin
      if not DestroyWindow(topLevelWinTab[w]) then
         xProgramError('X(alcleanup) - Program error: ' +
            'Unable to destroy top level window ' + inttostr(w) +
            ' - ' + alSystemErrorMessage() + '.');
      end
   else if w=topLevelWintabSize+1 then
      xProgramError('X(alcleanup) - X expected max ' +
         inttostr(topLevelWintabSize) + ' top level windows' +
         ' so it was unable to destroy the excessive top level windows ' +
         inttostr(topLevelWintabSize+1) + ' to ' + inttostr(topLevelWinCount) +
         ' that this script had created.');
   end;(* for *)
topLevelWinCount:= 0;

iofdefaultoutput:= 0;
end;


procedure programErrorNonIntegerReturned;
(* This is put in a separate procedure to avoid creating
   a string in the normal case (no error). *)
var str: string;
begin
   str:= '<win32WindowProc ...> - was supposed to return nothing or an integer, ' +
      'but was found to return "' + alfstostr(win32retstr,char(fseofs)) + '".';

   (* win32retstr must be deleted before calling alfault to prevent alfault
      from calling itself and eventually depleting the stack.*)
   fsrewrite(win32retstr);
   xProgramError(str);
end; (*programErrorNonIntegerReturned*)

// (debug:)
var wmpcnt: integer;

// (new:)
procedure win32WindowProc(phwnd: integer; var Message: TMessage);
var ptr,lptr: fsptr;
args: xargblock;
len: integer;
begin
fsrewrite(win32args);
ptr:= win32args;

with args do begin

   // arg1: hwnd
   // Space for length
   lPtr:= ptr;
   fspshend(ptr,char(0));
   fspshend(ptr,char(0));
   arg[1]:= ptr;
   alinttofs(phwnd,ptr);
   fspshend(ptr,char(xeoa));
   // Set length
   len:= integer(ptr)-integer(arg[1])-1;
   lptr^:= char(len div 250);
   fsforward(lptr);
   lptr^:= char(len mod 250);
   rekursiv[1]:= false;

   // arg2: msg
   lPtr:= ptr;
   fspshend(ptr,char(0));
   fspshend(ptr,char(0));
   arg[2]:= ptr;
   alinttofs(message.Msg,ptr);
   fspshend(ptr,char(xeoa));
   // Set length
   len:= integer(ptr)-integer(arg[2])-1;
   lptr^:= char(len div 250);
   fsforward(lptr);
   lptr^:= char(len mod 250);
   rekursiv[2]:= false;

   // arg3: wparam
   lPtr:= ptr;
   fspshend(ptr,char(0));
   fspshend(ptr,char(0));
   arg[3]:= ptr;
   alinttofs(message.WParam,ptr);
   fspshend(ptr,char(xeoa));
   len:= integer(ptr)-integer(arg[3])-1;
   lptr^:= char(len div 250);
   fsforward(lptr);
   lptr^:= char(len mod 250);
   rekursiv[3]:= false;

   // arg4: lparam
   lPtr:= ptr;
   fspshend(ptr,char(0));
   fspshend(ptr,char(0));
   arg[4]:= ptr;
   alinttofs(message.lParam,ptr);
   fspshend(ptr,char(xeoa));
   len:= integer(ptr)-integer(arg[4])-1;
   lptr^:= char(len div 250);
   fsforward(lptr);
   lptr^:= char(len mod 250);
   rekursiv[4]:= false;

   narg:= 4;
   end;

// BFn 111216: X shall always be locked except when waiting for things outside X.
if iolockcount<0 then begin
   iodisableotherthreads(30);
   alcall(alwin32windowproc,args,xEvalNormal,xcurrentStateEnv^,win32retstr);
   ioenableotherthreads(30);
   end
else
   alcall(alwin32windowproc,args,xEvalNormal,xcurrentStateEnv^,win32retstr);

end; (* win32WindowProc *)

// (old:)
procedure win32WindowProc0(var Message: TMessage);
var ptr,lptr: fsptr;
args: xargblock;
len: integer;
begin
fsrewrite(win32args);
ptr:= win32args;

with args do begin

   // Space for length
   lPtr:= ptr;
   fspshend(ptr,char(0));
   fspshend(ptr,char(0));
   arg[1]:= ptr;
   alinttofs(message.Msg,ptr);
   fspshend(ptr,char(xeoa));
   // Set length
   len:= integer(ptr)-integer(arg[1])-1;
   lptr^:= char(len div 250);
   fsforward(lptr);
   lptr^:= char(len mod 250);
   rekursiv[1]:= false;

   lPtr:= ptr;
   fspshend(ptr,char(0));
   fspshend(ptr,char(0));
   arg[2]:= ptr;
   alinttofs(message.WParam,ptr);
   fspshend(ptr,char(xeoa));
   len:= integer(ptr)-integer(arg[2])-1;
   lptr^:= char(len div 250);
   fsforward(lptr);
   lptr^:= char(len mod 250);
   rekursiv[2]:= false;

   lPtr:= ptr;
   fspshend(ptr,char(0));
   fspshend(ptr,char(0));
   arg[3]:= ptr;
   alinttofs(message.lParam,ptr);
   fspshend(ptr,char(xeoa));

   len:= integer(ptr)-integer(arg[3])-1;
   lptr^:= char(len div 250);
   fsforward(lptr);
   lptr^:= char(len mod 250);
   rekursiv[3]:= false;

   narg:= 3;
   end;

// BFn 111216: X shall always be locked except when waiting for things outside X.
if iolockcount<0 then begin
   iodisableotherthreads(30);
   alcall(alwin32windowproc,args,xEvalNormal,xcurrentStateEnv^,win32retstr);
   ioenableotherthreads(30);
   end
else
   alcall(alwin32windowproc,args,xEvalNormal,xcurrentStateEnv^,win32retstr);

end; (* win32WindowProc0 *)

// (new:)
var
dialogHandle: integer = 0; // Set by iofDialogMessageLoop

function WindowProc(hWnd,Msg,wParam,lParam:Integer):Integer; stdcall;
var message: tmessage;
var
dmsg: tmsg;
res: integer;
i: integer;
found: boolean;

begin

if alwin32windowproc<>0 then begin
   message.Msg:= msg;
   message.WParam:= wparam;
   message.LParam:= lparam;
   (* (new:) *)
   win32WindowProc(hwnd,message);
   // (old:) win32WindowProc(message);
   end;

if hwnd=dialogHandle then
   if Msg = WM_DESTROY then
      PostQuitMessage(0);

(*
if (msg<>wm_getdlgcode) and (msg<>wm_showwindow) and (msg<>wm_geticon) and
   (msg<>wm_activateapp) and (msg<>wm_ncactivate) and (msg<>wm_activate) and
   (msg<>WM_IME_NOTIFY) and (msg<>WM_SETFOCUS) and (msg<>WM_SIZE) and
   (msg<>WM_MOVE) and (msg<>WM_KILLFOCUS) and (msg<>WM_NCHITTEST) and
   (msg<>$88) and  (msg<>$f) and (msg<>$20) and (msg<>$200) and
   (msg<>$21) and (msg<>$201) and (msg<>$a0) and (msg<>$202) and
   (msg<>$2a2) and (msg<>$111) and (msg<>$24) and (msg<>$81) and
   (msg<>$83) and (msg<>$131) and (msg<>1) and (msg<>$46) and
   (msg<>$d) and (msg<>$31) and (msg<>$281) and (msg<>$85) and
   (msg<>$14) and (msg<>$210) and (msg<>$47) and (msg<>$138) and
   (msg<>$134) and (msg<>$133) and (msg<>$135) and (msg<>$bd00) then
*)
// (This is old stuff that probably does not work)
if (msg=$100) and false then begin
   dmsg.hwnd:= hwnd;
   dmsg.message:= msg;
   dmsg.wParam:= wparam;
   dmsg.lParam:= lparam;
   dmsg.time:= 0;
   dmsg.pt.X:= 0;
   dmsg.pt.Y:= 0;
   res:= integer(isdialogmessage(toplevelwindowhandle,dmsg));
   end;

if win32retstr^=char(fseofs) then
   // No output from user defined window proc - call default window proc.
   Res := DefWindowProc(hWnd,Msg,wParam,lParam)
else begin
   (* User defined window proc returned something - return it (supposed to be
      integer) and skip default window proc. *)
   if not alfstoint(win32retstr,res) then begin
      (* (This error message does not appear to work very well, probably because it is
         called from within windowproc. It just show a long title bar.
         /BFn 120528 *)
      programErrorNonIntegerReturned;
      res:= 0;
      end
   else fsrewrite(win32retstr);
   end;


windowproc:= res;

if Msg = WM_DESTROY then begin
   // If it was any of the top level windows - remove it from the table
   found:= false;
   for i:= 1 to topLevelWinCount do begin
      if found then topLevelWintab[i-1]:= topLevelWintab[i]
      else if topLevelWinTab[i]=hwnd then found:= true;
      end;
   if found then topLevelWinCount:= topLevelWinCount-1;
   end;

end;(*WindowProc*)



var (* (Tried to put wclass variables local in iofinitform1 but it would not
   work. Could have something to do with registerclass saving only
   the pointer to the class so if the class is overwritten later it will
   not work.) *)
xFormClass: TWndClass;
wClass: TWndClass;

function xFormMessageProc(winHandle: HWND; Msg: UINT; WParam: WPARAM;
   LParam: LPARAM): UINT; stdcall; forward;

function newMLEditMessageProc(hWnd: HWND; Msg: UINT; WParam: WPARAM;
   LParam: LPARAM): UINT; stdcall; forward;

var
oldEditWndProc: Tfarproc; // ptr to old window proc
font: hfont;
xcap: string= 'X '; // FPC
// (old:) xcap: string= 'X-fpc '; // FPC
// xcap: string:= 'X '; // Delphi



function iofCreateXForm(pshow: boolean): hwnd;
(* Create the X window class and the X form.
   Return its handle. *)

var
i: integer;


begin
xFormClass.hInstance := hInstance;
 with xFormClass do
 begin
  {there are more xFormClass parameters which are
  not used here to  keep this simple}
    style:= 0;
    hIcon:= LoadIcon(hInstance,'MAINICON');
    lpfnWndProc:= @xFormMessageProc;
    hbrBackground:= COLOR_BTNFACE+1;
    {COLOR_BTNFACE is not a brush, but sets it
    to a system brush of that Color}
    lpszClassName:= 'xForm class';
    {you may use any class name, but you may want to make it descriptive
    if you register more than one class}
    hCursor:= LoadCursor(0,IDC_ARROW);

    cbClsExtra:= 0;
    cbWndExtra:= 0;
    lpszMenuName:= '';
  end;

  windows.RegisterClass(xFormClass);

 {the First Window created in a Program for a Registered
  Class will be the apps Main Window or "Form" in Delphi
  terminology, and will be the Main Form for this App.}

  xForm[1].handle := CreateWindow(
    xFormClass.lpszClassName,
    pChar(xcap),
    WS_OVERLAPPEDWINDOW,
    Integer(CW_USEDEFAULT),
    Integer(CW_USEDEFAULT),
    505,
    302,
    0,
    0,
    hInstance,
    nil
   );


   // Debug form:
   xForm[2].Handle := CreateWindow(
      xFormClass.lpszClassName,
      'X debug',
      WS_OVERLAPPEDWINDOW,
      Integer(CW_USEDEFAULT),
      Integer(CW_USEDEFAULT),
      505,
      600,
      0,
      0,
      hInstance,
      nil
      );

   Font:=CreateFont (-11, 0, 0, 0, 0, 0, 0, 0, ANSI_CHARSET,
      OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
		DEFAULT_PITCH or FF_SWISS, 'MS Sans Serif');

   for i:= 1 to 2 do begin

      xform[i].cmdlineId:= 1001;
      //xform[i].cmdLineHandle:= CreateWindowEx($10100,'edit','',$50010080,40,40,345,21,
      xform[i].cmdLineHandle:= CreateWindowEx($200,'edit','',$50010080,40,40,345,21,
      (* $200 = WS_EX_CLIENTEDGE (sunken)
         50010080 = 40000000(WS_CHILD) + 10000000(WS_VISIBLE) + 10000(WS_TABSTOP) +
         80(ES_AUTOHSCROLL) *)
         xForm[i].handle,xform[i].cmdlineId,hInstance,nil);
      SendMessage (xform[i].cmdLineHandle, WM_SETFONT, WPARAM (Font), 1);

      xform[i].enterButtonHandle:= CreateWindow('button','Enter',$50010001,400,40,59,25,
         xForm[i].handle,0,hInstance,nil);
      SendMessage (xform[i].enterButtonHandle, WM_SETFONT, WPARAM (Font), 1);

      // Set the new font for the control:

      xform[i].resultAreaId:= 1002;

      xform[i].resultAreaHandle:= CreateWindowEx($200,'edit','',$50011044,40,72,417,177,
         xForm[i].handle,xform[i].resultAreaId,hInstance,nil);

      // (old debug:) iofshowmess('iofCreateXForm: xForm['+inttostr(i)+'].resultareahandle = '+inttostr(xform[i].resultAreaHandle)+'.');

      (* $200 = WS_EX_CLIENTEDGE (sunken)
         $50211044 = 40000000(WS_CHILD) + 10000000(WS_VISIBLE) + 200000(WS_VSCROLL) +
         10000(WS_TABSTOP) + 1000(ES_WANTRETURN) + 40(ES_AUTOVSCROLL) + 4(ES_MULTILINE) *)
      SendMessage (xform[i].resultAreaHandle, WM_SETFONT, WPARAM (Font), 1);
      (* Remove the 32kbyte size limit. *)
      SendMessage (xform[i].resultAreaHandle, EM_LIMITTEXT, 0, 0);

      // Init position and selection to unknown:
      xform[i].ResAreaSelStart:= -1;
      xform[i].ResAreaSelEnd:= -1;

      xform[i].ResAreaLength:= -1; // Unknown

      (* To catch tab-buttons in multiline resultarea edit (google on
         "Issue with tab key in multiline edit (Win32)"). *)
      (* oldEditWndProc = ( WNDPROC ) SetWindowLong( hWndEdit, GWL_WNDPROC,
         ( long ) NewEditWndProc ); *)

      oldEditWndProc:= TFarProc(SetWindowLong(xform[i].ResultAreaHandle,
         GWL_WNDPROC,integer(@NewMLEditMessageProc)));

      if i=2 then begin
         // (Debug form)
         xform[i].stepButtonHandle:= CreateWindow('button','Step',$50010000,40,256,75,17,
            xForm[i].handle,0,hInstance,nil);
         SendMessage (xform[i].stepButtonHandle, WM_SETFONT, WPARAM (Font), 1);

         xform[i].DownButtonHandle:= CreateWindow('button','Down',$50010000,128,256,75,17,
            xForm[i].handle,0,hInstance,nil);
         SendMessage (xform[i].downButtonHandle, WM_SETFONT, WPARAM (Font), 1);

         xform[i].RunButtonHandle:= CreateWindow('button','Run',$50010000,216,256,75,17,
            xForm[i].handle,0,hInstance,nil);
         SendMessage (xform[i].RunButtonHandle, WM_SETFONT, WPARAM (Font), 1);

         xform[i].xCodeAreaId:= 1003;
         xform[i].xCodeAreaHandle:= CreateWindowEx($200,'edit','',$50211044,40,280,417,89,
            xForm[i].handle,xform[i].xCodeAreaId,hInstance,nil);
         SendMessage (xform[i].xCodeAreaHandle, WM_SETFONT, WPARAM (Font), 1);
         (* Remove the 32kbyte size limit. *)
         SendMessage (xform[i].resultAreaHandle, EM_LIMITTEXT, 0, 0);
         end
      else begin

         // (Normal form)
         xform[i].stepButtonHandle:= 0;
         xform[i].DownButtonHandle:= 0;
         xform[i].RunButtonHandle:= 0;
         xform[i].xCodeAreaHandle:= 0;

         // Add <load> to history
         xform[i].oldestlinenr:= 1;
         xform[i].linetab[1]:= '<load>';

         end;
      end;


  if pshow then ShowWindow(xForm[1].handle, SW_SHOWNORMAL);
  SetFocus(xForm[1].cmdLineHandle);
  xform[1].focus:= xForm[1].cmdLineHandle;

  {the WS_VISIBLE style was NOT set in the Main window creation
   so you need to call ShowWindow( ) to make it visible.
   This "ShowWindow" with SW_SHOWNORMAL is a Standard way to make your 
   program visible, if you use this then your progrm can be started
   by another program as Maximized or Minimized, otherwize those 
   options will be ignored}

  UpdateWindow(xForm[1].handle);

  {the update line above is not needed here because the message loop
   has not started yet, but I have added it to show that you need to
   update to get changes to a window to be visible after the message loop starts}

iofCreateXForm:= xForm[1].handle;

end; (*iofCreateXForm*)

procedure iofinitform1(pinp:ioinptr);
(* This is supposed to be called when tform1 is created. That is,
   just after Application.Createform. *)
var stat:ioint16;
begin
xinitstateenv(iofdefaultstateenv,pinp);
alSaveIoPtr:= @oldIODummy; // (needed?)

xcurrentStateEnv:= @iofdefaultstateenv;
formExists:= true;

// Create appform with pure win32.
//wClass.lpszClassName:= 'CN';
wClass.lpszClassName:= 'xwindowclass';
 wClass.lpfnWndProc :=  @WindowProc;
 {CreateWindow( ) will not work without setting the
 2 wClass parameters above}

 wClass.hInstance := hInstance;
 wClass.hbrBackground:= color_btnface+1;
 {CreateWindow( ) will still create a window without the
 2 wClass parameters above, but they shoud be included}

// wClass.hIcon := LoadIcon(hInstance,'MAINICON');
 wClass.hCursor := LoadCursor(0,IDC_ARROW);

stat:= windows.RegisterClass(wClass);

if stat=0 then
   xprogramerror('X(iofinitform1): Received zero from registerclass. '+
   'Error code '+alSystemErrorMessage+'.');

(* Reset last error because RegisterClass appears to set it to 2
   (cant find file) also when it succeeds. *)
setLastError(0);

end;

function gettext(phandle: hwnd; pid: integer): string; forward;

var
testtemp: string;

procedure iofMainLoop(pi: integer);
(* Main message loop *)
var
msg: TMsg;
dialogmessage: boolean;
i: integer;
finished: boolean;

begin

while windows.GetMessage(Msg,0,0,0) do begin
   (* GetMessage will return True until it gets a WM_OUIT message.
      So this program will keep running until you Post a Quit Message *)

   finished:= false;
   if (msg.message=wm_keydown) and (msg.hwnd=xform[pi].cmdLineHandle) then
      with xform[pi] do begin
      if msg.wparam=vk_up then begin
         // Up
         if linenr=0 then
            // Save current contents temporarily in linetab[0]
            linetab[0]:= gettext(handle,cmdLineId);

         if linenr<oldestlinenr then begin
            linenr:=linenr+1;
            SetDlgItemTextA(handle,cmdLineId,pchar(linetab[linenr]));
            end;
         finished:= true;
         end
      else if msg.wparam=vk_down then begin
         // Down
         if linenr>0 then begin
            linenr:=linenr-1;
            SetDlgItemTextA(handle,cmdLineId,pchar(linetab[linenr]));
            end;
         finished:= true;
         end;
      end;

   if not finished then begin

      dialogmessage:=IsDialogMessage(xform[pi].handle,msg);
      if dialogmessage then
         // (Already processed in IsDialogMessage)
      else begin
         // See if dialogmessage to any user defined toplevelwindow
         i:= 1;
         while (i<=topLevelWinCount) and not dialogmessage do begin
            dialogmessage:= IsDialogMessage(topLevelWinTab[i],msg);
            i:= i+1;
            end;
         end;

      if not dialogmessage then begin

         (* Translate any WM_KEYDOWN keyboard Msg to a WM_CHAR message *)
         TranslateMessage(Msg);

         (* This Sends Msg to the address of the "Window Procedure" set
            in the Resistered Window's Class for that window *)
         DispatchMessage(Msg);
         end;
      end;
   end; (* (while) *)

end;(* (iofmainloop) *)

var
count: integer = 0;

procedure iofDialogMessageLoop(pHandle: integer);
(* Message loop for dialogs. Implements <win32 dialogMessageLoop[,handle]> *)
var
msg: TMsg;
finished: boolean;

begin

dialogHandle:= pHandle;

while windows.GetMessage(Msg,0,0,0) do begin
   (* GetMessage will return True until it gets a WM_OUIT message.
      So this program will keep running until you Post a Quit Message *)

   finished:= false;

   (* (old: Trying to find wm_destroy or wm_close in this loop
      put it appears to be impossible.
      case msg.message of
         $F,$A0,$A1,$113,$200,$2a2,$b000,$b001,$c0e2,$c0d7:;
         else
         count:= count+1;
         end;
      if count=-1 then iofshowmess('hej');
   *)

   if pHandle<>0 then finished:=IsDialogMessage(hwnd(pHandle),msg);

   if not finished then begin

      (* Translate any WM_KEYDOWN keyboard Msg to a WM_CHAR message *)
      TranslateMessage(Msg);

      (* This Sends Msg to the address of the "Window Procedure" set
         in the Resistered Window's Class for that window *)
      DispatchMessage(Msg);
      end;
   end; (* (while) *)

dialogHandle:= 0;

end;(* (iofDialogMessageLoop) *)


procedure iofreadln(var ps: string);
(* Read a line using a pop-up window. *)
var l: integer;
begin
if alPlayRunning then begin
   iofWriteWbufToResarea(false);
   ps:= alPlayGetInput;
   iofWritelnToWbuf('in:'+ps);
   end
else if formExists then begin
   iofWriteWbufToResarea(false);
   if althreadnr=0  then begin
      ioenableotherthreads(12);
      try
         ps:= InputBox('X','X readln:','');
      finally
        iodisableotherthreads(12);
        end;
      end
   else begin

      (* 1. Let only one thread use this function at a time. *)
      ioenableotherthreads(13);
      try
         instrWritelock.Acquire;
      finally
         iodisableotherthreads(13);
         end;

      (* 2. Use instrloaded to wait for completion. *)
      instrloaded.ResetEvent;

      (* 3. Send message to iofthreadmessage. *)

      postmessage(xform[currentform].handle,IOFMESSAGE,IOFREADCONS,0);

      (* 4. Wait until user has entered a string (but enable other threads). *)
      ioenableotherthreads(14);
      try
         instrloaded.WaitFor(infinite);
      finally
         iodisableotherthreads(14);
         end;

      (* 5. Take string. *)
      ps:= instr;
      instr:= '';

      (* 6. Enable other threads to use this function. *)
      instrWritelock.Release;
      end;

   iofWritelnToWbuf('in:'+ps);
   end

else begin
   ioenableotherthreads(15);
   try
      ps:= InputBox('X',wbuf[1],'');
   finally
      iodisableotherthreads(15);
      end;
   for l:= 1 to wbufcurline do wbuf[l]:= '';
   wbufcurline:= 1;
   wbufLineLen:= 0;
   end;
end; (*iofreadln*)

type
messagedlgDataType = record
   (* Parameters to the IOFDIALOGBOX message. *)
   messagestr: string; (* in *)
   answers: TMsgDlgButtons; (* in *)
   answer: word; (* out *)
   end;

messageDlgDataPtrType= ^messageDlgDataType;


function iofmessagedialog(ps: string; panswers: TMsgDlgButtons): word;
(* Get a response using a message dialog. Used by almessagedialog. *)
var answer: word;
messagedialogdata: MessageDlgDataType;

begin

   (* Send any buffered data. *)
   iofWriteWbufToResarea(false);

   (* If main thread, messagedlg can be called directly. *)
   if althreadnr=0  then begin
      (* Allow 100ms for updating the main form (to avoid that
         the main form is put on top of the message dialog). *)
      ioEnableAndSleep(100);
      
      ioenableotherthreads(16);
      try
         answer:= MessageDlg(ps,mtcustom,panswers,0);
      finally
         iodisableotherthreads(16);
         end;
      end
   else begin

      (* 0. Use same events as for iofreadln (it is only good that they
         concurrent dialogs are queued). *)

      (* 1. Let only one thread use this function at a time. *)
      ioenableotherthreads(17);
      try
         instrWritelock.Acquire;
      finally
         iodisableotherthreads(17);
         end;

      (* 2. Use instrloaded to wait for completion. *)
      instrloaded.ResetEvent;

      (* 3. Send message to iofthreadmessage. *)
      messageDialogData.messagestr:= ps;
      messageDialogData.answers:= panswers;
      postmessage(xform[currentform].handle,IOFMESSAGE,IOFDIALOGBOX,
         longint(@messageDialogData));

      (* 4. Wait until user has entered a string (but enable other threads). *)
      ioenableotherthreads(18);
      try
         instrloaded.WaitFor(infinite);
      finally
         iodisableotherthreads(18);
         end;

      (* 5. Take result. *)
      answer:= messagedialogData.answer;

      (* 6. Enable other threads to use this function. *)
      instrWritelock.Release;
      end;

   iofmessagedialog:= answer;

end; (*iofmessagedialog*)

procedure iofmovewindow(phandle: hwnd; pleft,ptop,pwidth,pheight: integer;
   pupdate: boolean); forward;
   
procedure resize; forward;


procedure iofformmove(pargptr: xargblockptrtype);
var arg1,arg2,arg3,arg4: integer; fault: boolean;
begin

fault:= false;
arg1:= -1;
arg2:= -1;
arg3:= -1;
arg4:= -1;

with pargptr^ do begin
   if (narg>=1) and (arg[1]^<>eoa) then begin
      arg1:= fsposint(arg[1]);
      if arg1<0 then fault:=true;
      end;
   if (narg>=2) and (arg[2]^<>eoa) then begin
      arg2:= fsposint(arg[2]);
      if arg2<0 then fault:=true;
      end;
   if (narg>=3) and (arg[3]^<>eoa) then begin
      arg3:= fsposint(arg[3]);
      if arg3<0 then fault:=true;
      end;
   if (narg>=4) and (arg[4]^<>eoa) then begin
      arg4:= fsposint(arg[4]);
      if arg4<0 then fault:=true;
      end;

   if fault then xProgramError('X(<move '+
      fstostr(arg[1])+','+
      fstostr(arg[2])+','+
      fstostr(arg[3])+','+
      fstostr(arg[4])+','+
      '>): Integer >= 0, or empty, was expected in all four parameters.')
   else begin
      if currentform=1 then begin
         iofmovewindow(xform[1].handle,arg1,arg2,arg3,arg4,true);
         resize;
         end;
      end;
   end; (*with*)

end; (*iofformmove*)


procedure iofinputbox(pargptr: xargblockptrtype;pfuncret: fsptr);
var arg1,arg2,arg3,res: string;
begin

with pargptr^ do begin
   arg1:= alfstostr(arg[1],eoa);
   arg2:= alfstostr(arg[2],eoa);
   if narg>2 then
     arg3:= alfstostr(arg[3],eoa)
   else arg3:= '';
   res:= inputbox(arg1,arg2,arg3);
   alstrtofs(res,pfuncret);
   end; (*with*)

end; (*iofinputbox*)

procedure iofrunthreadsafe(pfid: ioffunctionidtype;
   pargs: xargblock;
   pfuncret: fsptr);
(* Run a command threadsafe - using iofmessage.
   Example:
   iofrunthreadsafe(iofformmove,pargs,pfuncret);
   iofrunthreadsafe(iofinputbox,pargs,pfuncret);
   pargs are expected to be evaluated before caling
   iofrunthreadsafe. *)
var
argptr: ^iofargblocktype;
begin

// Empty write to edit-buffer
iofWriteWbufToResarea(false);

if althreadnr=0  then begin
   // Main thread: Run directly
   case pfid of
      iofformmovefid: iofformmove(@pargs);
      iofinputboxfid: iofinputbox(@pargs,pfuncret);
      end; (*case*)
   end

else begin

   // Subthread, Run using postmessage
   (* 1. Let only one thread use this function at a time. *)
   ioenableotherthreads(19);
   try
      GeneralWritelock.Acquire;
   finally
      iodisableotherthreads(19);
      end;

   (* 2. Use generalcompletion to wait for completion. *)
   GeneralCompletion.ResetEvent;

   (* 3. Send message to iofthreadmessage. *)
   new(argptr);
   argptr^.functionid:= pfid;
   argptr^.argblockptr:= xargblockptrtype(@pargs);
   argptr^.funcret:= pfuncret;
   postmessage(xform[currentform].handle,IOFMESSAGE,IOFGENERAL,longint(argptr));

   (* 4. Wait until completion (but enable other threads). *)
   ioenableotherthreads(20);
   try
      GeneralCompletion.WaitFor(infinite);
   finally
      iodisableotherthreads(20);
      end;

  (* 5. Enable other threads to use this function. *)
  GeneralWritelock.Release;

  (* 6. manuallyResized shall be true after manual resize but not after resize by
      <formmove ...> (iofformmove). *)
   if pfid=iofformmovefid then iofManuallyResized:= false;
  end;

end; (*iofrunthreadsafe*)


(* Here follow a type, six procedures and a function, whose names all
   begin with "ioft" (for "input output form thread"). They form a
   small software package. The package can be used to avoid that the
   program is blocked for a while now and then when it is writing to a
   log file. Such blocking can be especially problematic when the file
   is not on the computer's own hard disk but on some file server
   elsewhere.

   Type ioftFileType and procedures ioftOpen, ioftClose, ioftWrite and
   ioftWriteln are intended to be used directly from outside the
   package. Procedures ioftWriteToBuffer and ioftWriteFromBuffer and
   function ioftThreadFunction are only intended for internal use by
   the package. Also the components of type ioftFileType are only
   intended for internal use.

   The package requires an underlying ordinary text file, which must
   be open for writing while the package is used.

   To use the package, do as follows. Declare a variable, say
   ioftFile, of type ioftFileType. Make sure the underlying text file
   is open for writing. Call procedure ioftOpen with ioftFile and a
   pointer to the open text file as the first two parameters. Then to
   write to the log file, call procedures ioftWrite and ioftWriteln as
   desired. The calls to ioftWrite and ioftWriteln will not block.
   When all writing is done, call procedure ioftClose. You may then
   close the underlying text file, if desired.

   Blocking is avoided in the following way. Between the calls to
   ioftOpen and ioftClose, a special thread is running. Calls to
   ioftWrite and ioftWriteln put the text to log in a queue, an
   operation which does not block. The thread continuously writes out
   the queued text to the underlying text file, which may involve
   delays in the special thread but not in the program's other
   threads.

   The size in characters of the queue is specified by parameter
   BufLen to procedure ioftOpen. In case the queue overflows, some
   text will be lost, and the message specified by parameter
   OverflowMessage will be written to the log file to warn about the
   loss. *)

type
   ioftFileType =
      record
         TextFilePtr : PText;
         OverflowMessage : String;
         Buf : String;
         R, W : Integer;
         Stop : Boolean;
         CS : TRTLCriticalSection;
         State : PRTLEvent;
         ThreadID : TThreadID
      end;

procedure ioftWriteToBuffer
  (OverflowMessage : String; var Buf : String; R : Integer; var W : Integer; S : String);
   procedure HelpWrite(S : String);
   var
      N, M : Integer;
   begin
      N := 0;
      while N < Length(S) do
         begin
            M := Min(Length(S) - N, Length(Buf) - W);
            Move(S[N + 1], Buf[W + 1], M);
            N := N + M;
            W := (W + M) mod Length(Buf)
         end
   end;
var
   Free : Integer;
begin
   Free := (Length(Buf) + R - W - 1) mod Length(Buf);
   if Length(S) + Length(OverflowMessage) <= Free then
      HelpWrite(S)
   else if Length(OverflowMessage) <= Free then
      begin
         HelpWrite(LeftStr(S, Free - Length(OverflowMessage)));
         HelpWrite(OverflowMessage)
      end
end;

procedure ioftWriteFromBuffer(var TextFile : Text; Buf : String; var R : Integer; W : Integer);
var
   M : Integer;
begin
   while R <> W do
      begin
         if R < W then
            M := W - R
         else
            M := Length(Buf) - R;
         Write(TextFile, MidStr(Buf, R + 1, M));
         R := (R + M) mod Length(Buf)
      end
end;

function ioftThreadFunction(P : Pointer) : Ptrint;
type
   ioftFilePtrType = ^ioftFileType;
var
   ioftFilePtr : ioftFilePtrType;
   R, W : Integer;
   Stop : Boolean;
begin
   ioftFilePtr := ioftFilePtrType(P);
   repeat
      RTLEventWaitFor(ioftFilePtr^.State);
      R := ioftFilePtr^.R;
      W := ioftFilePtr^.W;
      Stop := ioftFilePtr^.Stop;
      LeaveCriticalSection(ioftFilePtr^.CS);
      if R <> W then
         begin
            ioftWriteFromBuffer(ioftFilePtr^.TextFilePtr^, ioftFilePtr^.Buf, R, W);
            EnterCriticalSection(ioftFilePtr^.CS);
            ioftFilePtr^.R := R;
            LeaveCriticalSection(ioftFilePtr^.CS)
         end
   until Stop;
   ioftThreadFunction := 0
end;

procedure ioftOpen
  (var ioftFile : ioftFileType;
   TextFilePtr : PText;
   OverflowMessage : String;
   BufLen : Integer);
var
   Success : Boolean;
begin
   ioftFile.TextFilePtr := TextFilePtr;
   ioftFile.OverflowMessage := OverflowMessage;
   SetLength(ioftFile.Buf, BufLen);
   ioftFile.R := 0;
   ioftFile.W := 0;
   ioftFile.Stop := False;
   InitCriticalSection(ioftFile.CS);
   ioftFile.State := RTLEventCreate;
   ioftFile.ThreadID := BeginThread(@ioftThreadFunction, @ioftFile);
   Success := ThreadSetPriority(ioftFile.ThreadID, THREAD_PRIORITY_LOWEST)
end;

procedure ioftClose(var ioftFile : ioftFileType);
begin
   EnterCriticalSection(ioftFile.CS);
   ioftFile.Stop := True;
   LeaveCriticalSection(ioftFile.CS);
   RTLEventSetEvent(ioftFile.State);
   WaitForThreadTerminate(ioftFile.ThreadID, 0);
   CloseThread(ioftFile.ThreadID);
   RTLEventDestroy(ioftFile.State);
   DoneCriticalSection(ioftFile.CS);
   ioftFile.Buf := '';
   ioftFile.TextFilePtr := nil
end;

procedure ioftWrite(var ioftFile : ioftFileType; S : String);
var
   R, W : Integer;
begin
   EnterCriticalSection(ioftFile.CS);
   R := ioftFile.R;
   W := ioftFile.W;
   LeaveCriticalSection(ioftFile.CS);
   ioftWriteToBuffer(ioftFile.OverflowMessage, ioftFile.Buf, R, W, S);
   EnterCriticalSection(ioftFile.CS);
   ioftFile.W := W;
   LeaveCriticalSection(ioftFile.CS);
   RTLEventSetEvent(ioftFile.State)
end;

procedure ioftWriteln(var ioftFile : ioftFileType; S : String);
begin
   ioftWrite(ioftFile, S);
   ioftWrite(ioftFile, Chr(13) + Chr(10))
end;


var
logfile: text;
logging: boolean= False;
logfilename: string= '';
logusethread: boolean = false;
ioftFile: ioftFileType;

function ioflogto(pfilename: string; usethread: boolean): integer;
(* Log output window to filename. Empty = close and stop.
   If logging already started, close old log file. *)
var ior: integer;
begin

if logging then begin
   (* enable posted lines to be written out, to prevent
      the last loggings from not being included if the loggings
      are sent from a thread. *)
   ioEnableAndSleep(1);
   if logusethread then
      ioftClose(ioftFile);
   logusethread:= false;
   closefile(logfile);
   end;

logging:= False;
logfilename:= '';

ior:= 0;
if pfilename='' then begin
   (* Close already done above *)
   end
else begin
   (*$I-*) (* Turn off IO error exceptions. *)
   assignfile(logfile,pfilename);
   ior:= ioresult;
   if ior=0 then begin
      rewrite(logfile);
      ior:= ioresult;
      end;
   (*$I+*)
   if ior=0 then begin
      if usethread then
         ioftOpen
           (ioftFile,
            @logfile,
            '*** Overflow in logto buffer, text missing! ***',
            100000);
      logusethread:= usethread;
      logging:= True;
      logfilename:= pfilename;
      end;
   end;

if ior<>0 then xScriptError('X (<logto ...>): Unable to open logfile "'
   +pfilename+'" (Error code '+inttostr(ior)
   +'="'+SysErrorMessage(ior)+'").');

ioflogto:= ior;

end; (*ioflogto*)


// Log string plus newline to log file if active
procedure ioflogLn(pstr: string);
var ior1,ior2: integer; errfilename: string;
begin
if logging then
   if logusethread then
      ioftWriteln(ioftFile,pstr)
   else begin
      (*$I-*) (* Turn off IO error exceptions. *)
      writeln(logfile,pstr);
      ior1:= ioresult;
      if ior1<>0 then begin
         (* Error writing to log file. Close it and print error message. *)
         errfilename:= logfilename;
         ior2:= ioflogto('',false);
         xScriptError('X(ioflogLn): Unable to write string "' + pstr + '" to file ' +
            errfilename + ' because of I/O error ' + inttostr(ior1) +
            '('+SysErrorMessage(ior1)+') - closed ' + errfilename + '.');
         end;
      (*$I+*)
      end;
if alPlayRunning then alPlayLog(pstr);
end; (*ioflogln*)


procedure iofresetlog;
begin
if logging then begin
   if logusethread then
      ioftClose(ioftFile);
   rewrite(logfile);
   if logusethread then
      ioftOpen
        (ioftFile,
         @logfile,
         '*** Overflow in logto buffer, text missing! ***',
         100000)
   end
end; (*iofresetlog*)

procedure iofWriteChToWbuf( pch: char );
(* Add a character to wbuf, if char is line separator (CR),
   then add a line to wbuf (emptying to result window first if necessary).
   Used by ioOutWrite. *)
BEGIN

if pch=char(13) then begin
  iofWritelnToWbuf('');
  wbufLineLen:= 0;
  end
else if pch=char(0) then (* - *)
else begin
  wbuf[wbufcurline]:= wbuf[wbufcurline] + pch;
  wbufLineLen:= wbufLineLen+1;
  end;
end; (*iofWriteChToWbuf*)


procedure iofWriteToWbuf( ps: string);
(* Add a string to wbuf. String may contain line separatators.
   For each new line in wbuf, first check that wbuf is not full and
   if it is, empty it by sending it to output window.*)
VAR
unconsumed1: integer; (* 1st unconsumed character in ps. *)
i: integer; len: integer;
begin
if formexists then begin

    unconsumed1:= 1;
    FOR i:= 1 TO length(ps) DO BEGIN
        len:= i-unconsumed1;
        if ps[i]=char(0) then begin
            wbufLineLen:= wbufLineLen+len;
            wbuf[wbufcurline]:= wbuf[wbufcurline] + copy(ps,unconsumed1,len);
            unconsumed1:= i+1;
            end
        else IF ps[i]=char(13) THEN BEGIN
            wbufLineLen:= wbufLineLen+len;
            (* Send a line to the memo box: *)
            wbuf[wbufcurline]:= wbuf[wbufcurline] + copy(ps,unconsumed1,len);
            iofWritelnToWbuf('');
            wbufLineLen:= 0;
            unconsumed1:= i+1;
            end;
        end;

    (* Add last unterminated line to wbuf. *)
    len:= length(ps)-unconsumed1+1;
    wbufLineLen:= wbufLineLen+len;
    wbuf[wbufcurline]:= wbuf[wbufcurline] + copy(ps,unconsumed1,len);
    end

else wbuf[wbufcurline]:= wbuf[wbufcurline] + ps;

end; (*iofWriteToWbuf*)



type functype = function: Integer; stdcall;

var
callbackfunc: functype = NIL;

raalCallCount: integer = 0;
rccMsgCnt: integer = 0;

procedure ResultAreaAddLines(pi: integer; ptext: string);
var len: integer; handle: hwnd;
begin

raalCallCount:= raalCallCount+1;
if (raalCallCount>1) and (rccMsgCnt<10) then begin
   iofWritelnToWbuf('ResultAreaAddLines: raalCallCount=1 was expected but '+
      inttostr(raalCallCount)+' was found.');
   rccMsgCnt:= rccMsgCnt+1;
   end;

handle:= xform[pi].ResultAreaHandle;
if (pi=1) and (iofentercallcnt=0) and (iofdefaultoutput<>0) then
   // Default output redirected to user defined gui
   handle:= iofdefaultoutput;

(* last error must be reset first, because it can be set to <>0 from
   a number of sources earlier, and getwindowtextlength will not reset it
   if it suceeds. *)
// setlasterror(0);
len:= xform[pi].ResAreaLength;
if len< 0 then len:= GetWindowTextLength(handle);
//errstat:= getlasterror;
(* This error status check was removed because errstat could apparently be set by
   a thread to for example 183 (Det går inte att skapa en fil som redan finns). *)
(* if errstat<>0 then
   xprogramerror('X(Resultareaaddlines): Unable to get length of text in control '+
   inttostr(handle)+'. Received error code '+alSystemErrorMessage+
   '.');*)
setlasterror(0);
(* Resultareaaddlines appears to work also without em_setsel (selection is
   probably left at end of text anyway), but em_setsel is kept anyway, since
   removing it does not appear to affect update time consumption, which
   primarily appears to be dependent of the time it takes to scroll the
   text area one step up on the screen. *)
SendMessage (handle, EM_SETSEL, len, len);
(* For some reason, em_setsel appears to set last error code to 5 (åtkomst nekad).
   allthough it apparently works.*)
(* Removed because getlasterror returned 1400 (ogiltig fönsterreferens (handle))
   although it appears to work. *)
(*if getlasterror=5 then setLastError(0);
errstat:= getlasterror;
if errstat<>0 then
   xprogramerror('X(Resultareaaddlines): Unable to send message EM_SETSEL '+
   'to handle '+inttostr(handle)+'. Received error code '+alSystemErrorMessage+
   '.');*)
ptext:= ptext+char(13)+char(10);
SendMessage (handle, EM_REPLACESEL, 0, integer(ptext));

(* Keep track of resarealength, assuming that calling GetWindowTextLength could
   possibly be more time consuming when the size of the text becomes very large
   (after a 24 hour simreccontrol test for instance). *)
len:= len+length(ptext);
xform[pi].ResAreaLength:= len;

raalCallCount:= raalCallCount-1;

end;

procedure AddLines(phandle:hwnd; ptext: string);
(* Only used for xcodearea. So it should not affect the
   validity of resarealength. *)
var length: integer;
begin
length:= GetWindowTextLength(phandle);
SendMessage (phandle, EM_SETSEL, length, length);
ptext:= ptext+char(13)+char(10);
SendMessage (phandle, EM_REPLACESEL, 0, integer(ptext));
end;

(* (new:) *)
procedure writewbuf(pKeeplastline: boolean);
(* Append output to result area. If callback is registered,
   (from AHK GUI) call the callback function to enable
   the AHK script to read and clear the result area. *)

var l: integer; lastline: integer;
keeplastline: boolean;
begin

if althreadnr=0 then begin
   // skip printing last line if it is empty, or if pKeepLastLine
   keeplastline:= (wbuf[wbufcurline]='') or pkeepLastLine;
   if keepLastLine then lastline:= wbufcurline-1 else lastline:= wbufcurline;

   if lastline>0 then begin
      for l:= 1 to lastline do begin
         ResultareaAddLines(currentform,wbuf[l]);
         ioflogLn(wbuf[l]);
         wbuf[l]:= '';
         end;
      if pKeeplastline then begin
         wbuf[1]:= wbuf[wbufcurline];
         wbuf[wbufcurline]:= '';
         end;
      wbufcurline:= 1;

      if @callbackfunc<>NIL then callbackfunc;
      end;
   end
else if pKeepLastLine then
   postmessage(xForm[currentForm].handle,IOFMESSAGE,IOFADDWBUF,1)
else postmessage(xForm[currentForm].handle,IOFMESSAGE,IOFADDWBUF,0)

end; (*writewbuf*)

(* (old:) *)
procedure writewbuf0;
(* Append output to result area. If callback is registered,
   (from AHK GUI) call the callback function to enable
   the AHK script to read and clear the result area. *)

var l: integer;
begin
if wbufcurline>1 then begin
   for l:= 1 to wbufcurline-1 do begin
      ResultareaAddLines(currentform,wbuf[l]);
      ioflogLn(wbuf[l]);
      wbuf[l]:= '';
      end;
   wbuf[1]:= wbuf[wbufcurline];
   wbuf[wbufcurline]:= '';
   wbufcurline:= 1;

   if @callbackfunc<>NIL then begin
      callbackfunc;
      end;
   end;

end; (*writewbuf0*)



procedure iofregistercallback(paddr: integer);
(* Register parameterless callback function which is called whenever
   something is written to the output window (writewbuf).
   used by xdll. *)
begin
@callbackfunc:= pointer(paddr);
end;


procedure showdebugform;

(* Program reached a break point - show the debug form and wait until the
   user continues with step, or down or run. *)

begin

setDlgItemText(xform[2].handle,xform[2].xCodeAreaId,'');

addlines(xform[2].xCodeAreaHandle,xcodestr);

cformsave:= currentform;
currentform:= 2;

EnableWindow(xform[1].handle,false);
ShowWindow(xForm[1].handle, SW_HIDE);
EnableWindow(xform[2].handle,true);
ShowWindow(xForm[2].handle, SW_SHOWNORMAL);
currentform:= 1;
iofmainloop(2);
EnableWindow(xform[2].handle,false);
ShowWindow(xForm[2].handle, SW_HIDE);
EnableWindow(xform[1].handle,true);
ShowWindow(xForm[1].handle, SW_SHOWNORMAL);
currentform:= 2;

(* signal "done" to iofreadln. *)
breakpointpassed.SetEvent;

end; (*showdebugform*)


procedure updateformcaption;
var loadname: string;
caption: string;
begin
   loadname:= altoploadtitle;
   if loadname<>'' then loadname:= 'with '+loadname;
   if iofspecialcaption<>'' then
      Caption:= xcap + iofspecialcaption
   else if althreadcount=0 then
      Caption:= xcap+loadname

   else if althreadcount=1 then
      Caption:= xcap+loadname+' (one thread running)'
   else
      Caption:= xcap+loadname+' ('+inttostr(althreadcount)+' threads running)';
   // Convert to Latin-1 (new:)
   caption:= ioUni2Iso(caption);
   SetWindowText(xform[currentform].handle,pchar(caption))
  end;

var
tmcallcount: integer = 0;

procedure ThreadMessage(phandle: hwnd; var Message: Tmessage);
(* Handle message from threads to the form. *)
var p: fsptr;
xargptr: xargblockptrtype; // used by iofshellexecute
argptr: iofargblockptr; // used by iofgeneral
arg2,arg3,arg4: string;
eofs: char;
se,i: integer;
filep,argp,dirp: PChar;
showcmd:integer;
messageDlgDataPtr: MessageDlgDataPtrType;

begin

eofs:= char(fseofs);

tmcallcount:= tmcallcount+1; // +++ Debug if x hangs in iodisablethreads.

iodisableotherthreads(22);

tmcallcount:= tmcallcount+1;

try

case Message.WParam of

   (* (new:) *)
   IOFADDWBUF: begin
      if althreadnr<>0 then xProgramError('ThreadMessage(IOFADDWBUF): ' +
      'For althreadnr 0 was expected but ' + inttostr(althreadnr) + ' was found.');
      writewbuf(message.lparam>0);
      end;
(* (old:
   IOFADDWBUF: begin
      writewbuf;
      end;
*)
   IOFREADCONS: begin
      (* Get line from user. *)
      instr:= InputBox('X','X readln:','');

      (* signal "done" to iofreadln. *)
      instrloaded.SetEvent;
      end;

   IOFTERMINATE: begin
      postMessage(xForm[1].handle,WM_CLOSE,0,0);
      end;

   IOFRESTORE: begin
      ShowWindow(xForm[1].handle,sw_restore);
      end;

   IOFMINIMIZE: begin
      ShowWindow(xForm[1].handle,sw_minimize);
      end;


   IOFSHOWMESSAGE: begin
      p:=fsptr(message.lparam);
      iofshowmess(fstostr(p));
      fsdispose(p);
      end;

   IOFUPDATEFORMCAP: updateformcaption;

   IOFSHELLEXECUTE: begin
      (* Get arguments from lparam *)
      xargptr:= xargblockptrtype(message.lparam);
      with xargptr^ do begin
         if narg>=1 then showcmd:= alshowcmd(xargptr^.arg[1],eofs)
         else showcmd:= sw_shownormal;
         if narg>=2 then begin
            arg2:= xfstostr(arg[2],eofs);
            filep:= PChar(arg2);
            end
         else filep:= nil;
         if narg>=3 then begin
            arg3:= xfstostr(arg[3],eofs);
            argp:= PChar(arg3);
            end
         else argp:= nil;
         if narg>=4 then begin
            arg4:= xfstostr(arg[4],eofs);
            dirp:= PChar(arg4);
            end
         else dirp:= nil;
         end; (*with*)

      (* Call shellexecute *)
      ioenableotherthreads(21);
      try
         se:= ShellExecute(xForm[currentForm].handle,PChar('open'),filep,
            argp,dirp,showcmd);
      finally
         iodisableotherthreads(21);
         end;

      (* Check return code *)
      if se<=32 then begin
         xScriptError('X(<win32 shellexecute,...'+arg2+'...>): Failed with code '+
            inttostr(se) + ' - "'+alseerrmess(se) + '".');
         end;

      // Dispose argblock
      with xargptr^ do
         for i:= 1 to narg do fsdispose(arg[i]);
      dispose(xargptr);
      end; (*IOFSHELLEXECUTE*)

   IOFGENERAL: begin

      // This tag can be used for general purpose

      // Get arguments from lparam
      argptr:= iofargblockptr(message.lparam);

      case argptr^.functionid of

         iofformmovefid: iofformmove(argptr^.argblockptr);
         iofinputboxfid: iofinputbox(argptr^.argblockptr,argptr^.funcret);
         end;

      (* signal "done" to iofrunthreadsafe. *)
      generalcompletion.SetEvent;

    end;

  IOFSHELLEXECUTEEX: iofshowmess(
    'threadmessage: shellexecuteex yet to be implemented for threads.');

  IOFCLEARFORM: begin
      SetWindowTextA(xForm[currentForm].ResultAreaHandle,'');
      xform[currentForm].ResAreaLength:= 0;
      iofresetlog;
      end;

  IOFUPDATEFORM: UpdateWindow(xForm[currentForm].handle);

  IOFSHOWDEBUGFORM: showdebugform;

  IOFDIALOGBOX: begin

      (* Get address to data record. *)

      messagedlgDataPtr:= messagedlgDataPtrType(message.lparam);
      with messagedlgdataptr^ do

         (* Get parameters from data record, and put result there too. *)
         Answer:= messageDlg(messagestr,mtcustom,answers,0);

      (* signal "done" to iofreadln. *)
      instrloaded.SetEvent;
      end;

  else ;
  end; (*case*)

finally
   tmcallcount:= tmcallcount-1;
   ioenableotherthreads(22);
   tmcallcount:= tmcallcount-1;
end;

end; (*threadmessage*)


procedure iofrestorecaption;
(* Clear iofspecialcaption (restore standard form caption) and
   update caption. *)
begin
iofspecialcaption:= '';
iofupdateformcaption;

end; (*iofrestorecaption*)

procedure iofWritelnToWbuf(ps: string);
(* Add a string to current line in wbuf and start on a new line. The string is
   allowed to contain line separators too.
   If wbuf is full, then empty it first by sending it to output window. *)
begin
 iofWriteToWbuf(ps);
 // If buffer is full, send to result area until it is not
 while wbufcurline>=IOFWBUFARRAYSIZE do begin
    writeWbuf(true);
    ioEnableAndSleep(50);
    end;
 wbufcurline:= wbufcurline+1;
 wbufLineLen:= 0;
end; (*iofWritelnToWbuf*)

var
writeWbufCallCnt: integer;
recursiveWriteWbufLost: integer;

procedure iofWriteWbufToResarea(pKeepcurrentline: boolean);
(* Empty wbuf by sending all completed lines to resultarea.
   If pcurrentline=true then also write the current, possibly not yet completed,
   line (wbufcurline). *)
var l: integer;
begin
writeWbufCallCnt:= writeWbufCallCnt+1;
// Do not call recursively (possible during <play ...>, through
// showcompareMessage).
if writeWbufCallCnt=1 then writewbuf(pKeepCurrentLine)
else recursiveWriteWbufLost:= recursiveWriteWbufLost+1;

writeWbufCallCnt:= writeWbufCallCnt-1;

end; (*iofWriteWbufToResarea*)


function iofwbufempty: boolean;
(* Tell if write buffer is empty or not. *)
begin
iofwbufempty:= (wbufcurline=1) and (wbuf[1]='');
end;

procedure iofclear;
(* Clear result area. *)
begin
(* Make sure write buffer is cleared. *)
iofWriteWbufToResarea(false);
if althreadnr=0 then begin
   SetWindowTextA(xForm[currentForm].ResultAreaHandle,'');
   xForm[currentForm].ResAreaLength:= 0;
   iofresetlog;
   end
else postmessage(xForm[currentForm].handle,IOFMESSAGE,IOFCLEARFORM,0);
end;

procedure iofupdateFormCaption;
(* Update form caption with active number of threads. *)
begin
if althreadnr=0 then updateformcaption
else postmessage(xForm[currentForm].handle,IOFMESSAGE,IOFUPDATEFORMCAP,0);
end;


procedure iofWcons(pStr: string);
(* Like alWcons, but from the Pascal program. *)
begin
iofWriteToWbuf(pStr);
iofWriteWbufToResarea(true);
end;



{$R *.lfm}


procedure iofenterString(var pstateenv: xstateenv; var ptext: string; pLock: boolean);
(* Used by alcleanup and by xdll to call X. pLock is false when calling from
   alcleanup, because ioxlock is then already acquired and need not to be
   acquired again. *)
var rets: string;
posdelim,posdelimgt,namelen: integer;
funcname: string;
pos1: integer;
loadEnteredSave: boolean;

begin

iofentercallcnt:= iofentercallcnt+1;

// User may have typed something - set length to unknown.
xform[1].ResAreaLength:= -1;

ResultAreaAddLines(1,ptext);

(* Reset count of empty lines from console. *)
ioemptylines:= 0;

(* Lock x if not already locked. *)
if plock then
   iodisableotherthreads(23);

try
   (* Reset faults. *)
   if xfault then begin
      xfault:= false;
      xProgramFault:= false;
      xinputcompileerror:= false;
      end;

   // (modelled from enterString:)
   loadEnteredSave:= iofLoadEntered;
   iofLoadEntered:= false;
   pos1:= ansipos('<',ptext);
   if pos1>0 then if ansilowercase(ansimidstr(ptext,pos1,5))='<load' then iofLoadEntered:= true;

   if xScriptInUndefinedState then begin

      if ptext[1]='<' then begin
         posdelim:= pos(' ',ptext);
         posdelimgt:= pos('>',ptext);
         if (posdelim=0) or (posdelim>posdelimgt) then posdelim:= posdelimgt;
         namelen:= posdelim-2;

         if namelen>0 then begin

            funcname:=ansimidstr(ptext,2,namelen);
            if xuserdefined(funcname) then
               (* Print warning *)
               ioMessage('Warning','The script may be in an undefined state after '+
               'earlier fault, until <load ...> or <cleanup> is done.');
            end;
         end;

      xScriptInUndefinedState:= false;
      end;

   xsendto(ptext,pstateenv,rets);

   // (No enterstring History when called from dll or alcleanup)

   ptext:= rets;
finally
   if plock then
      ioenableotherthreads(23);
   iofLoadEntered:= loadEnteredSave;
   end;

iofentercallcnt:= iofentercallcnt-1;

end; (*iofenterString*)

(* (new:) *)
procedure iofgetoutput1(pbufsize: integer; pbuf: pchar);
(* Remove the first pbufsize-1 chars from result window and
   put it in pbuf. Terminate with char(0).
   Used by xdll. *)
var rets: string;
len: integer;
controlhandle: hwnd;

begin

controlhandle:= xform[1].ResultAreaHandle;
if (iofentercallcnt=0) and (iofdefaultoutput<>0) then begin
   // Default output redirected to user defined gui
   iofshowmess('iofgetoutput: Script error - Output was redirected to a user '+
      'defined Edit, and retrieving this through xdll is yet to be implemented.');
   (* (No use changing the handle because GetDlgItemTextA will need window handle
      and the edit nr.) *)
   //controlhandle:= iofdefaultoutput;
   end;

// Get text from edit
len:= GetDlgItemTextA(xForm[1].handle,xForm[1].resultAreaId,pbuf,pbufsize);
// Delete text in edit
SendMessage (controlhandle, EM_SETSEL, 0, len);
SendMessage (controlhandle, EM_REPLACESEL, 0, (*0 *)integer(pchar('')));

end; (*iofgetoutput1*)


// (old:)
procedure iofgetoutput(var ptext: string);
(* Return contents of the output window, then clear the output window.
   Used by xdll. *)
var rets: string;
buf: array[1..1000] of char;
buflen: integer;

begin

buflen:= 1000;
GetDlgItemTextA(xForm[1].handle,xForm[1].resultAreaId,@buf,buflen);
ptext:= string(buf);

end; (*iofgetoutput*)

const dlgbuffersize=2001;

var dlgbuffer:  array[0..dlgbuffersize-1] of char;

function gettext(phandle: hwnd; pid: integer): string;
var
res: integer;
errcode: integer;

begin

res:= GetDlgItemText(pHandle, pid, @dlgBuffer[0], dlgbuffersize);
if res=dlgbuffersize-1 then xScriptError(
   'X Expected longest possible edit control text to be less than '+
   inttostr(dlgbuffersize-1)+ ' but this script appears to '+
   'require an even longer text value for an edit control.')

else if res=0 then begin
   errcode:= getlasterror();
   if errcode<>0 then
      xProgramError('user32.GetDlgItemText('+inttostr(phandle) + ','+inttostr(pid)+'...): Unable to get dialog text - ' +
         alErrCode2Message(errcode) + '.');
   end;

gettext:= pchar(@dlgbuffer[0]);
end;


procedure CommandLineclear;
begin
end;


procedure xiofAddLineToHistory(
   pi: integer; (* Form number. *)
   ptext: string (* Line. *)
   );
(* Add command (ptext) to the command history of form pi. *)

var tostart,lnr: integer;

begin

with xForm[pi] do begin
   (* Look for duplicate: If duplicate is found then copy all
      lines below it one step up. Else copy all lines one step
      up, limited of course to the size of the table. *)
   toStart:= 0;
   for lnr:= oldestLineNr downto 1 do begin
      // (only one copy shall be possible here)
      if lineTab[lnr]=ptext then toStart:= lnr;
      end;
   if tostart>0 then
      // Duplicate was found - active table size remains unchanged.
   else begin
      (* Duplicate was not found - increment oldestLineNr by one.
         Limit to size of table. Start copying to oldestLineNr. *)
      oldestLineNr:= oldestLineNr+1;
      if oldestLineNr>LineTabSize then oldestLineNr:= LineTabSize;
      toStart:= oldestLineNr;
      end;

   for lnr:= toStart downto 2 do lineTab[lnr]:= lineTab[lnr-1];
   LineTab[1]:= ptext;
   end;

end; (* xiofAddLineToHistory *)


procedure xiofAddLineToBeginningOfHistory(
   pi: integer; (* Form number. *)
   ptext: string (* Line. *)
   );
(* Add command (ptext) to beginning of the command history of form pi.
   Used by alUsage to insert commands marked with "*". *)

var
lnr: integer;
duplicateFound: boolean;

begin

with xForm[pi] do begin
   (* Look for duplicate: If duplicate is found then do nothing. *)
   duplicateFound:= false;
   for lnr:= oldestLineNr downto 1 do begin
      if lineTab[lnr]=ptext then duplicateFound:= true;
      end;

   if not duplicateFound then begin
      (* Enter the line as the oldest line, if there is still space in the table. *)
      if oldestLineNr<LineTabSize then begin
         oldestLineNr:= oldestLineNr+1;
         LineTab[oldestLineNr]:= ptext;
         end;
      end;

   end; // (with)

end; (* xiofAddLineToBeginningOfHistory *)


procedure enterString(
   pi: integer; // form number (1 for main form, 2 for debug form)
   ptext: string; // Command string.
   pAcquireLock: boolean;
   pSaveInCommandHistory: boolean (* Used to prevent command line parameters to
      be saved in commandHistory. *)
   );
var
entertext: string;
rets: string; quote: boolean; ch: char; i: integer;
xbufcopy: string;
savegroup: integer;
invariable: integer;
filename: fsptr;
inp: ioinptr; (* temporary input pointer. *)
lnr,toStart: integer;
posdelim, posdelimgt, pos1: integer;
namelen: integer;
funcname: string;
loadEnteredSave: boolean;
lengthPtext: integer;
incomment: boolean;

begin
iofentercallcnt:= iofentercallcnt+1;

// User may have typed something - set length to unknown.
xform[pi].ResAreaLength:= -1;

// Put "enter:" before <...> commands.
if level=0 then entertext:= 'enter:'+ptext
else entertext:= ptext;

ResultAreaAddLines(pi,entertext);
// Log if logging but not the log ending command
if AnsiCompareText(ptext,'<logto >')<>0 then begin
   iofEnterTextLogged:= true;
   ioflogLn(entertext);
   iofEnterTextLogged:= false;
   end;

(* Allow for multi-line <...>-calls (stall sending
   until the <>-level is back to zero). *)
CommandLineClear;
quote:= false;
invariable:= 0;
inComment:= false;

i:= 1; ch:= ' '; // (to please compiler)

lengthPtext:= length(ptext); // (new)

while (i<=lengthptext) and ((level>=0) or (invariable>0)) do begin
   ch:= ptext[i];

   // (new:)
   // Read away comments.
   if not quote then
      if i+1<=lengthptext then
         if (ptext[i]='(') and (ptext[i+1]='*') then begin
            i:= i+1;
            inComment:= true;
            end;
   if inComment then begin
      if i+1<=lengthptext then begin
         if (ptext[i]='*') and (ptext[i+1]=')') then begin
            i:= i+1;
            incomment:= false;
            end
         else if (ptext[i]='(') and (ptext[i+1]='*') then
            xScriptError('enterString(inComment): ('+
            '* was found when looking for *'+').');
         end;
      end
   else begin
      // (end of new)

      if not quote then begin
         if ch='<' then begin
            level:= level+1;
            xBufContainsACall:= true;
            end
         else if ch='>' then level:= level-1
         else if ch='''' then quote:= true;

         // (new:)
         if level=0 then begin
            if invariable=1 then begin
               if i=lengthptext then invariable:= 0
               else if quote then invariable:= 0
               else if ptext[i+1]='[' then invariable:=2
               else if not (ptext[i+1] in xidcharrange) and (ptext[i+1]<>'.') then
                  invariable:= 0;
               end
            else if invariable=2 then begin
               if i=lengthptext then invariable:= 0
               else if (ptext[i+1]='[') and not quote then invariable:=0
               end
            else begin
               if (level=0) and (ch='$') and (ptext[i+1] in xidcharrange) then begin
                  invariable:= 1;
                  xBufContainsACall:= true;
                  end;
               end;
            end;

         end
      else quote:= false;

      if level>=0 then xbuf:= xbuf+ch;

      // To process plain text in correct order
      if (level=0) and
         ((xBufContainsACall and (invariable=0)) or (i=lengthptext)) then begin

         (* Clear console input (is this good?). - It removes old input from
            console and creates a clear start, but it becomes confusing when
            you test low level functions such as <unread abc>
            <read 3>, because the <read 3> will not come from the unread buffer. *)
         (* ioinclearcons(inp); *)

         (* Reset count of empty lines from console. *)
         ioemptylines:= 0;

         (* Lock x. *)
         if pAcquireLock then iodisableotherthreads(24);

         try

         (* Reset faults (fault can have been activated after last enterstring,
            if a guiform was used). *)
         if xfault then begin
            xfault:= false;
            xProgramFault:= false;
            xinputcompileerror:= false;
            end;

         (* To enable use of xbuf in <debug>: *)
         xbufcopy:= xbuf;
         xbuf:= '';

         loadEnteredSave:= iofLoadEntered;
         iofLoadEntered:= false;
         pos1:= ansipos('<',xbufcopy);
         if pos1>0 then if ansilowercase(ansimidstr(xbufcopy,pos1,5))='<load' then iofLoadEntered:= true;

         if xScriptInUndefinedState then begin

            if pos1>0 then begin
               funcname:= AnsiRightStr(xbufcopy,length(xbufcopy)-pos1);
               posdelim:= pos(' ',funcname);
               posdelimgt:= pos('>',funcname);
               if (posdelim=0) or (posdelim>posdelimgt) then posdelim:= posdelimgt;
               namelen:= posdelim-1;

               if namelen>0 then begin

                  funcname:=ansiLeftStr(funcname,namelen);

                  if xuserdefined(funcname) then
                  (* Print warning *)
                  ioMessage('Warning','The script may be in an undefined state after '+
                     'earlier fault, until <load ...> or <cleanup> is done.');
                  end;
               end;

            xScriptInUndefinedState:= false;
            end;

         if pi=1 then begin
            (* Old style. *)

            (* (Do not reset local variable parameters if there is a thread running
               because they would then be destroyed) *)
            if althreadcount=0 then
               (* Reset local variable paremeters in case there was
                  an exception. *)
               alInitLocVarParameters;

            xsendto(xbufcopy,iofdefaultstateenv,rets);
            end

         else if pi=2 then begin
            (* Debug form *)

            (* Simulate compilation environment for current state. *)
            savegroup:= xcurrentgroupnr;
            xcurrentgroupnr:= debugstateenvptr^.statenr;

            (* New style for debug form. <p n> is allowed *)
            xsendto_debug(debugstateenvptr,xbufcopy,true,rets);
            (* Restore compilation environment. *)
            xcurrentgroupnr:= savegroup;
            end
         else xProgramError('enterstring: unexpected pi.');

         // Support enter string history
         if pSaveInCommandHistory then xiofAddLineToHistory(pi,ptext);

         xform[pi].lineNr:= 0;

         (* Terminate debugging when returning to main form. *)
         if pi=1 then iofdebug:= False;

         (* Reset faults. *)
         if xfault then begin
            ioErrmessWithDebugInfo('Terminating evaluation');
            xfault:= false;
            xProgramFault:= false;
            xinputcompileerror:= false;

            // Reset input or output file to none if input or output was deleted or closed
            if iogetinfilenr=0 then ioInNull(iofdefaultstateenv.cinp);
            if iogetoutfilenr=0 then ioOutNull;

            (* Read away any remaining console input so that a new call to x will
               read new input from console and not reuse the old that might have
               created the fault. *)
            fsnew(filename);
            ioinfilename(filename);
            if fstostr(filename)='cons' then begin
               inp:= iofdefaultstateenv.cinp;
               while (inp^<char(ioeofr)) do ioinforward(inp);
               ioinadvancereadpos(inp);
               iofdefaultstateenv.cinp:= inp;
               end;
            fsdispose(filename);
            end;

         // If eof in console (created by 4 empty lines) - remove it.
         ioResetConsEof(iofDefaultStateEnv);

         xbuf:= '';
         xBufContainsACall:= false;

         if length(rets)>0 then iofWriteToWbuf(rets);
         iofWriteWbufToResarea(false);

         finally
         if pAcquireLock then ioenableotherthreads(24);
         iofLoadEntered:= loadEnteredSave;
         end;(* try*)

         end;

      end; // (not comment)

   i:= i+1;
   end; (*while*)

if level<0 then begin
    ioErrmessWithDebugInfo('Too many ''>'' in command line.');
    level:= 0;
    end
else if level=0 then (* - *)
else if level>0 then begin (* not last line. Add CR unless "-" *)
    if (ch='-') and not quote then (* Remove "-" *)
        delete(xbuf,length(xbuf),1)
    else xbuf:= xbuf + char(13);
    end;

iofentercallcnt:= iofentercallcnt-1;


end; (*enterString*)

(* iofEnterLine
   ------------
   Used by the function <enterfromfile ...>
*)
procedure iofEnterLine(Pline: string);
begin
enterstring(1,pline,false,false);
end; // (iofEnterLine)

procedure EnterButtonClick(pi: integer);
var debugsave: boolean;
begin
(* We do not want breaks when evaluating from the debug form. *)
debugsave:= iofdebug;
iofdebug:= false;

if (pi=1) then
   // Reset alLoadLevel in case it has come in disorder after an exception or so.
   alLoadLevel:= 0;

enterString(pi,gettext(xform[pi].handle,xform[pi].cmdlineid),true,true);
setDlgItemText(xform[pi].handle,xform[pi].cmdLineId,'');
iofdebug:= debugsave;
end; (*EnterButtonclick*)

procedure stepbuttonClick;
begin
postmessage(xform[2].handle,wm_quit,0,0)
end;

procedure DownButtonClick;
begin
iofstepdown:= True;
postmessage(xform[2].handle,wm_quit,0,0)
end;

procedure RunbuttonClick;
begin
iofdebug:= False;
postmessage(xform[2].handle,wm_quit,0,0)
end;

var
dumcount: integer = 0;
procedure dumproc;
begin
dumcount:=dumcount+1;
if dumcount=100000000 then ioErrmessWithDebugInfo('dumproc');
end;


function xFormMessageProc(winhandle: HWND; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
var
i: integer;
tmess: Tmessage;
res: integer;
ks: smallint;
ret: integer;
focus: hwnd;

begin
{This is the "Window Proc" used to communicate with the OS,
  these messages are how the OS tells this program what has
  happened, look up the 5 WM_ messages in the Win32 API Help.
  This function must send a Result back to Windows for its
  "message" back to the OS, which may change what the OS does
  for that Msg. Each of these messages will produce a MessageBox
  so you can see when the message gets to this function}

Res := 0;

if (msg=$6)(* WM_ACTIVATE *) then begin
   for i:= 1 to 2 do if winhandle=xform[i].handle then begin
      if wparam>0 then begin
         // Activate
         if xform[i].focus=0 then
            setFocus(xform[i].cmdLineHandle)
         else
            setFocus(xform[i].focus);
         end
      else begin
         // Deactivate - save focus
         focus:= GetFocus;
         if focus<>xform[i].handle then
            xform[i].focus:= focus;
         end;
      end;
   end

else if msg=wm_exitsizemove then begin
   // After resize
   resize;
   iofManuallyResized:= true;
   end


else if msg=wm_close then begin
   (* /Replaces Tform1.formclose) *)
   if currentform=1 then begin
      // close log file.
      (* ioflogto calls ioEnableAndSleep, which expects x to be locked.
         (If we dont disable other threads here, we will get an error
         message from ioenableotherthreads (called by ioEnableAndSleep) saying that
         ioxlock has not been acquired.) *)
      iodisableotherthreads(29);
      try
         ioflogto('',false);
      finally
         ioenableotherthreads(29);
         end;
      ioclosing:= True;
      if not iofailureexit then enterstring(1,'<cleanup>',true,false);
      end
   else if currentform=2 then
      currentform:= cformsave;
   end

else if (msg=$7) then begin
   // (wm_setfocus)
   (* windows appears to want to set the focus to the parent window,
      but this code detects this (winhandle=xform[i].handle), and sets it
      back again to where it should be. *)
   if winhandle=xform[1].handle then
      setfocus(xform[1].focus)
   else if winhandle=xform[2].handle then
      setfocus(xform[2].focus)
   else
      xform[1].focus:= winhandle;

   (*
   if formexists then begin
         iofWritelnToWbuf('Setfocus: winhandle='+inttostr(winhandle)+'wparam='+inttostr(wparam)+'lparam='+inttostr(lparam)+'.');
      iofWriteWbufToResarea(true);
      end;*)
   end
else if (msg=$112) and (wparam and $fff0 = $f010) then
   dumproc
else if true(*(msg=$7)*)(* WM_SETFOCUS *) then begin
   if winhandle=xform[1].ResultAreaHandle then
      xProgramError('Message to result area: '+inttostr(msg)+'.');
   end

else if not (
      (msg=$1)(* WM_CREATE *)
   or (msg=$2)(* WM_DESTROY *)
   or (msg=$3)(* WM_MOVE *)
   or (msg=$5)(* WM_SIZE *)
   or (msg=$6)(* WM_ACTIVATE *)
   or (msg=$7)(* WM_SETFOCUS *)
   or (msg=$8)(* WM_KILLFOCUS *)
   or (msg=$f)(* WM_PAINT *)
   or (msg=$14)(* WM_ERASEBKGND *)
   or (msg=$16)(* WM_ENDSESSION *)
   or (msg=$18)(* WM_SHOWWINDOW *)
   or (msg=$1C)(* WM_ACTIVATEAPP *)
   or (msg=$20)(* WM_SETCURSOR *)
   or (msg=$21)(* WM_MOUSEACTIVATE *)
   or (msg=$24)(* WM_GETMINMAXINFO *)
   or (msg=$25)(* ? *)
   or (msg=$46)(* WM_WINDOWPOSCHANGING *)
   or (msg=$47)(* WM_WINDOWPOSCHANGED *)
   or (msg=$7F)(* WM_GETICON *)
   or (msg=$81)(* WM_NCCREATE *)
   or (msg=$83)(* WM_NCCALCSIZE *)
   or (msg=$84)(* WM_NCHITTEST *)
   or (msg=$85)(* WM_NCPAINT *)
   or (msg=$87)(* WM_GETDLGCODE *)
   or (msg=$88)(* WM_SYNCPAINT *)
   or (msg=$A0)(* WM_NCMOUSEMOVE *)
   or (msg=$111)(* WM_COMMAND *)
   or (msg=$133)(* WM_CTLCOLOREDIT *)
   or (msg=$135)(* WM_CTLCOLORBTN *)
   or (msg=$200)(* WM_MOUSEFIRST *)
   or (msg=$201)(* WM_LBUTTONDOWN *)
   or (msg=$202)(* WM_LBUTTONUP *)
   or (msg=$210)(* WM_PARENTNOTIFY *)
   or (msg=$281)(* WM_IME_SETCONTEXT *)
   or (msg=$282)(* WM_IME_NOTIFY *)
   or (msg=$400)(* DM_GETDEFID *)
   ) then begin
   dumproc;
   end;

try

case Msg of

   iofmessage: begin
      tmess.Msg:= msg;
      tmess.WParam:= wparam;
      tmess.LParam:= lparam;
      threadmessage(winhandle,tmess);
      res:= tmess.Result;
      end;

   WM_DESTROY: begin
      {WM_DESTROY is sent After the window is hidden but
         before the window is destroyed}
      (* MessageBox(0,'A Message for WM_DESTROY'#10'the Window has not been Destroyed yet',
         'Window is Hidden', MB_OK or MB_ICONQUESTION);*)
      PostQuitMessage(0);
      {IMPORTANT: to end this Program you need to end your
         GetMessage Loop. To do this you will have to send the
         WM_QUIT message with PostQuitMessage(0)}
      end;

   WM_COMMAND: begin
      if lparam=xform[1].resultAreaHandle then begin
         if (wparam and $FFFF0000)=$02000000 then begin
            (* en_killfocus - result area lost focus: Save caret position. *)
            SendMessage(xform[1].ResultAreaHandle, EM_GETSEL,
               integer(@xform[1].resareaselstart), integer(@xform[1].resareaselend));
            end

         else if (wparam and $FFFF0000)=$01000000 then begin
            (* en_setfocus - Result area got focus: Restore position and selection
               because windows automatically selects the entire field. *)
            // If first time, go to last position = last position of selection
            if xform[1].resareaselstart<0 then begin
               SendMessage(xform[1].ResultAreaHandle, EM_GETSEL,
                  integer(@xform[1].resareaselstart), integer(@xform[1].resareaselend));
               xform[1].resareaselstart:= xform[1].resareaselend;
               end;
            // Restore selection and position
            SendMessage(xform[1].ResultAreaHandle, EM_SETSEL,
               integer(xform[1].resareaselstart), integer(xform[1].resareaselend));
            end;
         end
      else if (lparam=xform[1].cmdLineHandle) then begin
         if      (wparam and $FFFF0000)=$01000000 then
            (* en_setfocus *)
            dumproc
         else if (wparam and $FFFF0000)=$02000000 then
            dumproc
         else if (wparam and $FFFF0000)=$03000000 then
            dumproc
         else if (wparam and $FFFF0000)=$04000000 then
            dumproc
         else
            dumproc;
         end

      else if lparam=0 then
         dumproc;

      for i:= 1 to 2 do begin
         if lParam=integer(xForm[i].enterButtonHandle) then enterButtonClick(i)
         else if i=2 then begin
            if lParam=integer(xform[i].stepButtonHandle) then stepButtonClick
            else if lParam=integer(xform[i].downButtonHandle) then downButtonClick
            else if lParam=integer(xform[i].runButtonHandle) then runButtonClick;
            end;
         end;
      end;

   dm_getdefid: begin
      if lParam=9999 then enterButtonClick(i);
      ks:= getkeystate(vk_return);
      if ks<0 then begin
         // High order bit is set
         enterbuttonclick(1);
         if ret=9999 then ioErrmessWithDebugInfo('xformmessageproc:9999');
         end;
      end;

   end; // (case)

except
   on e: exception do
      iofshowmess('X(xFormMessageProc): Exception occured (message=' +
      e.message + ', context=' + inttostr(e.helpcontext) + ').');

end;

Res := DefWindowProc(winhandle,Msg,wParam,lParam);

xFormMessageProc:= res;

{VERY VERY IMPORTANT - to get normal windows default behavior
   you must call DefWindowProc for that message, if you DO NOT want
   normal windows behavior then DO NOT let DefWindowProc be called.
   I have put it at the end of this function, so if you don't want
   DefWindowProc then you just add and "Exit;" in that message
   response above}

end; // (xFormMessageProc)


(* LONG WINAPI NewEditWndProc( HWND hWnd, UINT uMsg, WPARAM wParam,
   LPARAM lParam ) {
	// catch the messages here..
	// else:
	return CallWindowProc( oldEditWndProc, hWnd, uMsg, wParam, lParam );
} *)
function newMLEditMessageProc(hWnd: HWND; Msg: UINT; WParam: WPARAM; LParam:
   LPARAM): UINT; stdcall;
var
res: integer;
begin

(* if msg=wm_keydown then *)

if msg=$7 then
   dumproc
else if msg=$8 then
   dumproc
else if msg=$e then
   dumproc
else if msg=$f then
   dumproc
else if msg=$14 then
   dumproc
else if msg=$17 then
   dumproc
else if msg=$20 then
   dumproc
else if msg=$21 then
   dumproc
else if msg=$84 then
   dumproc
else if msg=$85 then
   dumproc
else if msg=$87 then
   dumproc
else if msg=$B1 then
   dumproc
else if msg=$C2 then
   dumproc
else if msg=$101 then
   dumproc
else if msg=$200 then
   dumproc
else if msg=$201 then
   dumproc
else if msg=$202 then
   dumproc
else if msg=$215 then
   dumproc
else if msg=$281 then
   dumproc
else if msg=$282 then
   dumproc
else
   dumproc;

res:= CallWindowProc( oldEditWndProc, hWnd, Msg, wParam, lParam );

if (msg=$87) and (wparam=$9) then
   // Remove want all keys
   res:= res and $FFFFFFFB

else if (msg=$b0) then
   (* em_getsel - through away res because full res is in wparam and lparam
      and res<0 will cause range error in converting it to longint below. *)
   res:= 0;


newMLEditMessageProc:= res;

end; (*newMLEditMessageProc*)

procedure iofSetInitString(pstr: string);
(* Used to execute command line parameters when X is started. *)
begin
initString:= pstr;
// Enter as command, but do not save in command history.
enterstring(1,initstring,true,false);
end;


procedure iofinit;
var l: integer;
begin
formExists:= false;
xbuf:= ''; (* (needed?) *)
level:= 0;
xBufContainsACall:= false;
for l:= 1 to IOFWBUFARRAYSIZE do
  wbuf[l]:= ''; (* (Needed?) *)
wbufcurline:= 1;
writeWbufCallCnt:=0;
recursiveWriteWbufLost:= 0;
wbufLineLen:= 0;
instrwritelock:= syncobjs.Tcriticalsection.create;
instrLoaded:= tsimpleevent.create;
breakpointpassed:= tsimpleevent.create;
eoa:= char(xeoa);

Generalwritelock:= syncobjs.Tcriticalsection.create;
GeneralCompletion:= tsimpleevent.create;
(* instrwritelock.Release;*)

tmcallcount:= 0; // (Test if x hangs in threadmessage)

end;

procedure iofthreadinit;
(* Initialize thread local variables of xioform. *)
begin
fsnew(win32args);
fsnew(win32retstr);
end;


procedure iofthreadrelease;
(* Release thread-local buffers when leaving a thread. *)
begin
fsdispose(win32args);
fsdispose(win32retstr);
end;

function iofCurrentFormHandle: hwnd;
(* Return handle to xForm[currentform].
   Used, for example, by <win32 visible,...>. *)
begin
iofCurrentFormHandle:= xForm[currentform].handle;
end;


function iofResultAreaHandle: hwnd;
(* Return handle to xForm[currentform].resultArea.
   Used by <win32 hresultarea> for debugging of xwgui. *)
begin
iofResultAreaHandle:= xForm[currentform].ResultAreaHandle;
end;


procedure iofstartdebug;
(* Run a debug window. *)

begin

iofdebug:= True;

end; (*iofstartdebug*)

procedure iofbreak(pstateenvptr: xstateenvptr; pxpos: fsptr);
(* Show the debug window and wait for user to step or run.
   mrCancel is returned if user decided to run. *)

var
inmacnr: integer;
xpos0, xcod, xcod0, inaltptr: fsptr;
str: string;
foundalt: boolean;
found: (no,inastate,inmac);
funcname: string;
prefix: string;

begin

(* Skip if already in a breakpoint. *)
if currentform=2 then
  (* - *)
else with pstateenvptr^ do begin
   (* 1. Find where we are. *)
   xpos0:= pxpos;
   fsbackend(xpos0);
   found:= no;
   if statenr>0 then begin
      xinalt(statenr,altnr,altstate,xpos0,foundalt,inaltptr);
      if foundalt then found:= inastate
      else begin
         inmacnr:= alinmac(xpos0);
         if inmacnr>0 then found:= inmac
         else ioErrmessWithDebugInfo('X(iofbreak): In a state, but string not found.');
         end;
      end
   else begin
      inmacnr:= alinmac(xpos0);
      if inmacnr>0 then found:= inmac;
      end;

   (* Create string. *)
   fsnew(xcod);
   xcod0:= xcod;

   case altstate of
   grandmother: prefix:= 'grandmother ';
   mother: prefix:= 'mother ';
   current: prefix:= '';
   end;

   case found of
   no: debugdecompile(pxpos,true,true,xcod);
   inastate: begin
      if altnr=0 then begin
         alstrtofs('In ' + prefix + 'preaction of state '+statename+':',xcod);
         fspshend(xcod,char(13));
         end
      else if altnr=999 then begin
         alstrtofs('In ' + prefix + 'postaction of state '+statename+':',xcod);
         fspshend(xcod,char(13));
         end
      else begin
         alstrtofs('In ' + prefix + 'alt '+inttostr(altnr)+ ' of state '+statename+':',xcod);
         fspshend(xcod,char(13));
         alstrtofs('?"',xcod);
         debugdecompile(inaltptr,false,false,xcod);
         alstrtofs('"?',xcod);
         fspshend(xcod,char(13));
         end;
      alstrtofs('!"',xcod);
      debugdecompile(pxpos,true,true,xcod);
      alstrtofs('"!',xcod);
      end;
   inmac: begin
      alstrtofs('<def '+xname(inmacnr)+' ',xcod);
      debugdecompile(pxpos,true,true,xcod);
      alstrtofs('>',xcod);
      end;
   end; (*case*)

   xcodestr:= fstostr(xcod0);
   fsdispose(xcod0);

   debugstateenvptr:= pstateenvptr;

   if althreadnr=0 then

     (* Show directly if in main thread. *)
     showdebugform

   else begin
      (* Else used thread event message. *)
      (* Use breakpointpassed to wait for user to continue. *)
      breakpointpassed.ResetEvent;

      (* Send message to iofthreadmessage. *)
      // (to update:) postmessage(form1.handle,IOFMESSAGE,IOFSHOWDEBUGFORM,0);

      (* Wait until user continues. Enable main thread to take care of the message. *)
      ioenableotherthreads(25);
      try
         breakpointpassed.WaitFor(infinite);
      finally
         iodisableotherthreads(25);
         end;
      end;
   end; (* not debug already *)

end; (*iofbreak*)

procedure resizewindow(phandle: hwnd; px,py: integer);
begin

// +++
// x: <getclientrect 788130>

// x: <getwindowrect 788130>

// x: <movewindow 788130,10,10,120,139,1>

end;

var
helpstr: string;

(* (New:) Reading help from resource HELPFUNC. *)
procedure gethelp;
(* <help>
   Creates a help window with short functions examples.
   The text is taken from the resource HELPFUNC,
   originally from the file helpfunctions.txt in the x-Fpc folder.
*)


begin (*getHelp*)

helpStr:= alHelpFunctionsStr;

end; (*gethelp*)


(* (old:) Reading help from the file helpFunctions.txt. *)
procedure gethelp0;
(* <help>
   Creates a help window with short functions examples.
   The text is taken from the file helpfunctions.txt

*)

var
xexedir,filename,funcname: string;
last,ior1: integer;
exampleFile: File;
readBufPtr,readBufPtr0,dashcopyPtr: fsptr;
readState: (s0,s1,s2,s3);
found: boolean;

begin (*getHelp*)

fsnew(readBufPtr);
readBufPtr0:= readBufPtr;
helpstr:= '';

// Get directory of x.exe
xexedir:=paramstr(0);

// Remove "x.exe"
last:= length(xexedir);
while (last>1) and (xexedir[last]<>'\') do last:= last-1;
if xexedir[last]='\' then last:= last-1;
xexedir:= LeftStr(xexedir,last);
filename:= xexedir + '\helpfunctions.txt';
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
         helpstr:= helpstr + fstostr(readbufptr0) + char(13) + char(10);
         end;// (while not eof...)

      // Close file
      close(exampleFile);

      end;// (ior 1 = 0)

   end
else xscripterror('<help>: This function works only if the file '+
   '"helpfunctions.txt" exists in the same directory as x.exe.');

fsdispose(readBufPtr);

end; (*gethelp0*)

procedure iofhelp;
(* Show the help window. *)
var
xhandle: hwnd;
handle, edithandle: hwnd;
boolres: longbool;
intres: longint;
xWinRect: trect;
helpxpos, helpypos: longint;
style: longint;

begin

   // Save currentwindow
   // x: <getactivewindow>=> "395188"
   xHandle:= xform[1].handle;

   // Help window shall be at located at the upper right corner of the x window.
   boolres:= getWindowRect(xHandle,xwinrect);
   helpxpos:= xwinrect.Right;
   helpypos:= xwinrect.Left;

   // x: <createwindowexa 0,xwindowclass,,80543744,10,10,50,70,0,0,4194304,0>=> "788130"
   // $04CD0000 = clipsiblings (04) + border (008) + dlgframe (004) + sysmenu (0008) +
   // sizebox (0004) + tabstop (0001)
   style:= $4CD0000;
   handle:= createwindowexa(0,'xwindowclass','Help',style,helpxpos,helpypos,500,500,0,0,$400000,0);

   // x: <setwindowtext 788130,Help>
   boolres:= setwindowtext(handle,'Help');

   // Mute rewrite during window creation.
   // x: <wm_setredraw 788130,0>
   intres:= sendmessage(handle,11,0,0);

   // Create multiline edit
   // x: <createwindowexa 512,edit,,1342246980,0,0,80,20,788130,1,4194304,0>=> "591364"
   edithandle:= createwindowexa($200,'edit','',$50011044,10,10,470,450,handle,1,400000,0);

   // Set font 1795818836 = <user32.CreateFontA -11,0,0,0,0,0,0,0,0(*ansi_charset*),
   // --0(*out_default_precis*),0(*clip_default_precis*),0(*default_quality*),
   // --20(*default_pitch or ff_swiss*),MS Sans Serif>>
   // x: <wm_setfont 591364,1795818836,1>
   // (already done when creating xform)
   // font:= createfont(-11,0,0,0,0,0,0,0,0(*ansi_charset*),
   //    0(*out_default_precis*),0(*clip_default_precis*),0(*default_quality*),
   //    20(*default_pitch or ff_swiss*),'MS Sans Serif');
   intres:= sendmessage(edithandle,48,font,1);
   // iofwcons('++ wm_setfont => ' + inttostr(intres) + '.');

   // em_setReadOnly
   // x: <dllcall user32,SendMessageA,int,$1,int,<htod CF>,int,$2,int>
   intres:= sendmessage(editHandle,$CF,1,0);

   // Put help text in edit
   // x: <user32.SetDlgItemTextA $windowhandle,$2,$3>
   // boolres:= SetDlgItemText(handle,1,'12345');
   if helpStr='' then gethelp;
   boolres:= SetDlgItemText(handle,1,pchar(helpstr));

   // Paint window
   // x: <wm_setredraw 788130,1>
   // x: <invalidaterect 788130,0,1>
   intres:= sendmessage(handle,11,1,0);
   boolres:= invalidaterect(handle,0,true);

   // Put multiline edit in window
   // x: <movewindow 591364,6,6,100,100,0>
   // boolres:= movewindow(edithandle,6,6,400,400,false);

   // x: <resizewindow 112,112>
   // resizewindow(handle,112,112);

   // Repaint window
   // x: <invalidaterect 788130,0,1>
   // invalidaterect(handle,0,false);

   // Make sure it is visible
   // x: <showwindow 788130,1>
   // showwindow(788130,1);

   // Repaint window
   // x: <invalidaterect 788130,0,1>
   // invalidaterect(handle,0,false);

  // showdebugform;

end; (*iofHelp*)


procedure iofhelp0;
(* Show the help window. *)

begin
  (* Show directly if in main thread. *)
  showdebugform

end; (*iofHelp0*)


(* var ret: smallint; (for testing sql odbc connection) *)

procedure getClientPos(phandle: hwnd; var px,py: integer);
(* Find out where window phandle is located in the client area of its
   parent window.  *)
var p: tpoint; parentHandle: hwnd;
prect,crect: trect;
begin
// 1. Get the handle to the parent window
parenthandle:= getparent(phandle);

// 2. Get the position and size of window phandle, in screen coordinates
GetWindowRect(phandle,crect);

// 3. Convert its upper left corner to client coordinates of the parent window.
p.X:= crect.Left;
p.Y:= crect.Top;
ScreenToClient(parenthandle,p);
px:= p.X;
py:= p.Y;

end; (* getClientPos *)

procedure iofmovewindow(phandle: hwnd; pleft,ptop,pwidth,pheight: integer;
   pupdate: boolean);
(* Change position and size (in screen coordinates) of window hwnd.
   Used by <formmove ...> and by resize. *)

var
wrect:tRect;
x,y,width,height: integer;
begin

// Get position of window phandle, in the client area of its parent window
getclientpos(phandle,x,y);

// Get position and size of window phandle, in screen coordinates
getwindowrect(phandle,wrect);
width:= wrect.Right-wrect.Left;
height:= wrect.Bottom-wrect.Top;

if pleft>=0 then x:= pleft;
if ptop>=0 then y:= ptop;
if pwidth>=0 then width:= pwidth;
if pheight>=0 then height:= pheight;

movewindow(phandle,x,y,width,height,pupdate);

end; (*iofmovewindow*)

(* iofGetFormValues
   ----------------
   Return current left, top, width and height.
   Used by <formmove>.
*)
procedure iofGetFormValues(var px,py,pxsize,pysize: integer);
var
wrect:tRect;
x,y,width,height: integer;
begin

getclientpos(xform[1].handle,px,py);

getwindowrect(xform[1].handle,wrect);
pxsize:= wrect.Right-wrect.Left;
pysize:= wrect.Bottom-wrect.Top;

end; (*iofGetFormValues*)


procedure iofmove(pleft,ptop,pwidth,pheight: integer);
begin

if currentform=1 then
   iofmovewindow(xform[1].handle,pleft,ptop,pwidth,pheight,false);

end; (*iofmove*)

procedure iofShowMess(pStr: string);
begin
   MessageBox(0, pansichar(pStr),'X', MB_OK);
end; (*iofshowmess*)


procedure resize;
var
wrect: trect;
newwidth,newheight: integer;
begin
   // Get new size of the form
   getwindowrect(xform[currentForm].handle,wrect);
   newwidth:= wrect.Right-wrect.Left;
   newheight:= wrect.Bottom-wrect.Top;

   if currentform=1 then begin
      iofmovewindow(xform[1].cmdLineHandle,-1,-1,newwidth-160,-1,true);
      iofmovewindow(xform[1].enterButtonHandle,newwidth-108,-1,-1,-1,false);
      iofmovewindow(xform[1].resultareahandle,-1,-1,newwidth-85,newheight-125,false);
      end
   else begin
      iofmovewindow(xform[2].cmdLineHandle,-1,-1,newwidth-160,-1,false);
      iofmovewindow(xform[2].enterButtonHandle,newwidth-105,-1,-1,-1,false);
      iofmovewindow(xform[2].ResultAreaHandle,-1,-1,newwidth-85,-1,false);
      iofmovewindow(xform[2].xCodeAreaHandle,-1,-1,newwidth-85,newheight-350,false);
   end;
   invalidateRect(xform[currentform].handle,NIL,true);
end;


initialization
iofinit;
end.
