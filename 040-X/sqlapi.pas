unit sqlapi;

{$MODE Delphi}

interface

(* Hämtat från C:\Program\GM - Components\Pas\GMOdbcAPI.pas: *)
type
  SQLCHAR = Char;
  SQLPCHAR = ^Char;
  SQLSCHAR = Byte;
  SQLDATE = Char;
  SQLDECIMAL = Char;
  SQLDOUBLE = double;
  SQLFLOAT = double;
  SQLINTEGER = LongInt;
  SQLPINTEGER = ^SQLINTEGER;
  SQLUINTEGER = LongWord;
  SQLPUINTEGER = ^SQLUINTEGER;
  SQLNUMERIC = Char;
  SQLPOINTER = Pointer;
  SQLPPOINTER = ^SQLPOINTER;
  SQLREAL = single;
  SQLSMALLINT = Smallint;
  SQLPSMALLINT = ^SQLSMALLINT;
  SQLUSMALLINT = Word;
  SQLPUSMALLINT = ^SQLUSMALLINT;
  SQLTIME = Char;
  SQLTIMESTAMP = Char;
  SQLVARCHAR = Char;

  SQLRETURN = SQLSMALLINT;

  SQLHANDLE = LongWord;
  SQLPHANDLE = ^SQLHANDLE;

  SQLHENV = SQLHANDLE;
  SQLHDBC = SQLHANDLE;
  SQLHSTMT = SQLHANDLE;
  SQLHDESC = SQLHANDLE;

const

  ODBC32_DLL = 'ODBC32.DLL';
  CODBCFractionFactor = 1000000;
  CStrSQLAllocEnv                = 'SQLAllocEnv';
  CStrSQLAllocConnect            = 'SQLAllocConnect';
  CStrSQLConnect                 = 'SQLConnect';
  CStrSQLAllocStmt               = 'SQLAllocStmt';
  CStrSQLExecDirect              = 'SQLExecDirect';
  CStrSQLFetch                   = 'SQLFetch';
  CStrSQLGetData                 = 'SQLGetData';
  CStrSQLDisconnect              = 'SQLDisconnect';
  CStrSQLNumResultCols           = 'SQLNumResultCols';

  {$EXTERNALSYM SQL_SUCCESS}
  SQL_SUCCESS                                       = 0;
  {$EXTERNALSYM SQL_SUCCESS_WITH_INFO}
  SQL_SUCCESS_WITH_INFO                             = 1;

  {$EXTERNALSYM SQL_API_SQLALLOCCONNECT}
  SQL_API_SQLALLOCCONNECT                           = 1;
  {$EXTERNALSYM SQL_API_SQLALLOCENV}
  SQL_API_SQLALLOCENV                               = 2;

  {$EXTERNALSYM SQL_CHAR}
  SQL_CHAR                                          = 1;

  {$EXTERNALSYM SQL_C_CHAR}
  SQL_C_CHAR                                        = SQL_CHAR;

  {$EXTERNALSYM SQL_NULL_DATA}
  SQL_NULL_DATA                                     = -1;

{$EXTERNALSYM SQLAllocEnv}
function SQLAllocEnv(var EnvironmentHandle: SQLHENV): SQLRETURN; stdcall;

{$EXTERNALSYM SQLAllocConnect}
function SQLAllocConnect(EnvironmentHandle: SQLHENV; var ConnectionHandle: SQLHDBC): SQLRETURN; stdcall;

{$EXTERNALSYM SQLConnect}
function SQLConnect(ConnectionHandle: SQLHDBC;
            ServerName: SQLPCHAR; NameLength1: SQLSMALLINT;
            UserName: SQLPCHAR; NameLength2: SQLSMALLINT;
            Authentication: SQLPCHAR; NameLength3: SQLSMALLINT): SQLRETURN; stdcall;

{$EXTERNALSYM SQLAllocStmt}
function SQLAllocStmt(ConnectionHandle: SQLHDBC; var StatementHandle: SQLHSTMT): SQLRETURN; stdcall;

{$EXTERNALSYM SQLExecDirect}
function SQLExecDirect(StatementHandle: SQLHSTMT;
            StatementText: SQLPCHAR;
            TextLength: SQLINTEGER): SQLRETURN; stdcall;

{$EXTERNALSYM SQLNumResultCols}
function SQLNumResultCols(StatementHandle: SQLHSTMT; var ColumnCount: SQLSMALLINT): SQLRETURN; stdcall;

{$EXTERNALSYM SQLFetch}
function SQLFetch(StatementHandle: SQLHSTMT): SQLRETURN; stdcall;

{$EXTERNALSYM SQLGetData}
function SQLGetData(StatementHandle: SQLHSTMT;
            ColumnNumber: SQLUSMALLINT; TargetType: SQLSMALLINT;
            TargetValue: SQLPOINTER; BufferLength: SQLINTEGER;
            pStrLen_or_Ind: SQLPINTEGER): SQLRETURN; stdcall;

{$EXTERNALSYM SQLDisconnect}
function SQLDisconnect(ConnectionHandle: SQLHDBC): SQLRETURN; stdcall;


function ODBCSucceeded(const ReturnCode: SQLRETURN): Boolean;

implementation

function SQLAllocEnv;                external ODBC32_DLL name CStrSQLAllocEnv;
function SQLAllocConnect;            external ODBC32_DLL name CStrSQLAllocConnect;
function SQLConnect;                 external ODBC32_DLL name CStrSQLConnect;
function SQLAllocStmt;               external ODBC32_DLL name CStrSQLAllocStmt;
function SQLExecDirect;              external ODBC32_DLL name CStrSQLExecDirect;
function SQLNumResultCols;           external ODBC32_DLL name CStrSQLNumResultCols;
function SQLFetch;                   external ODBC32_DLL name CStrSQLFetch;
function SQLGetData;                 external ODBC32_DLL name CStrSQLGetData;
function SQLDisconnect;              external ODBC32_DLL name CStrSQLDisconnect;

function ODBCSucceeded(const ReturnCode: SQLRETURN): Boolean;
begin
  Result := (ReturnCode = SQL_SUCCESS) or (ReturnCode = SQL_SUCCESS_WITH_INFO);
end;

end.
