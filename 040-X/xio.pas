{$R-} // (?/Bfn 170610)
(* XIO.PAS Bertil Friman *)

(* Modifications in xcallstate(110208):
   1. checkio is moved to after xEvaluate.
*)
(* 05-08-15: Sockets made more flexible: Connection can be closed and reopened
             without disturbing program. *)
(* 05-06-02: All file buffers end with next buffer pointer, so that ioinforward
             can function even when curinfilep has changed. *)
(* 05-03-04: Simplified interface to ioin and ioout. kind = infile and outfile
             unified to afile. *)
(* 04-05-18: Unread changed to preserve already read accessed by <p n>. *)
(* 00-07-02: Possible to write in middle of file using <in ...>
             <inseek ...> <out ...> *)
(* 00-04-20: Version 1.04 started. <in filename:pos> *)
(* 99-09-17: Version 1.03 started: <unread>
             (ioin, iounread, ioinsetbackpos). *)
(* 99-02-06: Major changes. Multiple output files, output files
             usable as input, in and out works on internet sockets. *)
(* 99-01-30: Changes unread so that it uses its own buffer. *)
(* 99-01-16: Version 1.01 finished. 1.02 started. *)
(* 98-11-14: Changes unread so that it works in the same way for file
             and console (new string copied to before the current posi-
             tion and pointer wraps around from consbuf[bufsize] to cons-
             buf[0]). *)
(* 98-07-18: V. 101. Implementation of ioin (for the multiple file
             version of <in filename>). *)
(* 98-06-08: Modications to make x look more like the old x.
             Read shall no longer read from file, only from
             the unread buffer. *)
(* 95-09-11: CONVERTS FIL.PAS TO LOOK ALIKE OLD XIO.PAS FROM X,
             BY IMPLEMENTING IOXRESET, IOXREAD, IOINREAD, IOUNREAD
             AND IOOUTWRITE. *)
UNIT xio;

{$MODE Delphi}

(* 93-03-12: IDL ON TURBO 4 *)
(****************************)


(****) INTERFACE (****)

USES
xfs    (* fsstring32, fsptr, fscopy, fsnew, fsdispose, .. *)
,xt (* ioinptr, xparsrecord. *)
,SysUtils (* EInOutError, Exception. *)
,syncobjs (* TCriticalsection *)
,Dialogs (* Messagedlg *)
,controls (* mrYes, mrNo, ... *)
,winsock (* gethostbyname, inet_ntoa, Tsocket, send, recv, ... *)
,windows (* initializecriticalsection *)
// ,LCLIntf
// ,LCLType
,LMessages (* createevent, setevent, wairforsingleobject. *)
,FileCtrl (* directoryexists, createdirectory. *)
,math (* min *)
,strUtils (* LeftStr *)
,classes (* TstringList *)
;

CONST
ioeofr=254;                 (* End of fragment. Something
                               must be done to get the next
                               character (such as calling
                               ioingetinput). *)
ioeobl=253;                 (* End of block. Last block have eobl+eofs+next pointer
                               at the end of it. Non-last blocks have eobl+nfreespace+
                               next pointer at the end of them. nfreespace=0-251 where
                               251 = >250. nfreespace is used by ioseek and
                               iocclosefilerec.
                               If a block has free space at the end,
                               the free space is either represented as eobl+eobl+...
                               (small space) or by eobl+eoblfillptr+pointer to "real"
                               eobl (large space).*)
ioeoblfillptr=252;          (* End of block fill pointer. The next four bytes is
                               a pointer to the "real" eobl at the end of the
                               block. eoblfillptr is used to
                               distiguish in-block pointers from end of
                               block pointers so that they can be maintained
                               when the block varies in size (ioremove, ioinsert). *)

TYPE
ioint16= INTEGER; (* (smallint is enough, but INTEGER is recommended
                     for efficiency.) *)
ioint32= INTEGER;
ioopentyp= (ioopenwr,ioopenrd,ioopenapp);
iocharptr= ^CHAR;
ioinptrptr= ^ioinptr; // block pointer (last 4 bytes of all file blocks)
ioprefroles     = (ionone, (* Sockets: Preferred roles: None . *)
                   ioclient, (* Connect only as client. *)
                   ioserver); (* Connect only as server. *)

// Used by alin and alout:
iooptions = set of (ioBinary,ioString,ioLocal,ioCircularbuffer,ioEofAccept,ioClean);


var
ioxlock: syncobjs.Tcriticalsection = nil;
                           (* Used to avoid threads from interrupting
                              each other except at defined places
                              (ioingetinput). *)
lockcount: integer; (* used by disableotherthreads and enableotherthreads. *)
critSectX: TRTLCriticalSection; (* Win32 critical section. *)

var
ioemptylines: ioint16; (* Number of empty lines from console in a row.
                          Four emptylines in a row is regared as eof.
                          Used by ioingetinput. *)
ioinlastpos: ioinptr; (* Last position reached by ioinforward. Used to find
                       out how long part of a string was recognized in
                       xcallstate. Set by xcallstate. Incremented by
                       ioinforward. Read by xcallstate. *)
ioclosing: boolean = False; (* True = User is closing X, *)
iosuppressbadcharmessage: boolean = False;
                       (* True = silently convert reserved chars, e.g. eofs
                          in non-binary input file without showing any
                          error message. *)
iomsgboxtooutputwindow: Boolean = False; (* <settings msgboxtooutputwindow,yes/no> *)

iofailureexit: boolean = False; (* True if exception is create because of
                          too many failures. Used to skip <cleanup> when
                          closing the X program (because it may cause news
                          exceptions and prevent closing the program. *)
iodoingcleanup: boolean = false; (* Used by iocleanup to signal to threads
                                  (iningetinput) that they shall terminate. *)


recvafterlfcnt: integer = 0;

(***)function iounrsize: integer;

function ioSerialBufferInfo(pcinp: ioinptr): string;

procedure iocheckcinp(var pstateenv: xstateenv );

procedure ioinit( var pinp: ioinptr );

procedure ioxhandleInternalFiles;

function ioInternalFile1: string;
(* Return name of first internal file (or '').
   Used by xtest to load the first internal file, if there are any. *)

procedure ioxreset( pfilename: fsptr; pShortName: boolean; var perror: BOOLEAN );
(* Open x file while still keeping current x file (if any) open.
   Load from alworkingdir if possible (overrides dir used in filename).
   pshortname means that original filename (in alLoad) had no path.
   Example: "test1.x". Used when looking for internal files. *)

procedure ioxclose;

procedure ioxread( var pch:CHAR; var pendfile: BOOLEAN );

procedure ioin( pfilename: fsptr; pendch: char; pOptions: ioOptions;
   ppos: ioint32; pbinary: boolean;
   pprefrole: ioprefroles; var pconfig: string; pcircularbuffer: boolean;
   pEofAccept: boolean; var pinp: ioinptr);
(* Change input file.
   Implements <in filename/domain:portnr/comn:[,pos|option|config,[,...]]>
   Filename on format domain:portnr means internet stream.
   Filename = "cons" means use console.
   Filename = comn:, e.g. "com1:" means a serial port.
   Empty filename means use current file.
   -1-pos means use current pos.
   pbinary tells if file is binary or not (only valid when opened first time).
   the current state.
   Prefrole is for sockets and telle wether client or server role is preferred.
     (only valid when opened the first time)
   pconfig is for serial ports. E.g. "baud=19200 parity=n data=8 stop=1" or
      "baud=115200 createretries=2".
  pcircularbuffer is for communication between threads, instead of using a file.
  *)

procedure iosetinpsave( pinp: ioinptr );
(* Update input pointer so that other thread is not misleaded (because it
   start from other file). *)

procedure ioinfilename( pfilename: fsptr );
(* Return name or domain:portnr of current input file. *)

function ioinfilenamestr: string;
(* Return name or domain:portnr of current input file, as stringh *)

function ioinpos( pinp: ioinptr ): ioint32;
(* Return current position in file or consbuf. First position =0.
   Other positions are expressed as the address of pinp.
   Implements <inpos>. *)

function iooutpos: ioint32;
(* Return current position in output file or consbuf. First position =0.
   Other positions are expressed as the address in file (outp).
   Implements <outpos>. *)

function ioinreadrescnt: ioint32;
(* Return read reservation count for current input file. *)

const IoMaxSelectSources = 20;
type iofilenametab = array[1..IoMaxSelectSources] of fsptr;

function ioselect( pinp: ioinptr; var pfilenames: iofilenametab; pnfiles: integer;
    pendch: char; ptimeoutms: integer): integer;
(* Wait until one of the files have input data to read. Then return
   1-10 to identify which file that has input to read.
   Used by <wait fn1,fn2,...> to be able to read from multiple tcp/ip ports
   simultaneously. If ptimeout=0, return 0 immidiately if no data available.
   If timeoutms<maxint, wait for data during ptimeoutms and then return with
   0 if no data was available *)

procedure ioingetinput( var pinp: ioinptr; pblocking: boolean );
(* Shall only be called when pinp^=eofr (end of fragment).
   If infile = console: Read one line to console input buffer.
   If infile = asocket: Call winsock recv function.
   If infile = acircularbuffer: Wait for somebody to write to the buffer.
   If infile = aserialport: Get data from the port.
   if infile = afile: If other thread has the same file open for output:
      Wait for data or eofs.
   Otherwise: do nothing.
   if pblocking= false: Return immediately if no data available from
   asocket or aserialport. *)

type iofileptr = ^char;

procedure ioinreservereadpos(pinp: ioinptr; var pfilep: iofileptr);
(* Set readpos unless reserved, advance the reservation counter and
   return a pointer to the current input file. Used
   to prevent <p n> from being overwritten because readpos
   is advanced in called states. *)

procedure ioinreleasereadpos(pfilep: iofileptr);
(* Decrement readpos reservation counter for file pfilep. See readpos. *)

procedure ioinadvancereadpos(pinp: ioinptr);
(* Update read consume pointer in current input file. See readpos. *)

(* ioReadRescnt
   ------------
   Return current read reservation count (debug purpose).
*)
function ioreadrescnt: integer;

procedure ioinclearcons( var pinp: ioinptr );
(* If infile = console: Clear input buffer.
   Otherwise: do nothing. *)

procedure iopushpn( var ppars: xparsrecord; var pdatamoved: boolean );
(* Push <p n> parameters to prevent them from being overwritten by unread.
   Return pdatamoved= true if any data was moved. *)

procedure iopoppn;

function iolocalstring: boolean;
(* Tell if we are in a local string (<in ...,string,local>).
   Used by ioin to prevent change of input file while processing string. *)

type iounrmode=(iounrnormal,iounrpush,iounrpop);

procedure iounread( pstr: fsptr; pendch: CHAR; pmode: iounrmode; var pstateenv: xstateenv );
(* Unread a string so as if it was inserted before the current
   position (pinp). This does not alter the input file buffer
   (or consbuf) it uses its own buffer.
   If pmode=push, then add eofs at end of pstr, and push save pointer to this pos.
   If pmode=pop, then go to character following eofs. Pop pointer stack.
   In pstateenv, cinp and inpback are used. *)

function ioinunrbuf( pinp: ioinptr ): boolean;
(* Return true if pinp is in unrbuf. *)

procedure ioinforward( var pinp: ioinptr );
(* Move input pointer one step forward. Convert CR LF, LF to CR. *)

procedure ioreplacewith(ps:fsptr; var pstateenv: xstateenv);
(* Implements <replacewith str>. Replace the characters between inpback
   and cinp ( representing ?"..."?) with ps. Use "eobl filling"
   to handle size changes (see definition of eobl). *)


function iolinenr( pinp: ioinptr ): ioint32;
(* Calculate current line number (first line=1 etcetera). *)

procedure ioout( pfilename: fsptr; pendch: char; ppos: ioint32; pbinary: boolean;
   pprefrole: ioprefroles;  var pconfig: string; pcircularbuffer: boolean;
   pinp: ioinptr);
(* Change output file. Implements <out file/domain:port/comn:[,pos/option/config[,...]]>  *)

function ioconnected( pfilename: fsptr; pendch: char; pinp: ioinptr): boolean;
(* If pfilename is a connected socket: true, otherwise false.
   Implements <connected domain:portnr>.
   Used to avoid waiting for writing to a socket which is in a listening
   state. *)

function ioComHandle( pfilename: fsptr; pendch: char): THandle;
(* Return the comhandle of a serial port.
   Used by <win32 ClearCommError...>
   Example:
   comHandle:= ioComHandle(arg2);
   *)

procedure iooutfilename( pfilename: fsptr);
(* Return file name or domain:portnr of current output file. *)

procedure ioUniqueFileName(pfuncret: fsptr);
(* <uniqueFileName> (Creates and returns a file name, intended for
   temporary usage, that is guaranteed different from other temporary file names.
   Also, it is not saved on disk unless explicitly by <close ...>.
   Names are on format "tf#n", where n is a number. *)

procedure ioclose( pfilename,pasfilename: fsptr; var pinp: ioinptr);
(* Remove a file or socket from the file list. If outfile: write
   it to disk. If socket: send unsent characters. Release buffers.
   Implements <close filename>, <close domain:portnr>
   and <close filename[,asfilename]>. *)

procedure ioOpenFiles( pfuncret: fsptr);
(* Append line based list of open file names to pfuncret.
   Implements <openfiles>. *)

procedure iodelete( pfilename: fsptr; var pinp: ioinptr );
(* Delete a file from the files list (not from disk).
   Implements <delete filename>
   and <delete domain:portnr>. *)

procedure iorename( pfilename1,pfilename2: fsptr; var pinp: ioinptr );
(* Rename a file in the files list (not on disk).
   Implements <rename filename,filename>
   and <rename domain:portnr,filename>. *)

procedure iooutwrite( pch: CHAR; pinp: ioinptr );
(* Write output character. (pinp is used by updatesocketstate) *)

procedure iooutwritefs( pstr:fsptr; pinp: ioinptr ); (* Write output string. *)

procedure iochecksbuf;
(* Check if <out> is a socket or a serial port,
   if so send content of sendbuf to socket or serial port.
   Typical usage (at end of alwrite): iochecksbuf;
*)

procedure iosenddata;
(* Send all unsent socket data.
   Used by alsleep and ioingetinput so that output is not delayed. *)

function ionewfs(ps: string): fsptr; (* Create fs from a string. *)
(* Note: This function must not be used often since it causes memory
   leakage each time it is used (unless the resulting fs is disposed). *)

function ioptrtostr( pinp: ioinptr ): string;
(* Convert pinp^ up to eofs or eofr or max 40 char's
   to a string. *)

function ioptrtostr400( pinp: ioinptr ): string;
(* Convert pinp^ up to eofs or eofr or max 400 char's
   to a string. *)

procedure iodostoiso( var pch: CHAR );
(* Convert from DOS-ascii to ISO-ASCII (ISO8859-1). *)

procedure ioMessageBox( ps: string );
(* Show a message box (with ok button), or
   send string to output window, if threads are used. *)

procedure ioErrmessCompile( ps: string );
(* Show an error message box (with ok button), or
   send string to output window, if threads are used. *)

procedure ioErrmessWithDebugInfo( ps: string );
(* Add debug info to the string. Then show an error message box (with ok button),
   or send string to output window, if threads are used. *)

procedure iomessage( pcaption,ps: string );
(* Like ioerrmess except it enables specifying caption also.
   Show an error message box (with ok button), or
   send string to output window, if threads are used. *)

procedure iodebugmess( ps: string );
(* Show a debug message (to a memo box?). *)

procedure ioreadln( ps: fsptr );
(* Read a line using a pop-up window. *)

procedure iocleanup( var pinp: ioinptr );
(* Delete all files and sockets and reset winsock. *)

procedure ioinfo(pfilename: fsptr; pendch: char; var pfuncret: fsptr);
(* Print information about a file or a socket. *)

procedure ioenableOtherThreads(pid: integer);
procedure iodisableOtherthreads(pid: integer);
(* These two functions shall always be called around any system call
   which involves waiting. pid is used in error message if
   ioenableotherthreads finds that ioxlock has not been acquired. *)
   
function ioOtherThreadsEnabled: boolean;

procedure ioEnableAndSleep(milliseconds: Cardinal );
(* Flush buffers, enable other threads, and go to sleep for milliseconds. *)

procedure ioSimpleSleep(milliseconds: Cardinal );
// Sleep without releasing x

procedure ioEnterThread(var pinp: ioinptr);
(* IO functions to be performed after entering a thread. *)

procedure ioLeaveThread(var pinp: ioinptr);
(* IO functions to be performed before leaving a thread. *)

procedure iotest;

procedure iogetindata(var punrbottom: ioinptr);
(* Return unrbottom (used by xcallstate for checks). *)

function iogetinfilenr: integer;
(* Return current input file number. *)

function iogetinfileptr: Pointer;
(* Return pointer to current input file record. *)

procedure ioStepUnreadCounter(pFileRecPtr: Pointer; pStep: integer);
(* Step unread string counter up (1) or down (-1). *)

function ioInfileBinary: boolean;
(* Return true if current input file is binary. *)

function iogetoutfilenr: integer;
(* Return current output file number. *)

procedure ioinwithfilenr( pfilenr: integer; var pinp: ioinptr );
(* Restore to existing input file with nr = pfilenr.
   ioinwithfilenr is written after model from ioin (beginning of).
   ioinwithfilenr is used to restore input when input has changed in a
   function call, in a state call, or inside <localio ...> (and option
   persistent was not used). *)

procedure iooutwithfilenr( pfilenr: integer);
(* Restore to existing output file with nr = pfilenr. Return pfailure=true
   if file is not found.
   iooutwithfilenr is written after model from ioout (beginning of).
   iooutwithfilenr is used to restore output when output has changed in a
   function call, in a state call, or inside <localio ...> (and option
   persistent was not used). *)

function iogetfilename(pfilenr: integer):string;
(* Return the name of a file. *)


function ioexistfilenr(pfilenr: integer): boolean;
(* Whether a file still exists (still open). *)

procedure ioinnr(pfilenr:ioint32; var pStateEnv: xStateEnv);
(* Go to an already existing file with number pfilenr. *)

procedure iocheckexitstate(var pStateEnv: xStateEnv; pcinp0: ioinptr);
(* Do checks upon return from a state.
   If preaction contained unread, then cinp shall be unchanged
   on exit. *)

procedure iomarkeoffiles(var pstateenv: xstateenv);
(* Set a flag in all files where cinp or saveinp^ = eof.
   Used by ioin to give warning message when the same file is
   opened again, now positioned at the end. *)

function ioinreadable(pinp: ioinptr): boolean;
(* Return true if possible to read more data from current input file.
   Used by <eofr> (aleofr). *)

function iogetfilenr(pfilename:string): integer;
(* Get file nr from file name, or 0 if file name is
   not the name of an existing file.  *)

procedure iobacklines(plines: integer;var pinp:ioinptr);
(* Go plines lines back in current input file, if possible. *)

function iogetlinesbefore(pinp:ioinptr;plines: integer): string;
(* Get plines lines before pinp in current input file. *)

function iogetlinesafter(pinp:ioinptr;plines: integer): string;
(* Get plines lines after pinp in current input file. *)

procedure ioskipcomment( var pinp: ioinptr; plinecomment: boolean );
(* Pinp points at first character of possible comment (xskipcomment
   or xcommentasblank).
   E.g. '(' if pascal comments are to be removed.
   If it is comment, move pinp to after the comment. *)

procedure iocreateDirIfNecessary(pfilename: string);
(* Create new directory if pfilename contains a directory that does not exist. *)

procedure ioclearlocalfilenamecache;
(* Used by alload to clear memory of user choice to use local versions of
   x files. *)

procedure ioInNull(var pinp: ioinptr);
(* Restore current input file to none (used if in enterstring if infile became
   deleted). *)

procedure ioOutNull;
(* Restore current output file to none (used if in enterstring if outfile became
   deleted). *)

(* iolockcount
   -----------
   Used by <debuginfo ...>
*)
function iolockcount: integer;

(* Start winsock if it is not already started. *)
procedure ioStartWinsock;

procedure ioResetConsEof( var pstateenv: xstateenv );

// Log to x.log
procedure ioLog(pStr: string);

function ioUni2iso( pStr: string ): string;
(* Convert from Unicode to ISO-ASCII (ISO8859-1).
   As yet, limited to swedish characters.

   C384 = 'Ä' (C4)
   C385 = 'Å' (C5)
   C396 = 'Ö' (D6)
   C389 = 'É' (C9)

   C3A4 = 'ä' (E4)
   C3A5 = 'å' (E5)
   C3B6 = 'ö' (F6)
   C3A9 = 'é' (E9)

   $C0-$80 = $40 = 64
   $D0-$90 = $40 = 64
   $E0-$A0 = $40 = 64
   $F0-$B0 = $40 = 64

   =>   Add 64 to char 2 to get Iso Latin-1.
   Tillåt ej tecken över 252 (motsv UTF8 188 = $BC).
   *)


function ioIso2Uni( pStr: string ): string;
   (* Convert from ISO-ASCII (ISO8859-1) to Unicode .
      As yet, limited to swedish characters.

      UTF8   ISO
      ----   ---
      C384 = 'Ä' (C4)
      C385 = 'Å' (C5)
      C396 = 'Ö' (D6)
      C389 = 'É' (C9)

      C3A4 = 'ä' (E4)
      C3A5 = 'å' (E5)
      C3B6 = 'ö' (F6)
      C3A9 = 'é' (E9)

      $C0-$80 = $40 = 64
      $D0-$90 = $40 = 64
      $E0-$A0 = $40 = 64
      $F0-$B0 = $40 = 64

      =>   If char > $7F, then replace with UTF escape char C3 + char - 64.
      *)


(****) IMPLEMENTATION (****)

USES xal, (* alflagga('D') *)
     xx,  (* xwritefs, xparsrecord *)
     xunr, (* unrinit *)
     xioform; (* iofreadln, iofWriteToWbuf, iofWritelnToWbuf. *)


CONST
iounrbuflen= 100000;
(* Old: iounrbuflen= 10000; *) (* Size of unread buffer. *)
//iobufsize=16384;         (* Size of blocks pointed at by filebuf and sendbuf. *)
iobufsize=1024; // Tradeoff between large files and efficient <replacewith ...>
//iobufsize=20; (only for debug)
iomaxcalllevel = 100;

// Blocktab: only for debug.
// blocktabsize = 5000;// ++
blocktabsize = 1;

(*
   Socket, serial port, circular buffer (initially):
   -------------------------------------------------

   |->|eofr|eofs|...|......|...|eobl|0|    *    |
   |                                       |
   |---------------------------------------|

   File (of two blocks):
      |...|...|...|...|......|...|eobl|0|    *    |
                                             |
   |-----------------------------------------|
   |
   |->|...|...|...|eofs|..................|...|...|
*)

TYPE

fileinfoptr = ^fileinforec;
fileinforec = record   (* Info about number of lines in each block of a file. *)
    line: ioint32;     (* Line number for first character in block. First line
                          in first block = 1. *)
    blockptr: ioinptr; (* Pointer to a block. *)
    next: fileinfoptr; (* Pointer to next info block in list (or nil). *)
    end;

filerecptr = ^filerec;
filerec = RECORD      (* Info about an input file,
                         an output file or an internet
                         socket. *)

      nr: ioint32;     (* 1... Sequential creation order number. Used to
                          identify a file when restoring input file in
                          xcallstate. (only pointer to filerecord is not
                          100% secure since a filerecord can be deleted and
                          reused). *)
      kind: (aconsole, (* This is the standard console. *)
             afile,    (* This is an input/output file (created
                         by <in filename,pos> or <out filename,pos>). *)
             asocket,  (* This is an internet socket
                         (created by <in domain:portnr> or
                         <out domain:portnr>). *)
             aserialport, (* This is a serial port (created by e.g.
                         <in com1:,(config)> or <out com2:,(config)>). *)
             acircularbuffer); (* This is a circular buffer port (created by e.g.
                         <in mybuf,circularbuffer>). After reaching the end of the
                         buffer, data is written to its beginning, however not
                         overwriting readpos. Last character is always followed by
                         eofr + eofs. *)


      filename: fsptr; (* "cons" or file name or domain:portnr *)

      binaryfile: Boolean; (* Kind=aconsole: -
                           Kind=afile,asocket,aserialPort:
                            Binary file (option "binary"):
                           Convert input from binary to hex
                           and convert output from hex to binary.
                           Kind=acircularbuffer: - *)
      filebufp: ioinptr; (* Kind=afile: Points the first
                            block of a list of blocks where
                            each block is iobufsize
                            bytes and the next link is in the
                            last 4 bytes. The 5th byte from the
                            end in last block is reserved for
                            an extra eofs guard. In non-last blocks
                            it contains number of free space 0-251 where
                            251 = >250. The sixth byte
                            from the end in all blocks except last
                            has an eobl character in it
                            (eobl=end of block). - (see also definition of eobl)
                            Kind=aconsole,asocket,aserialport,acircularbuffer:
                            Points at a circular buffer that contains the last
                            iobufsize characters received from the console or
                            internet socket or writing thread (circular buffer). *)

      // (These three are only for debugging:)
      blocktab: array[1..blocktabsize] of ioinptr;
      blocktablen: integer;

      errorfound: boolean; (* Error found by iocheckblockstructure. *)


      fileinfo: fileinfoptr; (* Kind= afile:
                                  nil=   File info not yet created.
                                  <>nil= pointer to linked list of information
                                         blocks (used by iolinenr).
                                Kind= aconsole,asocket,aserialport
                                  ,acirculcarbuffer: - *)

      inpsave: ioinptr; (* Kind= aconsole, afile, asocket, aserialPort
                           or acircularbuffer:
                           Points at a character in filebuf
                           (or a linked outfile block).
                           Used to remember the address of
                           the next character to read, when
                           switching between input files. *)
      readpos: ioinptr; (* Kind=aconsole, afile, asocket, aserialPort or
                           acircularbuffer:
                           Points after the last consumed position which is
                           at the end of the last fully executed ?"..."?.
                           Set by ioinsetreadpos when current input pointer is
                           in the file (not in unread buffer).
                           Kind=asocket or aserialport: Used when reading new data
                           to avoid that data accessed by <p n> is overwritten.
                           Amount of new data entered into the buffer shall be
                           adjusted so that readpos is not overwritten by
                           new data. *)
      readrescnt: integer; (* All kinds (but meaningful only in console, socket,
                              serialport and circularbuffer): >1 => ioinReserveReadpos
                              will not advance readpos. Used to prevent <p n>
                              from being overwritten when called states read
                              from the same file. *)
      unrendptr: ioinptr; (* Kind=aconsole, afile, asocket, aserialPort or
                             acircularbuffer:
                             If pinp in unread buffer: Just after last unread
                             character in unread buffer. Where to jump from
                             when leaving unread buffer. (pinp=pinp+1; if pinp
                             =unrendptr then pinp:= unrbranchptr). *)
      unrbranchptr: ioinptr; (* Kind=aconsole, afile, asocket, aserialPort or
                                acircularbuffer:
                                If <>nil: Where to jump when leaving unread
                                buffer*)

// New unread (may 2018):
      unreadCount: integer; (* Number of stored unread strings for this
                              file. Used by unrCheckRelease. *)

      outp: ioinptr;    (* Kind=aconsole, acircularbuffer: -
                           Kind=afile: Points at where to
                           write the next character (in filebuf).
                           Kind=asocket, aserialport: Points at first free
                           position in send buffer (which is
                           where to put the next output charac-
                           ter). *)
      outpsave: ioinptr;   (* Kind=aconsole, acircularbuffer: -
                           Kind=afile: Points at eofr or eofs (end of file)
                           when outp does not. Used to calculate the payload size
                           of the last block when a file is written to disk.
                           Kind=asocket, aserialport: - (?) *)
      filebufend: ioinptr; (* Kind=afile: Points 6 bytes before
                              the end of the last buffer. Filebufend^
                              shall always be eofs.
                              Kind=aconsole, asocket, aserialport,
                              acircularbuffer: Points 6 bytes before
                              the end of the (only) buffer.
                              Kind=afile: (filebufend+2)^ holds a four byte
                              address to next block
                              Kind=aconsole, asocket, aserialPort or acircularbuffer:
                              (filebufend+2)^ holds a four byte address to the
                              beginning of the same buffer. *)
      addedCrPtr: ioinptr; (* Kind=afile: If the file was first opened with <in ...>
                              (by reading a file from disk), and an extra CR then
                              was added to the file to simplify scanning, then
                              this pointer points at the added CR. This is used
                              to avoid writing the added CR if the same file
                              is later opened with <out ...> and written back
                              to disk. *)
      endp: ioinptr;       (* Kind=afile: Points at eofs or eofr (end of file).
                              Kind=aconsole, asocket, aserialport or
                              acircularbuffer: Points at eofr (end of data).
                              Used to identify false eofs or eofr caused by
                              binary characters in the data.
                              Note:!! Endp appears not to be used (search for "endp")
                              - can be removed? Or shall it replace outpsave which
                              has almost the same meaning? *)
      usedforoutput: boolean; (* Kind=aconsole: -
                               Kind=afile: has been accessed with ioout.
                              Kind=asocket, aserialPort, acircularbuffer: - *)
      inthreadnr: alint16; (* Kind = afile: -1 = no thread using it for input.
                                           0 = main thread using it for input.
                                           1.. = nr of thread using it for input.
                             Only one thread can use it for input at one time. *)
      outthreadnr: alint16; (* Kind = afile: -1 = no thread using it for output.
                                           0 = main thread using it for output.
                                           1.. = nr of thread using it for output.
                             Only one thread can use it for output at one time.
                             If eofr is found and outthread <> althreadnr, then
                             we will wait for more output, else regard as eof. *)
      writeEvent: THandle; (* Kind=afile or acircularport: 0 = No event has
                              been created yet. >0 = Handle to win32 event which
                              can be used to synchronize reading thread to
                              writing thread in the same file. Reading thread
                              does: waitForSingleObject(writeEvent,INFINITE);
                              Writing thread does: SetEvent(writeEvent).
                              Kind=aconsole, asocket, aserialport: -. *)
      DataRequest: boolean; (* Kind=afile or acircularbuffer: True = There
                               is a thread which requests more data and waits
                               for writeevent.
                               ioingetinput sets this variable to true before
                               waiting for the writeevent. iooutwritefs and iooutwrite
                               will set the writeevent if there is a datarequest,
                               and then remove the request (datarequest:= false).
                               socketSupervisionThread will only attempt to
                               receive more data if there is a datarequest. It too
                               resets the request after having added more data.
                               Kind= aconsole, asocket or aserialport: -. *)
      refcount: integer;    (* Kind=afile, aconsole, asocket,aserialPort or
                               acircularbuffer: Number of references (curoutfilep
                               or curinfilep) to this file. Used to avoid
                               deletion of a file which is still referenced by
                               another thread. *)
      eofatentry: boolean;  (* Kind=afile: Input pointer pointed at eof when
                               x program was entered (before xevaluate in
                               xsendto). Used to warn when same file is
                               read again but without resetting it.
                               kind= aconsole, asocket, aserialport or
                               acircularbuffer: - *)

      sockhand: Tsocket;  (* Kind=asocket: Socket handle. *)

      socketstate:                (* Kind=asocket: State of sockhand: *)
                    (disconnected, (* Disconnected by other side while reading
                                     data (inptr^=eofs). *)
                    unbound,     (* Just a fresh socket (or a socket that was
                                    earlier disconnected). *)
                    connectedAsClient, (* Connected as client. *)
                    listening,    (* Acting as server but yet without a client. *)
                    connectedAsServer,  (* Connected as server (by listen
                                           and accept). *)
                    connectionError (* Error code was returned from winsock. *)
                    );

      preferredRole: ioprefroles; (* Kind=asocket: See ioprefroles. *)
      prevWasCR: boolean; (* Kind=asocket: The last char from the previous
         call to recv was CR. Used to remove next char if it is LF. *)

      sendbufp: ioinptr;  (* Kind=asocket or aserialPort: Points at a buffer
                             with size=iobufsize. Contains
                             characters not having been sent
                             yet. Else: - *)
      sendbufend: ioinptr; (* Kind= asocket or aserialPort: Points at the last byte
                              in sendbuf. Else: - *)
      lastConTime: TDateTime; (* Kind=asocket:
                              Last time when connect(...) was attempted.
                              Used to discard connect(...) more often than
                              once per 10 seconds because it delays (about
                              1 second).
                              Else: - *)
      comHand: Thandle;    (* Kind=aSerialPort: Serial port device handle.
                              Else: -. *)
      comCreateRetries: integer; (* Kind=aSerialPort: 0-9 = Number of retries
                              when calling createfile. -1 = unspecified
                              number of retries (use default). *)
      next: filerecptr;    (* All kinds: Points at the next file in a
                              list starting with files^. *)
      // ++ Debug info
      recvcount: integer;

      end; (*filerec*)

type commentstatetype= (normal,leftpar,comment,star);

const MaxLoadDepth=10;


type
fileofByte = file of byte;
filePtrType = ^fileofbyte;

var
xfile: ARRAY [0..MaxLoadDepth] OF file of byte; // (0 = no file open)
xfilecomstate: array[1..MaxLoadDepth] of commentStateType;
xfileTextCnt: array[1..MaxLoadDepth] of integer;
filesopen: ioint16 = 0;

consfs: fsptr = NIL;
consfilep: filerecptr; (* Pointer to the "cons" file record. *)
nullInFilep: filerecptr; (* Pointer to the null in file record.
   Used when closing the current input file to prevent
   curinfilep to become nil. *)

eofs: char;              (* = char(fseofs) (=255). *)
eofr: char;              (* = char(ioeofr) (=254). *)
eobl: char;              (* = char(ioeobl) (=253). *)
eoblfillptr: char;          (* = char(ioeoblfillptr) (=252). *)

files: filerecptr = NIL; (* List of console, files, and sockets. *)

threadvar
curinfilep: filerecptr;  (* Pointer to Current input file record. *)
curoutfilep: filerecptr; (* <>nil: Pointer to current output file record.
                            =nil: Current output file is undefined. *)

var

wsaData: TWSAData; (* From wsastartup (contents not used). *)
wsstarted: boolean = false; (* Winsock is not started unless there is
                       an attempt to connect input or output
                       to an internet socket. *)

(* Unr push and pop stack: *)
const unrstacksize = 100;
threadvar
unrstack: array[1..unrstacksize] of record
  inp: ioinptr;
  stateCallLevel: integer;
  oldInFilep: filerecptr; // Pop must be done with the same file as push.
  end;
unrstacktop: 0..unrstacksize;

(*
   Combined unread and pnStack buffer:
   -----------------------------------
   unrbufend ->         higher addresses
                  -------------------------
                  |                       |
                  |   Unread data         |
                  |                       |
                  |                       |
   unrBottom ->   |                       |
                  -------------------------
                  |                       |
                  |  Free space           |
                  |                       |
                  |                       |
   pnStack ->     |                       |
                  -------------------------
                  |                       |
                  |   PnStack             |
                  |                       |
                  |                       |
                  |                       |
   unrBufp ->     -------------------------
                        lower addresses
*)
var (* (should be threadvar? *)
unrbufp: ioinptr = nil;       (* Pointer to unread buffer. Last position is
                                 is reserved for an eofs character. *)
unrbufend: ioinptr = nil;     (* Points after last usable char in unrbufp^,
                                 (unrbufend = @unrbufp^[iounrbuflen]). *)
unrbottom: ioinptr = nil;     (* Marks bottom of reserved unread data. Unread
   data grows from unrbufend towards lower addresses when <unread ...> or
   <in ...,string> is used. unrBottom is the lowest address currently reserved
   for unread data. It is used for two purposes. One is to check that the pn
   stack (which grows from unrbufp towards unrbufend) does not overwrite unread
   data. The other is to enable called states which takes input from another file
   to use the unread funktion. Example: state s1 takes input from file f1 and
   unreads the string "abcdefg". Before the unread string has been consumed,
   state s2 is called which takes input from file f2 and unreads the string
   "123456". The string "123456" is now put below unrbottom, to avoid it from
   overwriting "abcdefg". S2 saves address after "g" as where to leave the
   unread buffer in unrendptr. When it reaches this position, it jumps to
   unrbranchptr. s1 has its input position save in inpsave, so when control is
   returned to s1, it will continue to read from where it was in the unread
   buffer. It too has an unrendptr which tells it when to leave the unread
   buffer and jump to unrbranchptr. How is unrbottom updated? After unread:
   unrbottom is set to the address of the first character in the unread string.
   When input file is changed: If input pointer is in the unread buffer, then
   unrbottom is set to the input pointer. If there is unread from the new input
   file, this string will end just below unrbottom, and unrbottom is again set
   to the first character in the unread string. When input is changed back to
   the first file, and a new unread is done, unrbottom is again set to the first
   character in the unread string. This means that if the second file has not
   returned from the unread buffer before input is change back to the first
   file, the second unread buffer may be overwritten by subsequent unread from
   the first file. This means that if unread is done in more than one input file
   this must be done in a hierachical manner - the second file is "called" from
   the first and shall finish its use of the unread buffer before "returning"
   to the first file. When returning from unread buffer: Unrbottom is set to
   unrendptr otherwise unread buffer will grow for every unread (still there is
   a risk since ioinforward can be done on a local pointer while the real input
   pointer remains in the unread buffer. Checking of unread buffer: If there is
   unread in the preaction of a called state, then it is assumed that the called
   state shall work on the unread buffer. Therefore it is checked after
   returning from the state, that the input pointer is at the same place is it
   where when the state was entered. No such checks are today done for
   preactions in states which are jumped to. Conflict with <unread> function:
   <unread>  moves the pointer to the beginning of the previous ?"..."? string.
   But if this string is in the unread buffer, and <in ...,string,local> is
   called before <unread>, "...(eof)" will be written at the end of the ?"..."?
   string, since <in ...,string,local> also uses the unread buffer. Solution:
   Let <unread> do <unread <p 0>> instead, if <p n> parameters have been stored
   in the pnstack (meaning they otherwise may become invalid). *)

                              (* pnstack: An area in the beginning of the unread
                                 buffer, which is used to save <p n> data located
                                 in the unread buffer, since these could otherwise
                                 be overwritten by subsequent unreads.
                                 Pnstack starts at the first position of unrbuf
                                 and grows upward, but must not grow higher
                                 than unrbottom, because it would then overwrite
                                 unread data. When pnstack is used, the atp and
                                 afterp pointers are changed to point into the
                                 new positions in the pnstack. *)

pnstacktop: ioinptr = nil;    (* Next position where to write <p n> data
                                 to be saved. *)
pnstack: array[1..iomaxcalllevel] of ioinptr;
                              (* Stacktops saved so stack can be poped when
                                 data is not longer needed. <p n> data is
                                 saved when ever a state is called (<c ...>).
                                 Pnstack is poped whenever returning from a
                                 state. Note that <unread ...> which is not
                                 in the preaction of a called state, can still
                                 overwrite <p n> data. *)
pnsl: ioint16 = 0;            (* Pn stack level - the index in pnstack where
                                 to find the value that pnstacktop shall be
                                 set to, after returning from the current
                                 called state. Initially pnsl is 0, since
                                 no state has yet been called. *)

(* What is this? unrendptr is also found in the filerecord. Is this an old
   variable that should be removed?/BFn 2012-06-06. *)
(* unrendptr: ioinptr = nil; *)    (* If <>nil: Pointer to last character in unread
                                 buffer which contains data for this file.
                                 Used by ioinforward: if pinp=unrendptr then
                                 pinp:= unrbranchptr. *)

(* for file nr: *)
CreatedFilesCount: integer = 0;  (* Number of created files. Only counts up.
                                    Used to give each file a unique id nr. This
                                    number is used to identify files
                                    for some checking purposes. *)
ExistingFilesCount: integer = 0;  (* Number of existing files (in the files list).
                                    Used by iocleanup to check if all files were
                                    deleted. *)
var
readcount: integer = maxint; (* Updated (decremented) by ioinforward, used by ioingetinput
                           to close input when there is no activity. *)

var
localFilenameCache: tstringlist; (* Used by ioxreset to remember when
   user chose to select a local version of an x file. *)
localFileNameSelection: (onebyone,yestoall,notoall) = onebyone;

const
UniqueFileNameTabSize = 1000;
var
uniqueFileNameTab: array[1..uniqueFileNameTabSize] of boolean; // True = name in use

function kindToString(pFilep: filerecptr): string;
begin
case pfilep^.kind of
   aconsole: kindToString:= 'aconsole';
   afile: kindToString:= 'afile';
   asocket: kindToString:= 'asocket';
   aserialport: kindToString:= 'aserialport';
   acircularbuffer: kindToString:= 'acircularbuffer';
   end;
end; (* kindToString *)

function socketStateToString(pfilep: filerecptr): string;
begin
case pfilep^.socketstate of
   disconnected: socketStateToString:= 'disconnected';
   unbound: socketStateToString:= 'unbound';
   connectedasclient: socketStateToString:= 'connectedAsClient';
   listening: socketStateToString:= 'listening';
   connectedasserver: socketStateToString:= 'connectedAsServer';
   connectionError: socketStateToString:= 'connectionError';
   end;
end; (*socketStateToString*)


(* Only for debugging: *)
procedure iocheckblockstructure( pfrp: filerecptr );
var bufptr,ptr: ioinptr; size: integer; error: boolean; blockcnt: integer;
saveblockix,blockix: integer;
procedure fail(pstr: string);
var str: string;
begin
   str:= pstr + 'Block nr = ' + inttostr(blockcnt) + '. Offset = ' +
      inttostr(integer(ptr)-integer(bufptr)) + '.';
   xProgramError(str);
   error:= true;
   pfrp^.errorfound:= true;
end;
begin
error:= false; blockix:= 1; saveblockix:= 1;
with pfrp^ do begin
   bufptr:= filebufp;
   while not ((blocktab[blockix]=bufptr) or error) do begin
      blockix:= blockix+1;
      if (blockix=blocktablen+1) then blockix:= 1;
      if blockix=saveblockix then fail('iocheckblockstructure: Unidentified block (1).');
      end;
   saveblockix:= blockix;
   blockcnt:= 1;
   while (bufptr<>nil) and not error do begin
      // Read one block.
      ptr:= bufptr;
      size:= 0;
      while (ptr^<>eobl) and (ptr^<>eofs) and not error do begin
         ptr:= ioinptr(integer(ptr)+1);
         size:= size+1;
         if size>iobufsize-6 then fail('iocheckblockstructure: Too large size.');
         end;

      if (ptr^=eobl) and not error then begin
         // End of block - pass any free space
         while (integer(ptr)< integer(integer(bufptr)+iobufsize-6)) and not error do begin
            ptr:= ioinptr(integer(ptr)+1);
            if ptr^=eoblfillptr then ptr:= ioinptrptr(ioint32(ptr)+1)^
            else if ptr^<>eobl then
               fail('iocheckblockstructure: eobl or eoblfillptr was expected but "'+
                  ptr^+'" was found.');
            end;
         if (integer(ptr)<>integer(integer(bufptr)+iobufsize-6)) and not error then
            fail('iocheckblockstructure: ptr at iobufsize-6 was expected (1).');

         (* Move to next block. *)
         bufptr:= ioinptrptr(ioint32(ptr)+2)^;

         (* Identify new block. *)
         saveblockix:= blockix;
         while not ((blocktab[blockix]=bufptr) or error) do begin
            blockix:= blockix+1;
            if (blockix=blocktablen+1) then blockix:= 1;
            if blockix=saveblockix then fail('iocheckblockstructure: Unidentified block.');
            end;
         blockcnt:= blockcnt+1;
         end
      else begin
         // End of file
         if ptr^=eofs then bufptr:= nil;
         end;
      end; (* while *)

      if blockcnt<>blocktablen then fail('iocheckblockstructure: Wrong block count.');
   end; (* with *)

end; (* iocheckblockstructure *)


var lastblockcnt: integer = 0; // debugging

(* Only for debug: *)
procedure checkcinp( pfrp: filerecptr; pcinp: ioinptr );
(* Check that pcinp is within the blocks of a file. *)
var bufptr: ioinptr; found: boolean;
blockix: integer; cinp: integer;
procedure fail(pstr: string);
var str: string;
begin
   str:= pstr;
   xProgramError(str);
   pfrp^.errorfound:= true;
end;
begin
with pfrp^ do begin
   bufptr:= filebufp;
   blockix:= 1;
   found:= false;
   cinp:= integer(pcinp);
   while not ((blockix>blocktablen) or found) do begin
      if (cinp>=integer(bufptr)) and (cinp<(integer(bufptr)+14)) then found:= true
      else begin
         blockix:= blockix+1;
         bufptr:= blocktab[blockix];
         end;
      end;

   if found then
      lastblockcnt:= blockix
   else
      fail('checkcinp: cinp is not inside the blocks of the file (last blockix = '+
      inttostr(lastblockcnt)+'.');
   end; (* with *)

end; (* checkcinp *)

procedure iocheckcinp(var pstateenv: xstateenv );
begin
// checkcinp(curinfilep,pstateenv.cinp);
end;


// ++
function ioSerialBufferInfo(pcinp: ioinptr): string;
var s: string;
fptr: fileRecPtr;
found: boolean;
ptr,endPtr: ioinptr;
cnt: integer;

begin

fptr:= files;
found:= false;

while not found do begin
   if fptr=nil then found:= true
   else if (fptr^.kind=aSerialPort)
      // and (fstostr(fptr^.filename)='com3:')
    then found:= true
   else fptr:= fptr^.next;
   end;

if fptr<>NIL then with fptr^ do begin
   s:= '++ ioserialBufferInfo: '+char(13);
   s:= s+'   '+'filename='+fstostr(filename)+ char(13);
   s:= s+'   '+'cinp='+inttostr(integer(pcinp))+ char(13);
   s:= s+'   '+'filebufp='+inttostr(integer(filebufp))+ char(13);
   s:= s+'   '+'filebufend='+inttostr(integer(filebufend))+ char(13);
   s:= s+'   '+'inpsave='+inttostr(integer(inpsave))+ char(13);
   s:= s+'   '+'readpos='+inttostr(integer(readpos))+ char(13);
   s:= s+'   '+'outp='+inttostr(integer(outp))+ char(13);
   s:= s+'   '+'outpsave='+inttostr(integer(outpsave))+ char(13);
   s:= s+'   '+'usedforoutput='+inttostr(integer(usedforoutput))+ char(13);

   s:= s+'   '+'buffer="'+char(13)+'   ';
   ptr:= fptr^.filebufp;
   endPtr:= ioinPtr(integer(filebufend)+6);
   cnt:= 0;
   while integer(ptr)<integer(endPtr) do begin
      if (integer(ptr^)<integer(' ')) or (integer(ptr^)>126) then s:= s+'('+inttostr(integer(ptr^))+')'
      else s:= s+Ptr^;
      
      cnt:= cnt+1;
      if cnt>=64 then begin
         s:= s+char(13)+'   ';
         cnt:= 0;
         end;
      ptr:= ioinptr(integer(ptr)+1);
      end;
   s:= s+'"'+char(13);

   iofWritelnToWbuf(s);
   end
else iofWritelnToWbuf('++ ioserialbufferinfo: Found no serial port.');

end;


procedure ioclosefilerec( pfrp: filerecptr; var pinp: ioinptr); forward;


type addrptr=^ioinptr;

function iomakefile(pfilename: fsptr; pendch: char; pbinary: boolean;
    pfilebufp: ioinptr; plastbufp: ioinptr; pendp: ioinptr; pout: boolean;
    pCrPtr: ioinptr)
    : filerecptr; forward;
(* Create a file record. pfilebufp shall point at a ready made buffer or
   chain of buffers. Used by ioin and ioout. Examples:
      frp:= iomakefile(pfilename,pendch,pbinary,bufp1,bufp,false,crPtr);
   *)

procedure initoldnametab; forward;

procedure initxfilecache; forward;

// iosendsbuf recursive call counter
var sbfcallcnt: integer = 0;

procedure ioinit( var pinp: ioinptr );
(***************)
(* Initialisation *)

var ior: ioint16; inp: ioinptr; i: ioint16;
frp: filerecptr;
cnt: integer; ptr: ioinptr;
p: ioinptr;
addrp: addrptr;
newBufp,newBufEnd: ioinptr;

begin

(* Dont close open x files. filesopen:= 0; *)

initxfilecache;

eofs:= char(fseofs);
eofr:= char(ioeofr);
eobl:= char(ioeobl);
eoblfillptr:= char(ioeoblfillptr);

if files<>nil then xProgramError('X(ioinit): Program error. Files<>nil.');

(* Clean up winsocket if it has been used. *)
if wsstarted then begin
    i:= wsacleanup;
    wsstarted:= false;
    end;

(* Create and initialise a file record for the console. *)

if consfs=NIL then consfs:= ionewfs('cons');

(* Init console buffer: *)
GetMem(newBufp,iobufsize);
newBufp^:=eofr;
pinp:= newBufp;
inp:= ioinptr( ioint32(pinp)+1);
inp^:=eofs; (* (Add eofs as an extra guard) *)
newBufEnd:= ioinptr( ioint32(newBufp) + iobufsize -6);
(* No free space in consbuf because it is a circular buffer. *)
ioinptr( ioint32(newBufEnd) +1)^:= char(0);
newBufEnd^:= eobl;
(* Let next pointer point at the same block to enable
   ioinforward to function. *)
p:= ioinptr( ioint32(newBufEnd) + 2);
addrp:= addrptr(p);
addrp^:= newBufp;

CreatedFilesCount:= 0;
ExistingfilesCount:= 0;
consfilep:= iomakefile(ionewfs('cons'),eofs,false
  ,newBufp,newBufp,newBufp,false,nil);

curinfilep:= consfilep;
curoutfilep:= consfilep;
curoutfilep^.outthreadnr:= althreadnr;
curoutfilep^.inthreadnr:= althreadnr;
curoutfilep^.refcount:= 2;

(* Create a null infile to be used when closing current input file: *)
(* allocate at one block. *)
GetMem(newBufp,iobufsize);

(* Initialize last 6 bytes of new buffer. *)
p:= ioinptr( ioint32(newBufp) + iobufsize - 6);
p^:= eofs;
p:= ioinptr(ioint32(p) + 1);
p^:= eofs;
p:= ioinptr(ioint32(p) + 1);
addrp:= addrptr(p);
addrp^:= nil;

(* Append eofs. *)
newBufp^:= eofs;

nullinfilep:= iomakefile(ionewfs(''),eofs,false
  ,newBufp,newBufp,newBufp,false,nil);

xoptcr:= ' ';
xoptcr2:= ' ';

ioemptylines:= 0;

if ioxlock=nil then ioxlock:= syncobjs.Tcriticalsection.create;
//windows.
initializeCriticalSection(critSectX);
lockcount:= -1;

(* Init unread buffer. *)
if unrbufp=nil then GetMem(unrbufp,iounrbuflen);
unrbufend:= ioinptr(ioint32(unrbufp)+iounrbuflen-1);
unrbufend^:=eofs;
unrbottom:= unrbufend;
pnstacktop:= unrbufp;
pnsl:= 0;

(* Init new unr buffer: *)
if xunr.active then xunr.unrinit;

iomsgboxtooutputwindow:= False;

initoldnametab;

if localFilenameCache=NIL then
   localFilenameCache:= tstringlist.create
else
   localfilenamecache.Clear;

// Recuresive call counter
sbfcallcnt:= 0;

end; (* ioinit *)


procedure ioEnterThread(var pinp: ioinptr);
(* IO functions to be performed after entering a thread. *)
begin
xoptcr:= ' ';
xoptcr2:= ' ';
curinfilep:= consfilep;
pinp:= curinfilep^.inpsave;
curinfilep^.inthreadnr:= althreadnr;
curinfilep^.refcount:= curinfilep^.refcount+1;

curoutfilep:= consfilep;
curoutfilep^.outthreadnr:= althreadnr;
curoutfilep^.refcount:= curoutfilep^.refcount+1;
unrstacktop:= 0;
end;

procedure ioLeaveThread(var pinp: ioinptr);
(* IO functions to be performed before leaving a thread. *)

begin
(* Current outfile:  *)
if curoutfilep<>nil then with curoutfilep^ do begin
  outthreadnr:= -1;
  (* Update reference count. *)
  refcount:= refcount-1;
  if refcount<0 then
  (***) xProgramError('X(ioleavethread): Refcount>=0 was expected but '+
   inttostr(refcount)+' was found.');
  end;

(* Current infile: *)
with curinfilep^ do begin
  inpsave:= pinp;
  inthreadnr:= -1;

  (* Update reference count. *)
  refcount:= refcount-1;
  end;

end; (*ioLeaveThread*)


// Data Payload - X-files added to the end of the x.exe file

(* Functions to add data to the end of the x.exe file.
   See http://www.delphidabbler.com/articles?article=7&part=2 *)
type TPayloadFooter = packed record
   WaterMark: TGUID;
   ExeSize: LongInt;
   DataSize: LongInt;
   end;

const cWaterMarkGUID: TGUID =
   // arbitrary watermark constant: must not be all-zeroes
   '{9FABA105-EDA8-45C3-89F4-369315A947EB}';

type
internalFilesRecord = record
   filename: string;
   startpos: integer; // Points at 1st char in file
   endPos: integer; // Points after last char in file
   savePos: integer; (* Used to restor current position (filepos(...))
      when returning from a loaded x file, with xclose. *)
   end;

const maxNinternalFiles = 30;

var

// Cache copies
currentFileIsInternal: integer; // = internalFileIndexTab[filesopen]
internalfileIndexTab: array[0..MaxLoadDepth] of integer;
xexeFile: File; (* Full path to the exe-file which is running (normally x.exe)
   Used to read internal files (see internal files further down. *)

currentXfilePtr: filePtrType; (* = @xfile[filesopen] or, if
   currentFileIsInternal!=0: @xexefile. *)
currentxFileeof: boolean; (* = eof(currentXfilePtr^) or, if
   currentFileIsInternal!=0: internalFilesTab[n].pos >=
   internalFilesTab[n].endpos, where n = currentFileIsInternal. *)

xexeFileName: string;
internalFilesAvailable: boolean = false;
internalFilesTab: array [1..maxNinternalfiles] of internalFilesrecord;
ninternalFiles: integer = 0;


procedure initxfilecache;
begin
// x file cache values
currentFileIsInternal:= internalFileIndexTab[filesopen];
if currentFileIsInternal>0 then currentXfilePtr:= @xexefile
else currentXfileptr:= @xfile[filesopen];

// currentXfileEof
if filesopen>0 then begin
   if currentFileIsInternal>0 then currentXfileEof:=
      filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
   else currentXfileEof:= eof(currentXfilePtr^);
   end
else currentxfileeof:= false;

end;


function ReadFooter(var F: File;
  out Footer: TPayloadFooter): Boolean;
var
  FileLen: Integer;
begin
   // iofwcons('++ ReadFooter');
   // Check that file is large enough for a footer
  FileLen := FileSize(F);
  if FileLen > SizeOf(Footer) then
  begin
    // Big enough: move to start of footer and read it
    Seek(F, FileLen - SizeOf(Footer));
    BlockRead(F, Footer, SizeOf(Footer));
    //(new: Calculating ExeSize from Filelen and DataSize)
    footer.ExeSize:= FileLen  - SizeOf(Footer) - footer.DataSize;
    // iofwcons('++ ReadFooter: FileLen='+inttostr(filelen)+', size of footer = ' +
    //   inttostr(sizeof(footer)) + ', datasize = ' + inttostr(footer.datasize) +
    //   '=> exesize = ' + inttostr(footer.exesize) + '.');
  end
  else
    // File not large enough for footer: zero it
    // .. this ensures watermark is invalid
    FillChar(Footer, SizeOf(Footer), 0);
  // Return if watermark is valid
  Result := IsEqualGUID(Footer.WaterMark, cWaterMarkGUID);
end;

const
// Untyped file open modes
cReadOnlyMode = 0;
cReadWriteMode = 2;


function PayloadSize: Integer;
var
  Footer: TPayloadFooter;
  ior: integer;
begin
  // assume no data
  Result := 0;
  // open file

  alOpenForRead(xexeFile,xexeFileName,ior);
  (* Open a file  with FileMode:= fmOpenRead + fmShareDenyNone.
     This allows opening a file that is already locked by another program.
  *)

  // (old:)PayloadOpen(cReadOnlyMode);
  try
    // read footer and if valid return data size
    if ReadFooter(xexeFile, Footer) then begin
         Result := Footer.DataSize;
         // iofwcons('++ payloadsize: footer found.');
         end
    else begin
       // iofwcons('++ footer not found.');
       end;
  finally
    CloseFile(xexeFile);
  end;
end;



procedure PayloadGet;
var Footer: TPayloadFooter;
ior: integer;
lineStrFs: fsptr;
lineStr,filenamestr,fileSizeStr,fileStr: string;
found,n: integer;
middlePos,endStrPos,fileSize: integer;

internal_f: file;
cnt: integer;

begin
   fsnew(lineStrFs);
   // open file as read only
   alOpenForRead(xexeFile,xexeFileName,ior);
   try
   // read footer
      if ReadFooter(xexeFile, Footer) and (Footer.DataSize > 0) then begin
         // move to end of exe code
         // iofwcons('++ payLoadGet: footer.exesize = ' + inttostr(footer.exesize) + '.');
         Seek(xexeFile, Footer.ExeSize);

         // Find beginning of file
         found:= 0;
         while not eof(xexeFile) do begin
            fsRewrite(lineStrFs);
            alReadLine(xexeFile,lineStrFs);
            lineStr:= alFsToStr(lineStrFs,eofs);
            if (leftStr(lineStr,21)= '--------------- File ') and
               (rightStr(lineStr,22)= ' bytes ---------------') then begin

               found:= found+1;

               // Find ': '
               middlePos:= ansiPos(': ',lineStr);

               // Get filename
               fileNameStr:= ansiMidStr(lineStr,22,middlePos-22);

               // Get filesize
               endStrPos:= length(lineStr)+1-22;
               fileSizeStr:= ansiMidStr(lineStr,middlePos+2,endStrPos-(middlePos+2));
               fileSize:= strToInt(fileSizeStr);

               ninternalFiles:= ninternalFiles+1;
               if ninternalFiles<=MaxNinternalFiles then begin
                  with internalFilesTab[ninternalFiles] do begin
                     fileName:= fileNameStr;
                     startPos:= filePos(xexeFile);
                     endpos:= startPos+fileSize;
                     end;
                  end;

               // Jump to next possible file
               seek(xexeFile,filepos(xexeFile)+filesize);

               end
            else begin
               // iofwcons('++ leftstr='+leftStr(lineStr,21)+', rightstr='+rightStr(lineStr,22)+'.');
               end;
            end;

         if ninternalFiles>maxNinternalFiles then
            xScriptError('*** payloadGet: While scanning x script files which were addet to the end of x.exe, X assumed that ' +
               inttostr(maxNinternalFiles) + ' would be sufficient for all scripts, but now it found ' +
               inttostr(ninternalFiles) + ' and is unable to register them all.');

         if found>0 then begin
            // iofwcons('++ PayloadGet: ' + inttostr(found) + ' file(s) found. Last was '+
            //   fileNameStr+' size '+ fileSizeStr+' bytes.');
            for n:= 1 to ninternalFiles do with internalFilesTab[n] do begin
               seek(xexeFile,startpos);
               setLength(fileStr,endpos-startpos);
               // iofwcons('++ payloadget: filename='+ filename+'filelen='+inttostr(endpos-startpos)+'.');
               blockread(xexeFile,fileStr[1],endpos-startpos);

               (* ++ Copy to temporary file for debug purposes.
               ( *$I-* )
               AssignFile(internal_f,'internal_'+filename);
               ior:= ioResult;
               if ior=0 then begin
                  rewrite(internal_f,1); ( * 1 byte record size * )
                  ior:= ioresult;
                  end;
               ( *$I+* )
               if ior = 0 then begin
                  // Time to write the data, of one buffer, to disk.
                  ( *$I-* )
                  BlockWrite(internal_f,fileStr[1],endpos-startpos,cnt);
                  ior:= ioResult;
                  if ior=0 then begin
                     ( * close file * )
                     closefile(internal_f);
                     ior:= IOResult;
                     if ior<>0 then iofwcons('++ PayLoadGet: closefile failed (ior='+
                        inttostr(ior)+'.');
                     end
                  else iofwcons('++ PayLoadGet: BlockWrite failed (ior='+
                     inttostr(ior)+'.');
                  ( *$I+* )
                  end
               else iofwcons('++ PayLoadGet: Assignfile/rewrite failed (ior='+
                  inttostr(ior)+'.');
               *)

               // iofwcons('++ PayloadGet: File ' + filename + ' = "' + fileStr + '".');
               end;
   			end
			else
            iofwcons('++ PayloadGet: No files were found.');
         end;
   finally
   end;
   fsdispose(lineStrFs);
end; (* payloadget *)


procedure ioxhandleinternalFiles;
var plsize: integer;
dataStr: string;
begin
xexeFileName:= paramStr(0);
plSize:= PayLoadSize;
internalFilesAvailable:= plSize>0;

if internalFilesAvailable then begin
   iofShowMess('handleinternalFiles: Footer found. Datasize = ' + inttostr(plSize) + '.');
   SetLength(DataStr, PayloadSize);
   PayloadGet;
   end;
// else iofShowMess('++ handleinternalFiles: Footer not found.');

end;

function ioInternalFile1: string;
(* Return name of first internal file (or '').
   Used by xtest to load the first internal file, if there are any. *)
begin
if nInternalfiles>0 then ioInternalFile1:= internalFilesTab[1].filename
else ioInternalFile1:= '';
end;


procedure ioxreset( pfilename: fsptr; pShortName: boolean; var perror: BOOLEAN );
(* Open x file while still keeping current x file (if any) open.
   Load from alworkingdir if possible (overrides dir used in filename).
   pshortname means that original filename (in alLoad) had no path.
   Example: "test1.x". Used when looking for internal files. *)

var ior1,ior2,ior3,ior: ioint16; ptr: fsptr;
filename: string;
fileModeSave: integer;
n: integer;
found: boolean;
shortname: string;

(* ÖPPNA X-FIL *)
begin (*ioxreset*)

if filesopen>=MaxLoadDepth then begin
   xCompileError2('X: Cannot open X-file '+fstostr(pfilename)
      +' - '+inttostr(filesopen)+'  files open already!');
   perror:= TRUE;
   end
else begin
   if currentFileIsInternal>0 then
      // Save position
      internalFilesTab[currentFileIsInternal].savepos:= filepos(currentXfilePtr^);

   filesopen:= filesopen+1;
   internalFileIndexTab[filesopen]:= 0;
   currentFileIsInternal:= 0;
   currentXfileptr:= @xfile[filesopen];

   (*$I-*) (* Turn off IO error exceptions. *)

   fileModeSave:= fileMode;
   fileMode:= fmOpenRead + fmShareDenyNone; (* (Allows opening a file that is
              already locked by another program) *)

   (* Close file just in case it was open. ioresult must be called
      after every io operation in case there was an error. *)
   closeFile(currentXfilePtr^);
   ior1:= ioresult;

   (* Try to find the file on the working directory first. *)
   ptr:= pfilename;
   fsforwend(ptr);
   while not ((ptr^='/') or (ptr^='\') or (ptr=pfilename)) do fsback(ptr);
   if (ptr^='/') or (ptr^='\') then fsforward(ptr);

   (* ptr now points at for example "test.x" *)
   shortname:= fstostr(ptr);
   filename:= alworkingdir + '\' + fstostr(ptr);

   assignFile(currentXfilePtr^,filename);
   ior2:= ioresult;

   reset(currentXfilePtr^);
   ior3:= ioresult;

   (* Check if a local version is available and the user really wants to use it
      instead of the nominal version. (Ask not if the user specifically
      chose a file at the working directory). *)
   if (ior3=0) and (ansicomparetext(filename,fstostr(pfilename))<>0) then begin
      (* Cash answers to avoid asking the same question again if user reloads
         with <load>. *)
      if localfilenameSelection=YesToAll then
         (* Use local, dont ask. *)
      else if localfilenameSelection=NoToAll then
         (* Use original, dont ask. *)
         ior3:= 1
      else if localfilenamecache.values[filename]='no' then
         (* Use original, dont ask. *)
         ior3:= 1
      else if localfilenamecache.values[filename]='yes' then
         (* Use local, dont ask. *)

      else if althreadnr<>0 then begin
         (* Cannot use messageDlg because it is not thread safe. *)
         iofWritelnToWbuf(' ++ Wanted to ask about using local script '+filename+
            ' but was unable to do so because a thread is running and '+
            ' messageDlg which is used for this purpose is not threadsafe.'+
            ' Assumes answer="yes" instead.');
         localfilenamecache.values[filename]:= 'yes';
         end
      else case MessageDlg('X(ioxreset): Do you want to use the local version of '+
         fstostr(ptr)+'? (Answer yes if you are working with the Xscript on your local catalog.)',
         mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll], 0) of
         mrNo: begin
            (* Revert to original filename. *)
            ior3:= 1;
            localfilenamecache.values[filename]:= 'no';
            end;
         mrYes:
            localfilenamecache.values[filename]:= 'yes';
         mrYesToAll:
            localfilenameSelection:= YesToAll;
         mrNoToAll: begin
            localfilenameSelection:= NoToAll;
            (* Revert to original filename. *)
            ior3:= 1;
            localfilenamecache.values[filename]:= 'no';
            end;
         end; (*case*)
      if (ior3<>0) then closeFile(currentXfilePtr^);

      end; (* Found the file on users working dir. *)

   (* If file not found: Try original filename *)
   if ior3<>0 then begin
      filename:= fstostr(pfilename);

      assignFile(currentXfilePtr^,filename);
      ior2:= ioresult;

      reset(currentXfilePtr^);
      ior3:= ioresult;
      end;

   (* If file not found: Try internal files *)
   if pshortname and (nInternalFiles>0) and ((ior2<>0) or (ior3<>0)) then begin
      // iofwcons('++ ioxreset(' + shortname + '): looking for internal file.');
      n:= 1;
      found:= false;
      while (n<=nInternalFiles) and not found do begin
         // iofwcons('++ ioxreset: Comparing "'+ internalFilesTab[n].filename +
         //    '" with "' + shortname +  '".');
         if ansicomparetext(internalFilesTab[n].filename,shortname)=0 then
            found:= true
         else n:= n+1;
         end; // (while)
      if found then begin
         // iofwcons('++ ioxreset(' + shortname +
         //    '): Internal file found = ' + inttostr(n) + '.');
         internalFileIndexTab[filesopen]:= n;
         currentFileIsInternal:= n;
         currentXfilePtr:= @xexefile;
         with internalFilesTab[n] do seek(currentxFilePtr^,startpos);
         ior2:= 0;
         ior3:= 0;
         end;
      end;

   (*$I+*)

   (* Ignore close error but recognize assign and open errors. *)
   if ior2<>0 then ior:= ior2
   else ior:= ior3;

   perror:= (ior<>0);

   if perror then begin
      xCompileError2('X (ioxreset): Unable to open X-file "'
         +filename+'" (Error code '+inttostr(ior)
             +'="'+SysErrorMessage(ior)+'").');
      filesopen:= filesopen-1;
      currentFileIsInternal:= internalFileIndexTab[filesopen];
      if currentFileIsInternal>0 then currentXfilePtr:= @xexefile
      else currentXfileptr:= @xfile[filesopen];
      end;

   // Update cache
   // currentXfileEof
   if filesopen>0 then begin
      if currentFileIsInternal>0 then currentXfileEof:=
         filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
      else currentXfileEof:= eof(currentXfilePtr^);
      end
   else currentxfileeof:= false;

   // Restore filemode
   fileMode:= fileModeSave;

   end; (* not too many files *)

end; (*ioxreset*)

procedure ioclearlocalfilenamecachedummy;
(* Used by alload to clear memory of user choice to use local versions of
   x files. *)
begin
localfilenamecache.Clear;
localfilenameSelection:= onebyone;
end;


procedure ioclearlocalfilenamecache;
(* Used by alload to clear memory of user choice to use local versions of
   x files. *)
begin
localfilenamecache.Clear;
localfilenameSelection:= onebyone;
ioclearlocalfilenamecachedummy;
end;



procedure ioxclose;
begin

if not (filesopen in [1..MaxLoadDepth]) then xProgramError(
   'X: Program error found in ioxclose - filesopen = '
     +inttostr(filesopen))

else begin

   if currentFileIsInternal=0 then close(currentXfilePtr^)
   else internalFileIndexTab[filesOpen]:= 0;

   filesopen:= filesopen-1;

   // Update file cache variables
   currentFileIsInternal:= internalFileIndexTab[filesopen];

   if currentFileIsInternal>0 then begin
      currentXfilePtr:= @xexefile;
      seek(currentXfilePtr^,internalFilesTab[currentFileIsInternal].savePos);
      end

   else currentXfileptr:= @xfile[filesopen];

   // currentXfileEof
   if filesopen>0 then begin
      if currentFileIsInternal>0 then currentXfileEof:=
         filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
      else currentXfileEof:= eof(currentXfilePtr^);
      end
   else currentxfileeof:= false;

   end;

end; (*ioxclose*)



procedure ioxread(var pch: CHAR; var pendfile: BOOLEAN);
var ch: byte; pos,commentpos2: longint;
commentstate: commentstatetype;
textcnt: integer;
restorePosition: boolean;

   function restoflineiscomment: boolean;
   (* ch='('. Check if rest of line is comment(s) or beginning of
      comment or blank.
      Examples:
      "* abc * )" => yes
      "1..." => no
      "* abc " => Yes (line ends inside a comment)
      "* abc * )  ( * def * )" => Yes (line ends with two comments but otherwise
         only blanks.
      "* abc * )1" => no (the comment does not extend to the end of the line).
      *)
   var rolresult: boolean;
   state: (leftpar,comment,star,normal);
   begin
      rolResult:= true;
      state:= leftpar;
      while rolResult and (ch<>13) and (ch<>10) and not currentXfileEof do
         begin
         read(currentXfilePtr^,ch);

         // Update cache
         // currentXfileEof
         if currentFileIsInternal>0 then currentXfileEof:=
            filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
         else currentXfileEof:= eof(currentXfilePtr^);

         case state of
            leftpar: begin
               if char(ch)='*' then state:= comment
               else rolResult:= false;
               end;
            comment: if char(ch)='*' then state:= star;
            star: begin
               if char(ch)=')' then state:= normal
               else if char(ch)<>'*' then state:= comment;
               end;
            normal: begin
               if char(ch)='(' then state:= leftpar
               else if (char(ch)<>' ') and (ch<>9) and (ch<>13) and (ch<>10) then rolResult:= false;
               end;
            end; (*case*)
         end; (*while*)
      restoflineiscomment:= rolResult;
   end; (* restoflineiscomment *)


begin

pendfile:= FALSE;
if currentXfileEof then begin
   pendfile:= TRUE;
   pch:= ' ';
   end
else begin

   commentstate:= xfileComState[filesopen];
   textcnt:= xfileTextCnt[filesopen];

   (* 1. Read one character. *)
   read(currentXfilePtr^,ch);
   // currentXfileEof
   if currentFileIsInternal>0 then currentXfileEof:=
      filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
   else currentXfileEof:= eof(currentXfilePtr^);

   pch:= char(ch);

   (* 2. Remove invisible space at the end of a line, or
      visible space, if rest of line is comment or beginning of
      comment. *)
   if fsLcWsTab[pch]=' ' then begin
      if (commentstate in [normal,leftpar]) then begin
         pos:= filepos(currentXfilePtr^);
         ch:= byte(pch);
         restorePosition:= true;
         while ((char(ch)=' ') or (ch=9)) and not currentXfileEof do begin
            read(currentXfilePtr^,ch);
            // currentXfileEof
            if currentFileIsInternal>0 then currentXfileEof:=
               filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
            else currentXfileEof:= eof(currentXfilePtr^);
            end;

         if (ch=10) or (ch=13) then begin
            (* Skip invisible blanks. *)
            pch:= char(ch);
            restorePosition:= false;
            end
         else if (char(ch)='(') then begin
            (* Do not move the comment unless there was some text before
               the space, on the same line (textcnt>0). *)
            if alAllowBlanksBeforeCommentToEoln and (textcnt>0) then begin
               commentpos2:= filepos(currentXfilePtr^);
               if restoflineiscomment then begin
                  (* Rest of line is comment(s) or start of comment - return
                     first comment char and set position to 2nd. *)
                  pch:= '(';
                  seek(currentXfilePtr^,commentpos2);
                  // currentXfileEof
                  if currentFileIsInternal>0 then currentXfileEof:=
                     filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
                  else currentXfileEof:= eof(currentXfilePtr^);

                  restorePosition:= false;
                  end;// (rest of line comment)
               end;// (allow blanks before comment and textcnt>0)
            end;// '('
         if restorePosition then
            (* Blanks not invisible (or eof) - restore position. *)
            seek(currentXfilePtr^,pos);
            // currentXfileEof
            if currentFileIsInternal>0 then currentXfileEof:=
               filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
            else currentXfileEof:= eof(currentXfilePtr^);
         end;// (normal or leftpar)
      end;// (' ' or char(9))

   (* 3. Convert CRLF => CR and LF => CR. *)
   if (pch=char(13)) and not currentXfileEof then begin
      pos:= filepos(currentXfilePtr^);
      read(currentXfilePtr^,ch);
      // currentXfileEof
      if currentFileIsInternal>0 then currentXfileEof:=
         filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
      else currentXfileEof:= eof(currentXfilePtr^);

      pch:= char(ch);
      if pch<>char(10) then begin
         seek(currentXfilePtr^,pos);
         // currentXfileEof
         if currentFileIsInternal>0 then currentXfileEof:=
            filepos(currentxfileptr^)>=internalFilesTab[currentFileIsInternal].endpos
         else currentXfileEof:= eof(currentXfilePtr^);
         end;
      pch:= char(13);
      end
   else if pch=char(10) then
      pch:= char(13);

   // Keep track of if there is any text on the line
   if pch=char(13) then textcnt:= 0
   else if textcnt>0 then textcnt:= textcnt+1
   else if fsLcWsTab[pch]<>' ' then textcnt:= 1;

   // Keep track of commentstate
   case commentstate of
      normal: if pch='(' then commentstate:= leftpar;
      leftpar: begin
         if pch='*' then commentstate:= comment
         else if pch<>'(' then commentstate:= normal
         end;
      comment: if pch='*' then commentstate:= star;
      star: if pch=')' then commentstate:= normal
      else if pch<>'*' then commentstate:= comment;
      end;
   xFileComState[filesopen]:= commentstate;
   xFileTextCnt[filesopen]:= textcnt;
   end;

(* Character 253..255 are reserved for special codes. *)
if ORD(pch)>=253 then begin
    if alflagga('D') then iodebugmess('!'+inttostr(ord(pch))+'!');
    xScriptError('Special char "'+pch+'" read in file (converted to blank).');
    pch:= ' ';
    end;
end; (*ioxread*)

(* INPUT FILES, OUTPUT FILES AND SOCKETS. *)
(******************************************)

function iofindfile( pfilename:fsptr;pendch: char): filerecptr;
(* Find a filename.
   Return nil if no success. *)
var filep: filerecptr; found: boolean;
ch1,ch2: char;
begin

filep:= files; found:= false;

// Nullinfile is not a real file - return nil if specified file name is empty.
if pfilename^=pendch then
   filep:= nil

else while not ( (filep=nil) or found ) do with filep^ do begin

   (* (from fsequal:) *)
   ch1:= pfilename^;
   ch2:= filename^;
   if (ch1=ch2) (* Full equality *)
      or (* Case-insensitive equality *)
      ( ((((ord(ch1) xor ord(ch2)) and fscasemask) or (not ord(ch1) and $40)) = 0)
         and ((ord(ch1) and $5F)<=90) )
         then begin
      if fsEqualFilename(pfilename,filename,pendch,eofs) then found:= true;
      end;
   if not found then filep:= next;
   end;

iofindfile:= filep;
end; (*iofindfile*)

function iogetfilenr(pfilename:string): integer;
(* Get file nr from file name, or 0 if file name is
   not the name of an existing file.  *)
var filename,fptr: fsptr; i: integer;
filerec: filerecptr;
begin
fsnew(filename); fptr:= filename;
for i:= 1 to length(pfilename) do fspshend(fptr,pfilename[i]);

filerec:= iofindfile(filename,eofs);
if filerec=nil then iogetfilenr:= 0
else iogetfilenr:= filerec.nr;
end; (* iogetfilenr *)

procedure ioFindPortNr( pfilename: fsptr; pendch: char; var pportnr: ioint32;
 var pcolonpos: fsptr );
(* Calculate portnr from "domain:portnr". Return also position of colon.
   Return 0 and nil if no portnr. *)
var
magn: ioint32;
strp: fsptr;

begin

(* Get portnr from domain:portnr. *)
pportnr:= 0; (* 0 = no portnr *)
pcolonpos:= NIL; (* NIL = no portnr *)
if pfilename^<>pendch then begin

    strp:= pfilename;
    fsforwendch(strp,pendch);
    fsback(strp);
    if strp^in ['0'..'9'] then begin
        pportnr:= 0; magn:= 1;
        while (strp^ in ['0'..'9']) and (strp<>pfilename) do begin
            pportnr:= pportnr+ magn*(ord(strp^)-ord('0'));
            magn:= magn*10;
            fsback(strp);
            end;
        if strp^=':' then pcolonpos:= strp
        else pportnr:= 0;
        end;
    end;

end; (*ioFindPortNr*)


// (new:)
function ioSerialPort( pfilename: fsptr; pendch: char): boolean;
(* Check if pfilename is of format "COMn:", "comn:" or "\\.\COMn"
   where n is a number. *)
var
strp: fsptr;
res: boolean;
colonFound: boolean;

begin

res:= false;
colonFound:= false;

if pfilename^<>pendch then begin

   strp:= pfilename;
   fsforwendch(strp,pendch);
   fsback(strp);
   if strp^=':' then begin
      colonFound:= true;
      if strp<>pfilename then fsback(strp);
      end; //":"

      if (strp^ in ['0'..'9']) and (strp<>pfilename) then begin
         while (strp^ in ['0'..'9']) and (strp<>pfilename) do begin
            fsback(strp);
            end;
         if ((strp^='M') or (strp^='m')) and (strp<>pfilename) then begin
            fsback(strp);
            if ((strp^='O') or (strp^='o')) and (strp<>pfilename) then begin
               fsback(strp);
               if ((strp^='C') or (strp^='c')) then begin
                  if colonFound then begin
                     // "COMn:" format
                     if (strp=pfilename) then res:= true;
                     end
                  else begin
                     // "\\.\COMn" format (windows uses this for port numbers >= 10).
                     fsback(strp);
                     if (strp^='\') and (strp<>pfilename) then begin
                        fsback(strp);
                        if (strp^='.') and (strp<>pfilename) then begin
                           fsback(strp);
                           if (strp^='\') and (strp<>pfilename) then begin
                              fsback(strp);
                              if (strp^='\') and (strp=pfilename) then res:= true;
                              end; // "\"
                           end; // "."
                        end; // "\"
                     end;
                  end; // "C"
               end; // "O"
            end; // "M"
         end; // "0".."9"
   end; // pfilename not empty

ioSerialPort:= res;

end; (*ioSerialPort*)


// (old:)
function ioSerialPort0( pfilename: fsptr; pendch: char): boolean;
(* Check if pfilename is of format "COMn:" or "comn:" where n is a number. *)
var
strp: fsptr;
res: boolean;

begin

res:= false;

if pfilename^<>pendch then begin

    strp:= pfilename;
    fsforwendch(strp,pendch);
    fsback(strp);
    if strp^=':' then begin
      fsback(strp);
      if strp^in ['0'..'9'] then begin
        while (strp^ in ['0'..'9']) and (strp<>pfilename) do begin
            fsback(strp);
            end;
        if ((strp^='M') or (strp^='m')) and (strp<>pfilename) then begin
            fsback(strp);
            if ((strp^='O') or (strp^='o')) and (strp<>pfilename) then begin
              fsback(strp);
              if ((strp^='C') or (strp^='c')) and (strp=pfilename) then
                res:= true;
              end; // "O"
            end; // "M"
        end; // "0".."9"
      end; //":"
    end; // pfilename not empty

ioSerialPort0:= res;

end; (*ioSerialPort0*)



(* Start winsock if it is not already started. *)
procedure ioStartWinsock;
begin
if not wsstarted then begin
    if wsastartup($0101,wsadata)<>0 then xProgramError(
       'x(ioin/ioout): Program error (unable to load winsock).')
    else wsstarted:= true;
    end;
end;

function ioaccept( pListenhandle: Tsocket; pwait: boolean): Tsocket; forward;

procedure iorecv(pfilep: filerecptr; pblocking: boolean); forward;


function ioDataToRead(pHandle: Tsocket): integer;
var
res: integer;
status: integer;
errorCode: integer;
errorSize: integer;
numberofbytes: integer;

begin
   numberofbytes:= 0;
   errorSize:= 4;
   Status := GetSockOpt(phandle,SOL_SOCKET,SO_ERROR,@errorCode,errorSize);
   if errorCode<>0 then
      xProgramError('X(ioDataToRead): Expected error code 0 from GetSockOpt '+
         'but found '+inttostr(errorcode)+'.');

   status:= IoCtlSocket(pHandle,Fionread,numberofbytes);
   if (status<>0) then
      xProgramError('X(ioDataToRead): Expected status code 0 from GetSockOpt '+
         'but found '+inttostr(status)+'.');

   ioDataToRead:=numberofbytes;

end;// (IoDataToRead)

procedure ioUpdateSocketState( pfilep: filerecptr; pinp: ioinptr );

(* Start winsock if not already started.
   Preferredrole = ioclient:
      Try to connect if in initial or connectingclient state
   Preferredrole = ioserver:
      Accept calls if in initial or connectingserver state
   Preferredrole = none:
      Try to connect if in  initial state.
      Accept calls if not possible to connect.
*)

var
hostentp: Phostent; (* A pointer to a record that has a field
                    (h_addr_list) that points at a pointer to
                    the ip-nr. *)
sockaddr: TSockAddrIn; (* A record containing the ip-nr (.sin_addr)
                          and the portnr (.sin_port). *)
p: pinaddr;
con: integer;          (* Return from connect (=0 if ok). *)
domainstr: fsptr;
port: ioint32;
colonpos: fsptr;
bi,li: integer;
newhandle: Tsocket;
ioresult: integer;
readfds,writefds,errorfds: TFDSet;
n: longint;
timeout: TTimeVal;
seconds10: TDateTime;
inptr: ioinptr;

begin

domainstr:= nil;

with pfilep^ do begin


   // Restore after reconnection of socket if eof was accepted.
   if socketstate=disconnected then begin
      // Allow new connection if eof was not reached or if eof was accepted.
      if pfilep=curinfilep then inptr:= pinp else inptr:= inpsave;
      if inptr^<>eofs then socketstate:= unbound;
      end;

    if (socketstate=unbound) then begin

        (* If socket not yet bound: Get internet address from filename. *)
        fsnew(domainstr);
        fscopy(filename,domainstr,eofs);
        iofindportnr(domainstr,eofs,port,colonpos);
        if port=0 then
        xProgramError(
          'X(ioupdatesocketstate): Program error - port number not found in '
          +fstostr(domainstr)+'.')
        else begin

          fsdelrest(colonpos);
          hostentp:= gethostbyname( PChar(fstostr(domainstr)) );
          if hostentp=nil then begin
              xScriptError('X(updatesocketstate): "'+fstostr(domainstr)
              +'" is not a valid internet domain.');
              socketstate:= connectionError;
              end;
          end;
        end; (* unbound *)

    if (socketstate=unbound)
        and ((preferredrole=ioclient) or (preferredrole=ionone)) then begin

        (* Try to connect as client. *)
        seconds10:= 10.0/24/3600; (* 10 seconds. *)
        if not (socketstate=connectionError)
            and (time>(lastConTime + seconds10)) then begin
            sockaddr.sin_family:= AF_INET;
            sockAddr.sin_port:= htons(port);
            p:= pinaddr(hostentp^.h_addr_list^);
            sockaddr.sin_addr:= p^;
            ioenableotherthreads(1);
            try
              con:= connect(sockhand,sockaddr,sizeof(sockaddr));
            finally
              iodisableotherthreads(1);
              end;
            lastConTime:= time;
            if con=0 then socketstate:= connectedAsClient
            else begin
                (* Throw the old socket and get a new one. *)
                closesocket(sockhand);
                sockhand:= socket( PF_INET,SOCK_STREAM,0 );
                end;
            end;
        end; (* unbound and rPreferredrole = ionone of ioclient *)

    if (socketstate=unbound)
        and ((preferredrole=ioserver) or (preferredrole=ionone))
        then begin

        (* Try to act as server: bind to port. *)
        sockaddr.sin_family:= AF_INET;
        sockAddr.sin_port:= htons(port);
        p:= pinaddr(hostentp^.h_addr_list^);
        sockaddr.sin_addr:= p^;
        bi:= bind(sockhand,sockaddr,sizeof(sockaddr));
        if bi <> 0 then begin
            xScriptError('X(updatesocketstate): Unable to bind to localhost:'
            +inttostr(port)+' ('+inttostr(WSAGetLastError)+').');
            socketstate:= connectionError;
            end;

        (* Listen: *)
        if not (socketstate=connectionError) then begin
            li:= listen(sockhand,0); (* 0 means accept only one call *)
            if li=0 then socketstate:= listening
            else begin
                xScriptError('X(updatesocketstate): Unable to listen to localhost:'
                +inttostr(port)+' ('+inttostr(WSAGetLastError)+').');
                socketstate:= connectionError;
                end;
            end;
        end; (* unbound and ioserver or ionone *)

    if (socketstate= listening) then begin

       (* Accept incoming calls. *)
       newhandle:= ioaccept(sockhand,false);
       if xFault then socketstate:= connectionError

       else if newhandle<>invalid_socket then begin
            closesocket(sockhand);
            sockhand:= newhandle;
            socketstate:= connectedAsServer;
            end;
        end; (* listening *)

    if (socketstate=connectedAsClient)
        or (socketstate=connectedAsServer) then begin

        (* Use select to find out status of socket. *)
        with readfds do begin
          fd_count:= 1;
          fd_array[0]:= sockhand;
          end;
        with writefds do begin
          fd_count:= 1;
          fd_array[0]:= sockhand;
          end;
        with errorfds do begin
          fd_count:= 1;
          fd_array[0]:= sockhand;
          end;
        (* {0,0} = return immediately *)
        with timeout do begin
          tv_sec:= 0;
          tv_usec:= 0;
          end;

        n:= select(0,@readfds,@writefds,@errorfds,@timeout);
        if n=socket_error then begin
            xScriptError('X(ioUpdateSocketState): Error from select ('+
               inttostr(WSAGetLastError)+').');
            socketState:= connectionError;
            end
        else begin

            if errorfds.fd_count<>0 then begin
               xScriptError('X(ioUpdateSocketState): Error from select - '+
                  'unexpected errorfds.fd_count='+inttostr(errorfds.fd_count)+'.');
               socketstate:= connectionerror;
               end
            else if writefds.fd_count=0 then begin

                (* Disconnected from other side. *)
                closesocket(sockhand);
                sockhand:= socket( PF_INET,SOCK_STREAM,0 );
                socketstate:= disconnected;
                end
            else if readfds.fd_count>0 then begin

                (* This can mean either there is data to read, or that the
                   other side is trying to close. If inpsave has reached
                   eofr - use recv to check. *)
                (* Update insave if possible. *)
                if (pfilep=curinfilep) and (pinp<>nil) then inpsave:= pinp;
                if inpsave^=eofr then begin
                  // (new:)
                  if ioDataToRead(sockhand)>0 then
                     // Still connected
                  else
                     // Disconnected - use iorecv to clear the state.
                     iorecv(pfilep,true);
                     (* iorecv will take care of any necessary state transitions. *)
                  (* (old:)iorecv(pfilep,true);
                  ( * iorecv will take care of any necessary state transitions. * )
                  *)
                  end;
                end; (* read fd_count>0 *)
            end; (* n<>socketerror *)
        end; (* connectedAsServer or connectedAsClient *)
    end; (* with pfilep^ *)

if domainstr<>nil then fsdispose(domainstr);

end; (*ioUpdateSocketState*)


procedure ioremovefile(pfilep: filerecptr; pinp: ioinptr); forward;

procedure iomakesocket( pfilename: fsptr; pendch: char; (* domain:portnr *)
                        pbinary: boolean; pprefRole: ioprefroles;
                        var pinp: ioinptr; var pfile: filerecptr);
(* Start winsock if not already started. Create and connect an internet
   socket. Create a filerecord with buffers and pointers necessary to
   use the socket.
   The sample program QSMTP.C (first converted to qsmtp.pas) in the book
   "Internetprogrammering" by Jamsa and Cove, has been used as a model
   in the usage of the winsock interface. *)

var
handle: Tsocket; (* A number used by winsock to identify a socket. *)
rbuf,sbuf: ioinptr;    (* Preliminary pointers to filebuf and sbuf. *)
frp,filep: filerecptr;
port: ioint32;
cnt: integer;
ptr: ioinptr;
inp: ioinptr;
addrp: addrptr;
localfilebufend: ioinptr;

begin

pfile:= nil;

if not wsstarted then begin
    if wsastartup($0101,wsadata)<>0 then xProgramError(
       'x(ioin/ioout): Program error (unable to load winsock).')
    else wsstarted:= true;
    end;

if not xFault then begin

    handle:= socket( PF_INET,SOCK_STREAM,0 );
    if handle=INVALID_SOCKET then xProgramError(
       'X(ioin/ioout): Program error (unable to create a socket).');
    end;

if not xFault then begin (* (There ought to be a try-block
                             around this). *)
    GetMem(rbuf,iobufsize);
    GetMem(sbuf,iobufsize);
    end;

if not xFault then begin (* success *)

    rbuf^:= eofr;
    ioinptr(ioint32(rbuf)+1)^:= eofs;
    localfilebufend:= ioinptr( ioint32(rbuf) +iobufsize -6 );
    (* Let next pointer point at the same block to enable
       ioinforward to function. *)
    localfilebufend^:= eobl;
    ioinptr(ioint32(localfilebufend)+1)^:= char(0);
    inp:= ioinptr( ioint32(localfilebufend) + 2);
    addrp:= addrptr(inp);
    addrp^:= rbuf;

    frp:= iomakefile(pfilename,pendch,pbinary,
      rbuf,rbuf,rbuf,false,nil);

    (* No empty space in socket buffer. *)
    ioinptr( ioint32(localfilebufend) +1)^:= char(0);
    localfilebufend^:= eobl;

    with frp^ do begin
        kind:= asocket;
        preferredrole:= pprefrole;
        prevWasCR:= false;

        socketstate:= unbound;
        sockhand:= handle;

        sendbufp:= sbuf;
        outp:= sbuf;
        outpsave:= sbuf;
        sendbufend:= ioinptr( ioint32(sbuf) + iobufsize -1 );
        (* To ensure that 1st connect will not be discarded: *)
        lastConTime:= time - 2.0;
        end;
    pfile:= frp;
    end;

if not xFault then begin

   (* Try to connect. *)
   ioUpdateSocketState(frp,pinp);

   if frp^.socketstate=connectionError then
      (* Remove file. *)
      ioremovefile(frp,pinp);
   end;

end; (*iomakesocket*)



procedure iomakeSerialPort( pfilename: fsptr; pendch: char; (* "COMn:" or "comn:" *)
                        pbinary: boolean; pconfig: string;
                        var pinp: ioinptr; var pfile: filerecptr);
(* According to "Using the serial ports in Delphi under Win32 platforms" at
   www.commlinx.com.au/delphi-comms.htm.
   Usage examples:
      <in com1:,baud=19200 parity=n data=8 stop=1>
      <out com14:,baud=115200 createretries=2>
 *)

var
rbuf,sbuf: ioinptr;    (* Preliminary pointers to filebuf and sbuf. *)
frp,filep: filerecptr;
port: ioint32;
cnt: integer;
//ptr: ioinptr;
inp: ioinptr;
addrp: addrptr;
localfilebufend: ioinptr;

// for serial port:
DevName: string;
DeviceName: Array[1..80] of char;
ComFile: Thandle;
DCB: TDCB;
Config: String;
CommTimeouts: TCommTimeouts;
ptr: fsptr;
count: integer;

// Createretries=n
pos: integer;
retriesch: char;
retries: integer;
retriesstr: string;

begin

pfile:= nil;

if not xFault then begin

   devname:= xfstostr(pfilename,pendch);

   // Convert from "COM10:" to "\\.\COM10" for port numbers >= 10.
   ptr:= pfilename;
   fsforwendch(ptr,pendch);
   fsback(ptr);

   if ptr^=':' then begin
      // This is on format "COMn:"
      if fsdistance(pfilename,ptr)>=5 then
         // portnumber>=10 - Remove : and add \\.\ in the beginning
         devname:= '\\.\' + xfstostr(pfilename,':');
      end;

   // Make null-terminated string of devname
   StrPCopy(@Devicename,devname);

   // Take out createRetries=n from pconfig
   retries:=-1; // = default
   pos:= findPart('createretries=?',pconfig);
   if pos>0 then begin
      retriesch:= pconfig[pos+14];
      if length(pconfig)>pos+14 then
         if pconfig[pos+15]<>' ' then
         xScriptError('X(ioin/ioout): The serial port configuration ' +
            'createretries ended with unexpected character "'+
            pconfig[pos+15]+'" (only 0-9 is accepted).');
      if not xFault then begin
         if (retriesch in ['0'..'9']) then begin
            retries:= integer(retriesch) - integer('0');
            // Consider 0 as one try
            if retries=0 then retries:= 1;
            retriesStr:= 'createretries='+retriesch;
            pconfig:= ReplaceText(pconfig,retriesstr,'');
            end
         else xScriptError('X(ioin/ioout): createretries=(0-9) was expected but '+
            'createretries='+retriesch+' was found.');
         end;
      end;

   // Create "file"
   if not xFault then begin

      comfile:= windows.CreateFile(@Devicename,GENERIC_READ or GENERIC_WRITE,0,nil,
         OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
      if comFile = INVALID_HANDLE_VALUE then begin
         (* The port can be in process of closing.
            Retry 10 times with 500ms interval, before giving up. *)
         if retries=-1 then retries:= 10;

         count:= 0;
         while (comFile = INVALID_HANDLE_VALUE) and (count<retries) do begin
            ioEnableAndSleep(500);
            comfile:= windows.CreateFile(@Devicename,GENERIC_READ or GENERIC_WRITE,0,nil,
               OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
            count:= count+1;
            end;

         if comFile = INVALID_HANDLE_VALUE then
            xScriptError(
            'X(ioin/ioout): Script error (unable to connect to serial port).');
         end;
      end; // (not fault)

   end;// (not fault)

if not xFault then
   // Set up serial port buffers
   if not SetupComm(comFile,256,256) then xProgramError(
      'X(ioin/ioout): Program error (unable to setup serial port buffers).');

if not xFault then
   // Get comm state block
   if not GetCommState(Comfile,DCB) then xProgramError(
      'X(ioin/ioout): Program error (unable to config serial port).');

if not xFault then begin
   // Set up config
   (* (Bfn 111130: Tried to also add default retry=n, but BuildCommDCB did not
      accept it, it returned false, and no reference on how to specify it was
      found on in a shallow search on internet) *)
   if pconfig='' then pconfig:='baud=115200 parity=n data=8 stop=1'
   else begin
      if not ansicontainsText(pconfig,'baud=') then pconfig:= pconfig + ' baud=115200';
      if not ansicontainsText(pconfig,'parity=') then pconfig:= pconfig + ' parity=n';
      if not ansicontainsText(pconfig,'data=') then pconfig:= pconfig + ' data=8';
      if not ansicontainsText(pconfig,'stop=') then pconfig:= pconfig + ' stop=1';
      end;

   if not xFault then begin
      pconfig:= pconfig + char(0);
      if not BuildCommDCB(@pconfig[1],DCB) then xScriptError(
         'X(ioin/ioout): The serial port configuration string ('+pconfig+
         ') was not accepted by BuildCommDCB.');
      end;
   end;

if not xFault then
   // Set up config
   if not SetCommState(Comfile,DCB) then xProgramError(
      'X(ioin/ioout): Program error (unable to set config in serial port).');

if not xFault then begin
   // Set up timeouts

   // (new:)
   with CommTimeouts do begin
      (* According to msdn (http://msdn.microsoft.com/en-us/library/
         aa363190%28v=VS.85%29.aspx): "readintervaltimeout=maxdword in
         combination with zero values for both the ReadTotalTimeoutConstant
         and ReadTotalTimeoutMultiplier members, specifies that the read
         operation is to return immediately with the bytes that have already
         been received, even if no bytes have been received." *)
      ReadIntervalTimeout:= maxdword;
      ReadTotalTimeoutMultiplier:= 0;
      ReadTotalTimeoutconstant:= 0;
      WriteTotalTimeoutMultiplier:= 0;
      WritetotalTimeoutConstant:= 1000;
      end;
    (* (old:
    with CommTimeouts do begin
        ReadIntervalTimeout:= 0;
        ReadTotalTimeoutMultiplier:= 0;
        ReadTotalTimeoutconstant:= 1; // Minimum timeout
        WriteTotalTimeoutMultiplier:= 0;
        WritetotalTimeoutConstant:= 1000;
        end;
    *)

   if not SetCommTimeOuts(comFile,CommTimeouts) then xProgramError(
      'X(ioin/ioout): Program error (unable to set timeouts in serial port).');
   end;

if not xFault then begin (* (There ought to be a try-block
                             around this). *)
   GetMem(rbuf,iobufsize);
   GetMem(sbuf,iobufsize);
   end;

if not xFault then begin (* success *)

   rbuf^:= eofr;
   ioinptr(ioint32(rbuf)+1)^:= eofs;
   localfilebufend:= ioinptr( ioint32(rbuf) +iobufsize -6 );

   (* Let next pointer point at the same block to enable
      ioinforward to function. *)
   inp:= ioinptr( ioint32(localfilebufend) + 2);
   addrp:= addrptr(inp);
   addrp^:= rbuf;;

   (* No empty space in socket buffer. *)
   ioinptr( ioint32(localfilebufend) +1)^:= char(0);
   localfilebufend^:= eobl;

   frp:= iomakefile(pfilename,pendch,pbinary,rbuf,rbuf,rbuf,false,nil);

   with frp^ do begin
      kind:= aserialport;
      prevWasCR:= false;
      sendbufp:= sbuf;
      outp:= sbuf;
      outpsave:= sbuf;
      sendbufend:= ioinptr( ioint32(sbuf) + iobufsize -1 );
      comHand:= ComFile;
      comCreateRetries:= retries;
      end;
   pfile:= frp;
   end;

end; (*iomakeSerialPort*)



procedure iomakeCircularBuffer( pfilename: fsptr; pendch: char; (* Ex "mybuf" *)
                        var pfile: filerecptr);
(* Circular buffer for thread communication.
   Usage example:
    <out mybuf,circularbuffer> (in thread 1)
    ...
    <in mybuf,circularbuffer> (in thread 2)
 *)

var
rbuf: ioinptr;    (* Preliminary pointer to filebuf. *)
frp,filep: filerecptr;
cnt: integer;
ptr: ioinptr;
inp: ioinptr;
addrp: addrptr;
localfilebufend: ioinptr;


begin

pfile:= nil;

if not xFault then begin (* (There ought to be a try-block
                             around this). *)
    GetMem(rbuf,iobufsize);
    end;

if not xFault then begin (* success *)

    rbuf^:= eofr;
    ioinptr(ioint32(rbuf)+1)^:= eofs;
    localfilebufend:= ioinptr( ioint32(rbuf) +iobufsize -6 );

    (* Let next pointer point at the same block to enable
       ioinforward to function. *)
    inp:= ioinptr( ioint32(localfilebufend) + 2);
    addrp:= addrptr(inp);
    addrp^:= rbuf;;

    (* No empty space in socket buffer. *)
    ioinptr( ioint32(localfilebufend) +1)^:= char(0);
    localfilebufend^:= eobl;

    frp:= iomakefile(pfilename,pendch,false,
      rbuf,rbuf,rbuf,false,nil);

    with frp^ do begin
        kind:= acircularbuffer;
        prevWasCR:= false;
        sendbufp:= nil;
        outp:= rbuf;
        outpsave:= rbuf;
        sendbufend:= nil;
        end;
    pfile:= frp;
    end;

end; (*iomakeCircularBuffer*)

const makeblocktab: boolean = false;

function iomakefile(pfilename: fsptr; pendch: char; pbinary: boolean;
   pfilebufp: ioinptr; plastbufp: ioinptr; pendp: ioinptr; pout: boolean;
    pCrPtr: ioinptr )
   : filerecptr;
(* Create a file record. pfilebufp shall point at a ready made buffer or
   chain of buffers. Used by ioin and ioout. Examples:
      frp:= iomakefile(pfilename,pendch,pbinary,bufp1,bufp,false);
   *)
var
frp,filep: filerecptr; bufp: ioinptr;

begin

new(frp);
with frp^ do begin
   CreatedFilesCount:= CreatedFilesCount+1;
   nr:= CreatedFilesCount;
   ExistingFilesCount:= ExistingFilesCount+1;
   if fsEqualFilename(pfilename,consfs,eofs,eofs) then kind:= aconsole
   else kind:= afile;
   fsnew(filename);
   fscopy(pfilename,filename,pendch);
   binaryfile:= pbinary;
   filebufp:= pfilebufp;
   fileinfo:= nil;
   inpsave:= pfilebufp;

   (* Check if file starts with a comment. *)
   if inpsave^= xskipcomment then begin
      if xskipcomment<>' ' then ioskipcomment(inpsave,xlinecomment);
      end;

   readpos:= inpsave;
   readrescnt:= 0;
   unrendptr:= nil;
   unrbranchptr:= nil;
   // (new: Put outptr initially at the end.)
   outp:= pEndp;
   // (old:) outp:= inpsave;
   outpsave:= outp;

   filebufend:= ioinptr( ioint32(plastbufp) + iobufsize -6);
   blocktablen:= 0;
   errorfound:= false;
   bufp:= filebufp;

   // Debug ++
   if false then begin
      blocktablen:= 1;
      blocktab[blocktablen]:= bufp;
      end;

   while (bufp<>nil) do begin
      bufp:= ioinptr(integer(bufp) + iobufsize-6);
      if bufp^=eobl then begin
         bufp:= addrptr(integer(bufp)+2)^;
         if bufp=filebufp then
            (* Circular buffer. *)
            bufp:= nil
         else begin
            // ++
            if false then begin
               blocktablen:= blocktablen+1;
               blocktab[blocktablen]:= bufp;
               end;
            end;
         end
      else if bufp^=eofs then
         bufp:= nil
      else xProgramError('X(iomakefile): Program error - eobl or eofs was expected but char #'+
         inttostr(integer(bufp^))+' was found.');
      end;
   endp:= pendp;

   if pout then usedforoutput:= true
   else usedforoutput:= false;

   addedCrPtr:= pCrPtr;

   inthreadnr:= -1;
   outthreadnr:= -1;
   writeEvent:= createEvent(NIL,false,false,NIL);
   dataRequest:= False;
   refCount:= 0;
   eofatentry:= false;

   (* Unused socket variables: *)
   sockhand:= 0;
   socketstate:= unbound;
   preferredrole:= ionone;
   prevWasCR:= false;
   sendbufp:= nil;
   sendbufend:= nil;
   lastcontime:= 0;
   comhand:= 0;
   comCreateRetries:= -1;
   next:= NIL;

   // ++ Debug info
   recvcount:= 0;
   end;

if files=nil then files:= frp
else begin
   filep:= files;
   while not (filep^.next=nil) do filep:= filep^.next;
   filep^.next:= frp;
   end;

iomakefile:= frp;

end; (*iomakefile*)

function ioaccept( pListenhandle: Tsocket; pwait: boolean): Tsocket;

(* Do accept or check if possible to to accept on a socket which is
   in listening state. prfp = pointer to socket.
   pwait: False= Check (with select) before calling accept, that an incoming
          request has been received. (Return false if not.)
          True= Call accept (blocking) without prior checking.
   Return number of connected socket, INVALID_SOCKET if not connected. *)

var
newhandle: Tsocket; (* Handle for connection created by accept. *)
writefds: TFDSet;
n: longint;
sockerr: integer;
timeout: TTimeVal;

begin (*ioaccept*)

newhandle:= INVALID_SOCKET;

(* Check if someone has connected to us. *)
with writefds do begin
   fd_count:= 1;
   fd_array[0]:= plistenhandle;
   end;
(* {0,0} = return immediately *)
with timeout do begin
  tv_sec:= 0;
  tv_usec:= 0;
  end;

n:= select(0,@writefds,NIL,NIL,@timeout);

if (n>0) or (pwait) then begin

    (* pick up connection request (or wait until it comes). *)
    (* newhandle:= accept(plistenhandle,clientsockaddr,clientsockaddrlen); Delphi 2 *)
    ioenableotherthreads(2);
    try
      newhandle:= accept(plistenhandle,NIL,NIL); (* Delphi 7 *)
    finally
      iodisableotherthreads(2);
      end;
    if newhandle = INVALID_SOCKET then begin
        sockerr:= WSAGetLastError;
        xProgramError('X(ioaccept): Program error - Unable to accept localhost:portnr'
           +'('+inttostr(sockerr)+').');
        end;
    end;

ioaccept:= newhandle;

end; (*ioaccept*)



procedure iobintohex(pbinp: ioCharPtr; plen: ioint32; phexp: ioCharPtr);
var
cnt: ioint32;
bin: ioint16;

begin
for cnt:= 1 to plen do begin
    bin:= ioint16(pbinp^) shr 4;
    if (bin<=9) then
      phexp^:= char(bin + ioint16('0'))
    else
      phexp^:= char(bin + ioint16('A') - 10);
    phexp:= ioCharPtr(ioint32(phexp)+1);
    bin:= ioint16(pbinp^) and $0f;
    if (bin<=9) then
      phexp^:= char(bin + ioint16('0'))
    else
      phexp^:= char(bin + ioint16('A') - 10);
    phexp:= ioCharPtr(ioint32(phexp)+1);
    pbinp:= ioCharPtr(ioint32(pbinp)+1);
    end; (* for *)
end; (*iobintohex*)

procedure iohextobin(phexp: ioinPtr; plen: ioint32; pbinp: ioinPtr);
var
cnt: ioint32;
nib,byte: ioint16;
ch: char;
highnib: Boolean;
str: string;

begin
str:= '';
highnib:= True;
for cnt:= 1 to plen do begin
    nib:= 0; ch:= phexp^;
    if (ch>='0') and (ch<='9') then nib:= ioint16(ch) - ioint16('0')
    else if (ch>='A') and (ch<='F') then nib:= ioint16(ch) + 10 - ioint16('A')
    else str:= str + ch;

    if highnib then begin
        byte:= nib shl 4;
        highnib:= false;
        end
    else begin
        byte:= byte + nib;
        pbinp^:= char(byte);
        pbinp:= ioinptr(ioint32(pbinp) + 1);
        highnib:= true;
        end;
    phexp:= ioinptr(ioint32(phexp)+1);
    end; (*for*)

if not highnib then xProgramError(
   'X (iohextobin): Program error - len is odd ('+inttostr(plen)+').');

if str<>'' then
  xProgramError(
    'X (iohextobin): Program error - Non hex chars found in output to binary file:"'
    +str+ '"(converted to 0)');

end; (*iohextobin*)



procedure ioseek (pn: ioint32; pout: boolean; var pinp: ioinptr);
(* Go to position pn (address) in the current input or output file.
   0=beginning of file.  *)

var

bufp,p,nextbufp: ioinptr;
filep: filerecptr;
ptr: ioinptr;

begin
if pout then filep:= curoutfilep else filep:= curinfilep;

if filep=NIL then
   xScriptError('Unable to seek a pos in outfile when outfile is undefined (nil).')
else if filep.kind=aconsole then begin
   if pn>=0 then
      xScriptError('Unable to seek a pos in console in/out ('+inttostr(pn)+').');
   end
else if filep.kind=asocket then begin
   if pn>=0 then
      xScriptError('X(ioseek): Unable to seek a pos in an internet socket ('
          +inttostr(pn)+').');
   end
else if filep.kind=aserialport then begin
   if pn>=0 then
      xScriptError('X(ioseek): Unable to seek a pos in a serial port ('
         +inttostr(pn)+').');
   end
else if filep.kind=acircularbuffer then begin
   if pn>=0 then
      xScriptError('X(ioseek): Unable to seek a pos in a circular buffer ('
         +inttostr(pn)+').');
   end
else if filep.kind=afile then with filep^ do begin

    // 0 = beginning of file
    if pn=0 then begin
      p:= filebufp;
      (* Check if file starts with a comment. *)
      if p^= xskipcomment then begin
         if xskipcomment<>' ' then ioskipcomment(p,xlinecomment);
         end;
      end
    else p:= ioinptr(pn);

    // Check that address is in the file.
    bufp:= filebufp;
    nextbufp:= ioinptrptr(ioint32(bufp)+iobufsize-4)^;
    while not (
      (ioint32(p)>=ioint32(bufp)) and (ioint32(p)<=ioint32(bufp)+iobufsize-6)
      or (nextbufp=nil) )
      do begin
      bufp:= nextbufp;
      nextbufp:= ioinptrptr(ioint32(bufp)+iobufsize-4)^;
      end;

    if (ioint32(p)>=ioint32(bufp)) and (ioint32(p)<=ioint32(bufp)+iobufsize-6)
      then pinp:= p
    else begin
      // See if p is in unread buffer below unrEndPtr and above unrBottom
       if not pOut and (ioint32(p)>=ioint32(unrBottom)) and
         (ioint32(p)<ioint32(unrbufend)) and
         (ioint32(p)<ioint32(filep^.unrendptr)) then pinp:= p
       else xScriptError(
         'Index position (address ' + inttostr(integer(p)) +
         ') was not found in the file (' + fstostr(filename) + ') and not '+
         'in the part of the unread buffer reserved for the file ('+
         inttostr(integer(unrBottom))+'..'+
         inttostr(integer(filep^.unrEndPtr))+').');
         end;
    end; (*with*)
end; (*ioseek*)


procedure ioswitchinput(pnewinfilep: filerecptr;var pinp: ioinptr);
(* Change curinfilep to pnewinfilep and do some updating. *)
begin

with curinfilep^ do begin
    inthreadnr:= -1;

    (* 0. Reset loop detection if kind=file and input pointer has advanced. *)
    if (kind=afile) and (pinp<>inpsave) then xresetloopdetection:= True;

    (* 1. Save old file pointer. *)
    inpsave:= pinp;
    (* 2. Update old refcount. *)
    refCount:= refCount-1;
    end;

// Save IO unless already done
if alSaveIoPtr<>NIL then
   alSaveIo;

if pnewinfilep=nil then
   xProgramError('ioswitchinput: Unexpected switching to infile=nil.')

else with pnewinfilep^ do begin
    (* 3. Update new refcount. *)
    refCount:= refCount+1;
    (* 4. Get pinp. *)
    pinp:= inpsave;

    (* 5. Update unrbottom  *)
    if (ioint32(pinp)>=ioint32(unrbufp))
        and (ioint32(pinp)<=ioint32(unrbufend))
        then unrbottom:= pinp;

    (* 6. optcr shall be disabled for console *)
    if kind=aconsole then begin
       xoptcr:= ' ';
       xoptcr2:= ' ';
       end
     else begin
        xoptcr:= xoptcrfile; (* file or socket. *)
        if xoptcr=char(13) then xoptcr2:= char(10) else xoptcr2:= ' ';
        end;

    if (inthreadnr<>-1) then begin
      if (kind=afile)then
        xScriptError('X(<in ...>): Only one thread shall use a file as input at a time.')
      else if (kind=acircularbuffer) then
        xScriptError('X(<in ...>): Only one thread shall use a circular buffer as input at a time.')
      end;
    inthreadnr:= althreadnr;
    end;
curinfilep:= pnewinfilep;
end; (*ioswitchinput*)

procedure ioswitchoutput(pnewoutfilep: filerecptr);
(* Change curoutfilep to pnewoutfilep and do some updating. *)
begin

if curoutfilep<>nil then with curoutfilep^ do begin
    outthreadnr:= -1;
    (* Update old refcount. *)
    refCount:= refCount-1;
    end;

// Save in out numbers unless already done
if (alSaveIoPtr<>nil) then alSaveIo;

if pnewoutfilep<>nil then with pnewoutfilep^ do begin
   (* Update new refcount. *)
   refCount:= refCount+1;
   if (outthreadnr<>-1) then begin
      if (kind=afile)then
         xScriptError('X(<out ...>): Only one thread shall use a file as output at a time.')
      else if (kind=acircularbuffer) then
         xScriptError('X(<out ...>): Only one thread shall use a circular buffer as output at a time.')
      end;
   outthreadnr:= althreadnr;
   end;
curoutfilep:= pnewoutfilep;

end; (*ioswitchoutput*)

var speccharwarningissued: boolean = False; (* Used by alhtos *)

procedure ioscanforspecchars(pbufp,pendp: ioinptr; pfilename: fsptr; pendch: char);
var ptr: ioint32;
begin
(* Scan input data for special characters (>=253). *)
for ptr:= ioint32(pbufp) to (ioint32(pendp)-1) do begin
  if ord(ioinptr(ptr)^)>=ioeobl then begin
    if not speccharwarningissued
    and not iosuppressbadcharmessage then begin
      xScriptError('X(<in ...>): Warning: Special character, code '
        + inttostr(integer(ioinptr(ptr)^)) + ', found in file '+xfstostr(pfilename,pendch)+'.'
        +' Characters with code 253..255 are not allowed'
        +' because these values are reserved for use by X.'
        +'Character will be converted to code 216 ('
        +char(216)+'). Further warnings will not be shown.'+
        ' This messages can be suppressed with the function:'+
        ' <settings suppressbadcharmessage,yes>.');
      speccharwarningissued:= True;
      end; // not speccharwarningissued
    ioinptr(ptr)^:= char(216); (* Ø *)
    end; // >=ioeobl
  end; // for ...
end; // ioscanforspecchars

procedure iocheckoptionsexistingfile(pfilep: filerecptr; pbinary: boolean;
   pprefrole: ioprefroles; pcircularbuffer: boolean
   );
(* <in ...> or <out ...> is called. The new file is already existing.
  (pfilep). Check that any options are not contradictory
  to the already opened file. *)
begin

   (* 5A. Check options for existing file or socket. *)
   if pfilep=consfilep then begin
      if pbinary then xScriptError(
         'x(<in/out '+fstostr(pfilep^.filename)+',...>): Binary option is not available for console.')
      else if (pprefrole= ioclient) or (pprefrole=ioserver) then
         xScriptError(
         'X(<in/out '+fstostr(pfilep^.filename)+',...>): client and server options not valid for console.');
      end
   else if pfilep=nullinfilep then begin
      if pbinary then xProgramError('Binary option was selected for input but there was no input file.')
      else if (pprefrole= ioclient) or (pprefrole=ioserver) then
         xProgramError('"client" or "server" option was selected for input but there was no input file.');
      end
   else if pfilep=NIL then begin
      // Undefined output file
      if pbinary then xScriptError('Binary option was selected for a file that '+
         'was undefined (could for example have been caused by <out ,binary> '+
         'inside <localio ..>).')
      else if (pprefrole= ioclient) or (pprefrole=ioserver) then
         xScriptError('"client" or "server" option was selected for a file that '+
         'was undefined (could for example have been caused by <out ,binary> '+
         'inside <localio ..>).')
      else if pcircularbuffer then xScriptError('circularbuffer option was selected for a file that '+
         'was undefined (could for example have been caused by <out ,binary> '+
         'inside <localio ..>).')
      end

   else with pfilep^ do begin

      if pbinary and not binaryfile then xScriptError(
         'X(<in/out '+fstostr(filename)+',...>): Unable to change to binary format in an existing'
         +'file or socket.')
      else if pcircularbuffer and not (kind=acircularbuffer) then xScriptError(
         'X(<in/out '+fstostr(filename)+',...>): Unable to change to circular buffer in an existing'
         +'file.')
      else if (pprefrole<>ionone) and (pprefrole<>preferredrole) then
         xScriptError('X(<in/out '+fstostr(filename)+',...>): Unable to change to preferred role'
         +' client or server in an existing internet socket (or file).');
      end;

end; (*iocheckoptionsexistingfile*)

(*
   usedUniqueFileName
   -------------------
   Return code: -1 = not formatted as temporary file.
                0 = formatted as temporary file name but not in use.
                >0 = number of temporary file name in use.
*)
function usedUniqueFileName(ps: fsptr; pendch: char): integer;
var
state: (s1,s2,s3,s4);
ptr: fsptr;
exitloop: boolean;
n: integer;
returnvalue: integer;
begin
ptr:= ps;
exitloop:= false;
state:= s1;
n:= 0;
returnvalue:= -1; // Default: not formatted as a temporary file name.
while (ptr^<>pendch) and not exitloop do begin
   case state of
      s1: begin
         if (ptr^='t') or (ptr^='T') then state:= s2
         else exitloop:= true;
         end;
      s2: begin
         if (ptr^='f') or (ptr^='F') then state:= s3
         else exitloop:= true;
         end;
      s3: begin
         if (ptr^='#') then state:= s4
         else exitloop:= true;
         end;
      s4: begin
         if ptr^ in ['0'..'9'] then begin
            n:= 10*n + integer(ptr^) - integer('0');
            if n>uniqueFileNameTabSize then
               n:= uniqueFileNameTabSize+1;
            end
         else exitloop:= true;
         end;
      end;
   fsforward(ptr);
   end;

if (ptr^=pendch) then begin
   // formatted as a temporary file name
   returnvalue:= 0; // Assume unused
   if n <=uniqueFileNameTabSize then
      if uniqueFileNameTab[n] then
         returnvalue:= n;
   end;

usedUniqueFileName:= returnvalue;

end;(* usedUniqueFileName *)



// (new: adding pOptions - alClean)
procedure ioin( pfilename: fsptr; pendch: char; pOptions: ioOptions; ppos: ioint32; pbinary: boolean;
   pprefrole: ioprefroles; var pconfig: string; pcircularbuffer: boolean;
   pEofAccept: boolean; var pinp: ioinptr);
(* Change input file.
  Implements <in filename/domain:portnr/comn:[,pos|option|config,[,...]]>
  Filename on format domain:portnr means internet stream.
  Filename = "cons" means use console.
  Filename = comn:, e.g. "com1:" means a serial port.
  Empty filename means use current file.
  pOptions=clean means do not add CR at the end even if last line was
  not terminated.
  -1-pos means use current pos.
  pbinary tells if file is binary or not (only valid when opened first time).
  the current state.
  Prefrole is for sockets and telle wether client or server role is preferred.
     (only valid when opened the first time)
  pconfig is for serial ports. E.g. "baud=19200 parity=n data=8 stop=1".
  pcircularbuffer is for communication between threads, instead of using a file.
  *)

var
filep, frp: filerecptr;
cnt: longint; empty: fsptr;
ior,ior1,ior2,ior3,ior4: ioint16;
found: BOOLEAN;
f: file;
fl: ioint32;
bufp1,bufp,bufend,p: ioinptr;
sameasbefore: boolean;
portnr: ioint32;
colonpos: fsptr;
strp: fsptr;
binbufp: ioCharPtr;
totalcnt,readsize: ioint32;
addrp: addrptr;
oldinfilep: filerecptr;
bufendptr: ioinptr;
SaveFileMode: byte;
lastchar: char;
filenr: integer;
ptr: fsptr;
error: boolean;
ch: char;
crPtr: ioinPtr;

// ++
charptr: ioinptr;
endptr: ioinptr;
charcnt: integer;
str: string;


count: integer; // ++

   procedure addChar(pch: char);
   begin
   (* Allocate a new buffer if necessary. *)
   if readsize=iobufsize-6 then begin
      (* This is copied from the repeat until-loop above. *)
      p:= ioinptr( ioint32(bufp) + iobufsize - 6);
      p^:= eobl;
      p:= ioinptr(ioint32(p)+1);
      p^:= char(0); // 0 free space
      GetMem(bufp,iobufsize);
      addrp^:= bufp; (* Next field of previous buffer *)
      p:= ioinptr( ioint32(bufp) + iobufsize - 6);
      p^:= eofs;
      p:= ioinptr(ioint32(p) + 1);
      p^:= eofs;
      p:= ioinptr(ioint32(p) + 1);
      addrp:= addrptr(p);
      addrp^:= nil; (* Next field of last block. *)
      readsize:= 0;
      bufend:= bufp;
      end;
   (* Append pch *)
   bufend^:= pCh;
   bufend:= ioinptr(ioint32(bufend)+1);
   readsize:= readsize+1;
   end;

begin

count:= 0;
found:= false;

oldinfilep:= curinfilep;

ioFindPortNr(pfilename,pendch,portnr,colonpos);

(* 0. Same input file as before? *)
sameasbefore:= false;
(* No filename: Use current file. *)
if pfilename^=pendch then sameasbefore:= true

else with curinfilep^ do
   if fsEqualFilename(pfilename,filename,pendch,eofs) then sameasbefore:= true;

if not sameasbefore then begin

   (* 2. Input pointer sanity check. *)
   with curinfilep^ do begin

      if (kind<>afile) and ( (ioint32(pinp) < ioint32(filebufp))
         or (ioint32(pinp) > ioint32(filebufend)) )
         then begin
         if (ioint32(pinp)<longint(unrbottom))
            or (ioint32(pinp)>ioint32(unrbufend))
            then
            xProgramError(
             'X (ioin): Program error. pinp outside buffer boundary.');
         end
      end; (*with*)

    (* 3. Try find it. *)
   if not xFault then begin

      if not found then begin

         filep:= iofindfile(pfilename,pendch);
         found:= (filep<>nil);

         (* 4. If it existed already then switch input *)
         if found then ioswitchinput(filep,pinp);
         end;
      end; (* not xFault *)
   end; (* not sameasbefore *)

if sameasbefore or found then
   iocheckoptionsexistingfile(curinfilep,pbinary,pprefrole,pcircularbuffer);

if not xFault and not (sameasbefore or found) then begin

   // Is it a serial port?
   if ioSerialPort(pfilename,pendch) then begin

      if pcircularbuffer then xScriptError(
            'X(<in ...>): Serial port not expected to use option circularbuffer.')

      else begin
         iomakeSerialPort(pfilename,pendch,pbinary,pconfig,pinp,frp);
         if not xFault then  (* success *)
            ioswitchinput(frp,pinp);
         end;
      end // serial port

   else if usedUniqueFileName(pfilename,pendch)=0 then
      // Return code: -1 = not formated as temporary file.
      //              0 = formatted as temporary file but not in use.
      //              >0 = number of temporary file.
      // Names on format tf#n are reserved for temporary files.
      xScriptError('X(ioin): Name of file ('+alfstostr(pfilename,pendch)+') has format '+
      'reserved for temporary files ("tf#n" where n is a number). Temporary '+
      'file names can be created and registered with <uniquefilename>, but '+
      alfstostr(pfilename,pendch)+' was not found among the registered unique file '+
      'names. Please do not use file names of the reserved format "tf#n" in '+
      'the scripts.')

   (* 6. Not existed already. Is it a file or a socket?. *)
   else if portNr=0 then begin

      if pcircularbuffer then begin

         (* Create a circular buffer. *)
         iomakeCircularBuffer(pfilename,pendch,frp);
         if not xFault then (* success *)
            ioswitchinput(frp,pinp);
         end (* circular buffer *)
      else begin
         (* A file - open it, create a buffer and
            read the file in its full length. *)

         (*$I-*) (* Turn off IO error exceptions. *)
         (* Close file just in case it was open. ioresult must be called
            after every io operation in case there was an error. *)
         ior:= 0;
         closeFile(f);
         ior1:= ioresult;

         assignFile(f,alfstostr(pfilename,pendch));
         ior2:= ioresult;

         (* Use filemode 0, because filemode 2 (default) causes access denied
            if the file is readonly. *)
         saveFileMode:= FileMode;
         FileMode:= fmOpenRead + fmShareDenyNone;(* (Allows opening a file that is
              already locked by another program) *)
         reset(f,1);
         ior3:= ioresult;
         FileMode:= SaveFileMode;

         (*$I+*)

         (* Ignore close error but recognize assign and open errors. *)
         if ior2<>0 then ior:= ior2
         else ior:= ior3;

         if ior<>0 then begin
            xScriptError('X(<in ...>) - Unable to open file "'
               +alfstostr(pfilename,pendch)+'" (Error code '+inttostr(ior)
               +'="'+SysErrorMessage(ior)+'").');
            end;

         if ior=0 then begin
            (* Find size of file. *)
            (*$I-*)
            fl:= filesize(f);
            ior:= ioResult;
            if ior<>0 then begin
               xProgramError('X(ioin): Program error - filesize does not work ('+
                  inttostr(ior)+').');
               closefile(f);
               // (Ignore error from closefile)
               ior4:= ioResult;
               end;
            (*$I+*)
            end;

         (* Allocate memory for file and eofs character. *)
         if ior=0 then begin

            totalcnt:= 0;
            (* allocate at least one block. *)
            GetMem(bufp1,iobufsize);
            bufp:= bufp1;

            (* Main read and allocate loop: *)
            repeat
               (* Initialize last 6 bytes of new buffer. *)
               p:= ioinptr( ioint32(bufp) + iobufsize - 6);
               p^:= eofs;
               p:= ioinptr(ioint32(p) + 1);
               p^:= eofs;
               p:= ioinptr(ioint32(p) + 1);
               addrp:= addrptr(p);
               addrp^:= nil;

               (* Read from file. *)
               readsize:= fl-totalcnt;
               if pbinary then begin
                  if readsize>((iobufsize-6) div 2) then
                  readsize:= ((iobufsize-6) div 2);
                  GetMem(binbufp,((iobufsize-6) div 2));
                  (*$I-*)
                  BlockRead(f,binbufp^,readsize,cnt);
                  ior:= ioResult;
                  if (ior<>0) or (cnt<>readsize) then begin
                     xProgramError('X(ioin): Program error - blockread does not work ('
                        +inttostr(ior)+').');
                     FreeMem(binbufp);
                     FreeMem(bufp);
                     closefile(f);
                     // (ignore error code from closefile)
                     ior4:= ioResult;
                     end;
                  (*$I+*)

                  if (ior=0) then begin
                     iobintohex(binbufp,cnt,iocharptr(bufp));
                     FreeMem(binbufp);
                     end;
                  end (* pbinary *)

               else begin (* not binary *)
                  if readsize>(iobufsize-6) then readsize:= iobufsize-6;
                  (*$I-*)
                  BlockRead(f,bufp^,readsize,cnt);
                  ior:= ioResult;
                  if (ior<>0) or (cnt<>readsize) then begin
                     if ior<>0 then xProgramError(
                        'X(ioin): Program error - blockread does not work ('
                        +inttostr(ior)+').')
                     else xProgramError(
                        'X(ioin): Program error - blockread does not work - cnt('
                        +inttostr(cnt)+')<>readsize('+inttostr(readsize)+').');
                     FreeMem(bufp);
                     closefile(f);
                     // (ignore error code from closefile)
                     ior4:= ioResult;
                     end
                  else begin
                    (* block read ok *)
                    bufendptr:= ioinptr(ioint32(bufp)+cnt);
                    ioscanforspecchars(bufp,bufendptr,pfilename,pendch)
                    end; (* block read ok *)

                   (*$I+*)
                  end; (* not binary *)

               totalcnt:= totalcnt+cnt;

               (* Allocate and link new buffer if necessary. *)
               if (totalcnt < fl) and (ior=0) then begin
                  p:= ioinptr( ioint32(bufp) + iobufsize - 6);
                  p^:= eobl;
                  p:= ioinptr(ioint32(p)+1);
                  p^:= char(0); // 0 free space
                  GetMem(bufp,iobufsize);

                  (*  ++ Debug ...
                  if count < 10 then begin
                     iofWriteToWbuf('++ bufp = ' + inttostr(integer(bufp)) + '.');
                     iofWriteWbufToResarea(false);
                     count:= count+1;
                     end;
                  *)

                  addrp^:= bufp;
                  end; (* totalcnt < fl and ... *)
               until (totalcnt>=fl) or (ior<>0);
            end; (* ior=0 *)

            

         (* Close file. *)
         if ior=0 then begin
            (*$I-*)
            closefile(f);
            ior:=IoResult;
            if ior<>0 then xProgramError(
               'X(ioin): Program error - closeFile does not work ('
               +inttostr(ior)+').');
            (*$I+*)
            end; (* ior=0 *)

         if ior=0 then begin (* success *)

            (*  Find end of last buffer. *)
            if pbinary then readsize:= readsize * 2;
            bufend:= ioinptr(ioint32(bufp)+readsize);
            crPtr:= NIL;

            (* If text file and not empty file and no line delimiter at end - add one: *)
            if not pbinary and (readsize>0) then begin
               lastchar:= ioinptr(ioint32(bufend)-1)^;
               if (lastchar<>char(10)) and (lastchar<>char(13)) then begin
                  // (new:)
                  // Append CR(LF) unless option "clean" was specified.

                  if not (ioClean in pOptions) then begin
                     // iofwcons('++ ioin: option clean not used => add CR.');
                     addChar(char(13));
                     crPtr:= ioinptr(integer(bufend)-1);
                     end
                     else begin

                     // iofwcons('++ ioin: option clean used => no extra CR.');
                     end;

                  (* BFn 2017-03-17: Removing LF. When closing an input file
                     which later was opened with <out ...>, x will try to remove
                     the added CR character. This would be very complicated if it
                     was CRLF and crossing a block boundary. Therefore LF is removed
                     because it is probably not needed. This however remains to be
                     tested.
                  addChar(char(10));
                  *)
                  end; (* last char was not end of line char *)
               end; (* not pbinary *)

            (* Append eofs. *)
            bufend^:= eofs;

            (* Create and initialise file record. *)
            frp:= iomakefile(pfilename,pendch,pbinary,bufp1,bufp,bufend,false,crPtr);

            (* Select this file. *)
            ioswitchinput(frp,pinp);
            end; (* ior=0 *)
         end; (* afile *)
      end (* portnr=0 *)

   else begin (* it is a new socket. *)
      if pcircularbuffer then xScriptError(
            'X(<in ...>): Internet socket is not expected to use option circularbuffer.')
      else begin
         iomakesocket(pfilename,pendch,pbinary,pprefrole,pinp,frp);
         if not xFault then  (* success *)
            ioswitchinput(frp,pinp);
         end;
      end; (* new socket *)
   end; (* not xFault and not (sameasebefore or found) *)

if not xFault then begin
   if ppos>=0 then ioseek(ppos,false,pinp);
   if pEofAccept then with curinfilep^ do begin
      if pinp^<>eofs then xScriptError(
         'X(ioin): Option "eofaccept" is used but input pointer is not at eof in file '+
            fstostr(filename)+'.')
      else if kind<>asocket then xScriptError(
         'X(ioin): Option "eofaccept" only meaningful for socket kind, but '+
         ' this file ('+fstostr(filename)+') is of kind '+
         kindToString(curinfilep)+'.')
      else if socketstate<>disconnected then xScriptError(
          'X(ioin): option "eofaccept" is only expected in disconnected socket '+
          'but file '+fstostr(filename)+' has socket state'+
          socketStateToString(curinfilep)+'.')
      else begin
         pinp^:=eofr;
         ioUpdateSocketState(curinfilep,pinp);
         end;
      end;
   end;

if not xFault then begin
   if pinp^=eofs then with curinfilep^ do begin
      (* Check if we have forgotten to close or reset the file. *)
      if eofatentry then begin
         if (pinp^=eofs) and (filebufp^<>eofs) then
            xScriptError(
               'X(ioin): Warning - file '+fstostr(filename)+' was not closed or reset since last '
               +'run and now points at end of file. '+'Suggestion: Use <close ...> and <in ...> '
               +'to reopen, or <in ...,0> to reset.');
         eofatentry:= false
         end;

      end;
   end;

end; (*ioin*)



const
oldnametabsize = 100;
var
oldnametab: array[1..oldnametabsize] of record
   nr: integer;
   name: string;
   end;
lastoldname: integer = 0;

procedure initoldnametab;
var i: integer;
begin
for i:= 1 to oldnametabsize do begin
   oldnametab[i].nr:= 0;
   oldnametab[i].name:= '';
   end;
end; (*initoldnametab*)

procedure saveoldfilename(pnr: integer; pname: fsptr);
begin
lastoldname:= lastoldname+1;
if lastoldname>oldnametabsize then lastoldname:= 1;
oldnametab[lastoldname].nr:= pnr;
oldnametab[lastoldname].name:= fstostr(pname);
end;


procedure ioinwithfilenr( pfilenr: integer; var pinp: ioinptr );
(* Restore to existing input file with nr = pfilenr.
   ioinwithfilenr is written after model from ioin (beginning of).
   ioinwithfilenr is used to restore input when input has changed in a
   function call, in a state call, or inside <localio ...> (and option
   persistent was not used). *)

var
filep: filerecptr;
found: boolean;
i: integer;

begin

if pfilenr=0 then ioswitchinput(nullinfilep,pinp)

else begin
   (* 2. Find file. *)
   filep:= files; found:= false;
   while not ( (filep=nil) or found ) do with filep^ do begin
      if nr=pfilenr then found:= true
      else filep:= filep^.next;
      end;

   if not found then begin
      // Try find name in oldnametab
      i:= 0;
      found:= false;
      while (i<oldnametabsize) and not found do begin
         i:= i+1;
         if oldnametab[i].nr=pfilenr then found:= true;
         end;

      if found then
         xScriptError('X: Tried to restore input file to "' +
            oldnametab[i].name + '" but the file was not available anymore. ' +
            'It may have been closed or deleted.')
      else
         xScriptError('X: Tried to restore input file but the file was not '+
            'available anymore. It may have been closed or deleted.');
      end
   else ioswitchinput(filep,pinp);
   end;

end; (* ioinwithfilenr *)


procedure iosetinpsave( pinp: ioinptr );
(* Update input pointer so that other thread is not misleaded (because it
   start from other file). *)

begin
    with curinfilep^ do begin

        (* Check pointer within bounds, when possible. *)
        if (kind<>afile) and ( (ioint32(pinp) < ioint32(filebufp))
            or (ioint32(pinp) > ioint32(filebufend)) )
            then begin
            if (ioint32(pinp)<longint(unrbottom))
               or (ioint32(pinp)>ioint32(unrbufend))
               then begin
               xProgramError(
                'X (iosetinpsave): Program error. pinp outside buffer boundary.');
               end;
            end;

        (* Update input pointer.  *)
        inpsave:= pinp;
        end;

end; (*iosetinpsave*)


procedure ioinfilename( pfilename: fsptr );
(* Return name or domain:portnr of current input file. *)
begin
fscopy(curinfilep^.filename,pfilename,eofs);
end; (*ioinfilename*)

function ioinfilenamestr: string;
(* Return name or domain:portnr of current input file, as stringh *)
begin
ioinfilenamestr:= fstostr(curinfilep^.filename);
end;

procedure iooutfilename( pfilename: fsptr);
(* Return name or domain:portnr of current output file. *)
begin
if curoutfilep<>nil then fscopy(curoutfilep^.filename,pfilename,eofs);
end; (*iooutfilename*)


procedure ioUniqueFileName(pfuncret: fsptr);
(* <uniqueFileName> (Creates and returns a file name, intended for temporary
   usage, that is guaranteed different from other temporary file names.
   Also, it is not saved on disk unless explicitly by <close ...>. Names are
   on format "tf#n", where n is a number. *)
var
found: boolean;
i: integer;

begin

i:= 1;
found:= false;
while (i<=UniqueFileNameTabSize) and not found do begin
   if not uniqueFileNameTab[i] then found:= true
   else i:= i+1;
   end;

if found then begin
   uniqueFileNameTab[i]:= true;
   fspshend(pfuncret,'t');
   fspshend(pfuncret,'f');
   fspshend(pfuncret,'#');
   fsbitills(i,pfuncret);
   end
else begin
   xScriptError('ioUniqueFileName: This script appears to use a lot of tempo-'+
      'rary file names. X has a table for '+inttostr(uniqueFileNameTabSize)+
      ' temporary file names, but this script appears to need more.');
   end;

end;// (ioUniqueFileName)


function ionext(pbufp: ioinptr): ioinptr;
(* Return address of next buffer, given address of current buffer.
   Usage example (to fine last buffer in a file):
   bufp:= filebufp;
   nextbuf:= ionext(bufp);
   while not (nextbuf=NIL) do begin
      bufp:= nextbuf;
      nextbuf:= ionext(bufp)
      end;
   *)
var
p: ioinptr;
addrp: addrptr;
begin
p:= ioinptr(ioint32(pbufp) + iobufsize - 4);
addrp:= addrptr(p);
ionext:= addrp^;
end; (*ionext*)

function ioinpos( pinp: ioinptr ): ioint32;
(* Return current position in file or consbuf. First position =0.
   Other positions are expressed as the address of pinp.
   Implements <inpos>. *)
var inpos: ioint32; bufp: ioinptr;
cnt: ioint16; ix: ioint32;
begin

inpos:= 0;
(* Are we in unread buffer? *)
(*if ( ioint32(pinp)>=ioint32(unrbufp) )
    and ( ioint32(pinp)<=ioint32(unrbufend) )
    then begin
    xScriptError(
'X(<inpos>): <inpos> function is not valid in unread buffer.');
    // pinp:= curinfilep^.unrbranchptr;
    end; *)

(* Console, socket or file? *)
(* These tests removed because inpos can in all cases only be used
   when it is certain that the data in the buffers does not change. *)
(*
with curinfilep^ do if kind=aconsole then begin
    inpos:= 0;
    xScriptError(
'X(<inpos>): <inpos> function is not valid in console.');
    end
else if kind=asocket then begin
    xScriptError('X(<inpos>): Unable to determine pos in internet socket ('
    +fstostr(filename) +').');
    end
else if kind=aserialport then begin
    xScriptError('X(<inpos>): Unable to determine pos in a serial port ('
    +fstostr(filename) +').');
    end
else if kind=acircularbuffer then begin
    xScriptError('X(<inpos>): Unable to determine pos in a circular buffer port ('
    +fstostr(filename) +').');
    end
else if kind=afile then begin (* file *)
    if pinp=curinfilep^.filebufp then inpos:= 0
    else inpos:= ioint32(pinp);
    //end;
ioinpos:= inpos;
end; (*ioinpos*)


function iooutpos: ioint32;
(* Return current position in output file or consbuf. First position =0.
   Other positions are expressed as the address in file (outp).
   Implements <outpos>. *)
var outpos: ioint32;
begin
outpos:= 0;

if curoutfilep=NIL then
   xScriptError('Unable to determine pos in outfile when outfile is undefined (nil).')
(* Console, socket or file? *)
else with curoutfilep^ do if kind=aconsole then begin
    outpos:= 0;
    xScriptError(
'X(<outpos>): <outpos> function is not valid in console.');
    end
else if kind=asocket then begin
    xScriptError('X(<outpos>): Unable to determine pos in internet socket ('
    +fstostr(filename) +').');
    end
else if kind=aserialport then begin
    xScriptError('X(<outpos>): Unable to determine pos in a serial port ('
    +fstostr(filename) +').');
    end
else if kind=acircularbuffer then begin
    xScriptError('X(<outpos>): Unable to determine pos in a circular buffer port ('
    +fstostr(filename) +').');
    end
else if kind=afile then begin (* file *)
    if outp=filebufp then outpos:= 0
    else outpos:= ioint32(outp);
    end;
iooutpos:= outpos;
end; (*iooutpos*)


function ioinreadrescnt: ioint32;
(* Return read reservation count for current input file. *)
begin
ioinreadrescnt:= curinfilep^.readrescnt;
end; (*ioinreadrescnt*)


procedure iosendsbuf( pfrp: filerecptr);
(* Send all unsent bytes in this sockets sendbuf. *)
var length: ioint32;
binaryodd: boolean; (* Binary file and odd number of char's in sendbuf *)
last: ioinptr;
errco: integer;
sendptr: ioinptr;
fail: boolean;
BytesWritten: Cardinal;
retrycounter: integer;

begin

(* pfrp^ is a socket *)

with pfrp^ do if outp<>sendbufp then
   // Prevent recursive calls from error handling
   if sbfcallcnt=0 then begin

   sbfcallcnt:= sbfcallcnt+1;
    length:= ioint32(outp)-ioint32(sendbufp);
    binaryodd:= False;
    if binaryfile then begin
        if (length and 1) <> 0 then begin
            binaryodd:= True;
            length:= length-1;
            end;
        iohextobin(sendbufp,length,sendbufp);
        length:= length div 2;
        end;
    if length>0 then begin

        if kind=asocket then begin

          (* Send if connected. *)
          if (socketState=connectedAsClient) or (socketState=connectedAsServer)
          then begin

              if SEND(sockhand,sendbufp^,length,0) = SOCKET_ERROR then begin
                  errco:= wsagetlasterror;
                  if (errco=wsaeconnaborted) or (errco=wsaeconnreset) then
                    (* - no error message - Connected closed from other side. *)
                  else xScriptError(
                    'X(iosendsbuf) (socket '+fstostr(filename)+
                    '): Send function failed('+inttostr(errco)+').');
                  closesocket(sockhand);
                  sockhand:= socket( PF_INET,SOCK_STREAM,0 );
                  socketstate:= disconnected;
                  end; (*if SEND ..*)
              end;(*connectedAs...*)
          end (* socket *)
        else if kind=aserialport then begin
          sendptr:= sendbufp;
          fail:= false;
          retrycounter:= 2;
          while (length>0) and not fail do begin
            if not windows.WriteFile(ComHand,sendPtr^,length,BytesWritten,Nil)
              then begin
              errco:= getLastError;
              xProgramError('X(iosendsbuf) (serial port '+fstostr(filename)+
                '): WriteFile function failed('+inttostr(errco)+').');
              fail:= true;
              end
            else if BytesWritten=0 then begin
               retrycounter:= retrycounter-1;
               if retrycounter>0 then begin
                  (* Wait a short while to check that it is not the sendbuffer being full.
                     50 ms = 5 bytes at 100 baud. *)
                  ioEnableAndSleep(50);
                  end
               else begin
                  xScriptError('X(iosendsbuf) (serial port '+fstostr(filename)+
                   '): WriteFile reported bytesWritten=0 after 2 retries - connection broken?.');
                  fail:= true;
                  end;
               end
				else begin
              sendPtr:= ioinptr(ioint32(sendPtr)+BytesWritten);
              length:= length-BytesWritten;
              // Reset retry counter
              retrycounter:= 2;
              end;
            end; // while ...
          end
        else xProgramError(
          'X(iosendsbuf) (file '+fstostr(filename)+
          '): Program error - socket or serial port was expected.');

        (* Update outp pointer. *)
        if binaryodd then begin
            last:= ioinptr(ioint32(outp)-1);
            sendbufp^:= last^;
            outp:= ioinptr(ioint32(sendbufp)+1);
            end
        else outp:= sendbufp;
        end; (* length> 0 *)

    sbfcallcnt:= sbfcallcnt-1;
    end; (*with ... if ... if*)

end; (*sendsbuf*)

procedure iosenddata;
(* Send all unsent socket or serial port data.
   Used by alsleep so that output is not delayed by sleep. *)
var filep: filerecptr;
begin
filep:= files;
while not (filep=NIL) do begin
  if (filep^.kind=asocket) or (filep^.kind=aserialport) then iosendsbuf(filep);
  filep:= filep^.next;
  end;
end; (*iosenddata*)

procedure iochecksbuf;
(*
   Check if <out> is a socket or a serial port,
   if so send content of sendbuf to socket.
   Typical usage:
   (At end of alwrite:)
   	iochecksbuf;
*)
begin
with curoutfilep^ do if (kind=asocket) or (kind=aserialport) then begin
    (* See if there is something to send. *)
    if outp<>sendbufp then iosendsbuf(curoutfilep);
    end;
end; (*iochecksbuf*)

function ioReadableSocket(pHandle:Tsocket): boolean; forward;

function ioReadableSocketWait(pHandle:Tsocket;ptimeoutms:integer): boolean;
(* Return True if a recv call would not block. Wait up to
   ptimeoutms for socket to become readable.
   Used by ioingetinput to avoid lockup if there is no
   data from a tcp/ip port. *) forward;

function ioReadableSerialPort(pHandle:Thandle): boolean; forward;

function ioBytesToRead(pHandle: tsocket): integer; forward;

function iorecvtimeout(var pstring: string; pbuf: ioinptr; pbuflen: integer): integer;
(* Read from a string, resembling recv. *)
var inp: ioinptr; i: integer;
begin
inp:= pbuf;
i:= 0;
while i < min(length(pstring),pbuflen) do begin
   i:= i+1;
   inp^:= pstring[i];
   inp:= ioinptr(ioint32(inp)+1);
   end;
delete(pstring,1,i);
iorecvtimeout:= i;

end; (*iorecvtimeout*)


// (new:)
procedure iorecv(pfilep: filerecptr; pblocking: boolean);
(* Read data from a socket. Note: If called from current input: inpsave
   must be set = pinp before calling iorecv, or not yet read data will b
   overwritten!
   If pblocking, read data even if it involvs waiting, and assume there
   is free buffer space available. Otherwise: read only if there is data to
   read and free buffer space available.
   If timeoutstring is not empty: Read from timeoutstring instead of from socket. *)
var
reclength: ioint32;
rembufsize, bufsize: ioint32;
inp,p: ioinptr;
binbuf: array[1..iobufsize] of char;
skip: boolean;
testinp: ioinptr;
saveChar: char;

begin

skip:= false;

with pfilep^ do if inpsave^<>eofr then
   xProgramError('X(iorecv): Program error - inpsave<>eofr.')

else if (kind=asocket) and ( (socketState=connectedAsServer)
   or (socketstate=connectedAsClient) ) then begin

   // If not blocking: check if anything to read
   if not pblocking then
      if not ioreadablesocket(pfilep^.sockhand) then skip:= true;

   if not skip then begin
      (* 3. Calculate remaining buffer size and start receiving. *)
      (* Do not overwrite readpos with data. *)
      if integer(readpos)>integer(inpsave) then
         rembufsize:= integer(readpos)-integer(inpsave)
      else rembufsize:= integer(filebufend) - integer(inpsave);

      (* Do not overwrite readpos with eofr+eofs. *)
      testinp:= ioinptr(integer(inpsave)+rembufsize);
      if testinp=filebufend then testinp:= filebufp;
      if testinp=readpos then rembufsize:= rembufsize-1
      else begin
         testinp:= ioinptr(integer(testinp)+1);
         if testinp=filebufend then testinp:= filebufp;
         end;
      if testinp=readpos then rembufsize:= rembufsize-1;
      if rembufsize<0 then rembufsize:= 0;
      if rembufsize=0 then begin
         if pblocking then
            // Free buffer space is assumed to be available
            xScriptError(
            'X(iorecv): X uses input buffer size '+inttostr(iobufsize)+' bytes for '+
               'tcp/ip connections, but this script appears read more than that from '+
               'connection '+fstostr(filename)+' before processing the data.')
         else skip:= true; // Not blocking - skip read (used by <read *>)
         end;
      end;// (not skip)

   recLength:= 0;

   if not skip then begin

      if binaryfile then begin
         (* Convert binary data to hex format *)
         bufsize:= rembufsize div 2;

         (* Rembufsize div 2 is always at least 1 since rembufsize>=2. *)
         if bufsize=0 then xProgramError(
            'X(iorecv): Program error (bufsize=0).');

         inp:= ioinptr(@binbuf[1]);
         while not (ioreadableSocket(sockhand) or ioclosing) do ioEnableAndSleep(10);
         if not ioclosing then begin
            ioenableotherthreads(3);
            try
               reclength:= recv(sockhand,inp^,bufsize,0);
            finally
               iodisableotherthreads(3);
               end;
            if reclength<>SOCKET_ERROR then begin
               iobintohex(iocharptr(@binbuf),reclength,iocharptr(inpsave));
               reclength:= reclength*2;
               end;
            end; (* not closing *)
         end (* binary file *)

      else begin
         // Not binary file
         while not (ioreadablesocket(sockhand) or ioclosing) do ioEnableAndSleep(10);
         if not ioclosing then begin
            //ioenableotherthreads(4); (removed because next recv is expected to return immidiately)
            try
               // (new:)
               (* Note! If this code works stable, it ought to be inserted also for
                  serialports and perhaps for circular buffers. *)
               // Remove leading LF if previous char was CR
               if prevWasCR then begin
                  saveChar:= inpsave^;
                  reclength:= recv(sockhand,inpsave^,1,0);
                  // iodisableotherthreads(4); (see ioenableotherthreads above)
                  if (recLength>0) then begin
                     prevWasCR:= false;
                     if inpSave^=char(10) then begin
                        // Delete read character.
                        inpSave^:= saveChar;
                        recLength:= 0;
                        // Continue reading after LF
                        if not pblocking and not ioreadablesocket(sockhand) then skip:= true
                        else begin
                           // Wait for more data, or closing
                           while not (ioreadablesocket(sockhand) or ioclosing) do begin
                              ioEnableAndSleep(10);
                              end;
                           if not ioclosing then begin
                              reclength:= recv(sockhand,inpsave^,rembufsize,0);
                              end;
                           end;
                        end// char(10)
                     end;// (recLength>0)
                  end // (prevWasCR)

               else begin
                  reclength:= recv(sockhand,inpsave^,rembufsize,0);
                  end;
               if ioinptr(integer(inpsave)+reclength-1)^=char (13) then
                  prevWasCR:= true;

            finally
               // iodisableotherthreads; (see ioenableotherthreads above)
               end;
            end;
         end;// (not binary file)

      if not skip then begin
         if ioclosing then
            inpsave^:= eofs;

         if (reclength=0) or (reclength=SOCKET_ERROR) then begin
            inpsave^:= eofs; (* broken connection. *)
            closesocket(sockhand);
            sockhand:= socket( PF_INET,SOCK_STREAM,0 );
            socketstate:= disconnected;
            end
         else begin

            if reclength<=0 then
              xProgramError('X(iorecv): Program error - reclength>0 was expected.');

            (* Scan for special characters. *)
            ioscanforspecchars(inpsave,ioinptr(ioint32(inpsave)+reclength),filename,eofs);

            (* Update socket status. *)
            ioupdateSocketState(pfilep,inpsave);

            (* add eofr and (as an extra guard) eofs. *)
            p:= ioinptr(ioint32(inpsave) + reclength);

            if ioint32(p) > (ioint32(filebufend)-1) then p:= filebufp;
            p^:= eofr;
            endp:= p;
            p:= ioinptr( ioint32(p) + 1);
            if ioint32(p)>(ioint32(filebufend)-1) then p:= filebufp;
            p^:= eofs;
            SetEvent(writeEvent);
            end;
         end; // not skip

      end; // not skip
   end (*with*)

else xProgramError('x(iorecv): Program error - unexpected kind or socketstate.');

if (pfilep^.inpsave^=eofr) and pblocking then xProgramError('X(iorecv) - program error: Inpsave<>eofr was expected. '
+' Skip='+inttostr(integer(skip))+' pblocking='+inttostr(integer(pblocking))
+' reclength='+inttostr(reclength)+'.');


end; (*iorecv*)

// (old:)
procedure iorecv0(pfilep: filerecptr; pblocking: boolean);
(* Read data from a socket. Note: If called from current input: inpsave
   must be set = pinp before calling iorecv, or not yet read data will b
   overwritten!
   If pblocking, read data even if it involvs waiting, and assume there
   is free buffer space available. Otherwise: read only if there is data to
   read and free buffer space available.
   If timeoutstring is not empty: Read from timeoutstring instead of from socket. *)
var
reclength: ioint32;
rembufsize, bufsize: ioint32;
inp,p: ioinptr;
binbuf: array[1..iobufsize] of char;
(*saferembufsize,extra: ioint32; *)
skip: boolean;
testinp: ioinptr;

begin

skip:= false;

with pfilep^ do if inpsave^<>eofr then
   xProgramError('X(iorecv): Program error - inpsave<>eofr.')

else if (kind=asocket) and ( (socketState=connectedAsServer)
   or (socketstate=connectedAsClient) ) then begin

   (* 3. Calculate remaining buffer size and start receiving. *)
   (* New version: *)
   (* Do not overwrite readpos with data. *)
   if integer(readpos)>integer(inpsave) then
     rembufsize:= integer(readpos)-integer(inpsave)
   else rembufsize:= integer(filebufend) - integer(inpsave);

   (* Do not overwrite readpos with eofr+eofs. *)
   testinp:= ioinptr(integer(inpsave)+rembufsize);
   if testinp=filebufend then testinp:= filebufp;
   if testinp=readpos then rembufsize:= rembufsize-1
   else begin
      testinp:= ioinptr(integer(testinp)+1);
      if testinp=filebufend then testinp:= filebufp;
      end;
   if testinp=readpos then rembufsize:= rembufsize-1;
   if rembufsize<0 then rembufsize:= 0;
   if rembufsize=0 then begin
      if pblocking then
         // Free buffer space is assumed to be available
         xScriptError(
         'X(iorecv): X uses input buffer size '+inttostr(iobufsize)+' bytes for '+
            'tcp/ip connections, but this script appears read more than that from '+
            'connection '+fstostr(filename)+' before processing the data.')
      else skip:= true; // Not blocking - skip read (used by <read *>)
      end;

   // If not blocking: check if anything to read
   if not pblocking then
      if not ioreadablesocket(pfilep^.sockhand) then skip:= true;

   recLength:= 0;

   if not skip then begin

      if binaryfile then begin
         (* Convert binary data to hex format *)
         bufsize:= rembufsize div 2;

         (* Rembufsize div 2 is always at least 1 since rembufsize>=2. *)
         if bufsize=0 then xProgramError(
            'X(iorecv): Program error (bufsize=0).');

         inp:= ioinptr(@binbuf[1]);
         while not (ioreadableSocket(sockhand) or ioclosing) do ioEnableAndSleep(10);
         if not ioclosing then begin
            ioenableotherthreads(3);
            try
               reclength:= recv(sockhand,inp^,bufsize,0);
            finally
               iodisableotherthreads(3);
               end;
            if reclength<>SOCKET_ERROR then begin
               iobintohex(iocharptr(@binbuf),reclength,iocharptr(inpsave));
               reclength:= reclength*2;
               end;
            end; (* not closing *)
         end (* binary file *)
     else begin
        while not (ioreadablesocket(sockhand) or ioclosing) do ioEnableAndSleep(10);
        if not ioclosing then begin
           ioenableotherthreads(4);
           try
              reclength:= recv(sockhand,inpsave^,rembufsize,0);
           finally
              iodisableotherthreads(4);
              end;
           end;
        end;
     if ioclosing then
        inpsave^:= eofs;

     if (reclength=0) or (reclength=SOCKET_ERROR) then begin
        inpsave^:= eofs; (* broken connection. *)
        closesocket(sockhand);
        sockhand:= socket( PF_INET,SOCK_STREAM,0 );
        socketstate:= disconnected;
        end
     else begin

        if reclength<=0 then
          xProgramError('X(iorecv): Program error - reclength>0 was expected.');

        (* Scan for special characters. *)
        ioscanforspecchars(inpsave,ioinptr(ioint32(inpsave)+reclength),filename,eofs);

        (* Update socket status. *)
        ioupdateSocketState(pfilep,inpsave);

        (* add eofr and (as an extra guard) eofs. *)
        p:= ioinptr(ioint32(inpsave) + reclength);
        if ioint32(p) > (ioint32(filebufend)-1) then p:= filebufp;
        p^:= eofr;
        endp:= p;
        p:= ioinptr( ioint32(p) + 1);
        if ioint32(p)>(ioint32(filebufend)-1) then p:= filebufp;
        p^:= eofs;
        SetEvent(writeEvent);
        end;
     end; // not skip
   end (*with*)

else xProgramError('x(iorecv): Program error - unexpected kind or socketstate.');

if (pfilep^.inpsave^=eofr) and pblocking then xProgramError('X(iorecv) - program error: Inpsave<>eofr was expected. '
+' Skip='+inttostr(integer(skip))+' pblocking='+inttostr(integer(pblocking))
+' reclength='+inttostr(reclength)+'.');


end; (*iorecv0*)



var testnr: integer = 0;
printed: boolean = false;

// (new: with prevWasCR)
procedure iorecvSerial(pfilep: filerecptr; pBlocking: boolean);
(* Read data from a serial port. Note: If called from current input: inpsave
   must be set = pinp before calling iorecvserial, or not yet read data will b
   overwritten! *)
var
rembufsize, bufsize: ioint32;
binbuf: array[1..iobufsize] of char;
BytesRead,i: cardinal;
p: ioinptr;
ResultOk,skip: Boolean;
saveChar: char;
testinp: ioinptr;

time0: integer;
time1,time2,time3,time4,time5,time6,time7,time8,time9,time10: integer;
rembufsizelt500: boolean; // ++ Tell when readpos is close after inpsave.
lfremoved: boolean; // +++

begin

lfremoved:= false;
bytesread:= 0;

with pfilep^ do if inpsave^<>eofr then
   xProgramError('X(iorecvserial): Program error - inpsave<>eofr.')

else if kind<>aserialport then
     xProgramError('x(iorecvSerial): Program error - aSerialPort was expected.')

else if ioreadableserialport(pfilep^.comHand) or pBlocking then begin

   (* 3. Calculate remaining buffer size and start receiving. *)

   (* Do not overwrite readpos with data. *)
   rembufsizelt500:= false; // ++
   if integer(readpos)>integer(inpsave) then begin
      rembufsize:= integer(readpos)-integer(inpsave);
      if rembufsize<500 then rembufsizelt500:= true; // ++
      end
   else rembufsize:= integer(filebufend) - integer(inpsave);

   if alflagga('e') then begin
      if not printed then begin
         iofwcons('filebufp=' + inttostr(qword(filebufp)) +
            'filebufend=' + inttostr(qword(filebufend)) + '.');
         printed:= true;
         end;
      end;

   (* Do not overwrite readpos with eofr+eofs. *)
   testinp:= ioinptr(integer(inpsave)+rembufsize);
   if testinp=filebufend then testinp:= filebufp;
   if testinp=readpos then rembufsize:= rembufsize-1
   else begin
      testinp:= ioinptr(integer(testinp)+1);
      if testinp=filebufend then testinp:= filebufp;
      end;
   if testinp=readpos then rembufsize:= rembufsize-1;
   if rembufsize<0 then rembufsize:= 0;
   if rembufsize=0 then begin
      // Free buffer space is assumed to be available
      xScriptError(
         'X(iorecvserial): X uses input buffer size '+inttostr(iobufsize)+' bytes for '+
         'serial ports, but this script appears read more than that from '+
         'port '+fstostr(filename)+' before processing the data.');
      (* Debug:
      xScriptError(
         'X(iorecvserial): ++ Program error - insufficient buffer size.'+
         ' Raise iobufsize and recompile X.'+
         '(readpos='+inttostr(integer(readpos))+
         ', inpsave='+inttostr(integer(inpsave))+
         ', testinp='+inttostr(integer(testinp))+
         ', filebufp='+inttostr(integer(filebufp))+
         ', filebufend='+inttostr(integer(filebufend))+
         ', rembufsize='+inttostr(integer(rembufsize))+
         ', ++ recvcount='+inttostr(integer(recvcount))+
         ').') *)
      end;

   bytesread:= 0;

   // At this state, file is either readable, or call is blocking
   if binaryfile then begin
      (* Convert binary data to hex format *)
      bufsize:= rembufsize div 2;

      (* Rembufsize div 2 is always at least 1 since Rembufsize >= 2. *)
      if bufsize=0 then xProgramError(
         'X(iorecvserial): Program error (bufsize=0).');

      while (bytesRead=0) and not ioclosing do begin
         Try
            ioenableotherthreads(5);
            ResultOk:= windows.readFile(comHand,binbuf,bufsize,BytesRead,nil)
         finally
            iodisableotherthreads(5);
         end;
         If ResultOk then begin
            iobintohex(iocharptr(@binbuf),bytesRead,iocharptr(inpsave));
            BytesRead:= BytesRead*2;
            end
         else xProgramError('X(iorecvserial): Program error - ReadFile failed (#1).');
         end; (* not closing *)
      end
   else begin
      // not binaryfile
      if pblocking then begin
         // Wait for data...
         while not (ioreadableserialPort(comHand) or ioclosing) do ioEnableAndSleep(10);
         end;
      bytesRead:= 0;
      skip:= false;
      while (bytesRead=0) and not (ioclosing or skip) do begin
         Try
            ioenableotherthreads(6);
            // ++
            testnr:= testnr+1;
            time0:= gettickcount;
            time1:= 0;
            time2:= 0;
            time3:= 0;
            time4:= 0;
            time5:= 0;
            time6:= 0;
            time7:= 0;
            time8:= 0;
            time9:= 0;
            time10:= 0;

            // (new:)
            // Remove leading LF if previous char was CR
            if prevWasCR then begin
               time1:= gettickcount;
               // Read one char
               ResultOk:= windows.readFile(comHand,binbuf,1,BytesRead,nil);
               // (tcpip: reclength:= recv(sockhand,inpsave^,1,0);)
               if (bytesRead>0) then begin
                  if binbuf[1]=char(10) then begin
                     // Delete read character.
                     //iofwcons('++ iorecvserial: Char('+inttostr(qword(binbuf[1]))+') removed.');
                     prevWasCR:= false;
                     bytesRead:= 0;
                     lfremoved:= true;
                     // Continue reading after LF
                     time2:= gettickcount;
                     if ioreadableserialPort(comHand) then
                        ResultOk:= windows.readFile(comHand,binbuf,rembufsize,BytesRead,nil)
                     else if pblocking then begin
                        // Wait for more data, or closing
                        while not (ioreadableserialPort(comHand) or ioclosing) do begin
                           // Use simple sleep because other threads are already enabled.
                           ioSimpleSleep(10);
                           end;
                        if not ioclosing then begin
                           ResultOk:= windows.readFile(comHand,binbuf,rembufsize,BytesRead,nil)
                           end;
                        end // (pblocking)
                     else skip:= true; // No data avilable and not blocking: Leave while loop
                     end// char(10)
                  end;// (recLength>0)
               end // (prevWasCR)

            else begin
               // Normal (not prevWasCR)
               // Here: Either data is available, or call is blocking.
               time3:= gettickcount;
               ResultOk:= windows.readFile(comHand,binbuf,rembufsize,BytesRead,nil);
               time4:= gettickcount;
               // (tcpip: reclength:= recv(sockhand,inpsave^,rembufsize,0);)
               end;

            // Update prevWasCr
            if bytesread>0 then
               prevWasCR:= binbuf[BytesRead]=char(13);

         finally
            iodisableotherthreads(6);
         end;

         (* ++ *)
         if alFlagga('E') then begin
            //binbuf[bytesread+1]:= char(0);

            iofWritelnToWbuf('++ iorecvserial: received "'+ansiLeftStr(binbuf,bytesread)+
               '", last 2 char = ('+inttostr(integer(binbuf[bytesread-1]))+' '+
               inttostr(integer(binbuf[bytesread]))+').');
            //iofWritelnToWbuf('++ iorecvserial: received ('+inttostr(bytesread)+') "'+ansiLeftStr(binbuf,bytesread)+'".');
            iofWritelnToWbuf('   '+'readpos='+inttostr(integer(readpos))+', inpsave='+inttostr(integer(inpsave))+').');
            if not ResultOk then
               iofWritelnToWbuf('   ResultOk = False!');
            if rembufsizelt500 then
               iofWritelnToWbuf('   Remaining buffer size<500 bytes!');
            end;

         // ++
         time10:= gettickcount;
         if (time1-time0>0) then
            iofWritelnToWbuf('++ iorecvserial(pblocking='+booltostr(pBlocking)+
               ') (nr '+inttostr(testnr)+'): time spent in ReadFile='+
               inttostr(time10-time0)+':' +
               'time0-4, 10 = (' + inttostr(time0)+' '+ inttostr(time1)+' '+
               inttostr(time2)+' '+ inttostr(time3)+' '+ inttostr(time4)+' '+
               inttostr(time10)+')'+
               '.');

         If ResultOk then begin
            for i:= 1 to BytesRead do
               iocharptr(ioint32(inpsave)+i-1)^:= binbuf[i];
            end
         else xProgramError('X(iorecvserial): Program error - ReadFile failed (#2).');
         if bytesread=0 then ioEnableAndSleep(1000);
         end;
      if bytesread>0 then begin
         (* Scan for special characters. *)
         p:= ioinptr(ioint32(inpsave) + bytesread);
         ioscanforspecchars(inpsave,p,filename,eofs);
         end;
      end;

   // ++:
   recvcount:= recvcount + bytesread;

   if ioclosing then inpsave^:= eofs;

   if bytesread>0 then begin

      (* add eofr and (as an extra guard) eofs. *)
      p:= ioinptr(ioint32(inpsave) + bytesread);
      if ioint32(p) > (ioint32(filebufend)-1) then p:= filebufp;
      p^:= eofr;
      endp:= p;
      p:= ioinptr( ioint32(p) + 1);
      if ioint32(p)>(ioint32(filebufend)-1) then p:= filebufp;
      p^:= eofs;
      SetEvent(writeEvent);
      end;
   end; (*with*)

if lfremoved then recvafterlfcnt:= 0
else if bytesread>0 then recvafterlfcnt:= recvafterlfcnt+1;

end; (*iorecvSerial*)


// (old: without prevWasCR)
procedure iorecvSerial0(pfilep: filerecptr);
(* Read data from a serial port. Note: If called from current input: inpsave
   must be set = pinp before calling iorecvserial, or not yet read data will b
   overwritten! *)
var
rembufsize, bufsize: ioint32;
binbuf: array[1..iobufsize] of char;
BytesRead,i: cardinal;
p: ioinptr;
ResultOk: Boolean;
testinp: ioinptr;

time0,time1: integer;
rembufsizelt500: boolean; // ++ Tell when readpos is close after inpsave.

begin

with pfilep^ do if inpsave^<>eofr then
   xProgramError('X(iorecvserial): Program error - inpsave<>eofr.')

else if kind=aserialport then begin

   (* 3. Calculate remaining buffer size and start receiving. *)

   (* Do not overwrite readpos with data. *)
   rembufsizelt500:= false; // ++
   if integer(readpos)>integer(inpsave) then begin
      rembufsize:= integer(readpos)-integer(inpsave);
      if rembufsize<500 then rembufsizelt500:= true; // ++
      end
   else rembufsize:= integer(filebufend) - integer(inpsave);

   (* Do not overwrite readpos with eofr+eofs. *)
   testinp:= ioinptr(integer(inpsave)+rembufsize);
   if testinp=filebufend then testinp:= filebufp;
   if testinp=readpos then rembufsize:= rembufsize-1
   else begin
      testinp:= ioinptr(integer(testinp)+1);
      if testinp=filebufend then testinp:= filebufp;
      end;
   if testinp=readpos then rembufsize:= rembufsize-1;
   if rembufsize<0 then rembufsize:= 0;
   if rembufsize=0 then begin
      // Free buffer space is assumed to be available
      xScriptError(
         'X(iorecvserial): X uses input buffer size '+inttostr(iobufsize)+' bytes for '+
         'serial ports, but this script appears read more than that from '+
         'port '+fstostr(filename)+' before processing the data.');
      (* Debug:
      xScriptError(
         'X(iorecvserial): ++ Program error - insufficient buffer size.'+
         ' Raise iobufsize and recompile X.'+
         '(readpos='+inttostr(integer(readpos))+
         ', inpsave='+inttostr(integer(inpsave))+
         ', testinp='+inttostr(integer(testinp))+
         ', filebufp='+inttostr(integer(filebufp))+
         ', filebufend='+inttostr(integer(filebufend))+
         ', rembufsize='+inttostr(integer(rembufsize))+
         ', ++ recvcount='+inttostr(integer(recvcount))+
         ').') *)
      end;

   bytesread:= 0;
   if binaryfile then begin
      (* Convert binary data to hex format *)
      bufsize:= rembufsize div 2;

      (* Rembufsize div 2 is always at least 1 since Rembufsize >= 2. *)
      if bufsize=0 then xProgramError(
         'X(iorecvserial): Program error (bufsize=0).');

      while (bytesRead=0) and not ioclosing do begin
         Try
            ioenableotherthreads(5);
            ResultOk:= windows.readFile(comHand,binbuf,bufsize,BytesRead,nil)
         finally
            iodisableotherthreads(5);
         end;
         If ResultOk then begin
            iobintohex(iocharptr(@binbuf),bytesRead,iocharptr(inpsave));
            BytesRead:= BytesRead*2;
            end
         else xProgramError('X(iorecvserial): Program error - ReadFile failed (#1).');
         end; (* not closing *)
      end
   else begin
      // not binaryfile
      while not (ioreadableserialPort(comHand) or ioclosing) do ioEnableAndSleep(10);
      bytesRead:= 0;
      while (bytesRead=0) and not ioclosing do begin
         Try
            ioenableotherthreads(6);
            // ++
            testnr:= testnr+1;
            time0:= gettickcount;

            ResultOk:= windows.readFile(comHand,binbuf,rembufsize,BytesRead,nil);

         finally
            iodisableotherthreads(6);
         end;

         (* ++ *)
         if alFlagga('E') then begin
            binbuf[bytesread+1]:= char(0);

            iofWritelnToWbuf('++ iorecvserial: received ('+inttostr(bytesread)+') "'+ansiLeftStr(binbuf,bytesread)+'".');
            iofWritelnToWbuf('   '+'readpos='+inttostr(integer(readpos))+', inpsave='+inttostr(integer(inpsave))+').');
            if not ResultOk then
               iofWritelnToWbuf('   ResultOk = False!');
            if rembufsizelt500 then
               iofWritelnToWbuf('   Remaining buffer size<500 bytes!');
            end;


         // ++
         time1:= gettickcount;
         if (time1-time0>0) then
            iofWritelnToWbuf('++ iorecvserial (nr '+inttostr(testnr)+'): time spent in ReadFile='+inttostr(time1-time0)+'.');

         If ResultOk then begin
            for i:= 1 to BytesRead do
               iocharptr(ioint32(inpsave)+i-1)^:= binbuf[i];
            end
         else xProgramError('X(iorecvserial): Program error - ReadFile failed (#2).');
         if bytesread=0 then ioEnableAndSleep(1000);
         end;
      if bytesread>0 then begin
         (* Scan for special characters. *)
         p:= ioinptr(ioint32(inpsave) + bytesread);
         ioscanforspecchars(inpsave,p,filename,eofs);
         end;
      end;

   // ++:
   recvcount:= recvcount + bytesread;

   if ioclosing then inpsave^:= eofs;

   if bytesread>0 then begin

      (* add eofr and (as an extra guard) eofs. *)
      p:= ioinptr(ioint32(inpsave) + bytesread);
      if ioint32(p) > (ioint32(filebufend)-1) then p:= filebufp;
      p^:= eofr;
      endp:= p;
      p:= ioinptr( ioint32(p) + 1);
      if ioint32(p)>(ioint32(filebufend)-1) then p:= filebufp;
      p^:= eofs;
      SetEvent(writeEvent);
      end;
   end (*with*)

else xProgramError('x(iorecvSerial): Program error - aSerialPort was expected.');

end; (*iorecvSerial0*)

function ioselect( pinp: ioinptr; var pfilenames: iofilenametab; pnfiles: integer;
    pendch: char; ptimeoutms: integer): integer;
(* Wait until one of the files have input data to read. Then return
   1-10 (index to pfilenames) to identify which file that has input to read.
   Used by <select fn1,fn2,...> to be able to read from multiple tcp/ip ports,
   serial ports and circular buffers simultaneously. If ptimeout=0, return 0
   immidiately if no data available.
   pfilenames[1..pnfiles] (pnfiles is max 10) contains the names of the files
   to select from.
   If timeoutms<maxint, wait for data during timeoutms and then return with
   0 if no data was available.
   Return the number of the file in pfilenames, which has data to read,
   or 0 if timeout and no source has data. *)
var
 ftab: array[1..10] of filerecptr;
 selectedFnum,fnum,nfail: integer;
 filep: filerecptr;
 readfds: TFDSet;
 timeout: TTimeVal;
 n: longint;
 selectCalled: boolean;
 skip: boolean;
 timems,tvms: integer;
 timetowaitms: integer;
 connectiontimeout: boolean;

begin
// Tentatively removed because it should not be needed and it delays 16 ms: ioEnableAndSleep(1);

(* Update inpsave in current file to avoid special case in the following
   code. *)
curinfilep^.inpsave:= pinp;

(* 1. Find files. And check if either file already has data to read.
   Create a table ftab, containing the pointers to the filedesciptors for the
   files which shall be used for waiting
   for data. *)
fnum:= 1; selectedFnum:= 0; filep:= nil;
nfail:= 0; (* Number of files in pfilenames, which cannot produce data, because
   it does not exist, or is of wrong kind, or is disconnected (tcp/ip).
   The corresponding entries in ftab are nil. *)
timems:= 0; (* There are two timeout loops, one inner when waiting for data
   and one outer, when waiting for at least one open connection. *)
connectiontimeout:= false;

(* Outer loop to wait for an open connection. *)
repeat

(* Loop through pfilenames. Exit if a file is found that already has
   data available (selectedFnum>0). Otherwise, create a file table (ftab)
   of files for which it is possible to wait for data. The inactive entries
   in this table are are counted in nfail. *)
while (fnum<=pnfiles) and (selectedFnum=0) do begin
   filep:= iofindfile(pfilenames[fnum],pendch);
   ftab[fnum]:= nil;
   if filep=nil then begin
      xScriptError('X(<select ...>): File "'+xfstostr(pfilenames[fnum],pendch)
         + '" does not exist.');
      ftab[fnum]:= nil;
      nfail:= nfail+1;
      end
   else if filep^.kind=asocket then with filep^ do begin

      (* 2. Try connect if not already connected. *)
      if (socketstate=unbound) or (socketstate=listening) then
         ioupdateSocketState(filep,pinp);

      (* Check if data is available already. Eof is regarded as data
         here, because it can be read by the <eof> function. *)
      if (filep^.inpsave^<>eofr) then begin
         // Data available, no need to wait.
         selectedFnum:= fnum;
         end

      else begin
         // No source with data yet found (selectedFnum=0).

         (* Check that socket is connected, then add to list of files to
            wait for. *)
         if (socketstate=connectedAsServer)
            or (socketState=connectedAsClient) then ftab[fnum]:= filep
 
         else begin
            (* (Accept unconnected sockets, return 0 if all were unconnected.) *)
            ftab[fnum]:= nil;
            nfail:= nfail+1;
            end;
         end; (* selectedFnum=0 *)
      end (* kind= asocket *)

   else if filep^.kind=aserialport then with filep^ do begin

      (* Check if data is available already. *)
      if (filep^.inpsave^<>eofr) then selectedFnum:= fnum

      // No - put serial port in ftab for wait below
      else ftab[fnum]:= filep;
      end (* kind= aserialport *)

   else if (filep^.kind=acircularbuffer) or (filep^.kind=afile)
      then with filep^ do begin

      (* Check if data is available already. *)
      if (filep^.inpsave^<>eofr) then selectedFnum:= fnum

      // No - put circular buffer in ftab for wait below
      else ftab[fnum]:= filep;
      end (* kind= acircularbuffer *)

   else begin
      xScriptError('X(<select ...>): File "'+xfstostr(pfilenames[fnum],pendch)
         +'" is not a file, a socket, a serialport or a circular buffer (select is only '
         +'implemented for these).');
      ftab[fnum]:= nil;
      nfail:= nfail+1;
      end;
   fnum:= fnum+1;
   end; (*while*)

(* 3. Data already available? *)
if selectedFnum>0 then begin
   // No more to do.
   end

(* 4. Check if any files to wait for. *)
else if nfail=pnfiles then
   (* There are no active entries in ftab (all are nil). This means that it is
      currently not possible to wait for data from any of the files in pfilenames table.
      Wait instead for a connection to open in the outer loop, until timeout. *)

(* 5. Wait for the active entries in ftab. *)
else begin

   // (selectedFnum=0 and there is at least one active entry in ftab)

   (* 6. Wait for data or timeout (=skip). *)
   skip:= false;
   timems:= 0;
   while (selectedFnum=0) and not skip do begin

      // Look for all tcp/ip connections
      readfds.fd_count:= 0;
      n:= 0;
      for fnum:= 1 to pnfiles do if ftab[fnum]<>nil
         then if ftab[fnum].kind=asocket
         then with readfds do begin
         fd_count:= fd_count+1;
         fd_array[fd_count-1]:= ftab[fnum]^.sockhand;
         end;
 
      (* {0,10000} = 10 ms timeout *)
      tvms:= 10;
      if timems+tvms>ptimeoutms then tvms:= ptimeoutms-timems;
      with timeout do begin
         tv_sec:= 0;
         tv_usec:= tvms*1000;
         end;
 
      selectCalled:= false;
      if readfds.fd_count>0 then begin
         ioenableotherthreads(7);
         try
            n:= select(0,@readfds,nil,nil,@timeout);
         finally
            iodisableotherthreads(7);
            end;
         selectCalled:= true;
         if n=socket_error then begin
            xProgramError('X(<select ...>): Error from select ('+
               inttostr(WSAGetLastError)+').');
            skip:= true;
            end
         else if n=0 then begin
            (* (0 = timeout). *)
            timems:= timems+10;
            if ptimeoutms<maxint then begin
               if timems>=ptimeoutms then skip:= true;
               end;
            end
         else if n>0 then begin
            (* 5. Identify one readable socket. *)
            for fnum:= 1 to pnfiles do if ftab[fnum]<>nil then begin
               if ftab[fnum].sockhand=readfds.fd_array[0] then selectedFnum:= fnum;
               end;
            if selectedFnum=0 then begin
               xProgramError('X(<select ..>): Program error - selected socket not found.');
               skip:= true;
               end;
            end;
         end; // fd_count>0
 
      // Look for serial ports
      fnum:= 0;
      while (selectedFnum=0) and (fnum<pnfiles) do begin
         fnum:= fnum+1;
         if ftab[fnum]<>nil
            then if ftab[fnum].kind=aserialport
            then if ioreadableSerialPort(ftab[fnum].comHand)
            then selectedfnum:= fnum;
         end;
 
      // Look for circular buffers or files
      fnum:= 0;
      while (selectedFnum=0) and (fnum<pnfiles) do begin
         fnum:= fnum+1;
         if ftab[fnum]<>nil
            then if ((ftab[fnum].kind=acircularbuffer) or (ftab[fnum].kind=afile))
               and (ftab[fnum].inpsave^<>eofr)
            then selectedfnum:= fnum;
         end;
 
      // Add time delay if not already done in looking for sockets
      (* BFn 171221: Timeout seems to be disabled when select for
         tcp/ip ports has been called - Why? *)
      if not selectCalled and (selectedfnum=0) then begin
         ioEnableAndSleep(10);
         timems:= timems+10;
         if ptimeoutms<maxint then
            if timems>=ptimeoutms then skip:= true;
         end;
      end; (*while selectedFnum=0*)
   end; (* selectedFnum=0 *)

if (selectedFnum=0) and (nfail=pnfiles) then begin
   // No connection open
   if ptimeoutms=0 then
      // No time out. Wait 100 ms each turn
      ioEnableAndSleep(100)
   else if timems<ptimeoutms then begin
      timetowaitms:= 100;
      if (timems + timetowaitms>ptimeoutms) then timetowaitms:= ptimeoutms-timems;
      ioEnableAndSleep(timetowaitms);
      timems:= timems+timetowaitms;
      end
   else
      // Time out
      connectionTimeout:= true;
	end;

   // End of outer loop to handle timeout when there is no open connection
   until (nfail<pnfiles) or connectiontimeout;


(* 6. Return selectedFnum. *)
ioselect:= selectedFnum;

end; (*ioselect*)

var errstr: string;


(* ++ (old:) For debug:
procedure checkPointerInSerialPort(
   pprocname: string;
   pinp: ioinptr;
   pnewpinp: ioinptr
   );
begin

   if (integer(pinp)>=integer(curinfilep^.filebufp)) and (integer(pinp)<integer(curinfilep^.filebufend)) or (pinp=NIL) then
      if (integer(pnewpinp)<integer(curinfilep^.filebufp)) or (integer(pnewpinp)>=integer(curinfilep^.filebufend)) then
         xProgramError('++ '+pprocname+': New pointer was expected to land within buffer ('+
            inttostr(integer(curinfilep^.filebufp))+'..'+inttostr(integer(curinfileP.filebufend))+
            ') but was found to be outside ('+inttostr(integer(pnewpinp))+').');
end;
*)


(* (new: Handling pBlocking separately for each file type instead of calling
   itself blocking if pBlocking was false and and ioinreadable(...) was true). *)
procedure ioingetinput( var pinp: ioinptr; pblocking: boolean );
(* Shall only be called when pinp^=eofr (end of fragment).
   If infile = console: Read one line to console input buffer.
   If infile = asocket: Call winsock recv function.
   if infile = afile: If other thread has the same file open for output:
      Wait for data or eofs.
   Otherwise: do nothing.
   if pblocking= false: Return immediately if no data available from
   asocket or aserialport. *)
var starti,stopi,i: integer;
l: INTEGER;
str: string;
newhandle: TSocket;
ior: ioint16;
inp: ioinptr;
res: dword;
giveup: boolean;
lastcharp: ioinptr;
count: integer;
lastreadcount: integer;
previnp: ioinptr;

begin

(* 1. Check that we are standing at eofr. *)
if pinp^<>eofr then begin
   inp:= pinp;
   errstr:= '';
   i:= 0;
   while (i<10) and (integer(inp^)<=integer(eofr)) do begin
      if inp^=char(0) then errstr:= errstr+'\0'
      else errstr:= errstr+inp^;
      inp:= ioinptr(integer(inp)+1);
      i:= i+1;
      end;
   if integer(inp^)>=integer(eofr) then errstr:= errstr+inp^
   else errstr:= errstr+'...';

   xProgramError('X(ioingetinput): pinp^=eofr was expected but '+
      errstr+' was found.')
   end

(* (old: Removed because ioingetinput can block if the next char is LF and
   new new data after that has yet arrived)
else if not pblocking then begin
   if ioinreadable(pinp) then
      ( * Call ioingetinput recursively this time with pblocking=true
         because we know it will not block. * )
      if pinp^=eofr then ioingetinput(pinp,true);
   end
*)

else with curinfilep^ do
   (* 1. Check that pinp is pointing into the buffer (unless it is afile
      because it uses >1 buffers). *)
    if (kind<>afile)
        and ((ioint32(pinp)<ioint32(filebufp))
        or (ioint32(pinp) > ioint32(filebufend))) then
        xProgramError(
        'X(ioingetinput): Program error (pinp outside filebuf).')

else if kind=aconsole then begin (* console *)

   (* Console is always considered not blocking - it is always possible
      to retrieve a line from the user. *)

   (* 2. Give other threads a chance to get in. *)
   ioEnableAndSleep(1);

   (* 3. Read a line from the console. *)
   iofreadln(str);

   (* 4. Check its length (reserve 6 bytes for eobl, eofs and next block pointer,
      and 3 bytes for cr, eofr and eofs). *)
   l:= length(str);
   if l> iobufsize-9 then begin
      xScriptError('X(ioingetinput): Maximum line length ('+
         inttostr(iobufsize)+ 'exceeded.');
      l:= iobufsize-9;
      str[l+1]:= char(13);
      end;

   (* 5. Count empty lines. *)
   if l=0 then ioemptylines:= ioemptylines+1
   else ioemptylines:= 0;

   (* 6. Add line delimiter (iofreadln does not do it). *)
   str:= str+char(13);
   l:= l+1;

   (* 7. Copy it to consbuf. *)
   inp:= pinp; lastcharp:= nil;
   if ioint32(inp)>=ioint32(filebufend) then inp:= filebufp; (* (not possible?) *)
   for i:= 1 to l do begin
      if i=l then lastcharp:= inp; (* place for cr (or eof) *)
      inp^:= str[i];
      inp:= ioinptr(ioint32(inp)+1);
      if ioint32(inp)>=ioint32(filebufend) then begin
         ioscanforspecchars(pinp,filebufend,filename,eofs);
         inp:= filebufp;
         end;
      end;
   if ioint32(inp)<ioint32(pinp) then
      (* Pointer has crossed end of file buf. The part between pinp and
         filebufend was already checked in the loop above. Now test
         from beginning of buffer to inp. *)
      ioscanforspecchars(filebufp,inp,filename,eofs)
   else
      // Test from pinp to inp.
      ioscanforspecchars(pinp,inp,filename,eofs);

   (* 5. Change cr to end of file instead if this is the 4th
      empty line in a row. *)
   if ioemptylines=4 then begin
      iofshowmess('Four empty lines from console - regarded as end of file.');
      lastcharp^:= eofs;
      ioemptylines:= 0;
      (* (cons eof is removed in beginning of next enterString in xioform.pas,
         through a call to ioResetConsEof). *)
      end;

   (* 7. Terminate with eofr and, as an extra guard, put eofs
      behind it. *)
   inp^:= eofr;
   endp:= inp;
   inp:= ioinptr(ioint32(inp)+1);
   if ioint32(inp)>=ioint32(filebufend) then inp:= filebufp;
   inp^:= eofs;
   end (*console*)

(* socket? *)
else if kind=asocket then begin

   (* 2a. Try connect if not connected client. *)
   if (socketstate=unbound) or (socketstate=listening) then begin
      ioEnableAndSleep(10); // (Necessary?)
      ioupdateSocketState(curinfilep,pinp);
      end;

    (* 2b. IfpBlocking: Wait until connected or error: *)
    if pblocking then begin
      while ((socketstate=listening)
         or (socketstate=unbound) and (preferredRole=ioclient))
         and not iodoingcleanup do begin
         ioEnableAndSleep(100);
         ioupdateSocketState(curinfilep,pinp);
         end;// (while)
      end; // (pblocking)

   (* 3. Receive if connected, unless already received in ioupdatesocketstate. *)
   if ((socketstate=connectedAsServer) or (socketState=connectedAsClient))
      and (pinp^=eofr) then begin

      inpsave:= pinp;

      if pBlocking then begin
         (* Wait blocking until data or socket closed . *)
         while pinp^=eofr do begin
            if ioreadablesocketwait(sockhand,1000) then begin
               if pinp^<>eofs then iorecv(curinfilep,true);
               if pinp^=eofr then xProgramError(
                 'X(ioingetinput): Program error - data from socket "'
                 +fstostr(curinfilep^.filename)+'" was expected (w/o timeout).');
               end;
            end; (*while*)
         end// (pBlocking)
      else
         // Not pblocking
         iorecv(curinfilep,false);

      end;// (connected and eofr)

   (* 4. if pblocking and no result: Give up. *)
   if pBlocking and (pinp^=eofr) then pinp^:=eofs;

   end (* socket *)

(* serial port? *)
else if kind=aserialport then begin

   (* Receive from serial port. *)
   inpsave:= pinp;
   // (new:)
   iorecvSerial(curinfilep,pblocking);

   (* (old:)
   if pblocking then iorecvSerial(curinfilep)
   else begin
      if ioreadableserialport(curinfilep^.comHand) then
         iorecvSerial(curinfilep);
      end;
   *)

   (* if pblocking and no result: Give up. *)
   if pblocking and (pinp^=eofr) then
      pinp^:=eofs;
   end (* serial port *)

(* ordinary file? Only blocking read is possible here. This code is
   probably antiquated and should be removed, since circular buffers
   now are used for communication between threads. *)
else if (kind=afile) then begin
   if pBlocking then begin
      giveup:= false;
      while not ((pinp^<>eofr) or giveup) do begin

         (* If another thread is writing to it, then wait for more data. *)
         if (writeEvent>0) and (outthreadnr<>-1) and (outThreadNr<>alThreadnr) then begin
            datarequest:= true;
            ioenableotherthreads(8);
            try
               res:= waitforsingleobject(writeEvent,1000);
            finally
               iodisableotherthreads(8);
            end;
            datarequest:= false;
            if res = WAIT_TIMEOUT then begin
               (* Timeout - check if we are doing cleanup (should
                  we use waitformultiple instead of timeout for this?). *)
               if iodoingcleanup and (pinp^=eofr) then
                  pinp^:= eofs

               (* Or sender has changed output file. *)
               else if (outthreadnr=-1) and (pinp^=eofr) then begin
                  pinp^:= eofs;
                  xScriptError('X(ioingetinput): Thread was waiting for data '+
                     'but sender changed output file.');
                  end (* sender changed output file *)
               else if not pblocking then
                  giveup:= true;
               end; (* timeout *)
            end (* there is another thread which can write data. *)
         (* Else (same thread): Change to end of file. *)
         else begin
            (* This is removed because <writeeof> appears not no
              be used anywhere, and circular buffers shall be used
              instead of files to communicate between threads.
              In future, consider always ending files with eofs
              in iooutwrite, thereby removing the possibility
              to use files for inter-thread communication.
              /BF 2007-05-10. *)
            (* if althreadcount>0 then
               xScriptError('X(ioingetinput): If threads are used, '
               + 'output files are expected to be ended with <writeeof>. ');*)
            pinp^:= eofs;
            end; (* no other thread writing to this file. *)
         end; (*while*)
      end;//(pBlocking)
   end (*afile*)

(* circular buffer? *)
else if (kind=acircularbuffer) then begin
   if pblocking then begin

      count:= 0;
      while (pinp^=eofr) do begin

         (* If another thread is writing to it, then wait for more data. *)
         if (outthreadnr>0) and (outthreadnr<>althreadnr) then begin
            ioErrmessWithDebugInfo('X(ioingetinput): It appears as if a circular buffer is both read and written by the same thread.');
            pinp^:= eofs;
            end
         else if writeEvent>0 then begin
            lastreadcount:= readcount;
            datarequest:= true;
            ioenableotherthreads(9);
            try
               res:= waitforsingleobject(writeEvent,1000);
            finally
               iodisableotherthreads(9);
            end;
            datarequest:= false;
            if res = WAIT_TIMEOUT then begin
               (* Timeout - check if we are doing cleanup (should
                  we use waitformultiple instead of timeout for this?). *)
               if iodoingcleanup and (pinp^=eofr) then
                  pinp^:= eofs
               end; (* timeout *)
            (* Close after 10 seconds if there is no read activity in X. *)
            if readcount<>lastreadcount then count:= 0
            else count:= count+1;
            if count>10 then begin
               xScriptError('X(ioingetinput) - Attempt to read from circular buffer "' +
                  fstostr(filename) + '" when it is empty and no read activity in X during 10 s.' +
                  'Aborting by setting circular buffer to end of file. ');
               pinp^:= eofs;
               end;
            end (* there is another thread which can write data. *)
         else begin
            (* No write event available. Just wait for 10 seconds, then give up. *)
            ioEnableAndSleep(100);
            count:= count+1;
            if count>100 then begin
               xScriptError('X(ioingetinput) - No one started to write to circular buffer so reader gave up after 10 s.');
               pinp^:= eofs;
               end;
            end;
         end; (*while*)
      end // (pBlocking)
   else begin
      (* Non blocking read from circular buffer, just return, eofr
         will be removed automatically by the other side once data is
         available. *)
      (* BFn 2016-04-22: This could also be caused by reading from a file that
         is also being written to. *)
      end;

   end; (*acircularbuffer*)

(* (Tr4483) If first char is LF (and not binary) and previous was CR, move to next
   (like in ioinforward). This shall hopefully prevent reading of orphan 'LF's.
   (/BFn 2012-09-21).
   BFn 121129: It does not solve the problem bacause xcallstate saves the pointer
   to the beginning of the string and resets the cinp pointer after each failed
   alternative. And next time, ioinforward will be called instead of ioingetinput
   and it does not do this test. This test is better moved to iorecv, but then
   it will only work for sockets (not for serialports and circularbuffers) *)
with curinfilep^ do if kind in [asocket,aserialport,acircularbuffer] then begin

   if (pinp^=char(10)) and (not binaryfile) then begin
      // (LF)
      if integer(pinp)<=integer(filebufp) then
         previnp:= ioinptr(integer(filebufend)-1)
      else previnp:= ioinptr(integer(pinp)-1);
      if previnp^=char(13) then begin  // (CR)
         // Move to next char
         ioinforward(pinp);
         if pinp^=eofr then ioingetinput(pinp,pblocking);
         end;
      end;
   end;

end; (*ioingetinput*)

procedure ioResetConsEof( var pstateenv: xstateenv );
   var inp: ioinptr; s: boolean;
begin
   if curinfilep=consfilep then inp:= pstateenv.cinp
   else inp:= consfilep^.inpsave;

   // (new:)
   (* When running <play hexbitsDelphiMod> there was an error below because
      cons pointer was still in unread buffer, and it was pointing at ff ff ff
      for a reason I do not know. The code below is to leave the unreadbuffer
      when returning from having executed a string from the console. *)
   (* Removed because this shall be handled at the end of the state (unrpop and
      restoreio):
   if (integer(inp)>=integer(unrbufp)) and (integer(inp)<=integer(unrbufend)) then
      if (integer(consfilep^.unrendptr)>=integer(unrbufp)) and
         (integer(consfilep^.unrendptr)<=integer(unrbufend)) then
         inp:= consfilep^.unrbranchptr;
   *)

   while (inp^<char(ioeofr)) do ioinforward(inp);
   if inp^=char(fseofs) then begin
      // Replace it with CR (which it was before) and read past it
      inp^:= char(13);
      ioinforward(inp);
      end;

   // eofr expected here
   if inp^<> char(ioeofr) then begin
      // Restore to eofs
      inp^:= char(fseofs);
      xProgramError('X(ioResetConsEof): Expected eofr after eofs but found ' +
         'instead char ' + inttostr(integer(inp^)) + '.');
      end

   else begin
      (* Save the new position as readpos (if current file) or as current
         input position (if not current file). *)
      if curinfilep=consfilep then begin
         pstateenv.cinp:= inp;
         ioinadvancereadpos(inp)
         end
      else consfilep^.inpsave:= inp;
      end;

   if xunr.active then
      s:= unrCheckRelease(consfilep,inp);


end;(* ioResetConsEof *)


// (old:)
procedure ioResetConsEof0( var pstateenv: xstateenv );
   var inp: ioinptr;
begin
   if curinfilep=consfilep then inp:= pstateenv.cinp
   else inp:= consfilep^.inpsave;

   while (inp^<char(ioeofr)) do ioinforward(inp);
   if inp^=char(fseofs) then begin
      // Replace it with CR (which it was before) and read past it
      inp^:= char(13);
      ioinforward(inp);
      // eofr expected here
      if inp^<> char(ioeofr) then begin
         // Restore to eofs
         inp^:= char(fseofs);
         xProgramError('X(ioResetConsEof): Expected eofr after eofs but found ' +
            'instead char ' + inttostr(integer(inp^)) + '.');
         end

      else begin
         (* Save the new position as readpos (if current file) or as current
            input position (if not current file). *)
         if curinfilep=consfilep then begin
            pstateenv.cinp:= inp;
            ioinadvancereadpos(inp)
            end
         else consfilep^.inpsave:= inp;
         end;
      end;
end;(* ioResetConsEof0 *)


procedure ioinreservereadpos(pinp: ioinptr; var pfilep: iofileptr);
(* Set readpos unless reserved, advance the reservation counter and
   return a pointer to the current input file. Used
   to prevent <p n> from being overwritten because readpos
   is advanced in called states. *)
begin
   if curinfilep^.readrescnt=0 then begin
      if not ioinunrbuf(pinp) then
         curinfilep^.readpos:= pinp;
      end;

   curinfilep^.readrescnt:= curinfilep^.readrescnt+1;
   pfilep:= iofileptr(curinfilep);

end; (* ininreservereadpos *)


procedure ioinreleasereadpos(pfilep: iofileptr);
(* Decrement readpos reservation counter for file pfilep. See readpos. *)
var filep: filerecptr;
finished: boolean;
begin
if pfilep=iofileptr(curinfilep) then
   curinfilep^.readrescnt:= curinfilep^.readrescnt-1
else begin
   // Check that file still exists
   filep:= files;
   finished:= false;
   while not finished do begin
      if filep=Nil then finished:= true
      else if filep=filerecptr(pfilep) then finished:= true
      else filep:= filep^.next;
      end;

   if filep=nil then xProgramError(
      'ioinrelease: Program error - unable to find file where ' +
      'to advance the read pointer')
   else filep^.readrescnt:= filep^.readrescnt-1;
   end;
end; // (ioinreleasereadpos)

(* ioReadRescnt
   ------------
   Return current read reservation count (debug purpose).
*)
function ioreadrescnt: integer;
begin
   ioreadrescnt:= curinfilep^.readrescnt;
end;

procedure ioinadvancereadpos(pinp: ioinptr);
(* Update read consume pointer in current input file. See readpos. *)
begin

if not ioinunrbuf(pinp)  then begin
   curinfilep^.readpos:= pinp;
   if curinfilep^.readrescnt<>0 then
      xProgramError('ioinadvancereadpos: Expected readrescnt=0 when pfilen=nil but ' +
         'found readrescnt=.');
   end;

end; // (ioinadvancereadpos)


procedure ioinclearcons( var pinp: ioinptr );
(* If infile = console: Clear input buffer.
   Otherwise: do nothing. *)
var inp: ioinptr;
begin
if curinfilep^.kind=aconsole then with curinfilep^ do begin
    pinp:= filebufp;
    pinp^:= eofr;
    curinfilep^.endp:= pinp;
    inp:= ioinptr(ioint32(pinp)+1);
    inp^:=eofs;
    end;
end; (*ioinclearcons*)

var ovfcount: integer = 0;

procedure iopushpn( var ppars: xparsrecord; var pdatamoved: boolean );
(* Push <p n> parameters to prevent them from being overwritten by unread.
   Return pdatamoved= true if any data was moved. *)
var i: ioint16;
initstacktop,ip,oldstacktop: ioinptr;
overflow: boolean;

begin
overflow:= false;
pdatamoved:= false;
initstacktop:= pnstacktop;
with ppars do  for i:= 1 to npar do with par[i] do begin
   if fs<> nil then (* - *)
   else if ( ioint32(atp) < ioint32(unrbufp) )
      or ( ioint32(atp) > ioint32(unrbufend) ) then (* - *)
      (* atp outside unread buffer: Do not push on stack. *)
      (* (A <p n> cannot start in a file and end in unread buffer - so only
         atp need to be checked). *)
   // As it works:
   // else if xunr.active and false then
   // As it should work:
   else if xunr.active and true then
      // Not necessary to move pn parameter strings.
      (* 180512: Tried not to move pn parameter when xunr active but
         filtersvs then crashed. *)
   else begin

      // atp is in unread buffer.
      pdatamoved:= true;
      ip:= atp; oldstacktop:= pnstacktop;

      (* (BF 4/3-05: Should we also check that afterp or atp is >= unrbuf?)
         2016-11-27: Yes (afterp). Running testunread.log otherwise causes
         overflow because afterp was below unrbuf. *)
// (new:)
      if (ioint32(afterp) <= ioint32(unrbufend)) and
         (ioint32(afterp) >= ioint32(unrbufp)) then begin
         (* Both atp and afterp are in unread buffer. Use addition instead
            ioinforward, for higher speed. *)
// (old:) if ioint32(afterp) <= ioint32(unrbufend) then begin
         while not ((ip=afterp) or overflow) do begin
            pnstacktop^:= ip^;
            ip:= ioinptr(ioint32(ip)+1);
            pnstacktop:= ioinptr(ioint32(pnstacktop)+1);
            if integer(pnstacktop)>=integer(unrbottom) then overflow:= true
            end;
         if not overflow then begin
            atp:= oldstacktop;
            afterp:= pnstacktop;
            end;
         end

// (new:)
      else begin
// (old:) else if ioint32(atp) <= ioint32(unrbufend) then begin
         (* atp is in unread buffer, but not afterp. Use ioinforward to
            increment input pointer. *)
         while not ((ip=afterp) or overflow) do begin
            pnstacktop^:= ip^;
            ioinforward(ip);
            pnstacktop:= ioinptr(ioint32(pnstacktop)+1);
            if integer(pnstacktop)>=integer(unrbottom) then overflow:= true
            end;
         if not overflow then begin
            atp:= oldstacktop;
            afterp:= pnstacktop;
            end;
         end;

      (* bits function uses also the character pointed at by afterp. *)
      if (i=npar) and (bitsAs>0) then begin
         pnstacktop^:= ip^;
         pnstacktop:= ioinptr(ioint32(pnstacktop)+1);
         end;
      end; (* fs=nil and atp is in unread buffer *)
   end; (* with ppars *)

pnsl:= pnsl+1;
if (pnsl>iomaxcalllevel) and not xfault then xScriptError(
   'X(<c ...>: Too deep calling level ('+inttostr(pnsl)+').')

else pnstack[pnsl]:= initstacktop;

if overflow then
  xScriptError(
  'X(iopushpn): Unable to save <p ...> parameters (unread buffer full).');

end; (*iopushpn*)

procedure iopoppn;
begin
with curinfilep^ do if pnsl<=0 then
  iodebugmess('x(iopoppn): Program error, pnsl<=0. ')
else begin
  if pnsl<=iomaxcalllevel then pnstacktop:= pnstack[pnsl];
  pnsl:= pnsl-1;
  end;
end;


function iolocalstring: boolean;
(* Tell if we are in a local string (<in ...,string,local>).
   Used by ioin to prevent change of input file while processing string. *)
begin
iolocalstring:= (unrstacktop>0);
end;

procedure iounread( pstr: fsptr; pendch: CHAR; pmode: iounrmode; var pstateenv: xstateenv );
(* Unread a string so as if it was inserted before the current
   position (pinp). This does not alter the input file buffer
   (or consbuf) it uses its own buffer.
   If pmode=push, then add eofs at end of pstr, and push save pointer to this pos.
   If pmode=pop, then go to character following eofs. Pop pointer stack.
   In pstateenv, cinp and inpback are used. *)

var
endstr: fsptr; strl: ioint32;
remSpace: ioint32;
fsp: fsptr;
dmess: string; (* debug *)
startp,stopp,ptr: ioinptr;
overflow: boolean;
count: integer;
unrsize,pnsize: ioint32;
extraeofs: boolean;
filep: filerecptr;

begin

if alflagga('D') then begin
   dmess:= '->iounread("'+xfstostr(pstr,pendch)+'")';
   if curinfilep^.kind=aconsole then dmess:= dmess+'(console)'
   else dmess:= dmess+'(file)';
   iodebugmess(dmess);
   end;

(* 0. Handle unr push stack. *)
if pmode=iounrpush then begin
   if unrstacktop=unrstacksize then xScriptError(
      'x(<in push,...>): Error - stack full (>'+inttostr(unrstacksize)+').');
   unrstacktop:= unrstacktop+1;
   if unrstacktop<=unrstacksize then with unrstack[unrstacktop] do begin
      inp:= pstateenv.cinp;
      statecalllevel:= xstateCallLevel;
      oldInFilep:= curInFilep;
      end;
   end
else if pmode=iounrpop then begin
   if unrstacktop<=0 then xScriptError('X(<in pop>): Too many pops.')
   else begin
      if unrstacktop>unrstacksize then with curinfilep^ do begin
         if (integer(pstateenv.cinp)<=integer(unrbufend)) and
            (integer(pstateenv.cinp)>=integer(unrbufp)) then begin
            while pstateenv.cinp^<>eofs do ioinforward(pstateenv.cinp);
            if integer(pstateenv.cinp)<integer(unrbufend) then pstateenv.cinp:= ioinptr(integer(pstateenv.cinp)+1)
            else xProgramError(
               'iounread: Program error: Unexpected boundary break after unrpop.');
            end;
         end
      else begin

         with unrstack[unrstacktop] do begin
            // (new:)
            // Check that pop is done in the same file as push
            if curInFilep<>oldInFilep then begin
               // Input file has changed after push, change it back.
               // check that old infile still exists.
               filep:= files;
               while not ((filep=oldInFilep) or (filep=NIL)) do filep:= filep^.next;
               if filep<>nil then ioswitchinput(oldInFilep,pstateenv.cinp)
               else xScriptError('When leaving a state using <in ...,string>, ' +
                  'the original input file was expected to still exist, but it did not.');
               end;

            pstateenv.cinp:= inp;
            if xStateCallLevel<>statecalllevel then
               xScriptError(
                  'X(<in pop>): Warning - <in Pop> at different state call level than'+
                  'corresponding <in push,...>.');
            end;

         // Restore unrbottom the same way as in ioinforward when returning from
         // unread buffer
         with curinfilep^ do if pstateenv.cinp=unrbranchptr then unrbottom:= unrendptr;
         end;
      unrstacktop:= unrstacktop-1;
      end;
   end
else
   // iounrnormal
   (* Signal that unread was called. If in preaction, then xcallstate
      will check that all the string (but not more) was consumed. *)
   if pstateenv.cinp0=nil then pstateenv.cinp0:= pstateenv.cinp;

(* If pop, then we are finished. *)
if pmode=iounrpop then (* - *)

(* 0. <unread> means back to where we were before last
   ?"..."?. *)
else if pstr = nil then begin
    pstateenv.cinp:= pstateenv.inpback;

    // Make sure that unrbottom is not above cinp in unread buffer
    // because then the text can be written over by unread from other
    // place (BFn 2008-08-05).
    if not xunr.active then begin
       if (integer(unrbufp)<integer(pstateenv.cinp)) and
         (integer (pstateenv.cinp)<integer(unrbottom)) then
         unrbottom:= pstateenv.cinp;
       end;

    if pmode<>iounrnormal then xProgramError('X(iounread):Unexpected mode.');
    end

else begin

   (* 1. Find out length of unread string. *)
   endstr:= pstr;
   fsforwendch(endstr,pendch);
   strl:= fsdistance(pstr,endstr);

   if pmode=iounrpush then begin
      extraeofs:= true;
      strl:= strl+1;
      end

   else extraeofs:= false;

   if (pmode=iounrpop) and (strl>0) then begin
      xProgramError('X(iounread): Unexpected string in pmode=pop.');
      strl:= 0;
      end;

   (* 1a. Ignore empty unread strings. *)
   if strl>0 then begin

       (* 2. Are we already in unread buffer? *)

     (* (new (attempt to avoid overwriting of higher levels.
        Put new string below the oldest string.)
        Abandoned because it caused insertion of unread data
        to be put at the wrong place /BFn 180614. * )
       if ( ioint32(pstateenv.cinp)>=ioint32(unrbufp) )
           and ( ioint32(pstateenv.cinp)<=ioint32(unrbufend) )
           then  (* - Already in unread buffer.
		Note: This changes behaviour also when xunr is not active.
		If there is any problems in use, then this change will have to 
		be removed. /BFn 180614 * )
       else begin
          ( * Jump to unread buffer. * )
          ( * Save "real" input pointer. * )
          curinfilep^.unrbranchptr:= pstateenv.cinp;
          curinfilep^.unrendptr:= unrbottom;
          end;
       startp:= ioinptr(ioint32(unrbottom)-strl);
       stopp:= unrbottom; *)

       (* (old: may cause overwriting of higher levels.) *)
       if ( ioint32(pstateenv.cinp)>=ioint32(unrbufp) )
           and ( ioint32(pstateenv.cinp)<=ioint32(unrbufend) )
           then begin  (* Already in unread buffer. *)
           startp:= ioinptr(ioint32(pstateenv.cinp)-strl);
           stopp:= pstateenv.cinp;
           end
       else begin
          (* Jump to unread buffer. *)
          (* Save "real" input pointer. *)
          curinfilep^.unrbranchptr:= pstateenv.cinp;
          curinfilep^.unrendptr:= unrbottom;

          startp:= ioinptr(ioint32(unrbottom)-strl);
          stopp:= unrbottom;
          end;

       overflow:= False;

       if ioint32(startp) < ioint32(pnstacktop) then begin
          unrsize:= ioint32(unrbufend)-ioint32(unrbottom);
          pnsize:= ioint32(pnstacktop)-ioint32(unrbufp);
          // (new:)
          xScriptError(
            'ioUnread: Unread/instring/pnsave buffer too small for this request. '+
            'X has a buffer for <unread ...>, <in ...,string> and temporary saving '+
            'of <p n> variables. This buffer is '+inttostr(iounrbuflen)+' bytes long. '+
            'But this request to save a string of length '+inttostr(strl)+' would '+
            'have required more space than that. String is "'+alfstostr100(pstr,pendch)+
            '"). Remaining space in buffer is '+inttostr(integer(unrbottom)-integer(pnstacktop))+
            '. Used unread/instring space (unrsize)='+inttostr(unrsize)+
            ' bytes. Used pnstack space (pnsize)=' + inttostr(pnsize) + ' bytes. '+
            'Infile='+ioinfilenamestr+', line '+inttostr(iolinenr(pstateenv.cinp))+' (approximately).');
         (* (old:)
          xProgramError(
            'X(<unread ...>): Unable to unread whole string (size ='
            + inttostr(strl) + ', string="'+alfstostr100(pstr,pendch)+'").'
            + 'unrstack='+inttostr(unrsize)+' bytes. pnstack='
            + inttostr(pnsize) + ' bytes.'); *)
          startp:= pnstacktop;
          overflow:= true;
          end;

       ptr:= startp;
       count:= 0;
       if extraeofs then strl:= strl-1;

       while not ((count=strl) or (ptr=stopp)) do begin
           ptr^:= pstr^;
           fsforward(pstr);
           ptr:= ioinptr(ioint32(ptr)+1);
           count:= count+1;
           end;
       (*if pmode=iounrpop then begin*)
       if extraeofs then begin
           ptr^:= eofs;
           ptr:= ioinptr(ioint32(ptr)+1);
           count:= count+1;
           strl:= strl+1;
           end;

       (* Extra check: *)
       if ((count<>strl) or (ptr<>stopp)) and not overflow then begin
           xProgramError('iounread: Program error - count<>strl or ptr<>stopp.');
           overflow:= true;
           end;

       pstateenv.cinp:= startp;
       unrbottom:= pstateenv.cinp;

       end; (* strl>0. *)
   end; (* pstr<>nil *)

end; (* iounread *)


function iounrsize: integer;
begin
iounrsize:= ioint32(unrbufend)-ioint32(unrbottom);
end;

// (new:)
function ioinunrbuf( pinp: ioinptr ): boolean;
(* Return true if pinp is in unrbuf. *)
begin

if xunr.active then
   (* BFn 180512. Note: This range check is doubled, it checks both the new
      buffer (xunr) and the old (unrbufp). The old still needs to be checked
      because <in ...,string> still uses the old buffer (unrpush, unrpop).
      When these are moved to the new buffer, references to the old buffer will
      no longer be needed here. *)
   ioinunrbuf:= (pinp >= xunr.UnrBottomPtr) and (pinp <= xunr.UnrTopPtr) or
      (pinp<=unrbufend) and (pinp>=unrbufp)
else
   ioinunrbuf:= (integer(pinp)<=integer(unrbufend)) and
     (integer(pinp)>=integer(unrbufp));

end;(*ioinunrbuf*)

// (old:)
function ioinunrbuf0( pinp: ioinptr ): boolean;
(* Return true if pinp is in unrbuf. *)
begin

if xunr.active then
   ioinunrbuf0:= (pinp >= xunr.UnrBottomPtr) and (pinp <= xunr.UnrTopPtr)
else
   ioinunrbuf0:= (integer(pinp)<=integer(unrbufend)) and
     (integer(pinp)>=integer(unrbufp));

end;(*ioinunrbuf0*)

procedure iohandleeobl(var pinp: ioinptr);
(* pinp^=eobl - go to next block. *)

begin

while pinp^=eobl do begin

  (* Read away eobl filling and follow internal block link *)
  while pinp^=eobl do pinp:= ioinptr(ioint32(pinp)+1);

  if pinp^<=char(251) then begin
    // End of block - find next
    pinp:= ioinptrptr(ioint32(pinp)+1)^;
    end
  else if pinp^=eoblfillptr then begin
    // Internal fill pointer - jump twice
    pinp:= ioinptrptr(ioint32(pinp)+1)^;
    if pinp^=eobl then begin
      pinp:= ioinptr( ioint32(pinp)+1);
      if pinp^<=char(251) then pinp:= ioinptrptr(ioint32(pinp)+1)^
      else raise exception.Create('X(iohandleeobl): Program error (0-251 was expected here).');
      (* ++ Temporary check to solve problems readint serial port in stm2.
      if curinfilep^.kind=aSerialPort then
         checkPointerInSerialPort('iohandlebl',nil,pinp);
      *)
      end
    else raise exception.Create('X(iohandleobl): Program error (eobl was expected here).');
    end (* eoblfillptr *)
  else raise exception.Create(
    'X(iohandleobl): Program error (0-251 or eoblfillptr was expected here).');

  end; // while eobl

end; (* iohandleeobl *)

procedure ioskipcomment( var pinp: ioinptr; plinecomment: boolean );
(* Pinp points at first character of possible comment (xskipcomment
   or xcommentasblank).
   E.g. '(' if pascal comments are to be removed.
   If it is comment, move pinp to after the comment. *)
var
saveinp: ioinptr;
commentstartchar: char;
saveskipcomment,prevchar1,prevchar2: char;
skiptoendofline,finished: boolean;

begin

(* Fetch comment start character from pinp. *)
commentstartchar:= pinp^;

(* To avoid looking for comments when calling ioinforward
   recursively: *)
saveskipcomment:= xskipcomment;
xskipcomment:= ' ';
finished:= false;
while (pinp^=commentstartchar) and not finished do begin
   skiptoendofline:= false;
   if plinecomment then skiptoendofline:= true
   else case commentstartchar of
      '-': begin
         (* Ada style *)
         saveinp:= pinp;
         ioinforward(pinp);
         if pinp^=eofr then ioingetinput(pinp,false);
         if pinp^='-' then skiptoendofline:= true
         else begin
            pinp:= saveinp;
            finished:=true;
            end;
         end; (* - *)
      '/': begin
         (* C style *)
         saveinp:= pinp;
         ioinforward(pinp);
         if pinp^=eofr then ioingetinput(pinp,false);
         if pinp^='/' then skiptoendofline:= True
         else if pinp^='*' then begin
            (* Skip to "*/" *)
            prevchar1:=' ';
            prevchar2:=' ';
            while not ((prevchar1='*') and (prevchar2='/')) do begin
               prevchar1:= prevchar2;
               prevchar2:= pinp^;
               ioinforward(pinp);
               if pinp^=eofr then ioingetinput(pinp,false);
               if pinp^=eofr then begin
                  xScriptError('X(ioinforward): Unable to find end of comment - "*/".');
                  prevchar1:= '*';
                  prevchar2:= '/';
                  end;
               end;
            end (* / *)
         else begin
            pinp:= saveinp;
            finished:=true;
            end;
         end; (* case '/' *)

      '(': begin
         (* Pascal style *)
         saveinp:= pinp;
         ioinforward(pinp);
         if pinp^=eofr then ioingetinput(pinp,false);
         if pinp^='*' then begin
            (* Skip to '*' ')' *)
            prevchar1:=' ';
            prevchar2:=' ';
            while not ((prevchar1='*') and (prevchar2=')')) do begin
               prevchar1:= prevchar2;
               prevchar2:= pinp^;
               ioinforward(pinp);
               if pinp^=eofr then ioingetinput(pinp,false);
               if pinp^=eofr then begin
                  xScriptError('X(ioinforward): Unable to find end of comment - "*)".');
                  prevchar1:= '*';
                  prevchar2:= ')';
                  end;
               end;
            end (* '(' '*' *)
         else begin
            pinp:= saveinp;
            finished:=true;
            end;
         end; (* case '(' *)
      else xProgramError('X(ioinforward): Unexpected value of commentstartchar: "'
         + commentstartchar + '".');
      end; (* case commentstartchar *)

   if skiptoendofline then begin
      (* Ignore rest of line. *)
      while not ( (pinp^=char(13)) or (pinp^=char(10)) or (pinp^=eofr) ) do begin
         ioinforward(pinp);
         if pinp^=eofr then ioingetinput(pinp,false);
         end;
      finished:= true;
      end;
   end; (* while *)

xskipcomment:= saveskipcomment;

end; (*ioskipcomment*)


procedure ioinforward( var pinp: ioinptr );
(* Move input pointer one step forward.
   Convert CR LF or LF to CR.
   Disregard comments if that option is set. *)
var newpinp: ioinptr; cnt: longint;
nextinp,inp1: ioinptr;
ok: boolean;

begin

if pinp^=eofs then
   xProgramError(
      'X(ioinforward): Program error - attempt to read beyond eofs.')

else begin

   newpinp:= ioinptr( ioint32(pinp)+1);

   if newpinp^=eobl then (* Goto next block *)
      iohandleeobl(newpinp);

   (* Handle line deliminters. *)
   if newpinp^=char(10) then begin (*LF*)
      if pinp^=char(13) then (* CR - skip LF. Note - If pinp^=eofr and
         next char will be LF, then LF will not be jumped over. This is
         probably the cause of Tr4483/BFn 2012-09-21. *)
         ioinforward(newpinp)
      else (* Change LF to CR *)
         (* newpinp^:= char(13); - no: LF is line delim in unix! *)
      end (* LF *)
   else if newpinp^= xskipcomment then begin
      if xskipcomment<>' ' then ioskipcomment(newpinp,xlinecomment);
      end; (* newpinp = xskipcomment *)

   (* ++ debug
   if curinfilep^.kind=aserialport then
      checkPointerInSerialPort('ioinforward',pinp,newpinp);
   *)

   if ioinlastpos=pinp then ioinlastpos:= newpinp;
   pinp:= newpinp;

   (* Decrement is used instead of increment assuming that testing 0 is faster
      than comparing with maxint. (Compare is necessary because overflow
      checking will otherwise cause exception when readcount reaches its limit). *)

   readcount:= readcount-1;
   if readcount=0 then readcount:= maxint;

   end; (* not eofs *)

(* Shall we jump (either within or from the unread buffer)? *)
with curinfilep^ do if ioint32(pinp)=ioint32(unrendptr) then begin
   unrbottom:= unrendptr; // (risk that pinp is not the real input
   // pointer but a local pointer/Bfn 060827)
   pinp:= unrbranchptr;
   end;

end; (* ioinforward *)


procedure iofill(pfilep:filerecptr; pfrom: ioinptr; var pinp: ioinptr);
(* Mark area from pfrom to pinp as free space. pfrom and pinp are in the same
   block. Integrate it with
   possible free space following pinp.pinp initially points at eobl.
   Advance pinp to point at eobl which precedes
   pointer to next block. *)
var
inp1,inp2: ioinptr;
freespace: integer;
oldfreespace: integer;
begin
inp1:= pfrom;
inp2:= pinp;

if pinp^<>eobl then raise exception.Create('X(iofill): program error (eobl was expected here).');
// read past old eobl filling
while inp2^=eobl do inp2:= ioinptr(ioint32(inp2)+1);
if inp2^=eoblfillptr then begin
  inp2:= ioinptrptr(ioint32(inp2)+1)^;
  inp2:= ioinptr(ioint32(inp2)+1);
  end;

inp2:= ioinptr(ioint32(inp2)-1);

// inp2 points at eobl at the end of the block. (inp2+2) contains pointer to next block
oldfreespace:= ioint32(inp2)-ioint32(pinp);
freespace:= ioint32(inp2)-ioint32(inp1);
ioinptr(ioint32(inp2)+1)^:= char(byte(min(251,freespace)));

if freespace<6 then begin
  // not enough for an eobl fill pointer - fill with eobl instead
  while inp1<>inp2 do begin
    inp1^:= eobl;
    inp1:= ioinptr(ioint32(inp1)+1);
    end;
  end
else begin
  // Enough space for an eobl fill pointer (>= 6 bytes)
  inp1^:= eobl;
  inp1:= ioinptr(ioint32(inp1)+1);
  inp1^:= eoblfillptr;
  inp1:= ioinptr(ioint32(inp1)+1);
  // Let it point to eobl at the end of the block (inp2)
  ioinptrptr(inp1)^:= inp2;
  inp1:=  inp2;
  end;

pinp:= inp1;

end; (*iofill*)


// (new:)
procedure ioremove(pfilep: filerecptr; pfrom: ioinptr; var pinp: ioinptr);
(* Remove characters between pfrom and pinp. pfrom and pinp can be in
   different blocks. Use eobl filling to handle
   size changes (see definition of eobl). Used by <replacewith ...> *)
var
copyto,inp: ioinptr;
pinpfound: boolean;
freespace: integer;
newinp: ioinptr;
nextaddr: ioinptrptr; // Address of next field in last non-empty block
// (Used to update link when removing empty blocks)
begin

if pfrom<>pinp then begin

   // 1. Delete data in current block
   copyto:= pfrom;
   inp:= pfrom;
   pinpfound:= false;
   // Go from pfrom to end of block or end of file. Copy from pinp if found.
   while not ((inp^=eobl) or (inp^=eofs) or (inp^=eofr) ) do begin
      if pinpfound then begin
         copyto^:= inp^;
         copyto:= ioinptr(ioint32(copyto)+1);
         end;
      inp:= ioinptr(ioint32(inp)+1);
      if inp=pinp then begin
         pinpfound:= true;
         pinp:= copyto;
         end;
      end;
   // inp points at old eobl or eofs/eofr
   // copyto points at where new eobl or eofs/eofr should be
   if inp^=eobl then begin
      // Make copyto .. end of block free space.
      // Advance inp to eobl at the end of the block
      iofill(pfilep,copyto,inp);
      end // inp points at eobl
   else begin
      // inp points at eofs/eofr
      copyto^:= inp^;
      pfilep^.outp:= copyto;
      pfilep^.outpsave:= copyto;
      pfilep^.endp:= copyto;
      if not pinpfound then raise exception.Create(
         'ioremove - program error (pinpfound was expected here)');
      end;

   if not pinpfound then begin

      // 2. Unlink and release invalid blocks
      // inp points at "real" eobl. inp+2 points at next pointer

      // See if entire first block in file was emptied, then unlink and release
      // remove it and update filebufp
      if copyto=pfilep^.filebufp then begin
         inp:= copyto;
         newinp:= ioinptrptr(ioint32(inp)+iobufsize-4)^;
         if newinp=nil then raise exception.create(
            'X(ioremove): Program error (valid block pointer was expected here/1).');
         freemem(inp);
         pfilep^.filebufp:= newinp;
         inp:= newinp;
         nextAddr:= nil; // This will signal update of filebufp further down
         end
      else begin

         nextaddr:= ioinptrptr(ioint32(inp)+2);
         inp:= ioinptrptr(ioint32(inp)+2)^;
         end;

      // inp now points at next block
      if inp=nil then raise exception.create(
         'X(ioremove): Program error (valid block pointer was expected here/3).');

      while not ((ioint32(pinp)>=ioint32(inp))
         and (ioint32(pinp)<=(ioint32(inp)+iobufsize-6)))
         do begin
         newinp:= ioinptrptr(ioint32(inp)+iobufsize-4)^;
         if newinp=nil then raise exception.create(
            'X(ioremove): Program error (valid block pointer was expected here/3).');
         freemem(inp);
         inp:= newinp;
         end; (* while *)

      // inp now points at the block which contains pinp
      if nextAddr<>NIL then
         nextaddr^:= inp
      else
         pfilep^.filebufp:= inp;

      pinpfound:= true;

      // 3. Delete invalid data in block which contains pinp
      // inp now points at this block
      // All data between inp and pinp are invalid
      copyto:= inp;
      inp:= pinp;
      pinp:= copyto;
      while not ((inp^=eobl) or (inp^=eofs) or (inp^=eofr)) do begin
         copyto^:= inp^;
         copyto:= ioinptr(ioint32(copyto)+1);
         inp:= ioinptr(ioint32(inp)+1);
         end;
     // inp points at eobl or eofs/eofr.
     // copyto points at where eobl or eofs/eofr should be
     if inp^=eobl then
        iofill(pfilep,copyto,inp)
     else begin
        // inp points at eofs/eofr
        copyto^:= inp^;
        pfilep^.outp:= copyto;
        pfilep^.outpsave:= copyto;
        pfilep^.endp:= copyto;
        end;
  
      end; (* not pinpfound *)
   end; // pfrom<>pinp
 
end; (*ioremove*)


// (old:)
procedure ioremove0(pfilep: filerecptr; pfrom: ioinptr; var pinp: ioinptr);
(* Remove characters between pfrom and pinp. pfrom and pinp can be in
   different blocks. Use eobl filling to handle
   size changes (see definition of eobl). Used by <replacewith ...> *)
var
copyto,inp: ioinptr;
pinpfound: boolean;
freespace: integer;
newinp: ioinptr;
nextaddr: ioinptrptr; // Address of next field in last non-empty block
// (Used to update link when removing empty blocks)
begin

if pfrom<>pinp then begin

   // 1. Delete data in current block
   copyto:= pfrom;
   inp:= pfrom;
   pinpfound:= false;
   // Go from pfrom to end of block or end of file. Copy from pinp if found.
   while not ((inp^=eobl) or (inp^=eofs) or (inp^=eofr) ) do begin
      if pinpfound then begin
         copyto^:= inp^;
         copyto:= ioinptr(ioint32(copyto)+1);
         end;
      inp:= ioinptr(ioint32(inp)+1);
      if inp=pinp then begin
         pinpfound:= true;
         pinp:= copyto;
         end;
      end;
   // inp points at old eobl or eofs/eofr
   // copyto points at where new eobl or eofs/eofr should be
   if inp^=eobl then begin
      // Make copyto .. end of block free space.
      // Advance inp to eobl at the end of the block
      iofill(pfilep,copyto,inp);
      end // inp points at eobl
   else begin
      // inp points at eofs/eofr
      copyto^:= inp^;
      pfilep^.outp:= copyto;
      pfilep^.outpsave:= copyto;
      pfilep^.endp:= copyto;
      if not pinpfound then raise exception.Create(
         'ioremove - program error (pinpfound was expected here)');
      end;

   if not pinpfound then begin

      // 2. Unlink and release invalid blocks
      // inp points at "real" eobl. inp+2 points at next pointer
      nextaddr:= ioinptrptr(ioint32(inp)+2);

      inp:= ioinptrptr(ioint32(inp)+2)^;
      // inp now points at next block
      if inp=nil then raise exception.create(
         'X(ioremove): Program error (valid block pointer was expected here/1).');

      while not ((ioint32(pinp)>=ioint32(inp))
         and (ioint32(pinp)<=(ioint32(inp)+iobufsize-6)))
         do begin
         newinp:= ioinptrptr(ioint32(inp)+iobufsize-4)^;
         if newinp=nil then raise exception.create(
            'X(ioremove): Program error (valid block pointer was expected here/2).');
         freemem(inp);
         inp:= newinp;
         end; (* while *)

      // inp now points at the block which contains pinp
      nextaddr^:= inp;
      pinpfound:= true;
  
      // 3. Delete invalid data in block which contains pinp
      // inp now points at this block
      // All data between inp and pinp are invalid
      copyto:= inp;
      inp:= pinp;
      pinp:= copyto;
      while not ((inp^=eobl) or (inp^=eofs) or (inp^=eofr)) do begin
         copyto^:= inp^;
         copyto:= ioinptr(ioint32(copyto)+1);
         inp:= ioinptr(ioint32(inp)+1);
         end;
     // inp points at eobl or eofs/eofr.
     // copyto points at where eobl or eofs/eofr should be
     if inp^=eobl then
        iofill(pfilep,copyto,inp)
     else begin
        // inp points at eofs/eofr
        copyto^:= inp^;
        pfilep^.outp:= copyto;
        pfilep^.outpsave:= copyto;
        pfilep^.endp:= copyto;
        end;
  
      end; (* not pinpfound *)
   end; // pfrom<>pinp
 
end; (*ioremove0*)


procedure iooutaddblock(var poutp: ioinptr; var pfilebufend: ioinptr);
(* outp points att filebufend. Add block. *)
type
addrptr = ^ioinptr;
var
bufp,p: ioinptr;
addrp: addrptr;
begin

  if poutp<>pfilebufend then raise exception.Create(
    'X(iooutaddblock): Program error (poutp=pfilebufend was expected).');

  (* Write end of block in the last pos of the old
     buffer. *)
   poutp^:= eobl;
   ioinptr(ioint32(poutp)+1)^:= char(0); // last block is full

   (* Allocate a new buffer. *)
   GetMem(bufp,iobufsize);

   (* Let the last four bytes of the old buffer point at it. *)
   p:= ioinptr( ioint32(pfilebufend) +2);
   addrp:= addrptr(p);
   addrp^:= bufp;

   (* Update pfilebufend and
      set new buffers next pointer to nil. *)
   pfilebufend:= ioinptr( ioint32(bufp) + iobufsize -6);
   p:= ioinptr( ioint32(pfilebufend) + 2);
   addrp:= addrptr(p);
   addrp^:= nil;

   (* Put eofs after pfilebufend as an extra guard. *)
   pfilebufend^:= eofs;
   ioinptr( ioint32(pfilebufend) +1)^:= eofs;

   (* Let poutp point at the first byte in the new buffer, and
      we are ready to write. *)
   poutp:= bufp;
   poutp^:= eofr;

end; (*iooutaddblock*)


procedure ioinsert(ps: fsptr; var pinp:ioinptr);
(* Insert ps at pinp. Use eoblfill to handle free space in blocks.
   Let pinp point after inserted ps. *)
var
s: fsptr;
inp,nextblockp,localoutp: ioinptr;
moreblocks: boolean;
localfilebufend: ioinptr;
savecurout: filerecptr;
freespace: integer;
ch: char;
rest,rest0,p:fsptr;

begin

(* (old:)
if curinfilep^.filebufend^<>eofs then
   ioErrmessWithDebugInfo('++ ioinsert: eofs was expected but '+curinfilep^.filebufend^+' was found.');
*)

fsnew(rest);
rest0:= rest;

// 1. Save rest of block in rest
inp:= pinp;
while not ((inp^=eobl) or (inp^=eofs) or (inp^=eofr)) do begin
  ch:= inp^;
  fspshend(rest,ch);
  inp:=ioinptr(ioint32(inp)+1);
  end;
//checkcinp(curinfilep,pinp);

// 2. Save address of next block (if any)
if inp^=eobl then begin
  while inp^=eobl do inp:= ioinptr(ioint32(inp)+1);
  if inp^=eoblfillptr then begin
    // Internal fill pointer - jump to "real" eobl
    inp:= ioinptrptr(ioint32(inp)+1)^;
    inp:= ioinptr(ioint32(inp)+1);
    end;
  if inp^<=char(251) then nextblockp:= ioinptrptr(ioint32(inp)+1)^
  else raise exception.Create('X(ioinsert): Program error (0-251 was expected here).');
  // Let inp point at eobl
  inp:= ioinptr(ioint32(inp)-1);
  if inp^<>eobl then
      exception.Create('X(ioinsert): Program error (eobl was expected here).');
  end (* eobl *)
else (* eofs/eofr *) nextblockp:= nil;

// inp now points at eobl at the end of the block or at eofs/eofr (end of file)
// pinp points at where to put ps + rest
// 3. If there are more blocks: Make localfilebufend = end of current block
// (pretend that file ends at pinp)
localoutp:= pinp;
if inp^=eobl then begin
   moreblocks:= true;
   localfilebufend:= inp;
   end
else begin
   moreblocks:= false;
   localfilebufend:= curinfilep^.filebufend;
   end;

//checkcinp(curinfilep,pinp);
// 4. write ps to file
p:= ps;
while not (p^=eofs) do with curinfilep^ do begin

   if localoutp=localfilebufend then
      iooutaddblock(localoutp,localfilebufend);
   localoutp^:= p^;
   localoutp:= ioinptr(ioint32(localoutp)+1);

   // Expand cr to cr lf
   if p^=char(13) then p^:=char(10)
   else fsforward(p);
   end; (*while*)

if localoutp=localfilebufend then
   iooutaddblock(localoutp,localfilebufend);

localoutp^:= eofr;
pinp:= localoutp;

rest:= rest0;
while not (rest^=eofs) do with curinfilep^ do begin

    localoutp^:= rest^;
    localoutp:= ioinptr(ioint32(localoutp)+1);

    if localoutp=localfilebufend then begin
      iooutaddblock(localoutp,localfilebufend);

      // Debug(++)
      if false then begin
         blocktablen:= blocktablen+1;
         blocktab[blocktablen]:= localoutp;
         end;
      end;

    fsforward(rest);
    end; (*while*)
localoutp^:= eofr;

// 5. Reconnect following blocks if any
with curinfilep^ do if moreblocks then begin

  // Fill unused space in current block
  freespace:= ioint32(localfilebufend) - ioint32(localoutp);
  if freespace<6 then begin
    while localoutp<>localfilebufend do begin
      localoutp^:= eobl;
      localoutp:= ioinptr(ioint32(localoutp)+1);
      end;
    end
  else begin
    // Enough place for a pointer
    localoutp^:= eobl;
    localoutp:= ioinptr(ioint32(localoutp)+1);
    localoutp^:= eoblfillptr;
    localoutp:= ioinptr(ioint32(localoutp)+1);
    ioinptrptr(localoutp)^:= localfilebufend;
    localoutp:= localfilebufend;
    end;

  // Restore "real" next block pointer
  localfilebufend^:= eobl;
  ioinptr(ioint32(localfilebufend)+1)^:= char(min(251,freespace));
  ioinptrptr(ioint32(localfilebufend)+2)^:= nextblockp;
  end
else begin
   (* Not more blocks. *)
   filebufend:= localfilebufend;
   outp:= localoutp; // points at eofr
   outpsave:= localoutp;
   endp:= localoutp;
   end;
//checkcinp(curinfilep,pinp);

fsdispose(rest);

end; (*ioinsert*)

function ioKindToStr(var pFile: fileRec): string;
begin
case pfile.kind of
   aconsole: ioKindToStr:= 'aConsole';
   afile: ioKindToStr:= 'aFile';
   asocket: ioKindToStr:= 'aSocket';
   aserialport: ioKindToStr:= 'aSerialPort';
   acircularbuffer: ioKindToStr:= 'aCircularBuffer';
   else ioKindToStr:= '(ioKindToStr:unknownkind)';
   end;

end; (*ioKindToStr*)

procedure ioreplacewith(ps:fsptr; var pstateenv: xstateenv);
(* Implements <replacewith str>. Replace the characters between inpback
   and cinp ( representing ?"..."?) with ps. Use "eobl filling"
   to handle size changes (see definition of eobl). *)
var
outptr: ioinptr;
s: fsptr;
outchar: char; // debug ++
begin
//checkcinp(curinfilep,pstateenv.cinp);
//iocheckblockstructure(curinfilep);
if curinfilep^.kind<>afile then xScriptError(
  'Replacewith expects a file as input but input was of kind '+
   ioKindtoStr(curinfilep^)+'.')
else if curinfilep^.binaryfile then xScriptError(
  'X(<replacewith ...): Not implemented for binary files.')
else if curinfilep^.usedforoutput and (curinfilep^.outp<>curinfilep^.filebufp) and
   (curinfilep^.outp^<>eofr) and (curinfilep^.outp^<>eofs) then xScriptError(
      'X(<replacewith ...): Position of output pointer indicates writing the the middle of the file.' +
      'Writing in middle of file cannot be combined with use of the <replacewith ...>-function.')
(* (new:) *)
else if ioinunrbuf(pstateenv.inpback) or (pstateenv.inpback=nil) then
(* (old:)
else if (ioint32(pstateenv.inpback) >= ioint32(unrbufp)) and
   (ioint32(pstateenv.inpback) < ioint32(unrbufend)) or (pstateenv.inpback=nil)  then *)
   xScriptError(
      'X(<replacewith ...): Text to replace was located in unread buffer, but <replacewith ...> function is not' +
      'implemented for replacements in unread area or "string,local" file.')
else if pstateenv.cinp<>pstateenv.inpEnd then
   xScriptError('X(<replacewith ...>): This function expects the input pointer '+
      'to be at the end of the string to be replaced, but was found to have moved. '+
      'Check that there is no reading from the same file, or other change of the '+
      'input pointer, between ?"..."? and <replacewith ...>. '+'(Input pointer had '+
      'moved from address '+inttostr(integer(pstateenv.inpEnd))+' to '+
      inttostr(integer(pstateenv.cinp))+').'
      )

else with curinfilep^ do with pstateenv do begin
    outptr:= inpback;
    s:= ps;

    // iocheckblockstructure(curinfilep);
    // 1. Copy ps to inpback, but do not overwrite cinp
    while not ((s^=eofs) or (outptr=cinp) or (outptr^=eofs)) do begin
     // iocheckblockstructure(curinfilep);
        outchar:= outptr^;
        outptr^:= s^;
        outptr:= ioinptr( ioint32(outptr) + 1);
     // ++ iocheckblockstructure(curinfilep);
     if curinfilep^.errorfound then xProgramError('outchar='+outchar);
        if outptr^=eobl then iohandleeobl(outptr); // go to next block
     // iocheckblockstructure(curinfilep);
        if (s^=char(13)) and not (binaryfile) then
          // insert LF
          s^:= char(10)
        else fsforward(s);
        end;
    if outptr^=eofs then if (s^<>eofs) and (outptr<>cinp) then
        xProgramError('X(ioreplacewith): Program error - unexpected eofs in out file.');

         // iocheckblockstructure(curinfilep);
    // 2. Handle the cases when the new string was same size, shorter or longer
    // than inpback..cinp
    if (s^=eofs) and (outptr=cinp) then
        (* Same size - we are done. *)
    else if outptr<>cinp then begin
        (* New string was shorter - remove invalid characers. *)
        ioremove(curinfilep,outptr,cinp);
        end
    else if s^<>eofs then begin
       (* New string was longer - insert the rest of it at cinp. *)
       // iocheckblockstructure(curinfilep);
       iocheckcinp(pstateenv);
       ioinsert(s,cinp);
       iocheckcinp(pstateenv);
       // iocheckblockstructure(curinfilep);
       end;
    usedforoutput:= true;
    end; (* with *)
// iocheckblockstructure(curinfilep);
iocheckcinp(pstateenv);
end; (*ioreplacewith*)


procedure iocreatefileinfo;
(* Create a linked structure of information for the current input file.
   (used by iolinenr). *)

var inp: ioinptr;
fip: fileinfoptr;
lno: ioint32;
state: (normal,crstate);
addrp: addrptr;
nextbufp: ioinptr;

begin (*iocreatefileinfo*)
with curinfilep^ do if kind=afile then begin

    new(fileinfo);
    fip:= fileinfo;
    with fip^ do begin
        next:= nil;
        line:= 1; lno:= line;
        blockptr:= filebufp;
        end;
    inp:= filebufp;
    state:= normal;
    while not ((inp^=eofs) or (inp^=eofr)) do begin

        (* count lines. *)
        case state of
          normal: begin
            if inp^=char(13) then begin (* cr counts as one line. *)
              lno:= lno+1;
              state:= crstate; (* crlf shall count only as one line delimeter. *)
              end
            else if inp^=char(10) then (* lf also counts as line delimiter. *)
              lno:= lno+1;
            end;
          crstate: begin
             if inp^=char(10) then state:= normal (* (crlf) *)
             else if inp^=char(13) then lno:= lno+1
             else state:= normal;
             end; (*crstate*)
          end; (* case state *)

        (* Proceed to next character. *)
        inp:= ioinptr(ioint32(inp)+1);
        if inp^=eobl then begin
            (* Goto next block. *)
            iohandleeobl(inp);

            (* Create new fileinfo block. *)
            new(fip^.next);
            fip:= fip^.next;
            with fip^ do begin
                line:= lno;
                if state=crstate then line:= line-1;
                blockptr:= inp;
                next:= nil;
                end;
            end; (* eobl *)
        end; (* while not eofs *)
    end; (*afile*)

end; (*iocreatefileinfo*)

var
str: string; (* This variable is only used in iolinenr but kept outside to
   prevent unnecessary initialisation overhead in iolinenr. *)

function iolinenr( pinp: ioinptr ): ioint32;
(* Calculate current line number (first line=1 etcetera).
  (used by <linenr>) *)
var
modifiedPinp: ioinptr;
lno: ioint32;
inp: ioinptr;
fip: fileinfoptr;
foundblock, foundline: boolean;
res: integer;
ch: char;
deduction: integer;
cnt: integer;

begin

// (init to pinp just to keep clean)
modifiedPinp:= pinp;

(* Mod 2012-06-03: Use inpback instead, because it better follows the
   idea from 2008-04-26 (inpback is for example the pointer that is used
   for <unread>, which moves the pointer to the beginning of the last
   ?"..."?). *)
modifiedPinp:= xCurrentStateEnv^.inpback;

(* 2013-10-09: If inpback is not available (it is erased when parameters
   in unread buffer are moved), use original pinp instead (cinp). cinp is
   then probably in the unread buffer so it will then  probably be changed again to
   unrbranchptr, see below. *)
if modifiedPinp=nil then
   modifiedPinp:= pinp;
(* Mod 2008-04-26: use readpos instead of cinp so that we see the line nr
   at the beginning of the previous ?"..."?. *)
// (old:)modifiedPinp:= curinfilep^.readpos;

res:= 0;
deduction:= 0;
(* If in unreadbuffer: Use position before entering unread buffer: *)
(* (new:) *)
if ioinunrbuf(modifiedPinp)
(* (old:)
if ( ioint32(modifiedPinp)>=ioint32(unrbufp) )
   and ( ioint32(modifiedPinp)<= ioint32(unrbufend) ) *)
   then begin
   modifiedPinp:= curinfilep^.unrbranchptr;
   (* Since unrbranchptr normally pointst at end of ?"..."?, not at
      beginning, see if modifiedPinp-1=CR or LF, then subtract one line.
      This is not so scientific, since last ?"..."? can contain >1 line
      and since modifiedPinp-1 can be outside the block, but it is anyway more
      accurate than using unrbranchptr as it is. *)
   ch:= ioinptr(integer(modifiedPinp)-1)^;
   if (ch=char(10)) or (ch=char(13)) then deduction:= -1;
   end;

(* Only valid for kind=afile. *)
with curinfilep^ do if kind=afile then begin

   if fileinfo=nil then iocreatefileinfo;
   fip:= fileinfo;
   foundblock:= false;
   foundline:= false;
   while not (foundblock or (fip=NIL)) do with fip^ do begin
        if (ioint32(modifiedPinp)>=ioint32(blockptr))
            and (ioint32(modifiedPinp)<=(ioint32(blockptr)+iobufsize-6))
            then foundblock:= true
        else fip:= fip^.next;
        end;
   if foundblock then with fip^ do begin
        lno:= line;
        inp:= blockptr;
        while not (foundline
          or (ioint32(inp)>(ioint32(blockptr)+iobufsize-6)))
            do begin
            if inp=modifiedPinp then foundline:= true
            else begin
                if inp^=char(13) then begin
                   lno:= lno+1;
                   inp:= ioinptr(ioint32(inp)+1);
                   if inp^=char(10) then inp:= ioinptr(ioint32(inp)+1);
                   end
                else begin
                   if inp^=char(10) then lno:= lno+1;
                   inp:= ioinptr(ioint32(inp)+1);
                   end;
                end;
            end; (*while*)
        end; (*foundblock*)

   if foundblock then res:= lno
   else begin
      if modifiedPinp=nil then
         xProgramError('X(iolinenr): <linenr> was unable to find current line. ' +
            'Input file name = ' + fstostr(curinfilep^.filename) +
            '. Input pointer was nil.')
      else begin
         // Print one line from input in the error message
         inp:= modifiedPinp;
         str:= '';
         cnt:= 0;
         while not (
            (inp^=char(13)) or (inp^=char(10)) or (inp^=eofr) or
            (inp^=eofs) or (cnt=100)
            ) do begin
            ch:= inp^;
            str:= str + ch;
            ioinforward(inp);
            cnt:= cnt+1;
            end;
         xProgramError('X(iolinenr): <linenr> was unable to find current line. ' +
            'Input file name = ' + fstostr(curinfilep^.filename) + '. Input text = ' + str + '...');
         end;

      end;
   end; (*afile*)

    iolinenr:= res + deduction;

end; (*iolinenr*)


procedure ioout( pfilename: fsptr; pendch: char; ppos: ioint32; pbinary: boolean;
   pprefrole: ioprefroles;  var pconfig: string; pcircularbuffer: boolean;
   pinp: ioinptr);
(* Change output file. Implements <out file/domain:port/comn:[,pos/option/config[,...]]>  *)
type
addrptr = ^ioinptr;
var
found: boolean;
frp,filep: filerecptr;
bufp,p: ioinptr;
addrp: addrptr;
portnr: ioint32;
colonpos: fsptr;
checkresult: integer;
filenr: integer;
ptr: fsptr;
ch: char;
error: boolean;

begin (*ioout*)

found:= false;

(* 0. See if filename is empty (current file). *)
if pfilename^=pendch then begin
   found:= true;
   if curoutfilep=NIL then begin
      xScriptError('X(ioout): <out > was called with empty filename but the current output was undefined.');
      found:= false;
      end;
   end

(* 1a. See if new file is console. *)
else if fsEqualFilename(pfilename,consfs,pendch,eofs) then begin
   ioswitchoutput(consfilep);
   found:= true;
   end;

(* 2. See if file(/socket) exists already. *)
if not found then begin

    filep:= iofindfile(pfilename,pendch);
    found:= (filep<>nil);
    if found then ioswitchoutput(filep);
    end; (* see if exists already *)

if found then
    iocheckoptionsexistingfile(curoutfilep,pbinary,pprefrole,pcircularbuffer);

if not found and not xFault then begin

   iofindportnr(pfilename,pendch,portnr,colonpos);

   // Is it formatted as a tempfile but not registered as one?
   if usedUniqueFileName(pfilename,pendch)=0 then
      // Return code: -1 = not formated as temporary file.
      //              0 = formatted as temporary file but not in use.
      //              >0 = number of temporary file.
      // Names on format tf#n are reserved for temporary files.
      xScriptError('X(ioout): Name of file ('+alfstostr(pfilename,pendch)+') has format '+
      'reserved for temporary files ("tf#n" where n is a number). Temporary '+
      'file names can be created and registered with <uniquefilename>, but '+
      alfstostr(pfilename,pendch)+' was not found among the registered temporary file '+
      'names. Please do not use file names of the reserved format "tf#n" in '+
      'the scripts.')

    // Is it serial port?
    else if ioSerialPort(pfilename,pendch) then begin

      iomakeSerialPort(pfilename,pendch,pbinary,pconfig,pinp,frp);
      if not xFault then ioswitchoutput(frp);
      end // serial port

    (* 6. Not serial port. Is it a file or a socket?. *)
    else if portNr=0 then begin

      if pcircularbuffer then begin

        (* Create a circular buffer. *)
        iomakeCircularBuffer(pfilename,pendch,frp);
        if not xFault then ioswitchoutput(frp);
        end (* circular buffer *)

      else begin (* afile *)

        (* 3. Create a single empty output buffer
          ( bufp[0]=eofr, nextlink = nil). *)
        GetMem(bufp,iobufsize);
        bufp^:=eofr;
        p:= ioinptr( ioint32(bufp) + iobufsize - 4);
        addrp:= addrptr(p);
        addrp^:= nil;

        (* eofs eofs at end of buffer to be on safe side. *)
        p:= ioinptr(ioint32(p)-1);
        p^:= eofs;
        p:= ioinptr(ioint32(p)-1);
        p^:= eofs;

        (* 4. Create and initialize the file record. *)
        frp:= iomakefile(pfilename,pendch,pbinary,bufp,bufp,bufp,true,nil);
          // Debug(++)
          if false then begin
            frp^.blocktablen:= 1;
            frp^.errorfound:= false;
            frp^.blocktab[1]:= bufp;
            end;

        (* 5. Direct output to this file. *)
        ioswitchoutput(frp);
        end (* afile *)
      end (* portnr=0 *)

    else begin(* portnr<>0: asocket. *)
        iomakesocket(pfilename,pendch,pbinary,pprefrole,pinp,frp);
        if not xFault then ioswitchoutput(frp);
        end; (* asocket *)
    end; (* not found *)

if not xFault then begin
  curoutfilep^.usedforoutput:= True;
  (* Return error code if bad option was found. *)
  if ppos>=0 then ioseek(ppos,true,curoutfilep^.outp);
  end;

end; (*ioout*)



procedure iooutwithfilenr( pfilenr: integer);
(* Restore to existing output file with nr = pfilenr. Return pfailure=true
   if file is not found.
   iooutwithfilenr is written after model from ioout (beginning of).
   iooutwithfilenr is used to restore output when output has changed in a
   function call, in a state call, or inside <localio ...> (and option
   persistent was not used). *)

var
filep: filerecptr;
found: boolean;
i: integer;

begin

if pfilenr=0 then ioswitchoutput(nil)

else begin
   (* 2. Find file. *)
   filep:= files; found:= false;
   while not ( (filep=nil) or found ) do with filep^ do begin
      if nr=pfilenr then found:= true
      else filep:= filep^.next;
      end;


   if not found then begin
      // Try find name in oldnametab
      i:= 0;
      found:= false;
      while (i<oldnametabsize) and not found do begin
         i:= i+1;
         if oldnametab[i].nr=pfilenr then found:= true;
         end;

      if found then
         xScriptError('X: Tried to restore output file to "' +
            oldnametab[i].name + '" but the file was not available anymore. ' +
            'It may have been closed or deleted.')
      else
         xScriptError('X: Tried to restore output file (#'+inttostr(pfilenr)+
            ')but the file was not '+
            'available anymore. It may have been closed or deleted.');
      end
   else begin
      ioswitchoutput(filep);
      curoutfilep^.usedforoutput:= True;
      end;
   end;

end; (*iooutwithfilenr*)

function iogetfilename(pfilenr: integer):string;
(* Return the name of a file. *)
var
filep: filerecptr;
found: boolean;
i: integer;

begin

(* Find file. *)
filep:= files; found:= false;
while not ( (filep=nil) or found ) do with filep^ do begin
  if nr=pfilenr then found:= true
  else filep:= filep^.next;
  end;

if found then iogetfilename:= fstostr(filep^.filename)
else begin
   // Try find name in oldnametab
   i:= 0;
   found:= false;
   while (i<oldnametabsize) and not found do begin
      i:= i+1;
      if oldnametab[i].nr=pfilenr then found:= true;
      end;
   if found then iogetfilename:= oldnametab[i].name
   else iogetfilename:= '(?)';
  end;

end; (*iogetfilename*)


// (old:)
procedure ioout0( pfilename: fsptr; pendch: char; ppos: ioint32; pbinary: boolean;
   pprefrole: ioprefroles;  var pconfig: string; pcircularbuffer: boolean;
   pinp: ioinptr);
(* Change output file. Implements <out file/domain:port/comn:[,pos/option/config[,...]]>  *)
type
addrptr = ^ioinptr;
var
found: boolean;
frp,filep: filerecptr;
bufp,p: ioinptr;
addrp: addrptr;
portnr: ioint32;
colonpos: fsptr;
checkresult: integer;
filenr: integer;
ptr: fsptr;
ch: char;
error: boolean;

begin (*ioout*)

found:= false;

(* 0. See if filename is empty (current file). *)
if pfilename^=pendch then begin
   found:= true;
   if curoutfilep=NIL then begin
      xScriptError('X(ioout): <out > was called with empty filename but the current output was undefined.');
      found:= false;
      end;
   end

(* 1a. See if new file is console. *)
else if fsEqualFilename(pfilename,consfs,pendch,eofs) then begin
   ioswitchoutput(consfilep);
   found:= true;
   end;

(* 2. See if file(/socket) exists already. *)
if not found then begin

    filep:= iofindfile(pfilename,pendch);
    found:= (filep<>nil);
    if found then ioswitchoutput(filep);
    end; (* see if exists already *)

if found then
    iocheckoptionsexistingfile(curoutfilep,pbinary,pprefrole,pcircularbuffer);

if not found and not xFault then begin

    iofindportnr(pfilename,pendch,portnr,colonpos);

    // Is it serial port?
    if ioSerialPort(pfilename,pendch) then begin

      iomakeSerialPort(pfilename,pendch,pbinary,pconfig,pinp,frp);
      if not xFault then ioswitchoutput(frp);
      end // serial port

    (* 6. Not serial port. Is it a file or a socket?. *)
    else if portNr=0 then begin

      if pcircularbuffer then begin

        (* Create a circular buffer. *)
        iomakeCircularBuffer(pfilename,pendch,frp);
        if not xFault then ioswitchoutput(frp);
        end (* circular buffer *)

      else begin (* afile *)

        (* 3. Create a single empty output buffer
          ( bufp[0]=eofr, nextlink = nil). *)
        GetMem(bufp,iobufsize);
        bufp^:=eofr;
        p:= ioinptr( ioint32(bufp) + iobufsize - 4);
        addrp:= addrptr(p);
        addrp^:= nil;

        (* eofs eofs at end of buffer to be on safe side. *)
        p:= ioinptr(ioint32(p)-1);
        p^:= eofs;
        p:= ioinptr(ioint32(p)-1);
        p^:= eofs;

        (* 4. Create and initialize the file record. *)
        frp:= iomakefile(pfilename,pendch,pbinary,bufp,bufp,bufp,true,nil);
          // Debug(++)
          if false then begin
            frp^.blocktablen:= 1;
            frp^.errorfound:= false;
            frp^.blocktab[1]:= bufp;
            end;

        (* 5. Direct output to this file. *)
        ioswitchoutput(frp);
        end (* afile *)
      end (* portnr=0 *)

    else begin(* portnr<>0: asocket. *)
        iomakesocket(pfilename,pendch,pbinary,pprefrole,pinp,frp);
        if not xFault then ioswitchoutput(frp);
        end; (* asocket *)
    end; (* not found *)

if not xFault then begin
  curoutfilep^.usedforoutput:= True;
  (* Return error code if bad option was found. *)
  if ppos>=0 then ioseek(ppos,true,curoutfilep^.outp);
  end;

end; (*ioout0*)


function ioexistfilenr(pfilenr: integer): boolean;
(* Whether a file still exists (still open). *)
var
filep: filerecptr;
found: boolean;

begin

(* Find file. *)
filep:= files; found:= false;
while not ( (filep=nil) or found ) do with filep^ do begin
  if nr=pfilenr then found:= true
  else filep:= filep^.next;
  end;

ioexistfilenr:= found;
end; (*ioexistfilenr*)

function ioconnected( pfilename: fsptr; pendch: char; pinp: ioinptr): boolean;
(* If pfilename is a connected socket: true, otherwise false.
   implements <connected domain:portnr>.
   Used to avoid waiting for writing to a socket which is in a listening
   state. *)

var
filep,filepsave: filerecptr;
//ior: integer;
//newhandle: Tsocket;
res: boolean;

readfds,writefds,errorfds: TFDSet;
n: longint;
timeout: TTimeVal;
inptr: ioinptr;
saveIoPtr0: xSavedIODataPtrType;

begin (*ioconnected*)

(* Start pessimistic. *)
res:= false;

(* Find port in question. *)
filep:= iofindfile(pfilename,pendch);

if filep=nil then
        xScriptError(
    '<connected ...>: "'+alfstostr100(pfilename,pendch)+
    '" does not exist among open files.')
else if filep^.kind<>asocket then
        xScriptError(
    '<connected ...>: "'+alfstostr100(pfilename,pendch)+
    '" is not a socket.')
else with filep^ do begin

    (* Handle connection changes. *)
    ioUpdateSocketState(filep,pinp);

    (* Check if someone has connected to us. *)
    with readfds do begin
      fd_count:= 1;
      fd_array[0]:= sockhand;
    end;
    with writefds do begin
      fd_count:= 1;
      fd_array[0]:= sockhand;
    end;
    with errorfds do begin
      fd_count:= 1;
      fd_array[0]:= sockhand;
    end;
    (* {0,0} = return immediately *)
    with timeout do begin
      tv_sec:= 0;
      tv_usec:= 0;
      end;

    n:= select(0,@readfds,@writefds,@errorfds,@timeout);
    if n=socket_error then xProgramError('X(ioconnected): Error from select ('+
        inttostr(WSAGetLastError)+').');
    (***)(*ioErrmessWithDebugInfo('read='+inttostr(readfds.fd_count)
      +', write='+inttostr(writefds.fd_count)
      +', error='+inttostr(errorfds.fd_count)+'.');*)

    if writefds.fd_count>0 then begin

        if readfds.fd_count=0 then res:= true

        else begin
            (* This could be a closed connection. *)
            if readpos^<>eofr then
                (* All data not consumed. Do not regard as closed. *)
                res:= true
            else begin
                (* Get data from port. *)
                if filep=curinfilep then ioingetinput(readpos,true)
                else begin
                    filepsave:= curinfilep;
                    // Prevent unnecessary saving of current IO
                    saveIoPtr0:= alSaveIoPtr;
                    alSaveIoPtr:= NIL;

                    ioswitchinput(filep,pinp);
                    if pinp<>readpos then
                      xProgramError('X(ioconnected) - Program error: pinp=readpos was expected.');
                    ioingetinput(pinp,true);
                    ioswitchinput(filepsave,pinp);
                    alSaveIoPtr:= saveIoPtr0;
                    end;
                (* If there was data, it means socket was not closed from other side. *)
                if readpos^<>eofs then res:= true;
                end;
            end; (* read fdcount>0 *)
        end; (* write fdcount>0 *)
    end; (* socket exists. *)

ioconnected:= res;

end; (*ioconnected*)


function ioComHandle( pfilename: fsptr; pendch: char): Thandle;
(* Return the comhandle of a serial port.
   Used by <win32 ClearCommError...>
   Example:
   comHandle:= ioComHandle(arg2);
   *)
var res: THandle;
filep:filerecptr;

begin

(* Start pessimistic. *)
res:= 0;

(* Find port in question. *)
filep:= iofindfile(pfilename,pendch);

if filep=nil then xScriptError(
    'ioComHandle: "'+alfstostr100(pfilename,pendch)+
    '" does not exist among open files.')
else if filep^.kind<>aserialport then xScriptError(
    'ioComHandl: "'+alfstostr100(pfilename,pendch)+
    '" is not a serial port.')
else res:= filep^.comHand;

ioComHandle:= res;

end;

procedure iooutgotoend(pfilep: filerecptr);
(* go to end of file (eofr or eofs) *)
begin
with pfilep^ do begin
    if outp^<eofr then outp:= outpsave;
    if outp^<eofr then begin
        while outp^<eobl do outp:= ioinptr(ioint32(outp)+1);
        while (outp^=eobl) and (outp<>filebufend) do begin
            iohandleeobl(outp);
            outp:= ioinptr(ioint32(outp)+iobufsize-6);
            end;
        if outp=filebufend then begin
          outp:= ioinptr(ioint32(outp)-(iobufsize-6));
          while outp^<eofr do outp:= ioinptr(ioint32(outp)+1);
          end;
        end;
    if outp^<eofr then xProgramError(
      'X(iooutgotoend): Program error (eofr/eofs was expected here).')
    else outpsave:= outp;
    end; (* with *)
end; (*iooutgotoend*)


procedure iooutwrite( pch: char; pinp:ioinptr );
(* (pinp is used by updatesocketstate) *)
var
bufp,fromp,top,p: ioinptr;
cnt: integer;
addrp: addrptr;
binch: char;
ior: ioint16;
newhandle: Tsocket;
newoutp: ioinptr;
count: integer;

begin (*iooutwrite*)

if curoutfilep=NIL then
   xScriptError('iooutwrite: Attempt to write "'+pch+'" but <out> was undefined.'+
      'Note that <out> is undefined after <close <out>>.')
else with curoutfilep^ do begin

   if kind=aconsole then iofWriteChToWbuf(pch)

   else if kind=afile then begin

      (* Use eofr when writing at end of file, because it enables other threads
         to read simultaneously (BF060216). *)
      if outp^=eofs then begin
         outp^:= eofr;
         endp:= outp;
         end;

      if outp^=eofr then begin (* Normal writing at end of file. *)

         outp^:= pch;
         outp:= ioinptr(ioint32(outp)+1);

         outp^:= eofr;
         endp:= outp;
         if dataRequest then begin
            SetEvent(WriteEvent);
            dataRequest:= False;
            end;
         end (* outp^=eofr *)

      else begin (* writing in the middle of a file. *)
         outp^:= pch;
         outp:= ioinptr( ioint32(outp) + 1);
         if outp^=eobl then
            (* Goto next block. *)
            iohandleeobl(outp);
         end;

      if outp=filebufend then begin

          (* Write end of block in the last pos of the old
             buffer. *)
          outp^:= eobl;
          ioinptr(ioint32(outp)+1)^:= char(0); // No free space in last block

          (* Allocate a new buffer. *)
          GetMem(bufp,iobufsize);

          // debug(++)
          if false then begin
             blocktablen:= blocktablen+1;
             blocktab[blocktablen]:= bufp;
             end;

          (* Let the last four bytes of the old buffer point at it. *)
          p:= ioinptr( ioint32(filebufend) +2);
          addrp:= addrptr(p);
          addrp^:= bufp;

          (* Update filebufend and
             set new buffers next pointer to nil. *)
          filebufend:= ioinptr( ioint32(bufp) + iobufsize -6);
          ioinptrptr(integer(filebufend)+2)^:= nil;

          (* Put eofs after filebufend (= free space unknown). *)
          filebufend^:= eofs;
          ioinptr( ioint32(filebufend) +1)^:= eofs;

          (* Let outp point at the first byte in the new buffer, and
             we are ready to write. *)
          outp:= bufp;
          outp^:= eofr;
          endp:= outp;
          end; (*outp=filebufend*)

      if (pch=char(13)) and not (binaryfile) then iooutwrite(char(10),pinp);
      end (* afile *)

    else if kind=acircularbuffer then begin


      (* Reopen buffer if it was earlier closed because of timeout. *)
      if outp^=eofs then begin
        outp^:= eofr;
        endp:= outp;
        end;

      if outp^=eofs then (* Buffer overflow - do nothing. *)
      else if outp^<>eofr then
        xProgramError('X(iooutwrite) - Program error: eofr was expected.')
      else begin

        (* outp^=eofr *)
        (* Filebufend points at eobl and shall not be overwritten. *)
        if integer(outp)=integer(filebufend)-1 then
          newoutp:= filebufp
        else newoutp:= ioinptr(integer(outp)+1);

        (* Check not to overwrite readpos. *)
        if newoutp=readpos then begin

            (* Wait for 10 s, then give up. *)
            count:= 0;
            while (newoutp=readpos) and (count<100) do begin
                ioEnableAndSleep(100);
                count:= count+1;
                end;
            if newoutp=readpos then begin
              xProgramError('X(iooutwrite): Writing to circular buffer "' + fstostr(filename) + '" - buffer was full (size = ' +
               inttostr(iobufsize-6) + ') and X has waited 10s for other thread to read the data. ' +
               'A circular buffer must be read before it becomes full or there must be a separate thread to read it.' +
               ' (Buffer is cleared.)');
              // outp^:= eofs;
              // Clear buffer to avoid waiting 10 s for each character to be written to the buffer
              readpos:= outp;
              end;
            end;
        if outp^<>eofs then begin
            outp^:= pch;
            outp:= newoutp;
            outp^:= eofr;
            endp:= outp;
            if dataRequest then begin
                SetEvent(WriteEvent);
                dataRequest:= False;
                end;
            end;
        end; (* eofr *)
      end (* acircularbuffer *)

    else if kind=asocket then begin

      (* Try to connect if not connected. *)
      if (socketstate<>connectedAsClient) and (socketstate<>connectedAsServer)
          then ioUpdateSocketState(curoutfilep,pinp);

      (* Write is discarded unless socket is connected. *)
      if (socketstate=connectedAsClient) or (socketState=connectedAsServer)
          then begin

          (* Empty send buffer if necessary. *)
          if outp=sendbufend then iosendsbuf(curoutfilep);

          outp^:= pch;
          outp:= ioinptr(ioint32(outp)+1);
          if (pch=char(13)) and not (binaryfile) then iooutwrite(char(10),pinp);
          end; (* connected *)
      end (* asocket *)

    else if kind=aSerialPort then begin

      (* Empty send buffer if necessary. *)
      if outp=sendbufend then iosendsbuf(curoutfilep);

      outp^:= pch;
      outp:= ioinptr(ioint32(outp)+1);
      if (pch=char(13)) and not (binaryfile) then iooutwrite(char(10),pinp);
      end (* aSerialPort *)

    else xProgramError('X(iooutwrite): Program error (kind<>afile,asocket,aserialport,acircularbuffer),'+
      ' Filename = '+ fstostr(curoutfilep^.filename)+'.');
    end;

end; (*iooutwrite*)


procedure iooutwritefs( pstr:fsptr; pinp: ioinptr ); (* Write output string. *)
var ior: ioint16; newhandle: Tsocket;
begin

if pstr^=eofs then (* - *)

else if curoutfilep=NIL then
   xScriptError('iooutwritefs: Attempt to write "'+fstostr(pstr)+'" but <out> was undefined.'+
      'Note that <out> is undefined after <close <out>>.')

else with curoutfilep^ do if kind=aconsole then iofWriteToWbuf(fstostr(pstr))

else if kind=afile then begin

     while not (pstr^=eofs) do begin

        (* Try to do this without calling iooutwrite for every character. *)
        if (integer(outp)=integer(filebufend)-1) or (outp^<>eofr) then iooutwrite(pstr^,pinp)
        else begin
            outp^:= pstr^;
            outp:= ioinptr(ioint32(outp)+1);
            outp^:= eofr;
            endp:= outp;
            if pstr^=char(13) then iooutwrite(char(10),pinp);
            end;
        fsforward(pstr);
        end; (*while*)
    if dataRequest then begin
        SetEvent(writeEvent);
        dataRequest:= False;
        end;
    end (* afile *)

else if kind=acircularbuffer then begin

     while not (pstr^=eofs) do begin

        (* Try to do this without calling iooutwrite for every character. *)
        if (integer(outp)>=integer(filebufend)-1) or (outp^<>eofr)
          or (ioinptr(integer(outp)+1)=readpos) then iooutwrite(pstr^,pinp)
        else begin
            outp^:= pstr^;
            outp:= ioinptr(ioint32(outp)+1);
            outp^:= eofr;
            endp:= outp;
            if pstr^=char(13) then iooutwrite(char(10),pinp);
            end;
        fsforward(pstr);
        end; (*while*)
    if dataRequest then begin
        SetEvent(writeEvent);
        dataRequest:= False;
        end;
    end (* acircularbuffer *)

else if kind=asocket then begin

    (* Try to connect if not connected. *)
    if (socketstate<>connectedAsClient) and (socketstate<>connectedAsServer)
        then ioUpdateSocketState(curoutfilep,pinp);

    (* Write is discarded unless socket is connected. *)
    if (socketstate<>connectedAsClient) and (socketstate<>connectedAsServer) then
        xScriptError('X: Unable to write to socket '+fstostr(filename)+' because it is'
        +' not connected.')
    else (* (socketstate=connectedAsClient) or (socketState=connectedAsServer) *)
        while not (pstr^=eofs) do begin

        (* Empty send buffer if necessary. *)
        if outp=sendbufend then iosendsbuf(curoutfilep);

        outp^:= pstr^;
        outp:= ioinptr(ioint32(outp)+1);
        if pstr^=char(13) then iooutwrite(char(10),pinp);

        fsforward(pstr);
        end;
    end (* asocket *)

else if kind=aSerialPort then begin

    while not (pstr^=eofs) do begin

        (* Empty send buffer if necessary. *)
        if outp=sendbufend then iosendsbuf(curoutfilep);

        outp^:= pstr^;
        outp:= ioinptr(ioint32(outp)+1);
        if pstr^=char(13) then iooutwrite(char(10),pinp);

        fsforward(pstr);
        end;
    end; (* aSerialPort *)

end; (*iooutwritefs*)


procedure ioremovefile(pfilep: filerecptr; pinp: ioinptr );
type addrptr= ^ioinptr;
var
bufp,p,nextbufp: ioinptr;
prev: filerecptr;
addrp: addrptr;
clo,rc: integer;
fip: fileinfoptr;
readfds: TFDSet;
n: longint;
timeout: TTimeVal;
errcode: integer;
d: array[1..1000] of char;
BytesRead: Cardinal;

begin

with pfilep^ do begin

   // Check that buffer is not reserved for <p n>
   if readrescnt<>0 then
      xScriptError('ioremovefile: script error - file ' + fstostr(filename) +
         ' was removed while still in the output part of an alternative ' +
         'that was reading from the file (risk that <p n> references can ' +
         'invalid). (readrescnt=' + inttostr(readrescnt) + ').');

   // Used for error messages when unable to restore input file.
   saveoldfilename(nr,filename);

   if kind=afile then begin
        bufp:= filebufp;
        while not (bufp=nil) do begin
            p:= ioinptr(ioint32(bufp)+iobufsize-4);
            addrp:= addrptr(p);
            nextbufp:= addrp^;
            FreeMem(bufp);
            bufp:= nextbufp;
            end;
        end (*afile*)

   else if kind=acircularbuffer then begin
        bufp:= filebufp;
        FreeMem(bufp);
        end (*acircularbuffer*)

    else if kind=asocket then begin

        (* Update socket status before close. *)
        ioupdatesocketstate(pfilep,pinp);

        (* Empty the send buffer. *)
        if outp<>sendbufp then iosendsbuf(pfilep);

        (* Send possible odd hex char. *)
        if (binaryfile) and (outp<>sendbufp) then begin
            xProgramError(
              'X(ioremovefile): Socket '+fstostr(filename)
               +' ends with odd hex character.');
            outp^:= '0';
            outp:= ioinptr(ioint32(outp)+1);
            iosendsbuf(pfilep);
            end;

        (* Use select to find out if there is anything more to read. *)
        with readfds do begin
          fd_count:= 1;
          fd_array[0]:= sockhand;
          end;
        (* {0,0} = return immediately *)
        with timeout do begin
          tv_sec:= 0;
          tv_usec:= 0;
          end;

        n:= select(0,@readfds,NIL,NIL,@timeout);
        if n=socket_error then begin
            xProgramError('X(ioRemovefile): Error from select ('+
            inttostr(WSAGetLastError)+').');
            end
        else if n>0 then begin

            (* Something to read. *)
            rc:= recv(sockhand,filebufp^,iobufsize,0);
            if rc=socket_error then begin
               errcode:= WSAGetLastError;
               if errcode=10054 then
                  (* - 10054 = connection reset by peer - give no error message. *)
               else if errcode=10057 then
                  (* - 10057 = not connected. - give no error message. *)
               else xProgramError(
                 'X(ioremovefile): Unable to call recv ('
                   +inttostr(errcode)+').');
               end; (*socket_error*)
            end;

        FreeMem(filebufp);
        FreeMem(sendbufp);
        clo:= closesocket(sockhand);
        if clo<>0 then begin
            errcode:= WSAGetLastError;
            // Accept 10054 -  connection reset by peer - as normal
            if errcode<>10054 then xProgramError('X(ioremovefile): Unable to close socket '
              +fstostr(filename)+' ('+inttostr(WSAGetLastError)+').');
            end;
        end (*asocket*)

    else if kind=aSerialPort then begin

        (* Empty the send buffer. *)
        if outp<>sendbufp then iosendsbuf(pfilep);

        (* Send possible odd hex char. *)
        if (binaryfile) and (outp<>sendbufp) then begin
            xProgramError(
              'X(ioremovefile): Socket '+fstostr(filename)
               +' ends with odd hex character.');
            outp^:= '0';
            outp:= ioinptr(ioint32(outp)+1);
            iosendsbuf(pfilep);
            end;

        if ioReadableSerialPort(comHand) then begin

            (* Something to read (and throw).  (is this necessary?)*)
            if windows.readFile(comHand,d,sizeof(d),BytesRead,nil) then (* - *)
            else xProgramError('X(ioremovefile): Program error - Readfile failed.');
            end;

        FreeMem(filebufp);
        FreeMem(sendbufp);
        if not windows.closeHandle(comhand) then xProgramError(
          'X(ioremovefile): Unable to close socket '
          +fstostr(filename)+' ('+inttostr(WSAGetLastError)+').');
        end; (*aSerialPort*)

    (* Common cleaning up: *)
    fsdispose(filename);
    while fileinfo<>nil do begin
        fip:= fileinfo^.next;
        FreeMem(fileinfo);
        fileinfo:= fip;
        end;

    if pfilep=files then files:=next
    else begin
        prev:= files;
        while not ( (prev=nil) or (prev^.next=pfilep) ) do prev:= prev^.next;
        if prev=nil then raise exception.Create(
          'X(ioremovefile): Program error - prev=nil.');
        prev^.next:= prev^.next^.next;
        end;

    (* win32 writeevent *)
    if dataRequest then xProgramError(
      'ioremovefile: Program error - datarequest was unexpectedly true.');
    if writeEvent<>0 then begin
      (* Wake up any waiting thread (there should not be any). *)
      setEvent(WriteEvent);
      //ioEnableAndSleep(1); Removed because it slowed down applications with frequent
      //creation and removal of files (ida2trk)/BFn 090306)
      (* Release resources *)
      windows.closeHandle(writeEvent);
      end;

    ExistingFilesCount:= ExistingFilesCount-1;
    end; (*with*)

dispose(pfilep);

end; (*ioremovefile*)


procedure iodeletefile( pfilep: filerecptr; var pinp: ioinptr );
(* Delete a file from the files list (not from disk).
   Used by <delete filename> and <delete domain:portnr>
   and alCleanup. *)

begin

with pfilep^ do begin

   (* If file is current input or output, go to console. *)
   if pfilep=curinfilep then ioSwitchInput(nullinfilep,pinp);
   if pfilep=curoutfilep then ioSwitchOutput(nil);

   (* Not possible to delete file if still referenced by other thread. *)
   if refcount>0 then xScriptError('X(iodeletefile): File '+fstostr(filename)+
      ' is referenced by other thread (refcount>0), cannot be deleted.')

   else begin
      if refcount<0 then xProgramError('X(iodelete): Program error - refcount<0.');

      // Release all unread strings belonging to this file.
      if xunr.active then
         xunr.unrCheckReleaseAll(pfilep);

      (* Release memory. *)
      ioremovefile(pfilep,pinp);
      end;
   end; (* with *)

end; (*iodeleteFile*)


procedure iodelete( pfilename: fsptr; var pinp: ioinptr );
(* Delete a file from the files list (not from disk).
   Implements <delete filename>
   and <delete domain:portnr>. *)
var
filep:filerecptr;

begin

filep:= iofindfile(pfilename,eofs);
if filep=nil then
   xScriptError('<delete ...>: File '+fstostr(pfilename)+' not found.')

(* Delete the file, but not if it is the console. *)
else if filep^.kind<>aconsole then ioDeleteFile(filep,pinp);

end; (*iodelete*)


procedure iorename( pfilename1,pfilename2: fsptr; var pinp: ioinptr );
(* Rename a file in the files list (not on disk).
   Implements <rename filename,filename>
   and <rename domain:portnr,filename>. *)
var
filep1,filep2:filerecptr;

begin
filep1:= iofindfile(pfilename1,eofs);
if filep1=nil then xScriptError(
     '<rename ...>: File to rename ('+fstostr(pfilename1)+') was not found.')

else if filep1^.kind=asocket then xScriptError(
     '<rename ...>: Not possible to rename an internet socket ('
     +fstostr(pfilename1)+').')

else if filep1^.kind=aserialport then xScriptError(
     '<rename ...>: Not possible to rename a serial port ('
     +fstostr(pfilename1)+').')

else begin
    filep2:= iofindfile(pfilename2,eofs);
    if (filep2<>nil) then xScriptError(
     '<rename ...>: New filename ('+fstostr(pfilename2)+') was already used.')

    else with filep1^ do begin

        (* Just change its name *)
        fsrewrite(filename);
        fscopy(pfilename2,filename,eofs);
        end; (*ok to rename *)
    end; (* pfilename1 found. *)

end; (*iorename*)


procedure iocreateDirIfNecessary(pfilename: string);
(* Create new directory if pfilename contains a directory that does not exist. *)
var
filedir: string;
lastslash: integer;
begin

lastslash:= lastdelimiter('/\',pfilename);
if lastslash<>0 then begin
   filedir:= Leftstr(pfilename,lastslash-1);
   if filedir<>'' then begin
      (* Create dir if it does not already exist. *)
      if not DirectoryExists(filedir) then
         if not CreateDir(filedir) then begin
            if comparetext(filedir,'temp')=0 then
               xScriptError('X(<close ...>): Unable to create a directory named "temp" when saving file '+
               pfilename+'. Please use other directory name.')
            else
               xScriptError('X(<close ...>): Unable do create directory for '+
               pfilename+
               ' (failure code: '+syserrormessage(getlasterror)+').');
            end;
      end;
   end;

end; (*iocreateDirIfNecessary*)


procedure ioInNull(var pinp: ioinptr);
(* Restore current input file to none (used if in enterstring if infile became
   deleted). *)
begin

ioSwitchInput(nullInFilep,pinp);

end; (*ioInNull*)

procedure ioOutNull;
(* Restore current output file to none (used if in enterstring if outfile became
   deleted). *)
begin

ioSwitchOutput(nil);

end; (*ioOutNull*)

function istempfile(pfname: fsptr): boolean;
var res: boolean; nr: integer;
begin
   res:= false;
   if pfname^='t' then begin
      fsforward(pfname);
      if pfname^='f' then begin
         nr:= 0;
         fsforward(pfname);
         if pfname^ in ['0'..'9'] then begin
            nr:= nr*10 + integer(pfname^) - integer('0');
            fsforward(pfname);
            end;
         if pfname^=eofs then begin
            if nr <=uniqueFileNameTabSize then begin
               if uniqueFileNameTab[nr] then res:= true;
               end;
            end;
         end;
      end;

   istempfile:= res;
end; (*istempfile*)




procedure ioclosefilerec( pfrp: filerecptr; var pinp: ioinptr);
(* Remove a file record and do all necessary cleaning up
   (like iodelete, except that file buffers which were written to must be
   written to disk before they are deleted). *)
type addrptr = ^ioinptr;
var
f: file;
done,skip,clickedok: boolean;
ior: integer;
bufp,p,nextbufp,lastCharPtr: ioinptr;
blsize,cnt: ioint32;
filep: filerecptr;
fname: string;
addrp: addrptr;
totalcnt: ioint32;
freespace: integer;
ptr: ioinptr;
size: ioint32;
failcnt: integer;
lastslash: integer;
left,right,newname: string;
slash: char;

begin
(***)if alflagga('D') then begin
(***)iodebugmess('ioclosefilerec: '+fstostr(pfrp^.filename)+'.');
(***)end;
with pfrp^ do if (kind=afile) and not usedforoutput then iodelete(filename,pinp)

else begin
   if (kind=afile) and usedforoutput and not istempfile(filename) then begin

      fname:= fstostr(filename);

      (* Check if fname contains any new directory that shall be created. *)
      iocreateDirIfNecessary(fname);

      (* Try opening it for write. *)
      done:= false; skip:= false;
      failcnt:= 0;
      while not (done or skip) do begin
         (*$I-*)
         AssignFile(f,fname);
         ior:= ioResult;
         if ior=0 then begin
            rewrite(f,1); (* 1 byte record size *)
            ior:= ioresult;
            end;
         if ior=0 then done:= true
         else if althreadnr=0 then begin
            (* Ask user for another filename: *)
            clickedOK:= inputQuery('X',
'It was not possible to open out-file '+fname+ ' for write.'+
' Try other filename, or use cancel to lose the file.',fname);
            if not clickedOK then skip:= true;
            end
         else begin
            failcnt:= failcnt+1;
            if failcnt=3 then begin
               xScriptError('X(<close ...>) Unable to open file "' + fname +
                  '" for write - giving up.');
               skip:= True;
               end
            else begin
               LastSlash:= LastDelimiter('\/',fname);
               if (LastSlash>0) and (LastSlash<=length(fname)) then begin
                  left:= LeftBstr(fname,LastSlash-1);
                  Slash:= fname[LastSlash];
                  right:= RightBstr(fname,length(fname)-LastSlash);
                  newname:= left + Slash + 'x'+ right;
                  end
               else newname:= 'x' + fname;
               ioErrmessWithDebugInfo('X(<close ...>) Unable to open file "' + fname +
                  '" for write, trying "' + newname + '" instead.');
               fname:= newname;
               // fname:= 'x'+fname;
               end;
            end;
         (*$I-*)
         end; (*while*)

      (* Write the buffers to the file (or just release them if skip). *)
      bufp:= filebufp; totalcnt:= 0;
      while not (bufp=nil) and not skip do begin

         (* Find out pointer to next buffer. *)
         p:= ioinptr( ioint32(bufp)+iobufsize-4);
         addrp:= addrptr(p);
         nextbufp:= addrp^;

         (* Calculate block size. *)
         if ioinptr(ioint32(bufp)+iobufsize-6)=filebufend then begin
            (* Last buffer. Move the output pointer to the end of the file
               (eofr or eofs) if it is not there already. *)
            if outp^<eofr then outp:= outpsave;
            if outp^<eofr then begin
               (* End of file still not found. Go to the beginning of the block
                  and move forward until eofr or eofs is found. *)
               (* (Is this necessary? outpsave shall point at eofr/eofs if
                  outp does not, according to the description of outpsave /BFn 170315. *)
               outp:= bufp;
               while not (outp^>=eofr) do outp:= ioinptr(ioint32(outp)+1);
               end;
            freespace:= (iobufsize-6) - (ioint32(outp)-ioint32(bufp));

            (* See if last byte was an added CR when the file was read from
               disk. When reading a file from disk, X makes sure that the last
               line ends with CR. If not, it adds CR to the last line, to
               simplify scanning. If such a file is written back to disk, then
               the added CR not be written to disk. *)
            if addedCrPtr<>nil then begin
               lastCharPtr:= ioinptr(ioint32(outp)-1);
               if (lastCharPtr=addedCrptr) and (lastCharPtr^=char(13)) then
                  // Remove the last char.
                  freespace:= freespace-1;
               end;
            end
         else begin
            (* Blocks other than the last: Before the next pointer, there is a
               byte telling if there unused space at the end of the block.
               Unused spaces at the end of blocks, other than the last,
               can only arise as result of replacing text (with <replacewith ...>).
               The normal value is 0 (no unused space). 1..250 means that
               so many bytes are unused at the end of the block. 251 means that
               more than 250 bytes are unused at the end of the block. The last
               byte must then be found by stepping from the beginning of the
               block to the code 252 (eobl). *)
            freespace:= byte(ioinptr(ioint32(bufp) + iobufsize - 5)^);
            if freespace>250 then begin
               (* Size of freespace is >250 bytes. Find beginnig of free space
                  by searching for eobl. *)
               ptr:= bufp;
               while not (ptr^=eobl) do ptr:= ioinptr(ioint32(ptr)+1);
               freespace:= iobufsize-6- (ioint32(ptr)-ioint32(bufp));
               end;
            end;
         blsize:= iobufsize-6-freespace;
         if nextbufp=nil then begin (* Last buffer may not be full. *)
            (* Do some checking... *)
            if not (ioint32(bufp)+iobufsize-6 = ioint32(filebufend))
               then xProgramError('X(ioclosefilerec): Program error (last '+
               'buffer end <> filebufend).');
            if not ( (blsize>=0) and (blsize<=(iobufsize-6)) )
               then xProgramError('X(ioclosefilerec): Program error (block '+
               'size - '+inttostr(blsize)+' - not within bounds, '+
               'buf="'+ioptrtostr(bufp)+'".');
            end;

         (* Accumulate totalcnt before reducing blsize for binary files. *)
         totalcnt:= totalcnt+blsize;

         if binaryfile then begin
            if (blsize and 1) <> 0 then begin
                xProgramError(
                   'X(ioclosefilerec): Binary output file'+fname
                   +'has odd number of hex characters.');
                ioinptr(ioint32(bufp) + blsize)^:='0';
                if blsize>(iobufsize-6) then raise exception.create(
         'X(ioclosefilerec): Program error - pos outside bound.');
                blsize:= blsize+1;
                end;
            (* Convert hex coded data to binary data. Write to the same buffer is ok,
               because the result data is only half the length of the original data. *)
            iohextobin(bufp,blsize,bufp);
            blsize:= blsize div 2;
            end;

         if nextbufp=nil then begin
            // Last buffer, print size message to x window.
            if binaryfile then size:= totalcnt div 2
            else size:= totalcnt;
            iofWritelnToWbuf('size='+inttostr(size)+'('+fname+')');
            end;

         if (blsize>0) and not skip and not xFault then begin
            // Time to write the data, of one buffer, to disk.
            (*$I-*)
            BlockWrite(f,bufp^,blsize,cnt);
            ior:= ioResult;
            (*$I+*)
            if ior<>0 then
                xProgramError('X(ioclosefilerec): Error during writing to file'+
                  fname +'(error code='+inttostr(ior)+').')
            else if cnt<>blsize then xProgramError(
               'X(ioclosefilerec): Disk became full while writing to file '+
                fname+' - cnt('+inttostr(cnt)+')<>blsize('+inttostr(blsize)+').')
            end; (*blsize>0 and not skip*)

         bufp:= nextbufp;
         end; (*while*)

      (* close file *)
      (*$I-*)
      closefile(f);
      ior:= IOResult;
      if not skip and not xFault and (ior<>0) then xProgramError(
      'X(ioclosefilerec): Program error (ioresult='+inttostr(ior)
      +'from closefile).');
      (*$I+*)
      end; (* afile and usedforoutput but not temporary. *)

   // Release all unread strings belongning to this file.
   if xunr.active then
      xunr.unrCheckReleaseAll(pfrp);

   (* Release memory resources. *)
   ioremovefile(pfrp,pinp);
   end; (* kind/=afile or =afile and usedforoutput *)

end; (*ioclosefilerec*)


procedure ioclose( pfilename,pasfilename: fsptr; var pinp: ioinptr);
(* Remove a file or socket from the file list. If outfile: write
   it to disk. If socket: send unsent characters. Release buffers.
   Implements <close filename>, <close domain:portnr>
   and <close filename[,asfilename]>. *)
var
ior: ioint16;
filep,nextf: filerecptr;
emptystr: string;

begin
emptystr:= '';

(* Create new directory if pasfilename contains a direcory that does not exist. *)
//ioCreateDirIfNecessary(pasfilename);

if alfstostr100(pfilename,eofs)='cons' then (* (do nothing) *)
else if alfstostr100(pfilename,eofs)='*' then begin

   ioSwitchInput(nullinfilep,pinp);

   ioSwitchOutput(nil);

    if not xFault then begin
      filep:= files;
      while filep<>nil do begin
        nextf:= filep^.next;
        // (new:)
        if (filep=consfilep) or (filep=nullinfilep) then (* leave untouched *)
        // (old:)if fsEqualFilename(filep^.filename,consfs,eofs,eofs) then (* save *)
        else if filep^.refcount>0 then with filep^ do begin
          iooutgotoend(filep);
          outp^:= eofs; (* Signal to reading thread
          that the file is closed. *)
          if dataRequest then begin
              SetEvent(writeEvent);
              dataRequest:= False;
              end;
          xScriptError('Unable to close file '+
            fstostr(filep^.filename)+' because thread was reading (refcount='+
            inttostr(refcount)+' when 0 was expected)(1).');
          end (* refcount>0 *)
        else begin
          // refcount<=0
          if filep^.refcount<0 then
            xProgramError('X(ioclose): Program error. refcount<0.');
          ioclosefilerec(filep,pinp);
          end;
        filep:= nextf;
        end; (* while *)
      end; (*not xFault*)

   if pasfilename^<>eofs then xScriptError(
        '<close *,'+fstostr(pasfilename)+'>: Unable to close "*" under other filenames.');
    end (* <close *> *)

else if pfilename^=eofs then xScriptError('<close ...>: File name was empty.')

else begin

   filep:= iofindfile(pfilename,eofs);

   if filep=nil then xScriptError('File ('+fstostr(pfilename)+') was not found.')

   else begin

      if filep=curinfilep then ioSwitchInput(nullinfilep,pinp);

      if filep=curoutfilep then ioSwitchOutput(nil);

      if not xFault and (filep=consfilep) then
         xScriptError('File '+fstostr(pfilename)+' is console, cannot be closed.');

      if not xFault then if (filep^.refcount>0) then with filep^ do begin
         (* Sockets and serialports use separate sendbuf, which cannot be read from. *)
         if (filep^.kind=asocket) then begin
            if inpsave^<>eofr then xScriptError('X(ioclose socket): Char "' + inpsave^ +
               '" was found when Eofr was expected - possible error in X.');
            inpsave^:= eofs;
            xScriptError('Unable to close socket '+fstostr(filep^.filename)+
               ' because thread was reading (refcount='+inttostr(filep^.refcount) +
               ' when 0 was expected).');
            end

         else if (filep^.kind=aserialport) then begin

            if inpsave^<>eofr then xProgramError('X(ioclose serialport): Char "' + inpsave^ +
               '" was found when Eofr was expected - possible error in X.');
            inpsave^:= eofs;
            xScriptError('Unable to close serial port '+fstostr(filep^.filename)+
               ' because thread was reading (refcount='+inttostr(filep^.refcount) +
               ' when 0 was expected).');
            end

         else begin

            iooutgotoend(filep);
            outp^:= eofs; (* Signal to reading thread that the file is closed. *)
            if dataRequest then begin
               SetEvent(writeEvent);
               dataRequest:= False;
               end;
            xScriptError('Unable to close file '+fstostr(filep^.filename)+
               ' because thread was reading (refcount='+inttostr(filep^.refcount) +
               ' when 0 was expected) (3).');
            end; (* not socket or serial port. *)
         end (* not xfault and filep<>nil and refcount>0 *)

      else if filep<>nil then if not xFault then begin
         if filep^.refcount<0 then
            xProgramError('X(ioclose): Program error - refcount<0('+
            inttostr(filep^.refcount)+').');
         (* Change filename of pasfilename is specified. *)
         if pasfilename^<>eofs then begin
            fsrewrite(filep^.filename);
            fscopy(pasfilename,filep^.filename,eofs);
            end;
         ioclosefilerec(filep,pinp);
         end;
      end;
   end; (* else *)

end; (*ioclose*)

procedure ioOpenFiles( pfuncret: fsptr);
(* Append line based list of open file names to pfuncret.
   Implements <xdir>. *)
(* Remove a file or socket from the file list. If outfile: write
   it to disk. If socket: send unsent characters. Release buffers.
   Implements <close filename>, <close domain:portnr>
   and <close filename[,asfilename]>. *)

var
filep: filerecptr;

begin

if not xFault then begin
   filep:= files;
   while filep<>nil do begin
      fscopy(filep^.filename,pfuncret,eofs);
      fspshend(pfuncret,char(13)); // CR = line delimiter
      filep:= filep^.next;
      end;
   end;
end; (*ioOpenFiles*)


function ionewfs(ps: string): fsptr; (* Create fs from a string. *)
(* Note: This function must not be used often since it causes memory
   leakage each time it is used (unless the resulting fs is disposed). *)
var s: fsptr; i: ioint16;

begin
fsnew(s); ionewfs:= s;
FOR i:= 1 TO length(ps) do fspshend(s,ps[i]);
(* Note: s is not disposed. (A limited memory leakage). *)
end; (*ionewfs*)

function ioptrtostr400( pinp: ioinptr ): string;
(* Convert pinp^ up to eofs or eofr or max 400 char's
   to a string. *)

var cnt,nulcnt: ioint16; s: shortstring;
begin
s:= '';
cnt:= 0;
nulcnt:= 0;
while not ( (pinp^=eofs) or (pinp^=eofr)  or (cnt=400)  or (nulcnt>=3)) do begin
    if (pinp^=char(13)) or (pinp^=char(10)) then
      s:= s + char(13) (*(This used to be writeln before.)*)
    else if pinp^=char(0) then begin
      s:= s + '(nul)';
      nulcnt:= nulcnt+1;
      end
    else s:= s + (pinp^);
    cnt:= cnt+1;
    ioinforward(pinp);
    end;
if not ((pinp^=eofs) or (pinp^=eofr)) then s:= s + '...';

ioptrtostr400:= s;

end; (*ioptrtostr400*)

function ioptrtostr( pinp: ioinptr ): string;
(* Convert pinp^ up to eofs or eofr or max 40 char's
   to a string. *)

var cnt,nulcnt: ioint16; s: shortstring;
begin
s:= '';
cnt:= 0;
nulcnt:= 0;
while not ( (pinp^=eofs) or (pinp^=eofr)  or (cnt=37)  or (nulcnt>=3)) do begin
    if (pinp^=char(13)) or (pinp^=char(10)) then
      s:= s + char(13) (*(This used to be writeln before.)*)
    else if pinp^=char(0) then begin
      s:= s + '(nul)';
      nulcnt:= nulcnt+1;
      end
    else s:= s + (pinp^);
    cnt:= cnt+1;
    ioinforward(pinp);
    end;
if not ((pinp^=eofs) or (pinp^=eofr)) then s:= s + '...';

ioptrtostr:= s;

end; (*ioptrtostr*)


procedure iodostoiso( var pch: CHAR );
(* Convert from DOS-ascii to ISO-ASCII (ISO8859-1). *)
begin
CASE ORD(pch) OF
    143: PCH:= char($C5); // 'Å'
    142: pch:= char($C4); // 'Ä'
    153: pch:= char($D6); // 'Ö'
    134: pch:= char($E5); // 'å'
    132: pch:= char($E4); // 'ä'
    148: pch:= char($F6); // 'ö'
    144: pch:= char($C9); // 'É'
    130: pch:= char($E9); // 'é'
    else ;
    end;
end; (*iodostoiso*)

function ioUni2iso( pStr: string ): string;
(* Convert from Unicode to ISO-ASCII (ISO8859-1).
   As yet, limited to swedish characters.

   C384 = 'Ä' (C4)
   C385 = 'Å' (C5)
   C396 = 'Ö' (D6)
   C389 = 'É' (C9)

   C3A4 = 'ä' (E4)
   C3A5 = 'å' (E5)
   C3B6 = 'ö' (F6)
   C3A9 = 'é' (E9)

   $C0-$80 = $40 = 64
   $D0-$90 = $40 = 64
   $E0-$A0 = $40 = 64
   $F0-$B0 = $40 = 64

   =>   Add 64 to char 2 to get Iso Latin-1.
   Tillåt ej tecken över 252 (motsv UTF8 188 = $BC).
   *)
var
i1,i2: integer; ch1,ch2: char; last: integer;
res: string;

begin
last:= length(pStr);
i1:= 0;
res:= '';
while i1 < last do begin
   i1:= i1+1;
   ch1:= pStr[i1];
   if ch1>=char($C2) then begin
      if ch1= char($C3) then begin
         // UTF-8 escape character
         if i1 < last then begin
            i1:= i1+1;
            ch1:= pStr[i1];
            if integer(ch1)<=188 then ch2:= char(integer(ch1)+64)
            else ch2:= '?';
            res:= res+ch2;
            end
         else res:= res + ch1;
         end
      else res:= res + '?';
      end
   else res:= res + ch1;
   end; (* while *)

ioUni2iso:= res;

end; (*ioUni2iso*)


function ioIso2Uni( pStr: string ): string;
   (* Convert from ISO-ASCII (ISO8859-1) to Unicode .
      As yet, limited to swedish characters.

      UTF8   ISO
      ----   ---
      C384 = 'Ä' (C4)
      C385 = 'Å' (C5)
      C396 = 'Ö' (D6)
      C389 = 'É' (C9)

      C3A4 = 'ä' (E4)
      C3A5 = 'å' (E5)
      C3B6 = 'ö' (F6)
      C3A9 = 'é' (E9)

      $C0-$80 = $40 = 64
      $D0-$90 = $40 = 64
      $E0-$A0 = $40 = 64
      $F0-$B0 = $40 = 64

      =>   If char > $7F, then replace with UTF escape char C3 + char - 64.
      *)
var
i1,i2: integer; ch1: char; last: integer;
res: string;

begin
last:= length(pStr);
i1:= 0;
res:= '';
while i1 < last do begin
   i1:= i1+1;
   ch1:= pStr[i1];
   if ch1>=char($7F) then
      res:= res + char($C3) + char(integer(ch1)-64)
   else res:= res + ch1;
   end; (* while *)

ioIso2Uni:= res;

end; (*ioIso2Uni*)


procedure ioMessageBox( ps: string );
(* Show a message box (with ok button), or
   send string to output window, if threads are used. *)
var
p,p0: fsptr;
begin

if iomsgboxtooutputwindow and not xFault then
   (* Avoid message box, use output window instead. *)
   iofWritelnToWbuf(ps)

else if althreadnr=0 then iofshowmess(ps)

(* If threads are used: use postmessage. *)
else begin
  // Create fs string. Send its adress to winmain function
  // This will then call iofshowmess and dispose of the fs string
  // IOFSHOWMESSAGE is used to identify this message from other messages to
  // winmain function
  fsnew(p);
  p0:= p;
  alstrtofs(ps,p);
  postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFSHOWMESSAGE,longint(p0));
  // To enable windows to show the message
  ioEnableAndSleep(1);
  end;

end; (*ioMessageBox*)

procedure ioErrmessCompile( ps: string );
(* Show an error message box (with ok button), or
   send string to output window, if threads are used.
   This is the same ast ioErrmessWithDebugInfo, except without
   debug info. *)
var
len: integer;
s: string;
begin
(* Remove any nul-char and after it because else the xdebuginfor will not
   be visible. *)
len:= StrLen(pchar(ps));
s:= leftstr(ps,len);
ioMessageBox(s);
end; (* ioErrmessCompile *)

procedure ioErrmessWithDebugInfo( ps: string );
(* Add debug info to the string. Then show an error message box (with ok button),
   or send string to output window, if threads are used. *)
var
len: integer;
s: string;
begin
(* Remove any nul-char and after it because else the xdebuginfor will not
   be visible. *)
len:= StrLen(pchar(ps));
s:= leftstr(ps,len);
ioMessageBox(s+' '+xdebuginfo);
end; (* ioerrmessWithDebugInfo *)


procedure iomessage( pcaption,ps: string );
(* Like ioerrmess except it enables specifying caption also.
   Show an error message box (with ok button), or
   send string to output window, if threads are used. *)
var s: string;
p,p0: fsptr;
len: integer;
begin

(* Remove any nul-char and after it because else the xdebuginfor will not
   be visible. *)
len:= StrLen(pchar(ps));
s:= leftstr(ps,len);

if iomsgboxtooutputwindow and not xFault then
   (* Avoid message box, use output window instead. *)
   iofWritelnToWbuf(s+' '+xdebuginfo)

else if althreadnr=0 then
   MessageBox(0, pchar(s+' '+xdebuginfo),pchar(pcaption), mb_ok)

   // iofshowmess(s+' '+xdebuginfo)

(* If threads are used: use postmessage. *)
else begin
  // Create fs string. Send its adress to winmain function
  // This will then call iofshowmess and dispose of the fs string
  // IOFSHOWMESSAGE is used to identify this message from other messages to
  // winmain function
  fsnew(p);
  p0:= p;
  alstrtofs(pcaption+': '+s+' '+xdebuginfo,p);
  postmessage(iofCurrentFormHandle,IOFMESSAGE,IOFSHOWMESSAGE,longint(p0));
  // To enable windows to show the message
  ioEnableAndSleep(1);
  end

end; (*iomessage*)



procedure iothreaderrmess( ps: string );
(* Send string to output window. *)
begin
iofWritelnToWbuf(ps+' '+xdebuginfo);
end; (*iothreaderrmess*)

procedure iodebugmess( ps: string );
(* Show a debug message (to a memo box?). *)
begin
(* Showmess is supposed to be temporary until
   a better solution is found. *)
//iofshowmess(ps);
iofWritelnToWbuf(ps);
end; (*iodebugmess*)

procedure ioreadln( ps: fsptr );
(* Read a line using a pop-up window. *)
var s: string; i: integer;
begin
iofreadln(s);
for i:= 1 to length(s) do fspshend(ps,s[i]);
end; (*ioreadln*)


procedure iocleanup( var pinp: ioinptr );
(* Delete all files and sockets. *)
var ior: ioint16;
fp,fpnext: filerecptr;
timeleft: integer;
begin

iofWriteWbufToResarea(false);

(* Terminate all threads. *)
if althreadcount>0 then begin
   iodoingcleanup:= True;
   timeleft:= 2000; (* Wait no more than 2 seconds since threads shall look at
      the iodoingcleanup variable once every second. *)
   while (althreadcount>0) and (timeleft>0) do begin
      ioEnableAndSleep(10);
      timeleft:= timeleft-10;
      end;
   if althreadcount>0 then
      xScriptError('X(<cleanup>): Unable to terminate all threads.');
   iodoingcleanup:= false;
   end;

(* Redirect current input and output to console. *)
ioin(consfs,eofs,[],-1,false,ionone,emptystr,false,false,pinp);

(* Redirect output to console. *)
ioout(consfs,eofs,-1,false,ionone,emptystr,false,pinp);

fp:= files;
fpnext:= files^.next;
while fp<>nil do with fp^ do begin
   fpnext:= next;
   if fp^.kind=aconsole then (* - *)
   else if fp=nullinfilep then (* - *)
   else if fp^.refcount>0 then xScriptError(
    'X(<cleanup>): Unable to close file '
    + fstostr(fp^.filename)+' because it is still referenced '
      + 'by other thread(s).')
   else
      iodeletefile(fp,pinp);
   fp:= fpnext;
   end;

if ExistingFilesCount<>2 then
   xProgramError('X(<cleanup>): Was unable to close all files.')
else begin
   (* Reset unread buffer. *)
   unrbufend:= ioinptr(ioint32(unrbufp)+iounrbuflen-1);
   unrbufend^:=eofs;
   unrbottom:= unrbufend;
   pnstacktop:= unrbufp;
   pnsl:= 0;
   end;

xoptcr:= ' ';
xoptcr2:= ' ';
ioinclearcons(pinp);

(* Clear warning for illegal characters. *)
speccharwarningissued:= false;

(* Clean up new unread function (May 2018). Ported from xnewgui (c). *)
if xunr.active then xunr.cleanup;

(* Delete all threads ... (tbd) *)

end; (*iocleanup*)

procedure ioinfo(pfilename: fsptr; pendch: char; var pfuncret: fsptr);
(* Print information about a file or a socket. *)

var
filep: filerecptr;
str: string;
readfds,writefds,errorfds: TFDSet;
n: longint;
timeout: TTimeVal;
i: integer;
ch: char;
sockOpterrCode,status,errorCodeSize,ioctlErrCode: integer;
numberofbytes: integer;
errors: cardinal;
state: Tcomstat;
pstate: pComstat;

(* Delphi:
function comstatetostrDelphi(pcomstate: tcomstateflags): string;
var s: string;
begin
s:= '';
if fctlhold in pcomstate then s:= s + '1' else s:= s + '0';
if fDsrHold in pcomstate then s:= s + '1' else s:= s + '0';
if fRlsHold in pcomstate then s:= s + '1' else s:= s + '0';
if fXoffHold in pcomstate then s:= s + '1' else s:= s + '0';
if fXOffSent in pcomstate then s:= s + '1' else s:= s + '0';
if fEof in pcomstate then s:= s + '1' else s:= s + '0';
if fTxim in pcomstate then s:= s + '1' else s:= s + '0';
comstatetostrDelphi:= s;
end;
*)

(* FPC: *)

function comstatetostrFpc(pcomstate: DWORD): string;
var s: string; i: integer; comstate: DWORD;
begin
s:= '';
comState:=  pComState;
for i:= 1 to 21 do begin
   if comstate mod 2 = 1 then s:= s + '1' else s:= s + '0';
   comstate:= comstate div 2;
   end;
comstatetostrFpc:= s;
end;

begin (*ioinfo*)

str:= '';

(* Find port in question. *)
filep:= iofindfile(pfilename,pendch);

if filep=nil then
   ioErrmessWithDebugInfo('<info ...>: Unable to find file or socket '
      +alfstostr100(pfilename,pendch)+'.')
else with filep^ do begin

    if kind=afile then str:= str+'kind=afile'
    else if kind=aconsole then str:= str+'kind=aconsole'
    else if kind=aserialport then str:= str+'kind=aserialport'
    else if kind=asocket then str:= str+'kind=asocket'
    else if kind=aserialport then str:= str+'kind=aserialport'
    else if kind=aserialport then str:= str+'kind=acircularbuffer';

    if binaryfile then str:= str + ' (binary) '
    else str:= str + ' (ascii) ';

    ch:= filebufp^; if ch=eofs then ch:= '|';
    str:= str + ' filebufp^=' + ch;
    ch:= inpsave^; if ch=eofs then ch:= '|';
    str:= str + ' inpsave^=' + ch;
    ch:= outp^; if ch=eofs then ch:= '|';
    str:= str + ' outp^=' + ch;

    if usedforoutput then str:= str + ' usedforoutput'
    else str:= str + 'not usedforoutput';

    if kind=asocket then begin

        str:= str + char(13);

        str:= str + ' sockhand='+inttostr(sockhand);

        str:= str + ' socketstate=' + socketStateToString(filep);

        str:= str + ' preferredrole=';
        case preferredrole of
            ionone: str:= str + 'none';
            ioclient: str:= str + 'client';
            ioserver: str:= str + 'server';
            end;

        if outp=sendbufp then str:= str + ' sendbuffer empty'
        else str:= str + ' sendbuffer not empty';

      (* Check if someone has connected to us. *)
      with readfds do begin
        fd_count:= 1;
        fd_array[0]:= sockhand;
      end;
      with writefds do begin
        fd_count:= 1;
        fd_array[0]:= sockhand;
      end;
      with errorfds do begin
        fd_count:= 1;
        fd_array[0]:= sockhand;
      end;
      (* {0,0} = return immediately *)
      with timeout do begin
        tv_sec:= 0;
        tv_usec:= 0;
        end;

      n:= select(0,@readfds,@writefds,@errorfds,@timeout);
      if n=socket_error then ioErrmessWithDebugInfo('X(ioinfo): Error from select ('+
        inttostr(WSAGetLastError)+').');
      str:= str +' read='+inttostr(readfds.fd_count)
        +' write='+inttostr(writefds.fd_count)
        +' error='+inttostr(errorfds.fd_count);

      (* Check if still connected *)
      SockOptErrCode := 0;
      ErrorCodeSize:= Sizeof(SockOptErrCode);
      Status :=  GetSockOpt( SockHand,SOL_SOCKET,SO_ERROR,
                                  @SockOptErrCode,
                                  ErrorcodeSize );

      (* if sockOptErrCode<>0 then *)
        str:= str + ' GetSockOpt=' + inttostr(sockopterrcode);

      IoCtlErrCode:= 0;
      Status := IoctlSocket( Sockhand,FionRead, NumberOfBytes);
      if( Status <> 0 ) then begin
         IoCtlErrCode := WSAGetLastError;
         str:= str + ' ioctl=' + inttostr(ioctlerrcode);
         end
      else if numberofbytes>0 then
         str:= str + ' nofbytes=' + inttostr(numberofbytes);

      end (* asocket *)
    else if kind=aserialport then begin

      pstate:= @state;
      if ClearCommError(comHand,errors,pstate) then begin
        str:= str + ' errors=' + inttostr(errors);
        str:= str + ' flags=' +  comstatetostrFpc(pstate^.flag0); // FPC
        // str:= str + ' flags=' +  comstatetostrDelphi(pstate^.flags); // Delphi
        str:= str + ' cbInQue=' + inttostr(pstate^.cbInQue);
        str:= str + ' cbOutQue=' + inttostr(pstate^.cbOutQue);
        end;
      end; // serial port
    end; (* socket/socket exists. *)

for i:= 1 to length(str) do fspshend(pfuncret,str[i]);

end; (*ioinfo*)


function ioReadableSocket(pHandle:Tsocket): boolean;
(* Return True if a recv call would not block. *)

var
readfds: TFDSet;
n: longint;
timeout: TTimeVal;
res: boolean;

begin (*ioreadablesocket*)

res:= false;

(* Check if someone has connected to us. *)
with readfds do begin
  fd_count:= 1;
  fd_array[0]:= pHandle;
  end;
(* {0,0} = return immediately *)
with timeout do begin
  tv_sec:= 0;
  tv_usec:= 0;
  end;

n:= select(0,@readfds,nil,nil,@timeout);
if n=socket_error then begin
  xProgramError('X(ioreadablesocket): Error from select ('+
    inttostr(WSAGetLastError)+').');
  res:= False;
  end
else res:= (n>0);

ioreadablesocket:= res;

end; (*ioReadableSocket*)


function ioReadableSocketWait(pHandle:Tsocket;ptimeoutms:integer): boolean;
(* Return True if a recv call would not block. Wait up to
   ptimeoutms for socket to become readable.
   Used by ioingetinput to avoid lockup if there is no
   data from a tcp/ip port. *)

var
readfds: TFDSet;
n: longint;
timeout: TTimeVal;
res: boolean;

begin (*ioreadablesocketWait*)

   res:= false;

   (* Check if someone has connected to us. *)
   with readfds do begin
      fd_count:= 1;
      fd_array[0]:= pHandle;
      end;
   (* {0,0} = return immediately *)
   with timeout do begin
      tv_sec:= ptimeoutms div 1000;
      tv_usec:= (ptimeoutms mod 1000)*1000;
      end;

   ioenableotherthreads(10);

   try
      if ptimeoutms=maxint then
         // blocking wait
         n:= select(0,@readfds,nil,nil,nil)
      else n:= select(0,@readfds,nil,nil,@timeout);
   finally
      iodisableotherthreads(10);
      end;

   if n=socket_error then begin
      xProgramError('X(ioreadablesocketwait): Error from select ('+
      inttostr(WSAGetLastError)+').');
      res:= False;
      end
   else res:= (n>0);

   ioreadableSocketWait:= res;

end; (*ioReadableSocketWait*)

function lpError2Str(perror: Cardinal): string;
var s: string;
begin
case perror of
   $0010: s:= 'CE_BREAK-The hardware detected a break condition';
   $0008: s:= 'CE_FRAME-The hardware detected a framing error.';
   $0002: s:= 'CE_OVERRUN-A character-buffer overrun has occurred. The next character is lost';
   $0001: s:= 'CE_RXOVER-An input buffer overflow has occurred. There is either no room in the input buffer, or a character was received after the end-of-file (EOF) character';
   $0004: s:= 'CE_RXPARITY-The hardware detected a parity error';
   else s:= '?';
   end;
lpError2Str:= s;

end;

function comstate2str(var pstate: Tcomstat): string;
var s: string;
begin
s:= 'flag0=' + inttostr(pstate.flag0) + 'cbInQue=' + inttostr(pstate.cbInQue) +
   'cbOutQue=' + inttostr(pstate.cbOutQue);
comstate2str:= s;
end;

function ioReadableSerialPort(pHandle:Thandle): boolean;
(* Return True if a recvSerialPort call would not block. *)

var
errors: Cardinal;
state: Tcomstat;
stateptr: pComstat;
res: boolean;
errco: integer;

begin (*ioReadableSerialPort*)

   res:= false;
   statePtr:= @state;
   if ClearCommError(phandle,errors,stateptr) then
      res:= (stateptr^.cbInque>0)
   else begin
      errco:= getlasterror;
      xProgramError('ioreadableSerialPort: Program error - ClearCommError '+
         'failed with lperror ' + inttostr(errors) + '('+lperror2Str(errors) + ')' +
         ', comstat = [' + comstate2str(state) +
         '] and getlasterror= ' + inttostr(errco) + '('+syserrormessage(errco)+').');
      res:= false;
      end;
   ioreadableSerialPort:= res;

end; (*ioReadableSerialPort*)


function ioBytesToRead(pHandle: tsocket): integer;
(* Tell number of bytes to read from a connected socket. *)
var
status,ioctlErrCode: integer;
numberofbytes: integer;

begin (*ioBytesToRead*)

    IoCtlErrCode:= 0;
    Status := IoctlSocket( pHandle,FionRead, NumberOfBytes);
    if( Status <> 0 ) then IoCtlErrCode := WSAGetLastError;
    ioBytesToRead:= numberofbytes;

end; (*iobytesToRead*)

(* iolockcount
   -----------
   Used by <debuginfo ...>
*)
function iolockcount: integer;
begin
iolockcount:= lockcount;
end;

(* ioenableotherthreads and iodisableotherthreads shall always be called around
   any system call which involves waiting. pid is used in error message if
   ioenableotherthreads finds that ioxlock has not been acquired. *)
var lastid: integer = 0;
lastidtab: array[1..10] of integer;
lastidnr: integer = 0;
lastidstr: string;

procedure ioenableOtherThreads(pid: integer);
var i,cnt: integer;
begin

if lockcount<0 then begin
   // (new:)
   i:= lastidnr+1;
   if i>10 then i:= 1;
   lastidstr:= '';
   for cnt:= 1 to 10 do begin
      lastidstr:= lastidstr+' '+inttostr(lastidtab[i]);
      i:= i+1;
      if i>10 then i:= 1;
      end;

   xProgramError('ioenableotherthreads: ioxlock has not been acquired (lockcnt='+
      inttostr(lockcount)+' lastids='+lastidstr+').')
   end

else begin

   // (for debug purpose:)
   lastidnr:= lastidnr+1;
   if lastidnr>10 then lastidnr:= 1;
   lastidtab[lastidnr]:= pid+100;

  (* Send any unsent socket data to prevent delays. *)
  iosenddata;

  (* Send unsent wbuf lines. *)
  iofWriteWbufToResarea(true);

  (* Remove lock. *)
  lockcount:= lockcount-1;
  lastid:= pid;
  ioxlock.release;
  end;

(* win32 version: *)
(* if critSectX.lockCount<>0 then
  xProgramError('X(ioenableotherthreads): Program error - lockcount'
  + ' (before leavecriticalsection) ='
  +inttostr(critSectX.lockCount)+'(0 was expected).'); *)
(*leaveCriticalSection(critSectX);*)
(* if critSectX.lockCount<>-1 then
  xProgramError('X(ioenableotherthreads): Program error - lockcount'
  + ' (after leavecriticalsection) ='
  +inttostr(critSectX.lockCount)+'(-1 was expected).'); *)

end; (*ioenableotherthreads*)

procedure iodisableOtherthreads(pid: integer);
(* Upon entering iodisableOtherThreads, lockcount is expected to be -1
   (not acquired), or 0 (acquired by an other thread). Example of the latter
   case is when a created thread is doing processing and has ioxlock acquired,
   and then a message is received in the main loop (procedure iofmainloop).
   Procedure ThreadMessage will then call iodisableotherthreads to acquire
   ioxLock, but since it is already acquired, it will have to wait until the
   created thread releases it. Lockcount can also become >0 but only if the
   same thread acquires it more than once.
   If the x program "dies" (the cursor stops blinking and it has to be
   closed the "hard" way) - the probably reason is that a thread has acquired
   the ioxlock without releasing it. An alternative possibility is also that it
   has acquried it twice (a thread can acquire the lock several times as long
   is it releases it as many times - see http://stackoverflow.com/questions/
   3626715/can-i-nest-critical-sections-is-tcriticalsection-nestable),
   and only released it once. Then comes a windows message that
   will wait in threadmessage to acquire x, but it will never succeed because
   ioxlock will never be completetely released.
   *)
var i,cnt: integer;
begin

if lockcount>0 then begin
   i:= lastidnr+1;
   if i>10 then i:= 1;
   lastidstr:= '';
   for cnt:= 1 to 10 do begin
      lastidstr:= lastidstr+' '+inttostr(lastidtab[i]);
      i:= i+1;
      if i>10 then i:= 1;
      end;

   xProgramError('iodisableotherthreads: lockcount was expected to be -1, but it was '+
      inttostr(lockcount)+' (lastids='+lastidstr+'). ioxLock has already been acquired?')
   end;

if lockcount<=0 then begin

   // (for debug purpose:)
   lastidnr:= lastidnr+1;
   if lastidnr>10 then lastidnr:= 1;
   lastidtab[lastidnr]:= pid;

   ioxlock.acquire;

   // (for debug purpose:)
   lastidnr:= lastidnr+1;
   if lastidnr>10 then lastidnr:= 1;
   lastidtab[lastidnr]:= pid+1000;

   lockcount:= lockcount+1;
   end;

(* if critSectX.lockCount<>-1 then
  xProgramError('X(iodisableotherthreads): Program error - lockcount'
  + ' (before entercriticalsection) ='
  +inttostr(critSectX.lockCount)+'(-1 was expected).');*)
(* EnterCriticalSection(critSectX);
if critSectX.lockCount<0 then
  xProgramError('X(iodisableotherthreads): Program error - lockcount'
  + ' (after entercriticalsection) ='
  +inttostr(critSectX.lockCount)+'(>=0 was expected).');*)
end; (*iodisableotherthreads*)

function ioOtherThreadsEnabled: boolean;
begin
ioOtherThreadsEnabled:= lockcount<0;
end;


procedure ioEnableAndSleep(milliseconds: Cardinal );
begin

if xFault then begin
   (* Reserve x if it is not reserved (reservation may have been omitted
      because of error). This is to prevent eternal loop:
      ioerrmess->ioEnableAndSleep->ionenableotherthreads->ioerrmess... *)
   if lockcount<0 then
      ioDisableOtherThreads(91);
   ioenableotherthreads(11)
   end

else ioenableotherthreads(11);

try
  sleep(milliseconds);
finally
  iodisableotherthreads(11);
  end;
end;


// Sleep without releasing x
procedure ioSimpleSleep(milliseconds: Cardinal );
begin
  sleep(milliseconds);
end;



procedure iogetindata(var punrbottom: ioinptr);
(* Return unrbottom (used by xcallstate for checks). *)
begin
punrbottom:= unrbottom;
end;

function iogetinfilenr: integer;
(* Return current input file number. *)
begin
iogetinfilenr:= curinfilep^.nr;
end;


function iogetinfileptr: Pointer;
(* Return pointer to current input file record. *)
begin
iogetinfileptr:= curinfilep;
end;


procedure ioStepUnreadCounter(pFileRecPtr: Pointer; pStep: integer);
(* Step unread string counter up (1) or down (-1). *)
begin
fileRecPtr(pFileRecPtr)^.unreadCount+= pStep;
end;


function ioInfileBinary: boolean;
(* Return true if current input file is binary. *)
begin
ioinfilebinary:= curinfilep^.binaryfile;
end;


function iogetoutfilenr: integer;
(* Return current output file number. *)
begin
if curoutfilep<>nil then iogetoutfilenr:= curoutfilep^.nr
else iogetoutfilenr:= 0;
end;

procedure ioinnr(pfilenr:ioint32; var pStateEnv: xStateEnv);
(* Go to an already existing file with number pfilenr. *)
var
frp: filerecptr; found: boolean;
ior: integer;

begin
frp:= files; found:= false;
while not (found or (frp=nil)) do begin

   if frp^.nr=pfilenr then found:= true
   else frp:= frp^.next;
   end;

if not found then begin
   if not xFault then begin
      xScriptError('X(iocheckexitstate): Unable to return to old input file. '
        + 'File no longer exists. (- return to console.)');
      ioin(consfs,eofs,[],-1,false,ionone,emptystr,false,false,pstateenv.cinp);
      end;
   end
else ioin(frp^.filename,eofs,[],-1,false,ionone,emptystr,false,false,pstateenv.cinp);

end; (*ioinnr*)

var
morecount: integer = 0;
lesscount: integer = 0;
undefcount: integer = 0;

procedure iocheckexitstate(var pStateEnv: xStateEnv; pcinp0: ioinptr);
(* Do checks upon return from a state.
   If preaction contained unread, then cinp shall be unchanged
   on exit. *)
var
count: integer;
more,less: boolean;
str: string;
inp: ioinptr;
nr: integer;
begin

(* 1. Check that if unread was done during preaction, then input pointer
   is at the same place as before calling the state. *)
if (pcinp0<>nil) and alCheckUnreadPosAtExit then begin

   // There was unread in preaction
   // Check that input pointer is at the same place as before calling
   // the state
   if pstateenv.cinp<>pcinp0 then begin
      more:= false; less:= false;
      if ioinunrbuf(pstateenv.cinp) then begin
         // we are in unrbuf
         if ioinunrbuf(pcinp0) then begin
            // We were in unrbuf
            if ioint32(pstateenv.cinp)>ioint32(pcinp0) then more:= true
            else less:= true;
            end
         else begin
            // We were not in unrbuf
            less:= true;
            end
         end
      else begin
         // we are not in unrbuf
         if ioinunrbuf(pcinp0) then
            // we were in unrbuf
            more:= true
         else
            // we were not in unrbuf
            // unable to tell if more or if less
            ;
         end;
      if more and (morecount<3) then begin
         inp:= pcinp0; count:= 0;
         while not ( (inp=pstateenv.cinp) or (count>20) ) do begin
            if (inp^=char(13)) or (inp^=char(10)) then str:= str+'(CR)'
            else str:= str + inp^;
            ioinforward(inp);
            count:= count+1;
            end;
         if inp<>pstateenv.cinp then str:= str+'...';
         xScriptError('X: Warning - more characters where read than was unread in the preaction.'+
            'Extra characters read were: "'+str+
            '".(<settings checkUnreadPosAtExit,no> can be used to disable this test)');
         morecount:= morecount+1
         end
      else if less and (lesscount<3) then begin
         inp:= pstateenv.cinp; count:= 0;
         while not ( (inp=pcinp0) or (count>20) ) do begin
            if inp^=char(13) then str:= str+'(CR)'
            else str:= str + inp^;
            ioinforward(inp);
            count:= count+1;
            end;
         if inp<>pstateenv.cinp then str:= str+'...';
         xScriptError('X: Warning - less characters were read than was unread in the preaction.'+
            'Not read characters read were: "'+str+
            '".(<settings checkUnreadPosAtExit,no> can be used to disable this test)');
         lesscount:= lesscount+1
         end
      else if not more and not less and (undefcount<3) then begin
         xScriptError('X: Warning - more or less characters where read than was'+
         ' unread in the preaction.'+
            ' (<settings checkUnreadPosAtExit,no> can be used to disable this test)');
         undefcount:= undefcount+1
         end;
      end; // cinp<>oldinp1
   end; // there was unread in preaction

end; (*iocheckexitstate*)


procedure iomarkeoffiles(var pstateenv: xstateenv);
(* Set a flag in all files where cinp or saveinp^ = eof.
   Used by ioin to give warning message when the same file is
   opened again, now positioned at the end. *)
var filep: filerecptr;
begin
filep:= files;
while filep<>nil do begin
   if filep^.kind=afile then begin
      if (curinfilep=filep) and (pstateenv.cinp^=eofs) then
         filep^.eofatentry:= true
      else if filep^.inpsave^=eofs then
         filep^.eofatentry:= true
      end;
   filep:= filep^.next;
   end;
end; (*iomarkeoffiles*)

function ioinreadable(pinp: ioinptr): boolean;
(* Return true if possible to read more data from current input file.
   Used by <eofr> (aleofr). *)
var res: boolean;
begin
res:= false;
with curinfilep^ do case kind of
   // Always possible to get data from the console (?!?)
   aconsole: res:= true;

   afile: if  pinp^=eofs then res:= true;

   asocket: begin
      if pinp^<>eofr then res:= true
      else if ioreadablesocket(sockhand) then begin
         (* (new:) *)
         res:= true;
         (* (old:) *)
         (* (Bfn 111202: Removed because alto does not expect ioinreadable to
            read data). However, it means that ioinreadable will return
            true if a socket connection is closed but this was not yet
            discovered by the receiving side.
         ioingetinput(pinp,true);
         if (pinp^<>eofr) and (pinp^<>eofs) then res:= true; *)
         end;
      end; // asocket

   aserialport: begin
      if pinp^<>eofr then res:= true
      else if ioreadableserialport(comhand) then res:= true;
      end;

   acircularbuffer: begin
      if pinp^<>eofr then res:= true;
      end;
   end; (*case*)
ioinreadable:= res;
end; (*ioinreadable*)


procedure iobacklines(plines: integer;var pinp:ioinptr);
(* Go plines lines back in current input file, if possible. *)
var str: string; bufp,inp:ioinptr; cnt: integer;
begin

str:= '';

with curinfilep^ do if kind=afile then begin

   (* Find the buffer where pinp is. *)
   bufp:= filebufp;
   while not ((bufp=nil) or
      (integer(pinp)>=integer(bufp)) and
         (integer(pinp)<=integer(bufp)+iobufsize-6) )
      do
      bufp:= ioinptrptr(integer(bufp)+iobufsize-4)^;

   if bufp<>nil then begin

      (* Find the beginning of plines before. *)
      inp:= pinp;
      cnt:= 0;
      while (cnt<plines) and (integer(inp)>integer(bufp)) do begin
         inp:= ioinptr(integer(inp)-1);
         if inp^=char(13) then cnt:= cnt+1;
         end;
      pinp:= inp;
      end;
   end;
end; (*iobacklines*)


function iogetlinesbefore(pinp:ioinptr;plines: integer): string;
(* Get plines lines before pinp in current input file. *)
var str: string; bufp,inp:ioinptr; cnt: integer;
begin

str:= '';

with curinfilep^ do if kind=afile then begin

   (* Find the buffer where pinp is. *)
   bufp:= filebufp;
   while not ((bufp=nil) or
      (integer(pinp)>=integer(bufp)) and
         (integer(pinp)<=integer(bufp)+iobufsize-6) )
      do
      bufp:= ioinptrptr(integer(bufp)+iobufsize-4)^;

   if bufp<>nil then begin

      (* Find the beginning of plines before. *)
      inp:= pinp;
      cnt:= 0;
      while (cnt<plines) and (integer(inp)>integer(bufp)) do begin
         inp:= ioinptr(integer(inp)-1);
         if inp^=char(13) then cnt:= cnt+1;
         end;
      while not (inp=pinp) do begin
         str:= str + inp^;
         inp:= ioinptr(integer(inp)+1);
         end;
      end;

   end;

(* Return string. *)
iogetlinesbefore:= str;

end; (*iogetlinesbefore*)

function iogetlinesafter(pinp:ioinptr;plines: integer): string;
(* Get plines lines after pinp in current input file. *)
var str: string; bufp,inp:ioinptr; cnt: integer;
begin

str:= '';

inp:= pinp;
cnt:= 0;

while (cnt<plines) and (inp^<>eofr) and (inp^<>eofs) do begin
   str:= str + inp^;
   if (inp^=char(13)) or (inp^=char(10)) then begin
      cnt:= cnt+1;
      str:= str + char(10);
      end;
   ioinforward(inp);
   end;

iogetlinesafter:= str;

end; (* iogetlinesafter *)


// For debug purposes:
// Log to x.log
var
logFileOpened: boolean = false;
logFileError: boolean = false;
logFile: textFile;


procedure ioLog(pStr: string);
var ior: integer;
begin
if not logFileOpened and not logFileError then begin
   {$I-}
   AssignFile(logFile,'x.log');
   ior:= ioResult;
   if ior=0 then begin
      rewrite(logFile);
      ior:= ioResult;
      end;
   if ior=0 then logFileOpened:= true
   else logFileError:= true;
   {$I+}
   end;

if logFileOpened then writeln(logFile,pStr);

end;(* ioLog *)


// Old stuff:



procedure iotest;

begin

(* Empty for time being. *)

end; (*iotest*)


end. (* FIL *)






