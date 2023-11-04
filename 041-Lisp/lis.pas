program lis;

uses Classes, TStringHelper;


var
	myList : TList;
	a,b,c,d,e,f,g,h,i : TList;

	a1 : String = '-';
	a2 : String = 'n';
	a3 : Integer = 2;

	b1 : String = 'fib';

	c1 : String = '-';
	c2 : String = 'n';
	c3 : Integer = 2;

	d1 : String = 'fib';

	e1 : String = '+';

	f1 : String = '<';
	f2 : String = 'n';
	f3 : Integer = 2;

	g1 : String = 'if';
	g3 : Integer = 1;

	h1 : String = 'n';

	i1 : String = 'lambda';

// i          h      g      f                 e     d       c               b       a
// ['lambda', ['n'], ['if', ['<', 'n', 2], 1, ['+', ['fib', ['-', 'n', 1]], ['fib', ['-', 'n', 2]]]]]


// function tokenize(s:String): String
// begin
// 	return s.replace('(',' ( ').replace(')',' ) ').split()
// end;

begin

	TStringHelper.SplitString("adam bertil",' ');


	a := TList.Create;
	b := TList.Create;
	c := TList.Create;
	d := TList.Create;
	e := TList.Create;
	f := TList.Create;
	g := TList.Create;
	h := TList.Create;
	i := TList.Create;

	a.Add(@a1); // -
	a.Add(@a2); // n
	a.Add(@a3); // 2

	b.Add(@b1); // fib
	b.Add(@a);

	c.Add(@c1);
	c.Add(@c2);
	c.Add(@c3);

	d.Add(@d1);
	d.Add(@c);

	e.Add(@e1);
	e.Add(@d);
	e.Add(@b);

	f.Add(@f1);
	f.Add(@f2);
	f.Add(@f3);

	g.Add(@g1);
	g.Add(@f);
	g.Add(@g3);
	g.Add(@e);

	h.Add(@h1);

	i.Add(@i1);
	i.Add(@h);
	i.Add(@g);

end.