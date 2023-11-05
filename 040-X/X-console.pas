//program HelloWorld(output);
program HelloWorld;

Uses 
   windows
   ,sysutils
   ;

var stopped: boolean = false;
var str: ansistring;
var buffer: pchar = NIL;

// function xEnterString(pstr: pchar): integer; export; stdcall;
// procedure xgetreturn(pbufsize: integer; pbuf: pchar); export; stdcall;

type
   // Definition of the subroutine to be called, as defined in the DLL to be used
   TxEnterString = function(pstr: pchar) : integer;  stdcall;
   TxGetReturn = procedure(pbufsize: integer; pbuf: pchar); stdcall;
   TxGetOutput = procedure(pbufsize: integer; pbuf: pchar); stdcall;
   TxGetOutput2 = procedure(pbufsize: integer; pbuf: pchar); stdcall;
   TprintMode = (getreturn, getoutput, getoutput2);
   
 var
   // Creates a suitable variable (data field) for the DLL subroutine
   xEnterString : TxEnterString;
   xGetReturn : TxGetReturn;
   xGetOutput : TxGetOutput;
   xGetOutput2 : TxGetOutput2;
   
   // Creates a handle for the DLL
   LibHandle : THandle;   
   intResult: integer;
   strResult: ansistring;
   printMode: Tprintmode = getreturn;
   
function getAddress(pname: pchar): pointer;
var ptr: pointer;
begin
   ptr:= GetProcAddress(LibHandle, pname);
   if ptr = NIL then writeln('*** getAddress(Libhandle,' + pname + '): ' +
      'Address was expected from GetProcAddress(...) but NIL was found.');
   getAddress:= ptr;
end;

begin

   // Get the handle of the library to be used
   LibHandle := LoadLibrary(PChar('xdll.dll'));
   
   if LibHandle <> 0 then begin
      // writeln('Library xdll.dll was found (LibHandle='+inttostr(integer(LibHandle))+'.');
      // Assigns the address of the subroutine call to the variable funStringBack
      // 'funStringBack' from the DLL DLLTest.dll
      Pointer(xEnterString):= getAddress('xEnterString');
      Pointer(xGetReturn) := getAddress('xgetreturn');
      Pointer(xGetOutput) := getAddress('xgetoutput');
      Pointer(xGetOutput2) := getAddress('xgetoutput2');
      

      // Checks whether a valid address has been returned
      if @xEnterString <> nil then begin
         // writeln('Function xEnterString was found (@xEnterString='+inttostr(integer(@xEnterString))+'.');
         end
      else writeln('Function xEnterString was not found (@xEnterString = nil).');

      if @xGetReturn <> nil then begin
         // writeln('Function xGetReturn was found (@xGetReturn='+inttostr(integer(@xGetReturn))+'.');
         (* Creating buffer for answer - copied from aldllcall:
            buffer: pChar;
            ...
            if dllRefpartype[refCnt]<>refStr then begin
               // Get new string buffer.
               GetMem(Buffer, 2000);
               dllBuffer[refCnt]:= integer(Buffer);
               dllRefpartype[refCnt]:= refStr;
               end;
            atab[argcnt]:= dllBuffer[refCnt]; *)
         (* +++ *)
         if buffer=NIL then GetMem(Buffer, 2000);
         (* procedure xgetreturn(pbufsize: integer; pbuf: pchar); export; stdcall; *)
         (* xgetreturn(3000,buffer);
            strResult:= buffer;
            writeln('Result = "' + strResult + '".'); *)
         end
      else writeln('Function xGetReturn was not found (@xGetReturn = nil).');

     end
   else writeln('Library xdll.dll was not found (LibHandle=0).');


   while not stopped do begin
      write('(X)>');
      readln(str);
      if (lowercase(str)='quit') or (lowercase(str)='exit') or (lowercase(str)='stop') then stopped:= true
      
      else begin
         case str of
            'getreturn': begin
               printmode:= getreturn;
               writeln('printmode = getreturn');
               end;
            'getoutput': begin
               printmode:= getoutput;
               writeln('printmode = getoutput');
               end;
            'getoutput2': begin
               printmode:= getoutput2;
               writeln('printmode = getoutput2');
               end;
            else begin
               xEnterString(pchar(str));
               case printMode of
                  getreturn: xgetreturn(2000,buffer);
                  getoutput: xgetoutput(2000,buffer);
                  getoutput2: xgetoutput2(2000,buffer);
                  end; (* (case) *)
               end;
            end; (* (case) *)
            
         strResult:= buffer;
         writeln(strResult);
         end;
      end;
   writeln('Stopped!');
end.