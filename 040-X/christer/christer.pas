program christer;

uses SysUtils;


function fib(n:int32):int32;
begin
	if n<2 then fib := n else fib := fib(n-1) + fib(n-2)
end;

var z: int32 = 0;
var i: int32;
var antal:int32 = 0;
begin
	writeln(TimeToStr(Time));
	for i:=1 to 10
	 do begin
		z := fib(25);
		antal := antal+1;
	end;
	writeln(z);
	writeln(TimeToStr(Time));
end.