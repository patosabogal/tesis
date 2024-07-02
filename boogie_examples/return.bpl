procedure returner() returns(variable: int);
implementation returner() returns(variable: int) {
	variable := 1;
	return;
}
procedure test();
implementation test() {
var a : int;
a := 0;
call a := returner();
assert a > 0;
}
