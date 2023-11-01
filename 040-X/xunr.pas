(* xunr.pas *)

(* UNR - New package to implement <unread ...> *)
(***********************************************)

UNIT xunr;

(* {$MODE Delphi} (needed?) *)


(***) INTERFACE (***)
uses
   xt (* ioinptr *)
   ,xx (* xx.xscripterror *)
   ,xfs (* fsptr *)
   ;
var

active: boolean = false; (* Controls switching between old and new unread
   can be activated with <settings unractive,yes>. *)

unrBottomPtr: ioinptr; (* Pointer to first character of the occupied
   part of the unr buffer. This is probably the first character in the
   most recently created unread string that has not yet been released.
   Used by unrUnread to find the free part of the unread buffer. Also
   used by alC, to update UnrBottomPtrInCurrentState. Initialised to
   unrTopPtr. Updated by unrUnread and unrCheckRelease. *)

(* The purpose of the following pointers is to protect unread strings
   that can still be accessed with <p n> from being overwritten by
   new unread strings. *)
unrBottomPtrAtEntryToCurrentState: ioinptr; (* Pointer to the first uchar
   of the unread buffer, when the current state was called. Used, together
   with unrBottomPtrInCurrentState, by unrCheckRelease after completion of
   each alternative (?"..."? !"..."!) to determine which unrStrings can be
   released (deleted).
   Updated by alC. *)
unrBottomPtrInCurrentState: ioinptr; (* nil: No unread string has been
   created, and not yet released, in or under the current state
   >nil: points at the most recently created, and not yet released,
   unread string in or under the current state. Used by xEvaluate('A')
   to decide if it is necessary to check for possible release of
   unread strings. Updated by alc, unrUnread, UnrCheckRelease.
   Defined as: "if UnrBottomPtr>UnrBottomPtrAtEntryToCurrentState then
   unrBottomPtr else nil". *)

UnrTopPtr: ioinptr = nil; (* Initialised to @unrBuf) + ioint32(UnrBufSize)
   in unrInit. Never updated. *)


procedure unrInit; (* Initialize unr package *)

procedure unrUnread(pstr: fsptr; pendch: CHAR; var pstateenv: xstateenv);

function leavingUnrBuf(pinp1,pinp2: ioinptr): boolean;
(* Return true if pinp1 is in unreadbuf but not pinp2. *)

(* unrCheckRelease
   --------------
   To be called when it is time to release no longer used unread strings.
   It removes all unread strings belonging to the current input file, if
   the current input pointer is outside the unread buffer. If the current
   input pointer is in the unread buffer, then it removes all unread strings
   created after the one where the current input pointer is.

   Usage example:
      if (UnrRPtrInCurrentState) begin
         / * One or more unread strings have been created, and not yet released,
            since call of this state. * /
         if (unrCheckRelease(inFileRecPtr))
            // Sign of progress => reset loop detection
            loopCnt = 0;
            end
         end

*)
function unrCheckRelease(pFileRecPtr: pointer; pinp: ioinptr): boolean;

(* Release all unread strings belonging to a particular file
   (used when a file is closed or deleted). *)
function unrCheckReleaseAll(pFileRecPtr: pointer): boolean;

(* Clean up new unread function (May 2018). Ported from xnewgui (c).
   To be called by ioCleanup. *)
procedure cleanup;

(***) IMPLEMENTATION (***)

USES

xio (* ioerrormess, ioreadln, ioinptr *)
,SysUtils (* inttostr *)
,xioform  (* iofWriteToWbuf, iofWritelnToWbuf *)
;


(* About unread
   ------------

   <unread ...> inserts a string to be read as if it came from the input file.
   But the file is not changed. Instead, the string is saved in a buffer and
   the input pointer is moved to the beginning of it. When the input pointer
   as advanced past the end of the inserted string, it jumps automatically back
   to where it was before <unread ...> was done. It is also possible to do
   <unread ...> when already reading from an unread string. Then a new
   string is created, under the first, in the unread buffer. A table,
   unrStack, keeps track of all the created unread strings.

   Examples:

   From filtersvs.
   ?"'<li'>"?
   !"<unread •>"!

   From etcsbalise.scramble1.x
   !"<unread <sp 1>
   >"!

   From compileRioTinto.x (rioBaliseTgm.x)
   ( * For opposite direction: * )
   ?"[<to ],;>]<followedby ;, ;,<eof>>"?
   !"<set $opposite,yes><unread <p 1>>
   -( * (probably wrong/BFn 110917: )<set $normalOppositeCount,<calc $normalOppositeCount-1>> * )
   -"!

   From cmdfilereader.x
   <function queuecommand,
   -<buttondebug Queuecommand: $1>
   -<localio
   --<in $trkfilename>
   --<unread C: $1
   >
   -->>

   When it is safe to release an unread string?

   Principle for release of consumed unread strings
   ------------------------------------------------

   Unread is used to insert a string in the input  stream, or to change a string
   in the input stream. It can be released when passing its end, provided that
   it is not part of ?"..."? whose !"..."! not have been completed (so that
   <p n> still shall work).

   Implementation
   --------------
   To start with, release check when leaving the unr-string is not a solution,
   because the program then normally is in ?"..."? whose !"..."! not yet have
   been completed.

   Instead, release check is done at "!, or at end of <read ...>:

   1. At "!: Check, for the input file used in preceeding ?"..."?, all unread
      strings belonging to that input file, which were created since the current
      state was called. If the input files input pointer is "above" an unread
      string, release the unread string. If it is "in" or "below", break the search.
      "above" means either outside the unread buffer, or at a higher address in
      the unread buffer. "in" or "below" means inside the unread buffer and at
      a lower address than the first character in the unread string.

   2. At end of <read ...>, remove all unread strings, for the same input file,
      which are "below" the input pointer, provided that <read ...> is not done
      within ?"..."?. ( - This does not seem to be implemented, neither in
      xfpc nor in xnewgui)

*)

type UnrInfoType = record
   high: ioinptr; // end of unread string (pointing at 'u')
   fileRecPtr: pointer; // in which file the string was unread
   end;

(* unread block structure:
   uchar str[n]; // Unread string
   uchar unrEnd; // 'u' Tells that pointer is in unread buffer at end of string
   uchar *unrNextInPtr; // Saved inPtr
*)
const UnrBufSize = 100000;

var
unrBuf: array [0..UnrBufSize-1] of char;

const StackSize = 100;

var
unrStack: array[0..StackSize-1] of UnrInfoType;

stackTop: integer = 0;


procedure unrinit;
begin

// New unread buffer (from xnewgui):
unrTopPtr:= @unrBuf + UnrBufSize;

unrBottomPtr:= unrTopPtr;
unrBottomPtrAtEntryToCurrentState:= unrBottomPtr;

end;

(* unrUnread
   ---------
   Create an unread string in the unread buffer and let the input pointer
   point at its first character:
   1. Copy the current input pointer + 1 to the unread buffer.
   2. Below the current input pointer + 1, write 'XtOther' + 'u'
   3. Below 'u', write the string.
   4. Change the current input pointer to point at the first uchar of the string.

   Save info in the unrStack table about the new record, so that
   it can be removed later when it is not needed any more:
   1. Check that unrStack is not full.
   2. Add a record to the top of the stack.
   3. In this record, save a pointer to the current file record ("fileRecPtr")
      and a pointer to after the created string ("high"),
   4. These pointers are used to release unused unr strings belonging to the same
      file, which are below the current input pointer.

   Example, after <unread hej>:

                  unread buffer        unread stack          file record
   (old) unrBottom ->
                     -----
                     | c |              -------------
                     | i |       |------|    high    |
                     | n |       |      --------------        --------------
                     | p |       |      | fileRecPtr |------->|            |
                     | t |       |      --------------        --------------
                     | r |       |                            |            |
                     | - |       |                            --------------
                     | 1 |       |                            |            |
                     -----       |                            --------------
                     |'u'|<------|                            |            |
                     -----                                    --------------
            (xtother)|253|
                     -----
                     |'J'|
                     -----
                     |'E'|
                     -----
   (new) unrBottom ->|'H'|
                     -----
                     |   |<----- new cinptr
*)

type charPtrPtrType = ^ioInPtr;

procedure unrUnread(pstr: fsptr; pendch: CHAR; var pstateenv: xstateenv);
//(c:)  procedure unrUnread(pStartPtr: ioinptr; pEndPtr: ioinptr);

var
strLen: integer;

toPtr, toEndPtr, newUnrBottomPtr: ioinptr;
fromPtr,fromEndPtr: fsptr;

begin
   fromEndPtr:= pstr;
   fsforwendch(fromEndPtr,pendch);

   strLen:= fsdistance(pstr,fromEndPtr);
   if (strLen>0) then begin
      if (stackTop>=StackSize) then begin
         xProgramError('<unread ...> (alunread): overload in unread '+
            'Stack. Try increase Unr.cpp: StackSize, or there is an error in '+
            'the X program so that unread buffers are not always released when '+
            'no longer needed. (<unread ' + fstostr(pstr) + '> skipped).');
         end
      else begin
         newUnrBottomPtr:=unrBottomPtr - (strLen+6);
         if (newUnrBottomPtr<@unrBuf) then begin
            xProgramError('<unread ...> (alunread): overload in unrBuf. Try ' +
               'increase UntBufSize, or there is an error in the X program so ' +
               'that unread buffers are not always released when no longer ' +
               'needed. (<unread ' + fstostr(pstr) + '> skipped).');
            end
         else begin
            // Save ip in the unread buffer
            unrBottomPtr-=4;

            (* unrBottomPtr now points 4 bytes below the last unread string.
               This is the place to put the "back" pointer which is used when
               returning from the string. *)

            (* Make 'u' link work the same as 'n' link - it points
               to where you are going when leaving the previous block
               (not to where you were), thus "+1" below. *)
            charPtrPtrType (unrBottomPtr)^:= pstateenv.cinp;
            // (c:) *((uchar **)unrBottomPtr):=xCInPtr+1;

            // Put the unr string 'end sign'
            unrBottomPtr-=1;
            unrBottomPtr^:=char(0);
            // unrBottomPtr^:=char(fseofs);
            // (c:) unrBottomPtr^:='u';

            // Put the eobl character
            unrBottomPtr-=1;
            unrBottomPtr^:=char(ioeobl);
            // (c:) *unrBottomPtr:=(uchar)XtOther;

            // Save the unread string in the unread buffer
            toEndPtr:= unrBottomPtr;
            unrBottomPtr-=strLen;
            toPtr:= unrBottomPtr;
            fromPtr:= pStr;
            while (toPtr<toEndPtr) do begin
               toPtr^:= fromPtr^;
               toPtr+= 1;
               fsforward(fromPtr);
               end;

            // (Temporary test during development)
            if (fromPtr<>fromEndPtr) then xProgramError('xunr.unrUnread: fromPtr (' +
               inttostr(qword(fromPtr)) + ') was expected to be equal to fromEndPtr (' +
               inttostr(qword(fromEndPtr)) + ') but it was not.');

            unrStack[stackTop].high:= toEndPtr; // (pointing at 'eobl')
            unrStack[stackTop].fileRecPtr:= iogetinfileptr;
            stackTop+=1;

            ioStepUnreadCounter(@pstateenv,1);

            // Set new cinp
            pstateenv.cinp:= unrBottomPtr;
            // (c:) xCInPtr:= unrBottomPtr-1;

            // Set unread read pointer to point at the first uchar in the unread string.
            ioStepUnreadCounter(iogetinfileptr,1);
            // (c:) xInFileRecPtr->unrRPtr:=unrBottomPtr;

            // Update unrBottomPtrInCurrentState
            if (unrBottomPtr>=unrBottomPtrAtEntryToCurrentState) then
               xProgramError('unrUnread: unrBottomPtr (' +
                  intToStr(integer(unrBottomPtr))+
                  ') was expected to be below unrBottomPtrAtEntryToCurrentState (' +
                  intToStr(integer(unrBottomPtrAtEntryToCurrentState)) +
                  ') but it was not.')
            else
               unrBottomPtrInCurrentState:=unrBottomPtr;
            end// (no unrbuf overflow)
         end// (no stack overflow)
      end// (strlen>0)
end; // (unrUnread)



function leavingUnrBuf(pinp1,pinp2: ioinptr): boolean;
(* Return true if pinp1 is in unreadbuf but not pinp2. *)
var res: boolean = false;
begin
   if (qword(pinp1) >= qword(@unrbuf)) and (qword(pinp1) <= qword(unrTopPtr)) then
      if (qword(pinp2) < qword(@unrbuf)) or (qword(pinp2) > qword(unrTopPtr)) then
         res:= true;

   leavingUnrBuf:= res;

   end; (* leavingUnrBuf *)

(* (new:) Release all unread strings belonging to a file
   (this means that <p n> in unread strings higher up in the call
   structure are not protected. But these are anyway copied in
   x-fpc with pnstack.
   Later, consider protecting unread strings used in higher
   states, and removing the pnstack
   (BFn 2018-05-11)
*)

(* unrCheckRelease
   --------------
   To be called when it is time to release all unread strings belonging
   to a file. This is when the input pointer, during ?"..."?!"..."! changes
   from being in the unread buffer to being outside it.
   This means that the unread management is improved to handle different
   files separately, compared with the old unread, which erased
   all unread strings when one input pointer returned to its file.

   Usage example:
	   if xunr.leftUnrbuf(inpback,inpend) then begin
	      // Same file?
	      if xio.iogetinfileptr = inputfile then begin
	         // We have left the unread buffer, release unread strings if possible
	         if (xunr.unrCheckRelease(inputfile,pstateenv)) then
	            // Sign of progress => reset loop detection
	            loopCnt:= 0;
	         end;
	      end;

*)
(* New Test version (not very good) /180511. *)
function unrCheckRelease1(pFileRecPtr: pointer): boolean;

begin
   unrCheckRelease1:= unrCheckReleaseAll(pFileRecPtr);

end;// (UnrCheckRelease)

// (version ported from xnewgui)
(* unrCheckRelease
   ---------------
   To be called when it is time to release no longer used unread strings.
   It removes all unread strings belonging to the current input file, if
   the current input pointer is outside the unread buffer. If the current
   input pointer is in the unread buffer, then it removes all unread strings
   created after the one where the current input pointer is.

   Usage example:
      if (UnrRPtrInCurrentState) begin
         / * One or more unread strings have been created, and not yet released,
            since call of this state. * /
         if (unrCheckRelease(inFileRecPtr))
            // Sign of progress => reset loop detection
            loopCnt = 0;
            end
         end

*)
function unrCheckRelease(pFileRecPtr: pointer; pinp: ioinptr): boolean;

var
res: boolean = false;
finished: integer;
inputPtr: ioinptr;
starti,i: integer;

begin

   // 1. Get current read pointer (could be inside or outside unread buffer)
   inputPtr:=pinp;

   // 3. Simplify detection of new read ptr being outside unread buffer
   if (inputPtr<@unrBuf) then inputPtr:= unrTopPtr + 1;

   (* 4. Reduce input pointer to what it was at entry to the state, to protect
      <p n> strings at higher calling levels. *)
   if (inputPtr>unrBottomPtrAtEntryToCurrentState) then
      inputPtr:= unrBottomPtrAtEntryToCurrentState;

   // 5. Remove obsolete unread strings from top of stack and downwards
   starti:= stackTop-1;
   i:= starti;

   (* 6. Decrement i until it points at the last record that shall be kept,
      or = -1 if no records shall be kept. *)
   finished:= 0;
   while finished=0 do begin
      if i<0 then finished:= 1 // Reached bottom end of stack
      // Remove empty strings (holes).
      else if unrStack[i].fileRecPtr = nil then i-= 1 // empty record - ignore
      else if (unrStack[i].fileRecPtr = pFileRecPtr) and
         (inputPtr>unrStack[i].high) then begin
         // Found record that is obsolete - erase it
         unrStack[i].fileRecPtr:= nil;
         ioStepUnreadCounter(pfilerecptr,-1);
         res:= true;
         i-= 1;
         end
      else finished:= 2; // Found record belonging to another file.
      end;
   (* (c:) while ( i>=0 && (unrStack[i].fileRecPtr==NULL ||
      unrStack[i].fileRecPtr==pFileRecPtr && newUnrRPtr>unrStack[i].high) )
      i--; *)

   // 7. Remove deleted records from stack,
   if (i+1<stackTop) then begin
      // Something was removed.
      (* i+1 points at the last removed stack record. Its end pointer
         plus 6 ('XtOther' + 'u' + saved (in pointer+1)) shall point at the beginning
         of the next valid block. *)
      unrBottomPtr:=unrStack[i+1].high+6;
      stackTop:=i+1;

      // Check/update unrBottomPtrInCurrentState
      if (unrBottomPtrAtEntryToCurrentState<unrBottomPtr) then begin
         xProgramError('unread: unrBottomPtr (' +
            intToStr(cardinal(unrBottomPtr)) +
            ') was expected to be same or below unrBottomPtrAtEntryToCurrentState (' +
            intToStr(integer(unrBottomPtrAtEntryToCurrentState)) +
            ') but it was not.');
         unrBottomPtrAtEntryToCurrentState:= unrBottomPtr;
         end;

      // Update unrBottomPtrInCurrentState
      if (unrBottomPtr = unrBottomPtrAtEntryToCurrentState) then
         unrBottomPtrInCurrentState:= nil // No unread strings left in this state
      else
         unrBottomPtrInCurrentState:=unrBottomPtr; // Update after removal

      res:=true;
      end;

   (* 8. Delete embedded obsolete records belonging to the same file.
      (if the last record belongs to another file and there are older records
      which can be deleted). Go through all remaining records until and delete
      all records those which are records which belong to pFileRecPtr and are
      more recent than inputPtr. If an older record is found that belongs to the
      same file, then it is not necessary to continue. (Maybe it would be good
      to check the stack size at entry to the state, and only check those
      records which are above this index.)
   *)
   if i>0 then begin
      // There are at least two records left (0 and 1). i points at the last of them (>=1)
      finished:= 0;
      while finished=0 do begin
         if i<0 then finished:= 1 // Bottom reached
         else if inputPtr<unrStack[i].high then finished:= 2 // (a little unsure about reason)
         else begin
            if (unrStack[i].fileRecPtr = pFileRecPtr) then begin
               (* Input pointer has passed the record which belongs to the same file =>
                  string is obsolete. *)
               unrStack[i].fileRecPtr:= nil;
               ioStepUnreadCounter(pfilerecptr,-1);
               res:= true;
               end;
            i-= 1;
            end;
         end;
      end; (* i>0 *)

   (* c: while (i>=0 && newUnrRPtr>=unrStack[i].high) then begin
      if (unrStack[i].fileRecPtr==pFileRecPtr) unrStack[i].fileRecPtr:=NULL;
      i--;
      end*)

   unrCheckRelease:= res;

end;// (UnrCheckRelease)

(* Release all unread strings belonging to a particular file
   (used when a file is closed or deleted). *)
function unrCheckReleaseAll(pFileRecPtr: pointer): boolean;

var
i, newStackTop: integer;
newStackTopSaved: boolean;
res: integer = 0;

begin

   // 1. Start from top of unrStack
   i:= stackTop-1;
   newStackTop:= stackTop;
   newStackTopSaved:= false;

   (* 2. Decrement i until a record for another file is found. Delete all
      records belonging to this file. *)
   for i:= stackTop-1 downto 0 do begin
      // Remove empty strings (holes).
      if unrStack[i].fileRecPtr = nil then // Empty record - ignore
      else if (unrStack[i].fileRecPtr = pFileRecPtr)then begin
         // record belonging to this file - erase
         unrStack[i].fileRecPtr:= nil;
         ioStepUnreadCounter(pfilerecptr,-1);
         res+= 1;
         end
      else begin
         // Record belonging to other file - mark the last one
         if not newStackTopSaved then begin
            // Save new stacktop
            newStackTop:= i+1;
            newStackTopSaved:= true;
            end;
         end;
      end;

   if not newStackTopSaved then begin
      newStackTop:= 0;
      newStackTopSaved:= true;
      end;

   if newStackTop<stackTop then begin
      // Update bottom pointer, stack top and bottom in current state
      if newStackTop = 0 then unrBottomPtr:= unrTopPtr
      else unrBottomPtr:=unrStack[newStackTop-1].high+6;
      stackTop:= newStackTop;

      if (unrBottomPtrAtEntryToCurrentState<unrBottomPtr) then begin
         xProgramError('unread: unrBottomPtr (' +
            intToStr(cardinal(unrBottomPtr)) +
            ') was expected to be same or below unrBottomPtrAtEntryToCurrentState (' +
            intToStr(integer(unrBottomPtrAtEntryToCurrentState)) +
            ') but it was not.');
         unrBottomPtrAtEntryToCurrentState:= unrBottomPtr;
         end;

      if (unrBottomPtr = unrBottomPtrAtEntryToCurrentState) then
         unrBottomPtrInCurrentState:= nil
      else unrBottomPtrInCurrentState:=unrBottomPtr;
      end;

   unrCheckReleaseAll:= (res>0);

end;// (UnrCheckReleaseAll)

(* Clean up new unread function (May 2018). Ported from xnewgui (c).
   To be called by ioCleanup. *)
procedure cleanup;
begin

// Unread status Diagnostics
if (unrBottomPtr<>unrTopPtr) then
   xScriptError(
   'unr.Cleanup: unrBottomPtr(' + intToStr(Qword(unrBottomPtr)) +
   ') was expected to be same as unrTopPtr (' + intToStr(Qword(unrTopPtr)) +
   ') but it was not.');
if (unrBottomPtrAtEntryToCurrentState<>unrBottomPtr) then
   xScriptError(
   'unr.Cleanup: unrBottomPtrAtEntryToCurrentState(' +
   intToStr(Qword(unrBottomPtrAtEntryToCurrentState)) +
   ') was expected to be same as unrBottomPtr (' +
   intToStr(QWord(unrBottomPtr)) +
   ') but it was not.');
if (unrBottomPtrInCurrentState<>nil) then
   xScriptError(
   'unr.Cleanup: unrBottomPtrInCurrentState(' +
   intToStr(QWord(unrBottomPtrInCurrentState)) +
   ') was expected to nil but it was not.');

// Reset unread buffer
unrBottomPtr:= unrTopPtr;
unrBottomPtrAtEntryToCurrentState:= unrBottomPtr;
unrBottomPtrInCurrentState:= nil;
stackTop:= 0;

end; (* cleanup *)


end.


