unit xd;

{$MODE Delphi}

(* Descriptions to the X software.
   -------------------------------

   <out ,string> works the following way:
   1. When <out ,string> is used, the variable pstateenv.outstring is set
      to true.
   2. Whenever the program writes to the output file, it first looks at
      pstateenv.outstring. If it is true, it sends the character(s) to
      funcret instead. funcret is the return string of the currently
      evaluated <...>-function or a temporary storage for an evaluated
      argument.
   3. The program writes to the current output file at the following three places.
      In xEvaluate:
         iooutwritefs(pretstr,pstateenv.cinp);
         iooutwrite(ch,pstateenv.cinp);
      In alwrite:
         iooutwritefs(str,pstateenv.cinp);
   4. Conditional handling when pstateenv.outstring has been added at those
      three places. Example (from xEvaluate):
         if pstateenv.outstring then fspshend(pretstr,ch)
         else iooutwrite(ch,pstateenv.cinp);

   <r str> works in the following way:
   1. alr sets pstateenv.newstatenr to 0 to signal that xcallstate shall
      return.
   2. alr also adds arg1 (=str) to pfuncret after evaluation.
   3. Output from functions call



   Write to file is done through the following procedures:
   iooutwritefs: xEvaluate and alWrite
   iooutwrite: xEvaluate (all other calls to iooutwrite are from iooutwritefs)
*)
interface

implementation

end.
