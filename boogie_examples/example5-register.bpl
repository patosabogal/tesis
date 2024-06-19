function to_int(boolan: bool) returns (int);
axiom to_int(true) == 1;
axiom to_int(false) == 0;
var arg: int;

procedure contract();
implementation contract(){
	var a: int;
	var b: int;
	var c: int;
	var d: int;
	var e: int;
	a := 0;
	check:
		b := a;
		c := arg;
		d := to_int(b == c);
		if (d == 0) {
			goto add_1;
		}
		assert a < 256;
		return;
	add_1:
		e := 1;
		a := a + e;
		goto check;
}

procedure verify();
implementation verify() {
call contract();
}


